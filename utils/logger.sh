function log_info() {
    echo "[INFO] $1"
}

function var_dump() {
    local VAR_NAME=$1
    local VALUE="${!VAR_NAME}"

    echo "===== VAR_DUMP ====="
    echo "Name : $VAR_NAME"
    echo "Value: $VALUE"
    echo "Length: ${#VALUE}"
    echo "===================="
}

function assert_function() {
    if ! type "$1" &>/dev/null; then
        echo "Função não encontrada: $1"
        exit 1
    fi
}