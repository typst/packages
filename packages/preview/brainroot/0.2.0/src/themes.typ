// Themes: everything that decides how boxes and edges look.

#import "util.typ": _merge

// --- Themes ----------------------------------------------------------------
//
// A theme decides how boxes and edges look; the colours still come from
// the palette. Fields:
//   edge      "curve" | "elbow" | "straight" | "taper" | "comb"   routing
//             of the edges: taper is a curve that thins towards the child,
//             comb a shared spine with a twig to every child
//   fill      "tint" | "solid" | "white" | "none"   fill of the boxes
//   stroke    border width of the boxes (0pt = no border)
//   radius    corner radius (may be relative, 50% = pill)
//   underline true: no box, the text sits on a coloured line and the edges
//             flow into that line
//   dash      dash pattern of the edges ("solid", "dashed", "dotted")
//   font      font of the labels; `none` inherits from the document
//   hand      `none`, or a dictionary for hand-drawn lines:
//               amplitude   excursion of the wobble in pt
//               wavelength  length of one wave in pt
//               randomness  irregularity of the rhythm (1 = pure sine)
//               segment     step along the path in pt
//               passes      how often each line is drawn (2 = "scribbled")
//   shape     "rect" | "circle" | "ellipse"   shape of the boxes
//   size      `none`, or an array of lengths per depth: a fixed diameter
//             (width for ellipses) instead of a size fitted to the text
//   taper     for `edge: "taper"`: (start, end) factors on the level's
//             `thickness` at the parent and at the child
//   root      overrides for the root only (fill, stroke, radius, shape, size)
//   branches  the same overrides for the first level only

/// The built-in themes: `soft`, `outline`, `blocks`, `lines`, `sketch`,
/// `bubbles`, `hand`, `scribble`, `marker`, `pencil`, `organic`, `twigs`.
/// A theme is a dictionary of everything that decides how boxes and edges
/// look; each preset sets only what differs from the defaults, see
/// `theme-defaults` for the full list of fields. Adapt one with
/// `theme: (base: "hand", hand: (amplitude: 1))`.
///
/// -> dictionary
#let themes = (
  // Pastel boxes, soft S-curves -- the whiteboard original.
  soft: (edge: "curve", fill: "tint", stroke: 0pt, radius: 8pt, underline: false, dash: "solid",
         root: (fill: "solid")),
  // White boxes with a coloured border, curves.
  outline: (edge: "curve", fill: "white", stroke: 1pt, radius: 6pt, underline: false, dash: "solid",
            root: (fill: "solid", stroke: 0pt)),
  // Solid colour, white text, right angles: org-chart look.
  blocks: (edge: "elbow", fill: "solid", stroke: 0pt, radius: 0pt, underline: false, dash: "solid",
           root: (:)),
  // No boxes: the text sits on its line, the classic mind map.
  lines: (edge: "curve", fill: "none", stroke: 0pt, radius: 0pt, underline: true, dash: "solid",
          root: (fill: "solid", radius: 6pt)),
  // Sketch: dashed straight lines, thin border, no fill.
  sketch: (edge: "straight", fill: "none", stroke: 0.8pt, radius: 3pt, underline: false, dash: "dashed",
           root: (fill: "white", stroke: 1.5pt)),
  // Pills and straight connections.
  bubbles: (edge: "straight", fill: "tint", stroke: 1pt, radius: 50%, underline: false, dash: "solid",
            root: (fill: "solid")),
  // Hand-drawn: like `soft`, but every line wobbles slightly.
  hand: (edge: "curve", fill: "tint", stroke: 1pt, radius: 8pt, underline: false, dash: "solid",
         hand: (amplitude: 0.6, wavelength: 80, randomness: 2, segment: 1.5, passes: 1),
         root: (fill: "solid")),
  // Scribbled: no fill, every line drawn twice.
  scribble: (edge: "curve", fill: "none", stroke: 0.7pt, radius: 6pt, underline: false, dash: "solid",
             hand: (amplitude: 0.9, wavelength: 50, randomness: 2.5, segment: 1.5, passes: 2),
             root: (fill: "white", stroke: 1pt)),
  // Felt-tip: solid colour, wide straight strokes with a long wobble.
  marker: (edge: "straight", fill: "solid", stroke: 0pt, radius: 4pt, underline: false, dash: "solid",
           hand: (amplitude: 1.2, wavelength: 120, randomness: 2, segment: 2, passes: 1),
           root: (:)),
  // Pencil: thin lines with a fine tremor, right angles.
  pencil: (edge: "elbow", fill: "white", stroke: 0.6pt, radius: 2pt, underline: false, dash: "solid",
           hand: (amplitude: 0.35, wavelength: 30, randomness: 3, segment: 1, passes: 1),
           root: (stroke: 1pt)),
  // Organic: branches that thin out towards the leaves, after Buzan and the
  // TikZ mindmap library; pastel boxes.
  organic: (edge: "taper", fill: "tint", stroke: 0pt, radius: 50%, underline: false, dash: "solid",
            root: (fill: "solid")),
  // Twigs: white circles on the first level, bare text at the leaves,
  // attached by a shared spine with a twig to each -- the infographic look.
  twigs: (edge: "comb", fill: "none", stroke: 0pt, radius: 0pt, underline: false, dash: "solid",
          root: (fill: "solid", radius: 50%, shape: "circle"),
          branches: (fill: "white", stroke: 0.09em, shape: "circle")),
)

