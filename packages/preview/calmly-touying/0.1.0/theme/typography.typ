// Typography Settings - Refined & Elegant
// Optimized for readability with generous breathing room
// Includes golden ratio spacing utilities inspired by Moloch

// =============================================================================
// GOLDEN RATIO UTILITIES
// =============================================================================

// The golden ratio constant (φ ≈ 1.618)
#let phi = 1.618033988749895

// Golden ratio spacing - mathematically pleasing proportions
// Use for title pages and special layouts
#let golden-space-above = 1fr * phi  // Larger space above
#let golden-space-below = 1fr        // Smaller space below

// Golden ratio helper for vertical centering with offset
// Creates mathematically-informed spacing above/below content
#let golden-center(body) = {
  v(golden-space-above)
  body
  v(golden-space-below)
}

// Golden ratio proportions for layouts
#let golden-major = phi / (1 + phi)  // ~0.618 (larger portion)
#let golden-minor = 1 / (1 + phi)    // ~0.382 (smaller portion)

// Split layout using golden ratio (e.g., for title pages)
#let golden-split-left = golden-minor * 100%   // ~38.2%
#let golden-split-right = golden-major * 100%  // ~61.8%

// =============================================================================
// FONT FAMILIES
// =============================================================================

// Font families (prioritize installed fonts)
#let font-heading = ("Source Sans 3", "Inter", "Noto Sans", "sans-serif")
#let font-body = ("Source Sans 3", "Inter", "Noto Sans", "sans-serif")
#let font-mono = ("JetBrains Mono", "Fira Code", "Noto Sans Mono", "monospace")
#let font-math = ("STIX Two Math", "Latin Modern Math")

// Type scale - refined sizing with more contrast
#let size-display = 42pt       // Hero text
#let size-title = 34pt         // Section/title slides
#let size-slide-title = 26pt   // Slide headings
#let size-subtitle = 18pt      // Subtitles
#let size-body = 17pt          // Body text
#let size-small = 15pt         // Smaller body
#let size-caption = 13pt       // Captions, labels
#let size-code = 13pt          // Code blocks
#let size-footnote = 11pt      // Footnotes
#let size-focus = 38pt         // Focus slide text
#let size-micro = 10pt         // Very small text

// Font weights - using lighter weights for elegance
#let weight-black = 900
#let weight-bold = 700
#let weight-semibold = 600
#let weight-medium = 500
#let weight-regular = 400
#let weight-light = 300

// Spacing constants - generous whitespace
#let spacing-3xs = 2pt
#let spacing-2xs = 4pt
#let spacing-xs = 6pt
#let spacing-sm = 10pt
#let spacing-md = 16pt
#let spacing-lg = 24pt
#let spacing-xl = 36pt
#let spacing-2xl = 48pt
#let spacing-3xl = 64pt

// Border radius - softer, more rounded
#let radius-sm = 6pt
#let radius-md = 10pt
#let radius-lg = 14pt
#let radius-xl = 20pt
#let radius-full = 9999pt

// Line heights
#let leading-tight = 1.15
#let leading-snug = 1.3
#let leading-normal = 1.5
#let leading-relaxed = 1.7

// Letter spacing
#let tracking-tight = -0.02em
#let tracking-normal = 0em
#let tracking-wide = 0.02em
#let tracking-wider = 0.04em

// Paragraph spacing
#let par-spacing = 0.8em
