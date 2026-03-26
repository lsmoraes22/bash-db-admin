function generate_musiconhold() {
    local TENANT_CODE="$1"
    local SILENT="${2:-0}"

    if [[ -z "$TENANT_CODE" ]]; then
        dialog --msgbox "Tenant code não informado!" 6 40
        return 1
    fi

    local BASE_DIR="/etc/asterisk/tenants/${TENANT_CODE}"
    local OUTPUT_FILE="${BASE_DIR}/musiconhold.conf"
    local MOH_DIR="/var/lib/asterisk/moh/tenants/${TENANT_CODE}"

    # cria diretórios
    mkdir -p "$BASE_DIR"
    mkdir -p "$MOH_DIR"

    # gera config
    cat > "$OUTPUT_FILE" <<EOF
; Music on Hold - Tenant ${TENANT_CODE}

[moh-${TENANT_CODE}]
mode=files
directory=${MOH_DIR}
sort=alpha
EOF

    if [ "$SILENT" != "1" ]; then
        dialog --msgbox "musiconhold.conf gerado para ${TENANT_CODE}" 6 50
    fi
}
