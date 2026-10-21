// Public molecule rendering APIs and their synchronous call-boundary validation.

#import "@preview/cetz:0.5.2"
#import "validation.typ": (
  _color-type,
  _length-type,
  _angle-type,
  _invalid-input,
  _validate-positive-number,
  _validate-positive-length,
  _validate-offset,
  _validate-molecule-options,
)
#import "chemistry.typ": _compute-layout
#import "styles.typ": _resolve-foreground-theme, _canvas-scale, _style-preset
#import "molecule-rendering.typ": (
  _rendered-atom-position,
  _mirror-layout,
  _draw-molecule,
)
#import "annotations.typ": (
  _validate-annotations,
  _draw-highlight,
  _draw-arrow,
  _annotation-configuration,
)

// ── SMILES renderer ─────────────────────────────────────────────────────────────

/// Renders a SMILES string as a 2D skeletal molecular diagram.
///
/// - smiles-str (str): A valid SMILES string, e.g. "C1=CC=CC=C1" or
///   "c1ccccc1" for benzene.
/// - style ("default" / "acs" / "rsc" / "nature" / "wiley"): Journal style
///   preset filling in bond-length, font-size, bond-stroke, and font from the
///   journal's published drawing settings. Arguments passed explicitly win;
///   "default" applies nothing. Default: "default".
/// - scale (float): Balanced scale for bond length, atom labels, and bond stroke.
///   Explicit bond-length, font-size, or bond-stroke values override it.
///   Default: 1.0.
/// - bond-length (float): Bond length scale factor; 1.0 = 30 pt per bond.
/// - font-size (length): Font size for atom labels.
/// - font (auto / str / array): Font for atom labels. `auto` is
///   "New Computer Modern", or the preset's font when `style` is set.
/// - bond-stroke (length): Bond stroke width.
/// - color (auto / bool): Apply Jmol CPK atom colors. `auto` is true for the
///   default style and false for journal presets. Default: auto.
/// - fg (auto / color): Foreground color for bonds, carbon labels, and other
///   currently-black elements. `auto` inherits the surrounding text color, so
///   molecules recolor automatically on dark slides. Default: auto.
/// - theme (auto / "light" / "dark"): CPK palette variant. "dark" lifts the
///   lightness of hues that vanish on dark backgrounds (N, O, Br, I and the
///   dark named label colors). `auto` picks "dark" when `fg` is light.
///   Default: auto.
/// - rotation (angle): Rotate the molecule by this angle. Atom labels stay upright.
///   Example: rotation: 90deg. Default: 0deg.
/// - mirror (none / "horizontal" / "vertical"): Optional horizontal or vertical
///   page-axis reflection. Wedges and hashes are exchanged so the depicted
///   stereochemistry is preserved.
///   Default: none.
/// - show-h ("all" / int / array): Which implicit hydrogens to label beyond
///   the default heteroatom hydrogens. Use "all" for every atom, an integer for
///   one atom, or an array for selected atoms. Default: ().
/// - aromatic ("kekule" / "circle"): How rings written in aromatic (lowercase)
///   notation are depicted: alternating double bonds, or single bonds with an
///   inscribed circle. Kekulé-written input always draws its explicit bonds.
///   Default: "kekule".
/// - atom-annotations (array): Small gray side labels as tuple entries:
///   (index, content) or (index, content, offset). Default: ().
/// - opacity (ratio / float): Fade the whole drawing — bonds, labels, lone
///   pairs, annotations — e.g. for ghost molecules. Default: 100%.
/// - bond-customizations (array): Per-bond style overrides as
///   (bond(i, j), (..options..)) pairs; options are color, stroke (width),
///   and opacity. Default: ().
/// - lone-pairs (none / "dots" / "lines"): Draw non-bonding electron pairs on
///   skeletal atom labels. Default: none.
/// - atom-colors (dictionary): Color overrides taking priority over the CPK palette
///   and inline `{label|style}` styles. See documentation for the two key forms.
/// - show-indices (bool): Stamp each atom's writing-order index on the diagram, as a
///   development aid for writing atom()/bond()/lp() references. Default: false.
/// - ..annotations: Any number of arrow() / highlight() items referencing atoms of
///   this molecule (single-index form, e.g. atom(2)).
/// -> content
#let smiles(
  smiles-str,
  style: "default",
  scale: 1.0,
  bond-length: none,
  font-size: none,
  font: auto,
  bond-stroke: none,
  color: auto,
  fg: auto,
  theme: auto,
  rotation: 0deg,
  mirror: none,
  show-h: (),
  aromatic: "kekule",
  atom-annotations: (),
  opacity: 100%,
  bond-customizations: (),
  lone-pairs: none,
  atom-colors: (:),
  show-indices: false,
  ..annotations
) = context {
  _validate-positive-number(scale, "smiles scale")
  if bond-length != none {
    _validate-positive-number(bond-length, "smiles bond-length")
  }
  _validate-positive-length(
    font-size,
    "smiles font-size",
    allow-none: true,
  )
  _validate-positive-length(
    bond-stroke,
    "smiles bond-stroke",
    allow-none: true,
  )
  if type(rotation) != _angle-type {
    _invalid-input(
      "smiles rotation",
      "expected an angle, got " + repr(rotation),
      "Pass an angle such as 30deg.",
    )
  }
  // A style preset fills in only the sizing arguments the caller left unset,
  // and scales with `scale` like the built-in defaults do.
  let preset = _style-preset(style)
  let color = if color == auto { if preset == none { true } else { preset.color } } else { color }
  if type(color) != bool {
    panic("color must be auto or a bool")
  }
  let (bond-length, font-size, bond-stroke, font) = if preset == none {
    (bond-length, font-size, bond-stroke, font)
  } else {(
    if bond-length == none { preset.bond-length * scale } else { bond-length },
    if font-size == none { preset.font-size * scale } else { font-size },
    if bond-stroke == none { preset.bond-stroke * scale } else { bond-stroke },
    if font == auto { preset.font } else { font },
  )}
  let font = if font == auto { "New Computer Modern" } else { font }

  let (fg, theme) = _resolve-foreground-theme(fg, theme)
  let layout = _mirror-layout(_compute-layout(smiles-str), mirror, rotation: rotation)
  let canvas-scale = _canvas-scale(scale, bond-length)
  let actual-font-size = if font-size == none { 11pt * scale } else { font-size }
  let annotation = annotations.pos()
  let placed-species-list = ((
    kind: "mol",
    layout: layout,
    mol-scale: 1.0,
    rotation: rotation,
    origin: (0, 0),
    size: (layout.bbox_width, layout.bbox_height),
    canvas-scale: canvas-scale,
    actual-font-size: actual-font-size,
    actual-bond-stroke: if bond-stroke == none { 0.9pt * scale } else { bond-stroke },
    font: font,
    show-h: show-h,
    aromatic: aromatic,
  ),)
  let configuration = _annotation-configuration(canvas-scale, actual-font-size, scale, bond-stroke: bond-stroke)
  let the-scale = scale // cetz.draw `scale` shadows the argument inside the canvas
  _validate-molecule-options(
    layout,
    scale,
    bond-length,
    font-size,
    font,
    bond-stroke,
    color,
    rotation,
    show-h,
    lone-pairs,
    atom-colors,
    show-indices,
    fg,
    theme,
    aromatic,
    atom-annotations,
    opacity,
    bond-customizations,
  )
  _validate-annotations(annotation, placed-species-list, "smiles annotation")

  cetz.canvas(length: canvas-scale, {
    import cetz.draw: *
    for h in annotation {
      if type(h) == dictionary and h.at("__highlight__", default: false) {
        _draw-highlight(h, placed-species-list, configuration)
      }
    }
    _draw-molecule(
      layout,
      scale: the-scale,
      bond-length: bond-length,
      font-size: font-size,
      font: font,
      bond-stroke: bond-stroke,
      color: color,
      rotation: rotation,
      show-h: show-h,
      lone-pairs: lone-pairs,
      atom-colors: atom-colors,
      show-indices: show-indices,
      fg: fg,
      theme: theme,
      aromatic: aromatic,
      atom-annotations: atom-annotations,
      opacity: opacity,
      bond-customizations: bond-customizations,
    )
    for ar in annotation {
      if type(ar) == dictionary and ar.at("__arrow__", default: false) {
        _draw-arrow(ar, placed-species-list, configuration)
      }
    }
  })
}

