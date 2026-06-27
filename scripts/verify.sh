#!/usr/bin/env bash
#
# verify.sh — dotfiles のクリーン検証ワークフロー。macOS 専用。
#
# 実機の「隔離 HOME」で install.sh を流し、各設定が壊れていないことを
# 実コマンド出力で証明する。実際の ~/.config / ~/.zshenv には一切触れない。
#
# 検証ステージ:
#   install  一時 HOME へ install.sh を流し、symlink が repo を指すか検証
#   tmux     ヘッドレス tmux + TPM で 4 プラグインを入れ、127/command not found を走査
#   nvim     nvim --headless で lazy sync → colorscheme を適用し colors_name を検証
#   glyph    設定で使う PUA グリフを Ghostty のフォントが実際に含むか fc-list で検査
#
# 使い方:
#   ./scripts/verify.sh            # 全ステージ
#   ./scripts/verify.sh tmux nvim  # 指定ステージのみ
#
# 終了コード: いずれかのステージが失敗すると非 0。
#
set -uo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# --- 出力ヘルパ ---------------------------------------------------------------
c_red=$'\033[31m'; c_grn=$'\033[32m'; c_ylw=$'\033[33m'; c_dim=$'\033[2m'; c_off=$'\033[0m'
pass() { printf '%s  PASS%s  %s\n' "$c_grn" "$c_off" "$*"; }
fail() { printf '%s  FAIL%s  %s\n' "$c_red" "$c_off" "$*"; FAILED=1; }
info() { printf '%s  ....%s  %s\n' "$c_dim" "$c_off" "$*"; }
hdr()  { printf '\n%s== %s ==%s\n' "$c_ylw" "$*" "$c_off"; }

FAILED=0

# --- 隔離 HOME のセットアップ -------------------------------------------------
# glyph 検査は実ユーザのフォント環境が必要なので、上書き前に実 HOME を退避する。
# (fontconfig は ~/Library/Fonts を HOME 基準で展開するため、空 HOME だと
#  ユーザフォントを見失い偽 FAIL になる)
REAL_HOME="$HOME"
REAL_XDG="${XDG_CONFIG_HOME:-$HOME/.config}"

# install.sh は XDG_CONFIG_HOME と $HOME を見るので、両方を temp に向ける。
SANDBOX="$(mktemp -d "${TMPDIR:-/tmp}/dotconfig-verify.XXXXXX")"
export HOME="$SANDBOX/home"
export XDG_CONFIG_HOME="$HOME/.config"
mkdir -p "$XDG_CONFIG_HOME"
TMUX_SOCK="dotconfig-verify-$$"

# nvim ステージで repo の lazy-lock.json を書き換えないための退避先。
LOCK="$REPO_DIR/config/nvim/lazy-lock.json"
LOCK_BAK="$SANDBOX/lazy-lock.json.bak"

# shellcheck disable=SC2329  # trap 経由で呼ばれる
cleanup() {
  # nvim sync で書き換わった repo の lazy-lock.json を必ず元へ戻す。
  [ -f "$LOCK_BAK" ] && cp -f "$LOCK_BAK" "$LOCK" 2>/dev/null || true
  tmux -L "$TMUX_SOCK" kill-server >/dev/null 2>&1 || true
  # nvim が引く go mod cache 等は読取専用なので、書込可にしてから削除する。
  chmod -R u+w "$SANDBOX" 2>/dev/null || true
  rm -rf "$SANDBOX"
}
trap cleanup EXIT

info "隔離 HOME: $HOME"

# =============================================================================
# stage: install
# =============================================================================
stage_install() {
  hdr "install — 隔離 HOME へ install.sh"
  if ! bash "$REPO_DIR/install.sh"; then
    fail "install.sh が非 0 終了"
    return
  fi

  # 主要 symlink が repo を指しているか実 readlink で検証
  local ok=1 dst target want
  for tool in nvim tmux zsh; do
    dst="$XDG_CONFIG_HOME/$tool"
    want="$REPO_DIR/config/$tool"
    target="$(readlink "$dst" 2>/dev/null || true)"
    if [ "$target" = "$want" ]; then
      info "link ok: ~/.config/$tool -> $target"
    else
      fail "link 不一致: $dst -> ${target:-（無し）} (期待: $want)"
      ok=0
    fi
  done
  # .zshenv も検証
  target="$(readlink "$HOME/.zshenv" 2>/dev/null || true)"
  if [ "$target" = "$REPO_DIR/home/.zshenv" ]; then
    info "link ok: ~/.zshenv -> $target"
  else
    fail ".zshenv link 不一致: ${target:-（無し）}"; ok=0
  fi

  # べき等性: もう一度流して新規 backup/link が出ないこと（ok 行のみ想定）
  local rerun
  rerun="$(bash "$REPO_DIR/install.sh" 2>&1)"
  if grep -qE '^(link|backup) ' <<<"$rerun"; then
    fail "べき等でない（再実行で link/backup が発生）"; ok=0
  else
    info "べき等: 再実行は ok のみ"
  fi

  [ "$ok" = 1 ] && pass "install: symlink 正常・べき等"
}

