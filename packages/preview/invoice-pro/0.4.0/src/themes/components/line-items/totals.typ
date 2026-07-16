#import "../../../utils/types.typ"

// --- Styling Callbacks (Return (content, content)) ---

#let default-render-subtotal(ctx, value, styles) = {
  let strings = ctx.locale.strings
  let label = if ctx.tax-mode == "exclusive" {
    [#strings.summary.sum (#strings.line-items.net):]
  } else {
    [#strings.summary.sum (#strings.line-items.gross):]
  }
  (label, value)
}

#let default-render-total-net(ctx, value, styles) = {
  let strings = ctx.locale.strings
  (
    text(
      weight: styles.weight-bold,
    )[#strings.line-items.total #strings.line-items.net:],
    text(weight: styles.weight-bold)[#value],
  )
}

#let default-render-total-gross(ctx, value, styles) = {
  let strings = ctx.locale.strings
  (
    text(
      weight: styles.weight-bold,
      size: styles.size-total,
    )[#strings.summary.total:],
    text(
      weight: styles.weight-bold,
      size: styles.size-total,
    )[#value],
  )
}

#let default-render-discount(ctx, discount, styles) = {
  let strings = ctx.locale.strings
  (
    text(
      fill: styles.color-discount,
      size: styles.size-small,
    )[#strings.line-items.discount: #discount.name],
    text(
      fill: styles.color-discount,
    )[#if discount.is-percent [(− #discount.display) #h(0.5em)] − #discount.absolute],
  )
}

#let default-render-surcharge(ctx, surcharge, styles) = {
  let strings = ctx.locale.strings
  (
    text(
      fill: styles.color-surcharge,
      size: styles.size-small,
    )[#strings.line-items.surcharge: #surcharge.name],
    text(
      fill: styles.color-surcharge,
    )[#if surcharge.is-percent [(\+ #surcharge.display) #h(0.5em)] \+ #surcharge.absolute],
  )
}

#let default-render-tax(ctx, tax, styles) = {
  let strings = ctx.locale.strings
  let prefix = if ctx.tax-mode == "exclusive" {
    strings.summary.excluding
  } else {
    strings.summary.including
  }
  (
    text(
      fill: styles.color-vat-label,
    )[#prefix #strings.summary.vat-tax #tax.rate (#tax.category):],
    text(fill: black)[#tax.amount],
  )
}

// --- Structural Callbacks ---

/// Wrapper applied to every output of the styling functions
#let totals-cell-wrapper(ctx, content, styles) = {
  // Should wrap the raw content (label or value) in a container like table.cell.
  // This is the point where theme-specific cell styling (inset, fill, etc.) is applied.
  grid.cell(content)
}

/// Assembles the wrapped elements into the final content
#let default-render-totals-body(ctx, data, styles, elements) = {
  let is-net = data.tax-mode == "exclusive"
  let has-modifiers = data.discounts.len() > 0 or data.surcharges.len() > 0

  let null-row = grid.cell(colspan: 2, inset: 0pt, none)
  let grid-spacer(height) = grid.cell(colspan: 2, inset: 0pt, v(height))

  let rows = ()

  rows += if not is-net {
    (
      // --- Inclusive Mode ---
      ..if has-modifiers { elements.subtotal },
      elements.modifiers,
      grid.hline(stroke: styles.stroke-thick),
      null-row,
      elements.grand-total,
      grid.hline(stroke: styles.stroke-thick),
      null-row,
      elements.taxes,
    )
  } else {
    (
      // --- Exclusive Mode ---
      elements.subtotal,
      elements.modifiers,
      ..if has-modifiers { elements.net-total },
      grid.hline(stroke: styles.stroke-thin),
      null-row,
      elements.taxes,
      grid.hline(stroke: styles.stroke-thick),
      null-row,
      elements.grand-total,
      grid.hline(stroke: styles.stroke-thick),
      null-row,
    )
  }

  v(.5em)

  align(styles.totals-align)[
    #box(width: styles.totals-width)[
      #grid(
        columns: (1fr, auto),
        row-gutter: styles.totals-row-gutter,
        column-gutter: styles.totals-col-gutter,
        align: (left, right),
        ..rows.flatten(),
      )
    ]
  ]
}

// --- Main Component ---

#let render-totals(
  ctx,
  data,
  // Stylers
  render-subtotal: auto,
  render-total-net: auto,
  render-total-gross: auto,
  render-discount: auto,
  render-surcharge: auto,
  render-tax: auto,
  // Wrapper & Builder
  totals-cell-wrapper: auto,
  render-totals-body: auto,
  // Standard styling parameters
  color-discount: rgb("b22222"),
  color-surcharge: rgb("333333"),
  color-vat-label: rgb("475569"),
  size-small: 0.85em,
  size-total: 1.2em,
  weight-bold: "bold",
  stroke-thin: 0.5pt,
  stroke-thick: 2pt,
  totals-width: 66%,
  totals-row-gutter: 0.6em,
  totals-col-gutter: 1em,
  totals-align: right,
) = {
  let styles = (
    color-discount: color-discount,
    color-surcharge: color-surcharge,
    color-vat-label: color-vat-label,
    size-small: size-small,
    size-total: size-total,
    weight-bold: weight-bold,
    stroke-thin: stroke-thin,
    stroke-thick: stroke-thick,
    totals-width: totals-width,
    totals-row-gutter: totals-row-gutter,
    totals-col-gutter: totals-col-gutter,
    totals-align: totals-align,
  )

  // Resolve Callbacks
  let r-subtotal = if render-subtotal == auto or render-subtotal == none {
    default-render-subtotal
  } else {
    render-subtotal
  }
  let r-total-net = if render-total-net == auto or render-total-net == none {
    default-render-total-net
  } else {
    render-total-net
  }
  let r-total-gross = if (
    render-total-gross == auto or render-total-gross == none
  ) {
    default-render-total-gross
  } else {
    render-total-gross
  }
  let r-discount = if render-discount == auto or render-discount == none {
    default-render-discount
  } else {
    render-discount
  }
  let r-surcharge = if render-surcharge == auto or render-surcharge == none {
    default-render-surcharge
  } else {
    render-surcharge
  }
  let r-tax = if render-tax == auto or render-tax == none {
    default-render-tax
  } else {
    render-tax
  }
  let w-cell = if totals-cell-wrapper == auto or totals-cell-wrapper == none {
    content => grid.cell(content)
  } else {
    content => totals-cell-wrapper(ctx, content, styles)
  }
  let b-render = if render-totals-body == auto or render-totals-body == none {
    default-render-totals-body
  } else {
    render-totals-body
  }

  let wrap-pair(pair) = pair.map(w-cell)

  // Gather Elements
  let elements = (:)

  // Subtotal
  let sub-val = if data.tax-mode == "exclusive" {
    data.unmodified-total.net
  } else {
    data.unmodified-total.gross
  }
  elements.subtotal = wrap-pair(r-subtotal(ctx, sub-val, styles))

  // Modifiers
  elements.modifiers = ()
  for d in data.discounts {
    elements.modifiers.push(wrap-pair(r-discount(ctx, d, styles)))
  }
  for s in data.surcharges {
    elements.modifiers.push(wrap-pair(r-surcharge(ctx, s, styles)))
  }

  // Net Total (for exclusive)
  if data.tax-mode == "exclusive" {
    elements.net-total = wrap-pair(r-total-net(ctx, data.total.net, styles))
  }

  // Taxes
  elements.taxes = ()
  for t in data.taxes {
    elements.taxes.push(wrap-pair(r-tax(ctx, t, styles)))
  }

  // Grand Total
  elements.grand-total = wrap-pair(r-total-gross(ctx, data.total.gross, styles))

  b-render(ctx, data, styles, elements)
}
