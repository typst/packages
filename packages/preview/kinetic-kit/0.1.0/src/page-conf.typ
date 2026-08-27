// page-conf.typ — static page layout constants for KIT dissertation template

// Page dimensions per format. All formats use explicit width/height (170×240 mm has no
// Typst named paper type, so explicit dimensions keep the approach uniform).
#let page-dimensions-by-format = (
    a5: (width: 148mm, height: 210mm),
    "17x24": (width: 170mm, height: 240mm),
    a4: (width: 210mm, height: 297mm),
)

#let margins-by-format = (
    a5: (
        short: (top: 25mm, bottom: 22mm, inside: 20mm, outside: 15mm),
        medium: (top: 25mm, bottom: 22mm, inside: 23mm, outside: 15mm),
        long: (top: 25mm, bottom: 22mm, inside: 25mm, outside: 15mm),
    ),
    "17x24": (
        short: (top: 25mm, bottom: 22mm, inside: 20mm, outside: 15mm),
        medium: (top: 25mm, bottom: 22mm, inside: 23mm, outside: 15mm),
        long: (top: 25mm, bottom: 22mm, inside: 25mm, outside: 15mm),
    ),
    a4: (
        short: (top: 35mm, bottom: 30mm, inside: 35mm, outside: 25mm),
        medium: (top: 35mm, bottom: 30mm, inside: 35mm, outside: 25mm),
        long: (top: 35mm, bottom: 30mm, inside: 35mm, outside: 25mm),
    ),
)

#let title-page-margins-by-format = (
    a5: (top: 20mm, bottom: 25mm, inside: 22mm, outside: 18mm),
    "17x24": (top: 20mm, bottom: 25mm, inside: 22mm, outside: 18mm),
    a4: (top: 35mm, bottom: 30mm, inside: 35mm, outside: 25mm),
)

#let par-spacing = 1.0em
