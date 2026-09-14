# Global settings
set shell := ["bash", "-eu", "-o", "pipefail", "-c"]
set unstable := true

# Tooling knobs (overridable via env)
TT := env_var_or_default("TT", "tt")
TT_JOBS := env_var_or_default("TT_JOBS", "4")
TYPST := env_var_or_default("TYPST", "typst")
TYPSTYLE := env_var_or_default("TYPSTYLE", "typstyle")

# Paths
THUMB_SRC := "tests/demo/test.typ"
THUMB_OUT := "thumbnail.png"
THEME_SRC := "tests/theme-gallery/test.typ"
THEME_OUT := "themeshots.png"
DEMO_SRC := "tests/demo/test.typ"
DEMO_OUT := "build/demo.pdf"

# Aliases
alias c := check
alias f := fmt
alias t := test
alias w := watch

# Default entrypoint
[default]
help:
  @just --list --unsorted

# ---------------------------- CI / quality ----------------------------

# Format all Typst files
[group('ci')]
fmt:
  rg --files -g '*.typ' | xargs -r {{TYPSTYLE}} --inplace

# Check formatting without modifying files
[group('ci')]
fmt-check:
  rg --files -g '*.typ' | xargs -r {{TYPSTYLE}} --check

# Run all quality checks
[group('ci')]
check: fmt-check test

# Run tests with optional arguments
[group('ci')]
test *args:
  {{TT}} run --jobs {{TT_JOBS}} {{args}}

# Accept test outputs as new references
[group('ci')]
accept *args:
  {{TT}} accept {{args}}

# ---------------------------- Dev UX ----------------------------

# Watch for changes and run tests automatically
[group('dev')]
watch *args:
  watchexec \
    --watch . \
    --clear \
    --delay-run 5s \
    --ignore 'tests/**/diff/**' \
    --ignore 'tests/**/out/**' \
    --ignore 'tests/**/ref/**' \
    "{{TT}} run --jobs {{TT_JOBS}} {{args}}"

# ---------------------------- Artifacts ----------------------------

# Build demo.typ -> demo.pdf
[group('artifacts')]
demo:
  mkdir -p "$(dirname {{DEMO_OUT}})"
  {{TYPST}} compile --root . {{DEMO_SRC}} {{DEMO_OUT}}
  @echo "Wrote {{DEMO_OUT}}"

# Build all preview images
# Build all preview images
[group('artifacts')]
images:
  {{TT}} run theme-gallery && cp tests/theme-gallery/out/*.png {{THEME_OUT}}
  {{TT}} run demo && cp tests/demo/out/*.png {{THUMB_OUT}}

# ---------------------------- Housekeeping ----------------------------

# Remove all generated test files and build artifacts
[group('housekeeping')]
clean:
  rg --files tests -g '**/diff/**' -g '**/out/**' 2>/dev/null \
    | xargs -r dirname \
    | sort -u \
    | xargs -r bash -c 'for d; do echo "Removing files under: $d"; rm -rf -- "$d"/*; done' _ \
    || true
  rm -rf build

# ---------------------------- Release tooling ----------------------------

# Bump version by level (major|minor|patch) or to explicit version
[group('release')]
[script("python3")]
bump version_or_level:
  import re
  from pathlib import Path

  arg = "{{version_or_level}}".strip()
  if not arg:
      raise SystemExit("Usage: just bump <major|minor|patch|x.y.z>")

  # If it's a level keyword, calculate the new version
  if arg.lower() in {"major", "minor", "patch"}:
      level = arg.lower()
      data = Path("typst.toml").read_text()
      m = re.search(r'^version\s*=\s*"([^"]+)"', data, re.MULTILINE)
      if not m:
          raise SystemExit("Could not find current version in typst.toml")

      major, minor, patch = map(int, m.group(1).split("."))
      old_version = m.group(1)

      if level == "major":
          major, minor, patch = major + 1, 0, 0
      elif level == "minor":
          major, minor, patch = major, minor + 1, 0
      else:
          patch += 1

      version = f"{major}.{minor}.{patch}"
      print(f"Bumping {level} version: {old_version} → {version}")
  else:
      # It's an explicit version
      version = arg
      print(f"Setting version to {version}")

  # Update files
  def update(path: Path, pattern: re.Pattern):
      text = path.read_text()
      new_text, count = pattern.subn(lambda m: m.group(1) + version + m.group(3), text, count=1)
      if count == 0:
          raise SystemExit(f"Failed to update {path}")
      path.write_text(new_text)

  update(Path("typst.toml"), re.compile(r'^(version\s*=\s*")([^"]+)(")', re.MULTILINE))
  update(Path("README.md"), re.compile(r'(#import "@preview/glossy:)([^"]+)(": \*)'))
  print(f"Updated typst.toml and README.md")


# Run full pre-submission checks
[group('release')]
pre-submit: clean images check
