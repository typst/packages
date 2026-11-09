// LOOK `bold`: creative and branding agencies, design, photo and motion studios,
// marketing and event agencies. A poster block in the one brand colour carries the
// document word in oversized type and the amount the recipient pays; everything
// else is disciplined: capital labels in the label voice (DejaVu Sans Mono, embedded
// in every Typst build), heavy rules over the table and the footer, a light tint of
// the seed for zebra rows, and the payable amount repeated on a colour bar.
// All colours derive from the one seed, so theme.custom.brand(color: ..) restyles it.
// Public mechanisms only: tokens, options, look-safe area fields, part renderers.
#import "../custom.typ" as c
#import "../color.typ": luminance, on-color
#import "kit.typ": (
  bank-qr, blank, caps, figures, fit-size, label-grid, payable-label,
  tight-signature,
)

#let _t(ctx) = ctx.theme.tokens

/// The disc in the poster block: another shade of the seed that moves AWAY from
/// the text colour (on-primary), so the text stays legible where it crosses the
/// disc. On a very dark seed a darker disc would merge with the block, so it
/// turns lighter instead. Declared as the contrast pair `bold-disc`.
#let disc-color(t) = {
  let p = t.colors.primary
  if on-color(p) == white {
    if luminance(p) < 0.03 { rgb(p.lighten(22%)) } else { rgb(p.darken(22%)) }
  } else { rgb(p.lighten(30%)) }
}

/// Letterhead: the name large, the address on one line.
#let sender(ctx, view) = {
  let t = _t(ctx)
  let s = view.sender
  set par(leading: 0.45em, justify: false)
  text(
    font: t.fonts.heading,
    size: 1.45em,
    weight: t.weights.strong,
    tracking: -0.01em,
    s.name,
  )
  if s.lines.len() > 0 {
    linebreak()
    text(
      size: 0.9em,
      fill: t.colors.text-muted,
      s.lines.join[#h(0.35em)/#h(0.35em)],
    )
  }
}

/// Sans at the fine size: a mono line would wrap inside the window's return zone.
#let return-address(ctx, view) = {
  let t = _t(ctx)
  let s = view.sender
  let bits = (
    s.at("name-inline", default: none),
    s.at("address-inline", default: none),
    s.at("city-inline", default: none),
  )
  block(inset: (bottom: 3.5pt), text(
    size: t.sizes.fine,
    fill: t.colors.text-muted,
    bits.filter(x => x not in (none, "", [])).join[#h(0.3em)/#h(0.3em)],
  ))
}

/// In a flow area the recipient gets a capital label; behind an envelope window
/// (view.area.window) it stays a bare postal address.
#let recipient(ctx, view) = {
  let r = view.recipient
  set par(leading: 0.5em)
  if view.area == none or not view.area.window {
    caps(
      ctx,
      ctx.locale.strings.address.recipient,
      fill: _t(ctx).colors.text-muted,
    )
    v(0.55em, weak: true)
  }
  (strong(r.name), ..r.lines).join(linebreak())
}

#let _pairs(ctx, rows) = label-grid(
  rows.map(((k, v)) => (k, figures(ctx, v))),
  label: k => caps(ctx, k, fill: _t(ctx).colors.text-muted),
  row-gutter: 0.7em,
  align: (left + bottom, left + bottom),
)

/// References as a label/value list (the a4-digital and window layouts' info block).
#let reference-list(ctx, view) = {
  if view.references.len() == 0 { return none }
  set text(size: 0.92em)
  _pairs(ctx, view.references)
}

/// The sender's phone, e-mail, .. (DIN information block).
#let sender-details(ctx, view) = {
  let e = view.sender.extra
  if type(e) != array or e.len() == 0 { return none }
  set text(size: 0.88em, hyphenate: false)
  label-grid(
    e,
    label: k => caps(ctx, k, fill: _t(ctx).colors.text-muted),
    row-gutter: 0.7em,
    align: (left + bottom, left + bottom),
  )
}

