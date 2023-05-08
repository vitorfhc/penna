function naabu::is_installed() {
    if ! command -v naabu &> /dev/null
    then
        return 1
    fi
}

function naabu::scan_tcp_top_1000() {
    local target=$1
    local output=$2
    local nmap_output=$3

    if [ $# -ne 3 ]; then
        log::error "Usage: naabu::scan_top_1000 <target> <output> <nmap_output>"
        return 1
    fi

    naabu -top-ports 1000 -host $target -o $output -nmap-cli "-sC -sV -oN $nmap_output" -silent
}