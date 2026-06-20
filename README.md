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
  nvim/ tmux/ zsh/ git/ gh/ lazygit/ ghostty/
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

## secret scanning

public repo のため、secret / 個人情報の混入を多層で防ぐ:

- **pre-commit**: `./install.sh` が `core.hooksPath=.githooks` を設定。commit 時に [gitleaks](https://github.com/gitleaks/gitleaks) が staged 差分を検査(`brew install gitleaks` が必要)。
- **CI**: `.github/workflows/gitleaks.yml` が push/PR 時に検査。
- 検出ルールは `.gitleaks.toml`(gitleaks 標準ルール + メール等の個人情報)。誤検知は同ファイルの `allowlist` で除外。
