@echo off
setlocal enabledelayedexpansion

@REM SETTING
set "ROOT_SOURCE_DIR=\\192.168.1.234\Shared\AllKhanza"
if not exist "%ROOT_SOURCE_DIR%\" (
    echo Tidak dapat terhubung ke: %ROOT_SOURCE_DIR%
    pause
    exit /b
)

@REM Fetch version information, update folder, and count of versions to keep from JSON file
for /f "delims=" %%a in ('PowerShell -Command "Get-Content '%ROOT_SOURCE_DIR%\info.json' | ConvertFrom-Json | Select -ExpandProperty NEW_VERSION"') do set "NEW_VERSION=%%a"
for /f "delims=" %%b in ('PowerShell -Command "Get-Content '%ROOT_SOURCE_DIR%\info.json' | ConvertFrom-Json | Select -ExpandProperty SOURCE_NEW_KHANZA_FOLDER"') do set "SOURCE_NEW_KHANZA_FOLDER=%%b"
for /f "delims=" %%c in ('PowerShell -Command "Get-Content '%ROOT_SOURCE_DIR%\info.json' | ConvertFrom-Json | Select -ExpandProperty COUNT_OF_LATEST_VERSION_TO_KEEP"') do set "COUNT_OF_LATEST_VERSION_TO_KEEP=%%c"

@REM SETTING
set "SOURCE_DIR=%ROOT_SOURCE_DIR%\%SOURCE_NEW_KHANZA_FOLDER%"
set "TARGET_DIR=%~dp0simrs khanza %NEW_VERSION%"
set "SHORTCUT_NAME=SIMRS Khanza %NEW_VERSION%.lnk"
set "SHORTCUT_SCRIPT_PATH=%TARGET_DIR%\Aplikasi.bat"
set "SOURCE_ICON_PATH=%ROOT_SOURCE_DIR%\logo.ico"
set "SHORTCUT_ICON_PATH=%~dp0logo.ico"
set "desktop=%USERPROFILE%\Desktop"
set "SHORTCUT_PATH=%desktop%\%SHORTCUT_NAME%"
@REM must contain 'simrs' and 8 digit date format ddmmyyyy
set "SHORTCUT_DESCRIPTION=Shortcut SIMRS Khanza %NEW_VERSION%"

@REM Check if the version is up-to-date
echo Set objShell = CreateObject("Shell.Application") > %temp%\checkShortcuts.vbs
echo Set objFolder = objShell.NameSpace("%desktop%") >> %temp%\checkShortcuts.vbs
echo Set colItems = objFolder.Items >> %temp%\checkShortcuts.vbs
echo searchString = LCase("simrs") >> %temp%\checkShortcuts.vbs
echo Dim regex, matches, match >> %temp%\checkShortcuts.vbs
echo Set regex = New RegExp >> %temp%\checkShortcuts.vbs
echo regex.Pattern = "\b\d{8}\b" >> %temp%\checkShortcuts.vbs
echo regex.Global = True >> %temp%\checkShortcuts.vbs
echo For Each objItem in colItems >> %temp%\checkShortcuts.vbs
echo     If LCase(Right(objItem.Path, 4)) = ".lnk" Then >> %temp%\checkShortcuts.vbs
echo         Set objShortcut = objItem.GetLink >> %temp%\checkShortcuts.vbs
echo         strName = LCase(objItem.Name) >> %temp%\checkShortcuts.vbs
echo         description = LCase(objShortcut.Description) >> %temp%\checkShortcuts.vbs
echo         If InStr(strName, "simrs") > 0 Then >> %temp%\checkShortcuts.vbs
echo             If regex.Test(description) Then >> %temp%\checkShortcuts.vbs
echo                 Set matches = regex.Execute(description) >> %temp%\checkShortcuts.vbs
echo                 For Each match in matches >> %temp%\checkShortcuts.vbs
echo                     If match.Value = "%NEW_VERSION%" Then >> %temp%\checkShortcuts.vbs
echo                         WScript.Echo "SIMRS version is up-to-date." >> %temp%\checkShortcuts.vbs
echo                         WScript.Quit(1) >> %temp%\checkShortcuts.vbs
echo                     End If >> %temp%\checkShortcuts.vbs
echo                 Next >> %temp%\checkShortcuts.vbs
echo             End If >> %temp%\checkShortcuts.vbs
echo         End If >> %temp%\checkShortcuts.vbs
echo     End If >> %temp%\checkShortcuts.vbs
echo Next >> %temp%\checkShortcuts.vbs
cscript //nologo %temp%\checkShortcuts.vbs
if %errorlevel% neq 0 (
    del %temp%\checkShortcuts.vbs
    echo SIMRS version is up-to-date.
    pause
    exit /b
)
del %temp%\checkShortcuts.vbs

