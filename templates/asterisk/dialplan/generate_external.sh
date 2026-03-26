generate_external() {
    local TENANT_CODE="$1"
    local SILENT="${2:-0}"

    if [[ -z "$TENANT_CODE" ]]; then
        dialog --msgbox "Tenant code não informado!" 6 40
        return 1
    fi

    local OUTPUT_FILE="/etc/asterisk/tenants/${TENANT_CODE}/dialplan/external.conf"

    mkdir -p "/etc/asterisk/tenants/${TENANT_CODE}/dialplan"

    # busca trunks do tenant
    local TMP
    TMP=$(mktemp)

    execute_query "SELECT id FROM trunks WHERE tenant_code=$(sql_quote_value "$TENANT_CODE")" \
        | sed '1d' > "$TMP"

    # inicia arquivo
    echo "; Saida Local - Tenant ${TENANT_CODE}" > "$OUTPUT_FILE"

    # verifica se tem trunks
    if [[ ! -s "$TMP" ]]; then
        echo "; Nenhum trunk configurado" >> "$OUTPUT_FILE"
        rm -f "$TMP"
        if [ "$SILENT" != "1" ]; then
            dialog --msgbox "external.conf gerado para ${TENANT_CODE}" 8 50
        fi
        return 0
    fi

    # loop nos trunks
    while read -r trunk_id; do
        cat >> "$OUTPUT_FILE" <<EOF

exten => _[2-5]XXXXXXX,1,NoOp(Saida Local via ${trunk_id})
 same => n,Dial(PJSIP/\${EXTEN}@${trunk_id},60,rt)
 same => n,Hangup()
EOF

    done < "$TMP"

    rm -f "$TMP"

    if [ "$SILENT" != "1" ]; then
        dialog --msgbox "external.conf gerado para ${TENANT_CODE}" 8 50
    fi
}
