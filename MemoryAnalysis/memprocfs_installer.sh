#!/bin/bash

# Set these variables to determine how to install MemProcFS
INSTALLDIR='/opt/memprocfs'
SYMLINKLOC='/bin/memprocfs'
GITREPO='https://github.com/ufrisk/MemProcFS.git'

# =========================================
# Try to leave everything below this alone
# =========================================

VMMPYCDIR="${INSTALLDIR}/vmmpyc"
VMMDIR="${INSTALLDIR}/vmm"
MPFSDIR="${INSTALLDIR}/memprocfs"
MPFSBIN="${INSTALLDIR}/memprocfs/files/memprocfs"
CURRENTDIR=$(pwd)

# Check if running under elevated permissions
if [ "$EUID" -ne 0 ]; then
	echo "[!] Please run this script elevated with either sudo permissions or run as the root user"
	exit
fi

# Update APT packages and install the prerequisites for MemProcFS
echo "[*] Updating APT repository package lists\n"
apt-get update
echo "[*] Installing required packages from APT\n"
apt-get install -y libusb-1.0 fuse openssl lz4 git make gcc pkg-config libusb-1.0-0-dev libfuse2 libfuse-dev liblz4-dev
echo "[*] Cloning Git repository $GITREPO to folder $INSTALLDIR\n"
git clone $GITREPO $INSTALLDIR
echo "[*] Compiling directory $VMMDIR\n"
cd $VMMDIR
make
echo "[*] Compiling directory $VMMPYCDIR\n"
cd $VMMPYCDIR
make
echo "[*] Compiling directory $MPFSDIR\n"
cd $MPFSDIR
make
cd $CURRENTDIR
echo "[*] Creating symbolic link from $MPFSBIN at $SYMLINKLOC\n"
chmod +x $MPFSBIN
ln -s $MPFSBIN $SYMLINKLOC