# =============================================================================
# stage: tmux — TPM プラグインが 127 なしで読み込まれること
# =============================================================================
stage_tmux() {
  hdr "tmux — ヘッドレス起動 + TPM プラグイン"
  if ! command -v tmux >/dev/null; then fail "tmux 未インストール"; return; fi

  local conf="$XDG_CONFIG_HOME/tmux/tmux.conf"
  if [ ! -e "$conf" ]; then fail "$conf が無い（先に install ステージが必要）"; return; fi

  # 専用ソケットでサーバ起動。設定読込時のエラーを stderr で捕捉。
  local start_err
  start_err="$(tmux -L "$TMUX_SOCK" -f "$conf" new-session -d -s verify -x 200 -y 50 2>&1)"
  if [ -n "$start_err" ]; then
    info "起動時メッセージ:"; printf '%s\n' "$start_err" | sed 's/^/      /'
  fi

  # TPM で @plugin を非対話インストール
  export TMUX_PLUGIN_MANAGER_PATH="$XDG_CONFIG_HOME/tmux/plugins/"
  local install_log
  install_log="$("$XDG_CONFIG_HOME/tmux/plugins/tpm/bin/install_plugins" 2>&1)"
  printf '%s\n' "$install_log" | sed 's/^/      /'

  # サーバの蓄積メッセージ（run-shell の失敗等はここに出る）
  local msgs
  msgs="$(tmux -L "$TMUX_SOCK" show-messages 2>/dev/null || true)"

  # 127 / command not found の走査
  local haystack="$start_err"$'\n'"$install_log"$'\n'"$msgs"
  if grep -qiE 'returned 127|command not found|: 127\b|No such file' <<<"$haystack"; then
    fail "tmux: 127 / command not found を検出"
    grep -niE 'returned 127|command not found|: 127\b|No such file' <<<"$haystack" | sed 's/^/      /'
  else
    info "127 / command not found: 検出なし"
  fi

  # 期待プラグインが実体として clone されたか
  local ok=1 p
  for p in tpm tmux-pain-control tmux-fzf-url tmux-resurrect tmux-continuum; do
    if [ -d "$XDG_CONFIG_HOME/tmux/plugins/$p" ]; then
      info "plugin ok: $p"
    else
      fail "plugin 欠落: $p"; ok=0
    fi
  done

  tmux -L "$TMUX_SOCK" kill-server >/dev/null 2>&1 || true
  [ "$ok" = 1 ] && [ "$FAILED" = 0 ] && pass "tmux: プラグイン読込 OK（127 なし）"
}

# =============================================================================
# stage: nvim — colorscheme が実際に適用できること
# =============================================================================
stage_nvim() {
  hdr "nvim — lazy sync + colorscheme 適用"
  if ! command -v nvim >/dev/null; then fail "nvim 未インストール"; return; fi
  if [ ! -e "$XDG_CONFIG_HOME/nvim/init.lua" ]; then fail "nvim 設定が無い"; return; fi

  # 期待 colorscheme を設定から抽出（lazy.lua の active colorscheme）
  local want
  want="$(grep -hoE 'colorscheme *= *"[^"]+"' "$XDG_CONFIG_HOME"/nvim/lua/plugins/colorschema.lua 2>/dev/null \
          | grep -oE '"[^"]+"' | tr -d '"' | head -1)"
  want="${want:-solarized-osaka}"
  info "期待 colorscheme: $want"

  # nvim 設定は repo への symlink。:Lazy sync は lazy-lock.json を書き換えるため、
  # repo を汚さないよう実体をスナップショットしておく(復元は cleanup と末尾で行う)。
  if [ -f "$LOCK" ]; then cp "$LOCK" "$LOCK_BAK"; fi

  info "lazy sync 中（プラグイン取得・初回は数十秒）…"
  nvim --headless "+Lazy! sync" +qa >/dev/null 2>&1 || true

  # colorscheme を適用し colors_name を stderr へ。適用エラーは終了コードに出る。
  local out
  out="$(nvim --headless \
    -c "lua local ok,err=pcall(vim.cmd,'colorscheme $want'); io.stderr:write(ok and ('COLORS='..(vim.g.colors_name or '')) or ('ERR='..tostring(err)))" \
    -c 'qa!' 2>&1)"
  info "結果: $out"

  # repo の lazy-lock.json を即復元(検証は repo を汚さない)
  if [ -f "$LOCK_BAK" ]; then
    cp -f "$LOCK_BAK" "$LOCK"
    info "lazy-lock.json を復元(検証による変更を取消)"
  fi

  if grep -q "COLORS=$want" <<<"$out"; then
    pass "nvim: colorscheme '$want' 適用 OK"
  else
    fail "nvim: colorscheme '$want' 適用に失敗"
  fi
}

