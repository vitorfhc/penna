function nmap::is_installed() {
    if ! command -v nmap &> /dev/null
    then
        return 1
    fi
}

function nmap::scan_udp_top_1000() {
    local target=$1
    local output=$2

    if [ $# -ne 2 ]; then
        log::error "Usage: nmap::scan_udp_top_1000 <target> <output>"
        return 1
    fi

    local user=$(whoami)
    local sudo=""

    if [ "$user" != "root" ]; then
        sudo="sudo"
    fi

    $sudo nmap -sU -sV -sC -oN $output $target
}