// The SERIF family: the shared parts of the presets `elegant` and `prestige`.
// One body grammar, two colourings (the tokens decide):
//   - a centred letterhead: logo above the name (beside it when the area is too
//     low), the name in spaced display capitals over a short accent rule, the
//     address on one line;
//   - the document word centred between hairlines, number and date on ONE line;
//   - labels in tracked small capitals (fonts.label), figures in fonts.numeric;
//   - a hairline table, the payable amount between a thin rule and the
//     accountant's double rule, the bank details as a label grid.
// Colour roles: text-muted for secondary labels, accent-text for key labels
// (column heads, the payable, "Bill to"), border for hairlines, accent for the
// rules that frame the document word and the payable. elegant keeps accent =
// primary (ink); prestige sets champagne.
// Uses only public mechanisms: tokens, options, look-safe area fields and part
// renderers that read ctx.theme / ctx.locale / the view.
#import "../custom.typ" as c
#import "../color.typ": on-color
#import "kit.typ": (
  bank-qr, bank-rows, blank, block-width, double-rule, figures, label-grid,
  one-line, small-caps, spaced,
)

#let _t(ctx) = ctx.theme.tokens

/// Secondary label: small capitals in the secondary text colour.
#let label(ctx, body, ..args) = small-caps(
  ctx,
  body,
  fill: _t(ctx).colors.text-muted,
  size: _t(ctx).sizes.small,
  ..args,
)
/// Key label: small capitals in the accent used as text (colors.accent-text).
#let key-label(ctx, body, ..args) = small-caps(
  ctx,
  body,
  fill: _t(ctx).colors.accent-text,
  ..args,
)
#let _hairline(ctx) = _t(ctx).strokes.hairline + _t(ctx).colors.border

// --- frame parts -------------------------------------------------------------------

/// Letterhead arrangement (`arrange` of the letterhead area): every cell centred.
/// In order of preference: the logo ABOVE the other cells when the area is tall
/// enough (or flows); BESIDE them when the words keep their one-line width there
/// (DIN 5008 form A: 19 mm); above them with the logo scaled to the height left
/// (narrow boxes such as SN 010130: 80 x 30 mm); beside them with the logo scaled
/// to at most 40 % of the width. The logo column never shrinks below its content
/// (a squeezed column would cut an on-dark plate into bars). Works with any part
/// order the layout hosts (DIN: logo, sender; US: sender, logo).
#let letterhead-arrange(ctx, cells, area) = {
  let full = cells.filter(((n, b)) => not blank(b))
  let logo = full.find(((n, b)) => n == "logo")
  let rest = full.filter(((n, b)) => n != "logo").map(((n, b)) => b)
  let words = stack(spacing: 2.5mm, ..rest.map(b => align(center, b)))
  if logo == none { return align(center, words) }
  let mark = logo.last()
  let gap = 3mm
  let gutter = 5mm
  let fits(h) = area.height == auto or h <= area.height
  let height-at(w) = measure(block(width: w, words)).height
  let wh = height-at(area.width)
  let m = measure(mark)
  let above(mk) = stack(spacing: gap, align(center, mk), words)
  let beside(mk, mw) = align(center, grid(
    columns: (mw, area.width - mw - gutter),
    column-gutter: gutter,
    align: (center + horizon, center + horizon),
    mk, words,
  ))
  if fits(m.height + gap + wh) { return above(mark) }
  let side = area.width - m.width - gutter
  if (
    side > 0pt
      and height-at(side) <= wh + 0.5pt
      and fits(calc.max(m.height, wh))
  ) {
    return beside(mark, m.width)
  }
  if m.height > 0pt {
    let f = (area.height - gap - wh) / m.height
    if f >= 0.45 and m.width * f <= area.width {
      return above(scale(f * 100%, reflow: true, mark))
    }
  }
  let f = calc.min(1, 0.4 * area.width / calc.max(m.width, 1pt))
  if area.height != auto and m.height > 0pt {
    f = calc.min(f, area.height / m.height)
  }
  beside(scale(f * 100%, reflow: true, mark), m.width * f)
}

