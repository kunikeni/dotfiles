---
name: dod
description: Definition of Done チェック。プロジェクト全体の検証を実行し、全項目パスを確認。
---

# Definition of Done チェック

プロジェクト全体を対象に DoD の全項目を検証する。

## Prerequisites（CRITICAL）

DoD チェックは **全ての修正作業が完了した後** に実行すること。

- 修正対象の全箇所が修正済みであることを確認してから本チェックに移ること
- 修正途中で DoD チェックを実行しない（中間状態での検証は無意味）
- 修正漏れがないか、タスク一覧や差分を確認した上で開始する

## Instructions

### 1. プロジェクトのタスクランナーを特定

プロジェクトの設定ファイル（`pyproject.toml`, `Makefile` 等）を確認し、使用しているタスクランナーと各タスクのコマンド名を特定する。

### 2. 検証を実行

以下の 4 項目を順番に実行する。**必ずタスクランナー経由で実行すること。**

ツールの直接実行（`uv run ruff`, `uv run mypy`, `uv run pytest` 等）は禁止。

```bash
# taskipy の場合
uv run task test
uv run task lint
uv run task format
uv run task type-check

# Makefile の場合
uv run make test
uv run make lint
uv run make format
uv run make type-check

# プロジェクトに合わせてコマンドを読み替えること
```

Terraform プロジェクトの場合は、以下を順番に実行する。`terraform plan` まで DoD に含め、想定外の差分（特に delete/replace）がないか目視確認すること。

```bash
cd terraform/ && terraform fmt -recursive
tflint --config $(pwd)/.tflint.hcl --recursive
cd env/{target}/ && terraform validate
cd env/{target}/ && terraform plan
```

### 3. 判定基準

- **全項目エラーゼロ** であること
- **プロジェクト全体** を対象に検証していること（変更箇所のみは不可）
- 特定ファイルやディレクトリに限定した実行は不可
- Terraform の場合は `terraform plan` の差分を読み、意図しない削除・再作成がないことを確認していること

### 4. レポート出力

```
DoD VERIFICATION: [PASS/FAIL]

Test:       [OK/FAIL] (X passed, Y failed)
Lint:       [OK/FAIL] (X errors)
Format:     [OK/FAIL] (X errors)
Type-check: [OK/FAIL] (X errors)

Result: [COMPLETE/INCOMPLETE]
```

FAIL がある場合はエラー内容と修正方針を提示する。

## Arguments

$ARGUMENTS can be:
- (なし) - 全 4 項目を実行し、エラーがあれば修正まで行う（デフォルト）
- `check` - 検証のみ実行（修正は行わない）
