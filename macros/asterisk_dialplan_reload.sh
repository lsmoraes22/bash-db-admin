function asterisk_dialplan_reload() {
    asterisk -rx "dialplan reload"
    dialog --msgbox "Dialplan recarregado!" 6 40
}