/// The name in spaced display capitals (tracking narrows in slim areas), a short
/// accent rule and the address on one line. Colour: inherited from the area.
#let sender(ctx, view) = {
  let t = _t(ctx)
  let s = view.sender
  set par(justify: false, leading: 0.5em)
  set align(center)
  let name(tr, f: 1) = text(
    font: t.fonts.heading,
    size: t.sizes.large * f,
    weight: "regular",
    spaced(s.name, tracking: tr),
  )
  // the name stays on ONE line: full tracking, then narrow tracking, then a
  // smaller size (down to 72 %); only a name longer than that wraps
  layout(size => {
    if measure(name(0.24em)).width <= size.width { return name(0.24em) }
    let w = measure(name(0.06em)).width
    if w <= size.width { return name(0.06em) }
    name(0.06em, f: calc.max(0.72, size.width / w * 0.98))
  })
  block(above: 0.6em, below: 0.6em, line(
    length: 18mm,
    stroke: t.strokes.thin + t.colors.accent,
  ))
  if s.lines.len() > 0 {
    text(
      size: t.sizes.fine * 1.15,
      tracking: 0.06em,
      s.lines.join[#h(0.45em)·#h(0.45em)],
    )
  }
}

/// Return-address line (DIN zone) with a hairline exactly as wide as the text,
/// never wider than the area; the hairline's space is reserved inside the part.
#let return-address(ctx, view) = {
  let t = _t(ctx)
  let s = view.sender
  let bits = (
    s.at("name-inline", default: none),
    s.at("address-inline", default: none),
    s.at("city-inline", default: none),
  )
  let line-text = text(
    size: t.sizes.fine,
    fill: t.colors.text-muted,
    tracking: 0.03em,
    bits.filter(x => not blank(x)).join[#h(0.35em)·#h(0.35em)],
  )
  layout(size => {
    let w = calc.min(size.width, measure(line-text).width)
    block(inset: (bottom: 3.5pt), {
      line-text
      v(1.6pt, weak: false)
      line(length: w, stroke: _hairline(ctx))
    })
  })
}

/// Recipient; in a flow area (no envelope window) introduced by a key label.
#let recipient(ctx, view) = {
  let r = view.recipient
  set par(justify: false)
  let window = view.area != none and view.area.at("window", default: false)
  if not window {
    block(below: 0.7em, key-label(
      ctx,
      ctx.locale.strings.address.recipient,
      size: _t(ctx).sizes.small,
    ))
  }
  (r.name, ..r.lines).join(linebreak())
}

/// The sender's label/value pairs as a label grid (DIN information block).
#let sender-details(ctx, view) = {
  let e = view.sender.extra
  if type(e) != array or e.len() == 0 { return none }
  set text(size: 0.9em)
  set par(justify: false)
  label-grid(
    e.map(((k, v)) => (
      k,
      if type(v) == str and v.contains("@") { box(v) } else { v },
    )),
    label: k => label(ctx, k),
  )
}

/// The references as a label grid.
#let reference-list(ctx, view) = {
  let rows = view.references
  if rows.len() == 0 { return none }
  set text(size: 0.92em)
  set par(justify: false)
  label-grid(rows.map(((k, v)) => (k, figures(ctx, v))), label: k => label(
    ctx,
    k,
  ))
}

