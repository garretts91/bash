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
LOCAL_MDL="mdl.csv"      # Path to your local MDL file
IP_FILE="ip.txt"         # File to store extracted IPs
OUTPUT_CSV="local.rules" # Final output CSV file

# Check if LOCAL_MDL exists
if [[ -f "$LOCAL_MDL" ]]; then
    # Extract third column and save it to IP_FILE
    awk -F, '{print $3}' "$LOCAL_MDL" > "$IP_FILE"
    echo "IP addresses have been saved to $IP_FILE."
else
    echo "Error: $LOCAL_MDL not found."
    exit 1
fi

# Process the IP file to count occurrences, score them, and categorize
{
    echo "ip,category,score" # Add CSV header to output file
    awk '{count[$1]++} END {for (ip in count) {
        score = count[ip] > 127 ? 127 : count[ip]     # Cap score at 127
        category = score >= 50 ? "BAD IP REPUTATION: High Confidence Alert" : "BAD IP REPUTATION: Low Confidence Alert"
        print ip "," category "," score
    }}' "$IP_FILE" > "$OUTPUT_CSV"
}

echo "Scored IP data has been saved to $OUTPUT_CSV."
