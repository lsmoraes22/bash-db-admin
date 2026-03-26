edit_row() {
    local TABLE=$1
    local ROW=$2

    # pegar colunas
    local COLUMNS
    COLUMNS=$(show_columns_db "$TABLE" | awk 'NR>1 {print $1}')

    # transformar colunas em array
    mapfile -t COL_ARRAY <<< "$COLUMNS"

    # transformar linha em array (TAB → campos)
    IFS=$'\t' read -ra VAL_ARRAY <<< "$ROW"

    local FORM_ARGS=()
    local i=0

    for col in "${COL_ARRAY[@]}"; do
        local val="${VAL_ARRAY[$i]}"

        FORM_ARGS+=("COL$i|$col|$val")
        ((i++))
    done

    # abrir form com valores preenchidos
    form_box "Editar registro em $TABLE" "${FORM_ARGS[@]}" || return 1

    # montar UPDATE
    local SETS=()
    i=0

    for col in "${COL_ARRAY[@]}"; do
        local VAR="COL$i"
        local VALUE="${!VAR}"
        local SAFE_COL
        SAFE_COL=$(sql_quote_identifier "$col") || return 1

        SETS+=("$SAFE_COL=$(sql_quote_value "$VALUE")")
        ((i++))
    done

    local SET_JOINED
    SET_JOINED=$(IFS=,; echo "${SETS[*]}")

    local PK
    PK=$(search_primary_key_db "$TABLE")
    [ -z "$PK" ] && {
        dialog --msgbox "Chave primária não encontrada para a tabela $TABLE." 8 60
        return 1
    }

    local PK_INDEX=-1
    for i in "${!COL_ARRAY[@]}"; do
        if [ "${COL_ARRAY[$i]}" = "$PK" ]; then
            PK_INDEX=$i
            break
        fi
    done

    if [ "$PK_INDEX" -lt 0 ]; then
        dialog --msgbox "Não foi possível localizar a coluna da chave primária." 8 60
        return 1
    fi

    local PK_VALUE="${VAL_ARRAY[$PK_INDEX]}"
    local SAFE_TABLE
    SAFE_TABLE=$(sql_quote_identifier "$TABLE") || return 1
    local SAFE_PK
    SAFE_PK=$(sql_quote_identifier "$PK") || return 1

    local QUERY="UPDATE $SAFE_TABLE SET $SET_JOINED WHERE $SAFE_PK=$(sql_quote_value "$PK_VALUE")"

    execute_query "$QUERY"

    dialog --msgbox "Registro atualizado!" 8 40
}
