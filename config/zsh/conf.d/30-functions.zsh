# --- functions ---

function bd_list () {
    local dir=$PWD
    for i in {1..20}; do
        dir=$(dirname "$dir")
        echo "$dir"
        if [[ $dir = "/" ]]; then
            break
        fi
    done
}

function bd () {
    local dir=$(bd_list | FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} ${FZF_ALT_C_OPTS}" fzf)
    if [[ -n $dir ]]; then
        builtin cd $dir
    fi
}
