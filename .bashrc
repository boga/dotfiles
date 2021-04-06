# Set CLICOLOR if you want Ansi Colors in iTerm2 
export CLICOLOR=1

# Set colors to match iTerm2 Terminal Colors
export TERM=xterm-256color
NOCOLOR='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHTGRAY='\033[0;37m'
DARKGRAY='\033[1;30m'
LIGHTRED='\033[1;31m'
LIGHTGREEN='\033[1;32m'
YELLOW='\033[1;33m'
LIGHTBLUE='\033[1;34m'
LIGHTPURPLE='\033[1;35m'
LIGHTCYAN='\033[1;36m'
WHITE='\033[1;37m'

# Remove annoying "The default interactive shell is now zsh." message
export BASH_SILENCE_DEPRECATION_WARNING=1

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

export PATH="/usr/local/opt/php@7.3/bin:$PATH"
export PATH="/usr/local/opt/php@7.3/sbin:$PATH"
export PATH="~/.bin:$PATH"
export PATH="~/.bin/android-platform-tools:$PATH"
export PATH="/usr/local/opt/grep/libexec/gnubin:$PATH"
export PATH="~/.local/bin:$PATH"
export PATH="~/go/bin:$PATH"
export PATH="/usr/local/opt/node@10/bin:$PATH"
export PATH="$PATH:/usr/local/sbin"

if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='nano'
else
   export EDITOR='code'
fi

# confirmation
alias mv='mv -i'
alias cp='cp -i'
alias ln='ln -i'
alias T='tmux attach || tmux new'
alias dc="docker-compose"

# Coloring with grc
if [ -f /usr/bin/grc ] || [ -f /usr/local/bin/grc ]; then
	alias blkid="grc --colour=auto blkid" 
	alias cat="grc --colour=auto cat" 
	alias cvs="grc --colour=auto cvs" 
	alias df="grc --colour=auto df" 
	alias digg="grc --colour=auto digg" 
	alias dnf="grc --colour=auto dnf" 
	alias docker-machine="grc --colour=auto docker-machine" 
	alias docker="grc --colour=auto docker" 
	alias du="grc --colour=auto du" 
	alias env="grc --colour=auto env" 
	alias fdisk="grc --colour=auto fdisk" 
	alias findmnt="grc --colour=auto findmnt" 
	alias free="grc --colour=auto free" 
	alias g++="grc --colour=auto g++" 
	alias gcc="grc --colour=auto gcc" 
	alias getfacl="grc --colour=auto getfacl" 
	alias getsebool="grc --colour=auto getsebool" 
	alias id="grc --colour=auto id" 
	alias ifconfig="grc --colour=auto ifconfig" 
	alias iostat="grc --colour=auto iostat" 
	alias ip="grc --colour=auto ip" 
	alias last="grc --colour=auto last" 
	alias ls="grc --colour=auto ls" 
	alias lsattr="grc --colour=auto lsattr" 
	alias lsblk="grc --colour=auto lsblk" 
	alias lsmod="grc --colour=auto lsmod" 
	alias lsof="grc --colour=auto lsof" 
	alias lspci="grc --colour=auto lspci" 
	alias make="grc --colour=auto make" 
	# alias man="grc --colour=auto man" 
	alias mount="grc --colour=auto mount" 
	alias mtr="grc --colour=auto mtr" 
	alias netstat="grc --colour=auto netstat" 
	alias nmap="grc --colour=auto nmap" 
	alias ping="grc --colour=auto ping" 
	alias ps="grc --colour=auto ps" 
	alias sar="grc --colour=auto sar" 
	alias semanage="grc --colour=auto semanage" 
	alias showmount="grc --colour=auto showmount" 
	alias ss="grc --colour=auto ss" 
	alias stat="grc --colour=auto stat" 
	alias sysctl="grc --colour=auto sysctl" 
	alias systemctl="grc --colour=auto systemctl" 
	alias tail="grc --colour=auto tail" 
	alias tcpdump="grc --colour=auto tcpdump"
	alias traceroute="grc --colour=auto traceroute" 
	alias tune2fs="grc --colour=auto tune2fs"
	alias ulimit="grc --colour=auto ulimit" 
	alias uptime="grc --colour=auto uptime" 
	alias wdiff="grc --colour=auto wdiff" 
fi

# Coloring man pages
export LESS=-R
export LESS_TERMCAP_mb=$'\E[1;31m'     # begin blink
export LESS_TERMCAP_md=$'\E[1;36m'     # begin bold
export LESS_TERMCAP_me=$'\E[0m'        # reset bold/blink
export LESS_TERMCAP_so=$'\E[01;44;33m' # begin reverse video
export LESS_TERMCAP_se=$'\E[0m'        # reset reverse video
export LESS_TERMCAP_us=$'\E[1;32m'     # begin underline
export LESS_TERMCAP_ue=$'\E[0m'        # reset underline

# Remove duplicates from shell history
export HISTCONTROL=ignorespace:ignoredups

# https://miro.atlassian.net/wiki/spaces/PT/pages/109150224/aws-vault+How+to+securely+store+AWS+access+keys+locally
# https://github.com/99designs/aws-vault/blob/master/USAGE.md#environment-variables
export AWS_VAULT_KEYCHAIN_NAME=login

# default is 1h, which is awkward
export AWS_SESSION_TOKEN_TTL=12h

if [ -z "$BASH_EXECUTION_STRING" ]; then 
	if [ ! -z `command -v fish` ]; then 
		exec fish; 
	fi
fi

[ -e ${HOME}/.aliases ] && . ${HOME}/.aliases
