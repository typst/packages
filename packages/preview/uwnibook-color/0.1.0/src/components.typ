#let watermark(
  body,
  padding: 4em,
) = context {
  set par(spacing: 0em)
  let diameter = page.width + page.height

  let body = block(inset: padding, body)
  let (width, height) = measure(body)
  // make sure the watermark covers the whole page
  // by triangle inequality
  let angle = calc.atan(height / width)
  let y-num = calc.ceil(diameter / height)

  rotate(
    angle,
    block(
      width: diameter,
      height: diameter,
      repeat(
        justify: false,
        for y in range(y-num) {
          body
        },
      ),
    ),
  )
}

#let fignote(body) = {
  set align(left)
  set par(leading: 0.65em)
  grid(columns: 2)[_註._][#body]
}

// check if the calling page is the first page of a new chapter
// need a contextal env
#let is_starting() = {
  for h in query(heading.where(level: 1)) {
    if h.location().page() == here().page() {
      return true
    }
  }
  false
}

#let is_even_page() = calc.even(counter(page).get().at(0))


// none -> it is not already yet, e.g. titlepage
#let current_chapter() = {
  let chapter = {
    let c = query(heading.where(level: 1).before(here()))
    if c.len() > 0 {
      c.last().body
    } else {
      none
    }
  }

  let section = {
    let s = query(heading.where(level: 2).before(here()))
    if s.len() > 0 {
      s.last().body
    } else {
      none
    }
  }

  let index = counter(heading).get()
  index = (index.at(0, default: none), index.at(1, default: none))
  let body = (chapter, section)
  // styling it with numbering

  (index: index, body: body)
}

#let current_page() = counter(page).display(page.numbering)


/* Table tools */
#let heavyrule(config) = table.hline.with(stroke: 0.08em + config._color_palette.accent)
#let midrule(config) = table.hline.with(stroke: 0.05em + config._color_palette.accent)
#let vline(config) = table.vline(stroke: 0.05em + config._color_palette.accent)

#let multi-row(eq) = {
  block(
    spacing: 1em,
    eq
      .body
      .children
      .split(linebreak())
      .map([].func())
      .zip((
        [],
        {
          if (eq.has("label")) {
            let c = counter(math.equation)
            c.step()
            h(1em)
            context c.display()
          }
        },
      ))
      .map(array.join)
      .map(math.equation.with(block: true, numbering: none))
      .map(box)
      .join(((h(1fr),) * 2).join(linebreak())),
  )
}

/// todo: fancy pattern
#let justify_page() = {
  set page(header: none, footer: none)
  pagebreak(to: "odd", weak: true)
}

// #let styled_heading_1(kind: none, lineskip: none, text_size: none, config: none, it) = {
//   counter(math.equation).update(0)
//   counter(figure.where(kind: table)).update(0)
//   counter(figure.where(kind: image)).update(0)
//   counter(figure.where(kind: raw)).update(0)
//   pagebreak(weak: true)

//   set par(spacing: lineskip, first-line-indent: 0pt, justify: false)
//   set text(weight: "bold", size: text_size, fill:config._color_palette.accent)
//   set align(right)

//   let frame = block.with(
//     spacing: text_size,
//     width: 100%,
//     stroke: (right: 0.5em +config._color_palette.accent),
//     outset: (right: -0.25em),
//     inset: (right: 1em, y: 0.2em),
//   )

//   let (lang, appendix: (supplement: appendix_pre), ..) = config

//   if it.numbering == none {
//     show: pad.with(top: 10mm, bottom: 1em)
//     frame(upper(it.body))
//     return
//   }

//   let head_num = counter(heading)
//   let default_num = text(1.5em, head_num.display(it.numbering))
//   if kind == "chapter" {
//     show: pad.with(top: 80mm, bottom: 1em)

//     let line1 = if lang == "en" [
//       #smallcaps(it.supplement)~#default_num
//     ] else if lang == "ja" [
//       第 #default_num 章
//     ] else if lang == "zh" [
//       #set text(fill:config._color_palette.accent.transparentize(50%))
//       第#h(.25em)#text(2em, head_num.display("一"))
//     ]

//     let line2 = if lang == "zh" {
//       it.body + h(.25em) + text(luma(50%), it.supplement)
//     } else {
//       upper(it.body)
//     }
//     frame[#line1#v(0.25em)#line2]
//     return
//   }

//   if kind == "appendix" {
//     show: pad.with(top: 10mm, bottom: 1em)
//     let line1 = if lang == "en" [
//       #smallcaps(it.supplement)~#default_num
//     ] else if lang == "ja" [
//       #it.supplement~#default_num
//     ] else if lang == "zh" [
//       #set text(fill:config._color_palette.accent.transparentize(50%))
//       #text(luma(50%), appendix_pre)#h(.25em)#default_num
//     ]
//     let line2 = upper(it.body)
//     frame[#line1#v(0.25em)#line2]
//     return
//   }
// }

#let _heading_text_style(config) = (
  font: config._sans_font,
  weight: "bold",
  fill: config._color_palette.accent,
  tracking: 0.07em,
)

#let _toc_heading(config, it) = {
  let heading_size = 36pt
  let lineskip = 0.8 * heading_size
  set par(first-line-indent: 0pt, justify: false, leading: lineskip)
  set text(size: heading_size, .._heading_text_style(config))
  show text: upper
  it.body
  v(lineskip)
}

#let _fancy_chapter_heading(config, it) = {
  let heading_size = 26pt
  let lineskip = 0.7 * heading_size
  set par(leading: lineskip, justify: false)
  set text(size: heading_size, .._heading_text_style(config))

  let head_num = counter(heading)
  let default_num = text(white, head_num.display(it.numbering))

  v(-config._page_top_margin + config._chap_top_margin + heading_size)
  grid(
    columns: 2,
    column-gutter: 10pt,
    block(
      fill:config._color_palette.accent,
      inset: (x: 10pt),
      outset: (top: config._chap_top_margin + heading_size, bottom: 10pt),
      default_num,
    ),
    upper(it.body),
  )
  v(lineskip)
}

#let _standalone_heading(config, it) = {
  let heading_size = 26pt
  let lineskip = 0.6 * heading_size
  set par(first-line-indent: 0pt, justify: false, leading: lineskip)
  set text(size: heading_size, .._heading_text_style(config))
  show text: upper
  v(-config._page_top_margin)
  block(fill:config._color_palette.accent, height: config._page_top_margin, spacing: heading_size, hide(it.body))
  it.body
  v(lineskip)
}

#let _appendix_heading(config, chap_top_margin: 0pt, it) = {
  let prefix_size = 20pt
  let heading_size = 26pt
  let lineskip = 0.6 * heading_size
  set par(first-line-indent: 0pt, justify: false, spacing: lineskip)
  set text(size: heading_size, .._heading_text_style(config))

  show text: upper
  let prefix = text(prefix_size, config.i18n.appendix + h(.5em) + counter(heading).display(it.numbering))
  v(-config._page_top_margin)
  block(
    fill:config._color_palette.accent,
    height: config._page_top_margin,
    spacing: heading_size,
    inset: (x: 10pt),
    align(bottom, text(white, prefix)),
  )
  h(10pt) + text(heading_size, it.body)
  v(lineskip)
}

