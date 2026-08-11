@echo off
setlocal enabledelayedexpansion

:: Define variables
set "PACKAGE_NAME=modern-fzu-thesis"
set "PACKAGE_VERSION=0.1.0"
set "NAMESPACE=local"
set "SCRIPT_DIR=%~dp0"
set "SOURCE_DIR=%SCRIPT_DIR%.."
set "TARGET_DIR=%APPDATA%\typst\packages\%NAMESPACE%\%PACKAGE_NAME%\%PACKAGE_VERSION%"

:: Display information
echo ===== Fuzhou University Thesis Template Installation Script =====
echo Source directory: %SOURCE_DIR%
echo Target directory: %TARGET_DIR%

:: Create target directory
if not exist "%TARGET_DIR%" (
    mkdir "%TARGET_DIR%"
    if errorlevel 1 (
        echo Error: Unable to create target directory
        exit /b 1
    )
)

:: Copy files to target directory
echo Copying files...
xcopy "%SOURCE_DIR%\*" "%TARGET_DIR%" /E /I /Y
if errorlevel 1 (
    echo Error: Failed to copy files
    exit /b 1
)

echo Installation complete!
echo You can import the template in your Typst file using:
echo #import "@%NAMESPACE%/%PACKAGE_NAME%:%PACKAGE_VERSION%": *
echo Or create a new document using the template: typst init @%NAMESPACE%/%PACKAGE_NAME%

pause