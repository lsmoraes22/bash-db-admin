generate_full() {
    local TENANT_CODE="$1"
    local SILENT="${2:-0}"

    if [[ -z "$TENANT_CODE" ]]; then
        dialog --msgbox "Tenant code não informado!" 6 40
        return 1
    fi

    local OUTPUT_FILE="/etc/asterisk/tenants/${TENANT_CODE}/dialplan/external_mobile.conf"
    local BASE_DIR="/etc/asterisk/tenants/${TENANT_CODE}/dialplan"

    mkdir -p "$BASE_DIR"

    local TMP
    TMP=$(mktemp)

    execute_query "SELECT id FROM trunks WHERE tenant_code=$(sql_quote_value "$TENANT_CODE")" \
        | sed '1d' > "$TMP"

    echo "; Saida Celular e DDD - Tenant ${TENANT_CODE}" > "$OUTPUT_FILE"

    if [[ ! -s "$TMP" ]]; then
        echo "; Nenhum trunk configurado" >> "$OUTPUT_FILE"
        rm -f "$TMP"
        if [ "$SILENT" != "1" ]; then
            dialog --msgbox "Regras de saída geradas para ${TENANT_CODE}" 8 50
        fi
        return 0
    fi

    while read -r trunk_id; do
        [[ -z "$trunk_id" ]] && continue

        cat >> "$OUTPUT_FILE" <<EOF

exten => _9XXXXXXXX,1,NoOp(Saida Celular via ${trunk_id})
 same => n,Set(PJSIP_SEND_SESSION_REFRESH=invite)
 same => n,Dial(PJSIP/\${EXTEN}@${trunk_id},60,rt)
 same => n,Hangup()

exten => _0X.,1,NoOp(Saida DDD via ${trunk_id})
 same => n,Set(PJSIP_SEND_SESSION_REFRESH=invite)
 same => n,Dial(PJSIP/\${EXTEN}@${trunk_id},60,rt)
 same => n,Hangup()

EOF

    done < "$TMP"

    rm -f "$TMP"

    if [ "$SILENT" != "1" ]; then
        dialog --msgbox "Regras de saída geradas para ${TENANT_CODE}" 8 50
    fi
}