// Capture Typst transforms before local parameters and CeTZ imports shadow them.
#let _typst-scale = scale
#let _typst-rotate = rotate

/// Renders a molecule sized for running text. The drawing is scaled to a
/// target height and baseline-aligned so it sits inline like a word. Typst
/// grows a line to fit tall inline content, so neighboring lines are never
/// overlapped; the default height keeps ordinary line spacing (nearly)
/// unchanged, and larger heights make only the molecule's own line taller.
///
/// - smiles-str (str): The SMILES string.
/// - height (length): Target height of the drawing. Default: 1.4em.
/// - baseline (auto / length): How far the drawing's vertical center sits
///   above the text baseline. `auto` centers it on the lowercase body of the
///   surrounding text. Default: auto.
/// - ..args: Any #smiles() drawing options (color, fg, show-h, rotation, …).
/// -> content
#let smiles-inline(smiles-str, height: 1.4em, baseline: auto, ..args) = context {
  _validate-positive-length(height, "smiles-inline height")
  if baseline != auto and type(baseline) != _length-type {
    _invalid-input(
      "smiles-inline baseline",
      "expected auto or a length, got " + repr(baseline),
      "Use baseline: auto or pass a length such as 0.3em.",
    )
  }
  let body = smiles(smiles-str, ..args)
  let measured-body = measure(body)
  if measured-body.height <= 0pt { return body }
  let target-height = height.to-absolute()
  // Fit the drawing into the target height, but cap the scale so one bond
  // never exceeds most of that height: a flat, mostly horizontal molecule
  // measures almost no height and would otherwise blow up to fill it.
  let canvas-unit = _canvas-scale(
    args.named().at("scale", default: 1.0),
    args.named().at("bond-length", default: none),
  )
  let scale-factor = calc.min(
    target-height / measured-body.height,
    target-height * 0.9 / canvas-unit,
  )
  let scaled = _typst-scale(
    x: scale-factor * 100%,
    y: scale-factor * 100%,
    reflow: true,
    body,
  )
  let center-above = if baseline == auto { 0.30em.to-absolute() } else { baseline.to-absolute() }
  box(
    baseline: measured-body.height * scale-factor / 2 - center-above,
    scaled,
  )
}

