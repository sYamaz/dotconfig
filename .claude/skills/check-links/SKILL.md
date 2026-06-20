---
name: check-links
description: 管理対象の symlink が repo を正しく指しているか検証する。install 後やリンクが壊れた疑いがあるときに使う。
---

# check-links

この dotfiles repo が管理する symlink の健全性を検証する。

## 手順

1. リポジトリルートを特定する(このファイルから2階層上)。`XDG="${XDG_CONFIG_HOME:-$HOME/.config}"`。
2. `config/*/`(gh を除く)について、`~/.config/<tool>` が `config/<tool>` を指す symlink かを確認する。
3. gh は `~/.config/gh/config.yml` が `config/gh/config.yml` を指す symlink かを確認する。
4. `~/.zshenv` が `home/.zshenv` を指す symlink かを確認する。
5. 各対象を次の3分類で報告する:
   - **OK**: repo を正しく指す symlink
   - **未リンク**: 実体が存在する、または何も無い(`./install.sh` で解消)
   - **壊れている**: symlink だが指す先が存在しない、または別の場所を指す
6. 問題があれば修正方法(通常は `./install.sh` の再実行)を提示する。

read-only の確認(`ls -la`, `readlink`)のみで、勝手にリンクを張り替えない。修正が必要なら提案して指示を待つ。
