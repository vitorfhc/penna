#!/bin/bash

set -euo pipefail

script_path=$(realpath $0)
script_path=$(dirname $script_path)

source $script_path/libs/log.sh
source $script_path/libs/naabu.sh
source $script_path/libs/nmap.sh

function usage() {
    echo "Usage: $0 -i <ip>"
    echo "Options:"
    echo "  -t <target> Target IP address to scan"
    echo "  -u          Scan UDP ports"
    echo "  -i          Install this script"
    echo "  -o          Output directory (default: <ip>)"
    echo "  -h          Show this help message"
    exit 1
}

function install() {
    local target_dir="/usr/local/bin"
    local name="recon"
    local source_path=$(realpath $0)
    local target_path="$target_dir/$name"

    log::info "This script will be installed to $target_path"
    log::warn "You may be asked for your password"
    sudo rm -f $target_path
    sudo ln -s $source_path $target_path
}

function check_dependencies() {
    if ! nmap::is_installed
    then
        log::error "nmap could not be found"
        exit 1
    fi

    if ! naabu::is_installed
    then
        log::error "naabu could not be found"
        exit 1
    fi
}

function main() {
    local ip=""
    local udp=false

    while getopts ":hufit:" opt; do
        case $opt in
            h)
                usage
                ;;
            t)
                ip=$OPTARG
                ;;
            u)
                udp=true
                ;;
            i)
                install && exit 0 || exit 1
                ;;
            \?)
                log::error "Invalid option: -$OPTARG"
                usage
                ;;
        esac
    done

    if [ -z "$ip" ]; then
        log::error "IP address not specified"
        usage
    fi

    check_dependencies

    log::info "Setting up directories"
    local dir=$ip

    if [ ! -z "$output" ]; then
        dir=$output
    fi

    mkdir -p $dir

    log::info "Starting TCP scanning"
    naabu::scan_tcp_top_1000 $ip $dir/naabu.tcp-top-1000.txt $dir/nmap.tcp-top-1000.txt && \
        log::success "TCP scanning completed successfully" || \
        { log::error "TCP scanning failed" && exit 1; }
    
    if [ "$udp" = true ]; then
        log::info "Starting UDP scanning"
        log::warn "UDP scanning requires root privileges, you may be asked for your password"
        nmap::scan_udp_top_1000 $ip $dir/nmap.udp-top-1000.txt && \
            {
                log::success "UDP scanning completed successfully"
                log::warn "Changing ownership of $dir to $(whoami), you may be asked for your password"
                sudo chown -R $(whoami) $dir
            } || \
            { log::error "UDP scanning failed" && exit 1; }
    fi
}

main $@
