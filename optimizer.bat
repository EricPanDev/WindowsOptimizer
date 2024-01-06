@echo off

:: Check if the script is run as Administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo This script requires administrative privileges. Please run as Administrator.
    pause
    exit /b 1
)

:: Ask if the user wants to disable Windows Telemetry
echo Do you want to disable Windows Telemetry? (Y/N)
choice /c yn /m "Type Y for Yes or N for No."

if errorlevel 2 (
    echo You chose No. Windows Telemetry will not be disabled.
) else (
    echo You chose Yes. Disabling Windows Telemetry.

    :: Disable telemetry settings
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f
    reg add "HKLM\SOFTWARE\Policies\Microsoft\SQMClient\Windows" /v CEIPEnable /t REG_DWORD /d 0 /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\DiagTrack" /v Start /t REG_DWORD /d 4 /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\dmwappushservice" /v Start /t REG_DWORD /d 4 /f

    :: Restart the required services
    net stop DiagTrack
    net stop dmwappushservice
    net start DiagTrack
    net start dmwappushservice
    
    echo Windows Telemetry has been disabled.
)

:: Ask if the user wants to remove Windows Defender
echo Do you want to remove Windows Defender? (Y/N)
choice /c yn /m "Type Y for Yes or N for No."

if errorlevel 2 (
    echo You chose No. Windows Defender will not be removed.
) else (
    echo You chose Yes. Proceeding with the removal of Windows Defender.
    powershell -Command "Uninstall-MpClient -Force"
)

:: Ask if the user wants to remove Microsoft Edge
echo Do you want to remove Microsoft Edge? (Y/N)
choice /c yn /m "Type Y for Yes or N for No."

if errorlevel 2 (
    echo You chose No. Microsoft Edge will not be removed.
) else (
    echo You chose Yes. Proceeding with the removal of Microsoft Edge.

    :: Remove Microsoft Edge
    setlocal enabledelayedexpansion
    for /f "delims=" %%a in ('powershell "(New-Object System.Security.Principal.NTAccount($env:USERNAME)).Translate([System.Security.Principal.SecurityIdentifier]).Value"') do set "USER_SID=%%a"

    for /f "delims=" %%a in ('powershell -NoProfile -Command "Get-AppxPackage -AllUsers ^| Where-Object { $_.PackageFullName -like '*microsoftedge*' } ^| Select-Object -ExpandProperty PackageFullName"') do (
        if not "%%a"=="" (
            set "APP=%%a"
            reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\EndOfLife\!USER_SID!\!APP!" /f >nul 2>&1
            reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\EndOfLife\S-1-5-18\!APP!" /f >nul 2>&1
            reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\!APP!" /f >nul 2>&1
            powershell -Command "Remove-AppxPackage -Package '!APP!'" 2>nul
            powershell -Command "Remove-AppxPackage -Package '!APP!' -AllUsers" 2>nul
        )
    )
    endlocal
)

:: Ask if the user wants to disable Windows Update
echo Do you want to disable Windows Update? (Y/N)
choice /c yn /m "Type Y for Yes or N for No."

if errorlevel 2 (
    echo You chose No. Windows Update will not be disabled.
) else (
    echo You chose Yes. Disabling Windows Update.

    :: Disable Windows Update
    sc.exe config wuauserv start=disabled
    sc.exe query wuauserv
    sc.exe stop wuauserv
    sc.exe query wuauserv

    :: Double-check it's REALLY disabled - Start value should be 0x4
    REG.exe QUERY HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\wuauserv /v Start
)

pause
exit /b 0
