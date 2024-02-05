#!/bin/bash

# Title:			Mac OS Triage Collector
# Version:			1.1.1
# Author:			Gary Contreras (The Offensive Defender - 0x0D)
# Usage:			./MacTriage.sh
# Description:		Use this to grab a forensic triage of a live Mac OS system
# Github:			https://github.com/TheOffensiveDefender/DFIRTools

# Variables to store important data
SCRIPTSTART=$(date -u +'%Y-%m-%dT%H%M%SZ')
OUTPUTDIR=/var/root/ForensicTriage
HASHDIR=${OUTPUTDIR}/hashes
SYSTEMINFO=${OUTPUTDIR}/systeminfo
HOSTNAME=$(hostname)
ETCPATH=${OUTPUTDIR}/etc
VARPATH=${OUTPUTDIR}/var
ROOTPATH=${OUTPUTDIR}/var/root
USERPATH=${OUTPUTDIR}/Users
WWWPATH=${OUTPUTDIR}/var/www
LOGPATH=${OUTPUTDIR}/var/log
TMPPATH=${OUTPUTDIR}/tmp
LIBLOGS=${OUTPUTDIR}/library_logs
APPPATH=${OUTPUTDIR}/applications

# Print script start time
printf "\n[*] Mac OS Triage script started at $(date -u +'%Y-%m-%d %H:%M:%S') Z on host \"${HOSTNAME}\"\n"

# Create the forensic triage output directory
printf "\n[*] Creating output directories...\n"
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
mkdir -p ${APPPATH}

# Enumerate various information using an order of volatility

printf "\n[*] Enumerating processes and network connections...\n"
ps -ef >> ${SYSTEMINFO}/ps.txt 2>> /dev/null
lsof >> ${SYSTEMINFO}/lsof.txt 2>> /dev/null

printf "\n[*] Enumerating network information...\n"
ifconfig >> ${SYSTEMINFO}/ifconfig.txt 2>> /dev/null
arp -a >> ${SYSTEMINFO}/arp.txt 2>> /dev/null
netstat -natup tcp >> ${SYSTEMINFO}/netstat.txt 2>> /dev/null
netstat -nr >> ${SYSTEMINFO}/routes.txt 2>> /dev/null

printf "\n[*] Enumerating user login information...\n"
w >> ${SYSTEMINFO}/w.txt 2>> /dev/null
who >> ${SYSTEMINFO}/who.txt 2>> /dev/null
id >> ${SYSTEMINFO}/id.txt 2>> /dev/null
last >> ${SYSTEMINFO}/last_logins.txt 2>> /dev/null

printf "\n[*] Enumerating operating system and environment...\n"
env >> ${SYSTEMINFO}/env.txt 2>> /dev/null
sudo -l >> ${SYSTEMINFO}/sudo.txt 2>> /dev/null
uname -a >> ${SYSTEMINFO}/uname.txt 2>> /dev/null
mount >> ${SYSTEMINFO}/mount.txt 2>> /dev/null

# Get the configs from the "/etc" folder as well as passwd/group/shadow/cron files
printf "\n[*] Getting and hashing \"/etc\" files...\n"
find -E /etc -follow -type f -size -2M -iregex '.*(conf(ig)?|cfg|tab|\.local)$|/etc/(passwd|shadow|group|localtime|hosts|(host|issue).*|environment|net.*|profile|.*bashrc|services|timezone|sudoers|shells|.*(cron|daily|weekly|monthly|periodic).*)$' -exec tar -czf ${ETCPATH}/etc_configs.tar.gz {} + -exec shasum -a 256 {} + >> ${HASHDIR}/etc_hashes.txt 2> /dev/null
find /usr/lib/cron/tabs /usr/local/etc/periodic /usr/lib/cron/jobs -follow -type f -size -2M -exec tar -czf ${ETCPATH}/cron.tar.gz {} + -exec shasum -a 256 {} + >> ${HASHDIR}/cron_hashes.txt 2> /dev/null

