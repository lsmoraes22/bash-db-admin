asterisk::generate_all_moh() {
    local TMP
    TMP=$(mktemp)

    execute_query "SELECT code FROM tenants ORDER BY code" | sed '1d' > "$TMP"

    while read -r code; do
        [ -z "$code" ] && continue
        generate_musiconhold "$code" 1
    done < "$TMP"

    rm -f "$TMP"

    dialog --msgbox "MOH gerado para todos tenants!" 8 40
}
