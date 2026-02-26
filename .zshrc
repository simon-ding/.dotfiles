
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000

setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE


# 初始化补全系统
autoload -Uz compinit
compinit

# 加载历史前缀搜索 widget
autoload -Uz up-line-or-beginning-search
autoload -Uz down-line-or-beginning-search

# 注册为 zle widget（关键）
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# 绑定方向键
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

if command -v vim >/dev/null 2>&1; then 
  alias vi='vim'
fi

[[ -f ~/.secrets/env ]] && source ~/.secrets/env

export PUB_HOSTED_URL="https://pub.flutter-io.cn"
export FLUTTER_STORAGE_BASE_URL="https://storage.flutter-io.cn"

export PATH=$HOME/.gem/bin:$PATH:~/go/bin

is_distrobox() {
    [ -f "/.distroboxenv" ] || [ -n "$DISTROBOX_ENTER_PATH" ]
}

function macos_envs {
    if [[ $- == *i* ]]; then
      export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
      export PATH="/opt/homebrew/opt/grep/libexec/gnubin:$PATH"
    fi

    # zsh-autosuggestions & zsh-syntax-highlighting
    source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

    export PATH="/opt/homebrew/opt/node@20/bin:$PATH:$HOME/development/flutter/bin:$HOME/Library/Python/3.9/bin"
    export LDFLAGS="-L/opt/homebrew/opt/node@20/lib"
    export CPPFLAGS="-I/opt/homebrew/opt/node@20/include"

    export POLARIS_NO_AUTO_DOWNLOAD=true    
}


function linux_envs {
    alias devbox="distrobox enter dev"

    export PATH="$PATH:$HOME/development/flutter/bin"
    export PATH="$PATH:/usr/local/go/bin"
    

    source /etc/os-release
    if [[ "$ID" == "bazzite" ]]; then
      export PATH="$PATH:/home/linuxbrew/.linuxbrew/bin/"
      source /home/linuxbrew/.linuxbrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
      source /home/linuxbrew/.linuxbrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    elif [[ "$ID" == "arch" ]]; then
      source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
      source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    else
      source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
      source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    fi
}

case "$(uname -s)" in
  Darwin) 
    macos_envs    
    ;;
  Linux) 
    linux_envs
    ;;
esac

# 加载机器特定配置
[[ -f ~/.zshrc_local ]] && source ~/.zshrc_local

#start starship
eval "$(starship init zsh)"
