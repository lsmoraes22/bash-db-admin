source "$BASE_DIR/views/ui.sh"


function login_screen() {
    
    form_box "Login MySQL" \
        "DB_HOST|Host|localhost" \
        "DB_USER|Usuário|root" \
        "DB_NAME|Banco|asterisk_panel" || return 1

    DB_PASS=$(password_box "Senha:") || return 1

    [ $? -ne 0 ] && return 1

    export DB_PASS
}