function main_menu() {
    OPTION=$(show_main_menu)
    case $OPTION in
        1) build_tables ;;
        2) exit 0 ;;
    esac
}


