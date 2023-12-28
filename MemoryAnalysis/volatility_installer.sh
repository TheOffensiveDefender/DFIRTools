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
	echo "[!] Please run this script elevated with either sudo permissions or run as the root user"
	exit
fi

# Check for the type of Linux distro
if [[ $SYSINFO =~ $PATTERN ]]; then
	DEBIAN=true
else
	DEBIAN=false
fi

# Run commands to install Volatility 
if [[ DEBIAN = true ]]; then
	echo "[*] Updating APT repository package lists\n"
	apt-get update
	echo "[*] Installing Python3, PIP, and Git\n"
	apt install -y python3 python3-pip git
	echo "[*] Cloning Git repository $VOLATILITYURL to folder $INSTALLDIR\n"
	git clone $VOLATILITYURL $INSTALLDIR
	echo "[*] Giving "execute" permissions to all Python files in $INSTALLDIR\n"
	find $INSTALLDIR -type f -name "*.py" -exec chmod +x {} \;
	echo "[*] Upgrading Python 3 PIP installation\n"
	python3 -m pip install --upgrade pip
	echo "[*] Installing Volatility 3 PIP requirements from file $VOLREQS\n"
	python3 -m pip install -r $VOLREQS
	echo "[*] Creating a symbolic link to $VOLBIN in $SYMLINKLOC\n"
	ln -s $VOLBIN /bin/vol
else
	echo "[*] Updating YUM repository package lists\n"
	yum update -y
	echo "[*] Installing Python 3, PIP, and Git\n"
	yum install -y python3 python3-pip git
	echo "[*] Cloning Git repository $VOLATILITYURL to folder $INSTALLDIR\n"
	git clone $VOLATILITYURL $INSTALLDIR
	echo "[*] Giving "execute" permissions to all Python files in $INSTALLDIR\n"
	find $INSTALLDIR -type f -name "*.py" -exec chmod +x {} \;
	echo "[*] Upgrading Python 3 PIP installation\n"
	python3 -m pip install --upgrade pip
	echo "[*] Installing Volatility 3 PIP requirements from file $VOLREQS\n"
	python3 -m pip install -r $VOLREQS
	echo "[*] Creating a symbolic link to $VOLBIN in $SYMLINKLOC\n"
	ln -s $VOLBIN /bin/vol
fi

echo "\n[*] Script finished"