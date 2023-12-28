This is a collection of miscellaneous tools that analysts can use to either build their forensic environment or perform analysis
 
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

Linux Triage Collector: DFIRTools/TriageCollectors/LinuxTriage.sh

To use the Linux triage collector you can execute it directly from Github as root with the following command:

	curl -s https://raw.githubusercontent.com/TheOffensiveDefender/DFIRTools/main/TriageCollectors/LinuxTriage.sh | bash

Once the collector is done running it will produce a compressed .tar.gz file in your "/root" directory
