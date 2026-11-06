// ledger-rail: an invoice with a full-height navy rail and brass accents.
// Designed by pdfs.build. Library code is MIT licensed, see LICENSE.

#let default-colors = (
  ink: rgb("#15233b"),
  ink-deep: rgb("#0c1626"),
  accent: rgb("#b8892b"),
  accent-soft: rgb("#d9b45c"),
  canvas: rgb("#f4f5f7"),
  surface: rgb("#e9edf2"),
  muted: rgb("#5a6577"),
  rule: rgb("#d3d9e1"),
  on-ink: rgb("#f4f5f7"),
)

#let default-labels = (
  title: "Invoice",
  bill-to: "Bill to",
  description: "Description",
  quantity: "Qty",
  price: "Rate",
  amount: "Amount",
  subtotal: "Subtotal",
  total: "Total due",
  payment: "How to pay",
  page: "Page",
  of: "of",
)

#let default-fonts = (display: "Playfair Display", body: "Inter")

// Line boxes of Inter and Playfair Display with top-edge "ascender" and
// bottom-edge "descender". A line height converts to leading as
// `(height - box) * size`.
#let body-box = 1.210
#let display-box = 1.333

/// Formats an amount with two decimals and grouped thousands:
/// `format-money(1234.5)` gives "$1,234.50". Use it inside a custom `money`
/// formatter, e.g. `v => format-money(v, currency: "", thousands: ".", decimal: ",") + " €"`.
#let format-money(value, currency: "$", thousands: ",", decimal: ".") = {
  let cents = calc.round(calc.abs(value) * 100)
  let whole = str(calc.quo(cents, 100))
  let frac = calc.rem(cents, 100)
  let grouped = ""
  for (index, digit) in whole.rev().clusters().enumerate() {
    if index > 0 and calc.rem(index, 3) == 0 { grouped = thousands + grouped }
    grouped = digit + grouped
  }
  (if value < 0 { "−" } else { "" }) + currency + grouped + decimal + (if frac < 10 { "0" }) + str(frac)
}

// Tabular figures, so amounts line up in columns.
#let fig(body) = text(number-width: "tabular", body)

// A rule that takes up its own thickness in the flow, unlike a `line()` stroke.
#let bar(weight, fill) = block(width: 100%, height: weight, fill: fill)

// An array of lines is joined with line breaks; anything else is used as is.
#let lines(body) = if type(body) == array { body.join(linebreak()) } else { body }

