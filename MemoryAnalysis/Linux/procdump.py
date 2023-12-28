#!/usr/bin/python3

'''
# ===========================================================================

	Title:
		Procdump (Linux)
	Version:
		1.0
	Author:
		Gary Contreras (The Offensive Defender - 0x0D)
	Usage:
		procdump.py <pid>
	Example:
		procdump.py 1337
	Description:
		Allows an analyst to dump process memory, assuming they have 
		the privileges to do so. You can then extract strings, carve 
		sections out of the memory dump, run Yara scans, or anything 
		else you need to get done. Run the program without any 
		arguments to see additional information.

# ===========================================================================
'''

import sys
import re

# Print usage information
if len(sys.argv) < 2:
	print('\n[*] Usage:\n\t\t{0} <pid> [outputdirectory]\n'.format(sys.argv[0]))
	print('This program produces a memory dump and a memory map file for an individual process, given its Process ID (PID).')
	print('\nIt works by reading the "/proc/<pid>/maps", "/proc/<pid>/mem", and "/proc/<pid>/comm" files to pull its data.')
	print('\nThe output files will be dumped in the current directory at the following locations:\n\t./dump_<pid>\n\t./map_<pid>.txt')
	print('\nThe maps file is basically a copy of the "/proc/<pid>/maps", barring sections that cannot be read/copied.')
	print('\nThe dump file is a copy of every readable region of memory at the time the dump was processed from "/proc/<pid>/mem".')
	exit()

# Get the Process ID (PID) argument from command line
pid=sys.argv[1]

# Get the output directory, if given, otherwise use current directory
outputdir = ''
if len(sys.argv) == 3:
	outputdir=sys.argv[2].rstrip('/')
else:
	outputdir='.'

# Output files
dumpfilepath = '{0}/dump_{1}'.format(outputdir, pid)
mapfilepath = '{0}/map_{1}.csv'.format(outputdir, pid)

# Input files
maps = '/proc/{0}/maps'.format(pid)
mem = '/proc/{0}/mem'.format(pid)
exe = '/proc/{0}/comm'.format(pid)

# Open up the /proc/<pid>/comm file to figure out which process is actually being dumped based on its PID
with open(exe,'r') as infile:
	print('[*] Targeting Process ID {0} ({1})\n'.format(pid, infile.read().strip('\n')))

# Read the /proc/<pid>/maps file into memory and split it by lines
mapinfo = ''
with open(maps,'r') as infile:
	mapinfo = infile.read().split('\n')

# Record all bytes copied from memory
byteswritten = 0

# Open a new "maps" file for writing (in append mode); also write the header information to the file so we all know what we're looking at
mapcopy = open(mapfilepath,'w')
mapcopy.write('MemoryStartAddress,MemoryEndAddress,Permissions,MapFileOffset,MajorID:MinorID,MapFileINodeID,MemoryRegion/MapFilePath,DumpFileStartOffset,DumpFileEndOffset,DumpFileRegionSize\n')

# Open the dumpfile for binary writing (in append mode)
with open(dumpfilepath,'wb') as of:
	# Process each line in the map file and read the process memory regions with this information to write the dump file data
	for line in mapinfo:
		# Catch memory read errors
		memreaderror = False
		
		# We must exclude the "vvar" region
		if (len(line.strip()) < 5) or ('vvar' in line.strip()):
			continue
		else:
			try:
				mdata = line.strip().split(' ')
				perm = mdata[1]
				if not 'r' in perm:
					continue
				start = int(mdata[0].split('-')[0], 16)
				end = int(mdata[0].split('-')[1], 16)
				length = end-start
				offset = int(mdata[2], 16)
				dfoffset = of.tell()
				
				membytes = ''
				
				try:
					with open(mem,'rb') as memfile:
						memfile.seek(start, 0)
						membytes = memfile.read(length)
				except:
					print('[!] Error: Could not read memory at location {0} with length {1} ({2})\n\t{3}\n'.format(hex(start), length, hex(length), line.strip()))
					memreaderror = True
				
				if len(membytes) != 0:
					print('[*] Writing data from memory location {0} - {1} (Size: {2}) to file {3}'.format(hex(start),hex(end),length,dumpfilepath))
					ol = re.sub('0[-]', '0,', re.sub(' ', ',', re.sub(' {2,}', ' ', line.strip()))) + ',{0},{1},{2}'.format(hex(dfoffset), hex(dfoffset + len(membytes) - 1), hex(len(membytes)))
					ola = ol.split(',')
					outline = ''
					if len(ola) < 10:
						for x in range(0, len(ola)):
							if x == 0 or x == 1 or x == 3:
								outline += '{0},'.format(hex(int(ola[x], 16)))
							elif x == 6:
								outline += 'N/A,{0},'.format(ola[x])
							else:
								outline += ola[x] + ','
						mapcopy.write(outline.strip(',\n') + '\n')
					else:
						for x in range(0, len(ola)):
							if x == 0 or x == 1 or x == 3:
								outline += '{0},'.format(hex(int(ola[x], 16)))
							else:
								outline += ola[x] + ','
						mapcopy.write(outline.strip(',\n') + '\n')
					
					byteswritten += len(membytes)
					of.write(membytes)
			except:
				if memreaderror:
					pass
				else:
					print('[*] Error: Could not parse memory map for line\n\t{0}\n'.format(line.strip()))

# Close the maps file
mapcopy.close()

# Finish up
print('\n[*] A total of {0} bytes have been extracted from process memory'.format(byteswritten))
print('\n[*] Check {0} for the memory dump\n[*] Check {1} for the memory maps\n\n[*] Done!'.format(dumpfilepath, mapfilepath))
