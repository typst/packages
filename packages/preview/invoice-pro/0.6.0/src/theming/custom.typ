// `theme.custom`: the patch DSL. One typed helper per schema group (helper name ==
// group name), every parameter `auto` (= untouched), `none` = off, `reset()` =
// back to the schema default. Every helper returns a ONE-ELEMENT ARRAY, so several
// helpers in a block all apply:
//   { import theme.custom: *; colors(primary: teal); items-table(zebra: (none, none)) }
// A coverage test asserts helper parameters == schema keys (tests/coverage.typ).

#import "../utils/patch.typ": (
  clean-auto, emit, replace, reset, wrap as _wrap-marker,
)
#import "data.typ": from-data

#let _tokens(group, d) = emit("tokens", ((group): clean-auto(d)))
#let _options(group, d) = emit("options", ((group): clean-auto(d)))

// --- tokens (frozen semantic tier) --------------------------------------------------
/// Colour roles. A function value `t => color` is a derivation over the resolved tokens.
/// `primary-text` / `accent-text`: the brand colours where they are USED AS TEXT
/// (derived: darkened until 4.5:1 on `background`).
/// -> array
#let colors(
  primary: auto,
  on-primary: auto,
  primary-text: auto,
  accent: auto,
  accent-text: auto,
  text: auto,
  text-muted: auto,
  border: auto,
  tint: auto,
  background: auto,
) = _tokens("colors", (
  primary: primary,
  on-primary: on-primary,
  primary-text: primary-text,
  accent: accent,
  accent-text: accent-text,
  text: text,
  text-muted: text-muted,
  border: border,
  tint: tint,
  background: background,
))
/// Font roles; families are fallback chains (fonts cannot ship in packages): end
/// every chain in an embedded family (Libertinus Serif, New Computer Modern,
/// DejaVu Sans Mono). `label`: the voice of labels and column headers; `numeric`:
/// the voice of figures (amounts, quantities, IBAN). Both derive from `body`.
/// -> array
#let fonts(
  body: auto,
  heading: auto,
  label: auto,
  numeric: auto,
  number-width: auto,
  regulated: auto,
) = _tokens(
  "fonts",
  (
    body: body,
    heading: heading,
    label: label,
    numeric: numeric,
    number-width: number-width,
    regulated: regulated,
  ),
)
/// -> array
#let sizes(
  body: auto,
  small: auto,
  fine: auto,
  large: auto,
  title: auto,
) = _tokens(
  "sizes",
  (body: body, small: small, fine: fine, large: large, title: title),
)
/// -> array
#let weights(strong: auto) = _tokens("weights", (strong: strong))
/// Stroke thicknesses (paint comes from colour roles at the use site).
/// -> array
#let strokes(hairline: auto, thin: auto, regular: auto, thick: auto) = _tokens(
  "strokes",
  (hairline: hairline, thin: thin, regular: regular, thick: thick),
)
/// `leading`: paragraph leading of the body flow and of table cells.
/// -> array
#let spacing(small: auto, medium: auto, leading: auto) = _tokens(
  "spacing",
  (small: small, medium: medium, leading: leading),
)
/// Corner radii of filled blocks (`small`, e.g. the totals fill) and cards (`medium`).
/// -> array
#let radii(small: auto, medium: auto) = _tokens("radii", (
  small: small,
  medium: medium,
))

