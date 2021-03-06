# .bashrc

# Source global definitions
#if [ -f /etc/bashrc ]; then
  #. /etc/bashrc
#fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=
set -o vi

alias battery='acpitool -B'
alias grep='grep --color=auto'
alias gse='grunt serve'
alias mkdir='mkdir -p'
alias rm='trash'
alias ls='ls -alh --color=auto'
alias nmcli='nmcli -p'
alias v='vim'
alias json='python -mjson.tool'
alias p='pgrep -fa'
alias viewimage='feh'

export EDITOR='vim'
export VISUAL='vim'
export TERMINAL='urxvt256c-ml'
export GOPATH=~/dev/projects/active/gopath
export PATH=$PATH:${GOPATH//://bin:}/bin
export PATH=$PATH:/home/chris/dev/ide/SqlWorkbenchJ
export PATH=$PATH:/usr/pgsql-9.3/bin
export PATH=$PATH:/home/chris/bin/minishift/minishift-1.34.2-linux-amd64
export PATH=$PATH:/home/chris/bin/crc
export PATH=$PATH:/usr/local/kubebuilder/bin

#java
export JAVA_HOME=/home/chris/java-home
export PATH=$PATH:/home/chris/maven

#python
export PATH=$PATH:/home/chris/.local/bin
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init -)"
fi

#android
export PATH=$PATH:/home/chris/Android/Sdk/platform-tools

#openshift
# source oc_completion.sh

#vi mode esc timeout
export KEYTIMEOUT=1
bindkey -sM vicmd '^[' '^G'
bindkey -rM viins '^X'

#git
alias gro='git fetch origin && git rebase origin/master'
alias gnb='git checkout -b'

source ~/.local.rc

###############################################################################
# Unused
###############################################################################

#Old prompt layout
#export PS1="\[$(tput setaf 245)\]\n\u@\h\[$(tput setaf 10)\]:\[$(tput setaf 67)\]\w\n\[$(tput setaf 7)\]\T\$ \[\e[0;0m\e[m\]"

#source ~/bin/tmuxinator.bash

#alias vim='gvim -v'

export HISTTIMEFORMAT="%T"
export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
export PATH=$HOME/.node/bin:$PATH
export NODE_PATH=$HOME/.node/lib/node_modules:$NODE_PATH
export MANPATH="$HOME/.node/share/man:$MANPATH"  

# execute `ls` when no command entered
#precmd() { 
  #CUR_HIST=`history -t "%T" -1`
  #if [[ $PRE_HIST == $CUR_HIST ]]; then
    #ls
  #fi
  #PRE_HIST=$CUR_HIST
#}

source <(oc completion zsh)

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/home/chris/.sdkman"
[[ -s "/home/chris/.sdkman/bin/sdkman-init.sh" ]] && source "/home/chris/.sdkman/bin/sdkman-init.sh"
