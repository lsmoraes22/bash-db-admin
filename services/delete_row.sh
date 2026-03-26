function delete_row() {
    local TABLE=$1
    local ROW=$2

    local col_id
    col_id=$(search_primary_key_db "$TABLE")

    if [ -z "$col_id" ]; then
        dialog --msgbox "Chave primária não encontrada. Não é possível deletar." 8 60
        return 1
    fi

    local ID=""
    if [ -n "$ROW" ]; then
        local COLUMNS
        COLUMNS=$(show_columns_db "$TABLE" | awk 'NR>1 {print $1}')

        mapfile -t COL_ARRAY <<< "$COLUMNS"
        IFS=$'\t' read -ra VAL_ARRAY <<< "$ROW"

        local pk_index=-1
        local i
        for i in "${!COL_ARRAY[@]}"; do
            if [ "${COL_ARRAY[$i]}" = "$col_id" ]; then
                pk_index=$i
                break
            fi
        done

        if [ "$pk_index" -lt 0 ]; then
            dialog --msgbox "Não foi possível localizar a PK da linha selecionada." 8 60
            return 1
        fi

        ID="${VAL_ARRAY[$pk_index]}"
    else
        ID=$(dialog --inputbox "Digite o valor da chave primária ($col_id):" 8 50 \
            3>&1 1>&2 2>&3)

        [ $? -ne 0 ] && return 1
    fi

    dialog --yesno "Confirmar exclusão de $col_id = $ID?" 8 50
    [ $? -ne 0 ] && return 1

    local SAFE_COL
    SAFE_COL=$(sql_quote_identifier "$col_id") || return 1

    delete_db "$TABLE" "$SAFE_COL=$(sql_quote_value "$ID")"

    dialog --msgbox "Registro deletado!" 8 40
}
