// Every theme with its neutral value (no effect). Presets and user settings
// are merged on top of this; it also defines the accepted keys and types.
#let base = (
  paper: (
    color: white,
    grain: 0,
    aging: 0, // yellowing, foxing
    fibers: 0,
  ),
  stains: (
    color: rgb("#8b5a2b"),
    amount: 0,
    size: (min: 2mm, max: 15mm),
    dust: 0,
    scratches: 0,
  ),
  ink: (
    bleed: 0,
    fade: 0,
    legibility: 1, // 1 = sharp, 0 = barely readable
    wear: 0, // toner dropouts / worn ribbon
    ghosting: false, // offset copies; duplicates text for some extractors
  ),
  skew: (
    page-rotation: 0deg, // maximum, drawn per page
    line-jitter: 0deg, // rotation per block ("line") or per word ("word")
    char-jitter: 0pt, // offset per word / char
    drift: 0, // 0 = independent pages, 1 = slowly wandering angle
  ),
  edges: (
    shadow: 0,
    vignette: 0,
    uneven: 0, // uneven lighting (phone photos)
    binding: false,
    punch-holes: false,
  ),
  scanner: (
    lines: 0, // fax lines
    bands: 0, // photocopier bands
  ),
  quality: (
    resolution: 150, // dpi
    tile: true, // share textures across pages
    granularity: "line", // "page", "line", "word" or "char"
  ),
)

// Presets only list what differs from `base`.
#let presets = (
  clean-scan: (
    paper: (color: rgb("#fdfcf8"), grain: 0.15),
    ink: (bleed: 0.1),
    skew: (page-rotation: 0.25deg, line-jitter: 0.03deg, drift: 0.5),
    edges: (shadow: 0.1),
  ),
  office-scan: (
    paper: (color: rgb("#f7f5ef"), grain: 0.35, aging: 0.05),
    stains: (amount: 0.1, dust: 0.25),
    ink: (bleed: 0.3, fade: 0.15, legibility: 0.95),
    skew: (page-rotation: 0.6deg, line-jitter: 0.1deg, drift: 0.3),
    edges: (shadow: 0.5, vignette: 0.2),
  ),
  photocopy: (
    paper: (color: rgb("#f3f3f0"), grain: 0.5),
    stains: (color: luma(90), amount: 0.05, dust: 0.7, scratches: 0.4),
    ink: (bleed: 0.75, fade: 0.1, legibility: 0.8, wear: 0.2),
    skew: (page-rotation: 1deg, line-jitter: 0.15deg, drift: 0.2),
    edges: (shadow: 0.8, vignette: 0.3),
    scanner: (bands: 0.6),
  ),
  fax: (
    paper: (color: rgb("#fbfbf7"), grain: 0.3),
    stains: (dust: 0.5),
    ink: (bleed: 0.8, fade: 0.35, legibility: 0.6, wear: 0.45),
    skew: (page-rotation: 0.9deg, line-jitter: 0.3deg, char-jitter: 0.3pt),
    edges: (shadow: 0.2),
    scanner: (lines: 0.7),
    quality: (granularity: "word"),
  ),
  typewriter: (
    paper: (color: rgb("#f5f0e1"), grain: 0.3, aging: 0.15, fibers: 0.3),
    stains: (amount: 0.05),
    ink: (bleed: 0.45, fade: 0.55, legibility: 0.85, wear: 0.35),
    skew: (page-rotation: 0.3deg, char-jitter: 0.7pt),
    quality: (granularity: "char"),
  ),
  old-paper: (
    paper: (color: rgb("#efe3c8"), grain: 0.45, aging: 0.7, fibers: 0.5),
    stains: (color: rgb("#7a4e24"), amount: 0.5, dust: 0.3),
    ink: (bleed: 0.3, fade: 0.4, legibility: 0.85),
    skew: (page-rotation: 0.8deg, line-jitter: 0.1deg, drift: 0.4),
    edges: (shadow: 0.3, vignette: 0.5),
  ),
  // No true perspective in Typst: slight skew and uneven light only.
  phone-scan: (
    paper: (color: rgb("#f4f2ec"), grain: 0.25),
    ink: (bleed: 0.2, fade: 0.1),
    skew: (page-rotation: 1.5deg, line-jitter: 0.1deg),
    edges: (shadow: 0.3, vignette: 0.6, uneven: 0.7),
  ),
)
