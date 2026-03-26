function show_main_menu() {
    ui_menu "Menu Principal" \
        "1" "Mostrar Tabelas" \
        "2" "Gerar Arquivos Asterisk" \
        "3" "Editar Arquivo" \
        "4" "Sair"
}

function show_asterisk_menu() {
    ui_menu "Asterisk" \
        "1" "Gerar arquivos de um tenant" \
        "2" "Gerar arquivos de todos os tenants" \
        "3" "Recarregar dialplan" \
        "4" "Voltar"
}
