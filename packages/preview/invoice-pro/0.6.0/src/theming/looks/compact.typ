// LOOK `compact`: wholesale, distribution and B2B supply, collective invoices over
// several delivery notes with 40-80+ lines. Function over decoration: 8.5 pt type,
// single-line rows on a zebra that survives greyscale copies, an item-number and a
// unit column, a filled column header that repeats on every page, delivery-note
// groups as level-2 table headers (kept with their first row, repeated on the next
// page), boxed totals with a filled payable row, and explicit continuation
// ("Continued on page 2 -> Page 1 of 2").
// Public mechanisms only: tokens, options, look-safe area fields, part renderers.
// Default layout: a4-dense (us-letter-dense in the US), experimental.
#import "../custom.typ" as c
#import "../color.typ": on-color
#import "kit.typ": (
  bank-qr, bank-rows, figures, label-grid, split-seller-ids, tight-signature,
)

#let _t(ctx) = ctx.theme.tokens

/// A small capital label in the strong weight (group and column voice).
#let _label(ctx, body, fill: auto) = {
  let t = _t(ctx)
  text(
    font: t.fonts.label,
    size: t.sizes.small,
    weight: t.weights.strong,
    fill: if fill == auto { t.colors.text-muted } else { fill },
    upper(body),
  )
}

// --- frame parts -----------------------------------------------------------------

/// The name on the first line, the address on ONE line (the contact lines live in
/// the footer, so nothing is printed twice).
#let sender(ctx, view) = {
  let t = _t(ctx)
  let s = view.sender
  set par(leading: 0.45em, justify: false)
  text(
    weight: t.weights.strong,
    size: t.sizes.large,
    font: t.fonts.heading,
    s.name,
  )
  if s.lines.len() > 0 {
    linebreak()
    text(size: t.sizes.small, fill: t.colors.text-muted, s.lines.join[ · ])
  }
}

/// The recipient; in a flow area (not behind an envelope window) with a label.
#let recipient(ctx, view) = {
  let t = _t(ctx)
  let r = view.recipient
  set par(leading: 0.45em, justify: false)
  if view.area == none or not view.area.window {
    _label(ctx, ctx.locale.strings.address.recipient)
    v(0.35em, weak: true)
  }
  (text(weight: t.weights.strong, r.name), ..r.lines).join(linebreak())
}

// labels in the label voice, secondary colour; values as figures
#let _grid-label(ctx) = k => text(
  font: ctx.theme.tokens.fonts.label,
  fill: ctx.theme.tokens.colors.text-muted,
  k,
)

#let _ref-grid(ctx, rows) = label-grid(
  rows.map(((k, v)) => (k, figures(ctx, v))),
  label: _grid-label(ctx),
  align: left + top,
  column-gutter: 0.9em,
  row-gutter: 0.45em,
)

/// References as a list. The SELLER's tax identifiers form their own group under
/// the locale's sender label ("From" / "Rechnungssteller:in"), so a reader never
/// takes them for the customer's numbers.
#let reference-list(ctx, view) = {
  let (refs, seller) = split-seller-ids(view)
  if refs.len() + seller.len() == 0 { return none }
  set par(justify: false)
  if refs.len() > 0 { _ref-grid(ctx, refs) }
  if seller.len() > 0 {
    block(
      above: if refs.len() > 0 { 0.9em } else { 0pt },
      {
        _label(ctx, ctx.locale.strings.address.sender)
        v(0.3em, weak: true)
        _ref-grid(ctx, seller)
      },
    )
  }
}

/// References as a row (DIN layouts); the seller's tax identifiers in one labelled cell.
#let references(ctx, view) = {
  let (refs, seller) = split-seller-ids(view)
  let t = _t(ctx)
  let cells = refs.map(((k, v)) => [#text(
      fill: t.colors.text-muted,
      k,
    ) \ #figures(ctx, v)])
  if seller.len() > 0 {
    cells.push({
      _label(ctx, ctx.locale.strings.address.sender)
      v(0.3em, weak: true)
      _ref-grid(ctx, seller)
    })
  }
  if cells.len() == 0 { return none }
  set text(size: t.sizes.small)
  grid(columns: (auto,) * cells.len(), column-gutter: 2.2em, ..cells)
}

