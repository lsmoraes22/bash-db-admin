generate_internal() {
    local TENANT_CODE="$1"
    local SILENT="${2:-0}"

    if [[ -z "$TENANT_CODE" ]]; then
        dialog --msgbox "Tenant code não informado!" 6 40
        return 1
    fi

    local BASE_DIR="/etc/asterisk/tenants/${TENANT_CODE}/dialplan"
    local OUTPUT_FILE="${BASE_DIR}/internal.conf"

    mkdir -p "$BASE_DIR"

    cat > "$OUTPUT_FILE" <<EOF
; Internal Dialplan - Tenant ${TENANT_CODE}

[ctx-${TENANT_CODE}-from-internal]

; Chamadas internas (ramais de 4 dígitos)
exten => _XXXX,1,NoOp(Chamada Interna para o Ramal \${EXTEN})
 same => n,Dial(PJSIP/\${EXTEN},30,rtT)
 same => n,Hangup()

; Realtime (opcional)
switch => Realtime/${TENANT_CODE}-from-internal@extensions
EOF

    if [ "$SILENT" != "1" ]; then
        dialog --msgbox "internal.conf gerado para ${TENANT_CODE}" 8 50
    fi
}
