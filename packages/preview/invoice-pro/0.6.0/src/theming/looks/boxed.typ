// LOOK `boxed`: print first. Every section is a ruled box and hierarchy comes only
// from weight, size and rules, never from fills, so a black-and-white laser print,
// a copy or a fax loses nothing. Fits trades and crafts, labs, logistics and
// public-sector forms: anything read off paper and typed back in.
//
// Voices: a heavy grotesque for the title and the amount to pay, small monospaced
// capitals (fonts.label = DejaVu Sans Mono, embedded in every Typst build) for form
// labels and column headers, a calm sans for everything else. The brand colour
// marks only the letterhead rule. Default layout: the sender's window layout
// (layout: auto; DIN 5008 A in Germany). Works on every layout.
#import "../custom.typ" as c
#import "kit.typ": (
  bank-qr, bank-rows, figures, in-window, kicker, place-date, row-color,
  row-value, subject-of, tight-signature, tokens, totals-width,
)

/// Form label: small monospaced capitals (fonts.label).
#let tag(ctx, body) = kicker(
  ctx,
  body,
  size: tokens(ctx).sizes.small * 0.85,
  tracking: 0.03em,
)

/// A form table: label over value per cell, every cell ruled. Long values take a
/// whole row; the last short cell fills its row (no empty ruled cells). `widths`:
/// column widths (auto = equal).
#let form(ctx, pairs, cols: 3, widths: auto) = {
  let t = tokens(ctx)
  let long(v) = type(v) == str and v.len() > 30
  let pairs = (
    pairs.filter(((k, v)) => not long(v)) + pairs.filter(((k, v)) => long(v))
  )
  let cols = calc.max(1, calc.min(cols, pairs.len()))
  let short = pairs.filter(((k, v)) => not long(v)).len()
  let rest = calc.rem(short, cols)
  table(
    columns: if widths == auto { (1fr,) * cols } else { widths },
    stroke: t.strokes.thin + t.colors.border,
    inset: (x: 0.7em, y: 0.32em),
    ..pairs
      .enumerate()
      .map(((i, (k, v))) => table.cell(
        colspan: if long(v) { cols } else if rest != 0 and i == short - 1 {
          cols - rest + 1
        } else { 1 },
        stack(spacing: 0.45em, tag(ctx, k), figures(
          ctx,
          v,
          weight: t.weights.strong,
        )),
      )),
  )
}

// --- frame parts -----------------------------------------------------------------

/// REQUIRED ROLE. Heavy grotesque title (fonts.heading, options.title.color); number
/// and date in a ruled box on the right.
#let title(ctx, view) = {
  let t = tokens(ctx)
  let d = view.document
  let ref = ctx.locale.strings.reference
  let sub = subject-of(view)
  grid(
    columns: (1fr, auto),
    column-gutter: 1.2em,
    align: (left + bottom, right + bottom),
    stack(
      spacing: 0.5em,
      text(
        font: t.fonts.heading,
        size: t.sizes.title,
        weight: t.weights.strong,
        tracking: -0.01em,
        fill: ctx.theme.options.title.color,
        upper(d.title),
      ),
      if sub != none { text(weight: t.weights.strong, sub) },
    ),
    table(
      columns: (auto, auto),
      stroke: t.strokes.regular + t.colors.border,
      inset: (x: 0.8em, y: 0.4em),
      align: left + horizon,
      tag(ctx, ref.invoice-number), tag(ctx, ref.invoice-date),
      figures(ctx, d.number, size: 1.15em, weight: t.weights.strong),
      text(size: 1.15em, weight: t.weights.strong, place-date(ctx, view)),
    ),
  )
}

/// Order data as a ruled form (customer no., order, service period, site address).
#let references(ctx, view) = if view.references.len() > 0 {
  form(ctx, view.references, cols: 3)
}

/// The info column of window and digital layouts: the same form, two columns wide.
#let reference-list(ctx, view) = if view.references.len() > 0 {
  form(ctx, view.references, cols: 2)
}

/// REQUIRED ROLE. A form label only outside envelope windows.
#let recipient(ctx, view) = {
  let t = tokens(ctx)
  let r = view.recipient
  if not in-window(view) {
    tag(ctx, ctx.locale.strings.address.recipient)
    v(0.25em)
  }
  (text(weight: t.weights.strong, r.name), ..r.lines).join(linebreak())
}

/// The supplier: large strong name, address on one line.
#let sender(ctx, view) = {
  let t = tokens(ctx)
  let s = view.sender
  text(font: t.fonts.heading, size: 1.45em, weight: t.weights.strong, s.name)
  linebreak()
  s.lines.join([ · ])
}

// --- body parts ------------------------------------------------------------------

