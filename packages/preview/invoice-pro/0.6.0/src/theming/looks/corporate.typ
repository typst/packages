// LOOK `corporate`: larger companies, holdings, B2B enterprises (shared-service
// accounting, purchase-order driven invoicing, many references per invoice).
//
// A two-colour brand system: the deep primary carries the structure (filled table
// header, the payable bar, the serif display title, section kickers); the accent
// only draws rules and ticks, never text. Strict information architecture: number
// and date are key facts beside the title, references form a labelled details
// table, payment and bank details are labelled sections, and the amount to pay
// sits in a primary bar. Default layout: `a4-sidebar` (US: `us-letter-sidebar`),
// where the supplier identity and all legal data live in a tinted brand rail.
// The look patches only look-safe area fields, so it works on every layout.
#import "../custom.typ" as c
#import "kit.typ": (
  bank-qr, bank-rows, figures, in-window, keep-units, kicker, place-date,
  row-color, row-value, subject-of, tight-signature, tokens, totals-width,
)

/// Section heading: an accent tick and a kicker in the primary text colour. Sticky,
/// so a heading never ends a page.
#let section(ctx, body) = {
  let t = tokens(ctx)
  block(below: 0.7em, above: 1.2em, sticky: true, stack(
    dir: ltr,
    spacing: 0.6em,
    box(width: 1.2em, height: 0.8em, align(horizon, line(
      length: 100%,
      stroke: t.strokes.thick + t.colors.accent,
    ))),
    kicker(ctx, body, fill: t.colors.primary-text),
  ))
}

// --- frame parts -----------------------------------------------------------------

/// REQUIRED ROLE. Display title in the heading face (options.title.color), number
/// and date as key facts on the right.
#let title(ctx, view) = {
  let t = tokens(ctx)
  let d = view.document
  let ref = ctx.locale.strings.reference
  let fact(k, v) = stack(spacing: 0.45em, kicker(ctx, k), v)
  let sub = subject-of(view)
  block(width: 100%, above: 0pt, below: 0pt, {
    box(width: 14mm, height: t.strokes.thick * 1.5, fill: t.colors.accent)
    v(0.6em)
    grid(
      columns: (1fr, auto, auto),
      column-gutter: 1.4em,
      align: bottom + left,
      stack(
        spacing: 0.5em,
        text(
          font: t.fonts.heading,
          size: t.sizes.title,
          fill: ctx.theme.options.title.color,
          tracking: 0.01em,
          d.title,
        ),
        if sub != none { text(fill: t.colors.text-muted, sub) },
      ),
      fact(ref.invoice-number, figures(
        ctx,
        d.number,
        weight: t.weights.strong,
      )),
      fact(ref.invoice-date, place-date(ctx, view)),
    )
  })
}

/// Key-facts strip (DIN layouts): every reference as a tile with an accent tick.
#let references(ctx, view) = {
  let t = tokens(ctx)
  let refs = view.references
  if refs.len() == 0 { return none }
  block(
    width: 100%,
    inset: (y: 0.8em),
    stroke: (
      top: t.strokes.thin + t.colors.border,
      bottom: t.strokes.thin + t.colors.border,
    ),
    grid(
      columns: (1fr,) * calc.min(4, refs.len()),
      column-gutter: 1em,
      row-gutter: 1em,
      ..refs.map(((k, v)) => block(
        inset: (left: 0.7em),
        stroke: (left: t.strokes.regular + t.colors.accent),
        stack(spacing: 0.45em, kicker(ctx, k), figures(
          ctx,
          v,
          weight: t.weights.strong,
        )),
      ))
    ),
  )
}

/// Labelled details table with hairlines (the info column of window and digital layouts).
#let reference-list(ctx, view) = {
  let t = tokens(ctx)
  let rows = view.references
  if rows.len() == 0 { return none }
  stack(
    spacing: 0.55em,
    kicker(
      ctx,
      ctx.locale.strings.sections.details,
      fill: t.colors.primary-text,
    ),
    table(
      columns: (auto, 1fr),
      inset: (x: 0pt, y: 0.45em),
      column-gutter: 1em,
      stroke: (x, y) => (
        top: if y == 0 { t.strokes.regular + t.colors.primary } else {
          t.strokes.hairline + t.colors.border
        },
      ),
      ..rows
        .map(((k, v)) => (
          text(size: t.sizes.small, fill: t.colors.text-muted, k),
          figures(ctx, v, size: t.sizes.small),
        ))
        .flatten()
    ),
  )
}

/// REQUIRED ROLE. A "Bill to" kicker only outside envelope windows.
#let recipient(ctx, view) = {
  let t = tokens(ctx)
  let r = view.recipient
  if not in-window(view) {
    kicker(
      ctx,
      ctx.locale.strings.address.recipient,
      fill: t.colors.primary-text,
    )
    v(0.3em)
  }
  (text(weight: t.weights.strong, r.name), ..r.lines).join(linebreak())
}

/// The supplier: serif name in the primary text colour over muted address lines.
#let sender(ctx, view) = {
  let t = tokens(ctx)
  let s = view.sender
  text(font: t.fonts.heading, size: 1.25em, fill: t.colors.primary-text, s.name)
  linebreak()
  text(fill: t.colors.text-muted, s.lines.join(linebreak()))
}

// --- body parts ------------------------------------------------------------------

