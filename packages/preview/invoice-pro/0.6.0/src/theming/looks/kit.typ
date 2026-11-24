// The looks kit: shared helpers for the part renderers of the built-in looks
// (src/theming/looks/<name>.typ).
//
// Rules for everything in this file:
// - A helper reads ONLY what the part contract allows: `view`, `ctx.theme`
//   (tokens, options) and `ctx.locale`. No internal ctx keys, so a user can copy
//   any helper into a look of their own and a look built from them stays a plain
//   patch.
// - Helpers are look-neutral: a look passes its own voice (fonts, colours, sizes)
//   in through parameters; the defaults are the plain, token-driven voice.
// - One helper per job. Before adding a helper, check the sections below.
//
// Sections: values - voices - grids and rules - totals - bank details -
// title and references - signature.

// --- values ----------------------------------------------------------------------

/// The theme tokens of a part context (shorthand for `ctx.theme.tokens`).
/// -> dictionary
#let tokens(ctx) = ctx.theme.tokens

/// A value that renders nothing (none, "" or []).
/// -> bool
#let blank(x) = x == none or x == "" or x == []

/// Does this part render inside an envelope window (a fixed recipient area)?
/// Window content stays plain: no labels, no fills (OCR, postal rules).
/// -> bool
#let in-window(view) = {
  let a = view.at("area", default: none)
  a != none and a.at("window", default: false)
}

// --- voices ----------------------------------------------------------------------

/// Figures in the numeric voice (fonts.numeric, fonts.number-width); `args` go to
/// `text` (weight, size, fill, ..).
/// -> content
#let figures(ctx, body, ..args) = text(
  font: ctx.theme.tokens.fonts.numeric,
  number-width: ctx.theme.tokens.fonts.number-width,
  ..args,
  body,
)

/// A label in the label voice (fonts.label), in capitals with open tracking:
/// column headers, reference and bank labels. `fill: auto` keeps the surrounding
/// text colour; `size: auto` is 0.72em.
/// -> content
#let caps(
  ctx,
  body,
  size: auto,
  fill: auto,
  tracking: 0.06em,
  weight: "regular",
) = {
  let args = (
    font: ctx.theme.tokens.fonts.label,
    size: if size == auto { 0.72em } else { size },
    tracking: tracking,
    weight: weight,
  )
  if fill != auto { args.fill = fill }
  text(..args, upper(body))
}

/// A kicker: `caps` in the strong weight and the secondary colour, at 90 % of
/// sizes.small (section labels above a value, form labels).
/// -> content
#let kicker(ctx, body, fill: auto, size: auto, tracking: 0.08em) = {
  let t = tokens(ctx)
  caps(
    ctx,
    body,
    size: if size == auto { t.sizes.small * 0.9 } else { size },
    fill: if fill == auto { t.colors.text-muted } else { fill },
    tracking: tracking,
    weight: t.weights.strong,
  )
}

/// A label in true small capitals (OpenType smcp + c2sc) of fonts.label, tracked.
/// Fonts without small capitals show the label in its own case; every built-in
/// label chain ends in Libertinus Serif, which has them.
/// -> content
#let small-caps(ctx, body, tracking: 0.1em, ..args) = (
  text(
    font: ctx.theme.tokens.fonts.label,
    features: ("smcp", "c2sc"),
    tracking: tracking,
    ..args,
    body,
  )
    + h(-tracking)
) // trailing tracking would push centred labels off-centre

/// Spaced capitals in any font (display lines: letterheads, document words).
/// -> content
#let spaced(body, tracking: 0.2em, ..args) = (
  text(tracking: tracking, ..args, upper(body)) + h(-tracking)
)

/// Keeps short legal tokens on one line: register numbers ("HRB 104822") and
/// initials with a name ("M. Oyelaran"). Use in a `wrap` of the legal blocks:
/// `wrap("registration", (ctx, view, inner) => keep-units(inner(ctx, view)))`.
/// -> content
#let keep-units(body) = {
  show regex(
    "\b(HR[AB]|GnR|PR|VR|FN|HRA|CHE|RCS|REA)\s+[\dA-Z][\d./ -]*\d",
  ): box
  show regex("\b\p{Lu}\.\s\p{Lu}[\p{Ll}-]+"): box
  body
}

// --- measuring -------------------------------------------------------------------

