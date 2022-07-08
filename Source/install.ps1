#Script & package made by Bastiaan Geijtenbeek, July 8, 2022.
#
#Install script for Win32 app. 
#Copies the cpClearCache script to C:\Scripts\cpClearCache\ and runs it once.

#Copy remediation script to folder, create when required.
xcopy /f /y ".\cpClearCache.ps1" "C:\Scripts\cpClearCache\"