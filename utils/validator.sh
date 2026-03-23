# Permite apenas letras, números e underscore
function validate_identifier() {
    if [[ ! "$1" =~ ^[a-zA-Z0-9_]+$ ]]; then
        echo "Identificador inválido: $1"
        return 1
    fi
}

# Escapa valores (strings)
function escape_value() {
    echo "$1" | sed "s/'/''/g"
}

