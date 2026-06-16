@echo off
setlocal

:: The FOR /R command recursively iterates through files in subdirectories.
:: %%f is the loop variable that holds the full path to each .svg file found.
for /R .. %%f in (*.svg) do (
   
    :: Execute the Python script, passing the full file path as an argument.
    python clean-freecad-svg.py "%%f"
    
    :: The ERRORLEVEL check is optional but recommended to see if the Python script failed.
    if errorlevel 1 (
        echo.
        echo [ERROR] Python script failed for "%%f" with exit code %errorlevel%.
        echo.
    )
)

echo.
echo Operation complete.
endlocal
pause