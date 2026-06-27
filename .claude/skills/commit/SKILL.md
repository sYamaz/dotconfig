---
name: commit
description: 変更を commit して push する。検証を含む安全な手順で行う。コミットや push を依頼されたときに使う。
---

# Commit & Push

変更を安全に commit・push する。各操作は実際のコマンド出力で検証してから成功を報告する。

## 手順

1. `git status` と `git branch --show-current` で現状とブランチを確認する。default ブランチ(main)にいる場合はまずブランチを切る。
2. 変更を stage し、明確なメッセージで commit する。
3. 正しいブランチへ push する。
4. `git log -1` と `git status` で検証してから成功を報告する。

commit メッセージ末尾には `Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>` を付ける。secret・PII を含めないこと(pre-commit の gitleaks が検査する)。
