// Default FRAME parts, placed by the layout into areas.
// Contract: (ctx, view) => content. `view` = frame view (built by root, fresh).
// Built-in parts read ONLY ctx.theme.tokens and ctx.theme.options.<own name>.

#import "../../utils/iban.typ": format-iban, normalize-iban
#import "../color.typ": on-color

#let _t(ctx) = ctx.theme.tokens
#let _o(ctx, part) = ctx.theme.options.at(part)
// Label and figure faces (tokens fonts.label and fonts.numeric; both default to fonts.body).
#let _label-font(ctx) = _t(ctx).fonts.label
#let _numeric-font(ctx) = _t(ctx).fonts.numeric
#let _numeric(ctx, body) = text(
  font: _numeric-font(ctx),
  number-width: _t(ctx).fonts.number-width,
  body,
)

/// The page label from the locale string `strings.document.page: (current, total) => content`.
#let page-label(ctx, current, total) = (ctx.locale.strings.document.page)(
  current,
  total,
)
/// A label in the label voice (fonts.label).
#let label-text(ctx, ..args, body) = text(
  font: _t(ctx).fonts.label,
  ..args,
  body,
)
/// Figures in the numeric voice (fonts.numeric, tabular or proportional per fonts.number-width).
#let numeric-text(ctx, ..args, body) = text(
  font: _t(ctx).fonts.numeric,
  number-width: _t(ctx).fonts.number-width,
  ..args,
  body,
)

/// The logo. On a dark surface (view.area.surface) `logo.on-dark` decides: auto
/// puts the logo on a light plate (corner radius radii.medium; a normal dark logo would vanish), content
/// replaces it (a light version), none keeps it as it is.
#let logo(ctx, view) = {
  let o = _o(ctx, "logo")
  if o.image == none { return none }
  let surface = if view.area == none { none } else {
    view.area.at("surface", default: none)
  }
  let dark = type(surface) == color and on-color(surface) == white
  if dark and o.on-dark != none {
    if o.on-dark == auto {
      let pad = calc.max(1.2mm, o.height * 0.12)
      return box(fill: white, radius: _t(ctx).radii.medium, inset: pad, box(
        height: o.height,
        o.image,
      ))
    }
    return box(height: o.height, o.on-dark)
  }
  box(height: o.height, o.image)
}

// E-mail addresses and URLs never break (not even at their own hyphens): a reader
// types them off the paper.
#let _unbroken(v) = if (
  type(v) == str
    and (v.contains("@") or v.starts-with("www.") or v.contains("://"))
) { box(v) } else { v }

// sender, recipient and the legal blocks take their line spacing from the area
// (`par`, layout data), so an area's `par` reaches them.
#let sender(ctx, view) = {
  let s = view.sender
  (strong(s.name), ..s.lines).join(linebreak())
}

/// The sender's label/value pairs (`sender.extra`: phone, contact person, ..).
#let sender-details(ctx, view) = {
  let extras = view.sender.extra
  if type(extras) != array or extras.len() == 0 { return none }
  set text(size: 0.9em)
  grid(columns: 2, column-gutter: .6em, row-gutter: .6em, ..extras
      .map(a => (label-text(ctx)[#a.at(0):], _unbroken(a.at(1))))
      .flatten())
}

// Recipient notes (the recipient's `extra`, e.g. a customer contact or a postal
// note): the DIN 5008 "Zusatz- und Vermerkzone" between the return address and
// the address. An area that hosts the return address prints them under it;
// otherwise the recipient part prints them above its name.
#let _recipient-notes(ctx, view) = {
  let extras = view.recipient.at("extra", default: ())
  if type(extras) != array or extras.len() == 0 { return none }
  text(
    size: _t(ctx).sizes.small,
    extras
      .map(a => [#a.at(0, default: none): #a.at(1, default: none)])
      .join([, ]),
  )
}

#let _hosts(view, part) = (
  part
    in view
      .at("area", default: (:))
      .at(
        "parts",
        default: (),
      )
)

#let return-address(ctx, view) = {
  let s = view.sender
  let bits = (
    s.at("name-inline", default: none),
    s.at("address-inline", default: none),
    s.at("city-inline", default: none),
  )
  // the underline hangs 2pt below the baseline: reserve it (plus air) inside the
  // part, so a bottom-aligned return address never touches the recipient below
  block(inset: (bottom: 5pt), text(size: _t(ctx).sizes.fine, underline(
    offset: 2pt,
    bits.filter(x => x not in (none, "", [])).join([, ]),
  )))
  if _hosts(view, "recipient") {
    let notes = _recipient-notes(ctx, view)
    if notes != none { block(inset: (bottom: 3pt), notes) }
  }
}

#let recipient(ctx, view) = {
  let r = view.recipient
  let address = (r.name, ..r.lines).join(linebreak())
  let notes = if not _hosts(view, "return-address") {
    _recipient-notes(ctx, view)
  }
  if notes == none { address } else {
    stack(spacing: 0.6em, notes, address)
  }
}

