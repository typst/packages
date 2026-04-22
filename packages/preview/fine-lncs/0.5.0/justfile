default:
    @just --list

# Symlink this template into the local @preview package dir (typship dev)
dev:
    typship dev

# Install this template locally as @local/fine-lncs (typship install local)
install:
    typship install local

# Format all .typ files in place
fmt:
    typstyle -i .

# Check formatting without modifying files (same as CI)
fmt-check:
    typstyle --check .

# Regenerate tests/template/test.typ and tests/readme/test.typ
gen-tests:
    ./scripts/gen-tests.sh

# Regenerate, then fail if the committed copies drift (CI drift check)
gen-tests-check:
    ./scripts/gen-tests.sh --check

# Run the test suite
test:
    tt run

# Bump the package version across VERSION, typst.toml, template, and README
bump version:
    ./scripts/bump-version.sh {{version}}

# Run everything CI runs
ci: fmt-check gen-tests-check test

# Run release pre-flight checks without publishing
release-check:
    ./scripts/release.sh --dry-run

# Run release pre-flight checks and publish via typship
release:
    ./scripts/release.sh