# ==============================================================
# Get browser data
# ==============================================================
# Safari
printf "\n[*] Getting Safari browser data...\n"
find -E /var/root /Users -type f -iregex '/Users/[^/]+/Library/(Cookies/Cookies\.binarycookies$|Safari/(downloads\.plist|LastSession\.plist|history\.db|cloudtabs\.db)$|Containers/com\.apple\.safari/Data/Library/Caches/com\.apple\.safari/(|cache\.db$|(tabsnapshots|webkitcache/version../).*)' -exec tar -czf ${LIBLOGS}/safari_data.tar.gz {} + 2> /dev/null
# Chrome / Firefox
printf "\n[*] Getting Firefox/Chrome browser data...\n"
find -E /var/root /Users -type f -iregex '/Users/[^/]+/Library/Application Support/(Google|Firefox)/(Chrome/Default|Profiles).*' -exec tar -czf ${USERPATH}/chrome_firefox_data.tar.gz {} + 2> /dev/null

# ==============================================================
# Get Apple mailbox data
# ==============================================================
printf "\n[*] Getting Apple mailbox data...\n"
find -E /Users /var/root -type f -iregex '/Users/[^/]+/Library/(Containers/com\.apple\.mail/.*|Mail( Downloads/.*|/V./(Maildata/Envelope Index/.*|[^/]+/.*\.mbox$)))' -exec tar -czf ${USERPATH}/apple_mailbox_data.tar.gz {} + 2> /dev/null

# ==============================================================
# Get USB Usage
# ==============================================================
printf "\n[*] Getting USB usage data...\n"
find -E /Users /var/root -type f -iregex '/Users/[^/]+/Library/(Preferences/com\.apple\.finder\.plist|application support/com\.apple\.sharedfilelist/com\.apple\.LSSharedFileList\.FavoriteVolumes\.sfl2)$' -exec tar -czf ${USERPATH}/usb_usage.tar.gz {} + 2> /dev/null

# ==============================================================
# Account Usage
# ==============================================================
printf "\n[*] Getting account usage data...\n"
find -E /Library/Preferences -type f -iregex '.*com\.apple\.loginwindow\.plist$' -exec tar -czf ${LIBLOGS}/account_usage.tar.gz {} + 2> /dev/null

# ==============================================================
# iCloud Documents
# ==============================================================
printf "\n[*] Getting iCloud documents...\n"
find -E /Users -type f -iregex '/Users/[^/]+/Library/Mobile Documents/.*' -exec tar -czf ${USERPATH}/icloud_logs.tar.gz {} + 2> /dev/null

# Get any files in "/home" and "/tmp" that are executable and under 10 megabytes in size
printf "\n[*] Enumerating and hashing interesting executables...\n"
find -E /Users -type f -perm +111 -size -10M -not -iregex '.*(Library|Trash).*' -exec tar -czf ${USERPATH}/User_Executables.tar.gz {} + -exec shasum -a 256 {} + >> ${HASHDIR}/users_executable_hashes.txt 2> /dev/null
find -E /private/var/root -type f -perm +111 -size -10M -not -iregex '.*(Library|Trash).*' -exec tar -czf ${ROOTPATH}/Root_Executables.tar.gz {} + -exec shasum -a 256 {} + >> ${HASHDIR}/root_executable_hashes.txt 2> /dev/null
find /private/tmp -type f -perm +111 -size -10M -exec tar -czf ${TMPPATH}/Tmp_Executables.tar.gz {} + -exec shasum -a 256 {} + >> ${HASHDIR}/tmp_executable_hashes.txt 2> /dev/null

