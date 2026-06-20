# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

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
