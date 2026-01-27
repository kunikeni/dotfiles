# Dotfiles

## 概要

個人のdotfilesをchezmoiで管理するリポジトリ。

## セットアップ

### 前提条件

- chezmoi がインストールされていること
- Git がインストールされていること

### 設定ファイル

- `~/.config/chezmoi/chezmoi.toml`

```toml
[git]
    autoCommit = true
[data]
    gitName   = <gitのユーザー名>
    userEmail = <メールアドレス>
```

### インストール

```bash
chezmoi init https://github.com/navy1634/dotfiles.git

chezmoi git pull           # 変更の取得
chezmoi apply              # 設定を適用
chezmoi edit <file>        # ファイルを編集
chezmoi diff               # 変更差分を表示
chezmoi chattr +template   # ファイルをテンプレート化
```

## 管理しているもの

### 環境設定

- brew packages
- apt packages
- bash
- zsh

### ツール設定

- vscode/settings.json
- claude code
- gh
- mise
- yazi
- starship
- vim
