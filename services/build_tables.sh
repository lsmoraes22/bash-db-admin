function build_tables() {
    local TABLES
    TABLES=$(show_tables_db)
    #remove header
    TABLES=$(echo "$TABLES" | sed '1d')

    local OPTIONS
    OPTIONS=($(build_menu_options <<< "$TABLES"))

    local CHOICE
    #CHOICE=$(dialog --menu "Selecione uma tabela" \
    #    20 60 10 \
    #    "${OPTIONS[@]}" \
    #    3>&1 1>&2 2>&3)
    CHOICE=$(ui_menu "Selecione uma tabela" "${OPTIONS[@]}")

    [ $? -ne 0 ] && return 1

    local TABLE_NAME=$(echo "$TABLES" | sed -n "${CHOICE}p")

    table_actions_menu "$TABLE_NAME"
}