/// The references as a row: labels over values (DIN reference line).
#let references(ctx, view) = {
  let r = view.references
  if r.len() == 0 { return none }
  set par(justify: false)
  grid(
    columns: (1fr,) * calc.min(4, r.len()),
    row-gutter: 0.8em,
    ..r.map(((k, v)) => [#label(ctx, k) \ #figures(ctx, v)]),
  )
}

/// REQUIRED ROLE. The document word in spaced capitals between hairlines; below,
/// ONE line: number · place, date · subject (the subject moves to its own line
/// when it does not fit or when `title.arrange` is "stack"). Number and date are
/// rendered verbatim (identity check).
#let title(ctx, view) = {
  let t = _t(ctx)
  let o = ctx.theme.options.title
  let d = view.document
  set par(justify: false)
  let word = text(
    font: t.fonts.heading,
    size: t.sizes.title,
    weight: "regular",
    fill: o.color,
    spaced(d.title, tracking: 0.3em),
  )
  let area = view.at("area", default: none)
  if area != none and area.name != "title" {
    // hosted in a shared row (a4-dense: recipient | references | title): the
    // column is as wide as its content, so no full-width rules; the word, a
    // short accent rule, then number, date and subject, one per line
    let rows = (
      [#label(ctx, ctx.locale.strings.reference.invoice-number) #h(
          0.2em,
        ) #figures(ctx, d.number)],
    )
    if o.show-place-date {
      rows.push(text(style: "italic")[#if (
          d.place != none
        ) [#d.place, ]#d.date.text])
    }
    let subject = d.subject
    if (
      type(subject) in (str, content)
        and not blank(subject)
        and subject != d.title
        and not (
          type(subject) == str
            and type(d.title) == str
            and subject.starts-with(d.title)
        )
    ) { rows.push(text(style: "italic", subject)) }
    // right-aligned: the last letter carries no tracking (a trailing negative
    // space would be trimmed at the line end and the word would overhang)
    let flush = if type(d.title) == str and d.title.clusters().len() > 1 {
      let cs = upper(d.title).clusters()
      text(
        font: t.fonts.heading,
        size: t.sizes.title,
        weight: "regular",
        fill: o.color,
        text(tracking: 0.3em, cs.slice(0, -1).join()) + cs.last(),
      )
    } else { word }
    return align(right, stack(
      spacing: 0.5em,
      align(right, flush),
      align(right, line(
        length: 18mm,
        stroke: t.strokes.thin + t.colors.accent,
      )),
      ..rows.map(r => align(right, r)),
    ))
  }
  let rule = line(length: 100%, stroke: _hairline(ctx))
  block(above: 0.4em, below: 0.45em, grid(
    columns: (1fr, auto, 1fr),
    column-gutter: 1.2em,
    align: horizon,
    rule, word, rule,
  ))
  let dot = text(fill: t.colors.text-muted)[#h(0.7em)·#h(0.7em)]
  let facts = [#label(ctx, ctx.locale.strings.reference.invoice-number) #h(
      0.2em,
    ) #figures(ctx, d.number)]
  if o.show-place-date {
    facts += [#dot#text(style: "italic")[#if (
          d.place != none
        ) [#d.place, ]#d.date.text]]
  }
  let subject = d.subject
  let has-subject = (
    type(subject) in (str, content)
      and not blank(subject)
      and subject != d.title
  )
  if (
    type(subject) == str
      and type(d.title) == str
      and subject.starts-with(d.title)
  ) { has-subject = false }
  let subj = text(style: "italic", subject)
  let second = if not has-subject { facts } else if o.arrange == "stack" {
    [#facts \ #subj]
  } else {
    layout(size => align(center, if measure([#facts#dot#subj]).width
      <= size.width { [#facts#dot#subj] } else { [#facts \ #subj] }))
  }
  block(width: 100%, below: 0.5em, align(center, second))
}

/// Following pages: the sender's name in small capitals, the subject shortened to
/// one line, the document word and number on the right, a hairline below.
#let continuation(ctx, view) = {
  let t = _t(ctx)
  let d = view.document
  set text(size: t.sizes.small, fill: t.colors.text-muted, hyphenate: false)
  set par(justify: false)
  let name = small-caps(ctx, view.sender.name, tracking: 0.12em)
  let doc = [#d.title #h(0.3em) #figures(ctx, d.number, fill: t.colors.text)]
  let dot = [#h(0.5em)·#h(0.5em)]
  grid(
    columns: (auto, 1fr, auto),
    align: (left + bottom, left + bottom, right + bottom),
    name,
    if ctx.theme.options.continuation.show-subject
      and not blank(d.subject)
      and d.subject != d.title {
      layout(size => [#dot#text(style: "italic", one-line(
          d.subject,
          size.width - measure(dot).width - 1.2em.to-absolute(),
        ))])
    },
    doc,
  )
  v(-0.35em)
  line(length: 100%, stroke: _hairline(ctx))
}

// --- body parts -------------------------------------------------------------------

/// Totals from the row model (view.totals.rows, legal order, 0 % removed): quiet
/// rows, hairlines above the net and gross groups, then the PAYABLE row (the total,
/// or the amount due after prepayments) as the heaviest figure between a thin
/// accent rule and the accountant's double rule; inclusive taxes follow as notes.
/// Honours totals.width / min-width / fill / color and the line-items colours.
#let totals(ctx, view) = {
  let t = _t(ctx)
  let o = ctx.theme.options.totals
  let li = ctx.theme.options.line-items
  let rows = view.totals.rows
  let at = rows.position(r => r.payable)
  let (before, after) = if at == none { (rows, ()) } else {
    (rows.slice(0, at), rows.slice(at + 1))
  }
  let filled = o.fill != none
  let fg = if o.color != auto { o.color } else if filled {
    on-color(o.fill)
  } else { t.colors.text }
  let muted = if filled { fg } else { t.colors.text-muted }
  let key = if filled { fg } else { t.colors.accent-text }
  let accent = if filled { fg } else { t.colors.accent }
  let pad = (y: 0.34em)
  let cells = ()
  for (i, r) in before.enumerate() {
    let prev = if i > 0 { before.at(i - 1).kind }
    let group-start = (
      r.kind in ("net-total", "total")
        or (r.kind == "prepayment" and prev != "prepayment")
    )
    if i > 0 and group-start {
      cells.push(grid.hline(
        stroke: t.strokes.hairline + if filled { fg } else { t.colors.border },
      ))
    }
    let col = if r.kind in ("discount", "prepayment") {
      li.discount-color
    } else if r.kind == "surcharge" { li.surcharge-color } else { fg }
    let lab = if (
      r.rate != none and r.kind in ("discount", "surcharge")
    ) [#r.label (#r.rate)] else { r.label }
    let lab-col = if r.kind in ("discount", "surcharge", "prepayment") {
      col
    } else if r.kind == "tax" { muted } else { fg }
    cells.push(grid.cell(inset: pad, text(fill: lab-col, lab)))
    cells.push(grid.cell(inset: pad, figures(ctx, r.value.text, fill: col)))
  }
  let p = view.totals.payable
  if p != none {
    let big = (top: 0.62em, bottom: 0.55em)
    cells.push(grid.hline(stroke: t.strokes.thin + accent))
    cells.push(grid.cell(inset: big, align: left + horizon, small-caps(
      ctx,
      p.label,
      fill: key,
      tracking: 0.14em,
    )))
    cells.push(grid.cell(inset: big, align: right + horizon, figures(
      ctx,
      p.value.text,
      size: t.sizes.large,
      weight: t.weights.strong,
      fill: fg,
    )))
    cells.push(grid.cell(colspan: 2, inset: 0pt, double-rule(
      t.strokes.hairline + accent,
    )))
  }
  for r in after {
    cells.push(grid.cell(inset: (top: 0.45em), text(
      size: t.sizes.small,
      fill: muted,
      r.label,
    )))
    cells.push(grid.cell(inset: (top: 0.45em), figures(
      ctx,
      r.value.text,
      size: t.sizes.small,
      fill: muted,
    )))
  }
  let body = grid(columns: (1fr, auto), column-gutter: 1.5em, align: (
      left,
      right,
    ), ..cells)
  set text(fill: fg) if filled
  layout(size => {
    let w = block-width(o.width, o.min-width, size.width)
    let inner = if filled {
      block(
        width: w,
        fill: o.fill,
        inset: t.spacing.medium,
        radius: t.radii.small,
        body,
      )
    } else {
      block(width: w, body)
    }
    align(right, block(breakable: false, inner))
  })
}

/// Bank details as a label grid (holder, bank, IBAN grouped in fours, BIC, payment
/// reference) under a hairline, the QR code on the right. (An invalid IBAN is a
/// data issue of the core, as for the built-in renderer.)
#let bank-details(ctx, view) = {
  let t = _t(ctx)
  let rows = bank-rows(ctx, view)
  let qr = bank-qr(ctx, view, default: 22mm)
  block(width: 100%, breakable: false, {
    line(length: 100%, stroke: _hairline(ctx))
    v(0.55em, weak: true)
    set par(justify: false, leading: 0.5em)
    grid(
      columns: (1fr, auto),
      column-gutter: 1.5em,
      align: (left + horizon, right + horizon),
      label-grid(rows, label: k => label(ctx, k), row-gutter: 0.55em), qr,
    )
  })
}

// --- the shared patch ---------------------------------------------------------------

/// Parts and area styling shared by the family. Tokens and the colouring of the
/// letterhead area come from each preset.
#let family = {
  // hairline table: no fills, key-label column heads, rules in the border colour
  c.items-table(
    zebra: (none, none),
    header-fill: none,
    rule: t => t.colors.border,
    row-inset: t => t.spacing.small * 0.4,
    header-style: (
      features: ("smcp", "c2sc"),
      tracking: 0.08em,
      weight: "regular",
      fill: t => t.colors.accent-text,
    ),
  )
  c.totals(width: 55%, min-width: 72mm)
  c.bank-details(qr-size: 22mm)
  c.area("letterhead", arrange: letterhead-arrange, align: center + horizon)
  c.area("page-number", align: center, text: (style: "italic"))
  // a hairline over the legal footer (the computed bottom margin grows with it)
  c.area(
    "footer",
    cell-align: center,
    stroke: t => (top: t.strokes.hairline + t.colors.border),
    inset: (top: 1.6mm),
  )
  c.area("title", inset: (top: 3mm, bottom: 2.5mm))
  c.part("sender", sender)
  c.part("return-address", return-address)
  c.part("recipient", recipient)
  c.part("sender-details", sender-details)
  c.part("reference-list", reference-list)
  c.part("references", references)
  c.part("title", title)
  c.part("continuation", continuation)
  c.part("totals", totals)
  c.part("bank-details", bank-details)
}

/// Contrast pairs the family's parts introduce (checked under checks.min-contrast).
#let pairs = c.checks(pairs: (
  serif-key-labels: t => (t.colors.accent-text, t.colors.background),
))
