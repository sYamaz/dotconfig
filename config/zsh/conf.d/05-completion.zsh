# ===== 補完システム初期化 =====
# vendored 補完(config/zsh/completions/)を fpath 先頭に追加してから compinit する。
# 先頭に置くことで、同名の brew 配布版より repo 取り込み版を優先する。
#
# git 補完は git contrib の git-completion.zsh を _git として取り込み済み。
# _git は同ディレクトリの git-completion.bash を自動で source する(funcsourcetrace 基準)
# ため、zstyle での script パス指定は不要。
fpath=("${ZDOTDIR}/completions" $fpath)

# zcompdump は XDG キャッシュ配下に置き、$HOME を汚さない。
autoload -Uz compinit
typeset _zcompdir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
[[ -d $_zcompdir ]] || mkdir -p "$_zcompdir"
compinit -d "${_zcompdir}/zcompdump"
unset _zcompdir
