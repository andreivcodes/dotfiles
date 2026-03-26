#!/bin/bash

set -euo pipefail

# Source utility functions
source "$(dirname "$0")/../lib/utils.sh"

log_info "Configuring MCP environment variables..."

# Ensure not running as sudo
check_not_sudo
require_macos

ZSHRC_LOCAL="$HOME/.zshrc.local"

KEY_NAMES=(
    "CONTEXT7_API_KEY"
    "EXA_API_KEY"
)

KEY_LABELS=(
    "Context7 MCP"
    "Exa MCP"
)

KEY_DETAILS=(
    "Used by the Context7 MCP server in Codex, Claude Code, and OpenCode."
    "Used by the Exa MCP server in Codex, Claude Code, and OpenCode."
)

configured_keys=()
skipped_keys=()

has_export() {
    local file=$1
    local key=$2

    grep -Eq "^[[:space:]]*export[[:space:]]+${key}=" "$file" 2>/dev/null
}

ensure_zshrc_local() {
    if [ ! -f "$ZSHRC_LOCAL" ]; then
        printf "# Local secrets and machine-specific overrides\n" > "$ZSHRC_LOCAL"
        printf "# Created by dotfiles setup. This file is sourced from ~/.zshrc.\n\n" >> "$ZSHRC_LOCAL"
        chmod 600 "$ZSHRC_LOCAL"
        log_success "Created $ZSHRC_LOCAL"
    fi
}

upsert_export() {
    local key=$1
    local value=$2
    local escaped_value
    local temp_file

    ensure_zshrc_local

    printf -v escaped_value '%q' "$value"
    temp_file="$(mktemp "${TMPDIR:-/tmp}/dotfiles-mcp-env.XXXXXX")"

    awk -v key="$key" -v value="$escaped_value" '
        BEGIN { updated = 0 }
        $0 ~ "^[[:space:]]*export[[:space:]]+" key "=" {
            if (!updated) {
                print "export " key "=" value
                updated = 1
            }
            next
        }
        { print }
        END {
            if (!updated) {
                if (NR > 0) {
                    print ""
                }
                print "export " key "=" value
            }
        }
    ' "$ZSHRC_LOCAL" > "$temp_file"

    mv "$temp_file" "$ZSHRC_LOCAL"
    chmod 600 "$ZSHRC_LOCAL"
}

prompt_for_key() {
    local key=$1
    local label=$2
    local details=$3
    local current_value="${!key-}"
    local value=""

    echo
    log_info "$label"
    log_info "  $details"

    if has_export "$ZSHRC_LOCAL" "$key"; then
        if ! confirm "$key is already configured in ~/.zshrc.local. Update it?"; then
            skipped_keys+=("$key")
            return
        fi
    elif [ -n "$current_value" ]; then
        if confirm "$key is already set in your current shell. Save that value to ~/.zshrc.local?"; then
            upsert_export "$key" "$current_value"
            configured_keys+=("$key")
            log_success "Saved $key to ~/.zshrc.local"
            return
        fi

        if ! confirm "Enter a different value for $key now?"; then
            skipped_keys+=("$key")
            return
        fi
    else
        if ! confirm "Configure $key in ~/.zshrc.local now?"; then
            skipped_keys+=("$key")
            return
        fi
    fi

    while true; do
        read -r -s -p "$key: " value
        echo

        if [ -n "$value" ]; then
            break
        fi

        log_warning "$key cannot be empty"
    done

    upsert_export "$key" "$value"
    configured_keys+=("$key")
    log_success "Saved $key to ~/.zshrc.local"
}

for i in "${!KEY_NAMES[@]}"; do
    prompt_for_key "${KEY_NAMES[$i]}" "${KEY_LABELS[$i]}" "${KEY_DETAILS[$i]}"
done

echo
if [ ${#configured_keys[@]} -gt 0 ]; then
    log_success "Configured MCP environment variables: ${configured_keys[*]}"
fi

if [ ${#skipped_keys[@]} -gt 0 ]; then
    log_warning "Skipped MCP environment variables: ${skipped_keys[*]}"
    log_info "You can add them later to ~/.zshrc.local"
fi

log_info "Restart your terminal or run 'source ~/.zshrc' after setup to load updated API keys."
