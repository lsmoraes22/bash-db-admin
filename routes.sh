function main_menu() {
    local OPTION
    OPTION=$(show_main_menu)
    case $OPTION in
        1) build_tables ;;
        2) asterisk_menu ;;
        3) browse '/etc/asterisk' ;;
        4) exit 0 ;;
    esac
}

