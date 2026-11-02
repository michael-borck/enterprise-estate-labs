@echo off
setlocal
cd /d "%~dp0"

rem Prefer Git Bash, which ships with Git for Windows. The launcher is a bash
rem script so there is one code path, not a separate Windows implementation.
set "GITBASH=C:\Program Files\Git\bin\bash.exe"
if exist "%GITBASH%" (
  set "BASH=%GITBASH%"
  goto run
)

where bash >nul 2>nul
if %errorlevel%==0 (
  set "BASH=bash"
  goto run
)

echo.
echo Git Bash was not found.
echo Install Git for Windows (it includes Git Bash), then run start.bat again.
echo.
pause
exit /b 1

:run
if "%~1"=="" (
  "%BASH%" ./start.sh
  echo.
  pause
  exit /b 0
)

"%BASH%" ./start.sh %*
set "RC=%errorlevel%"
if not "%RC%"=="0" (
  echo.
  echo The launcher stopped with an error. Read the message above.
  pause
)
exit /b %RC%
