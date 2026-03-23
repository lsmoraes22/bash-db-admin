function delete_row() {
    local TABLE=$1

    local ID=$(dialog --inputbox "Digite o ID para deletar:" 8 40 \
        3>&1 1>&2 2>&3)

    [ $? -ne 0 ] && return 1

    dialog --yesno "Confirmar exclusão do ID $ID?" 8 40
    [ $? -ne 0 ] && return 1

    col_id=$(search_primary_key_db "$TABLE")

    if [ $? -ne 0 ]; then
        dialog --msgbox "Coluna 'id' não encontrada. Não é possível deletar." 8 50
        return 1
    fi

    if ! is_number "$ID"; then
        ID="'$ID'"
    fi
    delete_db "$TABLE" "\`$col_id\`=$ID"

    dialog --msgbox "Registro deletado!" 8 40
}