// --- options (provisional component tier: one helper per part with options) --------
/// Logo content. Give `alt` when passing `image(..)` (PDF/UA-1). `on-dark`: what
/// shows on a dark surface (the hosting area's fill, else the page background):
/// auto = the logo on a light plate, content = this logo instead (e.g. a white
/// version), none = the logo as it is.
/// -> array
#let logo(image: auto, height: auto, on-dark: auto) = _options("logo", (
  image: image,
  height: height,
  on-dark: on-dark,
))
/// -> array
/// `arrange`: "row" (title and date on one line) | "stack"; `color`: the title text colour.
#let title(arrange: auto, show-place-date: auto, color: auto) = _options(
  "title",
  (arrange: arrange, show-place-date: show-place-date, color: color),
)
/// Shared by items-table and totals: discount / surcharge amount colours, and
/// `gap`, the space between the table and the totals.
/// -> array
#let line-items(
  discount-color: auto,
  surcharge-color: auto,
  gap: auto,
) = _options(
  "line-items",
  (discount-color: discount-color, surcharge-color: surcharge-color, gap: gap),
)
/// Row fill as in #33: (odd, even), each none | colour | derivation, or a callback
/// (number) => fill, called with the running number of the entry (1 for the first).
/// `header-style`: set-text arguments of the column headers (merged key by key);
/// `row-rule`: none | stroke between two entries; `row-inset`: vertical padding of an entry.
/// -> array
#let items-table(
  zebra: auto,
  header-fill: auto,
  header-text: auto,
  rule: auto,
  column-order: auto,
  repeat-header: auto,
  header-style: auto,
  row-rule: auto,
  row-inset: auto,
) = _options("items-table", (
  zebra: zebra,
  header-fill: header-fill,
  header-text: header-text,
  rule: rule,
  column-order: column-order,
  repeat-header: repeat-header,
  header-style: header-style,
  row-rule: row-rule,
  row-inset: row-inset,
))
/// `width` of the area's column, at least `min-width`; `fill` behind the block and
/// `color` for its text (auto = the on-colour of the fill).
/// -> array
#let totals(width: auto, min-width: auto, fill: auto, color: auto) = _options(
  "totals",
  (width: width, min-width: min-width, fill: fill, color: color),
)
/// QR size: auto = the part's default; core clamps to >= 20 mm (EPC069-12).
/// -> array
#let bank-details(show-qr: auto, qr-size: auto) = _options("bank-details", (
  show-qr: show-qr,
  qr-size: qr-size,
))
/// `from`: auto = every page whenever the invoice has more than one page ("Page 1 of 2"
/// on page 1), or the first page that shows a label; `format: (ctx, current, total) => content`
/// (auto = the locale string `strings.document.page`).
/// -> array
#let page-number(from: auto, format: auto) = _options("page-number", (
  from: from,
  format: format,
))
/// -> array
#let continuation(show-subject: auto) = _options("continuation", (
  show-subject: show-subject,
))
/// EXPERIMENTAL: style captured by group/item inside a `themed` scope.
/// -> array
#let row(fill: auto) = _options("row", (fill: fill))

