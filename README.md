# cpClearCache
Written by Bastiaan Geijtenbeek, July 8 2022. <br />
Script / Intunewin to quickly empty the Company Portal cache

When ran (through intunewin), package installs cpClearCache.ps1 script in folder C:\Scripts\cpClearCache\. After installation it also runs once out of the box.
After that the script will be available for running locally in folder C:\Scripts\cpClearCache so IT Support can use this whenever they please.<br />
NOTE: Script does require admin credentials and exectutionpolicy unrestricted to run properly.

**INTUNE APP DEPLOYMENT** <br />
Install command: powershell -executionpolicy unrestricted -file install.ps1 <br />
Uninstall Command: powershell -executionpolicy unrestricted -file uninstall.ps1 <br />

Intune App Detection: 
- Rule type: File
- Patch: C:\Scripts\
- File or folder: cpClearCache	
- Detection method: File or foldert exists
- Associated with a 32-bit app on 64-bit clients: No
