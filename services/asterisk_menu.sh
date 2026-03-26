function list_tenant_codes() {
    execute_query "SELECT code FROM tenants ORDER BY code" | sed '1d'
}

function prompt_tenant_code() {
    local TENANTS
    TENANTS=$(list_tenant_codes)

    if [ -z "$TENANTS" ]; then
        show_message "Nenhum tenant encontrado na tabela tenants."
        return 1
    fi

    local OPTIONS
    OPTIONS=($(build_menu_options <<< "$TENANTS"))

    local CHOICE
    CHOICE=$(ui_menu "Selecione o tenant" "${OPTIONS[@]}")
    [ $? -ne 0 ] && return 1

    echo "$TENANTS" | sed -n "${CHOICE}p"
}

function generate_tenant_asterisk_files() {
    local TENANT_CODE="$1"
    local SILENT="${2:-0}"

    [ -z "$TENANT_CODE" ] && return 1

    generate_internal "$TENANT_CODE" 1 || return 1
    generate_external "$TENANT_CODE" 1 || return 1
    generate_full "$TENANT_CODE" 1 || return 1
    generate_incoming "$TENANT_CODE" 1 || return 1
    generate_extensions "$TENANT_CODE" 1 || return 1
    generate_musiconhold "$TENANT_CODE" 1 || return 1

    if [ "$SILENT" != "1" ]; then
        show_message "Arquivos do tenant ${TENANT_CODE} gerados com sucesso!" "Asterisk"
    fi
}

function generate_selected_tenant_asterisk_files() {
    local TENANT_CODE
    TENANT_CODE=$(prompt_tenant_code) || return 1

    generate_tenant_asterisk_files "$TENANT_CODE"
}

function generate_all_tenant_asterisk_files() {
    local TENANTS
    TENANTS=$(list_tenant_codes)

    if [ -z "$TENANTS" ]; then
        show_message "Nenhum tenant encontrado na tabela tenants."
        return 1
    fi

    local TENANT_CODE
    while IFS= read -r TENANT_CODE; do
        [ -z "$TENANT_CODE" ] && continue
        generate_tenant_asterisk_files "$TENANT_CODE" 1 || return 1
    done <<< "$TENANTS"

    show_message "Arquivos gerados para todos os tenants!" "Asterisk"
}

function asterisk_menu() {
    while true; do
        local ACTION
        ACTION=$(show_asterisk_menu)
        [ $? -ne 0 ] && return 1

        case $ACTION in
            1) generate_selected_tenant_asterisk_files ;;
            2) generate_all_tenant_asterisk_files ;;
            3) asterisk_dialplan_reload ;;
            4) break ;;
        esac
    done
}
