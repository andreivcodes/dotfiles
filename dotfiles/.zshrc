unalias claude 2>/dev/null
claude() {
    local config_value=""
    local claude_args=()
    local user_provided=false
    while [[ $# -gt 0 ]]; do
        case $1 in
            -u)
                if [[ -n "$2" && "$2" != -* ]]; then
                    config_value="$2"
                    user_provided=true
                    shift 2
                else
                    echo "Error: -u requires a value" >&2
                    return 1
                fi
                ;;
            *)
                claude_args+=("$1")
                shift
                ;;
        esac
    done
    if [[ "$user_provided" = false ]]; then
        echo "Error: -u parameter is required. Usage: claude -u <profile> [args...]" >&2
        return 1
    fi
    echo "Claude Code user: $config_value."
    CLAUDE_CONFIG_DIR="$HOME/.claude-$config_value" command claude "${claude_args[@]}"
}
