() {
  emulate -L zsh -o no_hist_expand -o extended_glob -o no_prompt_bang -o prompt_percent -o no_prompt_subst -o no_aliases -o no_bg_nice -o typeset_silent
  (( $+__p9k_trapped )) || { local -i __p9k_trapped; trap : INT; trap "trap ${(q)__p9k_trapint:--} INT" EXIT }
  local -a match reply mbegin mend
  local -i MBEGIN MEND OPTIND
  local MATCH REPLY OPTARG IFS=$' \t\n\0'
  (( ! $+__p9k_instant_prompt_disabled )) || return
  typeset -gi __p9k_instant_prompt_disabled=1 __p9k_instant_prompt_sourced=28
  [[ $ZSH_VERSION == 5.7.1 && $ZSH_PATCHLEVEL == zsh-5.7.1-0-g8b89d0d &&
     $TERM_PROGRAM != 'Hyper' && $+VTE_VERSION == 0 &&
     $POWERLEVEL9K_DISABLE_INSTANT_PROMPT != 'true' &&
     $POWERLEVEL9K_INSTANT_PROMPT != 'off' ]] || { __p9k_instant_prompt_sourced=0; return 1; }
  typeset -g __p9k_instant_prompt_param_sig=$'v99\C-A5.7.1\C-Azsh-5.7.1-0-g8b89d0d\C-A308\C-Aabarrows%\C-A\C-A\C-A\C-A\C-A\C-A\C-A1\C-A0\C-A0\C-AYes\C-A%B%S%#%s%b\C-A/usr/bin/locale\C-AUTF-8\C-A\C-AiTerm.app\C-A\C-A0\C-A/usr/bin/uname\C-A/Users/abarrows/Documents/AMU/repos/personal/dotfiles-and-tooling/dotfiles/.oh-my-zsh/custom/themes/powerlevel10k\C-A\C-A\C-A1${${${${CONDA_PROMPT_MODIFIER#\\(}% }%\\)}:-${CONDA_PREFIX:t}}\C-A37\C-A134\C-A129\C-A125\C-A38\C-A66\C-A37\C-A172\C-A32\C-A70\C-A32\C-A70\C-A67\C-A99\C-A31\C-Afalse\C-A37\C-A168\C-A37\C-A\C-Atrue\C-Ashell\C-Blocal\C-Bglobal\C-A*\C-BDEFAULT\C-A208\C-A70\C-Aeb\C-Aaws|awless|terraform|pulumi\C-A32\C-Aaz|terraform|pulumi\C-Aaz\C-A234\C-A37\C-Afalse\C-A≡\C-A70\C-A70\C-A178\C-A160\C-A20\C-A%K{232}▁\C-B%K{232}▂\C-B%K{232}▃\C-B%K{232}▄\C-B%K{232}▅\C-B%K{232}▆\C-B%K{232}▇\C-B%K{232}█\C-Afalse\C-A248\C-Ad h m s\C-A0\C-A%244Ftook \C-A3\C-A\C-A/Users/abarrows/.p10k.zsh\C-A\C-A\C-A180\C-A%244Fwith \C-A180\C-A180\C-A%n@%m\C-A%n@%m\C-A178\C-A%B%n@%m\C-A\C-A\C-A%n@%m\C-A178\C-Atrue\C-A39\C-A\C-A31\C-Afalse\C-A80\C-A40\C-A50\C-A103\C-Av2\C-Afalse\C-Atrue\C-A160\C-A95\C-A35\C-Afalse\C-A220\C-A90\C-A134\C-Atrue\C-A%{%}\C-A\C-A%{%}\C-A38\C-A${P9K_GCLOUD_PROJECT_NAME//\\%/%%}\C-A32\C-A${P9K_GCLOUD_PROJECT_ID//\\%/%%}\C-A60\C-Agcloud|gcs\C-A37\C-Afalse\C-Atrue\C-Ashell\C-Blocal\C-Bglobal\C-A*\C-BDEFAULT\C-A${P9K_GOOGLE_APP_CRED_PROJECT_ID//\\%/%%}\C-A32\C-Aterraform|pulumi\C-A37\C-Atrue\C-Atrue\C-A172\C-Ashell\C-Blocal\C-A\C-Anone\C-Averbose\C-A${P9K_IP_RX_RATE:+%70F⇣$P9K_IP_RX_RATE }${P9K_IP_TX_RATE:+%215F⇡$P9K_IP_TX_RATE }%38F$P9K_IP_IP\C-A38\C-Ae.*\C-A32\C-Afalse\C-Atrue\C-A32\C-Afalse\C-Atrue\C-Ashell\C-Blocal\C-Bglobal\C-A*\C-BDEFAULT\C-A${P9K_KUBECONTEXT_CLOUD_CLUSTER:-${P9K_KUBECONTEXT_NAME}}${${:-/$P9K_KUBECONTEXT_NAMESPACE}:#/default}\C-A134\C-A○\C-A%244Fat \C-Akubectl|helm|kubens|kubectx|oc|istioctl|kogito\C-A161\C-Adir\C-Bvcs\C-Bnewline\C-A\\uE0B2\C-A\\uE0B0\C-A\\uE0B0\C-A%242F\\uE0B1\C-A166\C-A66\C-A178\C-A5\C-A∅\C-A32\C-Afalse\C-Atrue\C-Ashell\C-Blocal\C-Bglobal\C-A178\C-Apowerline\C-A\C-A─\C-A238\C-A%238F╭─\C-A%238F─╮\C-A%238F╰─\C-A%238F─╯\C-A\C-A%238F├─\C-A%238F─┤\C-A74\C-A72\C-A70\C-A\C-A\C-Afalse\C-A70\C-Afalse\C-Atrue\C-Ashell\C-Blocal\C-Bglobal\C-A70\C-Atrue\C-A\C-A\C-A\C-A\C-A\C-A\C-A39\C-Anord\C-A70\C-A255\C-A117\C-A99\C-Afalse\C-Atrue\C-Ashell\C-Blocal\C-Bglobal\C-A99\C-Atrue\C-A67\C-Afalse\C-Atrue\C-Ashell\C-Blocal\C-Bglobal\C-Atrue\C-A\C-A❮\C-A196\C-A❯\C-A196\C-A▶\C-A196\C-AV\C-A196\C-A\C-A\C-A\C-A\C-A❮\C-A76\C-A❯\C-A76\C-A▶\C-A76\C-AV\C-A76\C-Atrue\C-A68\C-A94\C-A${P9K_CONTENT}${${P9K_PYENV_PYTHON_VERSION:#$P9K_CONTENT}:+ $P9K_PYENV_PYTHON_VERSION}\C-A37\C-Afalse\C-Atrue\C-Ashell\C-Blocal\C-Bglobal\C-A66\C-A178\C-A▲\C-A168\C-Afalse\C-Atrue\C-Ashell\C-Blocal\C-Bglobal\C-Astatus\C-Bcommand_execution_time\C-Bbackground_jobs\C-Bdirenv\C-Basdf\C-Bvirtualenv\C-Banaconda\C-Bpyenv\C-Bgoenv\C-Bnodenv\C-Bnvm\C-Bnodeenv\C-Brbenv\C-Brvm\C-Bfvm\C-Bluaenv\C-Bjenv\C-Bplenv\C-Bphpenv\C-Bhaskell_stack\C-Bkubecontext\C-Bterraform\C-Baws\C-Baws_eb_env\C-Bazure\C-Bgcloud\C-Bgoogle_app_cred\C-Bcontext\C-Bnordvpn\C-Branger\C-Bnnn\C-Bvim_shell\C-Bmidnight_commander\C-Bnix_shell\C-Bvi_mode\C-Btodo\C-Btimewarrior\C-Btaskwarrior\C-Btime\C-Bnewline\C-A\\uE0B2\C-A\\uE0B0\C-A\\uE0B2\C-A%242F\\uE0B3\C-A37\C-Atrue\C-A168\C-Afalse\C-Afalse\C-A\C-A1\C-A(.bzr|.citc|.git|.hg|.node-version|.python-version|.go-version|.ruby-version|.lua-version|.java-version|.perl-version|.php-version|.tool-version|.shorten_folder_marker|.svn|.terraform|CVS|Cargo.toml|composer.json|go.mod|package.json|stack.yaml)\C-Atruncate_to_unique\C-Atrue\C-A160\C-Atrue\C-A160\C-A✘\C-Atrue\C-A160\C-A✘\C-A✘\C-Atrue\C-Atrue\C-A70\C-Atrue\C-A70\C-A✔\C-A✔\C-Afalse\C-A96\C-A74\C-A*\C-BOTHER\C-A38\C-Afalse\C-A${P9K_CONTENT:0:24}${${P9K_CONTENT:24}:+…}\C-A110\C-A66\C-A%D{%I:%M:%S %p}\C-A%244Fat \C-Afalse\C-A\C-A110\C-Afalse\C-Atrue\C-Aalways\C-Agit\C-A\C-A76\C-A-1\C-A-1\C-A-1\C-A${$((my_git_formatter(1)))+${my_git_format}}\C-A~\C-Atrue\C-A${$((my_git_formatter(0)))+${my_git_format}}\C-A244\C-A-1\C-A178\C-A%244Fon \C-A-1\C-A-1\C-A76\C-A?\C-A-1\C-A76\C-A\C-A34\C-A37\C-A\C-A\C-Afalse\C-Afalse\C-ANORMAL\C-A\C-A66\C-A106\C-A172\C-A68\C-AOVERTYPE\C-AVISUAL\C-A\C-A81\C-A(wg|(.*tun))[0-9]*\C-Afalse\C-A68'
  local gitstatus_dir=/Users/abarrows/Documents/AMU/repos/personal/dotfiles-and-tooling/dotfiles/.oh-my-zsh/custom/themes/powerlevel10k/gitstatus
  local gitstatus_header=\#\ ae988158e1044abb1626a15d6a27751cd80c13be
  local -i ZLE_RPROMPT_INDENT=1
  local PROMPT_EOL_MARK=%B%S%\#%s%b
  [[ -n $SSH_CLIENT || -n $SSH_TTY || -n $SSH_CONNECTION ]] && local ssh=1 || local ssh=0
  local cr=$'\r' lf=$'\n' esc=$'\e[' rs=$'\x1e' us=$'\x1f'
  local -i height=1
  local prompt_dir=/Users/abarrows/.cache/p10k-abarrows

  local real_gitstatus_header
  if [[ -r $gitstatus_dir/install.info ]]; then
    IFS= read -r real_gitstatus_header <$gitstatus_dir/install.info || real_gitstatus_header=borked
  fi
  if [[ $real_gitstatus_header != $gitstatus_header ]]; then
    __p9k_instant_prompt_sourced=0
    return 1
  fi
  [[ $ZSH_SUBSHELL == 0 && -z $ZSH_SCRIPT && -z $ZSH_EXECUTION_STRING &&
     -t 0 && -t 1 && -t 2 && -o interactive && -o zle && -o no_xtrace ]] || return
  zmodload zsh/langinfo zsh/terminfo zsh/system || return
  if [[ $langinfo[CODESET] != (utf|UTF)(-|)8 ]]; then
    local loc_cmd=$commands[locale]
    [[ -z $loc_cmd ]] && loc_cmd=/usr/bin/locale
    if [[ -x $loc_cmd ]]; then
      local -a locs
      if locs=(${(@M)$(locale -a 2>/dev/null):#*.(utf|UTF)(-|)8}) && (( $#locs )); then
        local loc=${locs[(r)(#i)C.UTF(-|)8]:-${locs[(r)(#i)en_US.UTF(-|)8]:-$locs[1]}}
        [[ -n $LC_ALL ]] && local LC_ALL=$loc || local LC_CTYPE=$loc
      fi
    fi
  fi
  (( $+terminfo[cuu] && $+terminfo[cuf] && $+terminfo[ed] && $+terminfo[sc] && $+terminfo[rc] )) || return
  local pwd=${(%):-%/}
  local prompt_file=$prompt_dir/prompt-${#pwd}
  local key=$pwd:$ssh:${(%):-%#}
  local content
  { content="$(<$prompt_file)" } 2>/dev/null || return
  local tail=${content##*$rs$key$us}
  [[ ${#tail} != ${#content} ]] || return
  local P9K_PROMPT=instant
  if [[ $P9K_TTY != old ]]; then

    typeset -gx P9K_TTY=old
    zmodload -F zsh/stat b:zstat || return
    zmodload zsh/datetime || return
    local -a stat
    if zstat -A stat +ctime -- $TTY 2>/dev/null &&
      (( EPOCHREALTIME - stat[1] < 5.0000000000 )); then
      P9K_TTY=new
    fi
  fi
  local -i _p9k__empty_line_i=3 _p9k__ruler_i=3
  local -A _p9k_display_k=(-2/left 11 2/left 105 -2/right/timewarrior 93 -2/right/fvm 49 -2/right/nodenv 39 1/right/plenv 55 1/right/nvm 41 1/right/background_jobs 25 1/right/direnv 27 1/right/timewarrior 93 1/right/midnight_commander 85 1/right/rvm 47 -1/right 107 1/right/vim_shell 83 -2/right/plenv 55 -2/right/nvm 41 1/right/nnn 81 1/right/google_app_cred 73 1/right/asdf 29 1/right/nordvpn 77 -2/right/rvm 47 1/left/dir 17 -2/right/ranger 79 1/right/rbenv 45 1/right/terraform 63 1/right/nodenv 39 -1/left 105 -2/right/context 75 -2/left/vcs 19 -2/right/anaconda 33 -2/right/nnn 81 -2/right/google_app_cred 73 -2/right/asdf 29 1/right/virtualenv 31 -2/right/haskell_stack 59 -2/right/rbenv 45 1/right_frame 9 1/right 13 2/right 107 -2/right/virtualenv 31 1/right/pyenv 35 1/right/nodeenv 43 1/right/goenv 37 -2/right 13 -2/right/background_jobs 25 2/right_frame 103 1/right/haskell_stack 59 -2/right_frame 9 1/right/ranger 79 1/right/aws 65 1/right/jenv 53 -2/right/pyenv 35 -2/right/goenv 37 empty_line 1 1/right/todo 91 -2/right/midnight_commander 85 -1 99 1/right/context 75 -2/right/aws 65 -2/right/jenv 53 -2 5 1/left 11 1/right/azure 69 -1/gap 109 -1/right_frame 103 -2/right/todo 91 -2/right/vim_shell 83 1/right/aws_eb_env 67 -2/gap 15 1/left/vcs 19 1/right/time 97 -2/right/gcloud 71 1/right/kubecontext 61 -2/right/vi_mode 89 -2/right/azure 69 1/right/anaconda 33 1/right/nix_shell 87 -2/right/status 21 -2/right/taskwarrior 95 -2/right/aws_eb_env 67 -2/right/terraform 63 1 5 1/left_frame 7 -1/left_frame 101 2 99 -2/right/time 97 -2/right/nordvpn 77 -2/right/luaenv 51 ruler 3 -2/right/phpenv 57 1/gap 15 2/gap 109 1/right/command_execution_time 23 2/left_frame 101 1/right/taskwarrior 95 -2/right/kubecontext 61 -2/left_frame 7 1/right/gcloud 71 -2/right/command_execution_time 23 -2/right/nix_shell 87 1/right/status 21 -2/right/nodeenv 43 -2/left/dir 17 -2/right/direnv 27 1/right/vi_mode 89 1/right/luaenv 51 1/right/phpenv 57 1/right/fvm 49)
  local -a _p9k__display_v=(empty_line hide ruler hide 1 show 1/left_frame show 1/right_frame show 1/left show 1/right show 1/gap show 1/left/dir show 1/left/vcs show 1/right/status show 1/right/command_execution_time show 1/right/background_jobs show 1/right/direnv show 1/right/asdf show 1/right/virtualenv show 1/right/anaconda show 1/right/pyenv show 1/right/goenv show 1/right/nodenv show 1/right/nvm show 1/right/nodeenv show 1/right/rbenv show 1/right/rvm show 1/right/fvm show 1/right/luaenv show 1/right/jenv show 1/right/plenv show 1/right/phpenv show 1/right/haskell_stack show 1/right/kubecontext show 1/right/terraform show 1/right/aws show 1/right/aws_eb_env show 1/right/azure show 1/right/gcloud show 1/right/google_app_cred show 1/right/context show 1/right/nordvpn show 1/right/ranger show 1/right/nnn show 1/right/vim_shell show 1/right/midnight_commander show 1/right/nix_shell show 1/right/vi_mode show 1/right/todo show 1/right/timewarrior show 1/right/taskwarrior show 1/right/time show 2 show 2/left_frame show 2/right_frame show 2/left show 2/right show 2/gap show)
  function p10k() {
    emulate -L zsh -o no_hist_expand -o extended_glob -o no_prompt_bang -o prompt_percent -o no_prompt_subst -o no_aliases -o no_bg_nice -o typeset_silent
  (( $+__p9k_trapped )) || { local -i __p9k_trapped; trap : INT; trap "trap ${(q)__p9k_trapint:--} INT" EXIT }
  local -a match reply mbegin mend
  local -i MBEGIN MEND OPTIND
  local MATCH REPLY OPTARG IFS=$' \t\n\0'; [[ $langinfo[CODESET] != (utf|UTF)(-|)8 ]] && _p9k_init_locale && { [[ -n $LC_ALL ]] && local LC_ALL=$__p9k_locale || local LC_CTYPE=$__p9k_locale }
    [[ $1 == display ]] || return
    shift
    local -i k dump
    local opt prev new pair list name var
    while getopts ":ha" opt; do
      case $opt in
        a) dump=1;;
        h) return 0;;
        ?) return 1;;
      esac
    done
    if (( dump )); then
      reply=()
      shift $((OPTIND-1))
      (( ARGC )) || set -- "*"
      for opt; do
        for k in ${(u@)_p9k_display_k[(I)$opt]:/(#m)*/$_p9k_display_k[$MATCH]}; do
          reply+=($_p9k__display_v[k,k+1])
        done
      done
      return 0
    fi
    for opt in "${@:$OPTIND}"; do
      pair=(${(s:=:)opt})
      list=(${(s:,:)${pair[2]}})
      if [[ ${(b)pair[1]} == $pair[1] ]]; then
        local ks=($_p9k_display_k[$pair[1]])
      else
        local ks=(${(u@)_p9k_display_k[(I)$pair[1]]:/(#m)*/$_p9k_display_k[$MATCH]})
      fi
      for k in $ks; do
        if (( $#list == 1 )); then
          [[ $_p9k__display_v[k+1] == $list[1] ]] && continue
          new=$list[1]
        else
          new=${list[list[(I)$_p9k__display_v[k+1]]+1]:-$list[1]}
          [[ $_p9k__display_v[k+1] == $new ]] && continue
        fi
        _p9k__display_v[k+1]=$new
        name=$_p9k__display_v[k]
        if [[ $name == (empty_line|ruler) ]]; then
          var=_p9k__${name}_i
          [[ $new == hide ]] && typeset -gi $var=3 || unset $var
        elif [[ $name == (#b)(<->)(*) ]]; then
          var=_p9k__${match[1]}${${${${match[2]//\/}/#left/l}/#right/r}/#gap/g}
          [[ $new == hide ]] && typeset -g $var= || unset $var
        fi
      done
    done
  }
  [[ $P9K_TTY == old ]] && { unset _p9k__empty_line_i; _p9k__display_v[2]=print }

  local _p9k__1rkubecontext=
  _p9k__display_v[62]=hide

  local _p9k__1raws=
  _p9k__display_v[66]=hide

  local _p9k__1razure=
  _p9k__display_v[70]=hide

  local _p9k__1rgcloud=
  _p9k__display_v[72]=hide

  local _p9k__1rgoogle_app_cred=
  _p9k__display_v[74]=hide

  trap "unset -m _p9k__\*; unfunction p10k" EXIT
  local -a _p9k_t=("${(@ps:$us:)${tail%%$rs*}}")
  typeset -ga __p9k_used_instant_prompt=("${(@e)_p9k_t[-3,-1]}")

  (( height += ${#${__p9k_used_instant_prompt[1]//[^$lf]}} ))
  local _p9k__ret
  function _p9k_prompt_length() {
    local COLUMNS=1024
    local -i x y=$#1 m
    if (( y )); then
      while (( ${${(%):-$1%$y(l.1.0)}[-1]} )); do
        x=y
        (( y *= 2 ));
      done
      local xy
      while (( y > x + 1 )); do
        m=$(( x + (y - x) / 2 ))
        typeset ${${(%):-$1%$m(l.x.y)}[-1]}=$m
      done
    fi
    _p9k__ret=$x
  }
  local out

  local mark=${(e)PROMPT_EOL_MARK}
  [[ $mark == "%B%S%#%s%b" ]] && _p9k__ret=1 || _p9k_prompt_length $mark
  local -i fill=$((COLUMNS > _p9k__ret ? COLUMNS - _p9k__ret : 0))
  out+="${(%):-%b%k%f%s%u$mark${(pl.$fill.. .)}$cr%b%k%f%s%u%E}"

  out+="${(pl.$height..$lf.)}$esc${height}A$terminfo[sc]"
  out+=${(%):-"$__p9k_used_instant_prompt[1]$__p9k_used_instant_prompt[2]"}
  if [[ -n $__p9k_used_instant_prompt[3] ]]; then
    _p9k_prompt_length "$__p9k_used_instant_prompt[2]"
    local -i left_len=_p9k__ret
    _p9k_prompt_length "$__p9k_used_instant_prompt[3]"
    local -i gap=$((COLUMNS - left_len - _p9k__ret - ZLE_RPROMPT_INDENT))
    if (( gap >= 40 )); then
      out+="${(pl.$gap.. .)}${(%):-${__p9k_used_instant_prompt[3]}%b%k%f%s%u}$cr$esc${left_len}C"
    fi
  fi
  typeset -g __p9k_instant_prompt_output=${TMPDIR:-/tmp}/p10k-instant-prompt-output-${(%):-%n}-$$
  { echo -n > $__p9k_instant_prompt_output } || return
  print -rn -- "$out" || return
  local fd_null
  sysopen -ru fd_null /dev/null || return
  exec {__p9k_fd_0}<&0 {__p9k_fd_1}>&1 {__p9k_fd_2}>&2 0<&$fd_null 1>$__p9k_instant_prompt_output
  exec 2>&1 {fd_null}>&-
  typeset -gi __p9k_instant_prompt_active=1
  typeset -g __p9k_instant_prompt_dump_file=${XDG_CACHE_HOME:-~/.cache}/p10k-dump-${(%):-%n}.zsh
  if builtin source $__p9k_instant_prompt_dump_file 2>/dev/null && (( $+functions[_p9k_preinit] )); then
    _p9k_preinit
  fi
  function _p9k_instant_prompt_cleanup() {
    (( ZSH_SUBSHELL == 0 && ${+__p9k_instant_prompt_active} )) || return 0
    emulate -L zsh -o no_hist_expand -o extended_glob -o no_prompt_bang -o prompt_percent -o no_prompt_subst -o no_aliases -o no_bg_nice -o typeset_silent
  (( $+__p9k_trapped )) || { local -i __p9k_trapped; trap : INT; trap "trap ${(q)__p9k_trapint:--} INT" EXIT }
  local -a match reply mbegin mend
  local -i MBEGIN MEND OPTIND
  local MATCH REPLY OPTARG IFS=$' \t\n\0'
    unset __p9k_instant_prompt_active
    exec 0<&$__p9k_fd_0 1>&$__p9k_fd_1 2>&$__p9k_fd_2 {__p9k_fd_0}>&- {__p9k_fd_1}>&- {__p9k_fd_2}>&-
    unset __p9k_fd_0 __p9k_fd_1 __p9k_fd_2
    typeset -gi __p9k_instant_prompt_erased=1
    print -rn -- $terminfo[rc]${(%):-%b%k%f%s%u}$terminfo[ed]
    if [[ -s $__p9k_instant_prompt_output ]]; then
      command cat $__p9k_instant_prompt_output 2>/dev/null
      if (( $1 )); then
        local _p9k__ret mark="${(e)${PROMPT_EOL_MARK-%B%S%#%s%b}}"
        _p9k_prompt_length $mark
        local -i fill=$((COLUMNS > _p9k__ret ? COLUMNS - _p9k__ret : 0))
        echo -nE - "${(%):-%b%k%f%s%u$mark${(pl.$fill.. .)}$cr%b%k%f%s%u%E}"
      fi
    fi
    zshexit_functions=(${zshexit_functions:#_p9k_instant_prompt_cleanup})
    zmodload -F zsh/files b:zf_rm || return
    local user=${(%):-%n}
    local root_dir=${__p9k_instant_prompt_dump_file:h}
    zf_rm -f -- $__p9k_instant_prompt_output $__p9k_instant_prompt_dump_file{,.zwc} $root_dir/p10k-instant-prompt-$user.zsh{,.zwc} $root_dir/p10k-$user/prompt-*(N) 2>/dev/null
  }
  function _p9k_instant_prompt_precmd_first() {
    emulate -L zsh -o no_hist_expand -o extended_glob -o no_prompt_bang -o prompt_percent -o no_prompt_subst -o no_aliases -o no_bg_nice -o typeset_silent
  (( $+__p9k_trapped )) || { local -i __p9k_trapped; trap : INT; trap "trap ${(q)__p9k_trapint:--} INT" EXIT }
  local -a match reply mbegin mend
  local -i MBEGIN MEND OPTIND
  local MATCH REPLY OPTARG IFS=$' \t\n\0'; [[ $langinfo[CODESET] != (utf|UTF)(-|)8 ]] && _p9k_init_locale && { [[ -n $LC_ALL ]] && local LC_ALL=$__p9k_locale || local LC_CTYPE=$__p9k_locale }
    function _p9k_instant_prompt_sched_last() {
      (( ${+__p9k_instant_prompt_active} )) || return 0
      _p9k_instant_prompt_cleanup 1
      setopt no_local_options prompt_cr prompt_sp
    }
    zmodload zsh/sched
    sched +0 _p9k_instant_prompt_sched_last
    precmd_functions=(${(@)precmd_functions:#_p9k_instant_prompt_precmd_first})
  }
  zshexit_functions=(_p9k_instant_prompt_cleanup $zshexit_functions)
  precmd_functions=(_p9k_instant_prompt_precmd_first $precmd_functions)
  DISABLE_UPDATE_PROMPT=true
} && unsetopt prompt_cr prompt_sp || true
