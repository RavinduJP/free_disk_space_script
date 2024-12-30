#!/bin/bash

# Configuration
declare -A PATH_CONFIG
#PATH_CONFIG["/path/path/path/logs"]="/path/path_logs/file1"
PATH_CONFIG["/path/path/path1/logs"]="/path/path_logs/file2"
PATH_CONFIG["/path/path/path2/logs"]="/path/path_logs/file3"
PATH_CONFIG["/path/path/path3/logs"]="/path/path_logs/file4"
PATH_CONFIG["/path/path/path4/logs"]="/path/path_logs/file5"
#PATH_CONFIG["/path/path/path5/logs"]="/path/path_logs/file6"

# Prefixes in log to match 
PREFIXES=("log_type_1" "log_type_2" "log_type_3" "log_type_4")

# Get the current month and calculate the previous three months
CURRENT_MONTH=$(date +%Y-%m)
THREE_MONTHS_AGO=$(date -d "$CURRENT_MONTH-01 -3 months" +%Y-%m)

echo "Current month: $CURRENT_MONTH"
echo "Three months ago: $THREE_MONTHS_AGO"

# Process each log path
for LOG_PATH in "${!PATH_CONFIG[@]}"; do
  BACKUP_PATH="${PATH_CONFIG[$LOG_PATH]}"
  ORIGINAL_PATH="${BACKUP_PATH}/original"

  echo "Processing logs in: $LOG_PATH"
  echo "Backup path: $BACKUP_PATH"
  echo "Original path: $ORIGINAL_PATH"

  # Ensure backup and original directories exist
   mkdir -p "$BACKUP_PATH"
   mkdir -p "$ORIGINAL_PATH"

  # Loop through each prefix
  for PREFIX in "${PREFIXES[@]}"; do
    echo "Looking for logs with prefix: $PREFIX"

    # Loop through log files with the current prefix
    for LOG_FILE in "$LOG_PATH"/${PREFIX}-*.log; do
      # Check if file exists (to avoid errors if no matching files are found)
      if [[ ! -f $LOG_FILE ]]; then
        echo "No matching log files found for prefix: $PREFIX in $LOG_PATH."
        continue
      fi

      # Extract the month from the file name
      FILE_MONTH=$(basename "$LOG_FILE" | grep -oP "${PREFIX}-\K[0-9]{4}-[0-9]{2}")

      # Process files older than three months
      if [[ "$FILE_MONTH" < "$THREE_MONTHS_AGO" ]]; then
        echo "Processing logs for month: $FILE_MONTH with prefix: $PREFIX"

        # Create a zip file for the logs
        ZIP_FILE="${BACKUP_PATH}/${PREFIX}-${FILE_MONTH}.zip"
        echo "Zipping $LOG_FILE to $ZIP_FILE..."
        zip "$ZIP_FILE" "$LOG_FILE"

        # Move the original log files to the backup/original directory
        echo "Moving $LOG_FILE to ${ORIGINAL_PATH}..."
        mv "$LOG_FILE" "$ORIGINAL_PATH"
      else
        echo "Skipp ziping logs for month: $FILE_MONTH (within the last three months)."
      fi
    done
  done
done