/// Draws a molecule as CeTZ elements inside an existing #cetz.canvas and
/// registers named anchors on the group, so arbitrary CeTZ drawing can attach
/// to real molecular positions: dashed hydrogen bonds between molecules,
/// distance labels, coupling arcs, custom arrows into a larger diagram.
///
/// Anchors on `name` (writing-order indices, as shown by `show-indices`):
///  - "atom-<i>" — every atom center,
///  - "bond-<i>-<j>" — every bond midpoint (i < j),
///  - "center" — the molecule origin.
///
/// Coordinates are in bond-length units; give the canvas
/// `length: 30pt * scale` so sizes match #smiles(scale: ...).
///
/// - smiles-str (str): The SMILES string.
/// - name (str): CeTZ group name carrying the anchors.
/// - origin (array): (x, y) placement of the molecule center, in canvas units.
/// - fg (color): Foreground color. `auto` is not resolvable inside a raw
///   canvas and falls back to black. Default: black.
/// - theme ("light" / "dark"): CPK palette variant. Default: "light".
/// - ..opts: #smiles() drawing options — scale, font-size, font, bond-stroke,
///   color, rotation, mirror, show-h, aromatic, atom-annotations, opacity,
///   bond-customizations, lone-pairs, atom-colors, show-indices.
/// -> none  (emits CeTZ draw elements)
#let smiles-cetz(smiles-str, name: none, origin: (0, 0), fg: black, theme: "light", ..opts) = {
  import cetz.draw: *
  let options = opts.named()
  if name != none and type(name) != str {
    _invalid-input(
      "smiles-cetz name",
      "expected none or a string, got " + repr(name),
      "Pass a CeTZ group name such as \"substrate\".",
    )
  }
  _validate-offset(origin, "smiles-cetz origin")
  if fg != auto and type(fg) != _color-type {
    _invalid-input(
      "smiles-cetz foreground",
      "expected auto or a color, got " + repr(fg),
      "Pass a Typst color.",
    )
  }
  if theme != auto and theme not in ("light", "dark") {
    _invalid-input(
      "smiles-cetz theme",
      "expected auto, \"light\", or \"dark\", got " + repr(theme),
      "Choose one of the supported palette themes.",
    )
  }
  let fg = if fg == auto { black } else { fg }
  let theme = if theme == auto { "light" } else { theme }
  let mirror = options.at("mirror", default: none)
  let rotation = options.at("rotation", default: 0deg)
  if type(rotation) != _angle-type {
    _invalid-input(
      "smiles-cetz rotation",
      "expected an angle, got " + repr(rotation),
      "Pass an angle such as 30deg.",
    )
  }
  let layout = _mirror-layout(_compute-layout(smiles-str), mirror, rotation: rotation)
  let allowed = (
    "scale", "font-size", "font", "bond-stroke", "color", "rotation",
    "show-h", "lone-pairs", "atom-colors", "show-indices", "aromatic",
    "atom-annotations", "opacity", "bond-customizations",
  )
  let drawing-options = (:)
  for (option-name, option-value) in options {
    if option-name in allowed {
      drawing-options.insert(option-name, option-value)
    } else if option-name != "mirror" {
      panic("smiles-cetz does not accept option \"" + option-name + "\"")
    }
  }
  if drawing-options.at("font", default: none) == auto {
    drawing-options.insert("font", "New Computer Modern")
  }
  group(name: name, {
    translate(origin)
    _draw-molecule(layout, fg: fg, theme: theme, ..drawing-options)
    for atom-index in range(layout.atoms.len()) {
      let atom = layout.atoms.at(atom-index)
      let atom-position = _rendered-atom-position(atom, rotation)
      anchor(
        "atom-" + str(atom-index),
        (atom-position.x, atom-position.y),
      )
    }
    for bond-output in layout.bonds {
      if not bond-output.at("virtual_bond", default: false) {
        let from-position = _rendered-atom-position(
          layout.atoms.at(bond-output.from),
          rotation,
        )
        let to-position = _rendered-atom-position(
          layout.atoms.at(bond-output.to),
          rotation,
        )
        let midpoint-x = (from-position.x + to-position.x) / 2
        let midpoint-y = (from-position.y + to-position.y) / 2
        anchor(
          "bond-"
            + str(calc.min(bond-output.from, bond-output.to))
            + "-"
            + str(calc.max(bond-output.from, bond-output.to)),
          (midpoint-x, midpoint-y),
        )
      }
    }
    anchor("center", (0, 0))
  })
}
