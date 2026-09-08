// Font configuration for KIT dissertation template
// As recommended by KIT Scientific Publishing (KSP), sizes vary by paper format.

#let fonts = (
    serif: ("Libertinus Serif",),
    sans: ("Libertinus Sans",),
    mono: ("Libertinus Mono",),
)

// Font sizes per paper format as per KSP Handbook p. 13 (native, no scaling).
#let font-sizes-by-format = (
    a5: (
        // Main content
        base: 10pt,
        chapter: 18pt,
        section: 14pt,
        subsection: 12pt,
        subsubsection: 10pt,
        // Title page
        title: 18pt,
        author: 14pt,
        title-info: 14pt,
        // Auxiliary
        small: 8pt,
        footnote: 8pt,
    ),
    "17x24": (
        base: 10pt,
        chapter: 20pt,
        section: 15pt,
        subsection: 13pt,
        subsubsection: 10pt,
        title: 20pt,
        author: 14pt,
        title-info: 14pt,
        small: 8pt,
        footnote: 8pt,
    ),
    a4: (
        base: 11pt,
        chapter: 25pt,
        section: 17pt,
        subsection: 14pt,
        subsubsection: 11pt,
        title: 25pt,
        author: 14pt,
        title-info: 14pt,
        small: 9pt,
        footnote: 9pt,
    ),
)

// Line spacing: 1.15× — em-based so it scales automatically with the base font size.
// Typst `leading` is the gap between baseline and next baseline minus cap-height,
// so 0.75em ≈ 7.5 pt at 10 pt base, giving ~11.5 pt total line height.
#let leading = 0.75em
