function row_actions_menu() {
    local TABLE=$1
    local ROW=$2

    ACTION=$(dialog --menu "Registro:\n$ROW" 15 60 4 \
        1 "Ver detalhes" \
        2 "Editar" \
        3 "Deletar" \
        4 "Voltar" \
        3>&1 1>&2 2>&3)

    case $ACTION in
        1) show_message "$ROW" ;;
        2) edit_row "$TABLE" "$ROW" ;;
        3) delete_row "$TABLE" "$ROW" ;;
    esac
}