/// REQUIRED ROLE. The document word in capitals (title.color), the subject, then a
/// tight fact grid with number and date.
#let title(ctx, view) = {
  let t = _t(ctx)
  let o = ctx.theme.options.title
  let d = view.document
  let ref = ctx.locale.strings.reference
  let muted(x) = text(fill: t.colors.text-muted, x)
  set par(justify: false)
  block(below: 0.35em, text(
    size: t.sizes.title,
    weight: t.weights.strong,
    fill: o.color,
    font: t.fonts.heading,
    tracking: 0.04em,
    upper(d.title),
  ))
  if d.subject not in (none, "", d.title) {
    block(below: 0.6em, muted(d.subject))
  }
  let date = if (
    o.show-place-date and d.place != none
  ) [#d.place, #d.date.text] else { d.date.text }
  grid(
    columns: (auto, auto),
    column-gutter: 0.9em,
    row-gutter: 0.45em,
    muted(ref.invoice-number),
    text(weight: t.weights.strong, figures(ctx, d.number)),

    muted(ref.invoice-date), date,
  )
}

/// Running header of following pages: sender, document and number, and the
/// customer number when given, over a rule in the brand colour. The page label
/// lives in `page-number` only.
#let continuation(ctx, view) = {
  let t = _t(ctx)
  let d = view.document
  let cust = view.references.find(((k, v)) => (
    k == ctx.locale.strings.reference.customer-number
  ))
  set text(size: t.sizes.small, hyphenate: false)
  set par(justify: false)
  [#text(weight: t.weights.strong, view.sender.name) #h(0.6em) #text(
      fill: t.colors.text-muted,
    )[#d.title #figures(ctx, d.number)#if (
        cust != none
      ) [ · #cust.at(0) #figures(ctx, cust.at(1))]]]
  v(-0.3em)
  line(length: 100%, stroke: t.strokes.regular + t.colors.primary)
}

/// The page label, plus an explicit pointer to the next page on every page but the
/// last ("Continued on page 2 -> Page 1 of 2"). Honours page-number.from / format.
#let page-number(ctx, view) = {
  let t = _t(ctx)
  let p = view.page
  let o = ctx.theme.options.page-number
  if p == none { return none }
  if o.from == auto { if p.total < 2 { return none } } else if (
    p.current < o.from
  ) { return none }
  let label = if o.format == auto {
    (ctx.locale.strings.document.page)(p.current, p.total)
  } else { (o.format)(ctx, p.current, p.total) }
  set text(size: t.sizes.small)
  if p.current < p.total {
    [#text(fill: t.colors.text-muted, (
        ctx.locale.strings.document.continued-on
      )(p.current + 1)) #h(0.4em) #sym.arrow.r #h(0.8em) #text(
        weight: t.weights.strong,
        label,
      )]
  } else { text(weight: t.weights.strong, label) }
}

// --- body parts ----------------------------------------------------------------------

/// The seller's item number (item-id: str or (seller:, standard:, buyer:)).
#let _item-code(it) = {
  let id = it.at("item-id", default: none)
  if type(id) == str { return id }
  if type(id) == dictionary {
    for k in ("seller", "standard", "buyer") {
      if id.at(k, default: none) not in (none, "") { return id.at(k) }
    }
  }
  none
}
#let _unit-of(it) = {
  let u = it.at("unit", default: none)
  if type(u) == dictionary {
    u.at("display", default: u.at("name", default: none))
  } else { u }
}

