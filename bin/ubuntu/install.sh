# install.sh から eval で読み込まれる断片。単体では実行しない。

# mise bootstrap の途中でパスワード入力待ちになって止まらないよう先に通す
echo "==> authenticating sudo"
sudo -v

# mise と chezmoi を取得するための最小限だけ。残りは mise.ubuntu.toml が持つ
echo "==> installing prerequisites"
sudo apt-get update
sudo apt-get install -y ca-certificates curl git

export PATH="${HOME}/.local/bin:${PATH}"

# mise は Ubuntu 標準リポジトリに無い。更新は mise self-update で行う
if ! command -v mise >/dev/null 2>&1; then
    echo "==> installing mise"
    sudo apt install -y extrepo
    sudo extrepo enable mise
    sudo apt update
    sudo apt install -y mise
fi

if ! command -v chezmoi >/dev/null 2>&1; then
    echo "==> installing chezmoi"
    # sh -c "$(curl -fsSL https://get.chezmoi.io)" -- -b "${HOME}/.local/bin"
    mise use chezmoi -g
fi
