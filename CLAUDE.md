# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## プロジェクト概要

dotfiles / config repo。主な対象言語は Shell・YAML・Markdown。設定は `~/.config` 配下に置かれ、変更は PR 経由で管理し、複数デバイス間で同期される。

## 目的

`~/.config` 配下の各ツール設定と `~/.zshenv` を symlink で管理する dotfiles repo。**macOS 専用。**

## 適用

```sh
./install.sh
```

`config/<tool>` を `~/.config/<tool>` へ、`config/gh/config.yml` を `~/.config/gh/config.yml` へ、`home/.zshenv` を `~/.zshenv` へリンクする。べき等。既存の実体は `~/.dotconfig-backup/<timestamp>/` へ退避される。

## 重要な落とし穴

- install 後、`~/.config/<tool>` はこの repo への symlink。**`config/<tool>` の編集は即ライブ設定に反映される**(別途コピーや再 install は不要)。
- 新しいツール設定を取り込むには `/adopt-config <tool>` を使う(`~/.config/<tool>` を repo へ移して symlink を張り直す)。

## 検証ワークフロー(変更完了を報告する前に必ず実行)

設定変更を「完了」と報告する前に、実機の隔離 HOME で検証して実コマンド出力で証明する。

```sh
./scripts/verify.sh            # 全ステージ
./scripts/verify.sh tmux nvim  # 指定ステージのみ
```

- 一時 `$HOME`/`$XDG_CONFIG_HOME` を作り `install.sh` を流すため、**実 `~/.config` は壊さない**。macOS 専用。
- ステージ: **install**(symlink が repo を指すか・べき等性)/ **tmux**(TPM で4プラグインを入れ `127`・command not found を走査)/ **nvim**(`--headless` で lazy sync → `colorscheme` 適用を `vim.g.colors_name` で検証)/ **glyph**(設定で使う PUA グリフを Ghostty の `font-family` が実際に含むか `fc-list` で検査)。
- **グリフ描画は stdout では証明できない**(バイトは豆腐でも同じ)。証明は実フォントのカバレッジ検査か実ターミナルのスクショのみ。`glyph` は前者を自動化している。
- 出力が破損・曖昧なときは成功と仮定せず**再実行**する。

## 秘密情報・個人情報(絶対にコミットしない)

**この repo は public。** secret(トークン・鍵・認証情報)や PII(メール等)を絶対にコミットしない。

- 多層防御済み: commit 時に `.githooks/pre-commit` が gitleaks で staged 差分を検査(secret + 個人情報の両方)。GitHub Actions(`.github/workflows/gitleaks.yml`)でも push/PR 時に検査。
- フックは `core.hooksPath=.githooks` で有効化(`./install.sh` が設定)。検出ルールは `.gitleaks.toml`(標準ルール + 個人情報)。
- gh は `config.yml` のみ管理。`hosts.yml`(GitHub トークン)は取り込まず `.gitignore` 済み。
- `config/zsh/.zsh_history`、`~/.config/.mono/`(鍵)、`configstore/`、`yarn/`(キャッシュ)は管理対象外/除外。
- 新しい設定を取り込む際は、トークン・鍵・絶対パス・メール等が含まれないか必ず確認する。誤検知は `.gitleaks.toml` の `allowlist` で除外する(secret を消すのが先、allowlist は最後の手段)。

## 補足

- `home/.zshenv` が `XDG_CONFIG_HOME=$HOME/.config` と `ZDOTDIR=$HOME/.config/zsh` を定義する。zsh 設定の本体は `config/zsh/`。
- tmux プラグインは tpm 管理。`config/tmux/plugins/` は除外しており、版管理しない。

## Git 操作

git 操作(commit・push・PR 作成)の後は必ず `git log` / `git status` / `git branch --show-current` を実行して検証する。実際のコマンド出力で確認できるまで成功と報告しない。

## 主張前の検証

設定や機能が既に存在する/欠けていると主張する前に、まず実ファイルを読むか検証コマンドを実行する。慣例から推測で判断しない。

## デバッグ

設定の問題(tmux・helix・zsh・terminfo など)やバグ報告(ターミナル描画・PATH エラー・プラグイン失敗など)を診断する際は、根本原因ループを完了するまでファイルを編集しない。

1. 候補原因を3つ以上、可能性の高い順にランク付けして提示する。
2. 各候補に対し Bash で非破壊的なクイックテストを設計する。
3. テストを実行して実際の原因を特定する(根拠となるコマンド出力を示す)。
4. その根本原因だけを狙う最小限の修正を適用する。

仮説検証のための探索的変更(`~/.terminfo` パッチ等)は追跡し、不要と分かれば自動で revert する。最終修正の適用前に真の原因をユーザーに確認する。修正はシステムファイルへのパッチより、ドキュメント化されたアプリレベルの設定を優先する。
