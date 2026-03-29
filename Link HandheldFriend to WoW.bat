:: Links the HandheldFriend addon into WoW (_retail_ only).
:: Run as Administrator (right-click -> Run as administrator).
@echo off
SETLOCAL
pushd %~dp0

echo Looking for World of Warcraft...

call :try "C:\Program Files\World of Warcraft"
call :try "C:\Program Files (x86)\World of Warcraft"
call :try "D:\World of Warcraft"
call :try "E:\World of Warcraft"
call :try "..\World of Warcraft"
call :try "..\Blizzard\World of Warcraft"

if not defined LINKED (
    echo.
    echo WoW not found in common paths.
    echo Edit this script and add your WoW install path to the list above.
)

echo.
set /p DUMMY=Hit ENTER to close...
EXIT /B 0

:try
if not exist "%~1\_retail_\" EXIT /B 0
echo Found: %~1
set "ADDONS=%~1\_retail_\Interface\AddOns"
if not exist "%ADDONS%" mkdir "%ADDONS%"
if exist "%ADDONS%\HandheldFriend" rmdir /s /q "%ADDONS%\HandheldFriend"
mklink /J "%ADDONS%\HandheldFriend" "%cd%"
echo Done! Junction created at: %ADDONS%\HandheldFriend
set "LINKED=1"
EXIT /B 0
