function browse() {
    local DIR="${1:-.}"

    while true; do
        local OPTIONS=()
        local i=1

        for item in "$DIR"/*; do
            [[ ! -e "$item" ]] && continue

            local name=$(basename "$item")

            if [[ -d "$item" ]]; then
                OPTIONS+=("$i" "[DIR] $name")
            else
                OPTIONS+=("$i" "$name")
            fi

            ((i++))
        done

        OPTIONS+=("0" ".. (voltar)")

        local CHOICE
        CHOICE=$(dialog --menu "Diretório: $DIR" 20 80 10 \
            "${OPTIONS[@]}" \
            3>&1 1>&2 2>&3)

        [ $? -ne 0 ] && return 1

        if [[ "$CHOICE" == "0" ]]; then
            DIR=$(dirname "$DIR")
            continue
        fi

        local SELECTED=$(ls "$DIR" | sed -n "${CHOICE}p")
        local FULL_PATH="$DIR/$SELECTED"

        if [[ -d "$FULL_PATH" ]]; then
            DIR="$FULL_PATH"
        else
            edit_file "$FULL_PATH"
        fi
    done
}