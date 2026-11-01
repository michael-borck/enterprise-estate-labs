@echo off
setlocal
cd /d "%~dp0"

rem Prefer Git Bash, which ships with Git for Windows. The launcher is a bash
rem script so there is one code path, not a separate Windows implementation.
set "GITBASH=C:\Program Files\Git\bin\bash.exe"
if exist "%GITBASH%" (
  "%GITBASH%" ./start.sh %*
  exit /b %errorlevel%
)

where bash >nul 2>nul
if %errorlevel%==0 (
  bash ./start.sh %*
  exit /b %errorlevel%
)

echo.
echo Git Bash was not found.
echo Install Git for Windows (it includes Git Bash), then run start.bat again.
echo.
pause
exit /b 1
