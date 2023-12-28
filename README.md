This is a collection of miscellaneous tools that analysts can use to either build their forensic environment or perform analysis
 
Python-based "procdump" for Linux: DFIRTools/MemoryAnalysis/Linux/procdump.py

To get procdump, you can use the following command as any user:
 
	wget -qO procdump.py https://raw.githubusercontent.com/TheOffensiveDefender/DFIRTools/main/MemoryAnalysis/Linux/procdump.py && chmod +x procdump.py
 
Volatility 3 full install: DFIRTools/MemoryAnalysis/volatility_installer.sh
 
To install Volatility 3, you can either clone this repository and run the volatility_installer.sh file as root or run the following command as root:
 
	curl https://raw.githubusercontent.com/TheOffensiveDefender/DFIRTools/main/MemoryAnalysis/volatility_installer.sh | sh

After install, run the command "vol -h" to ensure it works!
