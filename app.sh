#!/usr/bin/env bash

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export BASE_DIR
source "$BASE_DIR/autoload.sh"
do_login

while true; do
    main_menu
done