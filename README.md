This is a collection of miscellaneous tools that analysts can use to either build their forensic environment or perform analysis
 
===========================================================================

Windows Triage Collector: DFIRTools/TriageCollectors/WindowsTriage.ps1

To use the Windows triage collector you can execute it directly from Github at an elevated Powershell prompt with the following command:

	Invoke-Expression $([net.webclient]::new().downloadstring('https://raw.githubusercontent.com/TheOffensiveDefender/DFIRTools/main/TriageCollectors/WindowsTriage.ps1'))

Once the collector is done running it will produce a compressed .zip file in your "C:\\" directory.
 
===========================================================================

Linux Triage Collector: DFIRTools/TriageCollectors/LinuxTriage.sh

To use the Linux triage collector you can execute it directly from Github as root with the following command:

	curl -s https://raw.githubusercontent.com/TheOffensiveDefender/DFIRTools/main/TriageCollectors/LinuxTriage.sh | bash

Once the collector is done running it will produce a compressed .tar.gz file in your "/root" directory.

Note: This script assumes Python 3 is installed on the system, as it is by default on many if not all Linux distributions. The script references "/usr/bin/python3" as its interpreter in order to use the "procdump.py" script available in this repository. If Python 3 is not installed, the script will not install it for you, in the interest of avoiding unnecessary modifications to the system. The procdump feature will simply not work in that case.

===========================================================================

Mac OS Triage Collector: DFIRTools/TriageCollectors/MacTriage.sh
 
To use the Mac OS Triage collector you can execute it directly from Github as root with the following command:
 
	curl -s https://raw.githubusercontent.com/TheOffensiveDefender/DFIRTools/main/TriageCollectors/MacTriage.sh | bash
 
Once the collector is done running it will produce a compressed .tar.gz file in your "/root" directory.
 
==========================================================================
 
Python 3 implementation to create a full dump of a Linux process' virtual address space: DFIRTools/MemoryAnalysis/Linux/procdump.py

To get procdump, you can use the following command as any user:
 
	wget -qO procdump.py https://raw.githubusercontent.com/TheOffensiveDefender/DFIRTools/main/MemoryAnalysis/Linux/procdump.py && chmod +x procdump.py
 
===========================================================================
 
Volatility 3 Full Installer Script: DFIRTools/MemoryAnalysis/volatility_installer.sh
 
To install Volatility 3, you can either clone this repository and run the volatility_installer.sh file as root or run the following command as root:
 
	curl -s https://raw.githubusercontent.com/TheOffensiveDefender/DFIRTools/main/MemoryAnalysis/volatility_installer.sh | bash

After install, run the command "vol -h" to ensure it works!
 
===========================================================================

