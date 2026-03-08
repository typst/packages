# The template testing is broken, so it's not tested. However, there is a
# duplicate "template" test that is "persistent" instead of just
# "compile-only". The only source code difference is the relative paths for
# dependent files/imports.
# https://github.com/typst-community/tytanic/issues/184

export TYPST_FONT_PATHS := "fonts"

# Ability to use "$@" in recipes to correctly handle quotes/spaces in arguments.
set positional-arguments

PREVIEW_DIR := shell(
  'typst info 2>&1 | grep "$1" | sed "$2"',
  '^\s*Package cache path',
  's/^.*Package cache path\s*//',
) / 'preview'

PACKAGE_NAME := shell(
  'grep "$1" typst.toml | sed -E "$2"',
  '^name',
  's/[^"]+"([^"]+)".*/\1/',
)

PACKAGE_VERSION := shell(
  'grep "$1" typst.toml | grep -o "$2"',
  '^version',
  '[0-9]\+\.[0-9]\+\.[0-9]\+',
)

PRE_COMMIT_SCRIPT := "\
#!/bin/sh
set -eu
# Run tests.
just test
# Format files.
if ! just format --check; then
  just format
  echo 'Include new formatting changes.'
  exit 1
fi
"

alias t := test
alias st := search-test
alias ut := update-test
alias f := format
alias i := install
alias un := uninstall
alias init := pre-commit
alias uv := update-version

default: test

# Automatically use local binary over global one, if present. For more
# information (including used version), see Testing section in ./README.md.
tt := shell("if [ -f tt ]; then echo ./tt; else echo tt; fi")

# Use Tytanic with exported environment variables.
tt *args:
  {{tt}} "$@"

# Run tests.
test *args: pre-commit
  {{tt}} run "$@"

# Run tests that match given regex.
search-test *args:
  just test --expression 'regex:{{args}}'

# Update tests.
update-test *args: pre-commit
  {{tt}} update "$@"

format action="--inplace":
  typstyle '{{action}}' ./template/paper.typ ./tests/*/test.typ
  typstyle '{{action}}' --wrap-text *.typ ./tests/*.typ

# Install the package by linking it to this repository.
install:
  mkdir -p '{{PREVIEW_DIR / PACKAGE_NAME}}'
  rm -rf '{{PREVIEW_DIR / PACKAGE_NAME / PACKAGE_VERSION}}'
  ln -s "$PWD" '{{PREVIEW_DIR / PACKAGE_NAME / PACKAGE_VERSION}}'
  @ echo
  @ echo 'Installed. To uninstall run:'
  @ echo 'just uninstall'

# Uninstall the package allowing the upstream version to be used.
uninstall:
  rm -rf '{{PREVIEW_DIR / PACKAGE_NAME / PACKAGE_VERSION}}'
  @ echo
  @ echo 'Uninstalled.'

# Initialize the pre-commit Git hook, overriding (potentially) existing one.
pre-commit:
  @ echo '{{PRE_COMMIT_SCRIPT}}' > .git/hooks/pre-commit
  @ chmod +x .git/hooks/pre-commit

# Before creating a package update, update the version with this recipe.
update-version version:
  #!/bin/sh
  set -eu
  old=$(grep 'version =' typst.toml | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+')
  new='{{version}}'
  [ "$new" = "old" ] && exit
  sed -i "/version =/s/$old/$new/" typst.toml
  sed -i "/@preview/s/$old/$new/" README.md template/paper.typ
  if ! grep -qF "[$new]:" CHANGELOG.md; then
    url=$(sed -n '/\[unreleased\]: /s/\[unreleased\]: //;'"s/HEAD/$new/p" CHANGELOG.md)
    sed -i '/\[unreleased\]: /'"s/$old/$new/" CHANGELOG.md
    sed -i "/\\[$old\\]:/i[$new]: $url" CHANGELOG.md
    sed -i '/## \[Unreleased\]/a'"\\
  \\
  ## [$new]" CHANGELOG.md
  fi
