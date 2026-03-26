function generate_extensions() {
    local TENANT_CODE="$1"
    local SILENT="${2:-0}"

    if [[ -z "$TENANT_CODE" ]]; then
        dialog --msgbox "Tenant code não informado!" 6 40
        return 1
    fi

    local BASE_DIR="/etc/asterisk/tenants/${TENANT_CODE}"
    local OUTPUT_FILE="${BASE_DIR}/extensions.conf"

    # cria diretório se não existir
    mkdir -p "$BASE_DIR/dialplan"

    # gera arquivo
    cat > "$OUTPUT_FILE" <<EOF
; --- PERFIL: SOMENTE INTERNO ---
; O nome do contexto [ctx-${TENANT_CODE}-from-internal] JÁ ESTÁ dentro do internal.conf
#include "/etc/asterisk/tenants/${TENANT_CODE}/dialplan/internal.conf"

; --- PERFIL: SOMENTE EXTERNO ---
[ctx-${TENANT_CODE}-from-external]
#include "/etc/asterisk/tenants/${TENANT_CODE}/dialplan/external.conf"
#include "/etc/asterisk/tenants/${TENANT_CODE}/dialplan/full.conf"

; --- PERFIL: AMBOS (FULL) ---
[ctx-${TENANT_CODE}-full]
include => ctx-${TENANT_CODE}-from-internal
include => ctx-${TENANT_CODE}-from-external

; --- ENTRADA (DID) ---
[ctx-${TENANT_CODE}-incoming]
#include "/etc/asterisk/tenants/${TENANT_CODE}/dialplan/incoming.conf"
; Se chegou aqui e não deu match em nada acima:
exten => _X.,1,NoOp(Fim do dialplan externo para ${TENANT_CODE})
 same => n,Playback(ss-noservice)
 same => n,Hangup()
EOF

    if [ "$SILENT" != "1" ]; then
        dialog --msgbox "extensions.conf gerado para tenant ${TENANT_CODE}!" 8 50
    fi
}
