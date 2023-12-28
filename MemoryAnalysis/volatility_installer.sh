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
	printf "[*] System is running debian-based distribution\n"
else
	DEBIAN=false
	printf "[*] System is redhat-based distribution\n"
fi

# Run commands to install Volatility 
if [[ $DEBIAN = true ]]; then
	printf "[*] Updating APT repository package lists\n"
	apt-get update
	printf "[*] Installing Python3, PIP, and Git\n"
	apt install -y python3 python3-pip git
	printf "[*] Cloning Git repository $VOLATILITYURL to folder $INSTALLDIR\n"
	git clone $VOLATILITYURL $INSTALLDIR
	printf "[*] Giving "execute" permissions to all Python files in $INSTALLDIR\n"
	find $INSTALLDIR -type f -name "*.py" -exec chmod +x {} \;
	printf "[*] Upgrading Python 3 PIP installation\n"
	python3 -m pip install --upgrade pip
	printf "[*] Installing Volatility 3 PIP requirements from file ${VOLREQS}\n"
	python3 -m pip install -r $VOLREQS
	printf "[*] Creating a symbolic link to ${VOLBIN} in ${SYMLINKLOC}\n"
	ln -s $VOLBIN /bin/vol
else
	printf "[*] Updating YUM repository package lists\n"
	yum update -y
	printf "[*] Installing Python 3, PIP, and Git\n"
	yum install -y python3 python3-pip git
	printf "[*] Cloning Git repository $VOLATILITYURL to folder ${INSTALLDIR}\n"
	git clone $VOLATILITYURL $INSTALLDIR
	printf "[*] Giving "execute" permissions to all Python files in ${INSTALLDIR}\n"
	find $INSTALLDIR -type f -name "*.py" -exec chmod +x {} \;
	printf "[*] Upgrading Python 3 PIP installation\n"
	python3 -m pip install --upgrade pip
	printf "[*] Installing Volatility 3 PIP requirements from file ${VOLREQS}\n"
	python3 -m pip install -r $VOLREQS
	printf "[*] Creating a symbolic link to ${VOLBIN} in ${SYMLINKLOC}\n"
	ln -s $VOLBIN /bin/vol
fi

printf "\n[*] Script finished"
