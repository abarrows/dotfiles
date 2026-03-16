# Git Worktree + VS Code/Windsurf: Common Pitfalls & Solutions

## Overview

Git worktrees allow multiple working directories from a single repository, but VS Code/Windsurf have specific quirks that can cause issues.

---

## Critical Pitfalls & Solutions

### 1. **VS Code Opens Wrong Worktree**

**Problem:** Opening a file in one worktree opens VS Code in a different worktree.

**Cause:** VS Code's workspace cache gets confused when multiple worktrees exist.

**Solution:**

```bash
# Always open worktrees as separate VS Code windows
code -n /path/to/worktree-1
code -n /path/to/worktree-2

# Or use Windsurf
windsurf -n /path/to/worktree-1
```

**Prevention:** Add to your shell aliases:

```bash
alias wt-open='windsurf -n'
```

---

### 2. **Git Extension Shows Wrong Branch**

**Problem:** VS Code's Git extension displays the wrong branch name or shows changes from other worktrees.

**Cause:** VS Code caches the `.git` directory location and doesn't handle worktree `.git` files correctly.

**Solution:**

```bash
# Reload VS Code window after switching worktrees
# Command Palette: "Developer: Reload Window"
```

**Prevention:** Use the GitLens extension which handles worktrees better:

```json
// .vscode/settings.json
{
  "gitlens.advanced.repositorySearchDepth": 2,
  "gitlens.worktrees.enabled": true
}
```

---

### 3. **Node Modules Shared Across Worktrees**

**Problem:** `node_modules` from one worktree affects another, causing version conflicts.

**Cause:** Symlinks or shared `node_modules` directories.

**Solution:**

```bash
# Run npm install in EACH worktree
cd /path/to/worktree-1 && npm install
cd /path/to/worktree-2 && npm install

# Verify separate node_modules
ls -la node_modules
```

**Prevention:** Use the post-checkout hook (already created in this repo):

- `~/.git-template-directory/hooks/post-checkout`

---

### 4. **ESLint/Prettier Config Not Found**

**Problem:** Linters fail in worktrees, saying config files are missing.

**Cause:** VS Code's working directory is set to the main repo, not the worktree.

**Solution:**

```json
// .vscode/settings.json (in each worktree)
{
  "eslint.workingDirectories": [{ "mode": "auto" }],
  "prettier.configPath": "${workspaceFolder}/.prettierrc"
}
```

**Prevention:** Use workspace-relative paths in all config:

```json
{
  "eslint.workingDirectories": ["${workspaceFolder}"]
}
```

---

### 5. **TypeScript Server Crashes**

**Problem:** TypeScript IntelliSense stops working or shows errors from other worktrees.

**Cause:** VS Code's TypeScript server gets confused by multiple `tsconfig.json` files.

**Solution:**

```bash
# Restart TypeScript server
# Command Palette: "TypeScript: Restart TS Server"
```

**Prevention:**

```json
// .vscode/settings.json
{
  "typescript.tsserver.maxTsServerMemory": 8192,
  "typescript.disableAutomaticTypeAcquisition": false
}
```

---

### 6. **Debugger Attaches to Wrong Process**

**Problem:** Debugger connects to a process running in a different worktree.

**Cause:** Port conflicts when running dev servers in multiple worktrees.

**Solution:**

```bash
# Use different ports for each worktree
# Worktree 1:
PORT=3000 npm start

# Worktree 2:
PORT=3001 npm start
```

**Prevention:** Create per-worktree `.env` files:

```bash
# worktree-1/.env
PORT=3000

# worktree-2/.env
PORT=3001
```

---

### 7. **Git Hooks Don't Run**

**Problem:** Pre-commit hooks fail or don't execute in worktrees.

**Cause:** Hooks are shared via `core.hooksPath` but may reference wrong paths.

**Solution:**

```bash
# Check hook path
git config core.hooksPath

# If using shared hooks, ensure they're worktree-aware
# Example: ~/.git-template-directory/hooks/pre-commit
#!/bin/sh
WORKTREE_ROOT=$(git rev-parse --show-toplevel)
cd "$WORKTREE_ROOT" || exit 1
npm run lint-staged
```

---

### 8. **Search Results Include Other Worktrees**

**Problem:** VS Code search finds files from other worktrees.

**Cause:** VS Code indexes the entire repository, including other worktrees.

**Solution:**

