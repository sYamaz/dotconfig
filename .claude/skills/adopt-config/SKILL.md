---
name: adopt-config
description: ~/.config/<tool> をこの dotfiles repo に取り込み、symlink を張り直す。新しいツール設定を版管理対象に加えるときに使う。
disable-model-invocation: true
---

# adopt-config

`$ARGUMENTS` で渡されたツール名(例: `starship`)の `~/.config/<tool>` を repo に取り込み、symlink へ置き換える。

## 手順

引数 `<tool>` = `$ARGUMENTS`(空なら何を取り込むかユーザーに尋ねる)。

1. `~/.config/<tool>` が存在し、かつ既に repo へのシンボリックリンクでないことを確認する。symlink 済みなら「取り込み済み」と伝えて終了。
2. リポジトリルートを特定する(このファイルから2階層上)。`config/<tool>` が既に存在しないことを確認する。
3. `~/.config/<tool>` を `config/<tool>` へ **移動** する(`mv`)。ディレクトリでもファイルでも可。
4. `./install.sh` を実行して `~/.config/<tool>` → `config/<tool>` の symlink を張る。
5. 秘密情報・状態・キャッシュが混入していないか確認する(トークン、`*_history`、`.DS_Store`、巨大なキャッシュ等)。見つかれば `.gitignore` に追記し、必要なら repo から除外する。
6. `git status` で取り込み結果を示し、追跡対象が妥当かユーザーに確認する。

## 注意

- gh のようにディレクトリ内に秘密情報が混ざるツールは、ディレクトリ全体ではなく安全なファイルだけを取り込む(`config.yml` のみ等)。CLAUDE.md の方針に従う。
- コミットはユーザーの指示があるまで行わない。
