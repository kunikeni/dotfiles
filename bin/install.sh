#!/bin/sh
# セットアップのエントリポイント。
#
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/kunikeni/dotfiles/main/bin/install.sh)"
#
# パイプ（curl ... | sh）では stdin がスクリプト本体に占有され、chezmoi init のプロンプトが動かない。
# 必ず上のコマンド置換形式で実行する。
set -eu

repo="https://github.com/kunikeni/dotfiles.git"
raw="https://raw.githubusercontent.com/kunikeni/dotfiles/main"

case "$(uname -s)" in
Darwin) os=mac ;;
Linux) os=ubuntu ;;
*)
    echo "unsupported OS: $(uname -s)" >&2
    exit 1
    ;;
esac

echo "==> detected OS: ${os}"

# PATH の変更を引き継ぎたいので、子プロセスではなく eval でこのシェルに読み込む
eval "$(curl -fsSL "${raw}/bin/${os}/install.sh")"

# source-path は未初期化でも終了コード 0 で既定パスを返すので .git の有無で判定する
if [ -d "$(chezmoi source-path)/.git" ]; then
    echo "==> applying dotfiles"
    chezmoi apply
else
    echo "==> initializing dotfiles from ${repo}"
    chezmoi init --apply "${repo}"
fi

echo "==> running mise bootstrap"
MISE_ENV="${os}" mise -C "$(chezmoi source-path)" bootstrap --yes --skip dotfiles

echo "==> done"
