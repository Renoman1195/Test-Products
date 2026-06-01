@echo off
setlocal
cd /d "%~dp0"
echo RazorWear will remove temporary files older than 1 day and clear the Recycle Bin.
echo Only use this if you are sure you do not need anything currently in the Recycle Bin.
echo.
choice /M "Continue"
if errorlevel 2 exit /b 0
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0RazorWear.ps1" -Clean -IncludeRecycleBin
echo.
pause