/// References as a row (DIN layouts put them in the flow above the title).
#let references(ctx, view) = {
  let r = view.references
  if r.len() == 0 { return none }
  grid(
    columns: (1fr,) * calc.min(4, r.len()),
    row-gutter: 0.9em,
    ..r.map(((k, v)) => [#caps(
        ctx,
        k,
        fill: _t(ctx).colors.text-muted,
      ) \ #figures(ctx, v)]),
  )
}

/// REQUIRED ROLE. The poster block (about 36-38 mm without a subject line): the
/// number and date in the label voice, the document word as large as fits next to
/// the payable amount (stepped down from sizes.title until it fits on one line),
/// the amount the recipient pays with the same label as the totals bar.
#let title(ctx, view) = {
  let t = _t(ctx)
  let o = ctx.theme.options.title
  let d = view.document
  let ref = ctx.locale.strings.reference
  let fg = t.colors.on-primary
  let due = view.totals.due
  let small = 0.78em
  let meta = [#caps(ctx, ref.invoice-number, size: small) #h(0.4em) #text(
      font: t.fonts.label,
      size: small,
      d.number,
    )]
  if o.show-place-date {
    let date = if d.place != none [#d.place, #d.date.text] else { d.date.text }
    meta += [#h(0.8em)#text(font: t.fonts.label, size: small)[/]#h(0.8em)#text(
        font: t.fonts.label,
        size: small,
        date,
      )]
  }
  let amount = if due.text != none {
    align(right, {
      caps(ctx, payable-label(ctx, view), size: small)
      v(0.7em, weak: true)
      figures(ctx, text(
        size: 2.3em,
        weight: t.weights.strong,
        tracking: -0.02em,
        top-edge: "cap-height",
        bottom-edge: "baseline",
        due.text,
      ))
    })
  }
  let word(size) = text(
    font: t.fonts.heading,
    size: size,
    weight: t.weights.strong,
    tracking: -0.035em,
    top-edge: "cap-height",
    bottom-edge: "baseline",
    hyphenate: true,
    d.title,
  )
  let pad = 7mm
  block(
    width: 100%,
    fill: t.colors.primary,
    inset: (x: pad, top: 4.5mm, bottom: 5mm),
    below: 0pt,
    clip: true,
    {
      place(top + right, dx: pad + 18mm, dy: -5mm - 36mm, circle(
        radius: 44mm,
        fill: disc-color(t),
      ))
      set text(fill: fg)
      set par(justify: false)
      grid(
        columns: (1fr, auto),
        align: (left + top, right + top),
        meta,
        if view.currency != none {
          text(font: t.fonts.label, size: small, view.currency)
        },
      )
      block(above: 5mm, below: 0pt, layout(size => {
        let gutter = 6mm
        let room = (
          size.width
            - (
              if amount == none { 0pt } else { measure(amount).width + gutter }
            )
        )
        let steps = (1, 0.88, 0.76, 0.66, 0.57, 0.5).map(f => t.sizes.title * f)
        grid(
          columns: (1fr, auto),
          column-gutter: gutter,
          align: (left + bottom, right + bottom),
          word(fit-size(word, room, steps)), amount,
        )
      }))
      if d.subject not in (none, "", d.title) {
        block(above: 3.5mm, text(size: 1.05em, d.subject))
      }
    },
  )
}

