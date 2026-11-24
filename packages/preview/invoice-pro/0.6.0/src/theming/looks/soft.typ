// LOOK `soft` - cafés, bakeries, wellness and health practices, small retail, B2C.
// Warm and friendly: a serif voice for headings, rounded cards on a pastel tint
// derived from the seed colour, number and date in pills, dotted separators,
// relaxed type. Corner radii come from the radii tokens (small: pills and
// badges' neighbours, medium: cards); the brand colour used as text is
// colors.primary-text. Envelope windows stay plain (no labels, no fills).
//
// Replaced parts: sender, references, title, totals, bank-details, signature.
// The items table is the built-in renderer in a rounded card (a wrap), styled
// through options (tinted header, dotted row rules, serif header voice).

#import "../custom.typ" as c
#import "kit.typ"
#import "../color.typ": legible

#let _t(ctx) = ctx.theme.tokens

/// Dotted, round-capped separator in the border colour (the look's rhythm element).
#let dotted(ctx) = kit.dotted(_t(ctx).colors.border, _t(ctx).strokes.regular)

/// Rounded pill: secondary label + strong value on the tint surface.
#let pill(ctx, label, value) = box(
  fill: _t(ctx).colors.tint,
  radius: 1em,
  inset: (x: 0.8em, y: 0.42em),
  {
    text(size: _t(ctx).sizes.small, fill: _t(ctx).colors.text-muted, label)
    h(0.45em)
    text(weight: _t(ctx).weights.strong, value)
  },
)

/// Serif heading voice in the brand colour used as text.
#let voice(ctx, body, size: 1.3em, style: "normal") = text(
  font: _t(ctx).fonts.heading,
  size: size,
  style: style,
  fill: _t(ctx).colors.primary-text,
  body,
)

/// Label/value list with secondary labels.
#let _rows(ctx, rows) = kit.label-grid(
  rows,
  columns: (auto, auto),
  label: k => text(
    size: _t(ctx).sizes.small,
    fill: _t(ctx).colors.text-muted,
    k,
  ),
  row-gutter: 0.42em,
)

// --- frame parts -----------------------------------------------------------------

#let sender(ctx, view) = {
  let t = _t(ctx)
  let s = view.sender
  voice(ctx, s.name, size: 1.45em)
  if s.lines.len() > 0 {
    linebreak()
    text(
      size: t.sizes.small,
      fill: t.colors.text-muted,
      s.lines.join[#h(0.35em)·#h(0.35em)],
    )
  }
}

/// The recipient with a small label in the brand voice, plain inside a window.
#let recipient(ctx, view, inner) = {
  let body = inner(ctx, view)
  if body == none or kit.in-window(view) { return body }
  text(
    size: _t(ctx).sizes.small,
    fill: _t(ctx).colors.primary-text,
    weight: _t(ctx).weights.strong,
    ctx.locale.strings.address.recipient,
  )
  v(0.5em, weak: true)
  block(body)
}

/// The reference list on a tinted card (never in a window).
#let reference-list(ctx, view, inner) = {
  let body = inner(ctx, view)
  if body == none or kit.in-window(view) { return body }
  block(
    fill: _t(ctx).colors.tint,
    radius: _t(ctx).radii.medium,
    inset: (x: 1em, y: 0.8em),
    body,
  )
}

#let references(ctx, view) = {
  if view.references.len() == 0 { return none }
  view.references.map(((k, v)) => pill(ctx, k, v)).join(h(0.5em))
}

/// REQUIRED ROLE (title): the document word in the serif voice, number and date
/// in pills, then the subject (without a repeated document word).
#let title(ctx, view) = {
  let t = _t(ctx)
  let d = view.document
  let o = ctx.theme.options.title
  let ref = ctx.locale.strings.reference
  block(below: 0.5em, text(
    font: t.fonts.heading,
    size: t.sizes.title,
    fill: o.color,
    d.title,
  ))
  let pills = (pill(ctx, ref.invoice-number, d.number),)
  if o.show-place-date { pills.push(pill(ctx, ref.invoice-date, d.date.text)) }
  pills.join(h(0.5em))
  let subject = kit.strip-word(d.subject, d.title)
  if subject not in (none, "", []) {
    v(0.55em, weak: true)
    block(text(size: 1.05em, subject))
  }
}

// --- body parts --------------------------------------------------------------------

/// The built-in items table inside one rounded card.
/// The card holds the table only: `view.tail` (the totals the core binds to the
/// last row) is dropped, so the totals stay a card of their own below it (the
/// composite renders them after the table when the table did not place them).
#let items-table(ctx, view, inner) = block(
  width: 100%,
  stroke: _t(ctx).strokes.thin + _t(ctx).colors.border,
  radius: _t(ctx).radii.medium,
  clip: true, // the tinted header runs edge to edge and follows the rounded corners
  inset: (bottom: _t(ctx).spacing.small * 0.5),
  {
    let view = view
    let _ = view.remove("tail", default: none)
    inner(ctx, view)
  },
)

