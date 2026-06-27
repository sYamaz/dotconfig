---
name: ship
description: secret 検査・ブランチ確認・commit・PR 作成までを一括で行い、PR URL と検証出力を報告する。変更を出荷(ship)したいときに使う。
---

# Ship

変更を安全に出荷する。各ステップは実際のコマンド出力で検証し、証明なしに成功と報告しない。破壊的な操作の前は確認する。

## 手順

1. **現状確認**: `git status` と `git branch --show-current` を実行し、変更内容と現在のブランチを把握する。default ブランチ(main)にいる場合は、commit 前に作業ブランチを切る(main へ直接 commit しない)。

2. **対象ブランチの確認**: PR のベース(通常 `main`)とヘッド(作業ブランチ)を確認し、ユーザーに提示する。意図と異なる場合はここで止めて確認する。

3. **secret 検査**: 変更を stage(`git add`)した上で、pre-commit と同じ検査を明示的に実行する:

   ```sh
   root="$(git rev-parse --show-toplevel)"
   gitleaks git --staged --redact --no-banner -c "$root/.gitleaks.toml" "$root"
   ```

   leak が検出されたら **commit せず中断** し、検出箇所を報告する(secret を消すのが先、`.gitleaks.toml` の allowlist は最後の手段)。`gitleaks` 未導入なら `brew install gitleaks` を促す。

4. **commit**: 明確なメッセージで commit する。メッセージ末尾に `Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>` を付ける。commit 時に pre-commit フックが gitleaks を再実行する(多層防御)。

5. **push**: 作業ブランチを `git push -u origin <branch>` でリモートへ push する。

6. **PR 作成**: `gh pr create` でベースブランチ宛に PR を開く。タイトルと本文は変更内容を簡潔に記述する。

7. **報告(検証付き)**: 以下をすべて実際の出力とともに提示する:
   - PR の URL(`gh pr view --json url -q .url` など)
   - `git log -1`、`git status`、`git branch --show-current` の出力
   - gitleaks の検査結果

   証明となる出力を伴わずに「完了」と言わない。

## 注意

- このスキルは push と PR 作成という外向きの操作を含む。実行前にユーザーの了承を得る(`/ship` 起動自体が了承とみなせる場合は進めてよいが、対象ブランチが想定外なら確認する)。
- commit のみで PR が不要な場合は [[commit]] スキルを使う。
