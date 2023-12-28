#!/bin/bash

# Change this if you want to
INSTALLDIR='/opt/volatility3'
SYMLINKLOC='/bin/vol'
VOLBIN="${INSTALLDIR}/vol.py"
VOLATILITYURL='https://github.com/volatilityfoundation/volatility3.git'

# Uncomment which requirements you want to install; by default, all requirements are installed for full functionality
VOLREQS=$INSTALLDIR/requirements-dev.txt
#VOLREQS=$INSTALLDIR/requirements.txt
#VOLREQS=$INSTALLDIR/requirements-minimal.txt

# =========================================
# Try to leave everything below this alone
# =========================================

PATTERN='[Dd]ebian|[Uu]buntu'
SYSINFO=$(uname -a)
DEBIAN=""

# Check if running under elevated permissions
if [ "$EUID" -ne 0 ]; then
	printf "[!] Please run this script elevated with either sudo permissions or run as the root user"
	exit
fi

# Check for the type of Linux distro
if [[ $SYSINFO =~ $PATTERN ]]; then
	DEBIAN=true
	printf "[*] System is running debian-based distribution\n\n"
else
	DEBIAN=false
	printf "[*] System is redhat-based distribution\n\n"
fi

# Run commands to install Volatility 
if [[ $DEBIAN = true ]]; then
	printf "[*] Updating APT repository package lists\n\n"
	apt-get update
	printf "\n[*] Installing Python3, PIP, and Git\n\n"
	apt install -y python3 python3-pip git
	printf "\n[*] Cloning Git repository $VOLATILITYURL to folder $INSTALLDIR\n\n"
	git clone $VOLATILITYURL $INSTALLDIR
	printf "\n[*] Giving "execute" permissions to all Python files in $INSTALLDIR\n\n"
	find $INSTALLDIR -type f -name "*.py" -exec chmod +x {} \;
	printf "[*] Upgrading Python 3 PIP installation\n\n"
	python3 -m pip install --upgrade pip
	printf "\n[*] Installing Volatility 3 PIP requirements from file ${VOLREQS}\n\n"
	python3 -m pip install -r $VOLREQS
	printf "\n[*] Creating a symbolic link to ${VOLBIN} in ${SYMLINKLOC}\n\n"
	ln -s $VOLBIN /bin/vol
else
	printf "[*] Updating YUM/DNF repository package lists\n\n"
	yum update -y || dnf update -y
	printf "\n[*] Installing Python 3, PIP, and Git\n\n"
	yum install -y python3 python3-pip git || dnf install -y python3 python3-pip git
	printf "\n[*] Cloning Git repository $VOLATILITYURL to folder ${INSTALLDIR}\n\n"
	git clone $VOLATILITYURL $INSTALLDIR
	printf "\n[*] Giving "execute" permissions to all Python files in ${INSTALLDIR}\n\n"
	find $INSTALLDIR -type f -name "*.py" -exec chmod +x {} \;
	printf "[*] Upgrading Python 3 PIP installation\n\n"
	python3 -m pip install --upgrade pip
	printf "\n[*] Installing Volatility 3 PIP requirements from file ${VOLREQS}\n\n"
	python3 -m pip install -r $VOLREQS
	printf "\n[*] Creating a symbolic link to ${VOLBIN} in ${SYMLINKLOC}\n\n"
	ln -s $VOLBIN /bin/vol
fi

printf "[*] Script finished"