# =============================================================================
# stage: glyph — Ghostty のフォントが設定で使う PUA グリフを含むこと
# =============================================================================
# stdout にバイトがあっても描画は証明できない。実フォントのカバレッジを検査する。
stage_glyph() {
  hdr "glyph — Ghostty フォントの PUA カバレッジ"
  if ! command -v fc-list >/dev/null; then
    fail "fc-list 未インストール（brew install fontconfig）"; return
  fi

  local font
  font="$(grep -E '^font-family' "$REPO_DIR/config/ghostty/config" 2>/dev/null \
          | head -1 | sed -E 's/^font-family *= *"?([^"]*)"?.*/\1/')"
  if [ -z "$font" ]; then fail "ghostty config に font-family が無い"; return; fi
  info "Ghostty font-family: $font"

  # 設定ファイルから実際に使う PUA(U+E000–F8FF) コードポイントを抽出。
  # 10-prompt.zsh は $'\uXXXX' 表記、statusline.conf は生バイトの両方に対応。
  local cps
  cps="$(python3 - "$REPO_DIR/config/zsh/conf.d/10-prompt.zsh" \
                   "$REPO_DIR/config/tmux/statusline.conf" <<'PY'
import re, sys
cps = set()
for path in sys.argv[1:]:
    try:
        s = open(path, encoding="utf-8").read()
    except OSError:
        continue
    # 生バイトの PUA
    for ch in s:
        if 0xE000 <= ord(ch) <= 0xF8FF:
            cps.add(ord(ch))
    # \uXXXX エスケープ表記の PUA
    for m in re.findall(r'\\u([0-9a-fA-F]{4})', s):
        v = int(m, 16)
        if 0xE000 <= v <= 0xF8FF:
            cps.add(v)
print(" ".join(f"{c:04x}" for c in sorted(cps)))
PY
)"
  if [ -z "$cps" ]; then fail "設定から PUA グリフを抽出できず"; return; fi
  info "検査対象コードポイント: $(tr ' ' '\n' <<<"$cps" | sed 's/^/U+/' | tr '\n' ' ')"

  # fontconfig は ~/Library/Fonts を HOME 基準で展開する。サンドボックス HOME の
  # ままだとユーザフォントを見失うため、実 HOME / 実 XDG で fc-list を走らせる。
  local ok=1 cp hit
  for cp in $cps; do
    hit="$(HOME="$REAL_HOME" XDG_CONFIG_HOME="$REAL_XDG" \
           fc-list ":family=$font:charset=$cp" file 2>/dev/null | head -1)"
    if [ -n "$hit" ]; then
      info "U+$cp : 含む (${hit%%:*})"
    else
      fail "U+$cp : '$font' に無い → 豆腐(□)になる"; ok=0
    fi
  done
  [ "$ok" = 1 ] && pass "glyph: '$font' が全 PUA グリフを含む"
}

# =============================================================================
# 実行
# =============================================================================
STAGES=("$@")
[ ${#STAGES[@]} -eq 0 ] && STAGES=(install tmux nvim glyph)

# tmux/nvim は install 後の symlink が前提。明示指定でも install を先に通す。
case " ${STAGES[*]} " in
  *" install "*) : ;;
  *) printf '%s\n' "${c_dim}（install ステージを前提として先に実行）${c_off}"; stage_install ;;
esac

for s in "${STAGES[@]}"; do
  case "$s" in
    install) stage_install ;;
    tmux)    stage_tmux ;;
    nvim)    stage_nvim ;;
    glyph)   stage_glyph ;;
    *) fail "未知のステージ: $s" ;;
  esac
done

hdr "結果"
if [ "$FAILED" = 0 ]; then
  pass "全ステージ成功"
  exit 0
else
  fail "失敗したステージあり（上のログ参照）"
  exit 1
fi
