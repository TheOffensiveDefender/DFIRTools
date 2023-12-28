#!/bin/bash

# Title:			Linux Triage Collector
# Version:			1.0
# Author:			Gary Contreras (The Offensive Defender - 0x0D)
# Usage:			./LinuxTriage.sh
# Description:		Use this to grab a forensic triage of a live Linux system
# Github:			https://github.com/TheOffensiveDefender/DFIRTools

# Variables to store important data
SCRIPTSTART=$(date -u +'%Y-%m-%dT%H%M%SZ')
OUTPUTDIR=/root/ForensicTriage
HASHDIR=${OUTPUTDIR}/hashes
TOOLSDIR=${OUTPUTDIR}/tools
DUMPDIR=${OUTPUTDIR}/dumps
SYSTEMINFO=${OUTPUTDIR}/systeminfo
PYPROCDUMP="IyEvdXNyL2Jpbi9weXRob24zCgonJycKIyA9PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT0KCglUaXRsZToKCQlQcm9jZHVtcCAoTGludXgpCglWZXJzaW9uOgoJCTEuMAoJQXV0aG9yOgoJCUdhcnkgQ29udHJlcmFzIChUaGUgT2ZmZW5zaXZlIERlZmVuZGVyIC0gMHgwRCkKCVVzYWdlOgoJCXByb2NkdW1wLnB5IDxwaWQ+CglFeGFtcGxlOgoJCXByb2NkdW1wLnB5IDEzMzcKCURlc2NyaXB0aW9uOgoJCUFsbG93cyBhbiBhbmFseXN0IHRvIGR1bXAgcHJvY2VzcyBtZW1vcnksIGFzc3VtaW5nIHRoZXkgaGF2ZSAKCQl0aGUgcHJpdmlsZWdlcyB0byBkbyBzby4gWW91IGNhbiB0aGVuIGV4dHJhY3Qgc3RyaW5ncywgY2FydmUgCgkJc2VjdGlvbnMgb3V0IG9mIHRoZSBtZW1vcnkgZHVtcCwgcnVuIFlhcmEgc2NhbnMsIG9yIGFueXRoaW5nIAoJCWVsc2UgeW91IG5lZWQgdG8gZ2V0IGRvbmUuIFJ1biB0aGUgcHJvZ3JhbSB3aXRob3V0IGFueSAKCQlhcmd1bWVudHMgdG8gc2VlIGFkZGl0aW9uYWwgaW5mb3JtYXRpb24uCgojID09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PQonJycKCmltcG9ydCBzeXMKaW1wb3J0IHJlCgojIFByaW50IHVzYWdlIGluZm9ybWF0aW9uCmlmIGxlbihzeXMuYXJndikgPCAyOgoJcHJpbnQoJ1xuWypdIFVzYWdlOlxuXHRcdHswfSA8cGlkPiBbb3V0cHV0ZGlyZWN0b3J5XVxuJy5mb3JtYXQoc3lzLmFyZ3ZbMF0pKQoJcHJpbnQoJ1RoaXMgcHJvZ3JhbSBwcm9kdWNlcyBhIG1lbW9yeSBkdW1wIGFuZCBhIG1lbW9yeSBtYXAgZmlsZSBmb3IgYW4gaW5kaXZpZHVhbCBwcm9jZXNzLCBnaXZlbiBpdHMgUHJvY2VzcyBJRCAoUElEKS4nKQoJcHJpbnQoJ1xuSXQgd29ya3MgYnkgcmVhZGluZyB0aGUgIi9wcm9jLzxwaWQ+L21hcHMiLCAiL3Byb2MvPHBpZD4vbWVtIiwgYW5kICIvcHJvYy88cGlkPi9jb21tIiBmaWxlcyB0byBwdWxsIGl0cyBkYXRhLicpCglwcmludCgnXG5UaGUgb3V0cHV0IGZpbGVzIHdpbGwgYmUgZHVtcGVkIGluIHRoZSBjdXJyZW50IGRpcmVjdG9yeSBhdCB0aGUgZm9sbG93aW5nIGxvY2F0aW9uczpcblx0Li9kdW1wXzxwaWQ+XG5cdC4vbWFwXzxwaWQ+LnR4dCcpCglwcmludCgnXG5UaGUgbWFwcyBmaWxlIGlzIGJhc2ljYWxseSBhIGNvcHkgb2YgdGhlICIvcHJvYy88cGlkPi9tYXBzIiwgYmFycmluZyBzZWN0aW9ucyB0aGF0IGNhbm5vdCBiZSByZWFkL2NvcGllZC4nKQoJcHJpbnQoJ1xuVGhlIGR1bXAgZmlsZSBpcyBhIGNvcHkgb2YgZXZlcnkgcmVhZGFibGUgcmVnaW9uIG9mIG1lbW9yeSBhdCB0aGUgdGltZSB0aGUgZHVtcCB3YXMgcHJvY2Vzc2VkIGZyb20gIi9wcm9jLzxwaWQ+L21lbSIuJykKCWV4aXQoKQoKIyBHZXQgdGhlIFByb2Nlc3MgSUQgKFBJRCkgYXJndW1lbnQgZnJvbSBjb21tYW5kIGxpbmUKcGlkPXN5cy5hcmd2WzFdCgojIEdldCB0aGUgb3V0cHV0IGRpcmVjdG9yeSwgaWYgZ2l2ZW4sIG90aGVyd2lzZSB1c2UgY3VycmVudCBkaXJlY3RvcnkKb3V0cHV0ZGlyID0gJycKaWYgbGVuKHN5cy5hcmd2KSA9PSAzOgoJb3V0cHV0ZGlyPXN5cy5hcmd2WzJdLnJzdHJpcCgnLycpCmVsc2U6CglvdXRwdXRkaXI9Jy4nCgojIElucHV0IGZpbGVzCm1hcHMgPSAnL3Byb2MvezB9L21hcHMnLmZvcm1hdChwaWQpCm1lbSA9ICcvcHJvYy97MH0vbWVtJy5mb3JtYXQocGlkKQpleGUgPSAnL3Byb2MvezB9L2NvbW0nLmZvcm1hdChwaWQpCgojIE9wZW4gdXAgdGhlIC9wcm9jLzxwaWQ+L2NvbW0gZmlsZSB0byBmaWd1cmUgb3V0IHdoaWNoIHByb2Nlc3MgaXMgYWN0dWFsbHkgYmVpbmcgZHVtcGVkIGJhc2VkIG9uIGl0cyBQSUQKcGV4ZWN1dGFibGUgPSAnJwp3aXRoIG9wZW4oZXhlLCdyJykgYXMgaW5maWxlOgoJcGV4ZWN1dGFibGUgPSBpbmZpbGUucmVhZCgpLnN0cmlwKCdcbicpCglwcmludCgnWypdIFRhcmdldGluZyBQcm9jZXNzIElEIHswfSAoezF9KVxuJy5mb3JtYXQocGlkLCBwZXhlY3V0YWJsZSkpCgojIE91dHB1dCBmaWxlcwpkdW1wZmlsZXBhdGggPSAnezB9L2R1bXBfezF9X3syfScuZm9ybWF0KG91dHB1dGRpciwgcGlkLCBwZXhlY3V0YWJsZSkKbWFwZmlsZXBhdGggPSAnezB9L21hcF97MX1fezJ9LmNzdicuZm9ybWF0KG91dHB1dGRpciwgcGlkLCBwZXhlY3V0YWJsZSkKCiMgUmVhZCB0aGUgL3Byb2MvPHBpZD4vbWFwcyBmaWxlIGludG8gbWVtb3J5IGFuZCBzcGxpdCBpdCBieSBsaW5lcwptYXBpbmZvID0gJycKd2l0aCBvcGVuKG1hcHMsJ3InKSBhcyBpbmZpbGU6CgltYXBpbmZvID0gaW5maWxlLnJlYWQoKS5zcGxpdCgnXG4nKQoKIyBSZWNvcmQgYWxsIGJ5dGVzIGNvcGllZCBmcm9tIG1lbW9yeQpieXRlc3dyaXR0ZW4gPSAwCgojIE9wZW4gYSBuZXcgIm1hcHMiIGZpbGUgZm9yIHdyaXRpbmcgKGluIGFwcGVuZCBtb2RlKTsgYWxzbyB3cml0ZSB0aGUgaGVhZGVyIGluZm9ybWF0aW9uIHRvIHRoZSBmaWxlIHNvIHdlIGFsbCBrbm93IHdoYXQgd2UncmUgbG9va2luZyBhdAptYXBjb3B5ID0gb3BlbihtYXBmaWxlcGF0aCwndycpCm1hcGNvcHkud3JpdGUoJ01lbW9yeVN0YXJ0QWRkcmVzcyxNZW1vcnlFbmRBZGRyZXNzLFBlcm1pc3Npb25zLE1hcEZpbGVPZmZzZXQsTWFqb3JJRDpNaW5vcklELE1hcEZpbGVJTm9kZUlELE1lbW9yeVJlZ2lvbi9NYXBGaWxlUGF0aCxEdW1wRmlsZVN0YXJ0T2Zmc2V0LER1bXBGaWxlRW5kT2Zmc2V0LER1bXBGaWxlUmVnaW9uU2l6ZVxuJykKCiMgT3BlbiB0aGUgZHVtcGZpbGUgZm9yIGJpbmFyeSB3cml0aW5nIChpbiBhcHBlbmQgbW9kZSkKd2l0aCBvcGVuKGR1bXBmaWxlcGF0aCwnd2InKSBhcyBvZjoKCSMgUHJvY2VzcyBlYWNoIGxpbmUgaW4gdGhlIG1hcCBmaWxlIGFuZCByZWFkIHRoZSBwcm9jZXNzIG1lbW9yeSByZWdpb25zIHdpdGggdGhpcyBpbmZvcm1hdGlvbiB0byB3cml0ZSB0aGUgZHVtcCBmaWxlIGRhdGEKCWZvciBsaW5lIGluIG1hcGluZm86CgkJIyBDYXRjaCBtZW1vcnkgcmVhZCBlcnJvcnMKCQltZW1yZWFkZXJyb3IgPSBGYWxzZQoJCQoJCSMgV2UgbXVzdCBleGNsdWRlIHRoZSAidnZhciIgcmVnaW9uCgkJaWYgKGxlbihsaW5lLnN0cmlwKCkpIDwgNSkgb3IgKCd2dmFyJyBpbiBsaW5lLnN0cmlwKCkpOgoJCQljb250aW51ZQoJCWVsc2U6CgkJCXRyeToKCQkJCW1kYXRhID0gbGluZS5zdHJpcCgpLnNwbGl0KCcgJykKCQkJCXBlcm0gPSBtZGF0YVsxXQoJCQkJaWYgbm90ICdyJyBpbiBwZXJtOgoJCQkJCWNvbnRpbnVlCgkJCQlzdGFydCA9IGludChtZGF0YVswXS5zcGxpdCgnLScpWzBdLCAxNikKCQkJCWVuZCA9IGludChtZGF0YVswXS5zcGxpdCgnLScpWzFdLCAxNikKCQkJCWxlbmd0aCA9IGVuZC1zdGFydAoJCQkJb2Zmc2V0ID0gaW50KG1kYXRhWzJdLCAxNikKCQkJCWRmb2Zmc2V0ID0gb2YudGVsbCgpCgkJCQkKCQkJCW1lbWJ5dGVzID0gJycKCQkJCQoJCQkJdHJ5OgoJCQkJCXdpdGggb3BlbihtZW0sJ3JiJykgYXMgbWVtZmlsZToKCQkJCQkJbWVtZmlsZS5zZWVrKHN0YXJ0LCAwKQoJCQkJCQltZW1ieXRlcyA9IG1lbWZpbGUucmVhZChsZW5ndGgpCgkJCQlleGNlcHQ6CgkJCQkJcHJpbnQoJ1shXSBFcnJvcjogQ291bGQgbm90IHJlYWQgbWVtb3J5IGF0IGxvY2F0aW9uIHswfSB3aXRoIGxlbmd0aCB7MX0gKHsyfSlcblx0ezN9XG4nLmZvcm1hdChoZXgoc3RhcnQpLCBsZW5ndGgsIGhleChsZW5ndGgpLCBsaW5lLnN0cmlwKCkpKQoJCQkJCW1lbXJlYWRlcnJvciA9IFRydWUKCQkJCQoJCQkJaWYgbGVuKG1lbWJ5dGVzKSAhPSAwOgoJCQkJCXByaW50KCdbKl0gV3JpdGluZyBkYXRhIGZyb20gbWVtb3J5IGxvY2F0aW9uIHswfSAtIHsxfSAoU2l6ZTogezJ9KSB0byBmaWxlIHszfScuZm9ybWF0KGhleChzdGFydCksaGV4KGVuZCksbGVuZ3RoLGR1bXBmaWxlcGF0aCkpCgkJCQkJb2wgPSByZS5zdWIoJzBbLV0nLCAnMCwnLCByZS5zdWIoJyAnLCAnLCcsIHJlLnN1YignIHsyLH0nLCAnICcsIGxpbmUuc3RyaXAoKSkpKSArICcsezB9LHsxfSx7Mn0nLmZvcm1hdChoZXgoZGZvZmZzZXQpLCBoZXgoZGZvZmZzZXQgKyBsZW4obWVtYnl0ZXMpIC0gMSksIGhleChsZW4obWVtYnl0ZXMpKSkKCQkJCQlvbGEgPSBvbC5zcGxpdCgnLCcpCgkJCQkJb3V0bGluZSA9ICcnCgkJCQkJaWYgbGVuKG9sYSkgPCAxMDoKCQkJCQkJZm9yIHggaW4gcmFuZ2UoMCwgbGVuKG9sYSkpOgoJCQkJCQkJaWYgeCA9PSAwIG9yIHggPT0gMSBvciB4ID09IDM6CgkJCQkJCQkJb3V0bGluZSArPSAnezB9LCcuZm9ybWF0KGhleChpbnQob2xhW3hdLCAxNikpKQoJCQkJCQkJZWxpZiB4ID09IDY6CgkJCQkJCQkJb3V0bGluZSArPSAnTi9BLHswfSwnLmZvcm1hdChvbGFbeF0pCgkJCQkJCQllbHNlOgoJCQkJCQkJCW91dGxpbmUgKz0gb2xhW3hdICsgJywnCgkJCQkJCW1hcGNvcHkud3JpdGUob3V0bGluZS5zdHJpcCgnLFxuJykgKyAnXG4nKQoJCQkJCWVsc2U6CgkJCQkJCWZvciB4IGluIHJhbmdlKDAsIGxlbihvbGEpKToKCQkJCQkJCWlmIHggPT0gMCBvciB4ID09IDEgb3IgeCA9PSAzOgoJCQkJCQkJCW91dGxpbmUgKz0gJ3swfSwnLmZvcm1hdChoZXgoaW50KG9sYVt4XSwgMTYpKSkKCQkJCQkJCWVsc2U6CgkJCQkJCQkJb3V0bGluZSArPSBvbGFbeF0gKyAnLCcKCQkJCQkJbWFwY29weS53cml0ZShvdXRsaW5lLnN0cmlwKCcsXG4nKSArICdcbicpCgkJCQkJCgkJCQkJYnl0ZXN3cml0dGVuICs9IGxlbihtZW1ieXRlcykKCQkJCQlvZi53cml0ZShtZW1ieXRlcykKCQkJZXhjZXB0OgoJCQkJaWYgbWVtcmVhZGVycm9yOgoJCQkJCXBhc3MKCQkJCWVsc2U6CgkJCQkJcHJpbnQoJ1sqXSBFcnJvcjogQ291bGQgbm90IHBhcnNlIG1lbW9yeSBtYXAgZm9yIGxpbmVcblx0ezB9XG4nLmZvcm1hdChsaW5lLnN0cmlwKCkpKQoKIyBDbG9zZSB0aGUgbWFwcyBmaWxlCm1hcGNvcHkuY2xvc2UoKQoKIyBGaW5pc2ggdXAKcHJpbnQoJ1xuWypdIEEgdG90YWwgb2YgezB9IGJ5dGVzIGhhdmUgYmVlbiBleHRyYWN0ZWQgZnJvbSBwcm9jZXNzIG1lbW9yeScuZm9ybWF0KGJ5dGVzd3JpdHRlbikpCnByaW50KCdcblsqXSBDaGVjayB7MH0gZm9yIHRoZSBtZW1vcnkgZHVtcFxuWypdIENoZWNrIHsxfSBmb3IgdGhlIG1lbW9yeSBtYXBzXG5cblsqXSBEb25lIScuZm9ybWF0KGR1bXBmaWxlcGF0aCwgbWFwZmlsZXBhdGgpKQ=="
PDPATH=${TOOLSDIR}/procdump.py
HOSTNAME=$(hostname)

