#let align-helper(state-key, what-to-measure, display) = context {
  let max-width = state(state-key, 0pt)
  let this-width = measure(what-to-measure).width
  max-width.update(max => calc.max(this-width, max))
  display(max-width.final(), this-width)
}

/// Repeat the given content to fill the full space.
///
/// Custom function instead of the built-in to support fixed-size gaps.
///
/// Parameters:
/// - gap: The gap between repeated items. (Default: none)
/// - justify: Whether to increase the gap to justify the items. (Default: false)
///
/// Returns: The repeated content.
///
/// Based on https://github.com/EpicEricEE/typst-plugins/blob/b13b0e1bc30beba65ff19d029e2dad61239a2819/outex/src/outex.typ#L1-L27
#let repeat(
  gap: none,
  justify: false,
  body
) = layout(size => context {
  // function to measure length in `pt` unit
  let pt-length(len) = measure(h(len)).width

  // width of the body to repeat
  let width = measure(body).width
  // how often the body should be repeated
  let repeat-count = calc.floor(pt-length(size.width + gap) / pt-length(width + gap))

  // justify the gap
  let gap = if not justify { gap } else {
    (size.width - repeat-count * width) / (repeat-count - 1)
  }

  let items = ((box(body),) * repeat-count)
  if type(gap) == length and gap != 0pt {
    // add gap between items
    items = items.intersperse(h(gap))
  }

  items.join()
})

#let presets = (
  // outrageous preset for a Table of Contents
  outrageous-toc: (
    font-weight: ("bold", auto),
    font-style: (auto,),
    vspace: (12pt, none),
    font: ("Noto Sans", auto),
    fill: (none, align(right, repeat(gap: 6pt)[.])),
    fill-right-pad: .4cm,
    fill-align: true,
    prefix-transform: none,
    body-transform: none,
    page-transform: none,
  ),
  // outrageous preset for List of Figures/Tables/Listings
  outrageous-figures: (
    font-weight: (auto,),
    font-style: (auto,),
    vspace: (none,),
    font: (auto,),
    fill: (align(right, repeat(gap: 6pt)[.]),),
    fill-right-pad: .4cm,
    fill-align: true,
    prefix-transform: (lvl, prefix) => {
      let (supplement, _, number) = prefix.children
      let v = if number.text.ends-with(regex("[^\d]1[^\d]*")) and not number.text.starts-with("1") {
        v(10pt)
      }
      box[#v#number.]
    },
    body-transform: none,
    page-transform: none,
  ),
  // preset without any style changes
  typst: (
    font-weight: (auto,),
    font-style: (auto,),
    vspace: (none,),
    font: (auto,),
    fill: (auto,),
    fill-right-pad: none,
    fill-align: false,
    prefix-transform: none,
    body-transform: none,
    page-transform: none,
  ),
)

#let show-entry(
  entry,
  font-weight: presets.outrageous-toc.font-weight,
  font-style: presets.outrageous-toc.font-style,
  vspace: presets.outrageous-toc.vspace,
  font: presets.outrageous-toc.font,
  fill: presets.outrageous-toc.fill,
  fill-right-pad: presets.outrageous-toc.fill-right-pad,
  fill-align: presets.outrageous-toc.fill-align,
  prefix-transform: presets.outrageous-toc.prefix-transform,
  body-transform: presets.outrageous-toc.body-transform,
  page-transform: presets.outrageous-toc.page-transform,
  state-key: "outline-page-number-max-width",
) = {
  fill-right-pad = if fill-right-pad == none { 0pt } else { fill-right-pad }
  let max-width = state(state-key, 0pt)
  let font-weight = font-weight.at(calc.min(font-weight.len(), entry.level) - 1)
  let font-style = font-style.at(calc.min(font-style.len(), entry.level) - 1)
  let vspace = vspace.at(calc.min(vspace.len(), entry.level) - 1)
  let font = font.at(calc.min(font.len(), entry.level) - 1)
  let fill = fill.at(calc.min(fill.len(), entry.level) - 1)

  set text(font: font) if font not in (auto, none)
  set text(weight: font-weight) if font-weight not in (auto, none)
  set text(style: font-style) if font-style not in (auto, none)
  if vspace != none { v(vspace, weak: true) }

  let prefix = if prefix-transform != none {
    let new-prefix = prefix-transform(entry.level, entry.prefix())
    if new-prefix == none { entry.prefix() } else { new-prefix }
  } else { entry.prefix() }
  let body = if body-transform != none {
    let new-body = body-transform(entry.level, entry.prefix(), entry.body())
    if new-body == none { entry.body() } else { new-body }
  } else { entry.body() }
  let page = if page-transform != none {
    let new-page = page-transform(entry.level, entry.page())
    if new-page == none { entry.page() } else { new-page }
  } else { entry.page() }

  context {
    // no gap when prefix is empty
    let gap = if prefix == none or measure(prefix).width == 0pt { 0pt } else { .5em }
    let display(fill) = link(
      entry.element.location(),
      entry.indented(prefix, gap: gap, [#body #box(width: 1fr, fill) #sym.wj#page]),
    )

    if fill in (none, auto) or not fill-align {
      let fill = if fill != auto {
        if fill == none { none } else {
          box(width: 100% - fill-right-pad, fill)
        }
      } else {
        entry.fill
      }
      display(fill)
    } else {
      align-helper(
        state-key,
        page,
        (max-width, this-width) => {
          let fill = box(width: 100% - (max-width - this-width) - fill-right-pad, fill)
          display(fill)
        }
      )
    }
  }
}
