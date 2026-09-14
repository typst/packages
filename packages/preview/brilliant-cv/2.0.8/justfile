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

# Bump package version - usage: just bump patch|minor|major
bump VERSION:
    @echo "⬆️  Bumping {{VERSION}} version..."
    @utpm ws bump {{VERSION}}
    @echo "✅ Version bumped!"

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
