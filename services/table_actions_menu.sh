function table_actions_menu() {
    local TABLE=$1

    while true; do
        ACTION=$(dialog --menu "Tabela: $TABLE" \
            15 60 5 \
            1 "Criar registro" \
            2 "Visualizar dados" \
            3 "Ver colunas" \
            4 "Deletar registro" \
            5 "Voltar" \
            3>&1 1>&2 2>&3)

        [ $? -ne 0 ] && return 1

        case $ACTION in
            1) create_record "$TABLE" ;;
            2) show_table_data "$TABLE" 10 0 ;;
            3) show_columns "$TABLE" ;;
            4) delete_row "$TABLE" ;;
            5) break ;;
        esac
    done
}