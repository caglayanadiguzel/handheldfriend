:: Run this script to link the HandheldFriend addon into WoW (_retail_ only).
:: It will automatically find your WoW installation by walking up the folder tree.
:: If it cannot find it, it tries common install paths.
:: On success you will see: "Linking using root WoW folder: ..."
@echo off
SETLOCAL
pushd %~dp0

set "TargetName=World of Warcraft"
set "MatchedDir="
set "Name="
set "Parent="

set "Dir=%~dp0"
if "%Dir:~-1%"=="\" set "Dir=%Dir:~0,-1%"

:Up
for %%F in ("%Dir%") do (
    set "Name=%%~nxF"
    set "Parent=%%~dpF"
)
if /I "%Name%"=="%TargetName%" (
    set "MatchedDir=%Dir%"
    goto :Found
)
if "%Parent:~-2%"==":\" goto :NotFound
set "Dir=%Parent:~0,-1%"
goto :Up

:Found
echo Found WoW folder: %MatchedDir%
goto :do_links

:NotFound
echo WoW folder not found in directory tree above this file. Trying common paths...
goto :do_links

:do_links
if defined MatchedDir (
    call :link_wowfolder "%MatchedDir%"
) else (
    call :link_wowfolder "C:\Program Files\World of Warcraft"
    call :link_wowfolder "C:\Program Files (x86)\World of Warcraft"
    call :link_wowfolder "..\World of Warcraft"
    call :link_wowfolder "..\Blizzard\World of Warcraft"
    call :link_wowfolder "F:\World of Warcraft"
    call :link_wowfolder "G:\World of Warcraft"
)
call :report_taskcomplete
EXIT /B 0

:link_wowfolder
if exist "%~1\" (
    echo Linking using root WoW folder: %~1
    call :link_retail "%~1\_retail_"
)
EXIT /B 0

:link_retail
if exist "%~1\" (
    echo Linking Retail "%~1\"
    if exist "%~1\Interface\AddOns\HandheldFriend" (
        rmdir /s /q "%~1\Interface\AddOns\HandheldFriend"
    )
    if NOT exist "%~1\Interface" mkdir "%~1\Interface"
    if NOT exist "%~1\Interface\AddOns" mkdir "%~1\Interface\AddOns"
    mklink /J "%~1\Interface\AddOns\HandheldFriend" "%cd%"
    echo Done.
)
EXIT /B 0

:report_taskcomplete
echo.
echo Task complete!
set /p DUMMY=Hit ENTER to close...
EXIT /B 0
