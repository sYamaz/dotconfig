# --- Hooks / interactive widgets ---

__list_directory_contents () {
    if [[ -o interactive ]]; then
        ls
    fi
}
add-zsh-hook chpwd __list_directory_contents

ghq_fzf () {
    local selected_repo=$(ghq list -p | FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} ${FZF_ALT_C_OPTS}" fzf)
    if [[ -z $selected_repo ]]; then
        zle redisplay
        return 0
    fi

    BUFFER="cd ${selected_repo}"
    zle accept-line

    zle reset-prompt
}

zle -N ghq_fzf
bindkey "^g" ghq_fzf