/// REQUIRED (totals): a rounded pastel card from view.totals.rows; the payable
/// amount in the serif voice. Its text is colors.text / primary-text on `fill`
/// (checked pairs soft-totals-*).
#let totals(ctx, view) = {
  let t = _t(ctx)
  let o = ctx.theme.options.totals
  let fill = if o.fill != none { o.fill } else { t.colors.tint }
  let row(r) = {
    let color = kit.row-color(ctx, r)
    let small = r.kind in ("discount", "surcharge", "tax", "prepayment")
    let weight = if r.emphasis == none { "regular" } else { t.weights.strong }
    let size = if small { t.sizes.small } else { 1em }
    grid(
      columns: (1fr, auto),
      column-gutter: 1em,
      align: (left + bottom, right + bottom),
      inset: (y: t.spacing.medium * 0.26),
      text(size: size, fill: color, weight: weight, r.label),
      text(size: size, fill: color, weight: weight, kit.row-value(r)),
    )
  }
  let out = ()
  for r in view.totals.rows {
    if r.payable {
      out.push(v(0.3em))
      out.push(line(length: 100%, stroke: dotted(ctx)))
      out.push(v(0.4em))
      out.push(grid(
        columns: (1fr, auto),
        align: (left + horizon, right + horizon),
        voice(ctx, r.label, size: 1.2em),
        text(
          font: t.fonts.heading,
          size: t.sizes.large,
          weight: t.weights.strong,
          fill: t.colors.primary-text,
          number-type: "lining",
          r.value.text,
        ),
      ))
    } else { out.push(row(r)) }
  }
  align(right, block(
    width: o.width,
    breakable: false,
    fill: fill,
    radius: t.radii.medium,
    inset: (x: 1.1em, y: 0.65em),
    stack(spacing: 0pt, ..out),
  ))
}

/// "How to pay" card: bank rows and the EPC QR code. It stays together, and it
/// sticks to nothing: when the page is full it moves on with the closing.
#let bank-details(ctx, view) = {
  let t = _t(ctx)
  let rows = kit.bank-rows(ctx, view, number: x => text(
    weight: t.weights.strong,
    x,
  ))
  block(
    breakable: false,
    width: 100%,
    above: 0.9em,
    stroke: t.strokes.thin + t.colors.border,
    radius: t.radii.medium,
    inset: (x: 1.1em, y: 0.7em),
    grid(
      columns: (1fr, auto),
      column-gutter: 1.5em,
      align: (left + top, right + horizon),
      {
        voice(ctx, ctx.locale.strings.sections.how-to-pay, size: 1.2em)
        v(0.4em, weak: true)
        _rows(ctx, rows)
      },
      kit.bank-qr(ctx, view, default: 20mm),
    ),
  )
}

#let signature(ctx, view) = block(breakable: false, above: 1.5em, {
  ctx.locale.strings.signature.closing
  v(0.5em)
  if view.signature != none {
    view.signature
    v(0.2em)
  }
  if view.name not in (none, "") {
    voice(ctx, view.name, size: 1.3em, style: "italic")
  }
})

// --- the look ------------------------------------------------------------------------

/// Pastel surface: a light, low-chroma version of the seed (OKLCH).
#let _pastel(seed, l, k, max) = {
  let (_, ch, hue, ..) = oklch(seed).components()
  rgb(oklch(l, calc.min(ch * k, max), hue))
}

#let look = {
  c.colors(
    primary: rgb("#9c3d26"),
    text: rgb("#33261f"),
    text-muted: rgb("#6b5a50"),
    tint: t => _pastel(t.colors.primary, 96%, 0.3, 0.022),
    // dark enough that card outlines and dotted rules survive a greyscale copy
    border: t => _pastel(t.colors.primary, 70%, 0.45, 0.06),
    // the brand used as text sits on the tint cards too: legible there (and on white)
    primary-text: t => legible(t.colors.primary, t.colors.tint),
  )
  c.fonts(
    // every missing family in a chain is a compiler warning, so the chain stays short:
    // Segoe UI (Windows), Liberation Sans (Linux), else the embedded serif
    body: ("Segoe UI", "Liberation Sans", "Libertinus Serif"),
    heading: "Libertinus Serif", // embedded in every Typst: the voice is identical everywhere
  )
  c.sizes(body: 10pt, small: 0.87em, large: 1.45em, title: 2em)
  c.strokes(hairline: 0.4pt, thin: 0.7pt, regular: 1pt, thick: 1.4pt)
  c.spacing(small: 0.5em, medium: 0.7em, leading: 0.62em)
  c.radii(small: 5pt, medium: 9pt)
  c.title(color: t => t.colors.primary-text)
  c.items-table(
    zebra: (none, none),
    header-fill: t => t.colors.tint,
    header-text: t => t.colors.primary-text,
    header-style: (font: t => t.fonts.heading, size: 1.08em),
    rule: t => t.colors.tint,
    row-rule: t => kit.dotted(t.colors.border, t.strokes.regular),
    row-inset: t => t.spacing.small * 0.4,
  )
  c.totals(width: 55%)
  c.area("title", inset: (top: 1mm, bottom: 4mm))
  c.area("footer", align: center + top, rule: t => (
    side: top,
    stroke: kit.dotted(t.colors.border, t.strokes.regular),
    gap: 2mm,
  ))
  c.area("page-number", align: center, inset: (bottom: 3mm)) // clear of the dotted footer rule
  c.part("sender", sender)
  c.wrap("recipient", recipient)
  c.wrap("reference-list", reference-list)
  c.part("references", references)
  c.part("title", title)
  c.wrap("items-table", items-table)
  c.part("totals", totals)
  c.part("bank-details", bank-details)
  c.part("signature", signature)
  // colours this look draws beyond the core pairs
  c.checks(pairs: (
    soft-brand-on-tint: t => (t.colors.primary-text, t.colors.tint),
    soft-text-on-tint: t => (t.colors.text, t.colors.tint),
    soft-muted-on-tint: t => (t.colors.text-muted, t.colors.tint),
  ))
}
