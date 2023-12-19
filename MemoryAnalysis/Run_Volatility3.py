#!/usr/bin/python3

import sys
from subprocess import check_output

# Set this to true if you want Volatility plugin output on the command line
verbose=False

# Set the path to vol.py if it is not in the following location
volpy = 'C:\\Users\\CRStudent\\Desktop\\Volatility3\\vol.py'
memdumpfile = ''

if len(sys.argv) == 2:
	if (sys.argv[1] == '-h' or sys.argv[1] == '--help'):
		print('\nUsage:\n\t{0} <path_to_memorydump>\n\nExample:\n\t{0} C:\memdump.raw'.format(sys.argv[0]))
		exit()
	else:
		memdumpfile = sys.argv[1]
else:
	print('\n[!] Error: Missing path to memory dump file\n\t{0} C:\\path\\to\\memdump.raw'.format(sys.argv[0]))

plugins = (
	'windows.pstree',
	'windows.cmdline',
	'windows.netscan',
	'windows.svcscan',
	'windows.privileges',
	'windows.pslist',
	'windows.psscan',
	'windows.dlllist',
	'windows.handles',
	'windows.cachedump',
	'windows.hashdump'
)

for plugin in plugins:
	file = ''
	output = ''
	try:
		file = plugin.split('.')[1]
	except:
		continue
	
	command = '{0} -f {1} -q -r csv {2}'.format(volpy, memdumpfile, plugin)
	print('\n[*] Running command:\n\t{0}\n'.format(command))
	
	try:
		output = check_output(command, shell=True)
	except:
		print('\n[!] Error executing plugin {0}; skipping it'.format(plugin))
		continue
	
	if verbose:
		print(output.decode('utf-8'))
	
	with open('{0}.csv'.format(file), 'wb') as of:
		of.write(output)
	
	print('\n[*] Output written to: {0}.csv\n'.format(file))

print('\n[*] Done!')