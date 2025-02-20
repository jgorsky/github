#!/bin/bash

# Ask for the directory containing the files
echo "Enter the directory containing the files to be deleted: "
read TARGET_DIR

# Confirm the directory with the user
echo "You entered: $TARGET_DIR. Is this correct? (y/n)"
read CONFIRM_DIR
if [[ "$CONFIRM_DIR" != "y" ]]; then
    echo "Operation cancelled."
    exit 1
fi

# Check if the directory exists
if [[ ! -d "$TARGET_DIR" ]]; then
    echo "Error: Directory $TARGET_DIR not found!"
    exit 1
fi

# Check if the file list exists
FILE_LIST="file_list.txt"
if [[ ! -f "$FILE_LIST" ]]; then
    echo "Error: $FILE_LIST not found!"
    exit 1
fi

# Log files
LOG_FILE="deletion_log.txt"
FILES_TO_DELETE="files_to_delete.txt"
FILES_NOT_FOUND="files_not_found.txt"
FILES_NOT_DELETED="files_not_deleted.txt"
FILES_NOT_IN_LIST="files_not_in_list.txt"
ALL_FILES_IN_DIR="all_files_in_directory.txt"
echo "Deletion Log - $(date)" > "$LOG_FILE"
echo "Files to be deleted:" > "$FILES_TO_DELETE"
echo "Files not found:" > "$FILES_NOT_FOUND"
echo "Files not deleted:" > "$FILES_NOT_DELETED"
echo "Files in directory but not in delete list:" > "$FILES_NOT_IN_LIST"
ls "$TARGET_DIR" > "$ALL_FILES_IN_DIR"

echo -e "Checking files in the specified directory... \n"

# List files to be deleted and check existence
echo -e "The following files will be deleted: \n"
while IFS= read -r file; do
    FILE_PATH="$TARGET_DIR/$file"
    if [[ -f "$FILE_PATH" ]]; then
        echo "$FILE_PATH" | tee -a "$FILES_TO_DELETE"
    else
        echo "$FILE_PATH" | tee -a "$FILES_NOT_FOUND"
    fi
done < "$FILE_LIST"

# Identify files in the directory that are not in the delete list
comm -23 <(sort "$ALL_FILES_IN_DIR") <(sort "$FILE_LIST") > "$FILES_NOT_IN_LIST"

echo -e "Files to be deleted: \n" && cat "$FILES_TO_DELETE"
echo -e "Files not found: \n" && cat "$FILES_NOT_FOUND"
echo -e "Files in directory that will not be deleted: \n" && cat "$FILES_NOT_IN_LIST"

echo "Do you want to proceed? (y/n)"
read CONFIRM_DELETE
if [[ "$CONFIRM_DELETE" != "y" ]]; then
    echo "Operation cancelled."
    exit 1
fi

# Delete files
while IFS= read -r file; do
    FILE_PATH="$TARGET_DIR/$file"
    if [[ -f "$FILE_PATH" ]]; then
        if rm "$FILE_PATH"; then
            echo "Deleted: $FILE_PATH" | tee -a "$LOG_FILE"
        else
            echo "$FILE_PATH" | tee -a "$FILES_NOT_DELETED"
        fi
    else
        echo "File not found: $FILE_PATH" | tee -a "$LOG_FILE"
    fi
done < "$FILE_LIST"

echo "Files not deleted:" && cat "$FILES_NOT_DELETED"
echo "Deletion process completed. Log saved in $LOG_FILE"

