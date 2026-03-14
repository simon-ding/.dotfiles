#!/usr/bin/env zsh

typeset -U path fpath  # 路径去重


# homebrew general
# --- 1. Homebrew 路径自动探测 ---
if [[ -d "/opt/homebrew" ]]; then
  # macOS ARM 路径
  export HOMEBREW_PREFIX="/opt/homebrew"
elif [[ -d "/home/linuxbrew/.linuxbrew" ]]; then
  # Bazzite / Linux 标准路径
  export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
fi

# 如果找到了 Homebrew，则初始化环境变量 (PATH, MANPATH 等)
if [[ -n "$HOMEBREW_PREFIX" ]]; then
  eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"

  export PATH="$HOMEBREW_PREFIX/bin:$PATH"

  if [[ -d "$HOMEBREW_PREFIX/share/zsh/site-functions" ]]; then
    fpath=($HOMEBREW_PREFIX/share/zsh/site-functions $fpath)
  fi

  # zsh-autosuggestions & zsh-syntax-highlighting
  source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  source $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

fi

HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000

setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# --- 4. 启动补全系统 ---
autoload -Uz compinit
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.m1) ]]; then
  compinit -C
else
  compinit
fi

# 强化补全风格 (美化 Tab 选单)
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # 忽略大小写补全

# 加载历史前缀搜索 widget
autoload -Uz up-line-or-beginning-search
autoload -Uz down-line-or-beginning-search

# 注册为 zle widget（关键）
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# 这里使用 $terminfo 数组来确保跨终端的兼容性
if [[ -n "${terminfo[kcuu1]}" ]]; then
  bindkey "${terminfo[kcuu1]}" up-line-or-beginning-search
fi
if [[ -n "${terminfo[kcud1]}" ]]; then
  bindkey "${terminfo[kcud1]}" down-line-or-beginning-search
fi

# failsafe 强制绑定按键（如果上面基于 terminfo 的绑定失败了）
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search

# case "$(uname -s)" in
#   Darwin) source "$HOME/.dotfiles/zsh/mac.zsh" ;;
#   Linux)  source "$HOME/.dotfiles/zsh/linux.zsh" ;;
# esac

# ===== Home / End 键支持 =====

# Home
bindkey '^[[H' beginning-of-line
bindkey '^[[1~' beginning-of-line
bindkey '^[[7~' beginning-of-line
bindkey '^[[OH' beginning-of-line

# End
bindkey '^[[F' end-of-line
bindkey '^[[4~' end-of-line
bindkey '^[[8~' end-of-line
bindkey '^[[OF' end-of-line

#tmux
bindkey '^[[1;5H' beginning-of-line
bindkey '^[[1;5F' end-of-line

# =============================

export LS_COLORS="\
di=38;5;75:\
ln=38;5;81:\
ex=38;5;71:\
fi=0:\
pi=38;5;178:\
so=38;5;170:\
bd=38;5;110:\
cd=38;5;110:\
su=38;5;196:\
sg=38;5;178:\
tw=38;5;130:\
ow=38;5;130"

alias ls='ls --color=auto -p --group-directories-first'
alias ll='ls -lh'

if command -v vim > /dev/null 2>&1; then
  alias vi='vim'
fi

export PATH=$HOME/.gem/bin:$PATH:~/go/bin

# --- Custom Functions ---
extract() { # 解压函数，支持多种格式
  # 1. 检查参数个数是否为 0
  if (($# == 0)); then
    echo "❌ Usage: extract <file_name>"
    return 1
  fi

  # 2. 使用双引号包裹变量，防止空值或带空格的文件名报错
  if [ -f "$1" ]; then
    case "$1" in
      *.tar.bz2) tar xjf "$1" ;;
      *.tar.gz) tar xzf "$1" ;;
      *.bz2) bunzip2 "$1" ;;
      *.rar) unrar x "$1" ;;
      *.gz) gunzip "$1" ;;
      *.tar) tar xf "$1" ;;
      *.tbz2) tar xjf "$1" ;;
      *.tgz) tar xzf "$1" ;;
      *.zip) unzip "$1" ;;
      *.7z) 7z x "$1" ;;
      *) echo "❓ '$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "❌ '$1' is not a valid file"
    return 1
  fi
}

serve() {
  local port="${1:-8080}"
  echo "🚀 Serving current directory at http://localhost:$port"
  # 优先使用 Go 写的静态服务工具，没有则用 Python
  if command -v go-serve &> /dev/null; then
    go-serve -port "$port"
  else
    python3 -m http.server "$port"
  fi
}

# --- End Custom Functions ---

is_distrobox() {
  [ -f "/.distroboxenv" ] || [ -n "$DISTROBOX_ENTER_PATH" ]
}

devbox() {
  if command -v distrobox > /dev/null 2>&1; then
    distrobox enter dev
  else
    if is_distrobox; then
      return 0
    fi
    echo "no distrobox, ignored"
    return 1
  fi
}

function macos_envs {
  if [[ $- == *i* ]]; then #只在交互式模式使用gnu命令，避免破坏系统脚本
    export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
    export PATH="/opt/homebrew/opt/grep/libexec/gnubin:$PATH"
  fi

  export PATH="/opt/homebrew/opt/node@20/bin:$PATH:$HOME/development/flutter/bin:$HOME/Library/Python/3.9/bin"
  export LDFLAGS="-L/opt/homebrew/opt/node@20/lib"
  export CPPFLAGS="-I/opt/homebrew/opt/node@20/include"

  export POLARIS_NO_AUTO_DOWNLOAD=true

}

function linux_envs {
  export PATH="$PATH:$HOME/development/flutter/bin"
  export PATH="$PATH:/usr/local/go/bin"

  source /etc/os-release
  if [[ "$ID" == "bazzite" ]]; then
    #pass, already sourced
  elif [[ "$ID" == "arch" ]]; then
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  else
    source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  fi
}

if [[ "$OSTYPE" == "darwin"* ]]; then
  macos_envs
else
  linux_envs
fi

# homebrew ustc mirror
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_ENV_HINTS=1
export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.ustc.edu.cn/brew.git"
export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.ustc.edu.cn/homebrew-core.git"
export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles"
export HOMEBREW_API_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles/api"

# flutter china mirror
export PUB_HOSTED_URL="https://pub.flutter-io.cn"
export FLUTTER_STORAGE_BASE_URL="https://storage.flutter-io.cn"

# fzf, bat, fd 配置
if command -v fzf > /dev/null 2>&1; then
  source <(fzf --zsh)
  if command -v bat > /dev/null 2>&1; then
    # 设置 FZF 的默认预览行为
    export FZF_DEFAULT_OPTS="--height 60% --layout=reverse --border --preview 'bat --color=always --style=numbers --line-range :500 {}'"
    # 设置预览窗口的布局（比如：右侧占 60%，允许换行）
    export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --preview-window=right:60%:wrap"
  fi
  if command -v fd > /dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --strip-cwd-prefix --exclude .git --exclude .DS_Store'
  fi
fi

# 加载机器特定配置
[[ -f ~/.zshrc_local ]] && source ~/.zshrc_local

#start starship
eval "$(starship init zsh)"
