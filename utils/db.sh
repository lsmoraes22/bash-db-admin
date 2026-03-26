source "$BASE_DIR/utils/validator.sh"
source "$BASE_DIR/views/ui.sh"

SQL_LIST_SEPARATOR=$'\x1f'

function sql_quote_identifier() {
    local IDENTIFIER="$1"

    validate_identifier "$IDENTIFIER" || return 1
    printf '`%s`' "$IDENTIFIER"
}

function sql_escape_value() {
    local VALUE="$1"

    VALUE=${VALUE//\\/\\\\}
    VALUE=${VALUE//$'\n'/\\n}
    VALUE=${VALUE//$'\r'/\\r}
    VALUE=${VALUE//$'\t'/\\t}
    VALUE=${VALUE//$'\032'/\\Z}
    VALUE=${VALUE//\'/\\\'}

    printf '%s' "$VALUE"
}

function sql_quote_value() {
    local VALUE="$1"

    printf "'%s'" "$(sql_escape_value "$VALUE")"
}

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

    local SAFE_TABLE
    SAFE_TABLE=$(sql_quote_identifier "$TABLE") || return 1

    local SAFE_COLUMNS=()
    if [ "$COLUMNS" = "*" ]; then
        SAFE_COLUMNS+=("*")
    else
        IFS=',' read -ra COL_ARRAY <<< "$COLUMNS"
        for col in "${COL_ARRAY[@]}"; do
            SAFE_COLUMNS+=("$(sql_quote_identifier "$col")") || return 1
        done
    fi

    local COLUMNS_JOINED
    COLUMNS_JOINED=$(IFS=,; echo "${SAFE_COLUMNS[*]}")

    local QUERY="SELECT $COLUMNS_JOINED FROM $SAFE_TABLE"

    if [ -n "$WHERE" ]; then
        QUERY="$QUERY WHERE $WHERE"
    fi

    if [ -n "$ORDER" ]; then
        QUERY="$QUERY $ORDER"
    fi

    if [ -n "$LIMIT" ]; then
        QUERY="$QUERY $LIMIT"
    fi

    if [ -n "$OFFSET" ]; then
        QUERY="$QUERY $OFFSET"
    fi

    execute_query "$QUERY"
}

function insert_db() {
    local TABLE="$1"
    local COLUMNS_SERIALIZED="$2"
    local VALUES_SERIALIZED="$3"

    local SAFE_TABLE
    SAFE_TABLE=$(sql_quote_identifier "$TABLE") || return 1

    IFS="$SQL_LIST_SEPARATOR" read -r -a COL_ARRAY <<< "$COLUMNS_SERIALIZED"
    IFS="$SQL_LIST_SEPARATOR" read -r -a VAL_ARRAY <<< "$VALUES_SERIALIZED"

    if [ ${#COL_ARRAY[@]} -ne ${#VAL_ARRAY[@]} ]; then
        echo "Número de colunas e valores não bate colunas ${#COL_ARRAY[@]} vs valores ${#VAL_ARRAY[@]}"
        return 1
    fi

    local SAFE_COLUMNS=()
    local ESCAPED_VALUES=()

    for i in "${!COL_ARRAY[@]}"; do
        local col="${COL_ARRAY[$i]}"
        local val="${VAL_ARRAY[$i]}"

        SAFE_COLUMNS+=("$(sql_quote_identifier "$col")") || return 1
        ESCAPED_VALUES+=("$(sql_quote_value "$val")")
    done

    local COLS_JOINED
    COLS_JOINED=$(IFS=,; echo "${SAFE_COLUMNS[*]}")

    local VALUES_JOINED
    VALUES_JOINED=$(IFS=,; echo "${ESCAPED_VALUES[*]}")

    local QUERY="INSERT INTO $SAFE_TABLE ($COLS_JOINED) VALUES ($VALUES_JOINED)"

    execute_query "$QUERY"
}

function update_db() {
    local TABLE="$1"
    local SETS_SERIALIZED="$2"
    local WHERE="$3"

    local SAFE_TABLE
    SAFE_TABLE=$(sql_quote_identifier "$TABLE") || return 1

    IFS="$SQL_LIST_SEPARATOR" read -r -a SET_ARRAY <<< "$SETS_SERIALIZED"

    local SET_STRING=""

    for pair in "${SET_ARRAY[@]}"; do
        IFS='=' read -r col val <<< "$pair"

        local SAFE_COL
        SAFE_COL=$(sql_quote_identifier "$col") || return 1

        if [ -n "$SET_STRING" ]; then
            SET_STRING+=", "
        fi

        SET_STRING+="$SAFE_COL=$(sql_quote_value "$val")"
    done

    local QUERY="UPDATE $SAFE_TABLE SET $SET_STRING"

    if [ -n "$WHERE" ]; then
        QUERY="$QUERY WHERE $WHERE"
    fi

    execute_query "$QUERY"
}

function delete_db() {
    local TABLE="$1"
    local WHERE="$2"

    local SAFE_TABLE
    SAFE_TABLE=$(sql_quote_identifier "$TABLE") || return 1

    if [ -z "$WHERE" ]; then
        echo "DELETE sem WHERE bloqueado por segurança"
        return 1
    fi

    local QUERY="DELETE FROM $SAFE_TABLE WHERE $WHERE"

    execute_query "$QUERY"
}

function show_columns_db() {
    local TABLE="$1"

    local SAFE_TABLE
    SAFE_TABLE=$(sql_quote_identifier "$TABLE") || return 1

    execute_query "SHOW COLUMNS FROM $SAFE_TABLE"
}

function show_tables_db() {
    execute_query "SHOW TABLES"
}

function describe_table_db() {
    local TABLE="$1"

    local SAFE_TABLE
    SAFE_TABLE=$(sql_quote_identifier "$TABLE") || return 1

    execute_query "DESCRIBE $SAFE_TABLE"
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
