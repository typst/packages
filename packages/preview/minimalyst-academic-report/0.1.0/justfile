root := justfile_directory()

export TYPST_ROOT := root

_default:
    @just -l

# Autoreload the generated PDF
[group: "dev"]
watch:
    @typst watch template/main.typ --root {{root}}

# package the library into the specified destination folder
[private]
package target:
  @./scripts/package.sh "{{target}}"

# install the library with the "@local" prefix (AUTORELOAD due to symlink)
[group: "build"]
local:
  @./scripts/local.sh

# install the library with the "@local" prefix (DOES NOT AUTORELOAD)
[group: "build"]
install: (package "@local")

# install the library with the "@preview" prefix (for pre-release testing)
[group: "build"]
install-preview: (package "@preview")

[private]
remove target:
  @./scripts/uninstall.sh "{{target}}"

# uninstalls the library from the "@local" prefix
[group: "build"]
uninstall: (remove "@local")

# uninstalls the library from the "@preview" prefix (for pre-release testing)
[group: "build"]
uninstall-preview: (remove "@preview")
