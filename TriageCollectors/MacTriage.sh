#!/bin/bash

# Title:            Mac OS Triage Collector
# Version:            1.0
# Author:            Gary Contreras (The Offensive Defender - 0x0D)
# Usage:            ./MacTriage.sh
# Description:        Use this to grab a forensic triage of a live Mac OS system
# Github:            https://github.com/TheOffensiveDefender/DFIRTools

# Variables to store important data
SCRIPTSTART=$(date -u +'%Y-%m-%dT%H%M%SZ')
OUTPUTDIR=/var/root/ForensicTriage
HASHDIR=${OUTPUTDIR}/hashes
SYSTEMINFO=${OUTPUTDIR}/systeminfo
PDPATH=${TOOLSDIR}/procdump.py
HOSTNAME=$(hostname)
ETCPATH=${OUTPUTDIR}/etc
VARPATH=${OUTPUTDIR}/var
ROOTPATH=${OUTPUTDIR}/var/root
USERPATH=${OUTPUTDIR}/Users
WWWPATH=${OUTPUTDIR}/var/www
LOGPATH=${OUTPUTDIR}/var/log
TMPPATH=${OUTPUTDIR}/tmp
LIBLOGS=${OUTPUTDIR}/library_logs

# Print script start time
printf "\n[*] Mac OS Triage script started at $(date -u +'%Y-%m-%d %H:%M:%S') Z on host \"${HOSTNAME}\"\n\n"

# Create the forensic triage output directory
printf "\n[*] Creating output directories...\n\n"
mkdir -p ${SYSTEMINFO}
mkdir -p ${HASHDIR}
mkdir -p ${ETCPATH}
mkdir -p ${ROOTPATH}
mkdir -p ${USERPATH}
mkdir -p ${TMPPATH}
mkdir -p ${VARPATH}
mkdir -p ${WWWPATH}
mkdir -p ${LOGPATH}
mkdir -p ${LIBLOGS}

# Enumerate various information using an order of volatility

printf "\n[*] Enumerating processes and network connections...\n\n"
ps -ef >> ${SYSTEMINFO}/ps.txt 2>> /dev/null
lsof >> ${SYSTEMINFO}/lsof.txt 2>> /dev/null

printf "\n[*] Enumerating network information...\n\n"
ifconfig >> ${SYSTEMINFO}/ifconfig.txt 2>> /dev/null
arp -a >> ${SYSTEMINFO}/arp.txt 2>> /dev/null
netstat -natup tcp >> ${SYSTEMINFO}/netstat.txt 2>> /dev/null
netstat -nr >> ${SYSTEMINFO}/routes.txt 2>> /dev/null

printf "\n[*] Enumerating user login information...\n\n"
w >> ${SYSTEMINFO}/w.txt 2>> /dev/null
who >> ${SYSTEMINFO}/who.txt 2>> /dev/null
id >> ${SYSTEMINFO}/id.txt 2>> /dev/null
last >> ${SYSTEMINFO}/last_logins.txt 2>> /dev/null

printf "\n[*] Enumerating operating system and environment...\n\n"
env >> ${SYSTEMINFO}/env.txt 2>> /dev/null
sudo -l >> ${SYSTEMINFO}/sudo.txt 2>> /dev/null
uname -a >> ${SYSTEMINFO}/uname.txt 2>> /dev/null
mount >> ${SYSTEMINFO}/mount.txt 2>> /dev/null

# Get the configs from the "/etc" folder as well as passwd/group/shadow files
printf "\n[*] Getting and hashing \"/etc\" files...\n\n"
find -E /etc -follow -type f -size -2M -iregex '.*(conf(ig)?|cfg|tab)$|/etc/(passwd|shadow|group|(host|issue).*|environment|net.*|profile|.*bashrc|services|timezone|sudoers|shells|.*cron.*)$' -exec tar -czf ${ETCPATH}/etc_configs.tar.gz {} + -exec shasum -a 256 {} + >> ${HASHDIR}/etc_hashes.txt 2> /dev/null

# Get any files in "/home" and "/tmp" that are executable and under 10 megabytes in size
printf "\n[*] Enumerating and hashing interesting executables...\n\n"
find -E /Users -type f -perm +111 -size -10M -not -iregex '.*(Library|Trash).*' -exec tar -czf ${USERPATH}/User_Executables.tar.gz {} + -exec shasum -a 256 {} + >> ${HASHDIR}/users_executable_hashes.txt 2> /dev/null
find -E /private/var/root -type f -perm +111 -size -10M -not -iregex '.*(Library|Trash).*' -exec tar -czf ${ROOTPATH}/Root_Executables.tar.gz {} + -exec shasum -a 256 {} + >> ${HASHDIR}/root_executable_hashes.txt 2> /dev/null
find /private/tmp -type f -perm +111 -size -10M -exec tar -czf ${TMPPATH}/Tmp_Executables.tar.gz {} + -exec shasum -a 256 {} + >> ${HASHDIR}/tmp_executable_hashes.txt 2> /dev/null

# Get any files in "/home", "/tmp", or "/var" that look interesting

