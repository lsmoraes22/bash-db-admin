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

        VALUE=$(escape_value "$VALUE")

        SETS+=("\`$col\`='$VALUE'")
        ((i++))
    done

    local SET_JOINED
    SET_JOINED=$(IFS=,; echo "${SETS[*]}")

    local PK
    PK=$(search_primary_key_db "$TABLE")

    local PK_VALUE="${VAL_ARRAY[0]}"   # assume primeira coluna é PK

    local QUERY="UPDATE \`$TABLE\` SET $SET_JOINED WHERE \`$PK\`='$PK_VALUE'"

    execute_query "$QUERY"

    dialog --msgbox "Registro atualizado!" 8 40
}