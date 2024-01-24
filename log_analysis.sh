#!/bin/bash
#
# A bash script to inspect various log files on a Linux system
#
# Author: Garrett Solomon
# Date: 12 January 2024
#
# Usage: log_analyzer.sh [OPTIONS] LOG_FILE
# Options:
#   -u, --user USER       Analyze logs for a specific user.
#   -d, --date DATE       Analyze logs for a specific date.
#   -h, --help            Display this usage message.

# Function to print usage information and exit with an error code.
usage() {
  echo "Usage: $0 [OPTIONS] LOG_FILE"
  echo "Options:"
  echo "  -u, --user USER       Analyze logs for a specific user."
  echo "  -d, --date DATE       Analyze logs for a specific date."
  echo "  -h, --help            Display this usage message."
  exit 1
}

# Validate inputs and set default values
while [[ $# -gt 0 ]]; do
  case "$1" in
    -u|--user)
      shift
      USER="$1"
      ;;
    -d|--date)
      shift
      DATE="$1"
      ;;
    -h|--help)
      usage
      ;;
    *)
      LOG_FILE="$1"
      ;;
  esac
  shift
done

# Check if the required log file is provided
if [ -z "$LOG_FILE" ]; then
  echo "Error: Please provide a log file."
  usage
fi

# Function to analyze log file
analyze_log() {
  local LOG_FILE="$1"
  local USER="$2"
  local DATE="$3"

  # Check if the log file exists
  if [ ! -f "$LOG_FILE" ]; then
    echo "Error: Log file not found - $LOG_FILE" >&2
    exit 1
  fi

  # Analyze log based on provided options
  if [ -n "$USER" ]; then
    USER_COUNT=$(grep -c "$USER" "$LOG_FILE")
    echo "User $USER accessed the system $USER_COUNT times."
  fi

  if [ -n "$DATE" ]; then
    DATE_COUNT=$(grep -c "$DATE" "$LOG_FILE")
    echo "On $DATE, there were $DATE_COUNT log entries."
  fi

}

# Main script execution
analyze_log "$LOG_FILE" "$USER" "$DATE"
exit 0
