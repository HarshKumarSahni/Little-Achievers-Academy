@echo off
echo Requesting Administrator privileges...
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Success: Administrative permissions confirmed.
) else (
    echo Failure: Current permissions inadequate.
    echo Please right-click this file and select "Run as Administrator".
    pause
    exit
)

echo Adding Firewall Rule for AI Quiz Backend (Port 5000)...
netsh advfirewall firewall add rule name="Allow Flask 5000" dir=in action=allow protocol=TCP localport=5000

echo.
echo Rule added successfully!
echo You can now use the AI Quiz app on your phone.
pause
