#!/bin/bash

# Configuration
declare -A PATH_CONFIG
#PATH_CONFIG["/var/www/aia/storage/logs"]="/var/app_logs/aia"
PATH_CONFIG["/var/www/bima/storage/logs"]="/var/app_logs/bima"
PATH_CONFIG["/var/www/ceylincolife/storage/logs"]="/var/app_logs/ceylincolife"
PATH_CONFIG["/var/www/janashakthi/storage/logs"]="/var/app_logs/janashakthi"
PATH_CONFIG["/var/www/lolc/storage/logs"]="/var/app_logs/lolc"
PATH_CONFIG["/var/www/directPayBackend/app/logs"]="/var/app_logs/directPayBackend"
#PATH_CONFIG["/var/www/ipg-backend/storage/logs"]="/var/app_logs/ipg-backend"

# Prefixes to match (add more as needed)
PREFIXES=("laravel" "info" "externalApi" "fileUpload")

# Get the current month and calculate the previous three months
CURRENT_MONTH=$(date +%Y-%m)
#CURRENT_MONTH=2024-10
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