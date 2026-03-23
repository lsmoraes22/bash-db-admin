function build_row_menu() {
    local DATA="$1"
    local OPTIONS=()
    local i=1

    while IFS= read -r line; do
        OPTIONS+=("$i" "$line")
        ((i++))
    done <<< "$DATA"

    echo "${OPTIONS[@]}"
}
