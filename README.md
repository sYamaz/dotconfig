# dotconfig

`~/.config`(と `~/.zshenv`)を symlink で管理する dotfiles。**macOS 専用。**

## requirements

- tmux
- lazyvim (Neovim)
- fzf
- eza (not exa)
- font: PlemolJP console nf
- lazygit (+ delta)

## install

```sh
./install.sh
```

`config/<tool>` を `~/.config/<tool>` へ、`home/.zshenv` を `~/.zshenv` へシンボリックリンクする。
べき等で、既存の実体は `~/.dotconfig-backup/<timestamp>/` へ退避される。

インストール後は `~/.config/<tool>` がこの repo への symlink になる。よって `config/<tool>` を編集すると、そのままライブ設定が変わる。

## 構成

```
config/        各ディレクトリが ~/.config/<tool> に対応
  nvim/ tmux/ zsh/ git/ gh/ lazygit/ mise/ ghostty/
home/.zshenv   -> ~/.zshenv (XDG_CONFIG_HOME と ZDOTDIR を定義)
install.sh     symlink を張る
```

## 管理対象外(コミットしない)

秘密情報・状態・キャッシュは `.gitignore` で除外、または取り込まない:

- `gh/hosts.yml`(GitHub トークン) … gh は `config.yml` のみ管理
- `zsh/.zsh_history`
- `tmux/plugins/` … tpm が clone するため別途インストール
- `~/.config/.mono/`, `configstore/`, `yarn/`(キャッシュ)など … 取り込み対象外

## tmux プラグイン

`tmux/plugins/` は管理しない。tpm をインストール後、prefix + I でプラグインを入れる。
