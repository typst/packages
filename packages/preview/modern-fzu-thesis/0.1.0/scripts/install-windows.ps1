# Fuzhou University Thesis Template Installation Script (PowerShell)

# Define variables
$PACKAGE_NAME = "modern-fzu-thesis"
$PACKAGE_VERSION = "0.1.0"
$NAMESPACE = "local"
$SCRIPT_PATH = $MyInvocation.MyCommand.Path
$SCRIPT_DIR = Split-Path -Parent $SCRIPT_PATH
$SOURCE_DIR = Split-Path -Parent $SCRIPT_DIR
$TARGET_DIR = Join-Path -Path $env:APPDATA -ChildPath "typst\packages\$NAMESPACE\$PACKAGE_NAME\$PACKAGE_VERSION"

# Display information
Write-Host "===== Fuzhou University Thesis Template Installation Script =====" -ForegroundColor Cyan
Write-Host "Source directory: $SOURCE_DIR"
Write-Host "Target directory: $TARGET_DIR"

# Create target directory
try {
    if (-not (Test-Path -Path $TARGET_DIR)) {
        New-Item -Path $TARGET_DIR -ItemType Directory -Force | Out-Null
        Write-Host "Created target directory." -ForegroundColor Green
    }
}
catch {
    Write-Host "Error: Unable to create target directory." -ForegroundColor Red
    Write-Host $_.Exception.Message
    exit 1
}

# Copy files to target directory
Write-Host "Copying files..." -ForegroundColor Yellow
try {
    Copy-Item -Path "$SOURCE_DIR\*" -Destination $TARGET_DIR -Recurse -Force
    Write-Host "Files copied successfully." -ForegroundColor Green
}
catch {
    Write-Host "Error: Failed to copy files." -ForegroundColor Red
    Write-Host $_.Exception.Message
    exit 1
}

# Success message
Write-Host "Installation complete!" -ForegroundColor Green
Write-Host "You can import the template in your Typst file using:"
# Fix: Using proper variable interpolation with PowerShell syntax
$importString = "#import `"@${NAMESPACE}/${PACKAGE_NAME}:${PACKAGE_VERSION}`": *"
Write-Host $importString -ForegroundColor Yellow
Write-Host "Or create a new document using the template: typst init @${NAMESPACE}/${PACKAGE_NAME}" -ForegroundColor Yellow

Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")