// The master schema, written ONCE. `field(default, ..types)` carries the default
// and the allowed types; `defaults-of` / `types-of` derive the two trees
// mechanically (no key is written twice). The custom.* helpers are the third
// spelling, guarded by a coverage test (tests/coverage.typ).
//
// Derivations: in `tokens` and `options`, a function value is a DERIVATION
// `t => value` (t = resolved tokens) unless the field's types include
// `function` (then it is a callback). Array elements may always be derivations.
// Area fields listed in `area-derivable` may be derivations too.

#import "color.typ": legible, on-color, tint-of

#let _fk = "__field__"
#let field(default, ..types) = (
  (_fk): true,
  default: default,
  types: types.pos(),
)
#let is-field(v) = type(v) == dictionary and _fk in v

/// Element-typed array: `array-of(none, color)` accepts `(none, red)`.
#let array-of(..types) = ("__array-of__": types.pos())
#let is-array-of(t) = type(t) == dictionary and "__array-of__" in t

#let defaults-of(s) = {
  if is-field(s) { return s.default }
  if type(s) != dictionary { return s }
  let out = (:)
  for (k, v) in s { out.insert(k, defaults-of(v)) }
  out
}
#let types-of(s) = {
  if is-field(s) { return s.types }
  if type(s) != dictionary { return () }
  let out = (:)
  for (k, v) in s { out.insert(k, types-of(v)) }
  out
}

// --- tokens: the frozen semantic tier -------------------------------------------
// Rule: a token is frozen only if a built-in part reads it (verified by a token
// mutation test in the prototype phase). `fonts.regulated` arrives with reserved zones (0.6.x).
#let token-schema = (
  colors: (
    primary: field(rgb("#1f2937"), color), // seed 1: brand colour
    on-primary: field(t => on-color(t.colors.primary), color), // text on primary fills
    // primary / accent USED AS TEXT on the page: darkened (or lightened on a dark
    // background) until they reach 4.5:1, so a light brand colour stays legible
    primary-text: field(
      t => legible(t.colors.primary, t.colors.background),
      color,
    ),
    accent: field(t => t.colors.primary, color), // seed 2
    accent-text: field(
      t => legible(t.colors.accent, t.colors.background),
      color,
    ),
    text: field(black, color), // body text
    text-muted: field(luma(100), color), // secondary text: descriptions, labels, notes
    border: field(black, color), // rules and table lines
    tint: field(t => tint-of(t.colors.primary), color, none), // zebra, soft fills
    background: field(white, color), // page colour; contrast reference
  ),
  fonts: (
    body: field(("Liberation Sans", "Libertinus Serif"), str, array), // chains end in a family embedded in Typst
    heading: field(t => t.fonts.body, str, array),
    label: field(t => t.fonts.body, str, array), // labels: column headers, section and reference labels
    numeric: field(t => t.fonts.body, str, array), // figures: amounts, quantities, IBAN, reference numbers
    number-width: field("tabular", "tabular", "proportional"), // Typst text(number-width:) of amounts (R4)
    regulated: field(
      ("Liberation Sans", "Arial", "Helvetica", "Libertinus Serif"),
      str,
      array,
    ), // 0.6.x: isolated zones
  ),
  sizes: (
    body: field(10pt, length), // body text size (fonts.body at sizes.body)
    small: field(0.85em, length),
    fine: field(7pt, length), // absolute, >= 6pt (validated)
    large: field(1.2em, length),
    title: field(1.4em, length),
  ),
  weights: (strong: field("bold", str, int)),
  strokes: (
    hairline: field(0.25pt, length),
    thin: field(0.5pt, length),
    regular: field(1pt, length),
    thick: field(2pt, length),
  ),
  spacing: (
    small: field(0.4em, length),
    medium: field(0.6em, length),
    leading: field(0.65em, length), // paragraph leading of the body flow (and table cells)
  ),
  radii: (small: field(2pt, length), medium: field(4pt, length)), // corner radii of filled blocks and cards
)

