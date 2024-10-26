#!/bin/bash 

# category can be anything? ip category,  cat 1, reputation 1, check suricata docs for categories and i think the reputation format
# https://docs.suricata.io/en/latest/reputation/ipreputation/ip-reputation-format.html
# bash script is really short, he used pipes and awk to parse the file and made a counter
# defined a couple variables, thats it
# 1. no need to curl. use the mdl.csv
# 2. output the mdl.csv to the mdl.list
# 3. no cron job
# 4. strip the mdl.csv (using awk), then take the ip.txt and run it against the mdl.csv
# ip.txt is not needed, its just a stripped down version of the mdl.csv
# iterate over the mdl to get the # of hits, how many times do they occur
# - make a counter
# - you need to cap it at like 127
# 5. pull up the suricata docs, section on reputation, should tell you exactly how to format it
# local.rules in the suricata
# - slight modifications to the .yaml, a little uncommenting
# - you shouldnt have to mess with file paths
# It will need to point to local.rules as well as the iprep file -> iprep file should be the mdl.csv
# alerts: low confidence, high confidence
# .yaml -> local.rules (line 54) and mdl.list (line 979)

# *** maybe try to add the mdl.csv to ip.txt? this might remove the need for adding another file on gitlab
# mdl.csv #this is the mdl.list to use when the curl attempt fails
# ip addr, cat, rep score for the mdl.list
# mdl.csv will be outputted to mdl.list
# use this format
# 1,BadHosts,Known bad hosts
# 2,Google,Known google host


