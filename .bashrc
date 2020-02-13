source ~/.git-completion.bash
source ~/.git-prompt.sh
GIT_PS1_SHOWDIRTYSTATE=true
GIT_PS1_SHOWSTASHSTATE=true
GIT_PS1_DESCRIBE_STYLE=describe
GIT_PS1_SHOWCOLORHINTS=true

#PROMPT_COMMAND='history -a;echo -en "\033[m\033[38;5;2m"$(( $(sed -nu "s/MemFree:[\t ]\+\([0-9]\+\) kB/\1/p" /proc/meminfo)/1024))"\033[38;5;22m/"$(($(sed -nu "s/MemTotal:[\t ]\+\([0-9]\+\) kB/\1/Ip" /proc/meminfo)/1024 ))MB"\t\033[m\033[38;5;55m$(< /proc/loadavg)\033[m"'
#PS1='\[\e[m\n\e[1;30m\][$$:$PPID \j:\!\[\e[1;30m\]]\[\e[0;36m\] \T \d \[\e[1;30m\][\[\e[1;34m\]\u@\H\[\e[1;30m\]:\[\e[0;37m\]${SSH_TTY} \[\e[0;32m\]+${SHLVL}\[\e[1;30m\]] \[\e[1;37m\]\w\[\e[0;37m\] \n($SHLVL:\!)\$ '

# < Start SSH Agent
mkdir -p "$HOME/.ssh"
SSH_ENV="$HOME/.ssh/environment"

function run_ssh_env {
	. "${SSH_ENV}" > /dev/null
}

function start_ssh_agent {
	echo "Initializing new SSH agent..."
	ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
	echo "succeeded"
	chmod 600 "${SSH_ENV}"

	run_ssh_env;
	if ls ${HOME}/.ssh/id_* > /dev/null 2>&1 ; then
		ssh-add ~/.ssh/id_*;
	else 
		echo "No keys"
	fi
}

if [ -f "${SSH_ENV}" ]; then
	run_ssh_env;
	ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
		start_ssh_agent;
	}
else
	start_ssh_agent;
fi
# < Start SSH Agent

# < History search, see https://unix.stackexchange.com/questions/5366/command-line-completion-from-command-history/20830#20830
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
bind '"\eOA": history-search-backward'
bind '"\eOB": history-search-forward'
# > History search

# < Prompt
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

function rightprompt() {
	local pwd=`pwd`
	local gt=`__git_ps1`
	local rp="${pwd}${gt}"
	rp=`echo -e "${rp}"`
	printf "%*s" $COLUMNS "${rp}"
}

EXIT_STATUS=0
function exitstatus() {	
	if [[ $EXIT_STATUS != 0 ]]; then
        echo -e "${RED}${EXIT_STATUS}${NOCOLOR} "
    fi
}

function prompt_command() {
	EXIT_STATUS=$?
	local host=""
	if [[ $HOSTNAME != "miju.local" ]]; then
		host=`echo -e "${ORANGE}${USER}@${HOSTNAME}${NOCOLOR} "`
	fi

	PS1="\[$(tput sc; rightprompt; tput rc)\]\t \$(exitstatus)${host}> "
}

PROMPT_COMMAND=prompt_command

# Remove annoying "The default interactive shell is now zsh." message
export BASH_SILENCE_DEPRECATION_WARNING=1

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

# Auto "cd" when entering just a path
shopt -s autocd

alias dc="docker-compose"
# alias code="code-insiders"


export PATH="/usr/local/opt/php@7.3/bin:$PATH"
export PATH="/usr/local/opt/php@7.3/sbin:$PATH"
export PATH="~/.bin:$PATH"
export PATH="/usr/local/opt/grep/libexec/gnubin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

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

[ -s /Users/miju/.config/fzf/completion.bash ] && . /Users/miju/.config/fzf/completion.bash
[ -s /Users/miju/.config/fzf/key-bindings.bash ] && . /Users/miju/.config/fzf/key-bindings.bash