# Print script start time
printf "\n[*] Script started at $(date -u +'%Y-%m-%d %H:%M:%S') Z on host ${HOSTNAME}...\n\n"

# Create the forensic triage output directory
printf "\n[*] Creating output directory \"${SYSTEMINFO}\", \"${HASHDIR}\", \"${TOOLSDIR}\", and \"${DUMPDIR}\"...\n\n"
mkdir -p ${SYSTEMINFO}
mkdir -p ${HASHDIR}
mkdir -p ${TOOLSDIR}
mkdir -p ${DUMPDIR}

# Enumerate various information using an order of volatility

printf "\n[*] Enumerating processes and network connections...\n\n"
ps -ef >> ${SYSTEMINFO}/ps.txt 2>> /dev/null
netstat -natup >> ${SYSTEMINFO}/netstat.txt 2>> /dev/null
lsof >> ${SYSTEMINFO}/lsof.txt 2>> /dev/null

printf "\n[*] Enumerating network information...\n\n"
ip addr >> ${SYSTEMINFO}/ipaddr.txt 2>> /dev/null
ifconfig >> ${SYSTEMINFO}/ifconfig.txt 2>> /dev/null
arp -e >> ${SYSTEMINFO}/arp.txt 2>> /dev/null
iptables -L >> ${SYSTEMINFO}/iptables.txt 2>> /dev/null
route >> ${SYSTEMINFO}/route.txt 2>> /dev/null