```json
// .vscode/settings.json
{
  "search.exclude": {
    "**/.git": true,
    "**/node_modules": true,
    // Exclude other worktrees (adjust paths)
    "../worktree-*": true
  }
}
```

---

### 9. **Extensions Install in Wrong Worktree**

**Problem:** VS Code extensions install globally but need per-worktree settings.

**Cause:** Extensions don't understand worktree boundaries.

**Solution:**

```json
// .vscode/extensions.json (in each worktree)
{
  "recommendations": [
    "dbaeumer.vscode-eslint",
    "esbenp.prettier-vscode",
    "eamodio.gitlens"
  ]
}
```

---

### 10. **Merge Conflicts Show Wrong Files**

**Problem:** VS Code's merge conflict editor shows files from other worktrees.

**Cause:** Git's conflict markers reference the shared `.git` directory.

**Solution:**

```bash
# Always resolve conflicts in the correct worktree
cd /path/to/correct-worktree
git status
windsurf .
```

**Prevention:** Use `merge.conflictStyle = zdiff3` (already in your config) for clearer conflict markers.

---

## Best Practices for Worktrees + VS Code/Windsurf

### 1. **Naming Convention**

```bash
# Use descriptive worktree names
git worktree add ../main-develop develop
git worktree add ../feature-auth feature/auth
git worktree add ../hotfix-bug hotfix/critical-bug
```

### 2. **Separate VS Code Windows**

```bash
# ALWAYS open worktrees in new windows
windsurf -n ../feature-auth
windsurf -n ../main-develop
```

### 3. **Per-Worktree Settings**

Create `.vscode/settings.json` in each worktree:

```json
{
  "window.title": "${rootName} - ${activeEditorShort}",
  "workbench.colorCustomizations": {
    "titleBar.activeBackground": "#ff0000" // Different color per worktree
  }
}
```

### 4. **Worktree-Specific Scripts**

```json
// package.json in each worktree
{
  "scripts": {
    "dev": "PORT=3000 next dev", // Unique port
    "worktree-info": "git worktree list"
  }
}
```

### 5. **Use GitLens Worktree Features**

```bash
# ALWAYS open worktrees in new windows
windsurf -n ../feature-auth
windsurf -n ../main-develop
```

### 3. **Per-Worktree Settings**

Create `.vscode/settings.json` in each worktree:

```json
{
  "window.title": "${rootName} - ${activeEditorShort}",
  "workbench.colorCustomizations": {
    "titleBar.activeBackground": "#ff0000" // Different color per worktree
  }
}
```

### 4. **Worktree-Specific Scripts**

```json
// package.json in each worktree
{
  "scripts": {
    "dev": "PORT=3000 next dev", // Unique port
    "worktree-info": "git worktree list"
  }
}
```

### 5. **Use GitLens Worktree Features**

```json
// .vscode/settings.json
{
  "gitlens.worktrees.enabled": true,
  "gitlens.worktrees.openComparison": "working",
  "gitlens.statusBar.enabled": true
}
```

---

## Quick Reference Commands

```bash
# List all worktrees
git worktree list

# Create new worktree
git worktree add ../feature-name branch-name

# Remove worktree
git worktree remove ../feature-name

# Prune deleted worktrees
git worktree prune

# Open worktree in new VS Code window
windsurf -n ../feature-name

# Check which worktree you're in
git rev-parse --show-toplevel

# View worktree-specific config
git config --worktree --list
```

---

## Troubleshooting Checklist

When things go wrong:

1. ✅ Reload VS Code window (`Cmd+Shift+P` → "Developer: Reload Window")
2. ✅ Verify you're in the correct worktree: `pwd` and `git branch`
3. ✅ Check node_modules exists: `ls -la node_modules`
4. ✅ Restart TypeScript server: `Cmd+Shift+P` → "TypeScript: Restart TS Server"
5. ✅ Clear VS Code cache: Close VS Code, delete `~/Library/Application Support/Code/Cache`
6. ✅ Verify Git config: `git config --list --show-origin`
7. ✅ Check for port conflicts: `lsof -i :3000`

---

## Additional Resources

- [Git Worktree Documentation](https://git-scm.com/docs/git-worktree)
- [VS Code Multi-root Workspaces](https://code.visualstudio.com/docs/editor/multi-root-workspaces)
- [GitLens Worktree Support](https://github.com/gitkraken/vscode-gitlens#worktree-support)