// --- layout patches (onto whatever layout is active) --------------------------------
/// Scalar page-master keys. `margin` folds: `(bottom: 35mm)` keeps the other sides;
/// `(bottom: reset())` returns to the computed bottom margin (footer + descent +
/// `footer-clearance`, at least 20 mm). `footer-clearance`: the least distance
/// between the last footer line and the sheet edge.
/// -> array
#let page(
  paper: auto,
  flipped: auto,
  margin: auto,
  body-top: auto,
  body-gap: auto,
  header-ascent: auto,
  footer-descent: auto,
  footer-clearance: auto,
) = emit("layout", clean-auto((
  paper: paper,
  flipped: flipped,
  margin: margin,
  body-top: body-top,
  body-gap: body-gap,
  header-ascent: header-ascent,
  footer-descent: footer-descent,
  footer-clearance: footer-clearance,
)))
/// none (the theme draws everything) | "pre-printed" | (first: content, rest: content).
/// Anything but none drops every `stationery: true` area, whatever renders it (mode wins).
/// -> array
#let stationery(value) = emit("layout", (stationery: value))
/// Print marks: none (digital) or geometry fields (patched onto a template).
/// -> array
#let marks(..args) = {
  let pos = args.pos()
  if pos.len() == 1 and pos.first() == none {
    emit("layout", (marks: none))
  } else {
    assert(
      pos.len() == 0,
      message: "theme::custom::marks takes named mark fields or a single `none`",
    )
    emit("layout", (marks: clean-auto(args.named())))
  }
}
/// Envelopes the page master is designed for (replaces the list): records
/// `(name:, size: (w, h), window: (left|right:, top|bottom:, width:, height:), fold: auto)`,
/// e.g. `envelopes(theme.layout.envelope.din-dl, (name: "ours", size: .., window: ..))`.
/// A folded sheet that does not fit an envelope is a lint finding; see `proof`.
/// -> array
#let envelopes(..items) = {
  assert(
    items.named().len() == 0,
    message: "theme::custom::envelopes takes envelope records as positional arguments",
  )
  emit("layout", (envelopes: items.pos()))
}
/// Print-proof overlay: draws every envelope window (insert in both extreme corners),
/// the band that always shows, the fold and punch lines and the recipient box, so one
/// printed sheet can be held against the real envelope. `true`, `false`, or an array of
/// envelope names. Never on for production output; e.g.
/// `proof(sys.inputs.at("proof", default: "") == "1")`.
/// -> array
#let proof(value) = {
  assert(
    type(value) == bool
      or (type(value) == array and value.all(v => type(v) == str)),
    message: "theme::custom::proof takes true, false or an array of envelope names, found "
      + repr(value),
  )
  emit("layout", (proof: value))
}
/// Patches an area (look-safe fields: fill, stroke, radius, rule, text, par, inset,
/// arrange, gap, align, cell-align; the rest is geometry) (fields merge; `auto` = untouched; setting `left` clears `right`
/// and `top` clears `bottom`, and vice versa); `area(name, none)` removes it (idempotent); a
/// patch with `place` (re-)creates it.
/// -> array
#let area(name, ..args) = {
  let pos = args.pos()
  if pos.len() == 1 and pos.first() == none {
    emit("layout", (areas: ((name): none)))
  } else {
    assert(
      pos.len() == 0,
      message: "theme::custom::area(\""
        + name
        + "\", ..) takes named area fields or a single `none`",
    )
    emit("layout", (areas: ((name): clean-auto(args.named()))))
  }
}

// --- parts ---------------------------------------------------------------------------
/// Replaces a renderer: `(ctx, view) => content` (or `none` to hide an optional part).
/// -> array
#let part(name, renderer) = emit("parts", ((name): renderer))
/// Wraps the inherited renderer: `(ctx, view, inner) => content`. Wraps stack in
/// patch order (look -> positional patches -> themed scopes); `part` resets the stack.
/// -> array
#let wrap(name, wrapper) = emit("parts", ((name): _wrap-marker(wrapper)))

// --- checks ----------------------------------------------------------------------------
/// `min-contrast: 4.5` reports every checked colour pair below WCAG AA (an issue:
/// it follows invoice(validation: ..)). `pairs` adds pairs a look or user draws:
/// `(name: t => (foreground, background))` over the resolved tokens (or a literal
/// pair); pairs merge by name, `none` drops one. Errors name the pair.
/// -> array
#let checks(min-contrast: auto, pairs: auto) = {
  if pairs != auto {
    assert(
      type(pairs) == dictionary,
      message: "variable `theme::custom::checks::pairs`("
        + repr(pairs)
        + ") must be of dictionary: (name: t => (foreground, background))",
    )
  }
  emit("checks", clean-auto((min-contrast: min-contrast, pairs: pairs)))
}

// --- macros --------------------------------------------------------------------------
/// The five-minute path: one colour (the palette derives), fonts, logo.
/// -> array
#let brand(
  color: auto,
  accent: auto,
  font: auto,
  heading-font: auto,
  logo: auto,
) = {
  colors(primary: color, accent: accent)
  fonts(body: font, heading: heading-font)
  if logo != auto { _options("logo", (image: logo)) }
}
