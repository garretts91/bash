#!/bin/bash 

# category can be anything? ip category,  cat 1, reputation 1, check suricata docs for categories and i think the reputation format
# https://docs.suricata.io/en/latest/reputation/ipreputation/ip-reputation-format.html
# .yaml -> local.rules (line 54) and mdl.list (line 979)

# *** maybe try to add the mdl.csv to ip.txt? this might remove the need for adding another file on gitlab
# mdl.csv #this is the mdl.list to use when the curl attempt fails
# ip addr, cat, rep score for the mdl.list
# mdl.csv will be outputted to mdl.list
# use this format
# 1,BadHosts,Known bad hosts
# 2,Google,Known google host

# Define file paths
LOCAL_MDL="ip.txt"      # Path to MDL file
IP_FILE="categories.txt" # File to store extracted IPs
OUTPUT_CSV="mdl.list"    # Final output CSV file

# Check if LOCAL_MDL exists
if [[ -f "$LOCAL_MDL" ]]; then
    # Extract only valid IP addresses from column 3, excluding loopback addresses
    awk -F, '{print $3}' "$LOCAL_MDL" | grep -oP '([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})' > "$IP_FILE"
    echo "IP addresses have been saved to $IP_FILE."
else
    echo "Error: $LOCAL_MDL not found."
    exit 1
fi

# Process the IP file to count occurrences, score them, and categorize
{
    # echo "ip,category,score" # Add CSV header to output file
    awk '{count[$1]++} END {for (ip in count) {
        if (ip == "127.0.0.1") continue
        score = count[ip] > 127 ? 127 : count[ip]     # Cap score at 127
        category = score >= 50 ? "BAD IP REPUTATION: High Confidence Alert" : "BAD IP REPUTATION: Low Confidence Alert"
        print ip "," category "," score
    }}' "$IP_FILE" > "$OUTPUT_CSV"
}

echo "Scored IP data has been saved to $OUTPUT_CSV."
