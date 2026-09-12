#import "@preview/tidy:0.4.2"
#import "lib.typ": *
#import thm-counter: *
#import thm-state: *
#import thm-themes.ams: *

#let project(title: "", author: "", url: "", body) = {
  set page(paper: "a4", margin: 1in, numbering: "1", number-align: center)
  set document(author: author, title: title)
  set text(font: "Libertinus Serif", lang: "en")
  set heading(numbering: "1.")
  set par(justify: true)
  set list(marker: ([•], [--]), indent: 1em)
  show heading.where(level: 1): it => pad(bottom: 0.5em, it)
  show heading.where(level: 2): it => pad(bottom: 0.5em, it)
  // show link: it => underline(text(fill: blue, it))
  show link: it => text(blue, it)
  show raw: set text(font: "Cascadia Code")


  block(below: 1.5em, text(weight: 500, 2.7em, title))

  block(below: 2.5em)[
    #set text(1.1em, style: "italic")
    #author \
    #link(url)
  ]

  v(2em)

  body
}

#let appendix(body) = {
  set heading(numbering: "A.1.", supplement: [Appendix])
  counter(heading).update(0)
  body
}



#let LATEX = box({
  set text(font: "New Computer Modern")
  [L];box(move(
    dx: -5.2pt, dy: -1.2pt,
    box(scale(65%)[A])
  ));box(move(
    dx: -7.8pt, dy: 0pt,
    [T]
  ));box(move(
    dx: -9.6pt, dy: 2.7pt,
    box(scale(100%)[E])
  ));box(move(
    dx: -11.2pt, dy: 0pt,
    [X]
  ));h(-10.6pt)
})



#let layout-example(
  code,
  preview,
  dir: ltr,
  ratio: 1,
  scale-preview: auto,
  code-block: block,
  preview-block: block,
  col-spacing: 5pt
) = {

  let preview-outer-padding = 5pt
  let preview-inner-padding = 12pt

  layout(size => context {
    let code-width
    let preview-width

    if dir.axis() == "vertical" {
      code-width = size.width
      preview-width = size.width
    } else {
      code-width = ratio / (ratio + 1) * size.width - 0.5 * col-spacing
      preview-width = size.width - code-width - col-spacing
    }

    let available-preview-width = preview-width - 2 * (preview-outer-padding + preview-inner-padding)

    let preview-size
    let scale-preview = scale-preview

    if scale-preview == auto {
      preview-size = measure(preview)
      assert(preview-size.width != 0pt, message: "The code example has a relative width. Please set `scale-preview` to a fixed ratio, e.g., `100%`")
      scale-preview = calc.min(1, available-preview-width / preview-size.width) * 100%
    } else {
      preview-size = measure(block(preview, width: available-preview-width / (scale-preview / 100%)))
    }

    set par(hanging-indent: 0pt)

    let arrangement(width: 100%, height: auto) = block(width: width, inset: 0pt, stack(dir: dir, spacing: col-spacing,
      code-block(
        breakable: dir.axis() == "vertical",
        width: code-width,
        height: height,
        inset: 5pt,
        {
          set text(size: .9em)
          set raw(block: true)
          code
        }
      ),
      preview-block(
        height: height, width: preview-width, 
        inset: preview-outer-padding,
        box(
          width: 100%,
          height: if height == auto {auto} else {height - 2*preview-outer-padding}, 
          fill: white,
          inset: preview-inner-padding,
          box(
            inset: 0pt,
            width: preview-size.width * (scale-preview / 100%), 
            height: preview-size.height * (scale-preview / 100%), 
            place(scale(
              scale-preview, 
              origin: top + left, 
              block(preview, height: preview-size.height, width: preview-size.width)
            ))
          )
        )
      )
    ))
    let height = if dir.axis() == "vertical" { auto } 
      else { measure(arrangement(width: size.width)).height }
    arrangement(height: height)
  })
}


#let scope = (
  thm-themes: thm-themes,
  thm-state: thm-state,
  thm-counter: thm-counter,
  thm-rules: thm-rules,
  thm: thm,
  proof: proof,
  proof-body-fmt: proof-body-fmt,
  tag: tag,
  qedhere: qedhere,
  // thm-display: thm-display,
  // thm-restate: thm-restate,
)

#let example = tidy.show-example.show-example.with(
  scope: scope,
  scale-preview: 100%,
  layout: layout-example,
  preview-block: block.with(
    radius: 3pt,
    fill: rgb("#e4e5ea"),
  ),
  code-block: block.with(
    radius: 3pt,
    stroke: .5pt + luma(200),
    // breakable: false
  )
)


#let example-code(code) = block(
  width: 100%,
  inset: 5pt,
  radius: 3pt,
  stroke: .5pt + luma(200),
  breakable: false,
  code
)

#let fn(fn, post: "()", module: "ctheorems") = {
  link(label(module + "-" + fn + post), raw(lang: "typ", fn))
}
#let var = fn.with(post: "")
