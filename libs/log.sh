function log::error() {
    printf "\e[1m\e[31m[!]\e[0m %s\e[0m\n" "$@"
}

function log::info() {
    printf "\e[1m\e[34m[*]\e[0m %s\e[0m\n" "$@"
}

function log::success() {
    printf "\e[1m\e[32m[+]\e[0m %s\e[0m\n" "$@"
}

function log::warn() {
    printf "\e[1m\e[33m[-]\e[0m %s\e[0m\n" "$@"
}
