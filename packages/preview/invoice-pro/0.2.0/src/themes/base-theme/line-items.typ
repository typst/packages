#let render-line-items(ctx, data, body) = {
  // --- Styling Variables ---
  let color-subtitle = luma(80)
  let color-desc = luma(100)

  let color-row-odd = rgb("e2e8f0")
  let color-discount = rgb("b22222")
  let color-surcharge = rgb("333333")
  let color-vat-label = rgb("475569")

  let size-subtitle = 0.85em
  let size-small = 0.85em
  let size-total = 1.2em

  let weight-bold = "bold"

  let stroke-thin = 0.5pt
  let stroke-regular = 1pt
  let stroke-thick = 2pt

  let cell-inset = (top: 0.125em, bottom: 0.125em)
  let totals-width = 66%
  let totals-row-gutter = 0.6em

  // --- Table Configuration & Flags ---
  let layout = data.layout-information
  let is-net = data.tax-mode == "exclusive"

  let cols = ()
  let headers = ()
  let aligns = ()

  let subtitle = text.with(
    size: size-subtitle,
    weight: weight-bold,
    fill: color-subtitle,
  )

  // --- Column & Header Setup ---
  set par(justify: false)

  if layout.show-pos {
    cols.push(auto)
    headers.push([*Pos*])
    aligns.push(center)
  }

  cols.push(1fr)
  headers.push([*Beschreibung*])
  aligns.push(left)

  if layout.show-quantity {
    cols.push(auto)
    headers.push([*Menge*])
    aligns.push(right)
  }

  if layout.show-unit-price {
    cols.push(auto)
    headers.push(align(
      center,
      if is-net [*Einzelpreis* \ #subtitle[(Netto)]] else [*Einzelpreis* \ #subtitle[(Brutto)]],
    ))
    aligns.push(right)
  }

  if layout.show-tax-rates {
    cols.push(auto)
    headers.push([*MwSt.*])
    aligns.push(right)
  }

  if layout.show-total-price {
    cols.push(auto)
    headers.push(align(
      center,
      if is-net [*Gesamt* \ #subtitle[(Netto)]] else [*Gesamt* \ #subtitle[(Brutto)]],
    ))
    aligns.push(right)
  }

  let colspan-left = if layout.show-pos { 1 } else { 0 }
  let colspan-right = (
    (if layout.show-tax-rates { 1 } else { 0 })
      + (if layout.show-total-price { 1 } else { 0 })
  )
  if colspan-right == 0 { colspan-right = 1 } // Fallback to prevent invalid span if both tax and total are hidden
  let colspan-mid = calc.max(1, cols.len() - colspan-left - colspan-right)

  let item-rows = ()

  // --- Item Rows Generation ---
  for (i, item) in data.items.enumerate() {
    let has-modifications = (
      (item.has-discounts or item.has-surcharge) and layout.show-modifier
    )

    let bg = if calc.odd(i) { color-row-odd } else { none }

    let cell = table.cell.with(fill: bg, stroke: none)

    let description-stack = stack(
      dir: ttb,
      spacing: 0.4em,
      text(weight: weight-bold, item.name),
      ..if item.has-description and layout.show-descriptions {
        (text(size: size-small, fill: color-desc, item.description),)
      } else { () },
      ..if item.has-date and layout.show-dates {
        (text(size: size-small, style: "italic", item.date),)
      } else { () },
    )

    if layout.show-pos {
      item-rows.push(cell(str(i + 1)))
    }

    item-rows.push(cell(description-stack))

    if layout.show-quantity {
      if layout.show-units {
        item-rows.push(cell([#item.quantity #item.unit]))
      } else {
        item-rows.push(cell([#item.quantity]))
      }
    }

    if layout.show-unit-price {
      item-rows.push(cell(item.price))
    }

    if layout.show-tax-rates {
      item-rows.push(cell([#item.tax.rate #item.tax.category]))
    }

    if layout.show-total-price {
      if has-modifications and item.keys().contains("unmodified-total") {
        item-rows.push(cell(str(item.unmodified-total)))
      } else {
        item-rows.push(cell(item.total))
      }
    }

    let cell-spacing = (inset: cell-inset, fill: bg)

    // --- Discount Handling ---
    if item.has-discounts and layout.show-modifier {
      for d in item.discounts {
        if layout.show-pos {
          item-rows.push(cell(..cell-spacing)[])
        }

        item-rows.push(cell(
          colspan: colspan-mid,
          align: left,
          ..cell-spacing,
        )[
          #text(size: size-small, fill: color-discount)[↳ Rabatt: #d.name]
        ])

        item-rows.push(cell(..cell-spacing, colspan: colspan-right)[
          #text(
            fill: color-discount,
          )[#if d.is-percent [(− #d.display) #h(.5em)]]
          #text(fill: color-discount)[− #d.absolute]
        ])
      }
    }

    // --- Surcharge Handling ---
    if item.has-surcharge and layout.show-modifier {
      for s in item.surcharge {
        if layout.show-pos {
          item-rows.push(cell(..cell-spacing)[])
        }

        item-rows.push(cell(
          colspan: colspan-mid,
          align: left,
          ..cell-spacing,
        )[
          #text(size: size-small, fill: color-surcharge)[↳ Zuschlag: #s.name]
        ])

        item-rows.push(cell(..cell-spacing, colspan: colspan-right)[
          #text(
            fill: color-surcharge,
          )[#if s.is-percent [(\+ #s.display) #h(.5em)]]
          #text(fill: color-surcharge)[\+ #s.absolute]
        ])
      }
    }

    // --- Subtotal per Item ---
    if has-modifications {
      if layout.show-pos {
        item-rows.push(cell[])
      }
      item-rows.push(cell(
        colspan: colspan-mid + (if layout.show-tax-rates { 1 } else { 0 }),
        align: left,
        fill: bg,
      )[
        #text(
          size: size-small,
          weight: weight-bold,
          fill: color-subtitle,
        )[Zwischensumme Pos. #str(i + 1):]
      ])

      if layout.show-total-price {
        item-rows.push(cell[#text(
          weight: weight-bold,
        )[#item.total]])
      } else if colspan-right == 1 and not layout.show-tax-rates {
        item-rows.push(cell[]) // Spacer if total price is hidden and forced fallback triggered
      }
    }
  }

  // --- Table Rendering ---
  table(
    columns: cols,
    stroke: none,
    align: (x, y) => aligns.at(x, default: right),

    table.header(
      repeat: true,
      table.hline(stroke: stroke-regular),
      ..headers,
      table.hline(stroke: stroke-thin),
    ),
    ..item-rows,
    table.hline(stroke: stroke-regular)
  )

  // --- Summary & Totals Box ---
  if layout.show-total {
    align(right)[
      #box(width: totals-width, {
        if data.tax-mode == "inclusive" {
          grid(
            columns: (1fr, auto),
            row-gutter: totals-row-gutter,
            column-gutter: 1em,
            align: (left, right),

            // Only show Brutto subtotal if there are actually modifiers
            ..if data.discounts.len() > 0 or data.surcharges.len() > 0 {
              (
                [Zwischensumme (Brutto):],
                data.unmodified-total.gross,
              )
            } else { () },

            ..data
              .discounts
              .map(d => (
                text(fill: color-discount, size-small)[Rabatt: #d.name],
                text(
                  fill: color-discount,
                )[#if d.is-percent [(− #d.display) #h(.5em)] − #d.absolute],
              ))
              .flatten(),

            ..data
              .surcharges
              .map(s => (
                text(fill: color-surcharge, size-small)[Zuschlag: #s.name],
                text(
                  fill: color-surcharge,
                )[#if s.is-percent [(\+ #s.display) #h(.5em)] \+ #s.absolute],
              ))
              .flatten(),

            grid.hline(stroke: stroke-thick),

            pad(top: 0.5em, text(
              weight: weight-bold,
              size: size-total,
            )[Bruttobetrag:]),
            pad(top: 0.5em, text(
              weight: weight-bold,
              size: size-total,
            )[#data.total.gross]),

            grid.hline(stroke: stroke-thick), [], [],

            ..data
              .taxes
              .map(t => (
                text(fill: color-vat-label)[inkl. MwSt. #t.rate (#t.category):],
                text(fill: black)[#t.amount],
              ))
              .flatten(),

            pad(y: -.5em)[], pad(y: -.5em)[],
            pad(bottom: 0.3em)[], pad(bottom: 0.3em)[],
          )
        } else {
          grid(
            columns: (1fr, auto),
            row-gutter: totals-row-gutter,
            column-gutter: 1em,
            align: (left, right),

            [Zwischensumme (Netto):], data.unmodified-total.net,

            ..data
              .discounts
              .map(d => (
                text(fill: color-discount, size-small)[Rabatt: #d.name],
                text(
                  fill: color-discount,
                )[#if d.is-percent [(− #d.display) #h(.5em)] − #d.absolute],
              ))
              .flatten(),

            ..data
              .surcharges
              .map(s => (
                text(fill: color-surcharge, size-small)[Zuschlag: #s.name],
                text(
                  fill: color-surcharge,
                )[#if s.is-percent [(+ #s.display) #h(.5em)] \+ #s.absolute],
              ))
              .flatten(),

            ..if data.discounts.len() > 0 or data.surcharges.len() > 0 {
              (
                text(weight: weight-bold)[Gesamt Netto:],
                text(weight: weight-bold)[#data.total.net],
              )
            } else { () },

            grid.hline(stroke: stroke-thin),

            pad(top: 0.3em)[], pad(top: 0.3em)[],

            ..data
              .taxes
              .map(t => (
                text(fill: color-vat-label)[zzgl. MwSt. #t.rate (#t.category):],
                text(fill: black)[#t.amount],
              ))
              .flatten(),

            pad(y: -.5em)[], pad(y: -.5em)[],
            pad(bottom: 0.3em)[], pad(bottom: 0.3em)[],

            grid.hline(stroke: stroke-thick),

            pad(y: 0.5em, text(
              weight: weight-bold,
              size: size-total,
            )[Bruttobetrag:]),
            pad(y: 0.5em, text(
              weight: weight-bold,
              size: size-total,
            )[#data.total.gross]),

            grid.hline(stroke: stroke-thick),
          )
        }
      })
    ]
  }

  // --- Global Information ---
  let global-infos = ()

  if (
    not layout.show-tax-rates
      and not layout.multiple-tax-rates
      and data.items.len() > 0
      and not data.tax-exempt-small-biz
  ) {
    let tax-rate = data.items.first(default: (tax: (rate: [0%]))).tax.rate
    let tax-text = if is-net { "zzgl." } else { "inkl." }
    global-infos.push(
      [Alle Positionen verstehen sich #tax-text #tax-rate MwSt.],
    )
  }

  if (
    not layout.show-units and not layout.multiple-units and data.items.len() > 0
  ) {
    let unit = data.items.first(default: (unit: none)).unit
    global-infos.push([Einheit aller Positionen: #unit])
  }

  if not layout.show-quantity and not layout.multiple-quantities {
    let quantity = data.items.first(default: (quantity: 0)).quantity
    global-infos.push([Menge aller Positionen: #quantity])
  }

  if (
    not layout.show-dates
      and layout.has-dates
      and not layout.multiple-dates
      and data.items.len() > 0
  ) {
    let date = data.items.first(default: (date: none)).date
    global-infos.push([Leistungsdatum aller Positionen: #date])
  }

  if data.tax-exempt-small-biz {
    global-infos.push([Gemäß § 19 UStG wird keine Umsatzsteuer berechnet.])
  }

  if layout.show-global-information and global-infos.len() > 0 {
    pad(
      top: 1em,
      text(
        size: size-small,
        fill: color-desc,
        global-infos.join([\ ]),
      ),
    )
  }

  body
}
