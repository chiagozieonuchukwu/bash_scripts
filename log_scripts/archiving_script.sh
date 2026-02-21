#!/usr/bin/env bash

#Variable declarations
DIRECTORY=$1
DAYS=$2
SCRIPT_LOG="progress.log"

#Check input and confirm syntax is correct
if [[ -z "$DIRECTORY" || -z "$DAYS" ]];
then
    echo "usage: $0 <log directory> <no of days>"
    exit 1
fi
if [[ ! -d "$DIRECTORY" ]];
then
    echo "Error: Directory $DIRECTORY does not exist."
    exit 1
fi

#create a function to update the user on the screen while logging the progress to a file
log_progress() {
    echo "$(date) - $1" | tee -a "$SCRIPT_LOG"
}

# Search for the files to be archived and deleted
if [[ "$DAYS" -eq 0 ]]; then
    mapfile -t FILES < <(find "$DIRECTORY" -type f -name "*.log")
else
    mapfile -t FILES < <(find "$DIRECTORY" -type f -name "*.log" -mtime +$((DAYS-1)))
fi


# Conditional statements to check if files meet this criteria or not
if [[ -z "$FILES" ]];
then
    log_progress "No files older than $DAYS days found in $DIRECTORY."
    exit 0
else
    echo "Select files to archive/delete:"

	for i in "${!FILES[@]}"; do
    		echo "$((i+1))) ${FILES[$i]}"
	done

fi

# Show the user and ask for confirmation before proceeding
read -p "Enter numbers separated by space: " CHOICES

SELECTED_FILES=()

for num in $CHOICES; do
    index=$((num-1))
    SELECTED_FILES+=("${FILES[$index]}")
done

read -p "Are you sure you want to archive and delete these files? (y/n): " CONFIRM
if [[ "$CONFIRM" != "y" ]];
then
    log_progress "Operation cancelled by user."
    exit 0
fi

# Archive the files
ARCHIVE="archived_files_$(date).tar.gz"
tar -czf "$ARCHIVE" $SELECTED_FILES
if [[ $? -ne 0 ]];
then
    log_progress "Error: Failed to create archive."
    exit 1
fi
log_progress "Successfully created archive $ARCHIVE."

# Delete the original files
rm -f $SELECTED_FILES
log_progress "Successfully deleted old files."#!/bin/bash

