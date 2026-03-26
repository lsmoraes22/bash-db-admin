function generate_all_extensions() {
    local TMP
    TMP=$(mktemp)

    execute_query "SELECT code FROM tenants ORDER BY code" | sed '1d' > "$TMP"

    while read -r code; do
        [ -z "$code" ] && continue
        generate_extensions "$code" 1
    done < "$TMP"

    rm -f "$TMP"

    dialog --msgbox "Todos os tenants gerados!" 8 40
}
