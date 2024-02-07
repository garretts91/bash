#!/bin/bash

# Change directory to /proc
cd /proc || { echo "Failed to change directory to /proc"; exit 1; }

# Display help information
display_help() {
  echo "Process Manager"
  echo "Usage: $0 [options]"
  echo "Options:"
  echo "  -h                      Display this help message."
  echo "  -u <username>           Filter processes by username."
  echo "  -d <directory>          Filter processes launched from a directory."
  echo "  --list                  Create an ongoing list of all process names used on the system."
  echo "  --zombies               Display zombie processes."
  echo "  -l <directory_pattern>  Filter processes launched from a particular directory or directory tree."
}

# Parse /proc to get process information
get_process_info() {
  if [ -n "$directory" ]; then
    # Display processes launched from the specified directory
    echo "Listing processes launched from directory: $directory"
    ps aux | awk -v dir="$directory" '$NF ~ dir {print $0}'
  fi

  if [ -n "$directory_pattern" ]; then
    # Display processes launched from directories matching the specified pattern
    echo "Listing processes launched from directories matching pattern: $directory_pattern"
    if [ -n "$directory" ]; then
      # If both -d and -l options are provided, ignore -d and only consider -l
      ps aux | grep -E "^\S+\s+\S+\s+[^ ]+$directory_pattern"
    else
      ps aux | grep -E "^\S+\s+\S+\s+[^ ]+$directory_pattern"
    fi
  fi
}

# Check if no arguments are provided or if -h/--help option is provided
if [[ "$#" -eq 0 || "$1" == "-h" || "$1" == "--help" ]]; then
  display_help
  exit 0
fi

# Initialize variables
directory=""
directory_pattern=""

# Process command-line arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    -u) username="$2"; shift ;;
    -d) directory="$2"; shift ;;
    -l) directory_pattern="$2"; shift ;;
    --list) list_processes=true ;;
    --zombies) get_process_info; exit 0 ;;  # Display zombie processes and exit
    *) echo "Unknown option: $1" >&2; display_help; exit 1 ;;
  esac
  shift
done

# Example logic to use variables set from command-line arguments
if [ ! -z "$username" ]; then
  echo "Filtering processes by username: $username"
  # Add logic to filter processes by username
fi

if [ ! -z "$directory" ]; then
  echo "Filtering processes launched from: $directory"
  # Add logic to filter processes by directory
fi

if [ "$list_processes" = true ]; then
  echo "Listing all process names..."
  # Add logic to list all process names
fi

# Placeholder for actual logic to parse and display processes based on criteria
get_process_info
