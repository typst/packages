// LOOK `technical` - IT freelancers, software houses, engineering offices.
// A spec sheet: a clean sans for prose, a monospace voice for labels and every
// figure (fonts.label / fonts.numeric), a fine rule grid instead of fills, and
// `// SECTION ───` markers in the accent colour. The only colour block is the
// payable amount, set inverted in primary like a terminal selection.
//
// Replaced parts: sender, title, totals, bank-details (four). The items table is
// the built-in renderer, styled through options (header-style, row-rule, rule),
// so it keeps the totals as its table footer (never widowed). recipient,
// reference-list and payment-terms are wrapped, the rest are built-ins.

#import "../custom.typ" as c
#import "kit.typ"

#let _t(ctx) = ctx.theme.tokens

/// Uppercase, tracked label in the label voice (the look's signature element).
#let tag(ctx, body, fill: auto, size: 0.74em, weight: "regular") = text(
  font: _t(ctx).fonts.label,
  size: size,
  tracking: 0.06em,
  weight: weight,
  fill: if fill == auto { _t(ctx).colors.text-muted } else { fill },
  upper(body),
)

/// Figures (amounts, numbers, codes) in the numeric voice.
#let fig(ctx, body, size: 0.92em) = text(
  font: _t(ctx).fonts.numeric,
  size: size,
  number-width: _t(ctx).fonts.number-width,
  body,
)

/// Section marker: `// LABEL ──────────`, the label in the accent used as text.
#let marker(ctx, label) = {
  let t = _t(ctx)
  grid(
    columns: (auto, 1fr),
    column-gutter: 0.7em,
    align: horizon,
    {
      text(font: t.fonts.label, size: 0.74em, fill: t.colors.text-muted, "//")
      h(0.45em)
      tag(ctx, label, fill: t.colors.accent-text, weight: t.weights.strong)
    },
    line(length: 100%, stroke: t.strokes.hairline + t.colors.border),
  )
}

/// Label/value list: tracked labels, figures as values.
#let kv(ctx, rows) = kit.label-grid(
  rows,
  columns: (auto, auto),
  label: k => tag(ctx, k),
  value: v => fig(ctx, v),
  column-gutter: 1.2em,
  row-gutter: 0.5em,
)

// --- frame parts -----------------------------------------------------------------

#let sender(ctx, view) = {
  let t = _t(ctx)
  let s = view.sender
  text(font: t.fonts.label, weight: t.weights.strong, size: 1.02em, s.name)
  if s.lines.len() > 0 {
    linebreak()
    text(
      size: t.sizes.small,
      fill: t.colors.text-muted,
      s.lines.join[#h(0.4em)·#h(0.4em)],
    )
  }
}

/// A label above the block, except inside an envelope window.
#let _labelled(label) = (ctx, view, inner) => {
  let body = inner(ctx, view)
  if body == none or kit.in-window(view) { return body }
  tag(ctx, label(ctx))
  v(0.55em, weak: true)
  block(body)
}

/// REQUIRED ROLE (title): the document word as a label, the number large in the
/// numeric voice (stepped down until it fits the column), the subject without a
/// repeated document word; date on the right.
#let title(ctx, view) = {
  let t = _t(ctx)
  let d = view.document
  let o = ctx.theme.options.title
  let subject = kit.strip-word(d.subject, d.title)
  let number = size => text(
    font: t.fonts.numeric,
    size: size,
    weight: t.weights.strong,
    fill: o.color,
    tracking: -0.01em,
    d.number,
  )
  let head = layout(room => {
    tag(
      ctx,
      d.title,
      fill: t.colors.accent-text,
      weight: t.weights.strong,
      size: 0.8em,
    )
    v(0.4em, weak: true)
    // responsive: a long number steps down instead of overflowing the column
    let size = t.sizes.title
    while size > t.sizes.large and measure(number(size)).width > room.width {
      size = size * 0.9
    }
    block(below: 0.75em, number(size))
    if subject not in (none, "", []) {
      text(fill: t.colors.text-muted, subject)
    }
  })
  let meta = if o.show-place-date {
    kv(ctx, ((ctx.locale.strings.reference.invoice-date, d.date.text),))
  }
  grid(
    columns: (1fr, auto),
    align: (left + bottom, left + bottom),
    column-gutter: 2em,
    head, meta,
  )
}

// --- body parts --------------------------------------------------------------------

