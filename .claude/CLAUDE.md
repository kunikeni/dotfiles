# chezmoi dotfiles リポジトリ

## chezmoi ルール（CRITICAL）

このリポジトリは chezmoi で管理された dotfiles の **source of truth** である。

- **編集対象は chezmoi リポジトリ内のファイルのみ**（例: `dot_claude/`, `dot_zshrc.tmpl` 等）
- 実ファイル（`~/.claude/`, `~/.zshrc` 等）には **絶対に直接触れない**
- 実ファイルへの反映は `chezmoi apply` が行う。Claude の仕事ではない

## パッケージ管理（CRITICAL）

置き場所の判断基準は README の「パッケージを追加する」にある。追加や変更の前に必ず読むこと。

この基準を変更する前に、必ずユーザーに確認すること。既存の配置を独自の基準で作り替えてはならない。

## agent設定

基本的に英語で記載すること。
descriptionは日本語で記述すること。
