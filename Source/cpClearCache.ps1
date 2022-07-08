#Script created by Bastiaan Geijtenbeek on the 8th of July, 2022 (out of sheer lazyness). 
#Troubleshooting app deployments regularly this entire process has become too much of a repetitive task, yay automation!
#
#Script removes the Company Portal App cache & GRS, allowing fur much faster reinstallation times (for required apps especially) via Company Portal.
#1: Check and create some log folders when not present yet
#2: Set log file path/output
#3: Create the WriteLog function to actually start making log entries
#4: Check if Company Portal is opened and close it if true.
#5: Delete regkeys that make up part of the Company Portal cache. 
#6: Remove Incoming folder.
#7: Remove Staging folder.
#8: Restart Intune Managament Extension Service
#9: Prompt user to restart Company Portal and Sync (via windows notification)
#
#Run as admin and make sure you set execution policy to unrestricted!

#1:Check and create log folders
$dirCheck1 = Get-Item "C:\ScriptLogs\" -ErrorAction SilentlyContinue
if ($dirCheck1) {
} else {
    New-Item -Path C:\ -Name ScriptLogs -ItemType Directory
}
$dirCheck2 = Get-Item "C:\ScriptLogs\cpClearCache" -ErrorAction SilentlyContinue
if ($dirCheck2) {
} else {
    New-Item -Path C:\ScriptLogs\ -Name cpClearCache -ItemType Directory
}
Remove-Variable dirCheck1, dirCheck2

#2: Set log file path/output
$logDate = (Get-Date).toString("yyyyMMdd_HHmmss")
$Logfile = "C:\ScriptLogs\cpClearCache\cpClearCache_Log"+ $logDate +".log"

#3: Create WriteLog Function
function WriteLog
{
Param ([string]$LogString)
$Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
$LogMessage = "$Stamp $LogString"
Add-content $LogFile -value $LogMessage
}

#4: Check if Company Portal is opened and close it if true.
WriteLog "4: Closing Company Portal if currently open.."
$companyPortal = Get-Process "CompanyPortal" -ErrorAction SilentlyContinue
if ($companyPortal) {
    $companyPortal | Stop-Process -Force
    Start-Sleep -s 1
    WriteLog "4: App was open. Closed now. Proceeding to phase 5.."
    } else {
    WriteLog "4: App was not open. Proceeding to phase 5.."
    }
Remove-Variable companyPortal

#5: Delete regkeys that make up part of the Company Portal cache.
WriteLog "5: Deleting regkeys that are part of the Company Portal cache.."
$allSubKeys = Get-ChildItem -Path Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\IntuneManagementExtension\Win32Apps\ -Exclude "Reporting" -ErrorAction SilentlyContinue
#If value is not equal to NULL, delete all subkeys 
if ($allSubKeys) {
    Get-ChildItem -Path Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\IntuneManagementExtension\Win32Apps\ -Exclude "Reporting"| Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    #See if it has worked and write to host
    Start-Sleep -Seconds 2
    $regKeyDelete = Get-ChildItem -Path Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\IntuneManagementExtension\Win32Apps\ -Exclude "Reporting" -ErrorAction SilentlyContinue
    if ($regKeyDelete) {
        WriteLog "5: Keys were found but failed to delete. Please manually check HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\IntuneManagementExtension\Win32Apps\ and delete all subkeys. Proceeding to phase 6.."
        Remove-Variable regKeyDelete
    } else {
        WriteLog "5: Keys were found and successfully deleted. Proceeding to phase 6.." 
    }
} else {
    WriteLog "5: No keys were found. Proceeding with phase 6.."
}
Remove-Variable allSubKeys 

#6: Remove Incoming folder.
WriteLog "6: Remove the Incoming folder that is part of the Company Portal cache.."
$checkIncoming = Get-Item 'C:\Program Files (x86)\Microsoft Intune Management Extension\Content\Incoming' -ErrorAction SilentlyContinue
if ($checkIncoming) {
    #take ownership for admin group
    takeown /a /r /d Y /f "C:\Program Files (x86)\Microsoft Intune Management Extension\Content\Incoming"
    #remove the folder
    Remove-Item -Path "C:\Program Files (x86)\Microsoft Intune Management Extension\Content\Incoming" -Force -Recurse -ErrorAction SilentlyContinue    
    Start-Sleep -s 3
    #has it worked?
    $checkIncoming = Get-Item 'C:\Program Files (x86)\Microsoft Intune Management Extension\Content\Incoming' -ErrorAction SilentlyContinue
    if ($checkIncoming) {
        WriteLog "6: The Incoming folder was found but deletion failed. Please check the C:\Program Files (x86)\Microsoft Intune Management Extension\Content\Incoming folder for manual deletion. Proceeding with phase 7.." 
    } else {
        WriteLog "6: The Incoming folder was found and successfully deleted. Proceeding with phase 7.." 
    }
} else {
    WriteLog "6: The Incoming folder was not found, no deletion required. Proceeding with phase 7.."
}
Remove-Variable checkIncoming 

#7: Remove Staging folder.
WriteLog "7: Remove the Staging folder that is part of the Company Portal cache.."
$checkStaging = Get-Item 'C:\Program Files (x86)\Microsoft Intune Management Extension\Content\Staging' -ErrorAction SilentlyContinue
if ($checkStaging) {
    #take ownership for admin group
    takeown /a /r /d Y /f "C:\Program Files (x86)\Microsoft Intune Management Extension\Content\Staging"
    #remove the folder
    Remove-Item -Path "C:\Program Files (x86)\Microsoft Intune Management Extension\Content\Staging" -Force -Recurse -ErrorAction SilentlyContinue    
    Start-Sleep -s 3
    #has it worked?
    $checkStaging = Get-Item 'C:\Program Files (x86)\Microsoft Intune Management Extension\Content\Staging' -ErrorAction SilentlyContinue
    if ($checkStaging) {
        WriteLog "7: The Staging folder was found but deletion failed. Please check the C:\Program Files (x86)\Microsoft Intune Management Extension\Content\Staging folder for manual deletion. Proceeding with phase 8.." 
    } else {
        WriteLog "7: The Staging folder was found and successfully deleted. Proceeding with phase 8.." 
    }
} else {
    WriteLog "7: Staging folder not found, no deletion required. Proceeding with phase 8.."
}
Remove-Variable checkStaging

#8: Restart Intune Managament Extension Service
WriteLog "8: Restarting IntuneManagementExtension Service"
Restart-Service -Name IntuneManagementExtension
Start-Sleep -s 6
WriteLog "8: Restart Intune Management Extension Service: service restarted!"

#9: Prompt user to restart Company Portal and Sync (via windows notification)
[reflection.assembly]::loadwithpartialname('System.Windows.Forms')
[reflection.assembly]::loadwithpartialname('System.Drawing')
$notify = new-object system.windows.forms.notifyicon
$notify.icon = [System.Drawing.SystemIcons]::Information
$notify.visible = $true
$notify.showballoontip(30000,'Company Portal cache cleared','Please start the Company Portal app, click the wheel and sync when option appears.',[system.windows.forms.tooltipicon]::None)

WriteLog "9: Prompted user to re-sync company portal via Windows Notification"
WriteLog "Script finished!"