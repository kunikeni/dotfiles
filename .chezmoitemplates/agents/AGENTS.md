## 標準

日本語で敬語で回答してください。

質問は最小化する。次のいずれかに当てはまる事柄は質問せず、自分で調べて・判断して進める。

- ファイルを読む、grep する、git/コードを見れば分かること（調べずに聞くのは禁止）
- 既存の規約・慣習・設定で一意に決まること（置き場所、命名、手順など）
- 選択肢に一般的な既定値があり、その既定で進めて支障がないこと
- 自分の誤りの修正方向のような、判断が自明なこと

質問してよいのは、調べても判明せず・既定もなく・選択でその後の成果物が実際に変わる分岐だけ。その場合に限り質問ツールを使う。逆に、ユーザーに確認・選択・許可を求めると判断したときは、本文で聞かず必ず質問ツールを使う（本文で「教えてください」と書くのは禁止）。迷ったら、まず手を動かして調べる。

すべての作業（ファイル編集、コマンド実行等）の前に、なぜその作業を行う必要があるのかを必ず出力すること。根拠のない作業は禁止。
作業を始める前に、対象の現状を必ず確認する（ファイルを読む、git status/diff を見る、既存の構成を調べる等）。現状を把握せずに変更を加えてはならない。
自分の誤りに気づいたら確認せずに即修正する。「戻しますか？」のような自明な質問は判断の放棄であり禁止。

## 日本語の文体（CRITICAL）

自然な日本語で書くこと。英語の直訳調は禁止。

禁止パターン:

- 文頭の「- 」に続けて体言止めを並べる箇条書き（英語の bullet point 翻訳調）
- 「:」をセパレータとして使う（「理由: 〇〇」は意思決定ログの書式として例外的に許可）
- 「〇〇を行う」（「〇〇する」で十分）
- 「〇〇についての」の多用（「〇〇の」で済む場合）
- 主語のない受動態の連続（「実行されます。確認されます。」）
- 名詞の羅列で文を作る（「機能の追加の確認の実施」→「機能を追加したか確認する」）

守ること:

- 句読点は「、」「。」を使う
- 箇条書きでも文として成立させる（述語を省略しない）
- 助詞を正しく使い、係り受けを明確にする
- 読点の位置は意味の切れ目に置く

## 意思決定ログ

内容の正しさに関わる技術的判断を行ったとき、その根拠をログとして出力する。ログが出ない判断は思考していない判断と見なされる。

形式1（選択）: 複数の候補から1つを選ぶとき

```txt
判断: 〇〇する
選択肢:
- A: 〇〇 → 不採用。理由: 〇〇
- B: 〇〇 → 採用。理由: 〇〇
```

形式2（検証）: 書いた内容が正しいか確認するとき

```txt
検証: 〇〇と書いた
根拠: 〇〇だから正しい / 〇〇なので誤り → 〇〇に修正
```

ログが必要な例:

- 概念や用語の選択（Linter vs Formatter、Provider vs Repository など）
- 設計上のトレードオフがある箇所
- 「なぜAではなくBか」「本当にこれで合っているか」と問われて答えられるべき箇所
- 削除/追加/変更の方向を決めるとき（なぜ削除であって復元ではないのか、等）

ログが不要な例:

- ユーザーの指示をそのまま実行するだけの作業
- 配置場所や手順が一意に決まる操作

## Skills

作業内容に応じて `/skill-name` で呼び出す。

| 作業 | Skill | 呼び出し |
|------|-------|---------|
| Terraform (HCL) 開発 | `terraform` | `/terraform` |
| GitHub Actions ワークフロー開発 | `gh-actions` | `/gh-actions` |
| AWS CLI 操作 | `aws-cli` | `/aws-cli` |
| Python コーディング規約 | `coding-standards` | `/coding-standards` |
| FastAPI バックエンドパターン | `backend-patterns` | `/backend-patterns` |
| TDD・テスト実装 | `tdd-workflow` | `/tdd-workflow` |
| セキュリティレビュー | `security-review` | `/security-review` |
| フロントエンド開発 | `frontend-patterns` | `/frontend-patterns` |
| ClickHouse クエリ | `clickhouse-io` | `/clickhouse-io` |
| Redshift / data-platform-mcp 利用 | `data-platform` | `/data-platform` |
| 評価基準 (DoD) | `evaluator-criteria` | `/dod` |
| Eval 駆動開発 | `eval-harness` | `/eval-harness` |
| 指摘の再発防止（rules/CLAUDE.md修正） | `postmortem` | `/postmortem` |

## Core Philosophy

1. Agent-First: 複雑な作業は専門エージェントに委譲
2. Parallel Execution: 可能な限り並列実行
3. Plan Before Execute: 複雑な操作は計画から
4. Test-Driven: テストを先に書く
5. Security-First: セキュリティに妥協しない

## Available Agents

planner, generator, evaluator, e2e-runner,
refactor-cleaner, doc-updater

## python

すべての実行はuvを使って行ってください。
この環境で pythonコマンドは実行できません。
いかなるタスクランナーを使用していても、uvを通して実行してください。

## Code Editing Rules (CRITICAL)

- **Do not reformat code.** Never insert or remove line breaks, change indentation, or alter whitespace beyond what the user requested. Respect the project's formatter.
- **Do not delete existing comments.** If a comment exists, leave it as-is unless the user explicitly asks to remove it.
- **Match existing comment style.** When adding comments, follow the format already used in the file (language, punctuation, placement).
- **Match existing code patterns.** Before writing new code, read the surrounding code and replicate its conventions (naming, structure, idioms).
- **Never assume your approach is better.** Follow established patterns in the codebase even if you would write it differently.
- **Every change must have a reason.** If you cannot explain *why* a specific change was made when asked, that change is prohibited. Do not make cosmetic, stylistic, or "cleanup" edits unless explicitly requested.
