function input_box() {
    if [ -n "$3" ]; then
        height="$3"
    else
        height=8
    fi
    if [ -n "$4" ]; then
        width="$4"
    else
        width=40
    fi
    dialog --inputbox "$1" $height $width "$2" 3>&1 1>&2 2>&3
}

function input_checkbox() {
    if [ -n "$3" ]; then
        height="$3"
    else
        height=8
    fi
    if [ -n "$4" ]; then
        width="$4"
    else
        width=8
    fi
    dialog --checklist "$1" $height $width 5 "${@:2}" 3>&1 1>&2 2>&3
}

function password_box() {
    if [ -n "$3" ]; then
        height="$3"
    else
        height=8
    fi
    if [ -n "$4" ]; then
        width="$4"
    else
        width=40
    fi
    dialog --insecure --passwordbox "$1" $height $width 3>&1 1>&2 2>&3
}

function select_option() {
    dialog --menu "$1" 15 60 4 "${@:2}" 3>&1 1>&2 2>&3
}

function confirm() {
    dialog --yesno "$1" 8 40
    return $?
}

function show_message() {
    dialog --title "${2:-Mensagem}" --msgbox "$1" 8 50
}

function ui_menu() {
    local TITLE="$1"
    local width=50
    local height=15
    local menu_height=6
    shift

    dialog --title "$TITLE" \
        --menu "Escolha uma opção:" $height $width $menu_height \
        "$@" \
        3>&1 1>&2 2>&3
}

function form_box() {
    local TITLE="$1"
    shift

    local FIELDS=("$@")
    local FORM_HEIGHT=${#FIELDS[@]}
    local HEIGHT=20
    local WIDTH=70

    local ARGS=()
    local i=1

    for field in "${FIELDS[@]}"; do
        IFS='|' read -r NAME LABEL DEFAULT <<< "$field"

        ARGS+=("$LABEL" "$i" "1" "$DEFAULT" "$i" "25" "30" "0")

        ((i++))
    done

    local RESULT
    RESULT=$(dialog --title "$TITLE" \
        --form "Preencha os campos:" \
        "$HEIGHT" "$WIDTH" "$FORM_HEIGHT" \
        "${ARGS[@]}" \
        3>&1 1>&2 2>&3)

    local STATUS=$?
    [ $STATUS -ne 0 ] && return 1

    i=1
    for field in "${FIELDS[@]}"; do
        IFS='|' read -r NAME LABEL DEFAULT <<< "$field"

        VALUE=$(echo "$RESULT" | sed -n "${i}p")
        export "$NAME"="$VALUE"

        ((i++))
    done

    return 0
}

function build_menu_options() {
    local OPTIONS=()
    local i=1

    while read -r line; do
        OPTIONS+=("$i" "$line")
        ((i++))
    done

    echo "${OPTIONS[@]}"
}

function textbox() {
    dialog --textbox "$1" "$2" "$3"
}