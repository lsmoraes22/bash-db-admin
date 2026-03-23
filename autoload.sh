source_files() {
    local base_dir="$1"

    for existing in "$base_dir"/*; do
        [[ ! -e "$existing" ]] && continue
        [[ "$existing" == *autoload.sh ]] && continue

        case "$existing" in
            *.sh)
                source "$existing"
                ;;
            *)
                [[ -d "$existing" ]] && source_files "$existing"
                ;;
        esac
    done
}

source_files "$BASE_DIR/utils"
source_files "$BASE_DIR/services"
source_files "$BASE_DIR/views"

source "$BASE_DIR/do_login.sh"
source "$BASE_DIR/routes.sh"
