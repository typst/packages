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
      (styles.at("num", default: x => x))(text(
        fill: color,
      )[(#sign #mod.display)])
    } else { [] },
    absolute: (styles.at("num", default: x => x))(text(
      fill: color,
    )[#sign #mod.absolute]),
  )
}

#let default-render-header(ctx, content, styles) = {
  set text(fill: styles.header-color)
  content
}

#let default-render-tax-suffix(ctx, is-net, styles, style-type) = {
  let strings = ctx.locale.strings.line-items
  let label = if is-net { strings.net } else { strings.gross }
  // on a filled header the suffix takes the header text colour (was invisible on dark fills)
  let fill-color = if styles.header-bg != none { styles.header-color } else {
    styles.color-subtitle
  }

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
  row-fill: none,
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
  // set-text arguments of the column headers; auto = (weight: weight-bold)
  header-text-style: auto,
  // font of the figure cells (position, quantity, prices, tax rate, amounts); none = inherited
  number-font: none,
  // paragraph leading inside the cells; none = inherited
  leading: none,
  // rule between two entries (none | stroke)
  row-rule: none,
  // keep an item's rows (name, description, modifiers, subtotal) on one page
  keep-together: true,
  // content bound to the LAST entry (the totals): it follows the table's bottom rule
  // inside the entry's unbreakable span, so it never starts a page alone (needs
  // keep-together; column 0 then has no width). none = the table ends with its rule.
  tail: none,
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
      // idx is none for a column the table does not show (e.g. no total column)
      if idx != none and idx < spec.len() {
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
  let entries = data.at("entries", default: data.items)
  // the tail binds to the last entry (an item or a group's subtotal)
  let bound = (
    tail != none
      and keep-together
      and render-table-footer == auto
      and entries.len() > 0
      and entries.last().at("kind", default: "item") in ("item", "group-footer")
  )
  // a bound tail spans columns 1.. of the last entry: column 0 (the entry's left
  // padding) must be empty, or its fill and gap would show beside the tail
  if bound { normalized-item-inset.left = 0pt }
  let normalized-item-stroke = normalize-directional(item-stroke)

  let styles = (
    color-subtitle: color-subtitle,
    color-desc: color-desc,
    color-discount: color-discount,
    color-surcharge: color-surcharge,
    color-row-odd: color-row-odd,
    color-row-even: color-row-even,
    row-fill: row-fill,

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
    // wraps figure content in the number font (identity when none)
    num: x => if number-font == none { x } else { text(font: number-font, x) },
  )

  set par(justify: false)
  set par(leading: leading) if leading != none
  let header-text-style = if header-text-style == auto {
    (weight: weight-bold)
  } else { header-text-style }
  let num(x) = if number-font == none { x } else { text(font: number-font, x) }

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
    header-contents.insert("pos", [#li-str.position])
  }
  header-contents.insert("description", [#li-str.description])

  let available-header-cols = (
    "quantity": [#li-str.quantity],
    "unit-price": block[#li-str.unit-price#get-suffix("unit-price")],
    "tax-rate": [#li-str.vat],
    "total-price": block[#li-str.total#get-suffix("total")],
  )
  for key in active-cols-keys {
    header-contents.insert(key, available-header-cols.at(key))
  }

  let empty-cell = table.cell.with(inset: 0pt, none)

  // the padding columns take the header fill too, so a filled header is exactly as
  // wide as the zebra rows below it
  let table-header-cells = (
    (empty-cell(fill: styles.header-bg),)
      + content-keys.map(key => {
        let default-align = get-default-align(key)
        let idx = content-keys.position(k => k == key)
        let cell-align = resolve-align(align-header, key, idx, default-align)
        table.cell(
          fill: styles.header-bg,
          inset: styles.header-cell-inset,
          align: cell-align,
        )[#do-render-header(
          ctx,
          text(..header-text-style, header-contents.at(key)),
          styles,
        )]
      })
      + (empty-cell(fill: styles.header-bg),)
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

  // Recursive Item Builder
  let build-item-rows(
    item,
    index,
    is-odd: auto,
    // running number of the entry (1 for the first), passed to a row-fill callback
    number: none,
    is-sub-item: false,
    bind: false,
    open: false,
    // keep this entry on one page (false: the fallback for an entry taller than a page)
    keep: keep-together,
  ) = {
    let rows = ()
    let resolved-odd = if is-odd != auto {
      is-odd
    } else if type(index) == int {
      calc.odd(index)
    } else {
      true
    }
    let row-style = item.at("style", default: none)
    let bg = if row-style != none and row-style.fill != none {
      row-style.fill
    } else if styles.row-fill != none {
      (styles.row-fill)(number)
    } else if resolved-odd {
      styles.color-row-odd
    } else {
      styles.color-row-even
    }

    // 1. Resolve Strokes (Top, Bottom, Left, Right)
    let cell-inset = styles.cell-inset
    let item-inset = styles.item-inset
    let item-stroke = styles.item-stroke

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

    let left-spacer = line-cell(
      inset: null-dir + (left: item-inset.left),
      stroke: (left: item-stroke.left),
      none,
    )

    let right-spacer = line-cell(
      inset: null-dir + (right: item-inset.right),
      stroke: (right: item-stroke.right),
      none,
    )

    // keep-together: column 0 is ONE unbreakable cell spanning all rows of the
    // item (inserted below), so the item never splits from its description,
    // modifiers or subtotal at a page break; every row then skips column 0.
    let ls = "__left-spacer__"
    let left-spacer = if keep { ls } else { left-spacer }
    let cap-span = if keep { total-cols + 1 } else { total-cols + 2 }
    let cap-stroke(side) = if keep {
      item-stroke + (left: none, (side): none)
    } else { item-stroke + ((side): none) }

    // --- TOP CAP: Padding & Border ---
    rows.push(line-cell(
      colspan: cap-span,
      inset: null-dir + (top: item-inset.top),
      stroke: cap-stroke("bottom"),
      none,
    ))

    // --- SECTION: MAIN ITEM ROW ---
    rows.push(left-spacer)

    let col-tracker = 0
    if layout.show-pos {
      let default-align = get-default-align("pos")
      let idx = content-keys.position(k => k == "pos")
      let cell-align = resolve-align(align-body, "pos", idx, default-align)
      rows.push(line-cell(
        num[#index],
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
    rows.push(line-cell(
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
      rows.push(line-cell(num(content), align: cell-align))
      col-tracker += 1
    }

    rows.push(right-spacer)

    // --- SECTION: DESCRIPTION ROW ---
    if has-description {
      let d-col-tracker = 0
      rows.push(left-spacer)

      if layout.show-pos {
        rows.push(line-cell(inset: 0pt, none))
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

      rows.push(line-cell(
        do-render-desc(ctx, item, layout, styles),
        colspan: abs-description-colspan,
        inset: cell-inset + (top: 0pt),
        align: desc-cell-align,
      ))

      let remaining = total-cols - desc-idx - abs-description-colspan
      if remaining > 0 {
        rows.push(line-cell(
          none,
          colspan: remaining,
        ))
      }

      rows.push(right-spacer)
    }

    // --- SECTION: MODIFIER ROWS ---
    let build-modifier-row(mod, is-discount) = {
      let m-row = ()
      let m-col-tracker = 0

      m-row.push(left-spacer)

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

      if indices.total == none {
        // No total column (left out of column-order or hidden): the label and
        // the percentage span the value columns, the amount shows in the
        // totals, as in the table of `compact`.
        let span1 = indices.total-count - indices.desc
        m-row.push(line-cell(
          [#mod-content.label #text(
              size: styles.size-small,
              mod-content.percent,
            )],
          inset: cell-inset + (top: 0pt),
          colspan: span1,
          align: desc-cell-align,
        ))
        m-col-tracker += span1
      } else if indices.percent != none {
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
      // the columns after the total, where column-order puts any
      let remaining = indices.total-count - m-col-tracker
      if remaining > 0 {
        m-row.push(line-cell(none, colspan: remaining, inset: 0pt))
      }

      m-row.push(right-spacer)

      return m-row
    }

    if has-mods {
      if item.at("has-discounts", default: false) {
        for discount in item.discounts {
          rows += build-modifier-row(discount, true)
        }
      }

      if item.at("has-surcharge", default: false) {
        for surcharge in item.surcharge {
          rows += build-modifier-row(surcharge, false)
        }
      }
    }

    // --- SECTION: SUBTOTAL ROW ---
    // Only with a total column: without one, the amounts show in the totals,
    // as in the table of `compact`.
    if has-mods and indices.total != none {
      rows.push(left-spacer)
      let sub-col-tracker = 0

      if layout.show-pos {
        rows.push(line-cell(inset: 0pt, none))
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
      rows.push(line-cell(
        text(
          weight: styles.weight-bold,
          size: styles.size-subtitle,
        )[#li-str.subtotal],
        colspan: span1,
        align: desc-cell-align,
      ))
      sub-col-tracker += span1

      // Total Value
      rows.push(line-cell(
        num(text(weight: styles.weight-bold)[#item.total]),
        align: total-cell-align,
      ))
      sub-col-tracker += 1

      // Fill remaining
      let remaining = total-cols - sub-col-tracker
      if remaining > 0 {
        rows.push(line-cell(
          none,
          inset: 0pt,
          colspan: remaining,
        ))
      }
      rows.push(right-spacer)
    }

    // --- BOTTOM CAP: Padding & Border ---
    rows.push(line-cell(
      colspan: cap-span,
      inset: null-dir + (bottom: item-inset.bottom),
      stroke: cap-stroke("top"),
      [],
    ))

    // the bound tail: one more row inside the unbreakable span, opened by the
    // table's bottom rule
    if bind {
      rows.push(ls)
      rows.push(line-cell(
        colspan: cap-span,
        fill: none,
        inset: 0pt,
        stroke: (top: styles.stroke-table-bottom),
        tail,
      ))
    }

    // open: the caller spans these rows together with the next entry's (the item
    // before a bound group subtotal); the separator row joins the span
    if open {
      rows.push(ls)
      rows.push(empty-cell(colspan: total-cols + 1))
      return rows
    }

    if keep {
      let spanned = rows.filter(r => r == ls).len() + 2
      rows = (
        (
          line-cell(
            rowspan: spanned,
            breakable: false,
            inset: null-dir + (left: item-inset.left),
            stroke: (
              left: item-stroke.left,
              top: item-stroke.top,
              bottom: item-stroke.bottom,
            ),
            none,
          ),
        )
          + rows.filter(r => r != ls)
      )
    }

    rows.push(empty-cell(colspan: total-cols + 2))

    rows
  }

  let build-group-header-rows(group, keep: keep-together) = {
    let rows = ()
    let cell-inset = styles.cell-inset
    let item-inset = styles.item-inset
    let item-stroke = styles.item-stroke
    let group-style = group.at("style", default: none)

    let line-cell = table.cell.with(
      colspan: 1,
      align: auto,
      fill: if group-style != none { group-style.fill } else { none },
      inset: cell-inset,
      stroke: none,
    )

    let left-spacer = line-cell(
      inset: null-dir + (left: item-inset.left),
      stroke: (left: item-stroke.left),
      none,
    )

    let right-spacer = line-cell(
      inset: null-dir + (right: item-inset.right),
      stroke: (right: item-stroke.right),
      none,
    )

    // keep-together: column 0 is ONE unbreakable cell spanning the header's rows
    // (inserted below), so a page break never falls inside the group header
    let ls = "__left-spacer__"
    let left-spacer = if keep { ls } else { left-spacer }
    let cap-span = if keep { total-cols + 1 } else { total-cols + 2 }
    let cap-stroke(side) = if keep {
      item-stroke + (left: none, (side): none)
    } else { item-stroke + ((side): none) }

    // Top spacer
    rows.push(line-cell(
      colspan: cap-span,
      inset: null-dir + (top: item-inset.top + 0.4em),
      stroke: cap-stroke("bottom"),
      none,
    ))

    rows.push(left-spacer)

    let remaining-cols = total-cols
    if layout.show-pos {
      let default-align = get-default-align("pos")
      let idx = content-keys.position(k => k == "pos")
      let cell-align = resolve-align(align-body, "pos", idx, default-align)
      rows.push(line-cell(
        num(text(weight: styles.weight-bold)[#group.pos]),
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

    rows.push(line-cell(
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

    rows.push(right-spacer)

    // Bottom cap
    rows.push(line-cell(
      colspan: cap-span,
      inset: null-dir + (bottom: item-inset.bottom),
      stroke: cap-stroke("top"),
      [],
    ))

    if keep {
      let spanned = rows.filter(r => r == ls).len() + 2
      rows = (
        (
          line-cell(
            rowspan: spanned,
            breakable: false,
            inset: null-dir + (left: item-inset.left),
            stroke: (
              left: item-stroke.left,
              top: item-stroke.top,
              bottom: item-stroke.bottom,
            ),
            none,
          ),
        )
          + rows.filter(r => r != ls)
      )
    }

    rows.push(empty-cell(colspan: total-cols + 2))

    rows
  }

  // `lead`: open rows of the entry before (its two cap rows are not ls-marked)
  let build-group-footer-rows(
    group,
    bind: false,
    lead: (),
    keep: keep-together,
  ) = {
    let rows = ()
    let cell-inset = styles.cell-inset
    let item-inset = styles.item-inset
    let item-stroke = styles.item-stroke
    let group-style = group.at("style", default: none)

    let line-cell = table.cell.with(
      colspan: 1,
      align: auto,
      fill: if group-style != none { group-style.fill } else { none },
      inset: cell-inset,
      stroke: none,
    )

    let left-spacer = line-cell(
      inset: null-dir + (left: item-inset.left),
      stroke: (left: item-stroke.left),
      none,
    )

    let right-spacer = line-cell(
      inset: null-dir + (right: item-inset.right),
      stroke: (right: item-stroke.right),
      none,
    )
    // keep-together (as for items) and a bound tail: column 0 becomes ONE
    // unbreakable cell spanning the subtotal (and the tail rows), so a group
    // subtotal never splits and travels with the totals as one unit
    let span = bind or keep
    let ls = "__left-spacer__"
    let left-spacer = if span { ls } else { left-spacer }
    let wide = if span { total-cols + 1 } else { total-cols + 2 }

    // Top spacer
    rows.push(line-cell(
      colspan: wide,
      inset: null-dir + (top: item-inset.top),
      stroke: item-stroke + (bottom: none),
      none,
    ))

    rows.push(left-spacer)
    let sub-col-tracker = 0

    if layout.show-pos {
      rows.push(line-cell(inset: 0pt, none))
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

    // Without a total column, the label spans the value columns and the
    // amount shows in the totals, as in the table of `compact`.
    let span1 = if indices.total == none { total-cols - sub-col-tracker } else {
      indices.total - indices.desc
    }
    rows.push(line-cell(
      text(
        weight: styles.weight-bold,
        size: styles.size-subtitle,
      )[#li-str.subtotal #group.name],
      colspan: span1,
      align: desc-cell-align,
      inset: cell-inset,
    ))
    sub-col-tracker += span1

    if indices.total != none {
      rows.push(line-cell(
        num(text(weight: styles.weight-bold)[#group.subtotal]),
        align: total-cell-align,
        inset: cell-inset,
      ))
      sub-col-tracker += 1
    }

    let remaining = total-cols - sub-col-tracker
    if remaining > 0 {
      rows.push(line-cell(
        none,
        inset: 0pt,
        colspan: remaining,
      ))
    }
    rows.push(right-spacer)

    // Bottom cap
    rows.push(line-cell(
      colspan: wide,
      inset: null-dir + (bottom: item-inset.bottom + 0.2em),
      stroke: item-stroke + (top: none),
      [],
    ))

    if bind {
      rows.push(ls)
      rows.push(line-cell(
        colspan: wide,
        fill: none,
        inset: 0pt,
        stroke: (top: styles.stroke-table-bottom),
        tail,
      ))
      rows = lead + rows
    }
    if span {
      let spanned = (
        rows.filter(r => r == ls).len() + 2 + if lead.len() > 0 { 2 } else { 0 }
      )
      // a bound tail zeroes the left padding (normalized-item-inset), see `bound`
      rows = (
        (
          line-cell(
            rowspan: spanned,
            breakable: false,
            inset: null-dir + (left: item-inset.left),
            stroke: (left: item-stroke.left),
            none,
          ),
        )
          + rows.filter(r => r != ls)
      )
    }

    rows.push(empty-cell(colspan: total-cols + 2))

    rows
  }

  // An entry kept on one page but taller than a page (next to the repeated
  // header and footer) would overflow it, so such an entry falls back to rows
  // that may break across pages, and a tail it carried follows the table.
  // Measuring the header as well makes Typst lay out the document once more,
  // so that is only done for entries that are not obviously small.
  // `layout` is shadowed by the layout information above.
  std.layout(size => {
    let fits(rows) = {
      if not keep-together { return true }
      let height(..header-footer) = {
        measure(
          width: size.width,
          table(
            columns: (auto,) + cols + (auto,),
            stroke: none,
            ..header-footer,
            ..rows,
          ),
        ).height
      }
      (
        height() <= size.height / 2
          or height(table-header, ..table-footer) <= size.height
      )
    }

    let item-rows = ()
    let tail-bound = bound
    let display-index = 1
    let n = entries.len()
    // a bound group subtotal takes the item before it into its span: the totals
    // stay with the last item row, not only with the subtotal
    let lead-open = (
      bound
        and n >= 2
        and entries.last().at("kind", default: "item") == "group-footer"
        and entries.at(n - 2).at("kind", default: "item") == "item"
    )
    let lead = ()
    let lead-plain = ()
    for (i, entry) in entries.enumerate() {
      let out = ()
      // rule between two entries (a group header opens its group: no rule below it)
      if (
        row-rule != none
          and i > 0
          and entries.at(i - 1).at("kind", default: "item") != "group-header"
      ) {
        out.push(table.hline(stroke: row-rule))
      }
      let entry-kind = entry.at("kind", default: "item")
      let bind = bound and i == n - 1
      if entry-kind == "group-header" {
        let rows = build-group-header-rows(entry)
        out += if fits(rows) { rows } else {
          build-group-header-rows(entry, keep: false)
        }
      } else if entry-kind == "group-footer" {
        let plain-footer() = {
          let rows = build-group-footer-rows(entry)
          if fits(rows) { rows } else {
            build-group-footer-rows(entry, keep: false)
          }
        }
        if lead.len() > 0 {
          // the rule between the lead item and the subtotal belongs inside the span
          let rows = build-group-footer-rows(
            entry,
            bind: bind,
            lead: lead + out,
          )
          if fits(rows) { out = rows } else {
            tail-bound = false
            out = lead-plain + out + plain-footer()
          }
        } else if bind {
          let rows = build-group-footer-rows(entry, bind: true)
          if fits(rows) { out += rows } else {
            tail-bound = false
            out += plain-footer()
          }
        } else {
          out += plain-footer()
        }
      } else {
        let rows-of = build-item-rows.with(
          entry,
          entry.at("pos", default: str(display-index)),
          is-odd: calc.odd(display-index),
          number: display-index,
        )
        let open = lead-open and i == n - 2
        let plain-item() = {
          let rows = rows-of()
          if fits(rows) { rows } else { rows-of(keep: false) }
        }
        display-index += 1
        if open {
          lead = out + rows-of(open: true)
          lead-plain = out + plain-item()
          continue
        }
        if bind {
          let rows = rows-of(bind: true)
          if fits(rows) { out += rows } else {
            tail-bound = false
            out += plain-item()
          }
        } else {
          out += plain-item()
        }
      }
      item-rows += out
    }

    table(
      columns: (auto,) + cols + (auto,),
      stroke: none,
      align: auto,
      table-header,
      ..item-rows,
      empty-cell(colspan: total-cols + 2),
      ..table-footer,
      // a bound tail already opened with the bottom rule
      ..if not tail-bound {
        (table.hline(stroke: styles.stroke-table-bottom),)
      },
    )
    // a tail that could not stay bound (no entry to bind to, or its entry is
    // taller than a page) follows the table, so the totals are never lost
    if tail != none and not tail-bound { tail }
  })
}
