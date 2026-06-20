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

## 秘密情報(絶対にコミットしない)

- gh は `config.yml` のみ管理。`hosts.yml`(GitHub トークン)は取り込まず `.gitignore` 済み。
- `config/zsh/.zsh_history`、`~/.config/.mono/`(鍵)、`configstore/`、`yarn/`(キャッシュ)は管理対象外/除外。

## 補足

- `home/.zshenv` が `XDG_CONFIG_HOME=$HOME/.config` と `ZDOTDIR=$HOME/.config/zsh` を定義する。zsh 設定の本体は `config/zsh/`。
- tmux プラグインは tpm 管理。`config/tmux/plugins/` は除外しており、版管理しない。
