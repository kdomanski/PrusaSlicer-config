#!/bin/bash

set -eu
set -o pipefail

TMP_FILE="$(mktemp)"
trap "rm -f $TMP_FILE" EXIT
FILE='vendor/Voron.ini'

SECTION="$1"
OPTION="$2"
VALUE="$3"

find_section() {
    fgrep -n "$1" "$FILE" | cut -d: -f1 | head -n1
}

find_opt_in_section() {
    local SECT_NAME="$1"
    local OPT_NAME="$2"

    local SECT_LINE="$(find_section "$SECT_NAME")"
    local LINE_AFTER_SECT="$(tail -n "+$SECT_LINE" "$FILE" | grep -nE "^$OPT_NAME = "  | cut -d: -f1 | head -n1)"
    echo $((SECT_LINE + LINE_AFTER_SECT - 1))
}

OPT_LINE="$(find_opt_in_section "$SECTION" "$OPTION")"
(head -n $((OPT_LINE - 1)) "$FILE"; tail -n +$((OPT_LINE)) "$FILE" | { IFS= read -r line && echo "$line""$VALUE" | tr -d '\r'; cat; }) > "$TMP_FILE" && mv "$TMP_FILE" "$FILE"
