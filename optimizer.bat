@echo off

:: Check if the script is run as Administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo This script requires administrative privileges. Please run as Administrator.
    pause
    exit /b 1
)

:: The rest of your script goes here
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
