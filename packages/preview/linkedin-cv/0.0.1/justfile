default: cv

name := "your-name"

cv:
    @echo "🔄 Watching Typst files for changes..."
    mkdir -p build
    typst watch --font-path fonts example/cv.typ build/{{name}}-cv.pdf --root .

build:
    typst compile --font-path fonts example/cv.typ build/{{name}}-cv.pdf --root .
    @echo "✓ Typst CV built: build/{{name}}-cv.pdf"

dev:
    @echo "Starting Typst in watch mode with auto-open..."
    @open build/{{name}}-cv.pdf 2>/dev/null || true
    typst watch --font-path fonts example/cv.typ build/{{name}}-cv.pdf --root .

init:
    mkdir -p build
    @echo "✓ Build directory ready"

regenerate-icons:
    @echo "Regenerating tech icons module from vector-icons/..."
    python3 generate_tech_icons.py
    @echo "✓ Tech icons regenerated - lib/tech-icons.typ updated"