printf "\n[*] Enumerating user login information...\n\n"
w >> ${SYSTEMINFO}/w.txt 2>> /dev/null
who >> ${SYSTEMINFO}/who.txt 2>> /dev/null
id >> ${SYSTEMINFO}/id.txt 2>> /dev/null
last >> ${SYSTEMINFO}/last_logins.txt 2>> /dev/null

printf "\n[*] Enumerating operating system, environment, and installed packages...\n\n"
env >> ${SYSTEMINFO}/env.txt 2>> /dev/null
sudo -l >> ${SYSTEMINFO}/sudo.txt 2>> /dev/null
apt list --installed >> ${SYSTEMINFO}/apt_installed_packages.txt 2>> /dev/null
yum list installed >> ${SYSTEMINFO}/yum_installed_packages.txt 2>> /dev/null
dnf list installed >> ${SYSTEMINFO}/dnf_installed_packages.txt 2>> /dev/null
dpkg -l >> ${SYSTEMINFO}/dpkg_listing.txt 2>> /dev/null
rpm -qa >> ${SYSTEMINFO}/rpm_listing.txt 2>> /dev/null
free >> ${SYSTEMINFO}/free.txt 2>> /dev/null
cat /proc/version >> ${SYSTEMINFO}/version.txt 2>> /dev/null
cat /etc/*release >> ${SYSTEMINFO}/os_release.txt 2>> /dev/null
uname -a >> ${SYSTEMINFO}/uname.txt 2>> /dev/null
mount >> ${SYSTEMINFO}/mount.txt 2>> /dev/null

# Memory dump section; unpack procdump.py and run it on each interesting process
printf "\n[*] Processing memory dumps...\n\n"
echo -n ${PYPROCDUMP} | base64 -d > ${PDPATH} 2> /dev/null
chmod +x ${PDPATH}
INTPROCS=$(ps -ef | egrep -i 'python|php|perl|powershell|([0-9]:){2}[0-9]{2}\s(\./|/tmp|/opt|/home|/var)' | egrep -iv 'procdump|triage' | tr -s ' ' | cut -d ' ' -f 2)
for i in $INTPROCS; do { printf "\n[*] Dumping Process ID $i\n\n"; ${PDPATH} $i ${DUMPDIR} > /dev/null 2> /dev/null; }; done

# Get the configs from the "/etc" folder as well as passwd/group/shadow files
printf "\n[*] Copying and hashing \"/etc\" files...\n\n"
find /etc -type f -size -2M -regextype egrep -iregex '.*(conf(ig)?|cfg|tab)$|/etc/(passwd|shadow|group|(host|issue).*|environment|net.*|profile|.*bashrc|services|timezone|sudoers|shells)$' -exec cp -R -f --parents --preserve {} ${OUTPUTDIR} \; -exec sha256sum {} + >> ${HASHDIR}/etc_hashes.txt 2> /dev/null

# Get any files in "/home" and "/tmp" that are executable and under 10 megabytes in size
printf "\n[*] Enumerating and hashing SUID/GUID executables...\n\n"
find /home /tmp -type f -executable -size -10M -exec cp -R -f --parents --preserve {} ${OUTPUTDIR} \; -exec sha256sum {} + >> ${HASHDIR}/tmp_executable_hashes.txt 2> /dev/null

# Get any files in "/home", "/tmp", or "/var" that look interesting
printf "\n[*] Copying and hashing interesting files in \"/tmp\", \"/var/www\", and \"/home\" directories...\n\n"
find /tmp /var/www /home -type f -size -2M -regextype egrep -iregex '.*\.(c(pp)?|php|py|pl|exe)$' -exec cp -R -f --parents --preserve {} ${OUTPUTDIR} \; -exec sha256sum {} + >> ${HASHDIR}/interesting_miscellaneous_hashes.txt 2> /dev/null

# Enumerate any zip file listings that may have been created for data exfiltration but DOES NOT actually retrieve them as these files may be large
printf "\n[*] Enumerating suspicious compressed files for possible data exfiltration...\n\n"
find /home /root /tmp /opt /var/www -regextype egrep -iregex '.*\.(tar|gz|xz|bz|bzip2?|7z|zip)$' -mtime -30 -size -10M -ls >> ${SYSTEMINFO}/possible_exfiltration_last30days.txt 2>> /dev/null

# Get all of the relevant logs under "/var" and preserve the directory structure and critical attributes
printf "\n[*] Copying and hashing relevant logs under \"/var\" directory...\n\n"
find /var -type f -size -10M -regextype egrep -iregex '.*(\.(gz|tar|bz|bzip2?|zip|7z)|messages|log.*|kern|dmesg|cron|secure|tmp|spooler)$' -exec cp -R -f --parents --preserve {} ${OUTPUTDIR} \; -exec sha256sum {} + >> ${HASHDIR}/var_hashes.txt 2> /dev/null

# Get all hidden user files
printf "\n[*] Copying and hashing user hidden files...\n\n"
find /root /home -type f -name ".*" -maxdepth 2 -exec cp -R -f --parents --preserve {} ${OUTPUTDIR} \; -exec sha256sum {} + >> ${HASHDIR}/user_hidden_files_hashes.txt 2> /dev/null

# Get authorized keys files from all users
printf "\n[*] Copying and hashing SSH authorized key files...\n\n"
find /etc /root /home -type f -name "authorized_keys" -exec cp -R -f --parents --preserve {} ${OUTPUTDIR} \; -exec sha256sum {} + >> ${HASHDIR}/user_authorized_keys_hashes.txt 2> /dev/null

# Find SUID/GUID executables
printf "\n[*] Enumerating and hashing SUID/GUID executables...\n\n"
find / -perm -g=s -type f 2>/dev/null -exec sha256sum {} + >> ${HASHDIR}/guid_executable_hashes.txt
find / -perm -u=s -type f 2>/dev/null -exec sha256sum {} + >> ${HASHDIR}/suid_executable_hashes.txt

# Create a file stat to record file stats like permissions, ownership, and MACB timestamps
printf "\n[*] Preserving file stats prior to compression...\n\n"
find ${OUTPUTDIR} -type f -exec stat {} + >> ${OUTPUTDIR}/file_stats.txt 2> /dev/null

# Delete empty files
printf "\n[*] Deleting empty files from triage collection...\n\n"
find ${OUTPUTDIR} -type f -size 0 -ls >> ${OUTPUTDIR}/deleted_empty_triage_files.txt 2> /dev/null
find ${OUTPUTDIR} -type f -size 0 -exec rm {} + 2> /dev/null

# Remove tools folder
printf "\n[*] Cleaning up folder \"${TOOLSDIR}\"...\n\n"
rm -rf ${TOOLSDIR}

# Create a gzipped tar file of the resulting collection
OUTPUTZIP=/root/${SCRIPTSTART}_${HOSTNAME}_ForensicTriage.tar.gz
printf "\n[*] Creating ZIP file \"${OUTPUTZIP}\" and cleaning up directory \"${OUTPUTDIR}\"\n\n"
tar --preserve-permissions -czf ${OUTPUTZIP} ${OUTPUTDIR} && rm -rf ${OUTPUTDIR}

# Finish
printf "\n[*] Script finished at $(date -u +'%Y-%m-%d %H:%M:%S') Z\n\n"
printf "\n[*] Output file is at ${OUTPUTZIP}\n\n"
