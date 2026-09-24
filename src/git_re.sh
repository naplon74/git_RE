#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Define paths relative to the script location
CONFIG_FILE="$SCRIPT_DIR/../config.json"
OUTPUT_FILE="$SCRIPT_DIR/../repos_status.json"
PYTHON_SCRIPT="$SCRIPT_DIR/output.py"          # ← fixed

# Default git directory (pulls from config.json using jq)
GIT=$(jq -r '.path_to_git' "$CONFIG_FILE")

# Check if the path exists
if [[ -e "$GIT" ]]; then
    echo "Git found in $GIT."
else
    echo "Error: Path specified in config.json does not exist."
    echo "Please edit config.json and set a valid path."
    echo "You may use commands such as 'where git' or 'whereis git' to find it's location."
    exit 1
fi

# Create a temporary file to collect objects
tmpfile=$(mktemp)

find ~ -type d -name ".git" 2>/dev/null | while read -r gitdir; do
    repo="${gitdir%/.git}"
    branch=$(git -C "$repo" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")

    if git -C "$repo" status --porcelain 2>/dev/null | grep -q .; then
        dirty=true
    else
        dirty=false
    fi

    short_status=$(git -C "$repo" status -sb 2>/dev/null | head -n 1)

    printf '{"path":"%s","name":"%s","branch":"%s","dirty":%s,"status":"%s"}\n' \
        "$repo" "$(basename "$repo")" "$branch" "$dirty" "$short_status" >> "$tmpfile"
done

# Turn the lines into a proper JSON array
jq -s '.' "$tmpfile" > "$OUTPUT_FILE"
rm "$tmpfile"

# Run the Python script
if [[ -f "$PYTHON_SCRIPT" ]]; then
    python3 "$PYTHON_SCRIPT"
else
    echo "Error: output.py not found at $PYTHON_SCRIPT"
    exit 1
fi