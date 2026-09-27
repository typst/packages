#import "../components/line-items/line-items.typ" as generic-line-items
#import "../components/line-items/totals.typ"

/// Default base theme line items
#let render-line-items(ctx, data, body) = {
  generic-line-items.render-line-items(
    ctx,
    data,
    body,
    color-subtitle: luma(80),
    color-desc: luma(100),
    color-row-odd: none,
    color-row-even: rgb("e2e8f0"),
    color-discount: rgb("b22222"),
    color-surcharge: rgb("333333"),
    color-vat-label: rgb("475569"),
    size-subtitle: 0.85em,
    size-small: 0.85em,
    size-total: 1.2em,
    weight-bold: "bold",
    stroke-thin: 0.5pt,
    stroke-regular: 1pt,
    stroke-thick: 2pt,
    cell-inset: .4em,
    item-inset: .3em,
    header-cell-inset: (x: .4em, y: .6em),
    totals-width: 66%,
    totals-row-gutter: 0.6em,
    tax-suffix-style: "newline",
    align-header: (center, left, right, center, center, center),
    align-body: (center, left, right, right, right, right),
  )
}

/// An elegant theme with a minimalist header
#let render-line-items-elegant(ctx, data, body) = {
  let elegant-label(content) = {
    set text(size: 0.75em, tracking: 0.2em, weight: "bold")
    upper(content)
  }

  generic-line-items.render-line-items(
    ctx,
    data,
    body,
    color-row-odd: none,
    stroke-header-top: 2pt + black,
    stroke-header-bottom: 0.5pt + black,
    stroke-table-bottom: 0.5pt + black,
    stroke-thin: 0.5pt + black,
    header-cell-inset: (y: 0.8em),
    cell-inset: (y: .4em),
    item-stroke: (bottom: .5pt + gray),
    item-inset: (y: .4em, x: .2em),
    totals-width: 50%,
    tax-suffix-style: (unit-price: none, total: "inline"),
    // Header Customization
    render-header: (ctx, content, styles) => {
      elegant-label(content)
    },
    // Totals Customization
    render-subtotal: (ctx, value, styles) => {
      let (label, val) = totals.default-render-subtotal(ctx, value, styles)
      (elegant-label(label), val)
    },
    render-total-net: (ctx, value, styles) => {
      let (label, val) = totals.default-render-total-net(ctx, value, styles)
      (elegant-label(label), val)
    },
    render-total-gross: (ctx, value, styles) => {
      let (label, val) = totals.default-render-total-gross(ctx, value, styles)
      (elegant-label(label), val)
    },
    render-discount: (ctx, discount, styles) => {
      (
        text(weight: "bold")[#discount.name],
        [#if discount.is-percent [(− #discount.display) #h(0.5em)] − #discount.absolute],
      )
    },
    render-surcharge: (ctx, surcharge, styles) => {
      (
        text(weight: "bold")[#surcharge.name],
        [#if surcharge.is-percent [(\+ #surcharge.display) #h(0.5em)] \+ #surcharge.absolute],
      )
    },
    totals-cell-wrapper: (_, content, _) => table.cell(content),
    render-totals-body: (ctx, data, styles, elements) => {
      let is-net = data.tax-mode == "exclusive"
      let has-modifiers = data.discounts.len() > 0 or data.surcharges.len() > 0

      // --- Section 1: Modifiers Table (Aligned with main table) ---
      if is-net or has-modifiers {
        let modifier-rows = ()

        // Transparent spacer to help align the first column with "Position"
        modifier-rows.push(table.cell(inset: (y: 0pt), block(
          height: 0pt,
          elegant-label(text(
            fill: black.transparentize(100%),
            ctx.locale.strings.line-items.position,
          )),
        )))
        modifier-rows.push(table.cell(inset: 0pt, []))
        modifier-rows.push(table.cell(inset: 0pt, []))

        // Add all modifiers
        for m in elements.modifiers {
          modifier-rows += (none, ..m)
        }

        table(
          columns: (auto, 1fr, auto),
          align: (center, left, right),
          stroke: none,
          ..modifier-rows,
          table.hline(stroke: styles.stroke-thick),
          table.cell(colspan: 3, inset: 0pt, []),
          // null row
        )
      }

      // --- Section 2: Summary Box (Right aligned, narrower) ---
      let summary-rows = ()
      let null-row = table.cell(colspan: 2, inset: 0pt, [])
      let spacer(height) = table.cell(colspan: 2, inset: 0pt, v(height))

      if is-net {
        if has-modifiers {
          summary-rows += elements.net-total
        }
        summary-rows += (
          spacer(0.1em),
          table.hline(stroke: styles.stroke-thin),
          null-row,
          ..elements.taxes.flatten(),
        )
      }

      summary-rows += (
        table.hline(stroke: styles.stroke-thick),
        null-row,
        spacer(0.2em),
        ..elements.grand-total,
        spacer(0.2em),
        table.hline(stroke: styles.stroke-thin),
        null-row,
        spacer(2pt),
        table.hline(stroke: styles.stroke-thin),
        null-row,
      )

      if not is-net {
        summary-rows += (
          spacer(0.5em),
          ..elements.taxes.flatten(),
        )
      }

      v(-1em)
      align(right)[
        #box(width: styles.totals-width)[
          #table(
            columns: (1fr, auto),
            column-gutter: styles.totals-col-gutter,
            stroke: none,
            align: (left + horizon, right + horizon),
            ..summary-rows,
          )
        ]
      ]
    },
  )
}

/// A modern vibrant theme with rounded header buttons
#let render-line-items-vibrant(ctx, data, body) = {
  let accent = rgb("#ec4899") // Pink

  generic-line-items.render-line-items(
    ctx,
    data,
    body,
    color-row-odd: accent.lighten(95%),
    stroke-header-top: none,
    stroke-header-bottom: none,
    stroke-table-bottom: 2pt + accent,
    tax-suffix-style: "none",
    item-inset: (y: .4em),
    cell-inset: .4em,
    align-header: (center, center, center, center, center),
    // Header
    render-header: (ctx, content, styles) => {
      align(center + horizon)[
        #place(block(
          width: 100%,
          height: 100%,
          fill: accent,
          radius: 1em,
          outset: (x: -.2em),
        ))
        #pad(x: 2em, y: .75em, text(
          fill: white,
          weight: "bold",
          size: 0.8em,
          content,
        ))
      ]
    },
  )
}

/// A luxury theme with custom styling
#let render-line-items-luxury(ctx, data, body) = {
  let gold = rgb("#b8860b")

  generic-line-items.render-line-items(
    ctx,
    data,
    body,
    color-subtitle: gold,
    color-discount: red.darken(20%),
    color-surcharge: blue.darken(20%),
    weight-bold: "bold",
    stroke-regular: 2pt + black,
    stroke-thin: 1pt + gold,
    cell-inset: (top: 0.5em, bottom: 0.5em),
  )
}

/// An informational theme
#let render-line-items-informational(ctx, data, body) = {
  generic-line-items.render-line-items(
    ctx,
    data,
    body,
    stroke-table-bottom: none,
    tax-suffix-style: (unit-price: "none", total: "accent"),
    color-subtitle: rgb("#2563eb"),
    render-table-footer: (ctx, total-cols, styles) => {
      (
        table.footer(
          repeat: false,
          table.cell(
            colspan: total-cols,
            stroke: (top: 1pt + black),
            inset: (top: 1.5em, bottom: 1em),
          )[
            #set text(size: 0.8em, fill: luma(100))
            *Final Note:* Thank you for your business. Please ensure payment is made within 14 days to the bank details below.
          ],
        ),
      )
    },
  )
}