/// Text shortened to one line of `width`: a string gets an ellipsis, other content
/// is clipped to one line. Needs context (measure).
/// -> str | content
#let one-line(body, width) = {
  if measure(body).width <= width { return body }
  if type(body) != str {
    return box(width: width, height: measure[Xg].height, clip: true, body)
  }
  let cs = body.clusters()
  let (lo, hi) = (0, cs.len())
  while lo < hi {
    let mid = calc.ceil((lo + hi) / 2)
    if measure(cs.slice(0, mid).join().trim() + "…").width <= width {
      lo = mid
    } else { hi = mid - 1 }
  }
  cs.slice(0, lo).join().trim() + "…"
}

/// The largest size from `sizes` (descending lengths) at which `body(size)` fits
/// `width` on one line; the last size when none fits. Needs context (call it
/// inside `layout` or `context`).
/// -> length
#let fit-size(body, width, sizes) = {
  for s in sizes {
    if measure(body(s)).width <= width { return s }
  }
  sizes.last()
}

/// Width of a block in a column: `width` (ratio | relative | length), floored by
/// `min-width` (none | length) and capped at the column (`avail`). Needs context.
/// -> length
#let block-width(width, min-width, avail) = {
  let abs = if type(width) == ratio { width * avail } else if (
    type(width) == relative
  ) {
    width.ratio * avail + width.length.to-absolute()
  } else { width.to-absolute() }
  if min-width != none { abs = calc.max(abs, min-width.to-absolute()) }
  calc.min(avail, abs)
}

// --- grids and rules -------------------------------------------------------------

/// A two-column label/value grid: `rows` = array of (label, value). `label` and
/// `value` style the cells (functions body => content). `columns: (auto, 1fr)`
/// fills the width; use `(auto, auto)` when the grid sits in an auto-width cell,
/// where a 1fr column collapses.
/// -> content
#let label-grid(
  rows,
  label: x => x,
  value: x => x,
  columns: (auto, 1fr),
  column-gutter: 1.1em,
  row-gutter: 0.6em,
  align: left + bottom,
) = grid(
  columns: columns,
  column-gutter: column-gutter,
  row-gutter: row-gutter,
  align: align,
  ..rows.map(((k, v)) => (label(k), value(v))).flatten(),
)

/// The accountant's double rule: two lines of `stroke`, `gap` apart, full width.
/// -> content
#let double-rule(stroke, gap: 1.6pt) = stack(
  spacing: gap,
  line(length: 100%, stroke: stroke),
  line(length: 100%, stroke: stroke),
)

/// A dotted, round-capped stroke (dots `thickness` wide, `gap` × thickness apart).
/// -> stroke
#let dotted(paint, thickness, gap: 3.2) = stroke(
  paint: paint,
  thickness: thickness,
  dash: (0pt, thickness * gap),
  cap: "round",
)

// --- totals ----------------------------------------------------------------------

/// The width of a totals block in a column `avail` wide, from options.totals
/// (width, at least min-width, never wider than the column). Needs context.
/// -> length
#let totals-width(ctx, avail) = {
  let o = ctx.theme.options.totals
  block-width(o.width, o.min-width, avail)
}

/// The value of a totals row (view.totals.rows); a relative modifier shows its
/// rate first: "(−10 %)  −145,00 €".
/// -> content
#let row-value(r, gap: 0.5em) = if (
  r.rate != none and r.kind != "tax"
) [(#r.rate)#h(gap)#r.value.text] else { r.value.text }

/// Text colour of a totals row by kind: discounts and prepayments in
/// line-items.discount-color, surcharges in surcharge-color, taxes in `tax`
/// (auto = colors.text-muted), everything else in `default` (auto = colors.text).
/// -> color
#let row-color(ctx, r, default: auto, tax: auto) = {
  let li = ctx.theme.options.line-items
  let t = tokens(ctx)
  let default = if default == auto { t.colors.text } else { default }
  if r.kind in ("discount", "prepayment") { li.discount-color } else if (
    r.kind == "surcharge"
  ) { li.surcharge-color } else if r.kind == "tax" {
    if tax == auto { t.colors.text-muted } else { tax }
  } else { default }
}

/// The label of the amount the recipient pays, from the FRAME view: the locale's
/// amount-due string after prepayments, else the total string (the same words
/// as view.totals.payable in the body).
/// -> str | content
#let payable-label(ctx, view) = {
  let s = ctx.locale.strings.summary
  let prepaid = view.totals.prepaid.value
  if prepaid != none and prepaid != 0 { s.amount-due } else { s.total }
}

