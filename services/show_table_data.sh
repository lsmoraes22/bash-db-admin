function show_table_data() {
    local TABLE=$1
    local LIMIT=${2:-10}
    local OFFSET=${3:-0}
    local COLUMNS="${4:-*}"
    local ORDER="${5:-}"
    local WHERE="${6:-}"
    local SEPARATOR="${7:-|}"

    if ! is_number "$LIMIT" || ! is_number "$OFFSET"; then
        show_message "LIMIT e OFFSET devem ser números."
        return 1
    fi

    while true; do
        # Monta query dinâmica
        local QUERY="SELECT $COLUMNS FROM \`$TABLE\`"

        [ -n "$WHERE" ] && QUERY="$QUERY WHERE $WHERE"
        [ -n "$ORDER" ] && QUERY="$QUERY ORDER BY $ORDER"

        QUERY="$QUERY LIMIT $LIMIT OFFSET $OFFSET"

        local RAW_DATA
        RAW_DATA=$(execute_query "$QUERY" | sed '1d')

        local MENU_ITEMS=()
        if [ ! -z "$RAW_DATA" ]; then
            local i=1
            while IFS= read -r line; do
                MENU_ITEMS+=("$i" "$line")
                ((i++))
            done <<< "$RAW_DATA"
        fi

        # adiciona navegação como opções extras
        MENU_ITEMS+=("n" ">> Próxima página")
        MENU_ITEMS+=("p" "<< Página anterior")

        local CHOICE
        CHOICE=$(dialog \
            --backtitle "Gerenciador de Banco de Dados" \
            --title "Tabela: $TABLE | Offset: $OFFSET | Limit: $LIMIT" \
            --cancel-label "Voltar" \
            --menu "Selecione uma linha ou navegue:" \
            30 200 15 \
            "${MENU_ITEMS[@]}" \
            3>&1 1>&2 2>&3)

        [ $? -ne 0 ] && break

        case "$CHOICE" in
            n)
                OFFSET=$((OFFSET + LIMIT))
                continue
                ;;
            p)
                OFFSET=$((OFFSET - LIMIT))
                [ $OFFSET -lt 0 ] && OFFSET=0
                continue
                ;;
        esac

        local SELECTED_ROW
        SELECTED_ROW=$(echo "$RAW_DATA" | sed -n "${CHOICE}p")

        row_actions_menu "$TABLE" "$SELECTED_ROW" "$LIMIT" "$OFFSET"
    done
}