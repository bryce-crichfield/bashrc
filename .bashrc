#!/bin/bash
# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

#==============================================================================
# HISTORY SETTINGS
#==============================================================================
HISTCONTROL=ignoreboth:erasedups
HISTSIZE=10000
HISTFILESIZE=20000
shopt -s histappend
shopt -s checkwinsize

#==============================================================================
# COLORS AND PROMPT
#==============================================================================
export TERM=xterm-256color
export CLICOLOR=1

# Enhanced colorful prompt with git branch
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[01;31m\]$(parse_git_branch)\[\033[00m\]\$ '

#==============================================================================
# EXPORTS
#==============================================================================
export EDITOR=vim
export VISUAL=vim
export PAGER=less
export BROWSER=firefox

# Go
export GOPATH=$HOME/go
export GOROOT=/usr/local/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

# Local bin
export PATH=$HOME/.local/bin:$PATH

# Python
export PYTHONDONTWRITEBYTECODE=1
export PIP_REQUIRE_VIRTUALENV=false

#==============================================================================
# SYSTEM ALIASES
#==============================================================================
alias sc='systemctl'
alias scu='systemctl --user'
alias j='journalctl'
alias ju='journalctl --user'
alias jf='journalctl -f'
alias je='journalctl -e'

# Process management
alias psg='ps aux | grep -v grep | grep -i'
alias topcpu='ps auxf | sort -nr -k 3 | head -10'
alias topmem='ps auxf | sort -nr -k 4 | head -10'

# System info
alias ports='netstat -tulanp'
alias listening='lsof -i -P | grep LISTEN'
alias meminfo='free -m -l -t'
alias cpuinfo='lscpu'
alias diskusage='df -H'
alias foldersize='du -sh'

#==============================================================================
# FILE OPERATIONS
#==============================================================================
alias ll='ls -alF --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Enhanced file operations
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias mkdir='mkdir -pv'
alias tree='tree -C'

# Quick navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias -- -='cd -'

#==============================================================================
# NETWORK ALIASES
#==============================================================================
alias myip='curl -s ifconfig.me'
alias localip='hostname -I'
alias ping='ping -c 5'
alias fastping='ping -c 100 -s.2'
alias ports='netstat -tulanp'
alias wget='wget -c'

#==============================================================================
# DOCKER ALIASES (if docker is installed)
#==============================================================================
if command -v docker >/dev/null 2>&1; then
    alias d='docker'
    alias dc='docker-compose'
    alias dps='docker ps'
    alias dpsa='docker ps -a'
    alias di='docker images'
    alias dex='docker exec -it'
    alias dlogs='docker logs -f'
    alias dclean='docker system prune -af'
fi

#==============================================================================
# GIT ALIASES
#==============================================================================
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'
alias gd='git diff'
alias gb='git branch'
alias gco='git checkout'
alias gcb='git checkout -b'

#==============================================================================
# PYTHON ALIASES
#==============================================================================
alias py='python3'
alias pip='pip3'
alias venv='python3 -m venv'
alias serve='python3 -m http.server'

#==============================================================================
# USEFUL FUNCTIONS
#==============================================================================

# Extract various archive formats
extract() {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar e $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Make directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Find process by name
psgrep() {
    ps aux | grep -v grep | grep "$@"
}

# Quick backup function
backup() {
    cp "$1"{,.bak-$(date +%Y%m%d-%H%M%S)}
}

# Weather function
weather() {
    curl -s "wttr.in/${1:-}"
}

# Generate random password
genpass() {
    openssl rand -base64 ${1:-12}
}

# Quick HTTP server
serve() {
    local port="${1:-8000}"
    python3 -m http.server "$port"
}

#==============================================================================
# TOOL INSTALLATION CHECK & SETUP
#==============================================================================

# Function to install packages if they don't exist
install_if_missing() {
    for pkg in "$@"; do
        if ! command -v "$pkg" >/dev/null 2>&1; then
            echo "Installing $pkg..."
            sudo apt update && sudo apt install -y "$pkg"
        fi
    done
}

# Auto-install common tools (run once per session)
if [[ ! -f /tmp/.bashrc_tools_checked ]]; then
    echo "Checking for essential tools..."
    
    # Basic tools
    install_if_missing curl wget git vim tree htop neofetch net-tools
    
    # Development tools
    install_if_missing build-essential python3 python3-pip nodejs npm
    
    # System tools
    install_if_missing tmux screen unzip p7zip-full
    
    # Install fzf if not present
    if ! command -v fzf >/dev/null 2>&1; then
        echo "Installing fzf..."
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf 2>/dev/null || true
        ~/.fzf/install --all 2>/dev/null || true
    fi
    
    # Install Go if not present
    if ! command -v go >/dev/null 2>&1; then
        echo "Installing Go..."
        GO_VERSION="1.21.5"
        wget -q "https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz" -O /tmp/go.tar.gz
        sudo rm -rf /usr/local/go
        sudo tar -C /usr/local -xzf /tmp/go.tar.gz
        rm /tmp/go.tar.gz
    fi
    
    touch /tmp/.bashrc_tools_checked
fi

#==============================================================================
# FZF CONFIGURATION
#==============================================================================
if command -v fzf >/dev/null 2>&1; then
    # Enhanced history search with fzf
    bind '"\C-r": "\C-a fzf_history\C-m"'
    
    fzf_history() {
        local selected=$(history | fzf --tac --height 40% --reverse | sed 's/^[ ]*[0-9]*[ ]*//')
        READLINE_LINE="$selected"
        READLINE_POINT=${#selected}
    }
    
    # FZF file finder
    alias ff='fzf --preview "head -100 {}"'
    
    # FZF directory changer
    fcd() {
        local dir=$(find . -type d 2>/dev/null | fzf)
        if [[ -n "$dir" ]]; then
            cd "$dir"
        fi
    }
fi

#==============================================================================
# FUN STUFF
#==============================================================================

# ASCII Art welcome message
if command -v figlet >/dev/null 2>&1; then
    figlet "Welcome $(whoami)" 2>/dev/null || echo "Welcome $(whoami)!"
else
    echo "Welcome $(whoami)!"
fi

# Show system info on new terminal (optional - comment out if annoying)
if command -v neofetch >/dev/null 2>&1; then
    neofetch --disable theme icons --ascii_distro ubuntu_small
fi

# Random motivational quote function
quote() {
    local quotes=(
        "Code is like humor. When you have to explain it, it's bad. – Cory House"
        "First, solve the problem. Then, write the code. – John Johnson"
        "Experience is the name everyone gives to their mistakes. – Oscar Wilde"
        "In order to be irreplaceable, one must always be different. – Coco Chanel"
        "Java is to JavaScript what car is to Carpet. – Chris Heilmann"
        "Knowledge is power. – Francis Bacon"
        "Sometimes it pays to stay in bed on Monday, rather than spending the rest of the week debugging Monday's code. – Dan Salomon"
    )
    echo "${quotes[$RANDOM % ${#quotes[@]}]}"
}

# Matrix effect (just for fun)
matrix() {
    echo -e "\e[1;40m" ; clear ; while :; do echo $LINES $COLUMNS $(( $RANDOM % $COLUMNS)) $(( $RANDOM % 72 )) ; sleep 0.05; done|awk '{ letters="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#$%^&*()"; c=$4; letter=substr(letters,c,1);a[$3]=0;for (x in a) {o=a[x];a[x]=a[x]+1; printf "\033[%s;%sH\033[2;32m%s",o,x,letter; printf "\033[%s;%sH\033[1;37m%s\033[0;0H",a[x],x,letter;if (a[x] >= $1) { a[x]=0; } }}'
}

#==============================================================================
# COMPLETION ENHANCEMENTS
#==============================================================================
# Enable programmable completion features
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Add tab completion for SSH hostnames
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh;

#==============================================================================
# ALIASES FOR QUICK EDITING
#==============================================================================
alias bashrc='nano ~/.bashrc && source ~/.bashrc'
alias hosts='sudo nano /etc/hosts'

#==============================================================================
# SAFETY ALIASES
#==============================================================================
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'

# Confirmation for dangerous operations
alias rm='rm -I --preserve-root'
alias mv='mv -i'
alias cp='cp -i'
alias ln='ln -i'

alias help='cat << "EOF"
🔧 CUSTOM ALIASES & FUNCTIONS HELP 🔧

📋 SYSTEM MANAGEMENT:
  sc            - systemctl
  scu           - systemctl --user  
  j             - journalctl
  ju            - journalctl --user
  jf            - journalctl -f
  je            - journalctl -e
  psg <name>    - grep processes
  topcpu        - top 10 CPU processes
  topmem        - top 10 memory processes
  ports         - show listening ports
  listening     - show listening processes
  meminfo       - memory info
  cpuinfo       - CPU info
  diskusage     - disk usage
  foldersize    - folder size

📁 FILE OPERATIONS:
  ll            - ls -alF with colors
  la            - ls -A with colors
  l             - ls -CF with colors
  ..            - cd ..
  ...           - cd ../..
  ....          - cd ../../..
  ~             - cd ~
  -             - cd -

🌐 NETWORK:
  myip          - show external IP
  localip       - show local IP
  fastping      - ping 100 times quickly

🐳 DOCKER (if installed):
  d             - docker
  dc            - docker-compose
  dps           - docker ps
  dpsa          - docker ps -a
  di            - docker images
  dex           - docker exec -it
  dlogs         - docker logs -f
  dclean        - docker system prune -af

📦 GIT:
  g             - git
  gs            - git status
  ga            - git add
  gc            - git commit
  gp            - git push
  gl            - git log --oneline --graph
  gd            - git diff
  gb            - git branch
  gco           - git checkout
  gcb           - git checkout -b

🐍 PYTHON:
  py            - python3
  pip           - pip3
  venv          - python3 -m venv
  serve         - python3 -m http.server

🛠️ FUNCTIONS:
  extract <file>     - extract any archive
  mkcd <dir>         - mkdir and cd into it
  psgrep <name>      - find processes by name
  backup <file>      - backup file with timestamp
  weather [city]     - show weather
  genpass [length]   - generate random password
  serve [port]       - start HTTP server
  ff                 - fzf file finder with preview
  fcd                - fzf directory changer
  quote              - random motivational quote
  matrix             - matrix effect (Ctrl+C to exit)

⚡ QUICK EDITS:
  bashrc        - edit and reload .bashrc
  vimrc         - edit .vimrc
  hosts         - edit /etc/hosts

Type any alias or function name to use it!
EOF'

echo "🚀 Bashrc loaded! Type 'quote' for inspiration or 'matrix' for fun!"