/// Every field a theme can have, with its default. Boxes: `shape` (`"rect"`,
/// `"circle"`, `"ellipse"`), `size` (a fixed diameter per depth, or `none`),
/// `fill` (`"tint"`, `"solid"`, `"white"`, `"none"`), `stroke` (border
/// width), `radius`, `inset`, `underline` (text on a line instead of a box),
/// `font`, `scale` (font size per level), `bold-depth`, `tint` and `tint-min`
/// (how the branch colour is lightened for the boxes), `shade` (colour steps
/// per level). Edges: `edge` (`"curve"`, `"elbow"`, `"straight"`, `"taper"`,
/// `"comb"`), `thickness` (per level), `dash`, `taper` (factors at parent
/// and child), `edge-label-fill`. `hand` is `none` or a dictionary with
/// `amplitude`, `wavelength`, `randomness`, `segment` and `passes` for
/// hand-drawn lines. `root` and `branches` override any of the box fields
/// for the root and the first level only.
///
/// -> dictionary
#let theme-defaults = (
  edge: "curve", fill: "tint", stroke: 0pt, radius: 8pt, underline: false, dash: "solid",
  shape: "rect", size: none, font: none, hand: none, taper: (2.4, 0.4),
  scale: (1.3, 1.1, 1.0), bold-depth: 2, thickness: (0.27em, 0.14em),
  inset: (x: 0.9em, y: 0.55em), tint: 60%, tint-min: 0.8, shade: 0%,
  edge-label-fill: white,
  root: (:), branches: (:),
)

#let _hand-defaults = (amplitude: 0.6, wavelength: 80, randomness: 2, segment: 1.5, passes: 1)

// Resolves a theme name or dictionary to a full theme.
#let _theme(t) = {
  let base = if type(t) == str { t } else if type(t) == dictionary { t.at("base", default: "soft") }
    else { panic("brainroot: theme must be a name or a dictionary") }
  assert(base in themes, message: "brainroot: unknown theme \"" + base + "\", expected one of " + themes.keys().join(", "))
  let lay(theme, over) = {
    // `hand` is a dictionary on its own; laid over a theme without hand
    // lines it starts from the hand defaults. `root` and `branches` hold
    // box fields and are checked against those.
    let over = over
    if type(over.at("hand", default: none)) == dictionary {
      let h = if theme.hand == none { _hand-defaults } else { theme.hand }
      over.hand = _merge(h, over.hand, "theme.hand")
    }
    for part in ("root", "branches") {
      if part in over {
        let allowed = theme
        let _ = allowed.remove("root"); let _ = allowed.remove("branches")
        let _ = _merge(allowed, over.at(part), "theme." + part)
        over.insert(part, theme.at(part) + over.at(part))
      }
    }
    _merge(theme, over, "theme")
  }
  let theme = lay(theme-defaults, themes.at(base))
  if type(t) == dictionary {
    let over = t
    let _ = over.remove("base", default: none)
    theme = lay(theme, over)
  }
  theme
}