// reference labels in the label face and the secondary colour, values in the figure face
#let _ref-label(ctx, k, size: auto) = text(
  font: _label-font(ctx),
  fill: _t(ctx).colors.text-muted,
  ..if size != auto { (size: size) },
  k,
)

#let references(ctx, view) = {
  if view.references.len() == 0 { return none }
  grid(
    columns: (1fr,) * calc.min(4, view.references.len()),
    row-gutter: 8pt,
    ..view.references.map(((k, v)) => [#_ref-label(
        ctx,
        k,
        size: _t(ctx).sizes.small,
      ) \ #_numeric(ctx, v)]),
  )
}

/// The references as a vertical label/value list (DIN information block style);
/// `references` renders them as a row.
#let reference-list(ctx, view) = {
  let rows = view.references
  if rows.len() == 0 { return none }
  set text(size: 0.9em)
  grid(
    columns: (auto, 1fr),
    column-gutter: 1em,
    row-gutter: 0.55em,
    ..rows.map(((k, v)) => (_ref-label(ctx, k), _numeric(ctx, v))).flatten(),
  )
}

/// REQUIRED ROLE: renders document title/subject, number, place and date.
#let title(ctx, view) = {
  let d = view.document
  let o = _o(ctx, "title")
  let t = _t(ctx)
  if o.arrange == "stack" {
    text(
      size: t.sizes.title,
      weight: t.weights.strong,
      fill: o.color,
      font: t.fonts.heading,
      d.title,
    )
    linebreak()
    text(
      fill: t.colors.text-muted,
    )[#ctx.locale.strings.reference.invoice-number: #d.number #h(1.2em) #if o.show-place-date [#d.date.text]]
  } else {
    grid(
      columns: (1fr, auto),
      align: (left + bottom, right + bottom),
      text(
        size: t.sizes.title,
        weight: t.weights.strong,
        fill: o.color,
        font: t.fonts.heading,
      )[#d.subject #d.number],
      if o.show-place-date {
        if d.place != none [#d.place, ]
        strong(d.date.text)
      },
    )
  }
}

// --- legal footer blocks (#18): one part per block, composed by an area ---------
// They print at the fine size and INHERIT the area's text colour (the footer
// areas set the secondary colour; a filled rail sets its own), so they work on
// dark surfaces too. E-mail addresses and URLs never hyphenate.
#let _small(ctx, body) = {
  set text(size: _t(ctx).sizes.fine, hyphenate: false)
  set par(justify: false)
  body
}
#let company(ctx, view) = _small(ctx, (
  strong(view.sender.name),
  ..view.sender.lines,
).join(linebreak()))
#let contact(ctx, view) = {
  let e = view.sender.extra
  if type(e) != array or e.len() == 0 { return none }
  _small(ctx, e.map(((k, v)) => [#k: #_unbroken(v)]).join(linebreak()))
}
/// Company register entry, management, VAT ID and tax number.
#let registration(ctx, view) = {
  let s = view.sender
  let ref = ctx.locale.strings.reference
  let rows = ()
  if s.at("register", default: none) != none { rows.push(s.register) }
  if s.at("management", default: none) != none { rows.push(s.management) }
  if s.at("vat-id", default: none) != none {
    rows.push([#ref.vat-id: #_numeric(ctx, s.vat-id)])
  }
  if s.at("tax-nr", default: none) != none {
    rows.push([#ref.tax-number: #_numeric(ctx, s.tax-nr)])
  }
  if rows.len() == 0 { return none }
  _small(ctx, rows.join(linebreak()))
}
/// IBAN (grouped in fours, as printed on paper) and BIC.
#let bank-account(ctx, view) = {
  let b = view.bank
  if b == none or b.at("iban", default: "") in ("", none) { return none }
  let iban = if type(b.iban) == str {
    format-iban(normalize-iban(b.iban)).replace(" ", "\u{202F}")
  } else { b.iban }
  let rows = ([IBAN: #_numeric(ctx, iban)],)
  if b.at("bic", default: "") not in ("", none) {
    rows.push([BIC: #_numeric(ctx, b.bic)])
  }
  _small(ctx, rows.join(linebreak()))
}

/// "Page 1 of 2". `from: auto` (default) labels every page whenever the invoice
/// has more than one; an int is the first page that shows a label.
#let page-number(ctx, view) = {
  let p = view.page
  let o = _o(ctx, "page-number")
  if p == none { return none }
  if o.from == auto { if p.total < 2 { return none } } else if (
    p.current < o.from
  ) { return none }
  set text(size: _t(ctx).sizes.small)
  if o.format == auto { page-label(ctx, p.current, p.total) } else {
    (o.format)(ctx, p.current, p.total)
  }
}

// One line: a string is shortened with an ellipsis, other content is clipped.
#let _one-line(body, width) = {
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

/// Compact header of following pages: sender · subject on the left (the subject
/// shortened to one line), the invoice number on the right. The page label lives
/// in `page-number` only.
#let continuation(ctx, view) = {
  let t = _t(ctx)
  set text(size: t.sizes.small, fill: t.colors.text-muted, hyphenate: false)
  set par(justify: false)
  let d = view.document
  let dot = [#h(0.5em)·#h(0.5em)]
  if _o(ctx, "continuation").show-subject {
    grid(
      columns: (auto, 1fr, auto),
      column-gutter: 0pt,
      align: (left, left, right),
      view.sender.name,
      layout(size => [#dot#_one-line(
          d.subject,
          size.width - measure(dot).width - 1.2em.to-absolute(),
        )]),
      _numeric(ctx, d.number),
    )
  } else { view.sender.name }
  v(-0.4em)
  line(length: 100%, stroke: t.strokes.thin + t.colors.text-muted)
}

/// Fold and punch marks from layout geometry (layout.marks).
#let marks(ctx, view) = {
  let m = view.marks
  if m == none { return none }
  for y in m.fold {
    place(top + left, dx: m.left, dy: y, line(
      length: m.length,
      stroke: m.stroke,
    ))
  }
  if m.punch != none {
    place(top + left, dx: m.left, dy: m.punch, line(
      length: m.length * 1.6,
      stroke: m.stroke,
    ))
  }
}

/// RESERVED (experimental): Swiss QR-bill payment part, fed from root's fresh ctx.
/// Placeholder showing the brand-immune zone until the QR-bill component exists.
#let qr-bill(ctx, view) = {
  line(length: 100%, stroke: (dash: "dashed", thickness: 0.5pt))
  place(top + left, dx: 5mm, dy: -0.6em, text(size: 8pt)[✂])
  grid(
    columns: (62mm, 1fr),
    inset: 5mm,
    stroke: (x, y) => if x == 0 { (right: 0.5pt) },
    [#text(11pt, weight: "bold")[Empfangsschein] \ #text(
        8pt,
      )[reserved 62 × 105 mm]],
    [#text(11pt, weight: "bold")[Zahlteil] \ #text(
        8pt,
      )[reserved 148 × 105 mm - regulated font, black]],
  )
}

#let frame-parts = (
  logo: logo,
  sender: sender,
  sender-details: sender-details,
  return-address: return-address,
  recipient: recipient,
  references: references,
  reference-list: reference-list,
  title: title,
  company: company,
  contact: contact,
  registration: registration,
  bank-account: bank-account,
  page-number: page-number,
  continuation: continuation,
  marks: marks,
  qr-bill: qr-bill,
)
