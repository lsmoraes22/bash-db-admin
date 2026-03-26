function edit_file() {
    local FILE="$1"

    # cria arquivo se não existir
    [[ ! -f "$FILE" ]] && touch "$FILE"

    local TMP_FILE="/tmp/edit_$(basename "$FILE")"

    cp "$FILE" "$TMP_FILE"

    dialog --title "Editando: $FILE" \
        --editbox "$TMP_FILE" 25 100 \
        2> "$TMP_FILE.out"

    local STATUS=$?

    # cancelado
    [ $STATUS -ne 0 ] && rm -f "$TMP_FILE" "$TMP_FILE.out" && return 1

    # salvar
    mv "$TMP_FILE.out" "$FILE"

    rm -f "$TMP_FILE"

    dialog --msgbox "Arquivo salvo com sucesso!" 6 40
}