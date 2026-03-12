#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

shopt -s nullglob

pt_files=("$SCRIPT_DIR"/*.pt "$SCRIPT_DIR"/results/*.pt "$SCRIPT_DIR"/results_pi3/*.pt)

choose_pt_file() {
    if (( ${#pt_files[@]} > 0 )); then
        echo "Found these .pt files:"
        local i=1
        for file in "${pt_files[@]}"; do
            echo "  ${i}) ${file#$SCRIPT_DIR/}"
            i=$((i + 1))
        done
        echo "  ${i}) Enter a custom path"
        read -r -p "Selection [1]: " file_choice
        file_choice="${file_choice:-1}"

        if [[ "$file_choice" =~ ^[0-9]+$ ]] && (( file_choice >= 1 && file_choice <= ${#pt_files[@]} )); then
            PT_FILE="${pt_files[file_choice-1]}"
            return
        fi
    fi

    read -r -e -p "Enter path to .pt file: " PT_FILE
}

choose_input_path() {
    local default_input="data/examples/office"
    read -r -e -p "Input folder for reference [${default_input}]: " INPUT_PATH
    INPUT_PATH="${INPUT_PATH:-$default_input}"
}

choose_port() {
    read -r -p "Viewer port [8080]: " PORT
    PORT="${PORT:-8080}"
}

choose_pt_file

if [[ ! -f "$PT_FILE" ]]; then
    echo "File not found: $PT_FILE"
    exit 1
fi

choose_input_path
choose_port

echo
echo "Starting viewer with:"
echo "  predictions: $PT_FILE"
echo "  input:       $INPUT_PATH"
echo "  port:        $PORT"
echo

XFORMERS_DISABLED=1 uv run python demo_viser.py \
    --load "$PT_FILE" \
    --input "$INPUT_PATH" \
    --device cpu \
    --port "$PORT"