/// Invoice with a full-height rail on the left for the sender, and the
/// invoice itself on the right. Use it as a show rule; the document body
/// becomes the closing note under the payment details.
///
/// - company (str, content): Sender name at the top of the rail.
/// - tagline (str, content, none): Small caps line under the company name.
/// - logo (auto, content, none): `auto` shows a brass tile with the first
///   letter of `company`; pass content such as `image("logo.svg", width: 37.5pt)`
///   to use your own mark, or `none` to hide it.
/// - rail (array): Rail sections, top to bottom. Each is a dictionary with a
///   `title` and any of: `body` (content or array of lines), `rows`
///   (dictionary of key: value), `note` (small print after the rows), `steps`
///   (array of `(date:, label:, done:)` for a timeline).
/// - rail-footer (content, array, none): Fine print at the foot of the rail.
/// - number (str): Invoice number, shown in the badge and the page footer.
/// - subtitle (str, content, none): Small caps line under the title.
/// - status (str, content, none): Outlined badge at the end of the meta row.
/// - meta (dictionary): Key facts under the title, e.g. `(Issued: "May 1, 2026")`.
/// - bill-to (dictionary): `name`, and optionally `role` and `address`.
/// - items (array): Line items as `(description:, detail:, quantity:, price:)`;
///   `detail` is optional.
/// - currency (str): Currency symbol placed before amounts.
/// - money (auto, function): Custom formatter `value => str` for every amount
///   and rate, for other currency placement or separators. See `format-money`.
/// - credit (dictionary, none): Amount deducted before tax, as
///   `(label:, amount:, note:)`; `note` is optional.
/// - tax (dictionary, none): Tax on the subtotal minus the credit, as
///   `(label:, rate:)` with `rate` a fraction, e.g. `0.08875`.
/// - due-note (str, content, none): Line under the total.
/// - payment (array): Payment options as `(title:, body:)`, shown side by side.
/// - footer (str, content, none): Left side of the page footer.
/// - paper (str): Paper size, e.g. `"a4"` or `"us-letter"`.
/// - colors (dictionary): Overrides for `default-colors`.
/// - fonts (dictionary): Overrides for `(display:, body:)` font families.
/// - labels (dictionary): Overrides for `default-labels`, for other languages.
#let invoice(
  company: "Company",
  tagline: none,
  logo: auto,
  rail: (),
  rail-footer: none,
  number: "INV-0001",
  subtitle: none,
  status: none,
  meta: (:),
  bill-to: (name: "Client"),
  items: (),
  currency: "$",
  money: auto,
  credit: none,
  tax: none,
  due-note: none,
  payment: (),
  footer: none,
  paper: "a4",
  colors: (:),
  fonts: (:),
  labels: (:),
  body,
) = {
  let colors = default-colors + colors
  let fonts = default-fonts + fonts
  let labels = default-labels + labels
  let amount = if money == auto { v => format-money(v, currency: currency) } else { money }
  let rate = if money == auto { v => format-money(v, currency: "") } else { money }

  let subtotal = items.map(item => item.quantity * item.price).sum(default: 0)
  let taxable = subtotal - if credit == none { 0 } else { credit.amount }
  let tax-amount = if tax == none { 0 } else { calc.round(taxable * tax.rate, digits: 2) }
  let total = taxable + tax-amount

  // A tracked, uppercase micro-label.
  let caps(body, size: 4.2pt, tracking: 0.9pt, fill: colors.muted, weight: 700) = text(
    size: size, weight: weight, tracking: tracking, fill: fill, upper(body),
  )

  // A paragraph at a given line height, with the half-leading above the first
  // and below the last line kept inside the block.
  let flow(
    body, size: 7.125pt, height: 1.85, fill: colors.muted, weight: 400,
    font: fonts.body, box: body-box,
  ) = block(inset: (y: (height - box) / 2 * size), {
    set par(leading: (height - box) * size, spacing: (height - box + 1) * size)
    set text(font: font, size: size, fill: fill, weight: weight)
    body
  })

  // ── Rail ──────────────────────────────────────────────────────────────────
  // Page chrome: it repeats full height on every page and does not grow, so
  // keep its content short enough to fit.
  let rail-width = 177pt
  let rail-rule = bar(0.75pt, colors.accent-soft.transparentize(72%))
  let rail-row(key, value) = grid(
    columns: (1fr, auto), inset: (y: 2.06pt),
    text(fill: colors.on-ink.transparentize(38%), key),
    align(right, fig(text(weight: 700, fill: colors.on-ink, value))),
  )
  let timeline(steps) = block(width: 100%, {
    // One hairline spine behind all markers: filled for done, hollow for pending.
    let step-height = 6pt * body-box + 1.5pt + 7.5pt * body-box
    place(top + left, dx: 2.25pt, dy: 3.75pt, rect(
      width: 0.75pt, fill: colors.accent-soft.transparentize(60%),
      height: steps.len() * step-height + (steps.len() - 1) * 9pt - 10.5pt,
    ))
    for (index, step) in steps.enumerate() {
      let done = step.at("done", default: false)
      grid(
        columns: (12.75pt, 1fr),
        place(top + left, dy: 2.25pt, if done {
          circle(radius: 2.625pt, fill: colors.accent-soft, stroke: none)
        } else {
          circle(radius: 2.06pt, fill: colors.ink-deep, stroke: 1.125pt + colors.accent-soft.transparentize(25%))
        }),
        {
          caps(step.date, size: 6pt, tracking: 1.12pt, fill: colors.on-ink.transparentize(55%), weight: 400)
          v(1.5pt)
          text(size: 7.5pt, weight: 700, fill: if done { colors.on-ink } else { colors.accent-soft }, step.label)
        },
      )
      if index + 1 < steps.len() { v(9pt) }
    }
  })

  let rail-content = {
    place(top + left, rect(
      width: rail-width, height: 100%,
      fill: gradient.linear(colors.ink, colors.ink-deep, angle: 88deg),
    ))
    place(top + left, dx: rail-width, rect(width: 1.5pt, height: 100%, fill: colors.accent))

    place(top + left, dx: 22.5pt, dy: 30pt, block(width: 135pt, {
      set text(font: fonts.body, size: 7.125pt, fill: colors.on-ink.transparentize(30%))
      show strong: set text(fill: colors.on-ink)

      if logo == auto and type(company) == str {
        block(
          width: 37.5pt, height: 37.5pt, radius: 9.75pt, fill: colors.accent,
          align(center + horizon, text(
            font: fonts.display, size: 19.5pt, weight: 700, fill: colors.ink, company.clusters().first(),
          )),
        )
        v(11.25pt)
      } else if logo not in (auto, none) {
        logo
        v(11.25pt)
      }
      text(font: fonts.display, size: 15.75pt, weight: 700, fill: colors.on-ink, tracking: 0.16pt, company)
      if tagline != none {
        v(4.5pt)
        caps(tagline, size: 6pt, tracking: 1.2pt, fill: colors.on-ink.transparentize(48%), weight: 400)
      }

      for section in rail {
        v(15.75pt)
        rail-rule
        v(15.75pt)
        caps(section.title, size: 6pt, tracking: 1.32pt, fill: colors.accent-soft)
        v(6.75pt)
        if "steps" in section { timeline(section.steps) }
        if "rows" in section {
          for (key, value) in section.rows { rail-row(key, value) }
        }
        if "body" in section {
          flow(lines(section.body), fill: colors.on-ink.transparentize(30%))
        }
        if "note" in section {
          v(3.75pt)
          flow(lines(section.note), size: 6.375pt, height: 1.6, fill: colors.on-ink.transparentize(55%))
        }
      }
    }))

    if rail-footer != none {
      place(bottom + left, dx: 22.5pt, dy: -19.5pt, block(width: 135pt, {
        rail-rule
        v(15pt)
        flow(
          lines(rail-footer), size: 6.375pt, height: 1.6,
          fill: colors.on-ink.transparentize(35%),
        )
      }))
    }
  }

  // The left margin reserves the rail, so the flow never runs under it.
  set document(title: [#labels.title #number])
  set page(
    paper: paper,
    margin: (top: 11.1mm, right: 11.1mm, bottom: 13mm, left: 73mm),
    fill: colors.canvas,
    background: rail-content,
    footer: {
      bar(0.75pt, colors.rule)
      v(7.5pt)
      set text(size: 6pt, tracking: 0.24pt, fill: colors.muted)
      grid(
        columns: (1fr, auto),
        footer,
        fig[#number · #labels.page #context counter(page).display() #labels.of #context counter(page).final().first()],
      )
    },
    footer-descent: 1.6pt,
  )
  set text(font: fonts.body, size: 7.875pt, fill: colors.ink, top-edge: "ascender", bottom-edge: "descender")
  set par(leading: (1.5 - body-box) * 7.875pt, spacing: 0pt)
  show strong: set text(fill: colors.ink)
  // Whole rows move to the next page together, never half a description.
  set table.cell(breakable: false)

  // ── Masthead ──────────────────────────────────────────────────────────────
  grid(
    columns: (1fr, auto), align: (left + top, right + top),
    {
      flow(
        labels.title, size: 35.25pt, height: 0.95, font: fonts.display, box: display-box,
        fill: colors.ink, weight: 700,
      )
      if subtitle != none {
        v(6.75pt)
        caps(subtitle, size: 6.75pt, tracking: 1.08pt)
      }
    },
    block(
      fill: colors.ink, radius: 3pt, inset: (x: 9pt, y: 4.5pt),
      fig(text(size: 7.875pt, weight: 700, tracking: 0.55pt, fill: colors.accent-soft, number)),
    ),
  )

  v(16.5pt)
  bar(1.5pt, colors.ink)
  block(width: 100%, inset: (y: 10.5pt), grid(
    columns: (auto,) * meta.len() + (1fr, auto),
    column-gutter: 16.5pt,
    align: horizon,
    ..meta.pairs().map(((key, value)) => {
      caps(key, size: 5.625pt, tracking: 1.2pt)
      v(3pt)
      fig(text(size: 7.875pt, weight: 700, value))
    }),
    [],
    if status != none {
      block(
        stroke: 1.125pt + colors.accent, radius: 2.25pt, inset: (x: 7.5pt, y: 4.125pt),
        caps(status, size: 6pt, tracking: 0.96pt, fill: colors.accent),
      )
    },
  ))
  bar(0.75pt, colors.rule)

  // ── Bill to ───────────────────────────────────────────────────────────────
  v(15pt)
  block(
    width: 100%, fill: colors.surface, inset: (left: 14.25pt, right: 12pt, y: 10.5pt),
    stroke: (left: 2.25pt + colors.accent),
    grid(
      columns: (1fr, auto), align: (left + bottom, right + bottom),
      {
        caps(labels.bill-to, size: 5.625pt, tracking: 1.2pt)
        v(4.5pt)
        text(font: fonts.display, size: 12pt, weight: 700, bill-to.name)
        if "role" in bill-to {
          v(1.5pt)
          text(size: 7.125pt, fill: colors.muted, bill-to.role)
        }
      },
      if "address" in bill-to {
        align(right, flow(lines(bill-to.address), size: 6.75pt, height: 1.65))
      },
    ),
  )

  // ── Line items ────────────────────────────────────────────────────────────
  v(15pt)
  table(
    columns: (1fr, 33.68pt, 57pt, 64.5pt),
    align: (left, right, right, right),
    inset: (x, y) => (
      left: if x == 0 { 9pt } else { 7.5pt },
      right: if x == 3 { 9pt } else { 7.5pt },
      top: if y == 0 { 6pt } else { 7.125pt },
      bottom: if y == 0 { 6pt } else { 7.875pt },
    ),
    stroke: (x, y) => if y == 0 { none } else { (bottom: 0.75pt + colors.rule) },
    fill: (x, y) => if y == 0 { colors.ink } else if calc.even(y) { colors.surface.transparentize(40%) },
    table.header(
      ..(labels.description, labels.quantity, labels.price, labels.amount)
        .map(label => caps(label, size: 5.625pt, tracking: 1.05pt, fill: colors.on-ink)),
    ),
    ..items.map(item => (
      {
        flow(item.description, size: 7.5pt, height: 1.35, fill: colors.ink, weight: 700)
        if item.at("detail", default: none) not in (none, "") {
          v(1.5pt)
          flow(item.detail, size: 6.375pt, height: 1.4)
        }
      },
      fig(str(item.quantity)),
      fig(text(fill: colors.muted, rate(item.price))),
      fig(text(weight: 700, amount(item.quantity * item.price))),
    )).flatten(),
  )

  // ── Total ─────────────────────────────────────────────────────────────────
  // Full width and unbreakable: a total split across pages is never right.
  v(9pt)
  block(width: 100%, fill: colors.ink, breakable: false, grid(
    columns: (177pt, 1fr),
    block(
      width: 100%, inset: (left: 13.5pt, right: 12pt, y: 11.25pt),
      stroke: (right: 0.75pt + colors.accent-soft.transparentize(70%)),
      {
        set text(size: 7.125pt, fill: colors.on-ink)
        let ladder-row(key, note, value) = grid(
          columns: (1fr, auto), inset: (y: 2.06pt), align: (left + top, right + top),
          {
            text(fill: colors.on-ink.transparentize(38%), key)
            if note != none {
              v(1.5pt)
              caps(note, size: 5.625pt, tracking: 0.75pt, fill: colors.on-ink.transparentize(60%), weight: 400)
            }
          },
          fig(value),
        )
        ladder-row(labels.subtotal, none, amount(subtotal))
        if credit != none { ladder-row(credit.label, credit.at("note", default: none), amount(-credit.amount)) }
        if tax != none { ladder-row(tax.label, none, amount(tax-amount)) }
      },
    ),
    block(width: 100%, inset: (left: 15pt, right: 13.5pt, y: 11.25pt), {
      caps(labels.total, size: 6pt, tracking: 1.44pt, fill: colors.accent-soft)
      v(3.75pt)
      flow(
        amount(total), size: 24.75pt, height: 1.05,
        font: fonts.display, box: display-box, fill: colors.accent-soft, weight: 700,
      )
      if due-note != none {
        v(3.75pt)
        text(size: 6.375pt, tracking: 0.32pt, fill: colors.on-ink.transparentize(40%), due-note)
      }
    }),
  ))

  // ── How to pay ────────────────────────────────────────────────────────────
  if payment.len() > 0 {
    v(18pt)
    caps(labels.payment, size: 6pt, tracking: 1.44pt)
    v(5.25pt)
    bar(1.125pt, colors.ink)
    v(8.25pt)
    grid(
      columns: (1fr,) * payment.len(),
      ..payment.enumerate().map(((index, cell)) => block(
        width: 100%,
        inset: (left: if index == 0 { 0pt } else { 11.25pt }, right: 10.5pt),
        stroke: if index == 0 { none } else { (left: 0.75pt + colors.rule) },
        breakable: false,
        {
          grid(
            columns: (auto, auto), column-gutter: 4.5pt, align: horizon,
            rect(width: 3.75pt, height: 3.75pt, fill: colors.accent),
            text(size: 7.125pt, weight: 700, cell.title),
          )
          v(4.5pt)
          fig(flow(lines(cell.body), size: 6.375pt, height: 1.95))
        },
      )),
    )
  }

  // ── Closing note ──────────────────────────────────────────────────────────
  if body != [] {
    v(11.25pt)
    flow(body, size: 6.375pt, height: 1.75)
  }
}
