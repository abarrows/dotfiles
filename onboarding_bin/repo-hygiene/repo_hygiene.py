#!/usr/bin/env python3
"""repo-hygiene: keep ~/Retail-Success/repos/* down to active work and default branches.

Subcommands (all read-only except `apply --execute` and `recover-worktrees --execute`):
  audit              fetch, enumerate branches/worktrees/stashes/orphan dirs, classify, write audit JSON
  manifest           turn the latest audit into an editable manifest.tsv with rule-based defaults
  apply              validate the manifest, archive (bundle + patches), then delete; dry-run by default
  verify             check the end-state invariants; --restore-test round-trips the last bundle
  restore            fetch refs back out of a bundle
  recover-worktrees  repair or salvage broken worktree registrations and orphan directories

Design rules: stdlib only; deterministic; idempotent; never calls rebase, reset --hard or push --force.
"""
from __future__ import annotations

import argparse
import collections
import datetime as dt
import fnmatch
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile

try:
    import tomllib
except ImportError:  # pragma: no cover
    tomllib = None

VERSION = "0.1.0"
HERE = os.path.dirname(os.path.realpath(__file__))
NOW = dt.datetime.now(dt.timezone.utc)
TS = NOW.strftime("%Y%m%d-%H%M%S")

DEFAULT_CONFIG = {
    "root": os.path.expanduser("~/Retail-Success/repos"),
    "archive": os.path.expanduser("~/Retail-Success/repos/.archive"),
    "categories": ["admins", "development-team", "digital-products", "digital-services", "personal"],
    "protected": ["develop", "main", "master", "production", "staging", "main-public",
                  "release/*", "hotfix/v*", "merge-down/*"],
    "noise_paths": [".codegraph/*", "*.tsbuildinfo", ".husky/_/*", ".claude/*", ".DS_Store", "*/.DS_Store"],
    "stash_noise": [r"^autostash$", r"^lint-staged automatic backup$", r"^Teleport auto-stash$"],
    "branch_noise": [r"^cascade/", r"^worktree-agent-", r"^dependabot/", r"^claude/[a-z]+-[a-z]+-[0-9a-f]{6}$"],
    "generated_paths": ["src/types/api/*", "*package-lock.json", "*yarn.lock", "*pnpm-lock.yaml", "*.snap", "*/dist/*", "*/build/*",
                        "*/coverage/*", "*.min.js", "*.min.css", "*/storybook-static/*", "*.tsbuildinfo", "*/mocks/handlers/handlers.js"],
    "thresholds": {"branch_age_days": 180, "stash_age_days": 90, "idle_worktree_days": 14,
                   "oversized_bytes": 1 << 30},
    "repos": {},
}

BRANCH_ACTIONS = {"keep", "pr", "archive-delete", "review", "blocked", "note"}
WORKTREE_ACTIONS = {"keep", "migrate", "remove", "repair", "salvage-remove", "review", "blocked", "note"}
STASH_ACTIONS = {"keep", "export-drop", "drop", "review"}
MANIFEST_COLUMNS = ["kind", "action", "bucket", "name", "sha", "age_d", "ahead", "behind", "pr", "evidence", "reason"]


# ----------------------------------------------------------------------------- helpers
class HygieneError(RuntimeError):
    pass


def run(args, cwd=None, check=True, env=None, input=None):
    # `args` is always a list and `shell` is never enabled, so the shell never parses any of it:
    # branch names containing ;, |, $() and friends are inert. The residual risk is argument
    # injection - a ref literally named `--upload-pack=...` would be read by git as an option -
    # so any such name is refused before it reaches git (see `safe_ref`).
    r = subprocess.run(args, cwd=cwd, capture_output=True, text=True, env=env, input=input)
    if check and r.returncode != 0:
        raise HygieneError(f"{' '.join(args)} (cwd={cwd}) rc={r.returncode}: {r.stderr.strip()}")
    return r


def safe_ref(name):
    """Refuse ref names that git would read as options. Git forbids these anyway, so a name like
    this means something is wrong (or hostile) rather than merely unusual."""
    if name.startswith("-"):
        raise HygieneError(f"refusing to act on a ref whose name starts with '-': {name!r}")
    return name


def git(repo, *args, check=True, env=None, input=None):
    return run(["git", "-C", repo, *args], check=check, env=env, input=input)


def gout(repo, *args, default=""):
    r = git(repo, *args, check=False)
    return r.stdout.strip() if r.returncode == 0 else default


def ref_exists(repo, ref):
    return git(repo, "show-ref", "--verify", "--quiet", ref, check=False).returncode == 0


def is_ancestor(repo, a, b):
    return git(repo, "merge-base", "--is-ancestor", a, b, check=False).returncode == 0


def commit_exists(repo, sha):
    return bool(sha) and git(repo, "cat-file", "-e", f"{sha}^{{commit}}", check=False).returncode == 0


