#
# .zshrc
# {{ ansible_managed }}
#
# Inspired by Jeff Geerling https://github.com/geerlingguy/dotfiles/blob/master/.zshrc
#

# Colors.
unset LSCOLORS
export CLICOLOR=1
export CLICOLOR_FORCE=1

setopt HIST_SAVE_NO_DUPS

# Don't require escaping globbing characters in zsh.
unsetopt nomatch

# Enable plugins.
plugins=(git brew history kubectl history-substring-search)

# Custom $PATH with extra locations.
export PATH=/usr/local/bin:$HOME/Library/Python/3.9/bin:/opt/homebrew/bin:/usr/local/sbin:$HOME/.cargo/bin:/usr/local/git/bin:$HOME/.composer/vendor/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/Applications/Wireshark.app/Contents/MacOS:/usr/local/go/bin

# Bash-style time output.
export TIMEFMT=$'\nreal\t%*E\nuser\t%*U\nsys\t%*S'

# Set architecture-specific brew share path.
arch_name="$(uname -m)"
if [ "${arch_name}" = "x86_64" ]; then
    share_path="/usr/local/share"
elif [ "${arch_name}" = "arm64" ]; then
    share_path="/opt/homebrew/share"
else
    echo "Unknown architecture: ${arch_name}"
fi

# Allow history search via up/down keys.
source ${share_path}/zsh-history-substring-search/zsh-history-substring-search.zsh
bindkey "^[[A" history-substring-search-up
bindkey "^[[B" history-substring-search-down

# Aliases.
alias gs='git status'
alias gc='git commit'
alias gp='git pull --rebase'
alias gcam='git commit -am'
alias gl='git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit'
alias cat='bat --style=plain --theme="Monokai Extended Bright"'
if type eza &>/dev/null
then
  alias ls='eza'
fi

# Completions.
if type brew &>/dev/null
then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi

# Initialize completion system once.
if (( ! ${+_comps} ))
then
  autoload -Uz compinit
  compinit
fi

if type codex &>/dev/null
then
  source <(codex completion zsh)
fi
# Case insensitive.
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*'

# Tell homebrew to not autoupdate every single time I run it (just once a week).
export HOMEBREW_AUTO_UPDATE_SECS=604800

# Git branch in prompt
autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst
zstyle ':vcs_info:git:*' formats '%b'

# ^x^e opens editor with the current command
autoload -z edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line

# space expands !!, !$, !v (last command starting with "v")
bindkey " " magic-space

# zoxide
if type zoxide &>/dev/null
then
  eval "$(zoxide init zsh)"
fi

if type fzf &>/dev/null
then
  source <(fzf --zsh)
fi

# NVM
function nvm_init {
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
}

export PS1="$ "
export RPS1=$' %F{cyan}${vcs_info_msg_0_:0:12}'"%F{green} %3~ %*%F{white}"

chpwd() {
  # Set KUBECONFIG when a local kubeconfig file exists in the CWD.
  if [ -f "$PWD/kubeconfig" ]
  then
    export KUBECONFIG="$PWD/kubeconfig"
  fi
}

if [ -e "$HOME/.zshrc.local" ]
then
  source "$HOME/.zshrc.local"
fi
