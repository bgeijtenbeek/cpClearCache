#Script & package made by Bastiaan Geijtenbeek, July 8, 2022.
#
#Uninstall script for Win32 app. 
#Deletes both the script + folder as well as the scriptlogs + folder.

#Delete local script and folder
Remove-Item -Path "C:\Scripts\cpClearCache\" -Force -Recurse -ErrorAction SilentlyContinue
#Delete local scriptlogs and folder
Remove-Item -Path "C:\ScriptLogs\cpClearCache\" -Force -Recurse -ErrorAction SilentlyContinue