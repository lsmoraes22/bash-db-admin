create_record() {
    local TABLE=$1

    # pega colunas
    local COLUMNS
    COLUMNS=$(show_columns_db "$TABLE" | awk 'NR>1 {print $1}' | paste -sd "," -)

    IFS=',' read -ra COL_ARRAY <<< "$COLUMNS"

    # monta campos do form
    local FORM_ARGS=()
    local i=1

    for col in "${COL_ARRAY[@]}"; do
        FORM_ARGS+=("COL$i|$col|")
        ((i++))
    done

    # chama form_box
    form_box "Criar Registro em $TABLE" "${FORM_ARGS[@]}" || return 1

    # monta valores
    local VALUES_ARRAY=()
    i=1

    for col in "${COL_ARRAY[@]}"; do
        local VAR_NAME="COL$i"
        local VALUE="${!VAR_NAME}"

        VALUE=$(escape_value "$VALUE")

        VALUES_ARRAY+=("$VALUE")
        ((i++))
    done

    # junta valores
    local VALUES_JOINED
    VALUES_JOINED=$(IFS=,; echo "${VALUES_ARRAY[*]}")

    insert_db "$TABLE" "$COLUMNS" "$VALUES_JOINED"
}