# Get any files in "/home", "/tmp", or "/var" that look interesting
printf "\n[*] Getting and hashing interesting files...\n"
find -E /tmp -follow -type f -size -2M -iregex '.*\.(c(pp)?|php|py|pl|exe)$' -exec tar -czf ${TMPPATH}/interesting_tmp_files.tar.gz {} + -exec shasum -a 256 {} + >> ${HASHDIR}/interesting_miscellaneous_hashes.txt 2> /dev/null
find -E /var/www -follow -type f -size -2M -iregex '.*\.(c(pp)?|php|py|pl|exe)$' -exec tar -czf ${WWWPATH}/interesting_web_files.targz {} + -exec shasum -a 256 {} + >> ${HASHDIR}/interesting_miscellaneous_hashes.txt 2> /dev/null
find -E /Users -follow -type f -size -2M -iregex '.*\.(c(pp)?|php|py|pl|exe)$' -not -iregex '.*(Trash|Library|venv).*'  -exec tar -czf ${USERPATH}/interesting_user_files.tar.gz {} + -exec shasum -a 256 {} + >> ${HASHDIR}/interesting_miscellaneous_hashes.txt 2> /dev/null
find -E /var/root -follow -type f -size -2M -iregex '.*\.(c(pp)?|php|py|pl|exe)$' -not -iregex '.*(Trash|Library|venv).*' -exec tar -czf ${ROOTPATH}/interesting_root_files.tar.gz {} + -exec shasum -a 256 {} + >> ${HASHDIR}/interesting_miscellaneous_hashes.txt 2> /dev/null

# Enumerate any zip file listings that may have been created for data exfiltration but DOES NOT actually retrieve them as these files may be large
printf "\n[*] Enumerating suspicious compressed files for possible data exfiltration...\n"
find -E /Users /var/root /tmp /opt /var/www -follow -not -iregex '.*Library.*' -iregex '.*\.(tar|gz|xz|bz|bzip2?|7z|zip)$' -mtime -30 -size -10M -ls >> ${SYSTEMINFO}/possible_exfiltration_last30days.txt 2>> /dev/null

# Get all of the relevant logs under "/var", "/Library", etc. and preserve the directory structure and critical attributes
printf "\n[*] Getting and hashing relevant logs...\n"
find /var/log /var/db/diagnostics /var/db/uuidtext /var/vm /var/run /var/audit -follow -type f -size -20M -exec tar -czf ${LOGPATH}/var_logs.tar.gz {} + -exec shasum -a 256 {} + >> ${HASHDIR}/var_hashes.txt 2> /dev/null
find /Libary/Logs -type f -size -20M -exec tar -czf ${LIBLOGS}/Library_System_Logs.tar.gz {} + 2> /dev/null
find -E /Library -type f -size -20M -iregex '.*\.(plist|dat|db)$' -exec tar -czf ${LIBLOGS}/library_plist_dat_db_files.tar.gz {} + 2> /dev/null
find /System/Library/LaunchAgents /Library/LaunchAgents -type f -exec tar -czf ${LIBLOGS}/persistence_system_launchagents.tar.gz {} + 2> /dev/null
find /System/Library/LaunchDaemons /Library/LaunchDaemons -type f -exec tar -czf ${LIBLOGS}/persistence_system_launchdaemons.tar.gz {} + 2> /dev/null
find -E /Users -type f -size -20M -iregex '.*/LaunchAgents/.*\.plist$|.*(knowledgeC\.db|\.history)$|/Users/[^/]+/Library/Containers/com\.apple\.corerecents\.recentsd/Data/Library/Recents/Recents' -exec tar -czf ${LIBLOGS}/persistence_user_launchagents.tar.gz {} + 2> /dev/null
find /Library/StartupItems /System/Library/StartupItems -type f -size -20M -exec tar -czf ${LIBLOGS}/persistence_system_startupitems.tar.gz {} + 2> /dev/null
find /Library/Preferences -type f -size -20M -exec tar -czf ${LIBLOGS}/system_application_preferences.tar.gz {} + 2> /dev/null
find -E "/Library/Application Support" -iregex '.*\.(apple|cache|cfg|conf|config|cud|cvd|dat|data|data-shm|data-wal|db|db-shm|db-wal|deployment|dylib|identity|jmf_settings|keychain|ldb|log|login|old|pem|pid|plist|properties|pst|results|rules|sh|sst|token|txt|xml|yar|[0-9])$' -type f -size -5M -exec tar -czf ${APPPATH}/system_applicationsupport.tar.gz {} + 2> /dev/null
find -E /Users /var/root -follow -type f -iregex '/(Users/[^/]+|var/root)/Library/(Logs|Caches|Mail|Containers|Preferences|Safari|Keychains|Accounts|LaunchAgents).*' -iregex '.*\.(apple|cache|cfg|conf|config|cud|cvd|dat|data|data-shm|data-wal|db|db-shm|db-wal|deployment|dylib|identity|jmf_settings|keychain|ldb|log|login|old|pem|pid|plist|properties|pst|results|rules|sh|sst|token|txt|xml|yar|[0-9])$' -size -20M -exec tar -czf ${USERPATH}/user_library_logs.tar.gz {} + 2> /dev/null