// --- options: provisional per-part component tier -------------------------------
// A built-in part reads its own group; items-table and totals also read
// `line-items` (their composite).
#let option-schema = (
  // on-dark: the logo on a dark surface (the hosting area's fill, else the page
  // background): auto = the logo on a light plate, content = this logo instead,
  // none = the logo as it is
  logo: (
    image: field(none, none, content),
    height: field(14mm, length),
    on-dark: field(auto, auto, none, content),
  ),
  title: (
    arrange: field("row", "row", "stack"), // as an area's `arrange`
    show-place-date: field(true, bool),
    color: field(t => t.colors.text, color), // title TEXT colour
  ),
  line-items: (
    discount-color: field(rgb("#b22222"), color), // discount() amounts
    surcharge-color: field(rgb("#333333"), color), // surcharge() amounts
    gap: field(0.7em, length), // space between the items table and the totals
  ),
  items-table: (
    // (odd, even) fills, each none | colour | derivation, OR a callback (number) => fill
    // called with the running number of the entry, 1 for the first (#33)
    zebra: field((none, t => t.colors.tint), array-of(none, color), function),
    header-fill: field(none, none, color),
    header-text: field(auto, auto, color), // auto = on-colour of header-fill, else text
    rule: field(t => t.colors.border, color),
    column-order: field(
      ("quantity", "unit-price", "tax-rate", "total-price"),
      array-of(str),
    ),
    repeat-header: field(true, bool),
    // set text(..) arguments of the column headers, applied over (font: fonts.label,
    // weight: weights.strong); values may be derivations. Open map (any text argument).
    header-style: field((:), dictionary),
    row-rule: field(none, none, length, color, stroke), // rule between two entries
    row-inset: field(t => t.spacing.small * 0.75, length), // vertical padding of every entry
  ),
  totals: (
    width: field(66%, ratio, relative, length),
    min-width: field(none, none, length), // floor for `width` in narrow columns (capped at the column)
    fill: field(none, none, color), // background of the totals block
    color: field(auto, auto, color), // text on `fill`; auto = on-colour of the fill (checked pair)
  ),
  bank-details: (
    show-qr: field(true, bool),
    qr-size: field(auto, auto, length),
  ), // core clamps to >= 20 mm
  // from: auto = every page whenever the invoice has more than one page; int = first
  // page that shows a label. format: (ctx, current, total) => content
  page-number: (
    from: field(auto, auto, int),
    format: field(auto, auto, function),
  ),
  continuation: (show-subject: field(true, bool)),
  row: (fill: field(none, none, color)), // captured by group/item inside `themed` (experimental)
  custom: field((:), dictionary), // open namespace for third-party parts; values are NOT interpreted
)

// --- checks -------------------------------------------------------------------
// `pairs`: extra contrast pairs a look or user declares, checked with the core
// pairs under `min-contrast`. An open map name -> `t => (foreground, background)`
// (or a literal pair); a later patch with the same name replaces it, `none` drops it.
#let check-schema = (
  min-contrast: field(none, none, float, int),
  pairs: field((:), dictionary),
)

// --- which options each built-in renderer reads ------------------------------------
// The documented rule (concept §3.4): an option group configures the BUILT-IN
// renderers listed here, nothing else. `part(name, fn)` replaces the renderer, and
// the replacement decides for itself which options it honours (it receives all of
// ctx.theme.options); `wrap(name, ..)` keeps the built-in inside, so its options stay
// honoured. `resolve` reports option groups that were changed but that no active
// built-in renderer reads (theme.unread-options).
#let part-options = (
  logo: ("logo",),
  title: ("title",),
  line-items: ("items-table", "totals"),
  items-table: ("items-table",),
  totals: ("totals",),
  bank-details: ("bank-details",),
  page-number: ("page-number",),
  continuation: ("continuation",),
)
/// Option groups read outside parts: `row` by the group/item components inside
/// `themed`; `custom` is an open namespace for third-party parts.
#let non-part-options = ("row", "custom")
/// Composite parts: a built-in child is only called while its composite is built-in.
#let composite-parts = (items-table: "line-items", totals: "line-items")

// --- layout ---------------------------------------------------------------------
#let places = (
  "fixed",
  "before",
  "after",
  "header",
  "footer",
  "background",
  "foreground",
)
#let page-sets = ("all", "first", "rest", "last", "not-last")
#let _dim = (auto, length, ratio, relative)
#let _paint = (none, color, gradient, tiling, function)

#let area-schema = (
  place: field("fixed", ..places),
  pages: field(auto, auto, ..page-sets), // auto: "first" for fixed, "all" for running/layer places
  left: field(auto, .._dim), // anchors: exactly one of left | right and of top | bottom (place: "fixed")
  top: field(auto, .._dim),
  right: field(auto, .._dim),
  bottom: field(auto, .._dim),
  width: field(auto, .._dim),
  height: field(auto, .._dim),
  parts: field((), array), // part names | content | (ctx, view) => content, in READING ORDER
  arrange: field("stack", "stack", "row", dictionary, function), // function: experimental
  gap: field(t => t.spacing.medium, length, function), // between cells: stack, columns and rows
  align: field(top + start, alignment),
  cell-align: field(auto, auto, alignment, array), // per cell (array: by cell index, last repeats); wins over arrange.align
  par: field((:), dictionary), // set par(..) args for the area's cells (leading, justify, ..); values may be derivations
  inset: field(
    (top: 0pt, right: 0pt, bottom: 0pt, left: 0pt),
    length,
    relative,
    dictionary,
  ), // always stored as full sides
  fill: field(none, .._paint),
  stroke: field(none, none, length, color, stroke, dictionary, function),
  radius: field(0pt, length, relative, dictionary, function), // corner radius of fill and stroke
  // zero-height decoration drawn OUTSIDE the box (not part of its height, so it
  // never counts for the footer fit): none | (side: top | bottom, stroke:, gap:)
  rule: field(none, none, dictionary, function),
  text: field((:), dictionary), // set text(..) args; values may be derivations
  stationery: field(false, bool), // belongs to the stationery: dropped when the layout's stationery is not none
  isolate: field(false, bool), // 0.6.x: regulated zone (neutral tokens, regulated font, white)
  float: field(false, bool), // 0.6.x: place "after": float to the paper's bottom edge
  reserve: field(auto, auto, bool), // does a first-page area push body-top down?
)
#let area-defaults = defaults-of(area-schema)
#let area-types = types-of(area-schema)
/// Area fields whose values may be derivations `t => ..` (for `text`: its values).
#let area-derivable = ("fill", "stroke", "gap", "text", "par", "radius", "rule")
/// Look-safe area fields: the only fields a LOOK may patch (CI lint), so any look
/// works on any layout. Everything else is geometry and belongs to the layout.
#let area-style-fields = (
  "fill",
  "stroke",
  "text",
  "inset",
  "arrange",
  "gap",
  "align",
  "cell-align",
  "par",
  "radius",
  "rule",
)

