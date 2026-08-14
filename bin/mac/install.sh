# install.sh から eval で読み込まれる。単体では実行しない。

if ! xcode-select -p >/dev/null 2>&1; then
    echo "==> installing Xcode Command Line Tools"
    xcode-select --install
    echo "インストールダイアログの完了後にもう一度実行してください" >&2
    exit 1
fi

# brew: バックエンドが Homebrew 本体を要求するので mise より先に入れる
if ! command -v brew >/dev/null 2>&1; then
    echo "==> installing Homebrew"
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

if ! command -v mise >/dev/null 2>&1; then
    echo "==> installing mise"
    brew install mise
fi

if ! command -v chezmoi >/dev/null 2>&1; then
    echo "==> installing chezmoi"
    # brew install chezmoi
    mise use chezmoi -g
fi