/// Totals from the row model: quiet rows, the net and total lines strong, the
/// payable row (view.totals.payable) on a colour bar; rows after it (inclusive
/// taxes) follow as small notes. The bar takes totals.fill / totals.color when set.
#let totals(ctx, view) = {
  let t = _t(ctx)
  let o = ctx.theme.options.totals
  let li = ctx.theme.options.line-items
  let rows = view.totals.rows
  let at = rows.position(r => r.payable)
  let (before, payable, after) = (
    rows.slice(0, at),
    rows.at(at),
    rows.slice(at + 1),
  )
  let label-of(r) = if (
    r.rate != none and r.kind in ("discount", "surcharge")
  ) [#r.label #box[(#r.rate)]] else { r.label }
  let cells = ()
  for (i, r) in before.enumerate() {
    let fg = if r.kind in ("discount", "prepayment") {
      li.discount-color
    } else if r.kind == "surcharge" {
      li.surcharge-color
    } else if r.kind == "tax" { t.colors.text-muted } else { t.colors.text }
    let w = if r.emphasis != none { t.weights.strong } else { "regular" }
    if r.emphasis != none and i > 0 {
      cells.push(grid.hline(stroke: t.strokes.thin + t.colors.border))
    }
    cells.push(grid.cell(inset: (y: 0.36em), text(
      fill: fg,
      weight: w,
      label-of(r),
    )))
    cells.push(grid.cell(inset: (y: 0.36em), text(
      fill: if r.kind == "tax" { t.colors.text } else { fg },
      weight: w,
      figures(ctx, r.value.text),
    )))
  }
  let fill = if o.fill != none { o.fill } else { t.colors.primary }
  let fg = if o.color != auto { o.color } else if o.fill != none {
    on-color(fill)
  } else { t.colors.on-primary }
  let bar = block(
    width: 100%,
    fill: fill,
    inset: (x: 5mm, y: 3mm),
    below: 0.6em,
    grid(
      columns: (1fr, auto),
      align: (left + horizon, right + horizon),
      caps(ctx, payable.label, size: 0.8em, fill: fg),
      figures(ctx, text(
        size: t.sizes.large,
        weight: t.weights.strong,
        fill: fg,
        tracking: -0.01em,
        payable.value.text,
      )),
    ),
  )
  let body = {
    if cells.len() > 0 {
      grid(columns: (1fr, auto), column-gutter: 1.5em, align: (
          left,
          right,
        ), ..cells)
      v(0.35em)
    }
    bar
    if after.len() > 0 {
      set text(size: t.sizes.small, fill: t.colors.text-muted)
      grid(
        columns: (1fr, auto), column-gutter: 1.5em, row-gutter: 0.5em, align: (
          left,
          right,
        ),
        ..after.map(r => (r.label, figures(ctx, r.value.text))).flatten(),
      )
    }
  }
  let w = o.width
  align(right, block(breakable: false, if o.min-width == none {
    block(width: w, body)
  } else {
    layout(size => {
      let abs = if type(w) == ratio { w * size.width } else if (
        type(w) == relative
      ) { w.ratio * size.width + w.length.to-absolute() } else {
        w.to-absolute()
      }
      block(
        width: calc.min(size.width, calc.max(abs, o.min-width.to-absolute())),
        body,
      )
    })
  }))
}

/// Column headers in capitals: header-style sets the voice (label font, size,
/// tracking), but set text() cannot change case, so the wrap upper-cases the
/// header rows (the default table's header spans rows 0-3: spacer, rule, labels,
/// spacer; API gap: a header case option).
#let items-table(ctx, view, inner) = {
  show table.cell: it => if it.y < 4 { upper(it) } else { it }
  inner(ctx, view)
}

/// Bank details under a heavy rule, as columns in the look's label voice: who
/// (holder, bank), where (IBAN grouped in fours, BIC), what (payment reference);
/// the QR code on the right. Two text rows high, so it sits beside the QR code.
#let bank-details(ctx, view) = {
  let t = _t(ctx)
  let s = ctx.locale.strings.bank-details
  let b = view.sender
  let cell(k, v) = [#caps(ctx, k, fill: t.colors.text-muted) \ #v]
  let who = ((s.account-holder, b.name), (s.bank, b.bank))
    .filter(((_, v)) => not blank(v))
    .map(((k, v)) => cell(k, v))
  let where = (cell(s.iban, figures(ctx, view.iban.text)),)
  if not blank(b.bic) { where.push(cell(s.bic, figures(ctx, b.bic))) }
  let what = if view.show-reference and view.payment-reference != none {
    (cell(s.reference, figures(ctx, view.payment-reference)),)
  } else { () }
  let cols = (who, where, what).filter(c => c.len() > 0)
  let depth = calc.max(..cols.map(c => c.len()))
  let cells = range(depth)
    .map(i => cols.map(c => c.at(i, default: [])))
    .flatten()
  block(breakable: false, above: 1em, below: 1em, {
    line(length: 100%, stroke: t.strokes.regular + t.colors.text)
    v(0.6em, weak: true)
    set par(leading: 0.5em)
    grid(
      columns: (1fr, auto),
      column-gutter: 6mm,
      align: (left + top, right + top),
      grid(columns: (auto,)
          * cols.len(), column-gutter: 7mm, row-gutter: 0.9em, ..cells),
      bank-qr(ctx, view, default: 20mm),
    )
  })
}

