#!/bin/bash
#
# A bash script to inspect various log files on a Linux system
#
# Garrett Solomon
# January 12, 2024
#
# TODO: Check for multiple arguments
#
# Usage: log_analyzer.sh [OPTIONS] LOG_FILE
# Options:
#   -u, --user USER       Analyze logs for a specific user.
#   -d, --date DATE       Analyze logs for a specific date or date range (e.x. "2024-01-10" or "2024-01-10:2024-01-12").
#   -p, --pattern PATTERN Analyze logs for a specific pattern (e.x. "error").
#   -h, --help            Display this usage message.

# Function to print usage information and exit with an error code.
usage() {
  echo "Usage: $0 [OPTIONS] LOG_FILE"
  echo "Options:"
  echo "  -u, --user USER       Analyze logs for a specific user."
  echo "  -d, --date DATE       Analyze logs for a specific date or date range (e.x. \"2024-01-10\" or \"2024-01-10:2024-01-12\")."
  echo "  -p, --pattern PATTERN Analyze logs for a specific pattern (e.x. \"error\")."
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
    -p|--pattern)
      shift
      PATTERN="$1"
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
  local PATTERN="$4"

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
    # Check if it's a single day or date range
    if [[ "$DATE" == *":"* ]]; then
      # Date range analysis
      START_DATE=$(echo "$DATE" | cut -d':' -f1)
      END_DATE=$(echo "$DATE" | cut -d':' -f2)
      DATE_COUNT=$(awk -v start="$START_DATE" -v end="$END_DATE" '$0 >= start && $0 <= end' "$LOG_FILE" | wc -l)
      echo "Between $START_DATE and $END_DATE, there were $DATE_COUNT log entries."
    else
      # Single day analysis
      DATE_COUNT=$(grep -c "$DATE" "$LOG_FILE")
      echo "On $DATE, there were $DATE_COUNT log entries."
    fi
  fi

  if [ -n "$PATTERN" ]; then
    echo "Lines matching the pattern '$PATTERN':"
    grep -i "$PATTERN" "$LOG_FILE" | sed 's/^.*'"$PATTERN"'/\1/'
  fi
}

# Main script execution
analyze_log "$LOG_FILE" "$USER" "$DATE" "$PATTERN"
exit 0