/// Totals: a ruled box from the row model; the payable row under a thick rule, label
/// and amount in ONE voice (heading face, strong, large).
#let totals(ctx, view) = {
  let t = tokens(ctx)
  let cells = ()
  for r in view.totals.rows {
    let top = if r.payable {
      (top: t.strokes.thick + t.colors.border)
    } else if r.kind in ("net-total", "total") {
      (top: t.strokes.thin + t.colors.border)
    } else { none }
    let ins = if r.payable { (x: 0.9em, top: 0.6em, bottom: 0.5em) } else {
      (x: 0.9em, y: 0.35em)
    }
    let style = if r.payable {
      (font: t.fonts.heading, weight: t.weights.strong, size: t.sizes.large)
    } else if r.emphasis != none {
      (weight: t.weights.strong)
    } else if r.kind == "tax" { (fill: t.colors.text-muted) } else {
      (fill: row-color(ctx, r, default: t.colors.text))
    }
    let lab = if r.payable { upper(r.label) } else { r.label }
    let val = if r.payable { row-value(r) } else { figures(ctx, row-value(r)) }
    cells.push(table.cell(stroke: top, inset: ins, align: left + horizon, text(
      ..style,
      lab,
    )))
    cells.push(table.cell(stroke: top, inset: ins, align: right + horizon, text(
      ..style,
      val,
    )))
  }
  layout(size => align(right, block(
    width: totals-width(ctx, size.width),
    stroke: t.strokes.regular + t.colors.border,
    table(columns: (1fr, auto), stroke: none, ..cells),
  )))
}

/// Payment terms in a box with a heavy left rule and a form label.
#let payment-terms(ctx, view, inner) = {
  let t = tokens(ctx)
  block(
    width: 100%,
    breakable: false,
    stroke: (
      left: t.strokes.thick * 1.5 + t.colors.border,
      rest: t.strokes.regular + t.colors.border,
    ),
    inset: (left: 1.1em, rest: 0.55em),
    {
      tag(ctx, ctx.locale.strings.sections.payment)
      v(0.1em)
      inner(ctx, view)
    },
  )
}

/// Bank details: a ruled form (IBAN grouped in fours) with the EPC QR code beside it.
#let bank-details(ctx, view) = {
  let t = tokens(ctx)
  let qr = bank-qr(ctx, view, default: 20mm)
  block(breakable: false, grid(
    columns: (1fr, auto),
    column-gutter: 1.2em,
    align: (left + top, center + top),
    stack(
      spacing: 0.5em,
      tag(ctx, ctx.locale.strings.sections.bank-details),
      form(
        ctx,
        bank-rows(ctx, view, iban: x => figures(
          ctx,
          x,
          weight: t.weights.strong,
        )),
        cols: 3,
        widths: (auto, auto, 1fr),
      ),
    ),
    if qr != none {
      stack(
        spacing: 0.5em,
        tag(ctx, ctx.locale.strings.sections.how-to-pay),
        block(stroke: t.strokes.thin + t.colors.border, inset: 1mm, qr),
      )
    },
  ))
}

// --- the look --------------------------------------------------------------------

#let look = {
  c.colors(
    primary: rgb("#b8400f"), // signal orange: only the letterhead rule
    text: black,
    text-muted: rgb("#3d3d3d"), // dark enough for a faint laser print
    border: black,
  )
  // grotesque title (the body family, so no extra font warning) with an embedded
  // fallback; mono form labels (embedded)
  c.fonts(
    heading: ("Liberation Sans", "DejaVu Sans Mono"),
    label: "DejaVu Sans Mono",
  )
  c.sizes(body: 9.5pt, small: 0.88em, fine: 7pt, large: 1.25em, title: 2.3em)
  c.strokes(hairline: 0.5pt, thin: 0.75pt, regular: 1.25pt, thick: 2.5pt)
  c.spacing(small: 0.45em, medium: 0.6em, leading: 0.68em)
  c.items-table(
    zebra: (none, none),
    header-fill: none,
    rule: t => t.colors.border,
    // column headers in the form-label voice
    header-style: (size: 0.8em, tracking: 0.02em),
    row-rule: t => t.strokes.hairline + luma(60%),
    row-inset: 0.3em,
  )
  c.line-items(discount-color: rgb("#9b1c1c"))
  c.totals(width: 60%, min-width: 80mm)
  c.area("letterhead", rule: t => (
    side: bottom,
    stroke: t.strokes.thick + t.colors.primary,
    gap: 2mm,
  ))
  c.area("references", inset: (bottom: 1mm))
  c.area("title", inset: (top: 1mm, bottom: 2mm))
  c.area("footer", rule: t => (
    side: top,
    stroke: t.strokes.regular + t.colors.border,
    gap: 0.8mm,
  ))
  c.area("page-number", text: (weight: "bold"), inset: (bottom: 1mm))
  c.part("title", title)
  c.part("references", references)
  c.part("reference-list", reference-list)
  c.part("recipient", recipient)
  c.part("sender", sender)
  c.part("totals", totals)
  c.wrap("payment-terms", payment-terms)
  c.part("bank-details", bank-details)
  // a form closes without a handwriting gap (like bold and compact), so a small
  // invoice keeps its signature on page 1 of every window layout
  c.part("signature", tight-signature)
  c.checks(pairs: (
    boxed-discount: t => (rgb("#9b1c1c"), t.colors.background),
  ))
}