@REM Check user confirmation to update
set "choice="
set /p choice="Update ke versi %NEW_VERSION%? (Y/n): "
if /i "%choice%" neq "Y" (
    echo Anda memilih tidak.
    pause
    exit /b
)

@REM Create target directory if it does not exist
if not exist "%TARGET_DIR%" (
    mkdir "%TARGET_DIR%"
)

@REM Copy logo and new version files
xcopy "%SOURCE_ICON_PATH%" . /Y
xcopy "%SOURCE_DIR%\*" "%TARGET_DIR%\" /I /Y /E /H
echo.
echo -----------------------------
echo [+] success: Copy completed from %SOURCE_DIR% to %TARGET_DIR%.

@REM Create shortcut using VBScript
set "VBS_FILE=%TEMP%\create_shortcut.vbs"
(
    echo Set WshShell = WScript.CreateObject^("WScript.Shell"^)
    echo Set Shortcut = WshShell.CreateShortcut^("%SHORTCUT_PATH%"^)
    echo Shortcut.TargetPath = "%SHORTCUT_SCRIPT_PATH%"
    echo Shortcut.WorkingDirectory = "%TARGET_DIR%"
    echo Shortcut.WindowStyle = 1
    echo Shortcut.IconLocation = "%SHORTCUT_ICON_PATH%"
    echo Shortcut.Description = "%SHORTCUT_DESCRIPTION%"
    echo Shortcut.Save
) > "%VBS_FILE%"
cscript /nologo "%VBS_FILE%"
del "%VBS_FILE%"

echo [+] success: Shortcut created.

@REM Delete old shortcuts not matching the new version
echo Set objShell = CreateObject("Shell.Application") > %temp%\modifyShortcuts.vbs
echo Set objFolder = objShell.NameSpace("%desktop%") >> %temp%\modifyShortcuts.vbs
echo Set colItems = objFolder.Items >> %temp%\modifyShortcuts.vbs
echo searchString = LCase("simrs") >> %temp%\modifyShortcuts.vbs
echo Dim regex, matches, match >> %temp%\modifyShortcuts.vbs
echo Set regex = New RegExp >> %temp%\modifyShortcuts.vbs
echo regex.Pattern = "\b\d{8}\b" >> %temp%\modifyShortcuts.vbs
echo regex.Global = True >> %temp%\modifyShortcuts.vbs
echo For Each objItem in colItems >> %temp%\modifyShortcuts.vbs
echo     If LCase(Right(objItem.Path, 4)) = ".lnk" Then >> %temp%\modifyShortcuts.vbs
echo         Set objShortcut = objItem.GetLink >> %temp%\modifyShortcuts.vbs
echo         strName = LCase(objItem.Name) >> %temp%\modifyShortcuts.vbs
echo         description = LCase(objShortcut.Description) >> %temp%\modifyShortcuts.vbs
echo         If InStr(strName, "simrs") > 0 And Not InStr(description, "%NEW_VERSION%") > 0 Then >> %temp%\modifyShortcuts.vbs
echo             objItem.InvokeVerb("delete") >> %temp%\modifyShortcuts.vbs
echo         End If >> %temp%\modifyShortcuts.vbs
echo     End If >> %temp%\modifyShortcuts.vbs
echo Next >> %temp%\modifyShortcuts.vbs
cscript //nologo %temp%\modifyShortcuts.vbs
del %temp%\modifyShortcuts.vbs

echo [+] success: Old shortcuts deleted.

@REM Delete directories exceeding the count to keep
set count=0
@REM Iterate current directory
for /d %%i in (*) do (
    echo %%i | findstr /ri "simrs.*[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]" >nul
    if !errorlevel! == 0 (
        set "dirs[!count!]=%%i"
        set /a count+=1
    )
)
if %count% == 0 (
    echo No matching directories found.
    goto end
)
for /l %%i in (0,1,%count%-1) do (
    for /l %%j in (%%i+1,1,%count%-1) do (
        set "dir1=!dirs[%%i]!"
        set "dir2=!dirs[%%j]!"
        set "date1=!dir1:~-8,2!!dir1:~-10,2!!dir1:~-4!"
        set "date2=!dir2:~-8,2!!dir2:~-10,2!!dir2:~-4!"
        if !date1! LSS !date2! (
            set "temp=!dirs[%%i]!"
            set "dirs[%%i]=!dirs[%%j]!"
            set "dirs[%%j]=!temp!"
        )
    )
)
for /l %%i in (%COUNT_OF_LATEST_VERSION_TO_KEEP%,1,%count%-1) do (
    if defined dirs[%%i] (
        echo Deleting old directory: !dirs[%%i]!
        rmdir /s /q "!dirs[%%i]!"
    )
)

:end
echo [+] success: Cleanup completed.
echo [+] success: Already updated to version %NEW_VERSION%.
echo -----------------------------
echo.
pause
endlocal
