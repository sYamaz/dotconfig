# ===== p10k classic-style prompt (native zsh, powerlevel10k 不使用) =====
# 要 Nerd Font（例: MesloLGS NF）。フォント未導入だと powerline グリフが豆腐になる。
# 前提: setopt prompt_subst / zmodload zsh/datetime / autoload vcs_info add-zsh-hook colors は .zshrc で実行済み。

# --- git (vcs_info, 同期) ---
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' unstagedstr '*'
zstyle ':vcs_info:git:*' stagedstr   '+'
zstyle ':vcs_info:git:*' formats       '%b%u%c'
zstyle ':vcs_info:git:*' actionformats '%b|%a%u%c'

# powerline グリフ（Nerd Font, private-use area）
typeset -g _PLC_LSEG=$'' _PLC_RSEG=$''
typeset -g _PLC_LSUB=$'' _PLC_BR=$''

# --- 実行時間計測 ---
_plc_preexec() { _plc_start=$EPOCHREALTIME }
_plc_human() {  # 秒(float) -> "1m 30s" 風（整数秒に丸め）
  local -i s; (( s = $1 )); local out=""
  (( s >= 86400 )) && { out+="$(( s/86400 ))d "; (( s %= 86400 )); }
  (( s >= 3600  )) && { out+="$(( s/3600  ))h "; (( s %= 3600  )); }
  (( s >= 60    )) && { out+="$(( s/60    ))m "; (( s %= 60    )); }
  out+="${s}s"; print -r -- "$out"
}

# --- precmd: vcs_info 更新 + git 色 + 実行時間 + 右プロンプト組み立て ---
_plc_precmd() {
  vcs_info
  # git セグメント（リポジトリ内のみ）
  _plc_git=""
  if [[ -n $vcs_info_msg_0_ ]]; then
    local gfg=76                      # clean -> 緑
    [[ $vcs_info_msg_0_ == *'*'* || $vcs_info_msg_0_ == *'+'* ]] && gfg=178  # dirty -> 黄
    _plc_git="%F{246}${_PLC_LSUB}%f %F{$gfg}${_PLC_BR} ${vcs_info_msg_0_}%f "
  fi
  # 実行時間（閾値3秒以上）
  local rt=""
  if (( ${_plc_start:-0} > 0 )); then
    local -F el=$(( EPOCHREALTIME - _plc_start ))
    (( el >= 3 )) && rt="%F{248}$(_plc_human $el)%f"
    unset _plc_start
  fi
  # status（エラー時のみ ✘code を 160 で）。classic は成功時は非表示。
  local st=""
  [[ $_plc_last -ne 0 ]] && st="%F{160}${_plc_last}✘%f"
  # 右プロンプト（2行目右端）: status / 実行時間（フレームなし）
  local rsegs="${st:+$st }${rt}"
  if [[ -n $rsegs ]]; then
    RPROMPT="%K{238} ${rsegs} %k"
  else
    RPROMPT=""
  fi
}
# 直前コマンドの終了コードを最優先で捕捉（他フックより先に登録）
_plc_status() { _plc_last=$? }
add-zsh-hook precmd _plc_status
add-zsh-hook precmd _plc_precmd
add-zsh-hook preexec _plc_preexec

# --- PROMPT（左・2行・フレームなし）---
# 1行目: dir(31) + git + 右閉じキャップ / 2行目: ❯
PROMPT='%K{238} %F{31}%~ %f${_plc_git}%k%F{238}${_PLC_LSEG}%f
%(?.%F{76}.%F{196})❯%f '