/// Standard area names. The injected base layout provides every one of them as
/// an empty stub, so patches and looks that name them work on ANY layout
/// (including third-party layouts that never heard of a name added later).
#let standard-areas = (
  marks: (place: "background", parts: ()),
  letterhead: (place: "before", parts: (), par: (leading: 0.5em)),
  address: (place: "before", parts: (), par: (leading: 0.5em)),
  info: (place: "before", parts: ()),
  references: (place: "before", parts: ()),
  title: (place: "before", parts: ()),
  continuation: (place: "header", parts: ()),
  page-number: (place: "footer", parts: ()),
  footer: (place: "footer", parts: (), par: (leading: 0.45em)),
)

#let marks-template = (
  fold: (),
  punch: none,
  left: 5mm,
  length: 2.5mm,
  stroke: t => t.strokes.hairline + t.colors.text,
)

/// The least computed bottom margin (margin.bottom: auto).
#let auto-margin-floor = 20mm

#let layout-defaults = (
  name: "plain",
  paper: "a4", // Typst paper name | (width: length, height: length | auto)
  flipped: false,
  // bottom: auto = computed from the tallest footer stack: footer + footer-descent +
  // footer-clearance, at least 20 mm. An explicit bottom that is too small is a lint finding.
  margin: (top: 20mm, right: 20mm, bottom: auto, left: 25mm),
  header-ascent: 30%,
  footer-descent: 30%,
  footer-clearance: 5mm, // footer text ends at least this far above the sheet edge (unprintable rim)
  body-top: auto,
  body-gap: 4.23mm,
  stationery: none, // none (the theme draws everything) | "pre-printed" | (first: content, rest: content)
  marks: none,
  // Envelopes this page master is designed for (window proof + fit check). Each entry:
  // (name: str, size: (w, h), window: (left|right, top|bottom, width, height), fold: auto | array).
  // Window anchors are measured on the envelope FRONT, flap edge up; `fold: auto` = marks.fold.
  envelopes: (),
  // Print-proof overlay: false | true | array of envelope names (see theming/proof.typ).
  proof: false,
  areas: (:),
)

/// Document kinds. The NAME SET is fixed now (mapped to UNTDID 1001 where a code
/// exists); 0.6.0 accepts only `invoice`, the others arrive with their rows in
/// the provisional requirements table.
#let document-kinds = (
  invoice: 380,
  credit-note: 381,
  corrected-invoice: 384,
  prepayment-invoice: 386,
  proforma-invoice: 325,
  quote: 310,
  order-confirmation: 231,
  delivery-note: 270,
  payment-reminder: none,
  receipt: none,
  letter: none,
)
#let supported-kinds = ("invoice",)

#let rules = (
  open: (
    "parts",
    "options::custom",
    "options::items-table::header-style",
    "checks::pairs",
  ),
  sides: ("layout::margin",),
  templates: ("layout::marks": marks-template),
  wrap-ok: ("parts::",),
  defaults: (
    tokens: token-schema,
    options: option-schema,
    checks: check-schema,
    layout: layout-defaults + (marks: none),
  ),
)
#let area-rules = (
  open: ("text", "par"),
  sides: ("inset",),
  atomic: ("arrange", "stroke", "radius", "rule", "cell-align"),
  templates: (:),
  wrap-ok: (),
  defaults: area-defaults,
)

/// The master schema OBJECT injected by `invoice()` (never imported by a theme).
#let make-schema(parts) = (
  version: "0.6.0",
  tokens: token-schema,
  options: option-schema,
  checks: check-schema,
  layout: layout-defaults,
  area: area-defaults,
  parts: parts,
  part-options: part-options,
  rules: rules,
)
