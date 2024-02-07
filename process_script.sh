#!/bin/bash

# Change directory to /proc
cd /proc || { echo "Failed to change directory to /proc"; exit 1; }

# Display help information
display_help() {
  echo "Process Manager"
  echo "Usage: $0 [options]"
  echo "Options:"
  echo "  -h                      Display this help message."
  echo "  --zombies               Display zombie processes."
  echo "  -c <comparison>         Compare processes based on runtime, memory, PID, or priority."
  echo "  -top2                   Display the top two processes based on the specified comparison."
  echo "  -bottom2                Display the bottom two processes based on the specified comparison."
  echo "  -adjacency              Display processes in adjacent or nearly adjacent memory locations."
}

# Function to check for zombie processes
# TODO: Zombie Killer Function
check_zombies() {
  zombie_count=$(grep -l '^State:\s*.*\(Z\|z\)' */status | wc -l)
  if [[ $zombie_count -gt 0 ]]; then
    echo "Zombie processes found."
    return 0
  else
    echo "No zombie processes found."
    return 1
  fi
}

# Function to compare processes
compare_processes() {
  local comparison="$1"
  local top_two=false
  local bottom_two=false
  local adjacency=false  # Flag to indicate whether to display adjacent/nearby processes

  # Parse additional flags
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -top2)
        top_two=true
        ;;
      -bottom2)
        bottom_two=true
        ;;
      -adjacency)
        adjacency=true
        ;;
    esac
    shift
  done

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
        rss)
          # Get memory size (Resident Set Size)
          rss=$(awk '/VmRSS/ {print $2}' "$pid/status")
          process_attributes["$pid"]=$rss
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
        address)
          # Get memory address
          address=$(awk '{print $34}' "$pid/stat")
          process_attributes["$pid"]=$address
          ;;
      esac
    fi
  done < <(ls -d [0-9]*)

  # Sort the processes based on the chosen attribute
  sorted_pids=($(printf "%s\n" "${!process_attributes[@]}" | sort -n -k2))

  # Determine the number of processes to display
  num_processes=${#sorted_pids[@]}
  if [[ $top_two == true ]]; then
    num_processes=2
  elif [[ $bottom_two == true ]]; then
    num_processes=2
  fi

  # Display processes based on the specified comparison
  if [[ $num_processes -gt 1 ]]; then
    if [[ $top_two == true ]]; then
      echo "Top two processes based on $comparison:"
    elif [[ $bottom_two == true ]]; then
      echo "Bottom two processes based on $comparison:"
      sorted_pids=($(printf "%s\n" "${sorted_pids[@]}" | tac))
    fi

    for ((i = 0; i < num_processes; i++)); do
      pid="${sorted_pids[$i]}"
      attribute_value="${process_attributes[$pid]}"
      echo "PID $pid: $comparison $attribute_value"
    done
  elif [[ $adjacency == true ]]; then
    # Display adjacent or nearly adjacent processes based on memory address
    echo "Processes in adjacent or nearly adjacent memory locations:"
    previous_address=""
    for pid in "${sorted_pids[@]}"; do
      current_address="${process_attributes[$pid]}"
      # Modify adjacency value here:
      if [[ ! -z "$previous_address" && $((current_address - previous_address)) -lt 500 ]]; then
        echo "PID $pid: Address $current_address"
        echo "PID $(($pid - 1)): Address $previous_address"
      fi
      previous_address="$current_address"
    done
  else
    echo "Insufficient processes for comparison."
  fi
}

# Function to get key by value from an associative array
array_get_key_by_value() {
  local value="$1"
  shift
  local array=("$@")
  for key in "${!array[@]}"; do
    if [[ "${array[$key]}" == "$value" ]]; then
      echo "$key"
      return
    fi
  done
}

# Check if no arguments are provided, print help
if [[ $# -eq 0 ]]; then
  display_help
  exit 0
fi

# Loop through arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h)
      display_help
      ;;
    --zombies)
      check_zombies
      shift
      ;;
    -c)
      # Compare processes based on runtime, memory size, PID, or priority
      comparison="$2"
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