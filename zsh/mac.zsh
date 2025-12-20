# GNU tools for interactive use only
if [[ $- == *i* ]]; then
  export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
  export PATH="/opt/homebrew/opt/grep/libexec/gnubin:$PATH"
fi

# zsh-autosuggestions & zsh-syntax-highlighting
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export PATH="/opt/homebrew/opt/node@20/bin:$PATH:$HOME/development/flutter/bin"
export LDFLAGS="-L/opt/homebrew/opt/node@20/lib"
export CPPFLAGS="-I/opt/homebrew/opt/node@20/include"
export PUB_HOSTED_URL="https://pub.flutter-io.cn"
export FLUTTER_STORAGE_BASE_URL="https://storage.flutter-io.cn"

export PATH=$HOME/.gem/bin:$PATH:~/go/bin
export POLARIS_NO_AUTO_DOWNLOAD=true