/// REQUIRED (totals): a right-aligned ledger from view.totals.rows; the payable
/// row is inverted (on-primary on primary).
#let totals(ctx, view) = {
  let t = _t(ctx)
  let o = ctx.theme.options.totals
  let line-row(r) = {
    let fill = kit.row-color(ctx, r)
    let small = r.kind in ("discount", "surcharge", "tax", "prepayment")
    let weight = if r.emphasis == none { "regular" } else { t.weights.strong }
    grid(
      columns: (1fr, auto),
      column-gutter: 1em,
      align: (left + bottom, right + bottom),
      inset: (x: t.spacing.small, y: t.spacing.medium * 0.55),
      text(
        fill: fill,
        weight: weight,
        size: if small { t.sizes.small } else { 1em },
        r.label,
      ),
      fig(ctx, text(fill: fill, weight: weight, kit.row-value(r))),
    )
  }
  let out = ()
  let prev = none
  for r in view.totals.rows {
    if r.payable {
      out.push(v(0.45em))
      out.push(block(
        width: 100%,
        fill: t.colors.primary,
        radius: t.radii.small,
        inset: (x: t.spacing.small + 0.25em, y: t.spacing.medium),
        grid(
          columns: (1fr, auto),
          align: (left + horizon, right + horizon),
          tag(
            ctx,
            r.label,
            fill: t.colors.on-primary,
            weight: t.weights.strong,
            size: 0.82em,
          ),
          fig(
            ctx,
            text(
              fill: t.colors.on-primary,
              weight: t.weights.strong,
              r.value.text,
            ),
            size: t.sizes.large,
          ),
        ),
      ))
    } else {
      // a rule above the strong rows (net total, total) and the prepayment group
      if (
        prev != none
          and (
            r.emphasis != none
              or (r.kind == "prepayment" and prev != "prepayment")
          )
      ) {
        out.push(line(length: 100%, stroke: t.strokes.thin + t.colors.text))
      }
      out.push(line-row(r))
    }
    prev = r.kind
  }
  align(right, block(width: o.width, breakable: false, stack(
    spacing: 0pt,
    ..out,
  )))
}

#let bank-details(ctx, view) = {
  let t = _t(ctx)
  let rows = kit.bank-rows(ctx, view, number: x => text(
    weight: t.weights.strong,
    x,
  ))
  block(breakable: false, above: 1.2em, {
    marker(ctx, ctx.locale.strings.sections.payment)
    v(0.6em, weak: true)
    grid(
      columns: (1fr, auto),
      column-gutter: 1.5em,
      align: (left + top, right + top),
      kv(ctx, rows), kit.bank-qr(ctx, view, default: 20mm),
    )
  })
}

/// The payment sentence behind an accent bar (a stroke, not text: no contrast pair).
#let payment-terms(ctx, view, inner) = block(
  inset: (left: 0.9em, y: 0.15em),
  stroke: (left: _t(ctx).strokes.regular * 2 + _t(ctx).colors.accent),
  inner(ctx, view),
)

// --- the look ------------------------------------------------------------------------

#let look = {
  c.colors(
    primary: rgb("#155e75"),
    text: rgb("#0f172a"),
    text-muted: rgb("#526070"),
    border: rgb("#c3cbd5"),
  )
  c.fonts(
    // no sans is guaranteed: the chain ends in the embedded serif, which reads like
    // technical documentation next to the embedded mono (intentional fallback)
    body: ("Inter", "Liberation Sans", "Arial", "Libertinus Serif"),
    label: "DejaVu Sans Mono", // embedded in every Typst: identical everywhere, no warnings
    numeric: "DejaVu Sans Mono",
  )
  c.sizes(body: 9.5pt, small: 0.86em, large: 1.12em, title: 2.2em)
  c.strokes(hairline: 0.3pt, thin: 0.5pt, regular: 0.8pt, thick: 1.6pt)
  c.spacing(small: 0.42em, medium: 0.66em)
  c.radii(small: 0pt, medium: 0pt) // a spec sheet has square corners
  c.items-table(
    zebra: (none, none),
    rule: t => t.colors.text,
    header-style: (
      size: 0.74em,
      tracking: 0.06em,
      fill: t => t.colors.text-muted,
    ),
    row-rule: t => t.strokes.hairline + t.colors.border,
    row-inset: t => t.spacing.small * 0.6,
  )
  c.totals(width: 50%)
  c.area("title", inset: (top: 1mm, bottom: 3mm))
  c.area("footer", rule: t => (
    side: top,
    stroke: t.strokes.thin + t.colors.border,
    gap: 1.4mm,
  ))
  // the folio sits above the footer rule with clear air (design review: >= 2 mm)
  c.area("page-number", text: (font: t => t.fonts.label), inset: (bottom: 3mm))
  c.area("continuation", text: (font: t => t.fonts.label))
  c.part("sender", sender)
  c.wrap("recipient", _labelled(ctx => ctx.locale.strings.address.recipient))
  c.wrap("reference-list", _labelled(ctx => {
    ctx.locale.strings.sections.details
  }))
  c.part("title", title)
  c.part("totals", totals)
  c.part("bank-details", bank-details)
  c.wrap("payment-terms", payment-terms)
  // colours this look draws as text beyond the core pairs
  c.checks(pairs: (
    technical-accent-labels: t => (t.colors.accent-text, t.colors.background),
    technical-payable: t => (t.colors.on-primary, t.colors.primary),
  ))
}
