# justfile for nutthead-ebnf

set shell := ["bash", "-euo", "pipefail", "-c"]
set dotenv-load := true
set positional-arguments := true

# Directories
test_dir := "tests"
target_dir := "target"

# Default recipe: show available commands
@default:
    just --list

# Compile all test files to PDF
test:
    mkdir -p {{ target_dir }}
    for f in {{ test_dir }}/*.typ; do \
        echo "Compiling: $f"; \
        typst compile --root . "$f" "{{ target_dir }}/$(basename "${f%.typ}.pdf")" || exit 1; \
    done
