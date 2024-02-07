#!/bin/bash

# Change directory to /proc
cd /proc || { echo "Failed to change directory to /proc"; exit 1; }

# Function to display help information
display_help() {
  echo "Process Manager"
  echo "Usage: $0 [options]"
  echo "Options:"
  echo "  -h                      Display this help message."
  echo "  -z                      Display zombie processes."
  echo "  -c <comparison>         Compare processes based on runtime, memory, PID, or priority and display the top two and bottom two processes."
}

# Function to check for zombie processes
check_zombies() {
  zombie_count=$(grep -l '^State:\s*.*\(Z\|z\)' */status | wc -l)
  if [[ $zombie_count -gt 0 ]]; then
    echo "Zombie processes found."
  else
    echo "No zombie processes found."
  fi
}

# Function to compare processes
compare_processes() {
  local comparison="$1"
  local top_two=()
  local bottom_two=()

  # Get attribute values for all processes
  declare -A process_attributes
  while read -r pid; do
    if [[ -e "$pid/stat" && -e "$pid/status" ]]; then
      case "$comparison" in
        runtime)
          # Get process start time
          start_time=$(awk '{print $22}' "$pid/stat")
          process_attributes["$pid"]=$start_time
          ;;
        memory)
          # Get memory size (Resident Set Size)
          rss=$(awk '/VmRSS/ {print $2}' "$pid/status")
          # Handle case where memory information is missing or empty
          if [[ -n $rss ]]; then
            process_attributes["$pid"]=$rss
          else
            process_attributes["$pid"]="N/A"
          fi
          ;;
        pid)
          # PID
          process_attributes["$pid"]=$pid
          ;;
        priority)
          # Get process priority
          priority=$(awk '{print $18}' "$pid/stat")
          process_attributes["$pid"]=$priority
          ;;
      esac
    fi
  done < <(ls -d [0-9]*)

  # Sort the processes based on the chosen attribute
  sorted_pids=($(printf "%s\n" "${!process_attributes[@]}" | sort -n -k2))

  # Populate top two and bottom two processes
  for ((i = 0; i < 2 && i < ${#sorted_pids[@]}; i++)); do
    top_two+=("${sorted_pids[$i]}")
  done
  for ((i = ${#sorted_pids[@]} - 1; i >= ${#sorted_pids[@]} - 2 && i >= 0; i--)); do
    bottom_two+=("${sorted_pids[$i]}")
  done

  # Display the top two and bottom two processes
  echo "Top two processes based on $comparison:"
  for pid in "${top_two[@]}"; do
    memory="${process_attributes[$pid]}"
    if [[ -n $memory ]]; then
      echo "PID $pid: $comparison $memory"
    else
      echo "PID $pid: $comparison N/A"
    fi
  done
  echo "Bottom two processes based on $comparison:"
  for pid in "${bottom_two[@]}"; do
    echo "PID $pid: $comparison ${process_attributes[$pid]}"
  done
  echo "Total number of processes: ${#sorted_pids[@]}"
}

# Main script

# Check if no arguments are provided, print help
if [[ $# -eq 0 ]]; then
  display_help
  exit 0
fi

# Process options
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h)
      display_help
      exit 0
      ;;
    -z)
      check_zombies
      exit 0
      ;;
    -c)
      shift
      comparison="$1"
      compare_processes "$comparison"
      exit 0
      ;;
    *)
      echo "Invalid option: $1"
      display_help
      exit 1
      ;;
  esac
  shift
done
