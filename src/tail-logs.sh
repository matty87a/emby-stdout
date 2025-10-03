#!/bin/sh

# Enhanced log tailing for Emby with category filtering
log_dir="/config/logs"

# Default to all log types if EMBY_LOGS not set
EMBY_LOGS="${EMBY_LOGS:-embyserver,ffmpeg,hardware}"

# Wait for logs directory to exist
while [ ! -d "$log_dir" ]; do
    echo "[$(date)] Waiting for logs directory..."
    sleep 2
done

# Wait for log files to exist
while [ -z "$(ls -A "$log_dir"/*.txt 2>/dev/null)" ]; do
    echo "[$(date)] Waiting for log files..."
    sleep 2
done

echo "[$(date)] Starting log tailing for categories: $EMBY_LOGS"

# Function to get log files based on category
get_log_files() {
    local category="$1"
    case "$category" in
        "embyserver")
            echo "$log_dir"/embyserver*.txt
            ;;
        "ffmpeg")
            echo "$log_dir"/ffmpeg-*.txt
            ;;
        "hardware")
            echo "$log_dir"/hardware_detection-*.txt
            ;;
        *)
            echo ""
            ;;
    esac
}

# Build list of files to tail based on EMBY_LOGS
files_to_tail=""

# Process each category
for category in $(echo "$EMBY_LOGS" | tr ',' ' '); do
    category=$(echo "$category" | xargs) # trim whitespace
    category_files=$(get_log_files "$category")
    if [ -n "$category_files" ]; then
        # Check if any files exist for this category
        if ls $category_files 2>/dev/null | grep -q .; then
            files_to_tail="$files_to_tail $category_files"
        fi
    fi
done

# If no files found, fall back to all files
if [ -z "$files_to_tail" ]; then
    echo "[$(date)] No files found for specified categories, falling back to all logs"
    files_to_tail="$log_dir"/*.txt
fi

# Tail the selected files
tail -f $files_to_tail 2>/dev/null
