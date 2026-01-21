root := justfile_directory()

export TYPST_ROOT := root

[private]
default:
	@just --list --unsorted

# Package the library into the specified destination folder
package target:
  ./scripts/package "{{target}}"

# Install the library with the "@local" prefix
install: (package "@local")

# Install the library with the "@preview" prefix (for pre-release testing)
install-preview: (package "@preview")

[private]
remove target:
  ./scripts/uninstall "{{target}}"

# Uninstalls the library from the "@local" prefix
[confirm("Are you sure you want to uninstall the library \"@local\"? This will remove all files and directories associated with the library.")]
uninstall: (remove "@local")

# Uninstalls the library from the "@preview" prefix (for pre-release testing)
[confirm("Are you sure you want to uninstall the library \"@preview\"? This will remove all files and directories associated with the library.")]
uninstall-preview: (remove "@preview")
