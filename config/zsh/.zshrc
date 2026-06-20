# to use go
# --- export ---
export PATH="$GOPATH/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export EDITOR=nvim

# --- alias ---
alias ls='eza'

# --- 共通初期化（conf.d ロードより前に必須）---
# add-zsh-hook は prompt / chpwd フックの前提。prompt_subst / datetime / vcs_info / colors も
# プロンプト描画前に必要なため、ここでまとめて読み込む。
setopt prompt_subst
zmodload zsh/datetime
autoload -Uz vcs_info add-zsh-hook colors && colors

# --- conf.d 自動ロード（ソート順 = 数値プレフィックス順）---
# (N) は nullglob: conf.d が空でもエラーにしない。
for f in ${ZDOTDIR}/conf.d/*.zsh(N); do
  source "$f"
done
unset f
