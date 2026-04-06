# Brilliant CV Development Justfile
# This file helps streamline development workflow for the brilliant-cv package

# Default recipe - show available commands
default:
    @just --list

# Complete development lifecycle with automatic cleanup
dev:
    @echo "🚀 Starting development lifecycle..."
    @echo "🔗 Linking workspace..."
    @just link || @echo "⚠️  Link failed or already linked"
    @echo "👁️  Starting watch mode (Ctrl+C to exit and cleanup)..."
    @echo "💡 When you exit, we'll build final version and cleanup automatically"
    @mkdir -p temp
    @trap 'echo "\n🛑 Stopping watch..."; just _dev-cleanup; exit 0' INT; \
    typst watch template/cv.typ temp/cv.pdf

# Internal cleanup function (don't call directly)
_dev-cleanup:
    @echo "🏗️  Building final version..."
    @mkdir -p temp
    @typst compile template/cv.typ temp/cv.pdf || @echo "⚠️  Build failed, but continuing cleanup..."
    @just unlink || @echo "⚠️  Unlink failed or already unlinked"
    @just clean || true
    @echo "✅ Development lifecycle complete!"
    @echo "💡 Your final CV is at temp/cv.pdf"

# Link local package for development
link:
    @echo "🔗 Linking local brilliant-cv package..."
    @utpm ws link --force --no-copy
    @echo "✅ Local package linked successfully!"
    @echo "💡 Typst will now use your local changes instead of cached version"

# Unlink local package (restore to using upstream version)
unlink:
    @echo "🔓 Unlinking local package..."
    @utpm pkg unlink --yes 2>/dev/null || @echo "💡 Package already unlinked or not found"
    @echo "✅ Local package unlinked - now using upstream version"

# Build CV template for testing
build:
    @echo "🏗️  Building CV template..."
    @mkdir -p temp
    @typst compile template/cv.typ temp/cv.pdf
    @echo "✅ CV built successfully at temp/cv.pdf"

# Build and open the result
open: build
    @echo "👀 Opening generated CV..."
    @open temp/cv.pdf

# Watch for changes and rebuild automatically
watch:
    @echo "👁️  Watching for changes in template..."
    @mkdir -p temp
    typst watch template/cv.typ temp/cv.pdf

# Sync dependencies to latest versions
sync:
    @echo "🔄 Syncing dependencies..."
    @utpm ws sync
    @echo "✅ Dependencies synced!"

# Clean build artifacts
clean:
    @echo "🧹 Cleaning build artifacts..."
    @find . -name "*.pdf" -not -path "./template/src/*" -delete
    @rm -rf temp/
    @echo "✅ Build artifacts cleaned"

# Reset development environment
reset: unlink clean
    @echo "🔄 Development environment reset"
    @echo "💡 Run 'just dev' to start development again"

# Release a new version (bump, build, commit, tag, push)
# Usage: just release 3.2.0
release version:
    #!/usr/bin/env bash
    set -euo pipefail
    VERSION="{{version}}"

    # Validate version format
    if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "❌ Invalid version format: $VERSION"
        echo "   Expected format: X.Y.Z (e.g., 3.2.0)"
        exit 1
    fi

    # Check if tag already exists
    if git tag -l "v$VERSION" | grep -q "v$VERSION"; then
        echo "❌ Tag v$VERSION already exists!"
        echo "   Use a different version number."
        exit 1
    fi

    # Check for uncommitted changes
    if ! git diff --quiet || ! git diff --cached --quiet; then
        echo "⚠️  You have uncommitted changes:"
        git status --short
        echo ""
        read -p "Continue anyway? [y/N] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Aborted."
            exit 1
        fi
    fi

    # Show what will happen
    CURRENT=$(grep '^version = ' typst.toml | sed 's/version = "\(.*\)"/\1/')
    echo "🚀 Release Summary:"
    echo "   Current version: $CURRENT"
    echo "   New version:     $VERSION"
    echo "   Branch:          $(git branch --show-current)"
    echo ""
    read -p "Proceed with release? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 1
    fi

    # Do the release
    echo ""
    just bump "$VERSION"
    just build
    git add -A
    git commit -m "build: bump version to $VERSION"
    git tag "v$VERSION"
    git push origin main --tags
    echo ""
    echo "🎉 Version $VERSION released!"

# Bump version in all files
# Usage: just bump 3.2.0
bump version:
    @echo "📦 Bumping version to {{version}}..."
    @# Update typst.toml
    @sed -i '' 's/^version = ".*"/version = "{{version}}"/' typst.toml
    @echo "  ✓ typst.toml"
    @# Update all template imports
    @find template docs -name "*.typ" -exec sed -i '' 's/@preview\/brilliant-cv:[0-9]*\.[0-9]*\.[0-9]*/@preview\/brilliant-cv:{{version}}/g' {} \;
    @echo "  ✓ template/*.typ and docs/*.typ files"
    @echo "✅ Version bumped to {{version}}"
    @echo ""
    @echo "📋 Next steps:"
    @echo "   1. git add -A && git commit -m 'build: bump version to {{version}}'"
    @echo "   2. git tag v{{version}}"
    @echo "   3. git push origin main --tags"

# Check that all version references are consistent
check-version:
    #!/usr/bin/env bash
    set -euo pipefail
    TOML_VERSION=$(grep '^version = ' typst.toml | sed 's/version = "\(.*\)"/\1/')
    echo "📦 Version in typst.toml: $TOML_VERSION"
    echo ""
    MISMATCHED=()
    # Find files with actual version numbers (not <version> placeholders)
    while IFS= read -r file; do
        # Skip files that only have placeholder versions like <version>
        if grep -q "@preview/brilliant-cv:[0-9]" "$file" 2>/dev/null; then
            if ! grep -q "@preview/brilliant-cv:$TOML_VERSION" "$file" 2>/dev/null; then
                MISMATCHED+=("$file")
            fi
        fi
    done < <(find template docs -name "*.typ" -exec grep -l "@preview/brilliant-cv:" {} \;)
    if [ ${#MISMATCHED[@]} -eq 0 ]; then
        echo "✅ All version references are consistent!"
        exit 0
    else
        echo "❌ Version mismatch in ${#MISMATCHED[@]} files:"
        for file in "${MISMATCHED[@]}"; do
            FOUND=$(grep -o "@preview/brilliant-cv:[0-9]*\.[0-9]*\.[0-9]*" "$file" | head -1)
            echo "   $file → $FOUND"
        done
        echo ""
        echo "💡 Run: just bump $TOML_VERSION"
        exit 1
    fi

# Compare PDFs for visual regression testing
# Usage: just compare <baseline.pdf> <new.pdf>
compare baseline new:
    @echo "🔍 Comparing PDFs..."
    @mkdir -p temp/compare
    @if diff-pdf "{{baseline}}" "{{new}}"; then \
        echo "✅ PDFs are IDENTICAL - no visual changes"; \
    else \
        echo "⚠️  PDFs DIFFER - generating visual diff..."; \
        diff-pdf --output-diff=temp/compare/diff.pdf "{{baseline}}" "{{new}}" || true; \
        echo "📄 Visual diff saved to temp/compare/diff.pdf"; \
        echo "👀 Opening files for review..."; \
        open "{{baseline}}" "{{new}}" temp/compare/diff.pdf; \
    fi

# Build and compare against a baseline PDF
compare-build baseline:
    @echo "🏗️  Building current version..."
    @just build
    @just compare "{{baseline}}" temp/cv.pdf
