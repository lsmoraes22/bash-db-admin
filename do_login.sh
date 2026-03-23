function do_login() {
    while true; do

        if ! login_screen; then
            show_message "Login cancelado!"
            exit 1
        fi

        if test_connection; then
            show_message "Login realizado com sucesso!"
            break
        else
            show_message "Erro ao conectar no banco!"
            confirm "Deseja tentar novamente?" || exit 1
        fi

    done
}