printf "\n[*] Getting and hashing interesting files...\n\n"
find -E /tmp -follow -type f -size -2M -iregex '.*\.(c(pp)?|php|py|pl|exe)$' -exec tar -czf ${TMPPATH}/interesting_tmp_files.tar.gz {} + -exec shasum -a 256 {} + >> ${HASHDIR}/interesting_miscellaneous_hashes.txt 2> /dev/null
find -E /var/www -follow -type f -size -2M -iregex '.*\.(c(pp)?|php|py|pl|exe)$' -exec tar -czf ${WWWPATH}/interesting_web_files.targz {} + -exec shasum -a 256 {} + >> ${HASHDIR}/interesting_miscellaneous_hashes.txt 2> /dev/null
find -E /Users -follow -type f -size -2M -iregex '.*\.(c(pp)?|php|py|pl|exe)$' -not -iregex '.*(Trash|Library|venv).*'  -exec tar -czf ${USERPATH}/interesting_user_files.tar.gz {} + -exec shasum -a 256 {} + >> ${HASHDIR}/interesting_miscellaneous_hashes.txt 2> /dev/null
find -E /var/root -follow -type f -size -2M -iregex '.*\.(c(pp)?|php|py|pl|exe)$' -not -iregex '.*(Trash|Library|venv).*' -exec tar -czf ${ROOTPATH}/interesting_root_files.tar.gz {} + -exec shasum -a 256 {} + >> ${HASHDIR}/interesting_miscellaneous_hashes.txt 2> /dev/null

# Enumerate any zip file listings that may have been created for data exfiltration but DOES NOT actually retrieve them as these files may be large
printf "\n[*] Enumerating suspicious compressed files for possible data exfiltration...\n\n"
find -E /Users /var/root /tmp /opt /var/www -follow -not -iregex '.*Library.*' -iregex '.*\.(tar|gz|xz|bz|bzip2?|7z|zip)$' -mtime -30 -size -10M -ls >> ${SYSTEMINFO}/possible_exfiltration_last30days.txt 2>> /dev/null

# Get all of the relevant logs under "/var", "/Library", etc. and preserve the directory structure and critical attributes
printf "\n[*] Getting and hashing relevant logs...\n\n"
find /var/log /var/db/diagnostics /var/db/uuidtext -follow -type f -size -20M -exec tar -czf ${LOGPATH}/var_logs.tar.gz {} + -exec shasum -a 256 {} + >> ${HASHDIR}/var_hashes.txt 2> /dev/null
find /Library/Logs "/Library/Application Support" -follow -type f -size -20M -exec tar -czf ${LIBLOGS}/system_library_logs.tar.gz {} + -exec shasum -a 256 {} + >> ${HASHDIR}/system_library_log_hashes.txt 2> /dev/null
find -E /Users /var/root -follow -type f -iregex '/(Users/[^/]+|var/root)/Library/Logs.*' -size -20M -exec tar -czf ${LIBLOGS}/user_library_logs.tar.gz {} + -exec shasum -a 256 {} + >> ${HASHDIR}/user_library_log_hashes.txt 2> /dev/null

# Get all hidden user files
printf "\n[*] Getting and hashing user hidden files...\n\n"
find /Users -follow -type f -name ".*" -maxdepth 2 -exec tar -czf ${USERPATH}/hidden_user_files.tar.gz {} + -exec shasum -a 256 {} + >> ${HASHDIR}/user_hidden_files_hashes.txt 2> /dev/null
find /var/root -follow -type f -name ".*" -maxdepth 2 -exec tar -czf ${ROOTPATH}/hidden_root_files.tar.gz {} + -exec shasum -a 256 {} + >> ${HASHDIR}/user_hidden_files_hashes.txt 2> /dev/null

# Get authorized keys files from all users
printf "\n[*] Getting and hashing SSH authorized key files...\n\n"
find /etc /var/root /Users -follow -type f -name "authorized_keys" -exec tar -czf ${OUTPUTDIR}/authorized_ssh_keys.tar.gz {} + -exec shasum -a 256 {} + >> ${HASHDIR}/user_authorized_keys_hashes.txt 2> /dev/null

# Find SUID/GUID executables
printf "\n[*] Enumerating and hashing SUID/GUID executables...\n\n"
find /bin /usr /var /tmp /opt -follow -perm -g=s -type f -size -10M -exec shasum -a 256 {} + >> ${HASHDIR}/guid_executable_hashes.txt 2> /dev/null
find /bin /usr /var /tmp /opt -follow -perm -u=s -type f -size -10M -exec shasum -a 256 {} + >> ${HASHDIR}/suid_executable_hashes.txt 2> /dev/null

# Create a file stat to record file stats like permissions, ownership, and MACB timestamps
printf "\n[*] Preserving file stats prior to compression...\n\n"
find ${OUTPUTDIR} -follow -type f -exec stat {} + >> ${OUTPUTDIR}/file_stats.txt 2> /dev/null

# Delete empty files
printf "\n[*] Deleting empty files from triage collection...\n\n"
find ${OUTPUTDIR} -follow -type f -size 0 -ls >> ${OUTPUTDIR}/deleted_empty_triage_files.txt 2> /dev/null
find ${OUTPUTDIR} -follow -type f -size 0 -exec rm {} + 2> /dev/null

# Create a gzipped tar file of the resulting collection
OUTPUTZIP=/var/root/${SCRIPTSTART}_${HOSTNAME}_ForensicTriage.tar.gz
printf "\n[*] Creating ZIP file \"${OUTPUTZIP}\" and cleaning up directory \"${OUTPUTDIR}\"\n\n"
tar -czf ${OUTPUTZIP} ${OUTPUTDIR} && rm -rf ${OUTPUTDIR}

# Finish
printf "\n[*] Mac OS script finished at $(date -u +'%Y-%m-%d %H:%M:%S') Z\n\n"
printf "\n[*] Output file is at ${OUTPUTZIP}\n\n" 
