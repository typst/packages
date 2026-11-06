#import "../../../utils/types.typ"
#import "columns.typ": get-column-metadata

// --- Default Renderers (Content Only) ---

#let default-render-title(
  ctx,
  item,
  layout,
  styles,
) = {
  stack(
    dir: ttb,
    spacing: 0.4em,
    text(
      weight: styles.weight-bold,
      item.name,
    ),
    ..if item.has-date and layout.show-dates {
      (
        text(
          size: styles.size-small,
          style: "italic",
          item.date,
        ),
      )
    } else { () },
  )
}

#let default-render-description(
  ctx,
  item,
  layout,
  styles,
) = {
  set par(leading: 0.35em)
  set text(size: styles.size-small, fill: styles.color-desc)
  item.description
}

#let default-render-modifier(
  ctx,
  mod,
  styles,
  is-discount: true,
) = {
  let color = if is-discount { styles.color-discount } else {
    styles.color-surcharge
  }
  let sign = if is-discount { "−" } else { "+" }

  let label-val = mod.at("label", default: auto)
  let resolved-label = if label-val == auto {
    let strings = ctx.locale.strings.line-items
    if is-discount { strings.discount } else { strings.surcharge }
  } else {
    label-val
  }

  let label-text = if resolved-label != none {
    if mod.name != none and mod.name != "" and mod.name != [] {
      [↳ #resolved-label: #mod.name]
    } else {
      [↳ #resolved-label]
    }
  } else {
    [↳ #mod.name]
  }

  (
    label: text(
      size: styles.size-small,
      fill: color,
    )[#label-text],
    percent: if mod.is-percent {
      text(fill: color)[(#sign #mod.display)]
    } else { [] },
    absolute: text(fill: color)[#sign #mod.absolute],
  )
}

#let default-render-header(ctx, content, styles) = {
  set text(fill: styles.header-color)
  content
}

#let default-render-tax-suffix(ctx, is-net, styles, style-type) = {
  let strings = ctx.locale.strings.line-items
  let label = if is-net { strings.net } else { strings.gross }
  let fill-color = styles.color-subtitle

  if style-type == "newline" {
    align(
      center,
      block(spacing: 0.2em, text(
        size: 0.8em,
        weight: "regular",
        fill: fill-color,
        [(#label)],
      )),
    )
  } else if style-type == "inline" {
    text(size: 0.8em, weight: "regular", fill: fill-color)[(#label)]
  } else if style-type == "accent" {
    text(size: 0.7em, weight: "bold", fill: fill-color.lighten(20%))[#upper(
      label,
    )]
  } else { none }
}

// --- Logic Helpers ---

#let compute-description-colspan(
  total-cols,
  desc-idx,
  active-cols-keys,
  colspan-spec,
) = {
  if type(colspan-spec) == int {
    if colspan-spec > 0 { return colspan-spec }
    return calc.max(1, total-cols - desc-idx + colspan-spec)
  } else if type(colspan-spec) == array {
    let count = 1
    for key in active-cols-keys {
      if key in colspan-spec { count += 1 } else { break }
    }
    return count
  }
  return 1
}

// --- Main Function ---

#let render-table(
  ctx,
  data,
  // Content styling
  color-subtitle: luma(80),
  color-desc: luma(100),
  color-discount: rgb("b22222"),
  color-surcharge: rgb("333333"),
  size-subtitle: 0.85em,
  size-small: 0.85em,
  weight-bold: "bold",
  // Table styling
  color-row-odd: rgb("e2e8f0"),
  color-row-even: none,
  stroke-thin: 0.5pt,
  stroke-regular: 1pt,
  // Spacing & Border
  item-inset: (y: 0.25em),
  item-stroke: none,
  cell-inset: (x: 0.4em),
  // Header styling
  header-bg: none,
  header-color: black,
  header-repeat: true,
  stroke-header-top: auto,
  stroke-header-bottom: auto,
  stroke-table-bottom: auto,
  header-cell-inset: (top: 0.5em, bottom: 0.5em),
  // Config
  column-order: ("quantity", "unit-price", "tax-rate", "total-price"),
  description-colspan: auto,
  tax-suffix-style: "newline",
  align-header: auto,
  align-body: auto,
  // Callbacks
  render-title: auto,
  render-description: auto,
  render-modifier: auto,
  render-header: auto,
  render-table-footer: auto,
  render-tax-suffix: auto,
) = {
  let resolve-align(spec, key, idx, default) = {
    if spec == auto {
      default
    } else if type(spec) == dictionary {
      spec.at(key, default: default)
    } else if type(spec) == array {
      if idx < spec.len() {
        spec.at(idx)
      } else {
        default
      }
    } else if type(spec) == function {
      spec(key)
    } else {
      spec
    }
  }

  let get-default-align(key) = {
    if key == "pos" { center } else if key == "description" { left } else {
      right
    }
  }

  let layout = data.layout-information
  let is-net = data.tax-mode == "exclusive"
  let li-str = ctx.locale.strings.line-items
  let null-dir = (left: 0pt, right: 0pt, top: 0pt, bottom: 0pt)

  // Input Normalization
  let normalize-directional(value) = if type(value) == dictionary {
    (
      left: value.at("left", default: value.at("x", default: 0pt)),
      right: value.at("right", default: value.at("x", default: 0pt)),
      top: value.at("top", default: value.at("y", default: 0pt)),
      bottom: value.at("bottom", default: value.at("y", default: 0pt)),
    )
  } else { (left: value, right: value, top: value, bottom: value) }

  let resolve-auto(value, fallback) = if value == auto { fallback } else {
    value
  }

  let normalized-cell-inset = normalize-directional(cell-inset)
  let normalized-header-cell-inset = normalize-directional(header-cell-inset)
  let normalized-item-inset = normalize-directional(item-inset)
  let normalized-item-stroke = normalize-directional(item-stroke)

  let styles = (
    color-subtitle: color-subtitle,
    color-desc: color-desc,
    color-discount: color-discount,
    color-surcharge: color-surcharge,
    color-row-odd: color-row-odd,
    color-row-even: color-row-even,

    size-subtitle: size-subtitle,
    size-small: size-small,
    weight-bold: weight-bold,

    header-bg: header-bg,
    header-color: header-color,
    header-repeat: header-repeat,
    stroke-header-top: resolve-auto(stroke-header-top, stroke-regular),
    stroke-header-bottom: resolve-auto(stroke-header-bottom, stroke-thin),
    stroke-table-bottom: resolve-auto(stroke-table-bottom, stroke-regular),

    item-inset: normalized-item-inset,
    item-stroke: normalized-item-stroke,
    cell-inset: normalized-cell-inset,
    header-cell-inset: normalized-header-cell-inset,
  )

  set par(justify: false)

  // Pre-resolve callbacks
  let do-render-title = resolve-auto(render-title, default-render-title)
  let do-render-desc = resolve-auto(
    render-description,
    default-render-description,
  )
  let do-render-header = resolve-auto(render-header, default-render-header)
  let do-render-modifier = resolve-auto(
    render-modifier,
    default-render-modifier,
  )

  let get-suffix(key) = {
    if render-tax-suffix != auto {
      return render-tax-suffix(ctx, is-net, styles, key)
    }
    let s-type = if type(tax-suffix-style) == str { tax-suffix-style } else if (
      type(tax-suffix-style) == dictionary
    ) {
      tax-suffix-style.at(key, default: "newline")
    } else if tax-suffix-style == none { none } else { "newline" }
    default-render-tax-suffix(ctx, is-net, styles, s-type)
  }

  // Column Setup
  let meta = get-column-metadata(data, column-order)
  let (
    cols,
    active-keys: active-cols-keys,
    total-count: total-cols,
    left-count: colspan-left,
    desc-idx,
    total-idx: abs-total-idx,
    percent-idx: abs-percent-idx,
  ) = meta

  let indices = (
    left: colspan-left,
    desc: desc-idx,
    total: abs-total-idx,
    percent: abs-percent-idx,
    total-count: total-cols,
  )

  let content-keys = ()
  if layout.show-pos {
    content-keys.push("pos")
  }
  content-keys.push("description")
  for key in active-cols-keys {
    content-keys.push(key)
  }

  // Header Construction
  let header-contents = (:)
  if layout.show-pos {
    header-contents.insert("pos", [*#li-str.position*])
  }
  header-contents.insert("description", [*#li-str.description*])

  let available-header-cols = (
    "quantity": [*#li-str.quantity*],
    "unit-price": block[*#li-str.unit-price*#get-suffix("unit-price")],
    "tax-rate": [*#li-str.vat*],
    "total-price": block[*#li-str.total*#get-suffix("total")],
  )
  for key in active-cols-keys {
    header-contents.insert(key, available-header-cols.at(key))
  }

  let empty-cell = table.cell.with(inset: 0pt, none)

  let table-header-cells = (
    (empty-cell(),)
      + content-keys.map(key => {
        let default-align = get-default-align(key)
        let idx = content-keys.position(k => k == key)
        let cell-align = resolve-align(align-header, key, idx, default-align)
        table.cell(
          fill: styles.header-bg,
          inset: styles.header-cell-inset,
          align: cell-align,
        )[#do-render-header(ctx, header-contents.at(key), styles)]
      })
      + (empty-cell(),)
  )

  let table-header = table.header(
    repeat: styles.header-repeat,
    table.cell(colspan: total-cols + 2, inset: 0pt, none),
    table.hline(stroke: styles.stroke-header-top),
    table.cell(colspan: total-cols + 2, inset: 0pt, none),
    ..table-header-cells,
    table.cell(colspan: total-cols + 2, inset: 0pt, none),
    table.hline(stroke: styles.stroke-header-bottom),
    table.cell(colspan: total-cols + 2, inset: 0pt, none),
  )

  let table-footer = if render-table-footer != auto {
    render-table-footer(ctx, total-cols, styles)
  } else { () }

  let abs-description-colspan = compute-description-colspan(
    total-cols,
    desc-idx,
    active-cols-keys,
    description-colspan,
  )

  // Frames the rows of one entry (item, group header or group footer) with
  // the item inset and stroke: a cap row above and below, and on either side
  // a spacer cell spanning all of the entry's rows. Unbreakable spacers keep
  // those rows on one page, so a description or modifier is never carried
  // over to the next page without its title.
  let frame-rows(
    body-rows,
    fill: none,
    extra-top: 0pt,
    extra-bottom: 0pt,
    breakable: false,
  ) = {
    let item-inset = styles.item-inset
    let item-stroke = styles.item-stroke

    let spacer(side) = table.cell(
      rowspan: body-rows.len() + 2,
      breakable: breakable,
      fill: fill,
      inset: null-dir + ((side): item-inset.at(side)),
      stroke: (
        (side): item-stroke.at(side),
        top: item-stroke.top,
        bottom: item-stroke.bottom,
      ),
      none,
    )

    (
      spacer("left"),
      table.cell(
        colspan: total-cols,
        fill: fill,
        inset: null-dir + (top: item-inset.top + extra-top),
        stroke: (top: item-stroke.top),
        none,
      ),
      spacer("right"),
      ..body-rows.flatten(),
      table.cell(
        colspan: total-cols,
        fill: fill,
        inset: null-dir + (bottom: item-inset.bottom + extra-bottom),
        stroke: (bottom: item-stroke.bottom),
        none,
      ),
      empty-cell(colspan: total-cols + 2),
    )
  }

  // Recursive Item Builder
  let build-item-rows(
    item,
    index,
    is-odd: auto,
    is-sub-item: false,
    breakable: false,
  ) = {
    let resolved-odd = if is-odd != auto {
      is-odd
    } else if type(index) == int {
      calc.odd(index)
    } else {
      true
    }
    let bg = if resolved-odd {
      styles.color-row-odd
    } else {
      styles.color-row-even
    }

    let cell-inset = styles.cell-inset

    // Centralized cell generator for internal row elements
    let line-cell = table.cell.with(
      colspan: 1,
      align: auto,
      fill: bg,
      inset: cell-inset,
      stroke: none,
    )

    let has-mods = (
      (
        item.at("has-discounts", default: false)
          or item.at("has-surcharge", default: false)
      )
        and layout.show-modifier
    )

    let has-description = (
      item.at("has-description", default: false) and layout.show-descriptions
    )

    // Content cells of each row; the caps and side spacers are added by
    // `frame-rows`.
    let rows = ()

    // --- SECTION: MAIN ITEM ROW ---
    let main-row = ()

    let col-tracker = 0
    if layout.show-pos {
      let default-align = get-default-align("pos")
      let idx = content-keys.position(k => k == "pos")
      let cell-align = resolve-align(align-body, "pos", idx, default-align)
      main-row.push(line-cell(
        [#index],
        align: cell-align,
      ))
      col-tracker += 1
    }

    let default-desc-align = get-default-align("description")
    let desc-idx = content-keys.position(k => k == "description")
    let desc-cell-align = resolve-align(
      align-body,
      "description",
      desc-idx,
      default-desc-align,
    )
    main-row.push(line-cell(
      do-render-title(ctx, item, layout, styles),
      inset: cell-inset,
      align: desc-cell-align,
    ))
    col-tracker += 1

    for key in active-cols-keys {
      let content = if key == "quantity" {
        if layout.show-units {
          let unit-disp = if type(item.unit) == dictionary {
            item.unit.at("display", default: item.unit.at(
              "name",
              default: none,
            ))
          } else {
            item.unit
          }
          if unit-disp != none {
            [#item.quantity #unit-disp]
          } else {
            [#item.quantity]
          }
        } else {
          [#item.quantity]
        }
      } else if key == "unit-price" { item.price } else if key == "tax-rate" {
        // The marker of the item's own exemption ground, if its category
        // has items exempt for different reasons.
        let marker = item.tax.at("marker", default: none)
        [#item.tax.rate #item.tax.category#if marker != none { super[#marker] }]
      } else if key == "total-price" {
        if has-mods and "unmodified-total" in item {
          item.unmodified-total
        } else { item.total }
      }
      let default-align = get-default-align(key)
      let idx = content-keys.position(k => k == key)
      let cell-align = resolve-align(align-body, key, idx, default-align)
      main-row.push(line-cell(content, align: cell-align))
      col-tracker += 1
    }

    rows.push(main-row)

    // --- SECTION: DESCRIPTION ROW ---
    if has-description {
      let desc-row = ()
      let d-col-tracker = 0

      if layout.show-pos {
        desc-row.push(line-cell(inset: 0pt, none))
        d-col-tracker += 1
      }
      d-col-tracker += abs-description-colspan

      let default-desc-align = get-default-align("description")
      let desc-idx = content-keys.position(k => k == "description")
      let desc-cell-align = resolve-align(
        align-body,
        "description",
        desc-idx,
        default-desc-align,
      )

      desc-row.push(line-cell(
        do-render-desc(ctx, item, layout, styles),
        colspan: abs-description-colspan,
        inset: cell-inset + (top: 0pt),
        align: desc-cell-align,
      ))

      let remaining = total-cols - desc-idx - abs-description-colspan
      if remaining > 0 {
        desc-row.push(line-cell(
          none,
          colspan: remaining,
        ))
      }

      rows.push(desc-row)
    }

    // --- SECTION: MODIFIER ROWS ---
    let build-modifier-row(mod, is-discount) = {
      let m-row = ()
      let m-col-tracker = 0

      if layout.show-pos {
        m-row.push(line-cell(none, inset: 0pt))
        m-col-tracker += 1
      }

      let mod-content = do-render-modifier(
        ctx,
        mod,
        styles,
        is-discount: is-discount,
      )

      let default-desc-align = get-default-align("description")
      let desc-idx = content-keys.position(k => k == "description")
      let desc-cell-align = resolve-align(
        align-body,
        "description",
        desc-idx,
        default-desc-align,
      )

      let default-total-align = get-default-align("total-price")
      let total-idx = content-keys.position(k => k == "total-price")
      let total-cell-align = resolve-align(
        align-body,
        "total-price",
        total-idx,
        default-total-align,
      )

      if indices.percent != none {
        let span1 = indices.percent - indices.desc
        m-row.push(line-cell(
          mod-content.label,
          inset: cell-inset + (top: 0pt),
          colspan: span1,
          align: desc-cell-align,
        ))
        m-col-tracker += span1

        m-row.push(line-cell(
          mod-content.percent,
          inset: cell-inset + (top: 0pt),
          align: total-cell-align,
        ))
        m-col-tracker += 1

        m-row.push(line-cell(
          mod-content.absolute,
          inset: cell-inset + (top: 0pt),
          align: total-cell-align,
        ))
        m-col-tracker += 1
      } else {
        let span1 = indices.total - indices.desc
        m-row.push(line-cell(
          mod-content.label,
          inset: cell-inset + (top: 0pt),
          colspan: span1,
          align: desc-cell-align,
        ))
        m-col-tracker += span1

        m-row.push(line-cell(
          [#mod-content.percent #mod-content.absolute],
          inset: cell-inset + (top: 0pt),
          align: total-cell-align,
        ))
        m-col-tracker += 1
      }
      let remaining = indices.total-count - m-col-tracker
      if remaining > 0 {
        m-row.push(line-cell(colspan: remaining, inset: 0pt))
      }

      return m-row
    }

    if has-mods {
      if item.at("has-discounts", default: false) {
        for discount in item.discounts {
          rows.push(build-modifier-row(discount, true))
        }
      }

      if item.at("has-surcharge", default: false) {
        for surcharge in item.surcharge {
          rows.push(build-modifier-row(surcharge, false))
        }
      }

      // --- SECTION: SUBTOTAL ROW ---
      let sub-row = ()
      let sub-col-tracker = 0

      if layout.show-pos {
        sub-row.push(line-cell(inset: 0pt, none))
        sub-col-tracker += 1
      }

      let default-desc-align = get-default-align("description")
      let desc-idx = content-keys.position(k => k == "description")
      let desc-cell-align = resolve-align(
        align-body,
        "description",
        desc-idx,
        default-desc-align,
      )

      let default-total-align = get-default-align("total-price")
      let total-idx = content-keys.position(k => k == "total-price")
      let total-cell-align = resolve-align(
        align-body,
        "total-price",
        total-idx,
        default-total-align,
      )

      // Label (aligned with description)
      let span1 = indices.total - indices.desc
      sub-row.push(line-cell(
        text(
          weight: styles.weight-bold,
          size: styles.size-subtitle,
        )[#li-str.subtotal],
        colspan: span1,
        align: desc-cell-align,
      ))
      sub-col-tracker += span1

      // Total Value
      sub-row.push(line-cell(
        text(weight: styles.weight-bold)[#item.total],
        align: total-cell-align,
      ))
      sub-col-tracker += 1

      // Fill remaining
      let remaining = total-cols - sub-col-tracker
      if remaining > 0 {
        sub-row.push(line-cell(
          none,
          inset: 0pt,
          colspan: remaining,
        ))
      }
      rows.push(sub-row)
    }

    frame-rows(rows, fill: bg, breakable: breakable)
  }

  let build-group-header-rows(group, breakable: false) = {
    let row = ()
    let cell-inset = styles.cell-inset

    let line-cell = table.cell.with(
      colspan: 1,
      align: auto,
      fill: none,
      inset: cell-inset,
      stroke: none,
    )

    let remaining-cols = total-cols
    if layout.show-pos {
      let default-align = get-default-align("pos")
      let idx = content-keys.position(k => k == "pos")
      let cell-align = resolve-align(align-body, "pos", idx, default-align)
      row.push(line-cell(
        text(weight: styles.weight-bold)[#group.pos],
        align: cell-align,
      ))
      remaining-cols -= 1
    }

    let default-desc-align = get-default-align("description")
    let desc-idx = content-keys.position(k => k == "description")
    let desc-cell-align = resolve-align(
      align-body,
      "description",
      desc-idx,
      default-desc-align,
    )

    row.push(line-cell(
      colspan: remaining-cols,
      align: desc-cell-align,
      inset: cell-inset,
      stack(
        dir: ttb,
        spacing: 0.35em,
        text(
          weight: styles.weight-bold,
          size: 1.05em,
          group.name,
        ),
        ..if group.has-description {
          (
            text(
              size: styles.size-small,
              fill: styles.color-desc,
              group.description,
            ),
          )
        } else { () },
      ),
    ))

    frame-rows((row,), extra-top: 0.4em, breakable: breakable)
  }

  let build-group-footer-rows(group, breakable: false) = {
    let row = ()
    let cell-inset = styles.cell-inset

    let line-cell = table.cell.with(
      colspan: 1,
      align: auto,
      fill: none,
      inset: cell-inset,
      stroke: none,
    )

    let sub-col-tracker = 0

    if layout.show-pos {
      row.push(line-cell(inset: 0pt, none))
      sub-col-tracker += 1
    }

    let default-desc-align = get-default-align("description")
    let desc-idx = content-keys.position(k => k == "description")
    let desc-cell-align = resolve-align(
      align-body,
      "description",
      desc-idx,
      default-desc-align,
    )

    let default-total-align = get-default-align("total-price")
    let total-idx = content-keys.position(k => k == "total-price")
    let total-cell-align = resolve-align(
      align-body,
      "total-price",
      total-idx,
      default-total-align,
    )

    let span1 = indices.total - indices.desc
    row.push(line-cell(
      text(
        weight: styles.weight-bold,
        size: styles.size-subtitle,
      )[#li-str.subtotal #group.name],
      colspan: span1,
      align: desc-cell-align,
      inset: cell-inset,
    ))
    sub-col-tracker += span1

    row.push(line-cell(
      text(weight: styles.weight-bold)[#group.subtotal],
      align: total-cell-align,
      inset: cell-inset,
    ))
    sub-col-tracker += 1

    let remaining = total-cols - sub-col-tracker
    if remaining > 0 {
      row.push(line-cell(
        none,
        inset: 0pt,
        colspan: remaining,
      ))
    }

    frame-rows((row,), extra-bottom: 0.2em, breakable: breakable)
  }

  let table-columns = (auto,) + cols + (auto,)
  let entries = data.at("entries", default: data.items)

  // `layout` is shadowed by the layout information above.
  std.layout(size => {
    // An entry kept on one page but taller than a page (next to the
    // repeated header and footer) would overflow it, so such an entry
    // falls back to rows that may break across pages.
    let keep-together(build-rows) = {
      let rows = build-rows(false)
      let height(..header-footer) = {
        measure(
          width: size.width,
          table(
            columns: table-columns,
            stroke: none,
            ..header-footer,
            ..rows,
          ),
        ).height
      }
      // Measuring the header as well makes Typst lay out the whole document
      // once more, so that is only done for entries that are not obviously
      // small.
      let fits = (
        height() <= size.height / 2
          or height(table-header, ..table-footer) <= size.height
      )
      if fits { rows } else { build-rows(true) }
    }

    let item-rows = ()
    let display-index = 1
    for entry in entries {
      let entry-kind = entry.at("kind", default: "item")
      if entry-kind == "group-header" {
        item-rows += keep-together(breakable => build-group-header-rows(
          entry,
          breakable: breakable,
        ))
      } else if entry-kind == "group-footer" {
        item-rows += keep-together(breakable => build-group-footer-rows(
          entry,
          breakable: breakable,
        ))
      } else {
        let is-odd = calc.odd(display-index)
        let pos-val = entry.at("pos", default: str(display-index))
        item-rows += keep-together(breakable => build-item-rows(
          entry,
          pos-val,
          is-odd: is-odd,
          breakable: breakable,
        ))
        display-index += 1
      }
    }

    table(
      columns: table-columns,
      stroke: none,
      align: auto,
      table-header,
      ..item-rows,
      empty-cell(colspan: total-cols + 2),
      ..table-footer,
      table.hline(stroke: styles.stroke-table-bottom)
    )
  })
}
