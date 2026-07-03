#!/bin/sh
set -eu

PACKAGE_NAME="chinna-free-claude"
CFC_HOME_DIRNAME=".cfc"
CFC_COMMANDS="cfc-server cfc-claude cfc-codex cfc-init chinna-free-claude"

dry_run=0

show_usage() {
    cat <<'USAGE'
Usage: uninstall.sh [options]

Removes the Chinna-Free-Claude uv tool and deletes ~/.cfc/.
Does not remove uv, Claude Code, Codex, or the uv-managed Python runtime.

Options:
  --dry-run                Print commands without running them.
  --help                   Show this help text.
USAGE
}

fail() {
    printf 'error: %s\n' "$*" >&2
    exit 1
}

step() {
    printf '\n==> %s\n' "$1"
}

quote_arg() {
    case "$1" in
        *[!A-Za-z0-9_./:@%+=,-]*|"")
            escaped=$(printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g')
            printf '"%s"' "$escaped"
            ;;
        *)
            printf '%s' "$1"
            ;;
    esac
}

print_command() {
    printf '+'
    for arg in "$@"; do
        printf ' '
        quote_arg "$arg"
    done
    printf '\n'
}

run() {
    print_command "$@"
    if [ "$dry_run" -eq 0 ]; then
        "$@"
    fi
}

is_missing_uv_tool_error() {
    normalized=$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')
    case "$normalized" in
        *"not installed"* | *"no tool"* | *"nothing to uninstall"*) return 0 ;;
        *) return 1 ;;
    esac
}

add_path_entry() {
    [ -n "$1" ] || return 0
    case ":$PATH:" in
        *":$1:"*) ;;
        *) PATH="$1:$PATH" ;;
    esac
}

add_uv_to_path() {
    if [ -n "${XDG_BIN_HOME:-}" ]; then
        add_path_entry "$XDG_BIN_HOME"
    fi

    if [ -n "${HOME:-}" ]; then
        add_path_entry "$HOME/.local/bin"
        add_path_entry "$HOME/.cargo/bin"
    fi

    export PATH
}

is_cfc_command_running() {
    command_name=$1

    if command -v pgrep >/dev/null 2>&1; then
        if pgrep -x "$command_name" >/dev/null 2>&1; then
            return 0
        fi
        if pgrep -f "(^|/)${command_name}( |$)" >/dev/null 2>&1; then
            return 0
        fi
        return 1
    fi

    if ps -A -o comm= 2>/dev/null | grep -qx "$command_name"; then
        return 0
    fi

    return 1
}

assert_no_cfc_processes_running() {
    running=""

    for command_name in $CFC_COMMANDS; do
        if is_cfc_command_running "$command_name"; then
            running="${running} ${command_name}"
        fi
    done

    if [ -n "$running" ]; then
        fail "Chinna-Free-Claude is still running (${running# }). Stop those processes, then rerun uninstall."
    fi
}

uninstall_chinna_free_claude() {
    add_uv_to_path

    if ! command -v uv >/dev/null 2>&1; then
        printf 'uv not found on PATH; skipping uv tool uninstall.\n'
        return 0
    fi

    print_command uv tool uninstall "$PACKAGE_NAME"
    if [ "$dry_run" -eq 0 ]; then
        if output=$(uv tool uninstall "$PACKAGE_NAME" 2>&1); then
            return 0
        else
            status=$?
        fi
        if is_missing_uv_tool_error "$output"; then
            printf 'Chinna-Free-Claude uv tool not installed or already removed; skipping uv tool uninstall.\n'
            return 0
        fi
        if [ -n "$output" ]; then
            printf '%s\n' "$output" >&2
        fi
        fail "uv tool uninstall $PACKAGE_NAME failed with exit code $status; aborting before deleting ~/.cfc."
    fi
}

purge_cfc_home() {
    [ -n "${HOME:-}" ] || fail "HOME is not set; cannot locate ~/.cfc."

    cfc_home="$HOME/$CFC_HOME_DIRNAME"
    if [ ! -e "$cfc_home" ]; then
        printf 'No CFC config directory at %s; skipping purge.\n' "$cfc_home"
        return 0
    fi

    run rm -rf "$cfc_home"
}

parse_args() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            --dry-run)
                dry_run=1
                ;;
            --help|-h)
                show_usage
                exit 0
                ;;
            *)
                show_usage >&2
                fail "unknown option: $1"
                ;;
        esac
        shift
    done
}

parse_args "$@"

step "Checking for running Chinna-Free-Claude processes"
assert_no_cfc_processes_running

step "Removing Chinna-Free-Claude uv tool"
uninstall_chinna_free_claude

step "Purging FCC config and data from ~/.cfc"
purge_cfc_home

printf '\nChinna-Free-Claude has been removed.\n'
printf 'uv, Claude Code, Codex, and the uv-managed Python runtime were left installed.\n'