#let payment-terms(ctx, view, inner) = block(above: 1em, text(
  size: 1.05em,
  inner(ctx, view),
))

/// Legal footer columns weighted by what they hold (the register column carries
/// the longest lines), for any number of footer parts on any layout: on A4, an
/// e-mail line such as "E-Mail: jane.doe@example.com" and a German IBAN fit on
/// one line each. An empty part (no `extra`, no bank account) gives up its column.
#let footer-weights = (
  company: 0.75fr,
  contact: 1.05fr,
  registration: 1.4fr,
  bank-account: 1.25fr,
)
#let arrange-footer(ctx, cells, area) = {
  let cells = cells.filter(((_, body)) => not blank(body))
  grid(
    columns: cells.map(((name, _)) => footer-weights.at(
      if name == none { "" } else { name },
      default: 1fr,
    )),
    column-gutter: 1.1em,
    ..cells.map(((_, body)) => body),
  )
}

#let look = {
  c.colors(
    primary: rgb("#2b2bd9"), // electric ultramarine: the one vivid colour
    text: rgb("#111114"),
    text-muted: rgb("#5b5b66"),
    border: rgb("#111114"),
    tint: t => t.colors.primary.lighten(92%),
  )
  c.fonts(
    // Inter where installed, then the platform grotesques; the chain ends in the
    // embedded Libertinus Serif (proportional, so the legal footer keeps its fit)
    body: ("Inter", "Arial", "Liberation Sans", "Libertinus Serif"),
    label: ("DejaVu Sans Mono",), // embedded: the label voice survives every install
  )
  c.sizes(body: 9.8pt, small: 0.85em, fine: 7pt, large: 1.75em, title: 4.3em)
  c.weights(strong: "bold")
  c.strokes(hairline: 0.3pt, thin: 0.5pt, regular: 1.6pt, thick: 1.6pt)
  c.spacing(small: 0.45em, medium: 0.65em)
  c.line-items(discount-color: rgb("#c2185b"))
  c.items-table(
    zebra: (none, t => t.colors.tint),
    header-fill: none,
    rule: t => t.colors.text,
    header-style: (size: 0.74em, tracking: 0.06em, weight: "regular"),
  )
  c.totals(width: 58%, min-width: 80mm)
  c.logo(height: 12mm)
  // "1 / 2": language-neutral and without descenders; shown only on multi-page invoices
  c.page-number(format: (ctx, current, total) => [#current / #total])
  // the heavy rule over the legal footer is zero-height decoration; the folio keeps
  // 1.3 mm plus the stack gap (0.4em), about 2.7 mm, of air above it
  c.area(
    "page-number",
    text: (font: t => t.fonts.label, fill: t => t.colors.text-muted),
    inset: (bottom: 1.3mm),
  )
  c.area(
    "footer",
    rule: t => (side: top, stroke: t.strokes.regular + t.colors.text, gap: 0pt),
    inset: (top: 2.2mm),
    arrange: arrange-footer,
  )
  c.checks(pairs: (bold-disc: t => (t.colors.on-primary, disc-color(t))))
  c.part("sender", sender)
  c.part("return-address", return-address)
  c.part("recipient", recipient)
  c.part("sender-details", sender-details)
  c.part("reference-list", reference-list)
  c.part("references", references)
  c.part("title", title)
  c.part("totals", totals)
  c.wrap("items-table", items-table)
  c.part("bank-details", bank-details)
  c.wrap("payment-terms", payment-terms)
  c.part("signature", (ctx, view) => tight-signature(
    ctx,
    view,
    strong-name: true,
  ))
}