# Get all hidden user files
printf "\n[*] Getting and hashing user hidden files...\n"
find /Users -follow -type f -name ".*" -maxdepth 2 -exec tar -czf ${USERPATH}/hidden_user_files.tar.gz {} + -exec shasum -a 256 {} + >> ${HASHDIR}/user_hidden_files_hashes.txt 2> /dev/null
find /var/root -follow -type f -name ".*" -maxdepth 2 -exec tar -czf ${ROOTPATH}/hidden_root_files.tar.gz {} + -exec shasum -a 256 {} + >> ${HASHDIR}/user_hidden_files_hashes.txt 2> /dev/null

# Get "/Application" files
printf "\n[*] Getting and hashing "/Applications" files...\n"
find -E /Applications -type f -size -10M -iregex '.*\.(plist|db|dat))$' -exec tar -czf ${APPPATH}/applications.tar.gz {} + -exec shasum -a 256 {} + >> ${HASHDIR}/appliciations_file_hashes.txt 2> /dev/null
find -E /Applications -type f -size -10M -iregex '/Applications/[^.]+\.app/Contents/Library/LoginItems/.*' -exec tar -czf ${APPPATH}/persistence_applications_loginitems.tar.gz 2> /dev/null
find -E /Users -type f -size -10M -iregex '/Users/[^/]+/Library/ApplicationSupport/com\.apple\.backgroundtaskmanagementagent/backgrounditems\.btm' -exec tar -czf ${USERPATH}/persistence_user_backgrounditems.tar.gz {} + 2> /dev/null

# Get authorized keys files from all users
printf "\n[*] Getting and hashing SSH authorized key files...\n"
find /etc /var/root /Users -follow -type f -name "(known|authorized)_hosts" -exec tar -czf ${OUTPUTDIR}/authorized_ssh_hosts.tar.gz {} + -exec shasum -a 256 {} + >> ${HASHDIR}/user_authorized_hosts_hashes.txt 2> /dev/null

# Find SUID/GUID executables
printf "\n[*] Enumerating and hashing SUID/GUID executables...\n"
find /bin /usr /var /tmp /opt -follow -perm -g=s -type f -size -10M -exec shasum -a 256 {} + >> ${HASHDIR}/guid_executable_hashes.txt 2> /dev/null
find /bin /usr /var /tmp /opt -follow -perm -u=s -type f -size -10M -exec shasum -a 256 {} + >> ${HASHDIR}/suid_executable_hashes.txt 2> /dev/null

# Create a file stat to record file stats like permissions, ownership, and MACB timestamps
printf "\n[*] Preserving file stats prior to compression...\n"
find ${OUTPUTDIR} -follow -type f -exec stat {} + >> ${OUTPUTDIR}/file_stats.txt 2> /dev/null

# Delete empty files
printf "\n[*] Deleting empty files from triage collection...\n"
find ${OUTPUTDIR} -follow -type f -size 0 -ls >> ${OUTPUTDIR}/deleted_empty_triage_files.txt 2> /dev/null
find ${OUTPUTDIR} -follow -type f -size 0 -exec rm {} + 2> /dev/null

# Create a gzipped tar file of the resulting collection
OUTPUTZIP=/var/root/${SCRIPTSTART}_${HOSTNAME}_ForensicTriage.tar.gz
printf "\n[*] Creating ZIP file \"${OUTPUTZIP}\" and cleaning up directory \"${OUTPUTDIR}\"\n"
tar -czf ${OUTPUTZIP} ${OUTPUTDIR} && rm -rf ${OUTPUTDIR}

# Finish
printf "\n[*] Mac OS script finished at $(date -u +'%Y-%m-%d %H:%M:%S') Z\n"
printf "\n[*] Output file is at ${OUTPUTZIP}\n\n" 