/// Dense items table: one line per item (description and dates in the same cell),
/// regular-weight names, figures in the numeric voice, a filled repeating header,
/// item-number and unit columns when items carry them. Honours items-table
/// (zebra, header-fill, header-text, header-style, rule, row-rule, row-inset,
/// column-order, repeat-header) and line-items colours. Emits `table.header`.
#let items-table(ctx, view) = {
  let t = _t(ctx)
  let o = ctx.theme.options.items-table
  let li = ctx.theme.options.line-items
  let s = ctx.locale.strings.line-items
  let l = view.layout-information
  let net = view.tax-mode == "exclusive"
  let visible = (
    quantity: l.show-quantity,
    unit-price: l.show-unit-price,
    tax-rate: l.show-tax-rates,
    total-price: l.show-total-price,
  )
  let cols = o.column-order.filter(k => visible.at(k, default: false))
  let entries = view.entries
  let items = entries.filter(e => e.kind == "item")
  let has-code = items.any(it => _item-code(it) != none)
  let show-unit = (
    l.show-units
      and "quantity" in cols
      and items.any(it => _unit-of(it) != none)
  )

  let keys = ()
  if l.show-pos { keys.push("pos") }
  if has-code { keys.push("code") }
  keys.push("description")
  for k in cols {
    keys.push(k)
    if k == "quantity" and show-unit { keys.push("unit") }
  }
  let numeric = ("quantity", "unit-price", "tax-rate", "total-price")
  let col-align(k) = if k in numeric { right } else { left }
  let n = keys.len()
  let desc-at = keys.position(k => k == "description")
  let total-at = keys.position(k => k == "total-price")

  let hf = o.header-fill
  let hc = if o.header-text != auto { o.header-text } else if hf == none {
    t.colors.text
  } else { on-color(hf) }
  let hstyle = (
    (
      font: t.fonts.label,
      weight: t.weights.strong,
      size: t.sizes.small,
      fill: hc,
    )
      + o.header-style
  )
  let tag = text(weight: "regular", size: 0.9em)[ #if net { s.net } else {
    s.gross
  }]
  let label = (
    pos: s.position,
    code: s.item-id,
    description: s.description,
    quantity: s.quantity,
    unit: s.unit,
    unit-price: [#s.unit-price#tag],
    tax-rate: s.vat,
    total-price: [#s.total#tag],
  )
  let pad = (x: t.spacing.small * 1.3, y: o.row-inset)
  let head = keys.map(k => table.cell(
    fill: hf,
    inset: (x: pad.x, y: t.spacing.medium),
    align: col-align(k) + horizon,
    text(..hstyle, label.at(k)),
  ))
  let zebra(index, e) = {
    let st = e.at("style", default: none)
    if st != none and st.at("fill", default: none) != none { return st.fill }
    if type(o.zebra) == function { return (o.zebra)(index) }
    if calc.odd(index) { o.zebra.at(0) } else { o.zebra.at(1) }
  }
  let row-rule = if o.row-rule == none { none } else if (
    type(o.row-rule) == color
  ) { t.strokes.hairline + o.row-rule } else { o.row-rule }
  // pads a partial row: `cells` fills columns [from, to), the rest stays empty
  let tail(cell, from) = if n - from > 0 {
    (cell(colspan: n - from, []),)
  } else { () }

  let rows = ()
  let index = 0
  for e in entries {
    if e.kind == "group-header" {
      let body = [#text(weight: t.weights.strong)[#e.pos #h(
            0.6em,
          ) #e.name]#if e.has-description [ #h(0.8em) #text(
            fill: t.colors.text-muted,
            size: t.sizes.small,
            e.description,
          )]]
      // level-2 header: never orphaned at a page end, repeated while the group continues
      rows.push(table.header(
        level: 2,
        repeat: o.repeat-header,
        table.hline(stroke: t.strokes.thin + t.colors.primary),
        table.cell(
          colspan: n,
          inset: (x: pad.x, top: t.spacing.medium, bottom: t.spacing.small),
          body,
        ),
      ))
      index = 0
      continue
    }
    if e.kind == "group-footer" {
      rows.push(table.hline(stroke: t.strokes.thin + o.rule))
      let span = if total-at == none { n } else { total-at }
      rows.push(table.cell(colspan: span, inset: pad, align: right, text(
        weight: t.weights.strong,
        size: t.sizes.small,
      )[#s.subtotal #e.name]))
      if total-at != none {
        rows.push(table.cell(inset: pad, align: right, text(
          weight: t.weights.strong,
          figures(ctx, e.subtotal),
        )))
        rows += tail(table.cell, total-at + 1)
      }
      rows.push(table.cell(colspan: n, inset: 0pt, v(t.spacing.small)))
      continue
    }
    if e.kind != "item" { continue }
    index += 1
    if row-rule != none and index > 1 {
      rows.push(table.hline(stroke: row-rule))
    }
    let cell = table.cell.with(fill: zebra(index, e), inset: pad)
    let mods = if l.show-modifier {
      e.discounts.map(m => (m, true)) + e.surcharge.map(m => (m, false))
    } else { () }
    let name = {
      e.name
      if e.has-date and l.show-dates {
        h(0.6em)
        text(size: t.sizes.small, fill: t.colors.text-muted, e.date)
      }
      if e.has-description and l.show-descriptions {
        linebreak()
        text(size: t.sizes.small, fill: t.colors.text-muted, e.description)
      }
    }
    let content = (
      pos: text(fill: t.colors.text-muted, e.pos),
      code: text(fill: t.colors.text-muted, figures(ctx, _item-code(e))),
      description: name,
      quantity: figures(ctx, e.quantity),
      unit: _unit-of(e),
      unit-price: figures(ctx, e.price),
      tax-rate: [#e.tax.rate],
      total-price: figures(ctx, if mods.len() > 0 { e.unmodified-total } else {
        e.total
      }),
    )
    for k in keys { rows.push(cell(align: col-align(k) + top, content.at(k))) }
    for (m, d) in mods {
      let col = if d { li.discount-color } else { li.surcharge-color }
      let lab = if m.at("label", default: none) == none {
        if d { s.discount } else { s.surcharge }
      } else { m.label }
      let pct = if m.is-percent [ (#if d [−] else [+]#m.display)] else []
      let span = if total-at == none { n - desc-at } else { total-at - desc-at }
      if desc-at > 0 { rows.push(cell(colspan: desc-at, [])) }
      rows.push(cell(colspan: span, text(
        size: t.sizes.small,
        fill: col,
      )[↳ #lab#if m.name not in (none, "", []) [: #m.name]#pct]))
      if total-at != none {
        rows.push(cell(align: right, text(fill: col, figures(
          ctx,
        )[#if d [−] else [+] #m.absolute])))
        rows += tail(cell, total-at + 1)
      }
    }
    if mods.len() > 0 and total-at != none {
      if desc-at > 0 { rows.push(cell(colspan: desc-at, [])) }
      rows.push(cell(colspan: total-at - desc-at, text(
        size: t.sizes.small,
        weight: t.weights.strong,
        s.subtotal,
      )))
      rows.push(cell(align: right, text(weight: t.weights.strong, figures(
        ctx,
        e.total,
      ))))
      rows += tail(cell, total-at + 1)
    }
  }

  set text(number-width: t.fonts.number-width)
  set par(justify: false, leading: t.spacing.leading)
  table(
    columns: keys.map(k => if k == "description" { 1fr } else { auto }),
    stroke: none,
    table.header(repeat: o.repeat-header, ..head),
    ..rows,
    table.hline(stroke: t.strokes.regular + o.rule),
  )
}

/// Boxed totals from the row model: quiet rows, net and total lines strong, the
/// payable row (view.totals.payable) filled in the brand colour. totals.fill tints
/// the quiet rows; totals.width with totals.min-width sets the box width.
#let totals(ctx, view) = {
  let t = _t(ctx)
  let o = ctx.theme.options.totals
  let li = ctx.theme.options.line-items
  let pad = (x: t.spacing.medium, y: t.spacing.small * 1.2)
  let quiet = if o.fill != none { o.fill } else { none }
  let quiet-fg = if o.color != auto { o.color } else if o.fill != none {
    on-color(o.fill)
  } else { t.colors.text }
  let cells = ()
  for r in view.totals.rows {
    let label = if (
      r.rate != none and r.kind in ("discount", "surcharge")
    ) [#r.label #box[(#r.rate)]] else { r.label }
    if r.payable {
      let st = (
        fill: t.colors.on-primary,
        weight: t.weights.strong,
        size: t.sizes.large,
      )
      cells.push(grid.cell(
        fill: t.colors.primary,
        inset: (x: pad.x, y: t.spacing.medium),
        align: left,
        text(..st, upper(label)),
      ))
      cells.push(grid.cell(
        fill: t.colors.primary,
        inset: (x: pad.x, y: t.spacing.medium),
        align: right,
        text(..st, figures(ctx, r.value.text)),
      ))
      continue
    }
    let col = if r.kind in ("discount", "prepayment") {
      li.discount-color
    } else if r.kind == "surcharge" { li.surcharge-color } else if (
      r.kind == "tax"
    ) {
      t.colors.text-muted
    } else { quiet-fg }
    let w = if r.emphasis != none { t.weights.strong } else { "regular" }
    if r.emphasis != none and cells.len() > 0 {
      cells.push(grid.hline(stroke: t.strokes.thin + t.colors.border))
    }
    cells.push(grid.cell(fill: quiet, inset: pad, align: left, text(
      fill: col,
      weight: w,
      label,
    )))
    cells.push(grid.cell(fill: quiet, inset: pad, align: right, text(
      fill: col,
      weight: w,
      figures(ctx, r.value.text),
    )))
  }
  set par(justify: false)
  let box-of(w) = block(
    width: w,
    breakable: false,
    stroke: t.strokes.thin + t.colors.primary,
    grid(columns: (1fr, auto), ..cells),
  )
  let w = o.width
  align(right, if o.min-width == none { box-of(w) } else {
    layout(size => {
      let abs = if type(w) == ratio { w * size.width } else if (
        type(w) == relative
      ) { w.ratio * size.width + w.length.to-absolute() } else {
        w.to-absolute()
      }
      box-of(calc.min(size.width, calc.max(abs, o.min-width.to-absolute())))
    })
  })
}

/// Bank details as a two-column label grid in the look's voice (IBAN grouped in
/// fours, the payment reference), headed by the locale's section label, QR right.
#let bank-details(ctx, view) = {
  let t = _t(ctx)
  block(breakable: false, above: 1.2em, {
    grid(
      columns: (1fr, auto),
      column-gutter: 5mm,
      align: (left + top, right + top),
      {
        _label(
          ctx,
          ctx.locale.strings.sections.bank-details,
          fill: t.colors.text,
        )
        v(0.45em, weak: true)
        label-grid(
          bank-rows(ctx, view),
          label: _grid-label(ctx),
          align: left + top,
          column-gutter: 1.2em,
          row-gutter: 0.45em,
        )
      },
      bank-qr(ctx, view, default: 22mm),
    )
  })
}

// --- the look ------------------------------------------------------------------------

#let look = {
  c.colors(
    primary: rgb("#1d3557"), // steel navy
    accent: rgb("#c2410c"), // signal orange (reserved for marks; not used as text)
    text: rgb("#111827"),
    text-muted: rgb("#4b5563"),
    border: rgb("#9aa5b4"),
    // zebra: 11 % of the seed on white (#e5e9ee for the navy): visible at 8.5 pt
    // on greyscale copies, and it follows a brand colour
    tint: t => rgb(color.mix(
      (t.colors.primary, 11%),
      (white, 89%),
      space: rgb,
    )),
  )
  c.fonts(
    body: ("Inter", "Arial", "Liberation Sans", "Libertinus Serif"),
    number-width: "tabular",
  )
  c.sizes(body: 8.5pt, small: 0.88em, fine: 6.5pt, large: 1.2em, title: 1.9em)
  c.weights(strong: "semibold")
  c.strokes(hairline: 0.25pt, thin: 0.4pt, regular: 0.75pt, thick: 1.5pt)
  c.spacing(small: 0.3em, medium: 0.55em, leading: 0.45em)
  c.logo(height: 10mm)
  c.title(color: t => t.colors.primary-text) // the brand as text: stays legible for light seeds
  c.line-items(gap: 0.9em)
  c.items-table(
    zebra: (none, t => t.colors.tint),
    header-fill: t => t.colors.primary,
    rule: t => t.colors.border,
    repeat-header: true,
    row-inset: t => t.spacing.small,
  )
  c.totals(width: 60%, min-width: 85mm)
  c.bank-details(qr-size: 22mm)
  // look-safe area fields only
  c.area("letterhead", inset: (bottom: 2mm))
  c.area("title", inset: (top: 1.5mm, bottom: 3mm))
  c.area(
    "footer",
    rule: t => (side: top, stroke: t.strokes.thin + t.colors.border, gap: 0pt),
    inset: (top: 1.8mm),
  )
  c.part("sender", sender)
  c.part("recipient", recipient)
  c.part("reference-list", reference-list)
  c.part("references", references)
  c.part("title", title)
  c.part("continuation", continuation)
  c.part("page-number", page-number)
  c.part("items-table", items-table)
  c.part("totals", totals)
  c.part("bank-details", bank-details)
  c.part("signature", tight-signature)
}
