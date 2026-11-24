#
# packageLocally.py
#
# Copies the template directory to the local Typst package installation folder. The OS-based folders are specified in the Typst packaging documentation:
#
#   https://github.com/typst/packages?tab=readme-ov-file#local-packages
#
# Run the script without arguments to show usage instructions.
#

import re
import platform
import sys
from pathlib import Path

def isValidSemanticVersion(version):
    """Check if the version string follows the semantic versioning scheme MAJOR.MINOR.PATCH."""
    pattern = r'^\d+\.\d+\.\d+$'
    return re.match(pattern, version) is not None

def detectOs():
    """Detect the operating system and return the appropriate application data path."""
    import os
    osName = platform.system().lower()
    if osName == 'linux':
        # Use $XDG_DATA_HOME or ~/.local/share on Linux
        xdgDataHome = Path(os.environ.get('XDG_DATA_HOME', '~/.local/share')).expanduser()
        return xdgDataHome
    elif osName == 'darwin':
        # Use ~/Library/Application Support on macOS
        return Path("~/Library/Application Support").expanduser()
    elif osName == 'windows':
        # Use %APPDATA% on Windows
        appData = Path(os.environ['APPDATA'])
        return appData
    else:
        # Exit with an error code for unknown OS
        print(f"Error: Unrecognized operating system: {osName}")
        sys.exit(1)

def removeDirectory(directory):
    """Remove a directory and all its contents."""
    for item in directory.iterdir():
        if item.is_dir():
            removeDirectory(item)
        else:
            item.unlink()
    directory.rmdir()

def copyDirectory(source, destination):
    """Copy a directory and all its contents to a destination."""
    destination.mkdir(parents=True, exist_ok=True)
    for item in source.iterdir():
        if item.is_dir():
            copyDirectory(item, destination / item.name)
        else:
            (destination / item.name).write_bytes(item.read_bytes())

def copyPackage(packageVersion, dataDir):
    """Copy the package to the example folder based on the OS."""
    # Get the directory of the script
    scriptDir = Path(__file__).parent

    # Define source path as the parent directory of the script directory
    sourcePath = scriptDir.parent

    # Check if the source path exists
    if not sourcePath.exists():
        print(f"Error: The source directory {sourcePath} does not exist.")
        return

    # Define the destination path as {data-dir}/typst/packages/preview/scholarly-tauthesis/{version}
    destinationPath = dataDir / "typst" / "packages" / "preview" / "scholarly-tauthesis" / packageVersion

    # Remove the destination folder if it exists
    if destinationPath.exists():
        print(f"The local template installation path {destinationPath} exists. Removing...")
        removeDirectory(destinationPath)

    # Copy the entire directory tree
    try:
        copyDirectory(sourcePath, destinationPath)
        print(f"Template copied successfully to {destinationPath}")
    except Exception as error:
        print(f"An error occurred: {error}")

def main():
    if len(sys.argv) != 2:
        print("Usage: python3 path/to/packageLocally.py <package_version>")
        sys.exit(1)

    packageVersion = sys.argv[1]

    if not isValidSemanticVersion(packageVersion):
        print("Error: The package version must follow the semantic versioning scheme MAJOR.MINOR.PATCH.")
        sys.exit(1)

    dataDir = detectOs()

    print(f"Local template installation directory: {dataDir}")
    copyPackage(packageVersion, dataDir)

if __name__ == "__main__":
    main()
