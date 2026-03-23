function is_number() {
    [[ "$1" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]
}

str_replace() {
    local search="$1"
    local replace="$2"
    local subject="$3"

    echo "${subject//$search/$replace}"
}

substr() {
    local string="$1"
    local start="$2"
    local length="$3"

    echo "${string:$start:$length}"
}

strlen() {
    local str="$1"
    echo "${#str}"
}

strpos() {
    local string="$1"
    local substring="$2"

    expr index "$string" "$substring"
}

str_contains() {
    [[ "$1" == *"$2"* ]]
}

trim() {
    local var="$1"
    # remove espaços início/fim
    var="${var#"${var%%[![:space:]]*}"}"
    var="${var%"${var##*[![:space:]]}"}"
    echo "$var"
}

explode() {
    local delimiter="$1"
    local string="$2"

    IFS="$delimiter" read -ra result <<< "$string"
    echo "${result[@]}"
}

implode() {
    local delimiter="$1"
    shift
    local array=("$@")

    local IFS="$delimiter"
    echo "${array[*]}"
}


to_upper() {
    echo "${1^^}"
}

to_lower() {
    echo "${1,,}"
}

replace_regex() {
    local pattern="$1"
    local replace="$2"
    local string="$3"

    echo "$string" | sed -E "s/$pattern/$replace/g"
}