def sha256_file(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def age_days(iso):
    try:
        d = dt.datetime.fromisoformat(iso)
        if d.tzinfo is None:
            d = d.replace(tzinfo=dt.timezone.utc)
        return (NOW - d).days
    except Exception:
        return None


def du_bytes(path):
    total = 0
    for dirpath, dirnames, filenames in os.walk(path, onerror=lambda e: None):
        for fn in filenames:
            try:
                total += os.lstat(os.path.join(dirpath, fn)).st_size
            except OSError:
                pass
    return total


def human(n):
    for unit in ("B", "KB", "MB", "GB", "TB"):
        if n < 1024:
            return f"{n:.0f}{unit}" if unit == "B" else f"{n:.1f}{unit}"
        n /= 1024
    return f"{n:.1f}PB"


def slug_from_url(url):
    m = re.search(r"github\.com[:/]([^/]+)/([^/]+?)(?:\.git)?/?$", url or "")
    return f"{m.group(1)}/{m.group(2)}" if m else ""


def load_config(path):
    cfg = json.loads(json.dumps(DEFAULT_CONFIG))
    if path and os.path.exists(path):
        if tomllib is None:
            raise HygieneError("python >= 3.11 is required for TOML config")
        with open(path, "rb") as f:
            user = tomllib.load(f)
        for k, v in user.items():
            if isinstance(v, dict) and isinstance(cfg.get(k), dict):
                cfg[k].update(v)
            else:
                cfg[k] = v
    cfg["root"] = os.path.realpath(os.path.expanduser(cfg["root"]))
    cfg["archive"] = os.path.realpath(os.path.expanduser(cfg["archive"]))
    return cfg


def discover_repos(cfg):
    out = []
    for cat in cfg["categories"]:
        d = os.path.join(cfg["root"], cat)
        if not os.path.isdir(d):
            continue
        for name in sorted(os.listdir(d)):
            if os.path.isdir(os.path.join(d, name, ".git")):
                out.append(f"{cat}/{name}")
    return out


# ----------------------------------------------------------------------------- repo context
class Repo:
    def __init__(self, cfg, rel):
        self.cfg = cfg
        self.rel = rel.strip("/")
        if self.rel.count("/") != 1:
            raise HygieneError(f"--repo must be <category>/<name>, got {rel!r}")
        self.category, self.name = self.rel.split("/")
        self.path = os.path.realpath(os.path.join(cfg["root"], self.rel))
        if not os.path.isdir(os.path.join(self.path, ".git")):
            raise HygieneError(f"not a main git checkout: {self.path}")
        self.opts = cfg.get("repos", {}).get(self.rel, {})
        self.archive = os.path.join(cfg["archive"], self.rel.replace("/", "__"))
        self.remote_url = gout(self.path, "remote", "get-url", "origin")
        self.has_remote = bool(self.remote_url) and self.opts.get("remote") != "none"
        self.slug = slug_from_url(self.remote_url) if self.has_remote else ""
        self.local_branches = [b for b in gout(self.path, "for-each-ref", "refs/heads", "--format=%(refname:short)").split("\n") if b]
        self.default = self.opts.get("default") or self.detect_default()
        self.protected_local = [b for b in self.local_branches if self.is_protected(b)]
        self.targets = self.integration_targets()
        self.primary = self.targets[0] if self.targets else None
        self.thr = cfg["thresholds"]
        self._blob_hist = {}

    def detect_default(self):
        head = gout(self.path, "symbolic-ref", "--short", "refs/remotes/origin/HEAD").replace("origin/", "")
        if head and self.is_protected(head):
            return head
        for cand in ("develop", "main", "master", "production"):
            if cand in self.local_branches:
                return cand
        return head or "main"

    def is_protected(self, name):
        return any(fnmatch.fnmatchcase(name, pat) for pat in self.cfg["protected"] + list(self.opts.get("protected_extra", [])))

    def integration_targets(self):
        targets = []
        remote_protected = [l.replace("refs/remotes/origin/", "") for l in gout(self.path, "for-each-ref", "refs/remotes/origin", "--format=%(refname)").split("\n")
                            if l and l != "refs/remotes/origin/HEAD" and self.is_protected(l.replace("refs/remotes/origin/", ""))]
        for b in [self.default] + sorted(set(self.protected_local) | set(remote_protected)):
            for ref in (f"origin/{b}", b):
                if ref not in targets and (ref_exists(self.path, f"refs/remotes/{ref}") if ref.startswith("origin/") else ref_exists(self.path, f"refs/heads/{ref}")):
                    targets.append(ref)
        return targets

    def protected_refs_full(self):
        out = [f"refs/heads/{b}" for b in self.protected_local]
        for line in gout(self.path, "for-each-ref", "refs/remotes/origin", "--format=%(refname)").split("\n"):
            short = line.replace("refs/remotes/origin/", "")
            if line and short != "HEAD" and self.is_protected(short):
                out.append(line)
        return out

    def is_noise_path(self, p):
        return any(fnmatch.fnmatchcase(p, pat) for pat in self.cfg["noise_paths"])

    def is_generated_path(self, p):
        pats = list(self.cfg.get("generated_paths", [])) + list(self.opts.get("generated_extra", []))
        return any(fnmatch.fnmatchcase(p, pat) for pat in pats)

    def changed_paths(self, base, head):
        """Paths the branch introduces relative to the merge base. NUL-separated, so paths with
        spaces, quotes or non-ASCII are exact (--name-only would quote and escape them)."""
        out = git(self.path, "diff", "-z", "--name-only", f"{base}...{head}", check=False).stdout
        return [p for p in out.split("\0") if p]

    def blob_map(self, ref, paths):
        """path -> blob sha for `ref`, restricted to `paths`. Missing paths are simply absent."""
        want = set(paths)
        out = git(self.path, "ls-tree", "-r", "-z", "--format=%(objectname) %(path)", ref, check=False).stdout
        m = {}
        for rec in out.split("\0"):
            if not rec:
                continue
            sha, _, path = rec.partition(" ")
            if path in want:
                m[path] = sha
        return m

    def blob_ever_on(self, ref, path, blob, limit=400):
        """True if `blob` was ever the content of `path` anywhere in `ref`'s history.
        A file differing from the target does not mean the branch's work is missing: the target
        usually moved on after the merge. What matters is whether this exact version ever landed."""
        key = (ref, path)
        if key not in self._blob_hist:
            commits = [c for c in gout(self.path, "log", "--format=%H", "-n", str(limit), ref, "--", path).split("\n") if c]
            seen = set()
            for c in commits:
                sha = gout(self.path, "rev-parse", f"{c}:{path}")
                if sha:
                    seen.add(sha)
            self._blob_hist[key] = seen
        return blob in self._blob_hist[key]

    def havens(self, extra=()):
        """Refs where content would still be found: the integration targets (develop, master,
        release/*) plus any open-PR branches. Work merged to a release branch, or still sitting
        on an open PR, is not lost just because the default branch lacks it."""
        return list(dict.fromkeys(list(self.targets) + [r for r in extra if r]))

    def unique_lines(self, base, head, path, havens=None):
        """Lines this branch ADDED to `path` (vs the merge base) that appear nowhere in `base`'s
        current version of it. An older version that the target later rewrote contributes none:
        its lines are either still there or were deliberately replaced. Non-empty means content
        that exists only on this branch."""
        mb = gout(self.path, "merge-base", base, head)
        if not mb:
            return []
        after = gout(self.path, "show", f"{head}:{path}", default="")
        if not after:
            return []
        before_set = {l.strip() for l in gout(self.path, "show", f"{mb}:{path}", default="").split("\n")}
        safe = set()
        for ref in (havens if havens is not None else [base]):
            safe |= {l.strip() for l in gout(self.path, "show", f"{ref}:{path}", default="").split("\n")}
        added = [l for l in after.split("\n") if l.strip() and l.strip() not in before_set]
        return [l for l in added if l.strip() not in safe]

    def never_landed(self, base, head, havens=None):
        """Hand-written paths whose version on `head` never existed in the history of any haven."""
        diffs, n = self.hand_differences(base, head)
        if not diffs:
            return [], n
        hm = self.blob_map(head, diffs)
        refs = havens if havens is not None else [base]
        return [p for p in diffs if not any(self.blob_ever_on(r, p, hm.get(p, "")) for r in refs)], n

    def hand_differences(self, base, head):
        """Hand-written paths whose content differs between `head` and `base`.
        Generated artifacts (indexes, maps, lockfiles, build output) and tool noise are excluded:
        they differ on every branch simply because the target moved on, and they are regenerated,
        not authored. Squash merges defeat commit-level comparison, so this compares blob ids over
        just the paths the branch touches - no pathspec quoting, no dependence on merge style."""
        paths = [p for p in self.changed_paths(base, head)
                 if not self.is_generated_path(p) and not self.is_noise_path(p)]
        if not paths:
            return [], 0
        hm, bm = self.blob_map(head, paths), self.blob_map(base, paths)
        return sorted(p for p in paths if hm.get(p) != bm.get(p)), len(paths)

    def content_superseded(self, base, head):
        """True when the branch touches hand-written files and every one of them already has
        identical content on `base`."""
        diffs, n = self.hand_differences(base, head)
        return n > 0 and not diffs

    def change_summary(self, base, head, paths_only=False):
        """Diffstat between base...head split into hand-written vs generated files.
        When the histories share no ancestor, compare the two trees directly and say so."""
        unrelated = git(self.path, "merge-base", base, head, check=False).returncode != 0
        rng = f"{base} {head}" if unrelated else f"{base}...{head}"
        names = [l for l in gout(self.path, "diff", "--name-only", *rng.split()).split("\n") if l]
        hand = [n for n in names if not self.is_generated_path(n) and not self.is_noise_path(n)]
        gen = [n for n in names if n not in hand]
        ins = dels = 0
        if hand:
            for line in gout(self.path, "diff", "--numstat", *rng.split(), "--", *hand[:400]).split("\n"):
                parts = line.split("\t")
                if len(parts) == 3 and parts[0].isdigit() and parts[1].isdigit():
                    ins += int(parts[0]); dels += int(parts[1])
        only_in_head = [l for l in gout(self.path, "diff", "--name-only", "--diff-filter=A", *rng.split()).split("\n") if l] if unrelated else []
        return {"files": len(names), "hand_files": len(hand), "gen_files": len(gen), "ins": ins, "dels": dels, "top_files": hand[:8] or gen[:4],
                "unrelated_history": unrelated, "only_in_branch": only_in_head[:12], "only_in_branch_count": len(only_in_head)}

    @staticmethod
    def value_rating(summary, unique_commits, age, stranded=0):
        lines = (summary or {}).get("ins", 0) + (summary or {}).get("dels", 0)
        hand = (summary or {}).get("hand_files", 0)
        if unique_commits == 0 and lines == 0:
            return "none"
        if hand == 0 or lines < 10:
            return "low"
        score = lines + 25 * hand + 40 * stranded
        if age is not None and age < 90:
            score *= 1.5
        return "high" if score >= 400 else "medium"

    def is_noise_branch(self, name):
        return any(re.search(pat, name) for pat in self.cfg["branch_noise"])

    def is_noise_stash(self, subject):
        return any(re.search(pat, subject) for pat in self.cfg["stash_noise"])

    def worktree_home(self):
        return os.path.join(self.path, ".claude", "worktrees")

    def layout_ok(self, wt_path):
        return os.path.dirname(os.path.realpath(wt_path)) == os.path.realpath(self.worktree_home())

    def status_split(self, wt_path):
        """Return (real_dirt, noise_dirt) lists for a checkout (modified + untracked)."""
        r = git(wt_path, "status", "--porcelain", "--untracked-files=all", check=False)
        real, noise = [], []
        for line in r.stdout.split("\n"):
            if not line.strip():
                continue
            p = line[3:]
            if " -> " in p:
                p = p.split(" -> ")[-1]
            p = p.strip('"')
            (noise if self.is_noise_path(p) else real).append(line)
        return real, noise

    def latest_audit_path(self):
        p = os.path.join(self.archive, "audit-latest.json")
        return p if os.path.exists(p) else None

    def load_audit(self):
        p = self.latest_audit_path()
        if not p:
            raise HygieneError(f"no audit for {self.rel}; run `audit --repo {self.rel}` first")
        with open(p) as f:
            return json.load(f)


# ----------------------------------------------------------------------------- PR data
PR_FIELDS = "number,state,headRefName,headRefOid,baseRefName,mergedAt,closedAt,mergeCommit,author,title,isDraft"


def fetch_prs(repo: Repo, log):
    if not repo.slug or not shutil.which("gh"):
        log(f"  PRs: skipped (slug={repo.slug or '-'}, gh={'yes' if shutil.which('gh') else 'no'})")
        return {}, "none"
    os.makedirs(repo.archive, exist_ok=True)
    cache = os.path.join(repo.archive, f"prs-{NOW:%Y-%m-%d}.json")
    if os.path.exists(cache):
        with open(cache) as f:
            data = json.load(f)
        src = "cache"
    else:
        r = run(["gh", "pr", "list", "-R", repo.slug, "--state", "all", "--limit", "3000", "--json", PR_FIELDS], check=False)
        if r.returncode != 0:
            log(f"  PRs: gh failed: {r.stderr.strip()[:200]}")
            return {}, "failed"
        data = json.loads(r.stdout)
        with open(cache, "w") as f:
            json.dump(data, f)
        src = "gh"
    by_head = collections.defaultdict(list)
    for p in data:
        by_head[p["headRefName"]].append(p)
    log(f"  PRs: {len(data)} from {src}")
    return by_head, src


def best_pr(prs_for_head):
    for st in ("OPEN", "MERGED", "CLOSED"):
        for p in prs_for_head or []:
            if p["state"] == st:
                return p
    return None


# ----------------------------------------------------------------------------- audit
def audit_repo(repo: Repo, log, fetch=True):
    os.makedirs(repo.archive, exist_ok=True)
    log(f"== audit {repo.rel} (default={repo.default}, targets={repo.targets}, slug={repo.slug or '-'})")
    fetch_ok = True
    if fetch and repo.has_remote:
        r = git(repo.path, "fetch", "--prune", "origin", check=False)
        fetch_ok = r.returncode == 0
        log(f"  fetch --prune: {'ok' if fetch_ok else 'FAILED ' + r.stderr.strip()[:200]}")
        if fetch_ok:
            repo.targets = repo.integration_targets()
            repo.primary = repo.targets[0] if repo.targets else None
    prs, pr_source = fetch_prs(repo, log)

    # --- worktrees
    worktrees = parse_worktrees(repo)
    wt_by_branch = {w["branch"]: w for w in worktrees if w.get("branch")}
    main_wt = worktrees[0] if worktrees else None
    for w in worktrees:
        if w["present"]:
            real, noise = repo.status_split(w["path"])
            w["dirt"], w["noise"] = real, noise
            w["head"] = gout(w["path"], "rev-parse", "HEAD")
            if real:
                paths = [l[3:].split(" -> ")[-1].strip('"') for l in real]
                ins = dels = 0
                tracked = [l[3:].split(" -> ")[-1].strip('"') for l in real if not l.startswith("??")]
                for line in gout(w["path"], "diff", "--numstat", "HEAD", "--", *tracked[:400]).split("\n"):
                    parts = line.split("\t")
                    if len(parts) == 3 and parts[0].isdigit() and parts[1].isdigit():
                        ins += int(parts[0]); dels += int(parts[1])
                untracked = [l[3:] for l in real if l.startswith("??")]
                w["dirt_detail"] = {"files": len(real), "untracked": len(untracked), "ins": ins, "dels": dels,
                                    "top_files": [p for p in paths if not repo.is_generated_path(p)][:8]}
                w["value"] = repo.value_rating({"ins": ins, "dels": dels, "hand_files": len([p for p in paths if not repo.is_generated_path(p)])}, len(real), w.get("last_touch"))
            else:
                w["dirt_detail"], w["value"] = None, "none"
            w["size"] = du_bytes(w["path"]) if w["kind"] == "linked" else 0
            w["last_touch"] = int(NOW.timestamp() - os.stat(w["path"]).st_mtime) // 86400
        else:
            w["dirt"], w["noise"], w["head"], w["size"], w["last_touch"] = [], [], "", 0, None
            w["dirt_detail"], w["value"] = None, "unknown"
        w["layout_ok"] = w["kind"] == "main" or repo.layout_ok(w["path"])
        w["in_progress"] = in_progress_ops(repo, w)

    # --- orphan directories
    orphans = scan_orphans(repo, worktrees)

    # A merged PR's head often is not local (review suggestions committed on GitHub, then the
    # branch deleted). Without it, "did this land?" is undecidable. refs/pull/<n>/head still
    # resolves after a merge, so fetch the ones we lack in a single batch.
    if repo.has_remote and prs:
        want = []
        for name, lst in prs.items():
            if not any(b == name for b in repo.local_branches):
                continue
            pr = best_pr(lst)
            if pr and pr["state"] == "MERGED" and pr.get("headRefOid") and not commit_exists(repo.path, pr["headRefOid"]):
                want.append(pr["number"])
        for i in range(0, len(want), 60):
            chunk = want[i:i + 60]
            specs = [f"+refs/pull/{n}/head:refs/archive/pr/{n}" for n in chunk]
            git(repo.path, "fetch", "--no-tags", "--quiet", "origin", *specs, check=False)
        if want:
            log(f"  fetched {len(want)} merged-PR head(s) so their branches can be judged")

    # --- branches
    merged_sets = {t: set(gout(repo.path, "branch", "--format=%(refname:short)", "--merged", t).split("\n")) for t in repo.targets}
    open_pr_branches = []
    fmt = "%(refname:short)%09%(objectname)%09%(upstream:short)%09%(upstream:track,nobracket)%09%(committerdate:iso8601-strict)%09%(subject)"
    branches = []
    for row in gout(repo.path, "for-each-ref", "refs/heads", f"--format={fmt}").split("\n"):
        if not row:
            continue
        name, sha, up, track, cdate, subject = (row.split("\t") + [""] * 6)[:6]
        b = {"name": name, "sha": sha, "upstream": up, "track": track, "commit_date": cdate[:10],
             "age_days": age_days(cdate), "subject": subject[:100], "protected": repo.is_protected(name),
             "noise": repo.is_noise_branch(name), "merged_into": [t for t, s in merged_sets.items() if name in s],
             "worktree": wt_by_branch.get(name, {}).get("path", ""),
             "checked_out_main": bool(main_wt and main_wt.get("branch") == name)}
        if repo.primary:
            lr = gout(repo.path, "rev-list", "--left-right", "--count", f"{repo.primary}...{name}")
            behind, ahead = (lr.split() + ["0", "0"])[:2] if lr else ("0", "0")
            b["ahead"], b["behind"] = int(ahead), int(behind)
        else:
            b["ahead"], b["behind"] = 0, 0
        pr = best_pr(prs.get(name))
        if pr:
            b["pr"] = {"number": pr["number"], "state": pr["state"], "base": pr["baseRefName"],
                       "head_oid": pr.get("headRefOid", ""), "merge_oid": (pr.get("mergeCommit") or {}).get("oid", ""),
                       "author": (pr.get("author") or {}).get("login", ""), "base_protected": repo.is_protected(pr["baseRefName"]),
                       "draft": pr.get("isDraft", False)}
            b["tip_vs_pr_head"] = tip_vs_pr_head(repo, sha, b["pr"])
            if pr["state"] == "OPEN":
                open_pr_branches.append(name)
        else:
            b["pr"] = None
            b["tip_vs_pr_head"] = ""
        b["bucket"] = bucket_for(repo, b, pr_source)
        branches.append(b)

    # expensive per-branch evidence only where a decision hinges on it
    for b in branches:
        needs_evidence = b["bucket"] in ("D4", "D5", "D6", "D7") or (b["bucket"] == "D2" and (b["tip_vs_pr_head"] not in ("equal", "ancestor") or not b["pr"]["base_protected"]))
        if needs_evidence and repo.primary:
            if 0 < b["ahead"] <= 50:
                out = gout(repo.path, "log", "--cherry-pick", "--right-only", "--no-merges", "--format=%H", f"{repo.primary}...{b['name']}")
                b["cherry_unique"] = len([l for l in out.split("\n") if l])
            else:
                b["cherry_unique"] = None if b["ahead"] > 50 else 0
            added = [p for p in gout(repo.path, "diff", "--diff-filter=A", "--name-only", f"{repo.primary}...{b['name']}").split("\n") if p]
            stranded = []
            elsewhere = [ob for ob in open_pr_branches if ob != b["name"]] + [t for t in repo.targets if t != repo.primary]
            for p in added[:200]:
                if any(git(repo.path, "cat-file", "-e", f"{ob}:{p}", check=False).returncode == 0 for ob in elsewhere):
                    continue
                stranded.append(p)
            b["stranded_files"] = stranded[:20]
            b["stranded_count"] = len(stranded)
            commits = [l.split("\t", 2) for l in gout(repo.path, "log", "--no-merges", "--date=short", "--format=%h%x09%ad%x09%s", f"{repo.primary}..{b['name']}").split("\n") if l]
            if not commits and git(repo.path, "merge-base", repo.primary, b["name"], check=False).returncode != 0:
                commits = [l.split("\t", 2) for l in gout(repo.path, "log", "--no-merges", "--date=short", "--format=%h%x09%ad%x09%s", "-n", "200", b["name"]).split("\n") if l]
            b["unique_commits"] = [{"sha": c[0], "date": c[1], "subject": c[2][:90]} for c in commits[:8]]
            b["unique_commit_count"] = len(commits)
            b["changes"] = repo.change_summary(repo.primary, b["name"])
            b["hand_diffs"], b["hand_paths"] = repo.hand_differences(repo.primary, b["name"])
            havens = repo.havens(open_pr_branches + ([f"origin/{b['pr']['base']}"] if b["pr"] and b["pr"]["base_protected"] else []))
            havens = [h for h in havens if h != b["name"]]
            b["havens"] = havens
            nl, _ = repo.never_landed(repo.primary, b["name"], havens)
            b["unique_content"] = {}
            for path in nl[:40]:
                lines = repo.unique_lines(repo.primary, b["name"], path, havens)
                if lines:
                    b["unique_content"][path] = {"lines": len(lines), "sample": [l.strip()[:120] for l in lines[:3]]}
            b["never_landed"] = sorted(b["unique_content"])
            b["superseded_versions"] = [p for p in nl if p not in b["unique_content"]]
            b["content_superseded"] = b["hand_paths"] > 0 and not b["never_landed"]
            b["value"] = "none" if b["content_superseded"] else repo.value_rating(b["changes"], len(commits), b["age_days"], b["stranded_count"])
        else:
            b["cherry_unique"] = None
            b["stranded_files"], b["stranded_count"] = [], 0
            b["unique_commits"], b["unique_commit_count"], b["changes"] = [], 0, None
            b["content_superseded"] = False
            b["hand_diffs"], b["hand_paths"], b["never_landed"] = [], 0, []
            b["unique_content"], b["superseded_versions"] = {}, []
            b["value"] = "none" if b["bucket"] in ("D1", "D8") else "merged-upstream" if b["bucket"] in ("D2", "D3") else "n/a"

    # --- stashes
    stashes = []
    for row in gout(repo.path, "stash", "list", "--format=%gd%x09%H%x09%ci%x09%gs").split("\n"):
        if not row:
            continue
        ref, sha, date, subject = (row.split("\t") + [""] * 4)[:4]
        idx = int(re.search(r"\{(\d+)\}", ref).group(1))
        m = re.match(r"^(?:WIP on|On) ([^:]+): (.*)$", subject)
        base, subj = (m.group(1), m.group(2)) if m else ("", subject)
        st = {"index": idx, "sha": sha, "date": date[:10], "age_days": age_days(date.replace(" ", "T", 1).replace(" ", "")),
              "base_branch": base, "subject": subj[:100], "noise": repo.is_noise_stash(subj)}
        names = [l for l in gout(repo.path, "stash", "show", "--name-only", "--include-untracked", sha).split("\n") if l]
        ins = dels = 0
        for line in gout(repo.path, "stash", "show", "--numstat", "--include-untracked", sha).split("\n"):
            parts = line.split("\t")
            if len(parts) == 3 and parts[0].isdigit() and parts[1].isdigit() and not repo.is_generated_path(parts[2]):
                ins += int(parts[0]); dels += int(parts[1])
        hand = [n for n in names if not repo.is_generated_path(n)]
        st["changes"] = {"files": len(names), "hand_files": len(hand), "gen_files": len(names) - len(hand), "ins": ins, "dels": dels, "top_files": hand[:8] or names[:4]}
        st["value"] = "low" if st["noise"] else repo.value_rating(st["changes"], 1, st["age_days"])
        stashes.append(st)

    audit = {"version": VERSION, "ts": TS, "repo": repo.rel, "path": repo.path, "default": repo.default,
             "targets": repo.targets, "slug": repo.slug, "fetch_ok": fetch_ok, "pr_source": pr_source,
             "branches": branches, "worktrees": worktrees, "orphans": orphans, "stashes": stashes,
             "counts": {"branches": len(branches), "worktrees": len(worktrees), "stashes": len(stashes), "orphans": len(orphans),
                        "buckets": dict(collections.Counter(b["bucket"] for b in branches))}}
    for ref in [r for r in gout(repo.path, "for-each-ref", "refs/archive/pr", "--format=%(refname)").split("\n") if r]:
        git(repo.path, "update-ref", "-d", ref, check=False)

    body = json.dumps(audit, indent=1, sort_keys=True)
    audit["audit_id"] = hashlib.sha256(body.encode()).hexdigest()[:16]
    path = os.path.join(repo.archive, f"audit-{TS}.json")
    with open(path, "w") as f:
        json.dump(audit, f, indent=1, sort_keys=True)
    shutil.copyfile(path, os.path.join(repo.archive, "audit-latest.json"))
    log(f"  branches={len(branches)} {audit['counts']['buckets']} worktrees={len(worktrees)} orphans={len(orphans)} stashes={len(stashes)}")
    log(f"  wrote {path} (audit-id {audit['audit_id']})")
    return audit


def parse_worktrees(repo: Repo):
    wts, cur = [], None
    for line in gout(repo.path, "worktree", "list", "--porcelain").split("\n"):
        if line.startswith("worktree "):
            if cur:
                wts.append(cur)
            cur = {"path": line[9:], "branch": "", "locked": "", "prunable": "", "detached": False}
        elif cur is None:
            continue
        elif line.startswith("HEAD "):
            cur["registered_head"] = line[5:]
        elif line.startswith("branch "):
            cur["branch"] = line[7:].replace("refs/heads/", "")
        elif line.startswith("locked"):
            cur["locked"] = line[6:].strip() or "yes"
        elif line.startswith("prunable"):
            cur["prunable"] = line[8:].strip() or "yes"
        elif line == "detached":
            cur["detached"] = True
    if cur:
        wts.append(cur)
    for i, w in enumerate(wts):
        w["kind"] = "main" if i == 0 else "linked"
        w["present"] = os.path.isdir(w["path"])
        if w["present"]:
            w["path"] = os.path.realpath(w["path"])
        w["id"] = os.path.basename(w["path"])
        w["sessions_path"] = w["path"].startswith("/sessions/")
    return wts


def in_progress_ops(repo: Repo, w):
    if not w["present"]:
        return []
    gd = gout(w["path"], "rev-parse", "--git-dir")
    gd = gd if os.path.isabs(gd) else os.path.join(w["path"], gd)
    return [m for m in ("MERGE_HEAD", "REBASE_HEAD", "CHERRY_PICK_HEAD", "rebase-merge", "rebase-apply", "BISECT_LOG") if os.path.exists(os.path.join(gd, m))]


def scan_orphans(repo: Repo, worktrees):
    """Directories with a `.git` gitfile that belong to this repo but are not (validly) registered."""
    registered = {os.path.realpath(w["path"]) for w in worktrees}
    cat_dir = os.path.dirname(repo.path)
    candidates = []
    for container in (f"{repo.name}.worktree", f"{repo.name}.worktrees", f"{repo.name}-worktrees"):
        d = os.path.join(cat_dir, container)
        if os.path.isdir(d):
            candidates += [os.path.join(d, n) for n in sorted(os.listdir(d))]
    home = repo.worktree_home()
    if os.path.isdir(home):
        candidates += [os.path.join(home, n) for n in sorted(os.listdir(home))]
    for n in sorted(os.listdir(cat_dir)):
        p = os.path.join(cat_dir, n)
        if n != repo.name and (n.startswith(f"{repo.name}-") or n.startswith("wt-") or n == f"{repo.name}.worktree") and os.path.isdir(p):
            candidates.append(p)
    out = []
    for p in candidates:
        ap = os.path.realpath(p)
        gitfile = os.path.join(ap, ".git")
        if ap in registered or not os.path.isfile(gitfile):
            if os.path.isdir(ap) and not os.path.exists(gitfile) and ap not in registered and os.path.dirname(ap) != cat_dir:
                out.append({"path": ap, "shape": "not-git", "gitdir": "", "size": du_bytes(ap)})
            continue
        with open(gitfile) as f:
            gitdir = f.read().strip().replace("gitdir: ", "")
        marker = f"/{repo.name}/.git/worktrees/"
        if marker not in gitdir + "/":
            continue  # belongs to another repo
        shape = "orphan-sessions" if gitdir.startswith("/sessions/") else "orphan-missing-admin"
        wid = os.path.basename(gitdir.rstrip("/"))
        admin = os.path.join(repo.path, ".git", "worktrees", wid)
        if os.path.isdir(admin) and any(w["id"] == wid and not w["present"] for w in worktrees):
            # Shape A twin: the registration still exists (missing, usually locked) and this is its local
            # directory. recover_shape_a repairs it in place; it must never be treated as an orphan.
            continue
        o = {"path": ap, "shape": shape, "gitdir": gitdir, "admin_exists": os.path.isdir(admin), "worktree_id": wid,
             "candidate_branch": guess_branch(repo, ap), "size": du_bytes(ap),
             "mtime": dt.datetime.fromtimestamp(os.stat(ap).st_mtime, dt.timezone.utc).strftime("%Y-%m-%d")}
        o["diff_vs_branch"] = orphan_diff(repo, ap, o["candidate_branch"]) if o["candidate_branch"] else None
        o["value"] = repo.value_rating(o["diff_vs_branch"], 1, None) if o["diff_vs_branch"] else "unknown"
        out.append(o)
    return out


def orphan_diff(repo: Repo, dirpath, branch):
    """Read-only: compare an orphan directory's files with a branch via a temporary index."""
    with tempfile.NamedTemporaryFile(delete=False) as tmp:
        idx = tmp.name
    os.remove(idx)
    env = dict(os.environ, GIT_INDEX_FILE=idx)
    base = ["git", "--git-dir", os.path.join(repo.path, ".git"), "--work-tree", dirpath]
    try:
        run(base + ["read-tree", branch], cwd=dirpath, env=env)
        # Content-based: a fresh index has no stat cache, so `status` over-reports; `diff <branch>` hashes files.
        changed = [l for l in run(base + ["diff", "--name-only", branch], cwd=dirpath, env=env, check=False).stdout.split("\n") if l.strip()]
        untracked = [l for l in run(base + ["ls-files", "--others", "--exclude-standard"], cwd=dirpath, env=env, check=False).stdout.split("\n") if l.strip()]
        tracked = [p for p in changed if not repo.is_noise_path(p)]
        paths = tracked + [p for p in untracked if not repo.is_noise_path(p)]
        ins = dels = 0
        for line in run(base + ["diff", "--numstat", branch, "--", *tracked[:400]], cwd=dirpath, env=env, check=False).stdout.split("\n") if tracked else []:
            parts = line.split("\t")
            if len(parts) == 3 and parts[0].isdigit() and parts[1].isdigit():
                ins += int(parts[0]); dels += int(parts[1])
        hand = [p for p in paths if not repo.is_generated_path(p)]
        return {"files": len(paths), "hand_files": len(hand), "gen_files": len(paths) - len(hand), "ins": ins, "dels": dels, "top_files": hand[:8] or paths[:4]}
    except HygieneError:
        return None
    finally:
        if os.path.exists(idx):
            os.remove(idx)


def guess_branch(repo: Repo, dirpath):
    base = os.path.basename(dirpath)
    for cand in (base, f"feature/{base}", f"feature/{base.replace('feature-', '')}", f"claude/{base.replace('claude-', '')}",
                 f"bugfix/{base}", f"hotfix/{base}"):
        if cand in repo.local_branches:
            return cand
    m = re.search(r"(WR-\d+)", base)
    if m:
        hits = [b for b in repo.local_branches if m.group(1) in b]
        if len(hits) == 1:
            return hits[0]
    return ""


def tip_vs_pr_head(repo: Repo, sha, pr):
    head, merge = pr.get("head_oid"), pr.get("merge_oid")
    if head and sha == head:
        return "equal"
    if head and commit_exists(repo.path, head) and is_ancestor(repo.path, sha, head):
        return "ancestor"
    if merge and commit_exists(repo.path, merge) and is_ancestor(repo.path, sha, merge):
        return "ancestor"
    if head and commit_exists(repo.path, head) and is_ancestor(repo.path, head, sha):
        return "ahead"
    if head and not commit_exists(repo.path, head):
        return "unknown"
    return "unrelated"


def bucket_for(repo: Repo, b, pr_source):
    pr = b["pr"]
    if b["protected"]:
        return "D8"
    if b["merged_into"]:
        return "D1"
    if not b["upstream"] and b["ahead"] == 0 and repo.primary:
        return "D1"
    if pr and pr["state"] == "MERGED":
        return "D2"
    if pr and pr["state"] == "OPEN":
        return "D3"
    if pr and pr["state"] == "CLOSED":
        return "D4"
    if not b["upstream"] or "ahead" in b["track"]:
        return "D7"
    if "gone" in b["track"]:
        return "D5"
    return "D6"


# ----------------------------------------------------------------------------- manifest rules
def build_rows(repo: Repo, audit):
    """Return manifest rows: dicts with MANIFEST_COLUMNS plus `section` (decide|prefilled|auto)."""
    thr = repo.thr
    rows = []
    wt_by_branch = {w["branch"]: w for w in audit["worktrees"] if w.get("branch") and w["kind"] == "linked"}
    branch_actions = {}

    def row(kind, action, section, bucket, name, sha, age, ahead, behind, pr, evidence, reason):
        r = {"kind": kind, "action": action, "section": section, "bucket": bucket, "name": name, "sha": (sha or "")[:12],
             "age_d": "" if age is None else str(age), "ahead": str(ahead), "behind": str(behind), "pr": pr,
             "evidence": evidence, "reason": reason}
        rows.append(r)
        return r

    for b in sorted(audit["branches"], key=lambda x: (x["bucket"], x["name"])):
        pr = b["pr"]
        prs = f"#{pr['number']} {pr['state']}" + ("" if not pr or pr["base_protected"] else f"→{pr['base']}") if pr else "-"
        wt = wt_by_branch.get(b["name"])
        wt_dirty = bool(wt and wt["present"] and wt["dirt"])
        bucket, age, name = b["bucket"], b["age_days"], b["name"]
        ev, reason, action, section = [], "", "review", "decide"
        if b["noise"]:
            ev.append("noise-branch")
        if b["worktree"]:
            ev.append("worktree" + ("(dirty)" if wt_dirty else ""))
        if b.get("cherry_unique") is not None:
            ev.append(f"cherry_unique={b['cherry_unique']}")
        if b.get("stranded_count"):
            ev.append(f"stranded={b['stranded_count']}:" + ",".join(b["stranded_files"][:3]))
        if b["tip_vs_pr_head"]:
            ev.append(f"tip_vs_pr={b['tip_vs_pr_head']}")
        if b.get("changes"):
            c = b["changes"]
            ev.append(f"value={b['value']} commits={b['unique_commit_count']} files={c['files']}(hand {c['hand_files']}) +{c['ins']}/-{c['dels']}")
            uc = sum(v["lines"] for v in b.get("unique_content", {}).values())
            ev.append(f"unique_lines={uc} in {len(b.get('never_landed', []))}/{b.get('hand_paths', 0)} files" + (":" + ",".join(b["never_landed"][:2]) if b.get("never_landed") else ""))
        if not repo.targets and bucket != "D8":
            action, section, reason = "review", "decide", ("no integration target could be resolved for this repo, so nothing"
                                                           " can be proven merged; decide each branch by hand")
        elif bucket == "D8":
            action, section, reason = "keep", "auto", "protected"
        elif bucket == "D1":
            action, section, reason = "archive-delete", "auto", ("merged into " + ",".join(b["merged_into"])) if b["merged_into"] else "no upstream, 0 ahead"
        elif bucket == "D2":
            if b.get("content_superseded"):
                action, section, reason = "archive-delete", "auto", f"PR #{pr['number']} merged; every version of the {b['hand_paths']} hand-written files it touches has landed on {repo.primary}"
            elif pr["base_protected"] and b["tip_vs_pr_head"] in ("equal", "ancestor"):
                action, section, reason = "archive-delete", "auto", f"squash-merged via PR into {pr['base']}"
            elif b.get("cherry_unique") == 0:
                action, section, reason = "archive-delete", "auto", f"PR merged into {pr['base']}; every local commit is patch-equivalent to {repo.primary}"
            elif not pr["base_protected"]:
                reason = f"PR #{pr['number']} merged into another feature branch ({pr['base']}), not into {repo.default}; check that branch reached {repo.default}"
            else:
                reason = (f"has commits that PR #{pr['number']} never included" if b['tip_vs_pr_head'] == "ahead"
                          else f"PR #{pr['number']} merged, but its final commit is not on this machine so the branch cannot be matched to it; has unique commits")
        elif bucket == "D3":
            action, section, reason = "keep", "auto", "open PR"
            if b["upstream"] and "ahead" in b["track"]:
                reason += "; local commits not pushed"
        elif bucket == "D4":
            action, section, reason = "archive-delete", "prefilled", "PR closed unmerged"
        elif bucket in ("D5", "D6", "D7"):
            label = {"D5": "GitHub copy deleted, no PR found", "D6": "still on GitHub, no PR", "D7": "exists only on this machine" if not b["upstream"] else "latest commits never pushed"}[bucket]
            if bucket == "D7" and pr and pr["state"] == "MERGED":
                reason = f"{label}; tip ahead of merged PR #{pr['number']}"
            elif b.get("content_superseded"):
                action, section, reason = "archive-delete", "auto", f"{label}; every version of the {b['hand_paths']} hand-written files it touches has landed on {repo.primary}"
            elif b.get("cherry_unique") == 0:
                action, section, reason = "archive-delete", "auto", f"{label}; all commits patch-equivalent to {repo.primary}"
            elif b["noise"]:
                action, section, reason = "archive-delete", "prefilled", f"{label}; tool snapshot/bot branch"
            elif age is not None and age >= thr["branch_age_days"]:
                action, section, reason = "archive-delete", "prefilled", f"{label}; {age}d old (>= {thr['branch_age_days']})"
            else:
                reason = f"{label}; {age}d old, has unique commits"
        if b["checked_out_main"] and action in ("archive-delete",):
            action, section, reason = "blocked", "decide", reason + f"; checked out in main worktree (git -C {repo.path} switch {repo.default})"
        elif wt_dirty and action == "archive-delete":
            action, section, reason = "review", "decide", reason + "; its worktree has uncommitted changes"
        elif b["worktree"] and action == "archive-delete" and bucket != "D1" and section != "auto":
            action, section = "review", "decide"
        branch_actions[name] = action
        row("branch", action, section, bucket, name, b["sha"], age, b["ahead"], b["behind"], prs, " ".join(ev), reason)

    for w in audit["worktrees"]:
        if w["kind"] == "main":
            on_default = w.get("branch") == repo.default
            row("worktree", "note", "auto", "-", w["path"], w.get("head", ""), None, "", "", "-",
                f"main branch={w.get('branch') or 'detached'} dirt={len(w['dirt'])} noise={len(w['noise'])}",
                "main checkout" + ("" if on_default else f"; not on {repo.default}"))
            continue
        name = w["path"]
        ev = [f"branch={w.get('branch') or ('detached' if w['detached'] else '?')}", f"dirt={len(w['dirt'])}", f"noise={len(w['noise'])}",
              f"size={human(w['size'])}", "layout-ok" if w["layout_ok"] else "LAYOUT", f"idle={w['last_touch']}d"]
        if w.get("dirt_detail"):
            d = w["dirt_detail"]
            ev.append(f"value={w['value']} +{d['ins']}/-{d['dels']} untracked={d['untracked']} top={','.join(d['top_files'][:3])}")
        if w["locked"]:
            ev.append(f"locked={w['locked']}")
        if w["in_progress"]:
            ev.append("in-progress=" + ",".join(w["in_progress"]))
        if not w["present"]:
            action, section, reason = ("repair", "decide", "registration missing; " + ("locked cloud-session path, admin dir present" if w["locked"] else "prunable"))
        elif w["in_progress"]:
            action, section, reason = "review", "decide", "merge/rebase in progress"
        elif w["detached"]:
            action, section, reason = "review", "decide", "detached HEAD"
        else:
            ba = branch_actions.get(w.get("branch"), "review")
            if ba in ("keep", "pr"):
                action, section, reason = ("keep" if w["layout_ok"] else "migrate"), "auto", f"branch {ba}" + ("" if w["layout_ok"] else f"; move under {repo.worktree_home()}")
                if w["dirt"] and w["last_touch"] is not None and w["last_touch"] >= thr["idle_worktree_days"]:
                    reason += f"; dirty and idle {w['last_touch']}d"
            elif ba == "archive-delete" and not w["dirt"]:
                action, section, reason = "remove", "auto", "clean; branch archived"
            elif ba == "archive-delete":
                action, section, reason = "salvage-remove", "decide", f"branch archived but {len(w['dirt'])} uncommitted paths; salvage patch will be written"
            elif ba == "blocked":
                action, section, reason = "review", "decide", "branch blocked"
            else:
                action, section, reason = "review", "decide", "branch needs a decision first"
        row("worktree", action, section, "-", name, w.get("head", ""), w["last_touch"], "", "", "-", " ".join(ev), reason)

    for o in audit["orphans"]:
        if o["shape"] == "not-git":
            row("worktree", "note", "auto", "-", o["path"], "", None, "", "", "-", f"size={human(o['size'])}", "directory without git metadata; leave or delete by hand")
            continue
        dv = o.get("diff_vs_branch")
        dv_s = f" diff-vs-branch: files={dv['files']} +{dv['ins']}/-{dv['dels']} value={o['value']}" if dv else ""
        row("worktree", "review", "decide", "-", o["path"], "", None, "", "", "-",
            f"{o['shape']} admin={'yes' if o['admin_exists'] else 'no'} branch={o['candidate_branch'] or '?'} size={human(o['size'])} mtime={o['mtime']}{dv_s}",
            "orphan directory: `recover-worktrees` will diff it against the branch, salvage, then remove (set to salvage-remove)")

    for s in sorted(audit["stashes"], key=lambda x: x["index"]):
        name = f"stash@{{{s['index']}}}"
        c = s.get("changes") or {}
        ev = f"{s['date']} on {s['base_branch'] or '?'}: {s['subject']} | value={s.get('value','?')} files={c.get('files',0)} +{c.get('ins',0)}/-{c.get('dels',0)} top={','.join(c.get('top_files',[])[:3])}"
        if s["noise"]:
            action, section, reason = "drop", "auto", "tool noise"
        elif s["age_days"] is not None and s["age_days"] >= thr["stash_age_days"]:
            action, section, reason = "export-drop", "auto", f"{s['age_days']}d old; exported as patch"
        else:
            action, section, reason = "keep", "prefilled", f"{s['age_days']}d old; decide keep / export-drop / drop"
        row("stash", action, section, "-", name, s["sha"], s["age_days"], "", "", "-", ev, reason)
    return rows


def write_manifest(repo: Repo, audit, rows, path):
    sections = [("decide", "NEEDS YOUR DECISION"), ("prefilled", "PRE-FILLED, PLEASE SKIM"), ("auto", "AUTO (collapsed)")]
    lines = [f"# repo-hygiene manifest v1\trepo={repo.rel}\tdefault={repo.default}\taudit-id={audit['audit_id']}\tgenerated={TS}",
             "# Edit only the `action` column. branch: keep|pr|archive-delete   worktree: keep|migrate|remove|repair|salvage-remove   stash: keep|export-drop|drop",
             "# Every `review` row must be changed before apply. `blocked` and `note` rows are informational.",
             "\t".join(MANIFEST_COLUMNS)]
    for key, title in sections:
        sec = [r for r in rows if r["section"] == key]
        lines.append(f"# ---- {title} ({len(sec)}) ----")
        for r in sec:
            lines.append("\t".join(r[c].replace("\t", " ").replace("\n", " ") for c in MANIFEST_COLUMNS))
    with open(path, "w") as f:
        f.write("\n".join(lines) + "\n")


WIP_RE = re.compile(r"\b(wip|not working|broken|temp|todo|experiment|snapshot|hack|test only|scratch)\b", re.I)


def explain_branch(repo: Repo, b, r, pr_source="none"):
    """Plain-language what / complete? / recommendation / confidence for a branch row."""
    pr = b["pr"]; bucket = b["bucket"]; action = r.get("action", "?")
    tgt = repo.primary or repo.default
    what = {
        "D1": f"Everything in it is already in {', '.join(b['merged_into']) or tgt}.",
        "D2": (f"Its PR #{pr['number']} was merged into {pr['base']}." if pr else "") + (
            " The branch also has commits that PR never included." if b["tip_vs_pr_head"] == "ahead" else
            " The PR's final commit is not on this machine, so I could not match the branch to it exactly." if b["tip_vs_pr_head"] == "unknown" else ""),
        "D3": f"Its PR #{pr['number']} is still open." if pr else "",
        "D4": f"Its PR #{pr['number']} was closed without being merged." if pr else "",
        "D5": "It was pushed to GitHub once, but that copy has since been deleted and no PR references it.",
        "D6": "It is still on GitHub, but no PR was ever opened for it.",
        "D7": ("This repo has no remote, so every branch exists only on this machine." if not repo.has_remote else
               "It exists only on this machine; GitHub has none of these commits.") if not b["upstream"] else "Its latest commits were never pushed; GitHub holds an older copy.",
        "D8": "Protected branch.",
    }.get(bucket, "")
    if b.get("content_superseded"):
        sup = len(b.get("superseded_versions", []))
        extra = f" ({sup} file(s) differ from {tgt} today, but every line this branch added is already there, so {tgt} simply moved on.)" if sup else ""
        where = "the branches it would have landed on" if len(b.get("havens", [])) > 1 else tgt
        what += (f" Nothing it adds is missing: across the {b['hand_paths']} hand-written files it touches,"
                 f" every added line is already on {where}.{extra}")
    elif b.get("never_landed"):
        tot = sum(v["lines"] for v in b.get("unique_content", {}).values())
        bits = [f"`{f}` ({b['unique_content'][f]['lines']} lines)" for f in b["never_landed"][:6]]
        what += (f" {tot} line(s) it adds appear on no branch at all (checked {len(b.get('havens', []))} targets and open PRs), across {len(b['never_landed'])} file(s): "
                 + ", ".join(bits) + (" …" if len(b["never_landed"]) > 6 else "") + ".")
    if (b.get("changes") or {}).get("unrelated_history"):
        c = b["changes"]
        what += (f" It comes from an older, unrelated history of this repo (no common ancestor with {tgt}), so commit comparison is impossible;"
                 f" comparing files instead: {c['only_in_branch_count']} file(s) exist only in this branch"
                 + (": " + ", ".join(c["only_in_branch"][:5]) if c["only_in_branch"] else "") + ".")
    elif b.get("cherry_unique") is not None:
        what += f" {b['cherry_unique']} of its {b['unique_commit_count']} commits carry changes {tgt} does not already have."
    if b["stranded_count"]:
        what += f" {b['stranded_count']} file(s) in it exist nowhere else."
    flags = []
    if any(WIP_RE.search(c["subject"]) for c in b.get("unique_commits", [])):
        flags.append("commit messages mention WIP, not-working or experiments")
    if b["worktree"]:
        flags.append("it has a checked-out worktree; see the worktree section for uncommitted changes")
    if b["age_days"] is not None and b["age_days"] > 365:
        flags.append(f"untouched for {b['age_days']} days, so it will need rebasing onto {tgt}")
    complete = "; ".join(flags) if flags else "no red flags in the commit messages; whether it still builds and runs is untested"
    if action == "archive-delete":
        rec = "Delete it; the commits are archived in the bundle first."
    elif action == "keep":
        rec = "Keep it."
    elif action == "blocked":
        rec = f"Switch the main checkout to {repo.default} first, then delete it."
    elif action == "pr":
        rec = "Push it and open a PR."
    elif b["value"] in ("high", "medium"):
        rec = f"Worth a look: if the work is still wanted, rebase it onto {tgt} and open a PR; otherwise delete it (archived first)."
    else:
        rec = "Probably delete it (archived first); the unique changes are small."
    if b.get("content_superseded"):
        conf, why = "High", "every added line checked against all targets, release branches and open PRs"
    elif b.get("never_landed"):
        conf, why = "High", "added lines checked against all targets, release branches and open PRs"
    elif (b.get("changes") or {}).get("unrelated_history"):
        conf, why = "Medium", "unrelated history: judged by comparing file trees, not commits"
    elif bucket in ("D1", "D8") or (bucket == "D2" and b["tip_vs_pr_head"] in ("equal", "ancestor")):
        conf, why = "High", "git confirms every commit is already in the target"
    elif b.get("cherry_unique") is not None and (pr or bucket == "D7"):
        conf, why = "High", "PR state and a commit-by-commit content comparison both checked"
    elif b["tip_vs_pr_head"] == "unknown":
        conf, why = "Medium", "the merged PR's final commit is missing locally, so the match relies on content comparison only"
    elif b.get("cherry_unique") is None and b["ahead"] > 50:
        conf, why = "Medium", f"the branch is {b['ahead']} commits ahead, too large for the content comparison"
    elif pr_source in ("gh", "cache") and b.get("cherry_unique") is not None:
        conf, why = "Medium", "no PR exists for it; the judgement rests on the commit-by-commit content comparison"
    else:
        conf, why = "Low", "PR data could not be fetched for this repo"
    return what, complete, rec, f"{conf} ({why})"


def explain_stash(repo: Repo, s, r):
    action = r.get("action", "?"); c = s.get("changes") or {}
    what = f"Uncommitted work parked on `{s['base_branch'] or '?'}` on {s['date']}: {c.get('files', 0)} file(s), +{c.get('ins', 0)}/-{c.get('dels', 0)} lines."
    complete = "tool-generated stash (autostash / lint-staged), not deliberate work" if s["noise"] else (
        "subject mentions WIP or experiments" if WIP_RE.search(s["subject"]) else "a stash is by definition unfinished; the patch shows exactly what was mid-flight")
    rec = {"drop": "Drop it; nothing hand-written is in it.", "export-drop": "Drop it after exporting the patch to the archive (default for stashes older than the age threshold).",
           "keep": "Keep it, or mark export-drop if the patch is enough."}.get(action, "Decide.")
    conf = "High (stash content inspected file by file)" if not s["noise"] else "High (matched the tool-noise pattern)"
    return what, complete, rec, conf


def explain_worktree(repo: Repo, w, r):
    d = w.get("dirt_detail") or {}; action = r.get("action", "?")
    what = f"Checkout of `{w.get('branch') or 'detached HEAD'}` with {d.get('files', 0)} uncommitted path(s) (+{d.get('ins', 0)}/-{d.get('dels', 0)} lines), idle {w['last_touch']} day(s)."
    complete = "uncommitted changes are by definition unfinished; the salvage patch will capture them" if d else "clean"
    rec = {"remove": "Remove it; the branch decision covers the commits.", "salvage-remove": "Remove it after the uncommitted changes are saved as a patch and archived.",
           "keep": "Keep it.", "migrate": f"Keep it and move it under {repo.worktree_home()}.", "repair": "Repair the registration first (recover-worktrees)."}.get(action, "Decide.")
    return what, complete, rec, "High (working tree inspected directly)"


def write_review(repo: Repo, audit, rows, path):
    """Human-readable companion to manifest.tsv: what is inside every at-risk item, most valuable first."""
    order = {"high": 0, "medium": 1, "low": 2, "unknown": 3, "n/a": 4, "none": 5, "merged-upstream": 6}
    act = {(r["kind"], r["name"]): r for r in rows}
    L = [f"# Review: {repo.rel}", "", f"Generated {TS} from audit {audit['audit_id']}. Items are sorted most-valuable first; the `action` shown is the manifest default.",
         "Value = hand-written lines + files + stranded files, boosted when younger than 90 days. Generated files (API types, lockfiles, snapshots, build output) are excluded from the count.",
         "Each item says what it is in plain words, whether it looks complete, a recommendation, and how confident the engine is and why. `Complete / working?` is a heuristic from commit messages and working-tree state; only running the code proves it.", ""]
    at_risk = [b for b in audit["branches"] if b.get("changes")]
    at_risk.sort(key=lambda b: (order.get(b["value"], 9), -(b["changes"]["ins"] + b["changes"]["dels"])))
    L.append(f"## Branches with unique work ({len(at_risk)})"); L.append("")
    for b in at_risk:
        r = act.get(("branch", b["name"]), {})
        c = b["changes"]; pr = b["pr"]
        what, complete, rec, conf = explain_branch(repo, b, r, audit.get("pr_source", "none"))
        L.append(f"### `{b['name']}` — value **{b['value'].upper()}**, {b['age_days']} days old")
        L.append(f"- What it is: {what}")
        L.append(f"- {b['unique_commit_count']} unique commit(s), {c['files']} files ({c['hand_files']} hand-written, {c['gen_files']} generated), +{c['ins']}/-{c['dels']} hand-written lines"
                 + (f"; PR #{pr['number']} {pr['state']} → {pr['base']}" if pr else "; no PR") + (f"; cherry-unique {b['cherry_unique']}" if b.get("cherry_unique") is not None else "")
                 + (f"; worktree `{b['worktree']}`" if b["worktree"] else ""))
        if b["unique_commits"]:
            L.append("- Commits: " + " · ".join(f"{u['date']} {u['subject']}" for u in b["unique_commits"][:5]) + (" · …" if b["unique_commit_count"] > 5 else ""))
        if c["top_files"]:
            L.append("- Files: " + ", ".join(f"`{f}`" for f in c["top_files"]))
        if b.get("unique_content"):
            L.append("- Content found only on this branch:")
            for f, v in list(b["unique_content"].items())[:6]:
                L.append(f"  - `{f}` — {v['lines']} line(s), e.g. " + " / ".join(f"`{s}`" for s in v["sample"][:2]))
        if b["stranded_count"]:
            L.append(f"- Stranded (exist nowhere else): " + ", ".join(f"`{f}`" for f in b["stranded_files"][:6]) + (f" (+{b['stranded_count']-6} more)" if b["stranded_count"] > 6 else ""))
        L.append(f"- Complete / working? {complete}")
        L.append(f"- Recommendation: {rec} (manifest default: `{r.get('action','?')}`)")
        L.append(f"- Confidence: {conf}"); L.append("")
    dirty = [w for w in audit["worktrees"] if w["kind"] == "linked" and w.get("dirt_detail")]
    orphans = [o for o in audit["orphans"] if o["shape"] != "not-git"]
    if dirty or orphans:
        L.append(f"## Worktrees with uncommitted changes ({len(dirty)}) and orphan directories ({len(orphans)})"); L.append("")
        for w in sorted(dirty, key=lambda w: order.get(w["value"], 9)):
            d = w["dirt_detail"]; r = act.get(("worktree", w["path"]), {})
            what, complete, rec, conf = explain_worktree(repo, w, r)
            L.append(f"### `{w['path']}` — value **{w['value'].upper()}**")
            L.append(f"- What it is: {what} {human(w['size'])} on disk.")
            L.append("- Files: " + ", ".join(f"`{f}`" for f in d["top_files"]))
            L.append(f"- Complete / working? {complete}")
            L.append(f"- Recommendation: {rec} (manifest default: `{r.get('action','?')}`)")
            L.append(f"- Confidence: {conf}"); L.append("")
        for o in orphans:
            dv = o.get("diff_vs_branch"); r = act.get(("worktree", o["path"]), {})
            L.append(f"### `{o['path']}` — {o['shape']}, last touched {o['mtime']}, {human(o['size'])}, action **{r.get('action','?')}**, value **{o['value'].upper()}**")
            if dv:
                L.append(f"- vs `{o['candidate_branch']}`: {dv['files']} differing paths, +{dv['ins']}/-{dv['dels']} lines; files: " + ", ".join(f"`{f}`" for f in dv["top_files"]))
            else:
                L.append("- no candidate branch identified; recover-worktrees needs --branch")
            L.append("")
    st = [s for s in audit["stashes"]]
    if st:
        L.append(f"## Stashes ({len(st)})"); L.append("")
        for s in sorted(st, key=lambda s: (order.get(s.get("value"), 9), -(s.get("changes") or {}).get("ins", 0))):
            c = s.get("changes") or {}; r = act.get(("stash", f"stash@{{{s['index']}}}"), {})
            what, complete, rec, conf = explain_stash(repo, s, r)
            L.append(f"### `stash@{{{s['index']}}}` **{s['subject']}** — value **{s.get('value','?').upper()}**")
            L.append(f"- What it is: {what}")
            if c.get("top_files"):
                L.append("- Files: " + ", ".join(f"`{f}`" for f in c.get("top_files", [])[:6]))
            L.append(f"- Complete / working? {complete}")
            L.append(f"- Recommendation: {rec} (manifest default: `{r.get('action','?')}`)")
            L.append(f"- Confidence: {conf}"); L.append("")
        L.append("")
    with open(path, "w") as f:
        f.write("\n".join(L) + "\n")
    hi = [b for b in at_risk if b["value"] in ("high", "medium")] + [w for w in dirty if w["value"] in ("high", "medium")] + [s for s in st if s.get("value") in ("high", "medium")]
    return len(hi)


def read_manifest(path):
    header, rows = {}, []
    with open(path) as f:
        for line in f:
            line = line.rstrip("\n")
            if line.startswith("# repo-hygiene manifest"):
                for part in line.split("\t")[1:]:
                    k, _, v = part.partition("=")
                    header[k] = v
            elif not line or line.startswith("#") or line.startswith("kind\t"):
                continue
            else:
                vals = line.split("\t")
                if len(vals) < len(MANIFEST_COLUMNS):
                    vals += [""] * (len(MANIFEST_COLUMNS) - len(vals))
                rows.append(dict(zip(MANIFEST_COLUMNS, vals)))
    return header, rows


def manifest_has_edits(repo: Repo, path):
    """True if manifest.tsv differs from what the latest audit would generate (i.e. user edits)."""
    gen = os.path.join(repo.archive, "manifest.generated.tsv")
    if not (os.path.exists(path) and os.path.exists(gen)):
        return False
    _, a = read_manifest(path)
    _, b = read_manifest(gen)
    return [(r["kind"], r["name"], r["action"]) for r in a] != [(r["kind"], r["name"], r["action"]) for r in b]


def validate_manifest(repo: Repo, audit, rows, policy=None):
    problems = []
    if not rows:
        problems.append("manifest has no rows")
    by_branch = {b["name"]: b for b in audit["branches"]}
    by_wt = {w["path"]: w for w in audit["worktrees"]}
    by_orphan = {o["path"]: o for o in audit["orphans"]}
    by_stash = {s["sha"][:12]: s for s in audit["stashes"]}
    wt_actions = {}
    for r in rows:
        k, a, n = r["kind"], r["action"], r["name"]
        if k == "branch":
            if a not in BRANCH_ACTIONS:
                problems.append(f"branch {n}: bad action {a!r}")
            b = by_branch.get(n)
            if not b:
                problems.append(f"branch {n}: not in audit")
            elif b["sha"][:12] != r["sha"]:
                problems.append(f"branch {n}: sha drifted {r['sha']} -> {b['sha'][:12]}")
            elif b["protected"] and a != "keep":
                problems.append(f"branch {n}: protected but action {a}")
        elif k == "worktree":
            if a not in WORKTREE_ACTIONS:
                problems.append(f"worktree {n}: bad action {a!r}")
            if n not in by_wt and n not in by_orphan:
                problems.append(f"worktree {n}: not in audit")
            wt_actions[n] = a
        elif k == "stash":
            if a not in STASH_ACTIONS:
                problems.append(f"stash {n}: bad action {a!r}")
            if r["sha"][:12] not in by_stash:
                problems.append(f"stash {n} {r['sha']}: not in audit (stashes are matched by sha)")
        else:
            problems.append(f"unknown kind {k!r} for {n}")
        if a == "review" and policy != "safe":
            problems.append(f"{k} {n}: still marked review")
    for r in rows:
        if r["kind"] == "branch" and r["action"] == "archive-delete":
            b = by_branch.get(r["name"])
            if b and b["worktree"] and wt_actions.get(b["worktree"]) == "keep":
                problems.append(f"branch {r['name']}: archive-delete but its worktree {b['worktree']} is keep")
    return problems


# ----------------------------------------------------------------------------- apply
class Applier:
    def __init__(self, repo: Repo, audit, rows, execute, log, skip_drifted=False, policy=None):
        self.repo, self.audit, self.rows, self.execute, self.log = repo, audit, rows, execute, log
        self.skip_drifted, self.policy = skip_drifted, policy
        self.removed_bytes = 0
        self.by_branch = {b["name"]: b for b in audit["branches"]}
        self.by_wt = {w["path"]: w for w in audit["worktrees"]}
        self.by_orphan = {o["path"]: o for o in audit["orphans"]}
        self.by_stash_sha = {s["sha"][:12]: s for s in audit["stashes"]}
        self.archive_refs = []
        self.lock = os.path.join(repo.archive, ".lock")

    def do(self, desc, fn):
        self.log(("  [exec] " if self.execute else "  [dry ] ") + desc)
        if self.execute:
            return fn()

    def run_all(self):
        repo = self.repo
        rows = [r for r in self.rows if r["action"] not in ("note",)]
        if self.policy == "safe":
            rows = [r for r in rows if r["action"] in ("keep", "archive-delete", "remove", "drop", "export-drop", "migrate")]
        if os.path.exists(self.lock):
            raise HygieneError(f"lock present: {self.lock}")
        if self.execute:
            with open(self.lock, "w") as f:
                f.write(str(os.getpid()))
        try:
            self.precheck(rows)
            self.recover(rows)
            salvaged = self.salvage(rows)
            self.export_stashes(rows)
            self.bundle(rows)
            self.raise_prs(rows)
            self.worktrees(rows, salvaged)
            self.branches(rows)
            self.stashes(rows)
            self.finish(rows)
        finally:
            if self.execute and os.path.exists(self.lock):
                os.remove(self.lock)

    # -- 2. prechecks
    def precheck(self, rows):
        repo = self.repo
        if repo.has_remote:
            r = git(repo.path, "fetch", "--prune", "origin", check=False)
            if r.returncode != 0:
                raise HygieneError("fetch failed; refusing to apply: " + r.stderr.strip()[:200])
        for w in self.audit["worktrees"]:
            if w["present"] and in_progress_ops(repo, w):
                raise HygieneError(f"in-progress git operation in {w['path']}")
        problems = validate_manifest(repo, self.audit, rows, self.policy)
        if problems:
            raise HygieneError("manifest invalid:\n    " + "\n    ".join(problems))
        # drift: compare live state with the audit for every row we will touch
        drifted = []
        for r in rows:
            if r["kind"] == "branch":
                live = gout(repo.path, "rev-parse", f"refs/heads/{r['name']}")
                if live[:12] != r["sha"]:
                    drifted.append(f"branch {r['name']} {r['sha']} -> {live[:12] or 'gone'}")
            elif r["kind"] == "worktree" and r["name"] in self.by_wt and self.by_wt[r["name"]]["present"]:
                w = self.by_wt[r["name"]]
                live_head = gout(w["path"], "rev-parse", "HEAD")
                real, _ = repo.status_split(w["path"])
                if live_head != w["head"] or len(real) != len(w["dirt"]):
                    drifted.append(f"worktree {r['name']} head/dirt changed")
            elif r["kind"] == "stash":
                if r["sha"] not in {s[:12] for s in gout(repo.path, "stash", "list", "--format=%H").split("\n")}:
                    drifted.append(f"stash {r['name']} {r['sha']} no longer present")
        if drifted:
            msg = "state drifted since audit:\n    " + "\n    ".join(drifted)
            if not self.skip_drifted:
                raise HygieneError(msg + "\n  re-run audit + manifest, or pass --skip-drifted")
            self.log("  WARN " + msg)
            names = {d.split(" ")[1] for d in drifted}
            rows[:] = [r for r in rows if r["name"] not in names]
        self.log(f"  prechecks ok: {len(rows)} rows")

    # -- 3. recovery
    def recover(self, rows):
        for r in rows:
            if r["kind"] != "worktree":
                continue
            if r["action"] == "repair" and r["name"] in self.by_wt:
                recover_shape_a(self.repo, self.by_wt[r["name"]], self.do, self.log)
            elif r["name"] in self.by_orphan and r["action"] in ("salvage-remove", "remove"):
                o = self.by_orphan[r["name"]]
                ref = recover_orphan(self.repo, o, self.do, self.log)
                if ref:
                    self.archive_refs.append(ref)

    # -- 4. salvage dirty worktrees
    def salvage(self, rows):
        salvaged = set()
        for r in rows:
            if r["kind"] != "worktree" or r["action"] not in ("remove", "salvage-remove") or r["name"] not in self.by_wt:
                continue
            w = self.by_wt[r["name"]]
            if not w["present"]:
                continue
            real, _ = self.repo.status_split(w["path"])
            if real:
                ref = salvage_tree(self.repo, w["path"], w["id"], self.do, self.log)
                if ref:
                    self.archive_refs.append(ref)
                salvaged.add(r["name"])
            for vi in self.repo.opts.get("valuable_ignored", []):
                src = os.path.join(w["path"], vi)
                if os.path.exists(src):
                    dst = os.path.join(self.repo.archive, "salvage", f"{TS}-{w['id']}", vi)
                    self.do(f"copy ignored {vi} from {w['id']}", lambda s=src, d=dst: (os.makedirs(os.path.dirname(d), exist_ok=True), shutil.copy2(s, d)))
        return salvaged

    # -- 5. stash export
    def export_stashes(self, rows):
        repo = self.repo
        outdir = os.path.join(repo.archive, "stashes")
        idx_path = os.path.join(outdir, "index.tsv")
        for r in rows:
            if r["kind"] != "stash" or r["action"] not in ("drop", "export-drop"):
                continue
            s = self.by_stash_sha[r["sha"]]
            ref = f"refs/archive/stash/{s['sha'][:12]}"
            self.do(f"ref {ref} <- {r['name']}", lambda ref=ref, s=s: git(repo.path, "update-ref", ref, s["sha"]))
            self.archive_refs.append(ref)
            if r["action"] == "export-drop":
                slug = re.sub(r"[^A-Za-z0-9._-]+", "-", s["subject"])[:40].strip("-") or "stash"
                patch = os.path.join(outdir, f"{TS}-{s['index']}-{slug}.patch")

                def export(s=s, patch=patch):
                    os.makedirs(outdir, exist_ok=True)
                    p = git(repo.path, "stash", "show", "-p", "--include-untracked", s["sha"], check=False)
                    if p.returncode != 0:
                        p = git(repo.path, "show", "-p", "--format=", s["sha"])
                    with open(patch, "w") as f:
                        f.write(p.stdout)
                    with open(idx_path, "a") as f:
                        f.write("\t".join([s["sha"], s["date"], s["base_branch"], s["subject"], os.path.basename(patch)]) + "\n")
                self.do(f"export {r['name']} -> {os.path.basename(patch)}", export)

    # -- 6. bundle
    def bundle(self, rows):
        repo = self.repo
        deletions = [r for r in rows if r["kind"] == "branch" and r["action"] == "archive-delete"]
        refs = [f"refs/heads/{r['name']}" for r in deletions] + list(dict.fromkeys(self.archive_refs))
        refs_tsv = os.path.join(repo.archive, f"{TS}.refs.tsv")
        bundle = os.path.join(repo.archive, f"{TS}.bundle")
        if not refs:
            self.log("  bundle: nothing to archive")
            return
        excl = [f"^{ref}" for ref in repo.protected_refs_full()]

        def make():
            os.makedirs(repo.archive, exist_ok=True)
            r = git(repo.path, "bundle", "create", bundle, *refs, *excl, check=False)
            in_bundle = r.returncode == 0
            if not in_bundle:
                if "empty bundle" in (r.stderr or "").lower():
                    for ref in refs:
                        if not any(is_ancestor(repo.path, ref, p) for p in repo.protected_refs_full()):
                            raise HygieneError(f"empty bundle but {ref} is not reachable from a protected ref")
                    self.log("  bundle: empty (every tip reachable from protected refs); refs.tsv is the record")
                else:
                    raise HygieneError("bundle create failed: " + r.stderr.strip()[:300])
            else:
                git(repo.path, "bundle", "verify", bundle)
                self.log(f"  bundle: {bundle} verified ({human(os.path.getsize(bundle))})")
            with open(refs_tsv, "w") as f:
                f.write("ref\tsha\tbucket\taction\tin_bundle\n")
                prot = repo.protected_refs_full()
                for r_ in deletions:
                    ref = f"refs/heads/{r_['name']}"
                    reachable = any(is_ancestor(repo.path, ref, p) for p in prot)
                    f.write("\t".join([ref, gout(repo.path, "rev-parse", ref), r_["bucket"], r_["action"], "no(reachable)" if reachable else ("yes" if in_bundle else "no")]) + "\n")
                for ref in dict.fromkeys(self.archive_refs):
                    f.write("\t".join([ref, gout(repo.path, "rev-parse", ref), "-", "archive", "yes" if in_bundle else "no"]) + "\n")
        self.do(f"bundle {len(refs)} refs -> {os.path.basename(bundle)} (thin, excluding {len(excl)} protected refs)", make)

    # -- 7. PRs
    def raise_prs(self, rows):
        repo = self.repo
        for r in rows:
            if r["kind"] != "branch" or r["action"] != "pr":
                continue
            b = self.by_branch[r["name"]]
            base = repo.default
            m = re.match(r"^(hotfix|backport)/", b["name"])
            if m:
                self.log(f"  pr {b['name']}: release-bound branch; run by hand: git push -u origin {b['name']} && gh pr create --base origin/release/vX --title '{b['name']}' (rollback sha {b['sha'][:12]})")
                continue

            def create(b=b, base=base):
                p = git(repo.path, "push", "-u", "origin", b["name"], check=False)
                if p.returncode != 0:
                    self.log(f"    push rejected; branch left intact: {p.stderr.strip()[:200]}")
                    return
                body = gout(repo.path, "log", "--no-merges", "--format=- %s", f"{repo.primary}..{b['name']}")
                c = run(["gh", "pr", "create", "-R", repo.slug, "--base", base, "--head", b["name"], "--title", b["name"], "--assignee", "@me",
                         "--body", f"Salvaged by repo-hygiene from a local branch.\n\n{body}\n"], check=False)
                self.log("    " + (c.stdout.strip() if c.returncode == 0 else "gh pr create failed: " + c.stderr.strip()[:200]))
            self.do(f"push + pr {b['name']} -> {base}", create)

    # -- 8. worktrees
    def worktrees(self, rows, salvaged):
        repo = self.repo
        for r in rows:
            if r["kind"] != "worktree" or r["name"] not in self.by_wt:
                continue
            w = self.by_wt[r["name"]]
            if r["action"] == "migrate" and w["present"]:
                dest = os.path.join(repo.worktree_home(), w["id"])
                if os.path.exists(dest):
                    self.log(f"  migrate {w['id']}: destination exists, skipped")
                    continue

                def move(w=w, dest=dest):
                    os.makedirs(repo.worktree_home(), exist_ok=True)
                    ensure_excluded(repo)
                    git(repo.path, "worktree", "move", w["path"], dest)
                self.do(f"worktree move {w['path']} -> {dest}", move)
            elif r["action"] in ("remove", "salvage-remove") and w["present"]:
                real, _ = repo.status_split(w["path"])
                force = bool(real) and (r["name"] in salvaged)
                if real and not force:
                    self.log(f"  remove {w['id']}: uncommitted paths and no salvage; skipped")
                    continue
                size = w["size"]

                def remove(w=w, force=force):
                    args = ["worktree", "remove"] + (["--force"] if force or w["noise"] else []) + [w["path"]]
                    git(repo.path, *args)
                    self.removed_bytes += size
                self.do(f"worktree remove{' --force' if force or w['noise'] else ''} {w['path']} ({human(size)})", remove)

    # -- 9. branches
    def branches(self, rows):
        repo = self.repo
        live_checked_out = {w["branch"] for w in parse_worktrees(repo) if w.get("branch")}
        for r in rows:
            if r["kind"] != "branch" or r["action"] != "archive-delete":
                continue
            if r["name"] in live_checked_out and self.execute:
                self.log(f"  branch -D {r['name']}: still checked out somewhere; skipped")
                continue
            self.do(f"branch -D {r['name']} ({r['bucket']}: {r['reason'][:60]})", lambda n=r["name"]: git(repo.path, "branch", "-D", n))

    # -- 10. stashes
    def stashes(self, rows):
        repo = self.repo
        todo = [r for r in rows if r["kind"] == "stash" and r["action"] in ("drop", "export-drop")]
        for r in sorted(todo, key=lambda x: -int(re.search(r"\{(\d+)\}", x["name"]).group(1))):
            def drop(r=r):
                # locate by sha at drop time; indexes shift after each drop
                lst = [l.split("\t") for l in gout(repo.path, "stash", "list", "--format=%gd%x09%H").split("\n") if l]
                hit = [ref for ref, sha in lst if sha[:12] == r["sha"]]
                if not hit:
                    self.log(f"    {r['name']} {r['sha']} not found; skipped")
                    return
                git(repo.path, "stash", "drop", hit[0])
            self.do(f"stash drop {r['name']} {r['sha']} ({r['action']})", drop)

    # -- 11/12. finish
    def finish(self, rows):
        repo = self.repo
        self.do("worktree prune", lambda: git(repo.path, "worktree", "prune"))
        for ref in dict.fromkeys(self.archive_refs):
            self.do(f"update-ref -d {ref}", lambda ref=ref: git(repo.path, "update-ref", "-d", ref))
        keep = sorted(r["name"] for r in rows if r["action"] in ("keep", "pr") and r["kind"] == "branch" and r["bucket"] not in ("D8", "D3"))
        keep_wt = sorted(r["name"] for r in rows if r["action"] == "keep" and r["kind"] == "worktree")
        keep_st = sorted(r["sha"] for r in rows if r["action"] == "keep" and r["kind"] == "stash")

        def write_keep():
            with open(os.path.join(repo.archive, "keep.txt"), "w") as f:
                f.write("\n".join([f"branch\t{k}" for k in keep] + [f"worktree\t{k}" for k in keep_wt] + [f"stash\t{k}" for k in keep_st]) + "\n")
        self.do(f"write keep.txt ({len(keep)} branches, {len(keep_wt)} worktrees, {len(keep_st)} stashes)", write_keep)
        self.log(f"  disk released: {human(self.removed_bytes)}")


def ensure_excluded(repo: Repo):
    if git(repo.path, "check-ignore", "-q", ".claude/worktrees/x", check=False).returncode == 0:
        return
    excl = os.path.join(repo.path, ".git", "info", "exclude")
    os.makedirs(os.path.dirname(excl), exist_ok=True)
    with open(excl, "a") as f:
        f.write("\n.claude/worktrees/\n")


def salvage_tree(repo: Repo, work_tree, wid, do, log, parent="HEAD", git_dir=None):
    """Commit the uncommitted state of a checkout to refs/archive/salvage/<wid> without touching its index."""
    ref = f"refs/archive/salvage/{wid}"
    patch = os.path.join(repo.archive, "salvage", f"{TS}-{wid}.patch")

    def make():
        os.makedirs(os.path.dirname(patch), exist_ok=True)
        with tempfile.NamedTemporaryFile(delete=False) as tmp:
            idx = tmp.name
        os.remove(idx)
        env = dict(os.environ, GIT_INDEX_FILE=idx)
        base = ["git"] + (["--git-dir", git_dir] if git_dir else []) + ["--work-tree", work_tree]
        run(base + ["read-tree", parent], cwd=work_tree, env=env)
        excl = [f":(exclude){p}" for p in repo.cfg["noise_paths"] if "*" not in p or p.endswith("/*")]
        run(base + ["add", "-A", "--", "."] + [e.replace("/*", "") for e in excl], cwd=work_tree, env=env, check=False)
        tree = run(base + ["write-tree"], cwd=work_tree, env=env).stdout.strip()
        parent_sha = run(base + ["rev-parse", parent], cwd=work_tree).stdout.strip()
        commit = run(base + ["commit-tree", tree, "-p", parent_sha, "-m", f"salvage({wid}): uncommitted state {TS}"], cwd=work_tree, env=env).stdout.strip()
        run(base + ["update-ref", ref, commit], cwd=work_tree)
        diff = run(base + ["diff", parent_sha, tree], cwd=work_tree).stdout
        with open(patch, "w") as f:
            f.write(diff)
        os.remove(idx)
        log(f"    salvaged {wid}: {ref} = {commit[:12]}, patch {os.path.basename(patch)} ({len(diff.splitlines())} lines)")
    do(f"salvage uncommitted state of {wid} -> {ref}", make)
    return ref


def recover_shape_a(repo: Repo, w, do, log):
    """Registered + missing + admin dir exists: repair the local twin directory, then unlock."""
    local = None
    cat_dir = os.path.dirname(repo.path)
    for container in (f"{repo.name}.worktree", f"{repo.name}.worktrees", f"{repo.name}-worktrees", os.path.join(repo.name, ".claude", "worktrees")):
        cand = os.path.join(cat_dir, container, w["id"])
        if os.path.isfile(os.path.join(cand, ".git")):
            local = cand
            break
    if not local:
        log(f"  repair {w['id']}: no local twin directory found; leaving registration alone (report only)")
        return

    def repair():
        r = git(repo.path, "worktree", "repair", local, check=False)
        log("    repair: " + (r.stdout.strip() or r.stderr.strip() or "ok"))
        admin = os.path.join(repo.path, ".git", "worktrees", w["id"])
        with open(os.path.join(admin, "gitdir"), "w") as f:
            f.write(os.path.join(local, ".git") + "\n")
        with open(os.path.join(local, ".git"), "w") as f:
            f.write(f"gitdir: {admin}\n")
        if w["locked"]:
            git(repo.path, "worktree", "unlock", local, check=False)
        real, noise = repo.status_split(local)
        log(f"    repaired {local}: dirt={len(real)} noise={len(noise)}; re-run audit + manifest to decide keep/remove")
    do(f"worktree repair {local} (registration pointed at {w['path']})", repair)


def recover_orphan(repo: Repo, o, do, log):
    """Gitfile points at a dead admin dir: diff files against the candidate branch, salvage, remove."""
    branch = o.get("candidate_branch")
    if not branch:
        log(f"  orphan {o['path']}: no candidate branch; leaving in place (choose one and re-run with --branch)")
        return None
    git_dir = os.path.join(repo.path, ".git")
    wid = os.path.basename(o["path"])
    ref = None
    with tempfile.NamedTemporaryFile(delete=False) as tmp:
        idx = tmp.name
    os.remove(idx)
    env = dict(os.environ, GIT_INDEX_FILE=idx)
    base = ["git", "--git-dir", git_dir, "--work-tree", o["path"]]
    run(base + ["read-tree", branch], cwd=o["path"], env=env)
    st = run(base + ["status", "--porcelain", "--untracked-files=all"], cwd=o["path"], env=env, check=False).stdout
    os.path.exists(idx) and os.remove(idx)
    real = [l for l in st.split("\n") if l.strip() and not repo.is_noise_path(l[3:].strip('"'))]
    log(f"  orphan {wid}: vs {branch}: {len(real)} non-noise differences")
    if real:
        ref = salvage_tree(repo, o["path"], wid, do, log, parent=branch, git_dir=git_dir)
    do(f"rm -rf {o['path']} ({human(o['size'])})", lambda: shutil.rmtree(o["path"]))
    return ref


# ----------------------------------------------------------------------------- verify
def verify_repo(repo: Repo, log, restore_test=False):
    problems = []
    keep = {"branch": set(), "worktree": set(), "stash": set()}
    kp = os.path.join(repo.archive, "keep.txt")
    if os.path.exists(kp):
        for line in open(kp):
            k, _, v = line.strip().partition("\t")
            if k in keep:
                keep[k].add(v)
    audit = audit_repo(repo, lambda *_: None, fetch=False)
    wt_by_branch = {w["branch"]: w for w in audit["worktrees"] if w.get("branch")}
    for b in audit["branches"]:
        ok = b["bucket"] in ("D8", "D3") or b["name"] in keep["branch"] or (b["worktree"] and b["worktree"] in keep["worktree"])
        if not ok:
            problems.append(f"branch {b['name']} ({b['bucket']}) is neither protected, open-PR, nor kept")
    for w in audit["worktrees"]:
        if w["kind"] == "main":
            continue
        if not w["present"]:
            problems.append(f"worktree {w['path']} missing" + (" (locked)" if w["locked"] else ""))
            continue
        if w["prunable"]:
            problems.append(f"worktree {w['path']} prunable")
        if w["locked"] and w["path"] not in keep["worktree"]:
            problems.append(f"worktree {w['path']} locked ({w['locked']})")
        if not w["layout_ok"]:
            problems.append(f"worktree {w['path']} outside {repo.worktree_home()}")
        if w["dirt"] and not (w.get("branch") in keep["branch"] or w["path"] in keep["worktree"] or wt_by_branch.get(w.get("branch"), {}) and any(b["name"] == w.get("branch") and b["bucket"] == "D3" for b in audit["branches"])):
            problems.append(f"worktree {w['path']} dirty ({len(w['dirt'])} paths) without a kept branch")
    for o in audit["orphans"]:
        if o["shape"] != "not-git":
            problems.append(f"orphan directory {o['path']} ({o['shape']})")
    for s in audit["stashes"]:
        if s["noise"]:
            problems.append(f"stash@{{{s['index']}}} is tool noise")
        elif s["age_days"] is not None and s["age_days"] >= repo.thr["stash_age_days"] and s["sha"][:12] not in keep["stash"]:
            problems.append(f"stash@{{{s['index']}}} is {s['age_days']}d old and not kept")
    if restore_test:
        problems += restore_test_last_bundle(repo, log)
    for p in problems:
        log("  FAIL " + p)
    log(f"== verify {repo.rel}: {'OK' if not problems else str(len(problems)) + ' problems'}")
    return problems


def restore_test_last_bundle(repo: Repo, log):
    bundles = sorted(f for f in os.listdir(repo.archive) if f.endswith(".bundle")) if os.path.isdir(repo.archive) else []
    if not bundles:
        return []
    b = os.path.join(repo.archive, bundles[-1])
    refs_tsv = b.replace(".bundle", ".refs.tsv")
    probs = []
    r = git(repo.path, "bundle", "verify", b, check=False)
    if r.returncode != 0:
        return [f"bundle {bundles[-1]} does not verify: {r.stderr.strip()[:200]}"]
    fr = git(repo.path, "fetch", "--no-tags", b, "+refs/heads/*:refs/restore-test/heads/*", "+refs/archive/*:refs/restore-test/archive/*", check=False)
    if fr.returncode != 0:
        return [f"restore-test: fetching {os.path.basename(b)} failed: {fr.stderr.strip()[:200]}"]
    if os.path.exists(refs_tsv):
        for line in list(open(refs_tsv))[1:]:
            ref, sha, *_ = line.rstrip("\n").split("\t")
            if not commit_exists(repo.path, sha):
                probs.append(f"restore-test: {ref} {sha[:12]} not restorable")
    for line in gout(repo.path, "for-each-ref", "refs/restore-test", "--format=%(refname)").split("\n"):
        if line:
            git(repo.path, "update-ref", "-d", line, check=False)
    log(f"  restore-test: {bundles[-1]} {'round-trips' if not probs else 'FAILED'}")
    return probs


# ----------------------------------------------------------------------------- restore
def restore(repo: Repo, bundle, log, branch=None, stash=None, salvage=None, everything=False):
    if not bundle:
        bundles = sorted(f for f in os.listdir(repo.archive) if f.endswith(".bundle"))
        tsvs = sorted(f for f in os.listdir(repo.archive) if f.endswith(".refs.tsv"))
        if not bundles and not tsvs:
            raise HygieneError("no bundle or refs.tsv found")
        bundle = os.path.join(repo.archive, bundles[-1] if bundles else tsvs[-1].replace(".refs.tsv", ".bundle"))
    bundle_has = os.path.exists(bundle)
    if bundle_has:
        git(repo.path, "bundle", "verify", bundle)
        log(gout(repo.path, "bundle", "list-heads", bundle))
    else:
        log(f"no bundle file ({os.path.basename(bundle)}); restoring from the refs.tsv record instead")
    refs_tsv = bundle.replace(".bundle", ".refs.tsv") if bundle else ""
    recorded = {}
    if refs_tsv and os.path.exists(refs_tsv):
        for line in list(open(refs_tsv))[1:]:
            f = line.rstrip("\n").split("\t")
            if len(f) >= 2:
                recorded[f[0]] = f[1]

    def from_record(ref):
        """Recreate a ref from refs.tsv when the bundle does not carry it (every tip was already
        reachable from a protected ref, so git refused to write an empty bundle)."""
        sha = recorded.get(ref if ref.startswith("refs/") else f"refs/heads/{ref}")
        if sha and commit_exists(repo.path, sha):
            git(repo.path, "update-ref", ref if ref.startswith("refs/") else f"refs/heads/{ref}", sha)
            return True
        return False

    if branch:
        safe_ref(branch)
        r = git(repo.path, "fetch", bundle, f"refs/heads/{branch}:refs/heads/{branch}", check=False) if bundle_has else None
        if (r is None or r.returncode != 0) and not from_record(branch):
            raise HygieneError(f"{branch} is in neither the bundle nor {os.path.basename(refs_tsv)}")
        log(f"restored branch {branch}")
    if stash:
        git(repo.path, "fetch", bundle, f"refs/archive/stash/{stash}:refs/archive/tmp")
        git(repo.path, "stash", "store", "-m", f"restored {stash}", "refs/archive/tmp")
        git(repo.path, "update-ref", "-d", "refs/archive/tmp")
        log(f"restored stash {stash} as stash@{{0}}")
    if salvage:
        git(repo.path, "fetch", bundle, f"refs/archive/salvage/{salvage}:refs/heads/salvage/{salvage}")
        log(f"restored salvage/{salvage} as a branch")
    if everything:
        if bundle_has:
            git(repo.path, "fetch", bundle, "refs/heads/*:refs/heads/*", "refs/archive/*:refs/archive/*", check=False)
        n = sum(1 for ref in recorded if from_record(ref))
        log(f"restored every ref in the bundle, plus {n} recreated from {os.path.basename(refs_tsv)}"
            " (tips still reachable from protected refs, so they were never bundled)")
    if not (branch or stash or salvage or everything):
        log("nothing selected; pass --branch, --stash, --salvage or --all")


# ----------------------------------------------------------------------------- CLI
def make_logger(repo: Repo | None, name):
    path = os.path.join(repo.archive, f"{TS}.{name}.log") if repo else None
    if path:
        os.makedirs(repo.archive, exist_ok=True)

    def log(*parts):
        msg = " ".join(str(p) for p in parts)
        print(msg, flush=True)
        if path:
            with open(path, "a") as f:
                f.write(msg + "\n")
    return log


def rel_from_cwd(cfg):
    common = gout(os.getcwd(), "rev-parse", "--git-common-dir")
    if not common:
        raise HygieneError("not inside a git repository")
    main = os.path.dirname(os.path.realpath(common if os.path.isabs(common) else os.path.join(os.getcwd(), common)))
    rel = os.path.relpath(main, cfg["root"])
    if rel.startswith(".."):
        raise HygieneError(f"{main} is outside root {cfg['root']}")
    return rel


def repos_from_args(cfg, args):
    if getattr(args, "repo", None):
        return [Repo(cfg, rel_from_cwd(cfg) if args.repo == "." else args.repo)]
    if getattr(args, "all", False):
        out = []
        for rel in discover_repos(cfg):
            try:
                out.append(Repo(cfg, rel))
            except HygieneError as e:
                print(f"skip {rel}: {e}")
        return out
    raise HygieneError("pass --repo <category>/<name> or --all")


def cmd_audit(cfg, args):
    for repo in repos_from_args(cfg, args):
        audit_repo(repo, make_logger(repo, "audit"), fetch=not args.no_fetch)


def cmd_manifest(cfg, args):
    for repo in repos_from_args(cfg, args):
        audit = repo.load_audit()
        rows = build_rows(repo, audit)
        gen = os.path.join(repo.archive, "manifest.generated.tsv")
        target = os.path.join(repo.archive, "manifest.tsv")
        carried = 0
        pristine = [dict(r) for r in rows]
        if os.path.exists(target) and manifest_has_edits(repo, target) and not args.force:
            # carry the user's marks forward for rows whose identity (kind, name, sha) is unchanged
            _, old_rows = read_manifest(target)
            _, old_gen = read_manifest(gen) if os.path.exists(gen) else ({}, [])
            gen_action = {(r["kind"], r["name"], r["sha"]): r["action"] for r in old_gen}
            user_settable = {"keep", "pr", "archive-delete", "export-drop", "drop", "remove", "salvage-remove", "migrate", "repair"}
            marks = {(r["kind"], r["name"], r["sha"]): r["action"] for r in old_rows
                     if r["action"] in user_settable and r["action"] != gen_action.get((r["kind"], r["name"], r["sha"]))}
            for r in rows:
                key = (r["kind"], r["name"], r["sha"])
                if key in marks and r["action"] in ("review", "keep", "archive-delete", "export-drop", "drop", "remove", "salvage-remove", "migrate"):
                    r["action"] = marks[key]; r["section"] = "decide" if r["section"] == "decide" else r["section"]; carried += 1
            shutil.copyfile(target, target + ".bak")
        write_manifest(repo, audit, pristine, gen)
        write_manifest(repo, audit, rows, target)
        if carried:
            print(f"{repo.rel}: carried {carried} of your marks into the regenerated manifest (previous copy: manifest.tsv.bak)")
        review = os.path.join(repo.archive, "review.md")
        n_hi = write_review(repo, audit, rows, review)
        c = collections.Counter(r["section"] for r in rows)
        print(f"{repo.rel}: {target}  decide={c['decide']} prefilled={c['prefilled']} auto={c['auto']}  review={review} ({n_hi} medium/high-value items)")


def cmd_apply(cfg, args):
    for repo in repos_from_args(cfg, args):
        log = make_logger(repo, "apply" if args.execute else "apply-dry")
        audit = repo.load_audit()
        if args.policy == "safe":
            rows = [r for r in build_rows(repo, audit) if r["section"] == "auto"]
            log(f"== apply --policy safe {repo.rel}: {len(rows)} auto rows")
        else:
            mpath = args.manifest or os.path.join(repo.archive, "manifest.tsv")
            header, rows = read_manifest(mpath)
            if header.get("audit-id") != audit.get("audit_id"):
                log(f"  note: manifest was generated from audit {header.get('audit-id')}, latest is {audit.get('audit_id')}; every row is re-checked against the latest audit by sha")
            log(f"== apply {repo.rel} from {mpath} ({'EXECUTE' if args.execute else 'dry-run'})")
        Applier(repo, audit, rows, args.execute, log, skip_drifted=args.skip_drifted, policy=args.policy).run_all()
        if args.execute:
            shutil.copyfile(args.manifest or os.path.join(repo.archive, "manifest.tsv"), os.path.join(repo.archive, f"manifest-{TS}.applied.tsv")) if args.policy != "safe" else None
            verify_repo(repo, log, restore_test=False)


def cmd_verify(cfg, args):
    bad = 0
    for repo in repos_from_args(cfg, args):
        bad += len(verify_repo(repo, make_logger(repo, "verify"), restore_test=args.restore_test))
    sys.exit(1 if bad else 0)


def cmd_restore(cfg, args):
    repo = Repo(cfg, rel_from_cwd(cfg) if args.repo == "." else args.repo)
    restore(repo, args.bundle, make_logger(repo, "restore"), branch=args.branch, stash=args.stash, salvage=args.salvage, everything=args.all)


def cmd_recover(cfg, args):
    repo = Repo(cfg, rel_from_cwd(cfg) if args.repo == "." else args.repo)
    log = make_logger(repo, "recover" if args.execute else "recover-dry")
    audit = audit_repo(repo, log, fetch=False)

    def do(desc, fn):
        log(("  [exec] " if args.execute else "  [dry ] ") + desc)
        if args.execute:
            return fn()
    for w in audit["worktrees"]:
        if w["kind"] == "linked" and not w["present"]:
            recover_shape_a(repo, w, do, log)
    for o in audit["orphans"]:
        if o["shape"] == "not-git":
            continue
        if args.branch and len(audit["orphans"]) == 1:
            o["candidate_branch"] = args.branch
        recover_orphan(repo, o, do, log)
    if args.execute:
        do("worktree prune", lambda: git(repo.path, "worktree", "prune"))
        audit_repo(repo, log, fetch=False)


def main(argv=None):
    ap = argparse.ArgumentParser(prog="repo-hygiene", description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--config", default=os.environ.get("REPO_HYGIENE_CONFIG", os.path.join(HERE, "hygiene.toml")))
    ap.add_argument("--version", action="version", version=VERSION)
    sub = ap.add_subparsers(dest="cmd", required=True)

    def common(p, all_ok=True):
        p.add_argument("--repo", help="<category>/<name> relative to root, or . for the repo containing the cwd")
        if all_ok:
            p.add_argument("--all", action="store_true", help="every main checkout under root/<categories>")
    p = sub.add_parser("audit"); common(p); p.add_argument("--no-fetch", action="store_true"); p.set_defaults(fn=cmd_audit)
    p = sub.add_parser("manifest"); common(p); p.add_argument("--force", action="store_true", help="overwrite an edited manifest.tsv"); p.set_defaults(fn=cmd_manifest)
    p = sub.add_parser("apply"); common(p)
    p.add_argument("--execute", action="store_true", help="perform the actions (default is dry-run)")
    p.add_argument("--manifest", help="path to manifest.tsv (default .archive/<repo>/manifest.tsv)")
    p.add_argument("--policy", choices=["safe"], help="safe: only the auto rows of a fresh manifest; no human marks needed")
    p.add_argument("--skip-drifted", action="store_true"); p.set_defaults(fn=cmd_apply)
    p = sub.add_parser("verify"); common(p); p.add_argument("--restore-test", action="store_true"); p.set_defaults(fn=cmd_verify)
    p = sub.add_parser("restore"); common(p, all_ok=False); p.add_argument("--bundle"); p.add_argument("--branch"); p.add_argument("--stash", help="12-char stash sha")
    p.add_argument("--salvage", help="worktree id"); p.add_argument("--all", action="store_true"); p.set_defaults(fn=cmd_restore)
    p = sub.add_parser("recover-worktrees"); common(p, all_ok=False); p.add_argument("--execute", action="store_true"); p.add_argument("--branch", help="candidate branch when exactly one orphan exists")
    p.set_defaults(fn=cmd_recover)
    args = ap.parse_args(argv)
    cfg = load_config(args.config)
    try:
        args.fn(cfg, args)
    except HygieneError as e:
        print(f"error: {e}", file=sys.stderr)
        sys.exit(2)


if __name__ == "__main__":
    main()
