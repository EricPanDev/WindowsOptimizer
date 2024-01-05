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

pause
exit /b 0