/// Totals from the row model: quiet rows over hairlines, the payable row in a
/// primary bar (on-primary text, corner radius radii.small). Width from
/// options.totals (width, at least min-width), right-aligned.
#let totals(ctx, view) = {
  let t = tokens(ctx)
  let cells = ()
  for r in view.totals.rows {
    let bar = r.payable
    let (fg, w, size) = if bar {
      (t.colors.on-primary, t.weights.strong, t.sizes.large)
    } else if r.emphasis != none {
      (t.colors.text, t.weights.strong, 1em)
    } else if r.kind == "tax" { (t.colors.text-muted, "regular", 1em) } else {
      (row-color(ctx, r, default: t.colors.text), "regular", 1em)
    }
    let cell(al, body) = grid.cell(
      align: al,
      inset: if bar { (x: 0.8em, y: 0.7em) } else { (x: 0.8em, y: 0.5em) },
      stroke: if bar { none } else {
        (bottom: t.strokes.hairline + t.colors.border)
      },
      text(fill: fg, weight: w, size: size, body),
    )
    let row = (cell(left, r.label), cell(right, figures(ctx, row-value(r))))
    cells += if bar {
      (
        grid.cell(colspan: 2, inset: 0pt, block(
          width: 100%,
          fill: t.colors.primary,
          radius: t.radii.small,
          grid(columns: (1fr, auto), ..row),
        )),
      )
    } else { row }
  }
  layout(size => align(right, block(
    width: totals-width(ctx, size.width),
    grid(columns: (1fr, auto), ..cells),
  )))
}

/// Payment terms as a tinted call-out with an accent edge, under a section heading.
#let payment-terms(ctx, view, inner) = {
  let t = tokens(ctx)
  section(ctx, ctx.locale.strings.sections.payment)
  block(
    width: 100%,
    fill: t.colors.tint,
    inset: (x: 1em, y: 0.65em),
    stroke: (left: t.strokes.thick + t.colors.accent),
    inner(ctx, view),
  )
}

/// Bank details: a label/value table with hairlines, the EPC QR code on the right.
#let bank-details(ctx, view) = {
  let t = tokens(ctx)
  let qr = bank-qr(ctx, view, default: 22mm)
  block(breakable: false, {
    section(ctx, ctx.locale.strings.sections.bank-details)
    grid(
      columns: (1fr, auto),
      column-gutter: 2em,
      align: (left + top, right + top),
      table(
        columns: (auto, 1fr),
        inset: (x: 0pt, y: 0.42em),
        column-gutter: 1.5em,
        stroke: (x, y) => (bottom: t.strokes.hairline + t.colors.border),
        ..bank-rows(ctx, view, iban: x => figures(
          ctx,
          x,
          weight: t.weights.strong,
        ))
          .map(((k, v)) => (text(fill: t.colors.text-muted, k), v))
          .flatten()
      ),
      qr,
    )
  })
}

// --- the look --------------------------------------------------------------------

#let look = {
  c.colors(
    primary: rgb("#15325b"), // deep navy
    accent: rgb("#c9972c"), // brass: rules and ticks only, never text
    text: rgb("#18202b"),
    text-muted: rgb("#556070"),
    border: rgb("#c6cdd7"),
    // a cooler, quieter surface than the schema's tint: brand hue, low chroma
    tint: t => {
      let (l, ch, hue, ..) = oklch(t.colors.primary).components()
      rgb(oklch(95.5%, calc.min(ch * 0.25, 0.018), hue))
    },
  )
  // the display face is embedded in every Typst build; body keeps the schema default
  c.fonts(heading: "Libertinus Serif")
  c.sizes(body: 9.5pt, title: 2.6em, large: 1.15em, fine: 7pt)
  c.strokes(thick: 1.5pt)
  c.spacing(small: 0.4em, medium: 0.75em)
  c.title(color: t => t.colors.primary-text)
  c.items-table(
    zebra: (none, t => t.colors.tint),
    header-fill: t => t.colors.primary,
    rule: t => t.colors.border,
    // narrow columns (the 124 mm sidebar body): a smaller header keeps the figure
    // columns as narrow as their figures
    header-style: (size: 0.88em),
    row-inset: t => t.spacing.small * 0.9,
  )
  c.line-items(gap: 0.9em)
  c.totals(width: 52%, min-width: 96mm)
  c.area("letterhead", rule: t => (
    side: bottom,
    stroke: t.strokes.regular + t.colors.accent,
    gap: 1.5mm,
  ))
  c.area("title", inset: (top: 1mm, bottom: 3mm))
  c.area("references", inset: (bottom: 2mm))
  c.area("footer", rule: t => (
    side: top,
    stroke: t.strokes.thin + t.colors.border,
    gap: 0.8mm,
  ))
  c.area(
    "page-number",
    text: (fill: t => t.colors.text-muted),
    inset: (bottom: 1mm),
  )
  c.part("title", title)
  c.part("references", references)
  c.part("reference-list", reference-list)
  c.part("recipient", recipient)
  c.part("sender", sender)
  c.wrap("company", (ctx, view, inner) => keep-units(inner(ctx, view)))
  c.wrap("registration", (ctx, view, inner) => keep-units(inner(ctx, view)))
  c.part("totals", totals)
  c.wrap("payment-terms", payment-terms)
  c.part("bank-details", bank-details)
  // closing and name without a handwriting gap: a small invoice keeps its
  // signature on page 1 of the window layouts too (sn-010130-left, us-letter-10)
  c.part("signature", tight-signature)
  // colours this look draws beyond the core pairs
  c.checks(pairs: (
    corporate-payable: t => (t.colors.on-primary, t.colors.primary),
    corporate-kicker: t => (t.colors.primary-text, t.colors.background),
    corporate-callout: t => (t.colors.text, t.colors.tint),
  ))
}
