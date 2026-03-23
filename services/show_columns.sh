function show_columns() {
    local TABLE=$1
    local TMP_FILE="/tmp/columns.txt"

    execute_query "SHOW COLUMNS FROM $TABLE" > "$TMP_FILE"

    dialog --textbox "$TMP_FILE" 20 70

    rm -f "$TMP_FILE"
}