source "$BASE_DIR/utils/validator.sh"
source "$BASE_DIR/views/ui.sh"

function test_connection() {
    MYSQL_PWD="$DB_PASS" mysql \
        -h"$DB_HOST" \
        -u"$DB_USER" \
        "$DB_NAME" \
        -e "SELECT 1;" >/dev/null 2>&1

    return $?
}

function execute_query() {
    local QUERY="$1"

    MYSQL_PWD="$DB_PASS" mysql \
        -h"$DB_HOST" \
        -u"$DB_USER" \
        "$DB_NAME" \
        -e "$QUERY"
}

function select_db() {
    local COLUMNS="$1"
    local TABLE="$2"
    local WHERE="$3"
    local ORDER="$4"
    local LIMIT="$5"
    local OFFSET="$6"

    if [ -z "$COLUMNS" ]; then
        COLUMNS="*"
    fi

    if [ -n "$ORDER" ]; then
        ORDER="ORDER BY $ORDER"
    fi

    if [ -n "$LIMIT" ]; then
        LIMIT="LIMIT $LIMIT"
    fi

    if [ -n "$OFFSET" ]; then
        OFFSET="OFFSET $OFFSET"
    fi

    validate_identifier "$TABLE" || return 1

    # valida colunas (suporta múltiplas separadas por vírgula)
    IFS=',' read -ra COL_ARRAY <<< "$COLUMNS"
    for col in "${COL_ARRAY[@]}"; do
        validate_identifier "$col" || return 1
    done

    local QUERY="SELECT $COLUMNS FROM $TABLE"

    if [ -n "$WHERE" ]; then
        QUERY="$QUERY WHERE $WHERE"
    fi

    execute_query "$QUERY"
}

function insert_db() {
    local TABLE="$1"
    local COLUMNS="$2"
    local VALUES="$3"

    validate_identifier "$TABLE" || return 1

    IFS=',' read -ra COL_ARRAY <<< "$COLUMNS"
    IFS=',' read -ra VAL_ARRAY <<< "$VALUES"


    if [ ${#COL_ARRAY[@]} -ne ${#VAL_ARRAY[@]} ]; then
        echo "Número de colunas e valores não bate colunas ${#COL_ARRAY[@]} vs valores ${#VAL_ARRAY[@]}"
        return 1
    fi

    local SAFE_COLUMNS=()
    local ESCAPED_VALUES=()

    for i in "${!COL_ARRAY[@]}"; do
        local col="${COL_ARRAY[$i]}"
        local val="${VAL_ARRAY[$i]}"

        validate_identifier "$col" || return 1
        val="'$val'"

        SAFE_COLUMNS+=("\`$col\`")
        ESCAPED_VALUES+=("$val")
    done

    local COLS_JOINED
    COLS_JOINED=$(IFS=,; echo "${SAFE_COLUMNS[*]}")

    local VALUES_JOINED
    VALUES_JOINED=$(IFS=,; echo "${ESCAPED_VALUES[*]}")

    local QUERY="INSERT INTO $TABLE ($COLS_JOINED) VALUES ($VALUES_JOINED)"

    execute_query "$QUERY"
}

function update_db() {
    local TABLE="$1"
    local SETS="$2"
    local WHERE="$3"

    validate_identifier "$TABLE" || return 1

    # Ex: "name=lucas,email=test"
    IFS=',' read -ra SET_ARRAY <<< "$SETS"

    local SET_STRING=""

    for pair in "${SET_ARRAY[@]}"; do
        IFS='=' read -r col val <<< "$pair"

        validate_identifier "$col" || return 1

        val=$(escape_value "$val")

        if [ -n "$SET_STRING" ]; then
            SET_STRING+=", "
        fi

        SET_STRING+="$col='$val'"
    done

    local QUERY="UPDATE $TABLE SET $SET_STRING"

    if [ -n "$WHERE" ]; then
        QUERY="$QUERY WHERE $WHERE"
    fi

    execute_query "$QUERY"
}

function delete_db() {
    local TABLE="$1"
    local WHERE="$2"

    validate_identifier "$TABLE" || return 1

    if [ -z "$WHERE" ]; then
        echo "DELETE sem WHERE bloqueado por segurança"
        return 1
    fi

    local QUERY="DELETE FROM $TABLE WHERE $WHERE"

    execute_query "$QUERY"
}

function show_columns_db() {
    local TABLE="$1"

    validate_identifier "$TABLE" || return 1

    execute_query "SHOW COLUMNS FROM $TABLE"
}

function show_tables_db() {
    execute_query "SHOW TABLES"
}

function describe_table_db() {
    local TABLE="$1"

    validate_identifier "$TABLE" || return 1

    execute_query "DESCRIBE $TABLE"
}

function search_primary_key_db() {
    local TABLE="$1"

    validate_identifier "$TABLE" || return 1

    show_columns_db "$TABLE" | awk 'NR>1 && $4=="PRI" {print $1}'
}

function  show_columns() {
    local TABLE="$1"

    validate_identifier "$TABLE" || return 1

    show_columns_db "$TABLE" | awk 'NR>1 {print $1}' | paste -sd, -
}