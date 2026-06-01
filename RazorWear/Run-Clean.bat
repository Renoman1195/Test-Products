@echo off
setlocal
cd /d "%~dp0"
echo RazorWear will remove temporary files older than 1 day.
echo It will not touch Desktop, Documents, Pictures, Downloads, or the Recycle Bin.
echo.
choice /M "Continue"
if errorlevel 2 exit /b 0
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0RazorWear.ps1" -Clean
echo.
pause