// --- bank details ----------------------------------------------------------------

/// The bank-details view as (label, value) pairs: account holder, bank, IBAN
/// (grouped in fours, from view.iban.text), BIC and the payment reference when
/// shown; empty entries are left out. `number` styles the figures (BIC,
/// reference; auto = `figures`), `iban` the IBAN (auto = `number`).
/// -> array
#let bank-rows(ctx, view, number: auto, iban: auto) = {
  let s = ctx.locale.strings.bank-details
  let snd = view.sender
  let number = if number == auto { x => figures(ctx, x) } else { number }
  let iban = if iban == auto { number } else { iban }
  let rows = ()
  if not blank(snd.name) { rows.push((s.account-holder, snd.name)) }
  if not blank(snd.bank) { rows.push((s.bank, snd.bank)) }
  if not blank(view.iban.text) { rows.push((s.iban, iban(view.iban.text))) }
  if not blank(snd.bic) { rows.push((s.bic, number(snd.bic))) }
  if view.show-reference and view.payment-reference != none {
    rows.push((s.reference, number(view.payment-reference)))
  }
  rows
}

/// The EPC QR code of the bank-details view, honouring bank-details.show-qr and
/// qr-size (`default` when qr-size is auto); none when there is none.
/// -> content | none
#let bank-qr(ctx, view, default: 22mm) = {
  let o = ctx.theme.options.bank-details
  if not o.show-qr or view.qr == none { return none }
  (view.qr)(if o.qr-size == auto { default } else { o.qr-size })
}

// --- title and references ----------------------------------------------------------

/// The date line of a title: "Place, date" when options.title.show-place-date.
/// -> content
#let place-date(ctx, view) = {
  let d = view.document
  if (
    ctx.theme.options.title.show-place-date and d.place != none
  ) [#d.place, #d.date.text] else { d.date.text }
}

/// The subject line under a title, or none when it only repeats the document word.
/// -> content | none
#let subject-of(view) = {
  let d = view.document
  let s = d.subject
  if s in (none, "", []) or s == d.title { none } else { s }
}

/// The subject without a leading document word: "Invoice — Sprint 14" under the
/// title word "Invoice" becomes "Sprint 14" (a title stack never says it twice).
/// Only string subjects are shortened; none when nothing is left.
/// -> str | content | none
#let strip-word(subject, word) = {
  if type(subject) != str or type(word) != str { return subject }
  let s = subject.trim()
  if not lower(s).starts-with(lower(word)) { return subject }
  let rest = s.slice(word.len()).trim(regex("[\s\-–—:·|,]+"), at: start)
  if rest == "" { none } else { rest }
}

/// Splits view.references into the recipient-facing references and the SELLER's
/// tax identifiers (VAT ID, tax number), so a look can label the seller's group
/// and a reader never takes them for the customer's numbers. A reference counts
/// as the seller's when its value equals view.sender.vat-id or tax-nr.
/// -> dictionary (refs: array, seller: array)
#let split-seller-ids(view) = {
  let s = view.sender
  let ids = (s.at("vat-id", default: none), s.at("tax-nr", default: none))
    .filter(x => x not in (none, "", []))
    .map(x => if type(x) == str { x.replace(" ", "") } else { x })
  let key(v) = if type(v) == str { v.replace(" ", "") } else { v }
  let refs = ()
  let seller = ()
  for (k, v) in view.references {
    if key(v) in ids { seller.push((k, v)) } else { refs.push((k, v)) }
  }
  (refs: refs, seller: seller)
}

// --- signature ---------------------------------------------------------------------

/// Closing and signer set tight: the closing, the signature image (when given)
/// or a line break, then the signer's name (`strong-name`: in the strong weight).
/// The default renderer leaves a free line above and below the closing; dense
/// and poster looks need that height for the page.
/// -> content
#let tight-signature(ctx, view, strong-name: false) = block(
  breakable: false,
  above: 1.1em,
  {
    set par(leading: 0.5em)
    ctx.locale.strings.signature.closing
    if view.signature != none {
      block(above: 0.6em, below: 0.6em, view.signature)
    } else { linebreak() }
    if view.name not in (none, "") {
      if strong-name { strong(view.name) } else { view.name }
    }
  },
)
