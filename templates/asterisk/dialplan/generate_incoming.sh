generate_incoming() {
    local TENANT_CODE="$1"
    local SILENT="${2:-0}"

    if [[ -z "$TENANT_CODE" ]]; then
        dialog --msgbox "Tenant code não informado!" 6 40
        return 1
    fi

    local BASE_DIR="/etc/asterisk/tenants/${TENANT_CODE}/dialplan"
    local OUTPUT_FILE="${BASE_DIR}/incoming.conf"

    mkdir -p "$BASE_DIR"

    local TMP
    TMP=$(mktemp)

    # busca DID + destino
    execute_query "SELECT number,destination FROM did_numbers WHERE tenant_code=$(sql_quote_value "$TENANT_CODE")" \
        | sed '1d' > "$TMP"

    # inicia arquivo
    cat > "$OUTPUT_FILE" <<EOF
; Entrada DID - Tenant ${TENANT_CODE}
[ctx-${TENANT_CODE}-incoming]
EOF

    if [[ ! -s "$TMP" ]]; then
        echo "; Nenhum DID configurado" >> "$OUTPUT_FILE"
        rm -f "$TMP"
        if [ "$SILENT" != "1" ]; then
            dialog --msgbox "incoming.conf gerado para ${TENANT_CODE}" 8 50
        fi
        return 0
    fi

    while IFS=$'\t' read -r did_number destination; do
        [[ -z "$did_number" ]] && continue

        cat >> "$OUTPUT_FILE" <<EOF

exten => ${did_number},1,NoOp(Entrada via DID ${did_number})
 same => n,Set(CDR(accountcode)=${TENANT_CODE})
 same => n,Goto(ctx-${TENANT_CODE}-from-internal,${destination},1)
EOF

    done < "$TMP"

    rm -f "$TMP"

    if [ "$SILENT" != "1" ]; then
        dialog --msgbox "incoming.conf gerado para ${TENANT_CODE}" 8 50
    fi
}
