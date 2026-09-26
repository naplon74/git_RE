#!/bin/bash

VERSION="v1.1"

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Define paths relative to the script location
CONFIG_FILE="$SCRIPT_DIR/../config.json"
OUTPUT_FILE="$SCRIPT_DIR/../repos_status.json"
PYTHON_SCRIPT="$SCRIPT_DIR/output.py"
LOG_FILE="$SCRIPT_DIR/../logs.txt"

# Default git directory (pulls from config.json using jq)
GIT=$(jq -r '.path_to_git' "$CONFIG_FILE")

echo "Git_RE $VERSION"
echo "Git_RE $VERSION logs" > "$LOG_FILE"
echo >> "$LOG_FILE"
date >> "$LOG_FILE"

# Check if the path exists
if [[ -e "$GIT" ]]; then
    echo "[SUCCESS] Git found in $GIT." >> "$LOG_FILE"
else
    echo "[ERROR] Git Path specified in config.json does not exist." >> "$LOG_FILE"
    echo "[INFO] Please edit config.json and set a valid path." >> "$LOG_FILE"
    echo "[INFO] You may use commands such as 'where git' or 'whereis git' to find its location." >> "$LOG_FILE"
    echo "[EXIT] Exited with 1" >> "$LOG_FILE"
    echo "Git wasn't. Found please check $LOG_FILE for more information."
    exit 1
fi

# Create a temporary file to collect objects
tmpfile=$(mktemp)

echo "[INFO] Starting to look for local git repos." >> "$LOG_FILE"
find ~ -type d -name ".git" 2>/dev/null | while read -r gitdir; do
    repo="${gitdir%/.git}"

    # Branch
    branch=$(git -C "$repo" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")

    # Dirty check
    echo "Found $repo."
    echo >> "$LOG_FILE"
    echo "----------------------------------" >> "$LOG_FILE"
    echo "[INFO] $repo found." >> "$LOG_FILE"
    if git -C "$repo" status --porcelain 2>/dev/null | grep -q .; then
        dirty=true
    else
        dirty=false
    fi

    # Fetch latest from remote (quiet)
    echo "[INFO] Running git fetch in $repo." >> "$LOG_FILE"
    git -C "$repo" fetch --quiet 2>/dev/null

    # Ahead / Behind
    ahead=0
    behind=0

    if git -C "$repo" rev-parse --abbrev-ref @{u} >/dev/null 2>&1; then
        counts=$(git -C "$repo" rev-list --left-right --count HEAD...@{u} 2>/dev/null)
        if [[ -n "$counts" ]]; then
            ahead=$(echo "$counts" | cut -f1)
            behind=$(echo "$counts" | cut -f2)
        fi
    fi

    echo "[INFO] Adding $repo to the json file." >> "$LOG_FILE"
    echo "----------------------------------" >> "$LOG_FILE"
    short_status=$(git -C "$repo" status -sb 2>/dev/null | head -n 1)

    # Safely create JSON object
    jq -n \
        --arg path "$repo" \
        --arg name "$(basename "$repo")" \
        --arg branch "$branch" \
        --argjson dirty "$dirty" \
        --argjson ahead "$ahead" \
        --argjson behind "$behind" \
        --arg status "$short_status" \
        '{
            path: $path,
            name: $name,
            branch: $branch,
            dirty: $dirty,
            ahead: $ahead,
            behind: $behind,
            status: $status
        }' >> "$tmpfile"
done

# Turn the lines into a proper JSON array
jq -s '.' "$tmpfile" > "$OUTPUT_FILE"
rm "$tmpfile"

# Run the Python script
if [[ -f "$PYTHON_SCRIPT" ]]; then
    echo >> "$LOG_FILE"
    echo "[SUCCESS] No error, running $PYTHON_SCRIPT." >> "$LOG_FILE"
    echo "[EXIT] Exited with code 0." >> "$LOG_FILE"
    echo
    echo "Running python script..."
    sleep 2
    clear
    python3 "$PYTHON_SCRIPT"
    exit 0
else
    echo >> "$LOG_FILE"
    echo "[ERROR] Python script wasn't found at $PYTHON_SCRIPT." >> "$LOG_FILE"
    echo "[EXIT] Exited with code 1." >> "$LOG_FILE"
    echo
    echo "Error: output.py not found check $LOGS_FILE for more information."
    exit 1
fi