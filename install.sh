#!/usr/bin/env bash
#
# install.sh — ~/.config と ~/.zshenv をこの repo へシンボリックリンクする。
# べき等(再実行しても安全)。既存の実体は ~/.dotconfig-backup/<timestamp>/ へ退避する。
# macOS 専用。
#
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
XDG="${XDG_CONFIG_HOME:-$HOME/.config}"
BACKUP="$HOME/.dotconfig-backup/$(date +%Y%m%d-%H%M%S)"

# pre-commit などの git hook(.githooks/)を有効化する。
# これで commit 時に gitleaks が走り、secret/PII の混入をブロックする。
git -C "$REPO_DIR" config core.hooksPath .githooks
echo "hooks core.hooksPath -> .githooks"

# link <src> <dst>: src(repo 内)へ向かう symlink を dst に作る。
link() {
  local src="$1" dst="$2"

  # 既に正しい symlink ならスキップ(べき等)
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    echo "ok    $dst"
    return 0
  fi

  # 実体(または別の symlink)があればバックアップへ退避
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    local rel="${dst#"$HOME"/}"
    mkdir -p "$BACKUP/$(dirname "$rel")"
    mv "$dst" "$BACKUP/$rel"
    echo "backup $dst -> $BACKUP/$rel"
  fi

  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst"
  echo "link  $dst -> $src"
}

# config/<tool> -> ~/.config/<tool>(ディレクトリ単位)
for dir in "$REPO_DIR"/config/*/; do
  name="$(basename "$dir")"
  # gh はファイル単位で扱うのでディレクトリリンクから除外
  [ "$name" = "gh" ] && continue
  link "$REPO_DIR/config/$name" "$XDG/$name"
done

# gh は config.yml のみリンク(hosts.yml のトークンを repo に置かないため)
if [ -f "$REPO_DIR/config/gh/config.yml" ]; then
  mkdir -p "$XDG/gh"
  link "$REPO_DIR/config/gh/config.yml" "$XDG/gh/config.yml"
fi

# home/.zshenv -> ~/.zshenv
link "$REPO_DIR/home/.zshenv" "$HOME/.zshenv"

echo
echo "done. backups (if any) under: $BACKUP"
