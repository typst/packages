/// Estimates footer height to adjust page margins.
#let estimate-footer-height(footer, theme, page-height) = {
  if not footer.enable { return 0pt }
  
  let page-width = page-height * 16 / 10
  let available-width = (page-width / 3) - 2.5cm
  let char-count = footer.authors.join(", ").len()
  
  let lines = if char-count > 0 { 
    calc.ceil(char-count / (available-width / 5.5pt)) 
  } else { 
    1 
  }
  
  calc.max(lines * 1em, 1em)
}

/// Renders the presentation footer.
#let create-footer(footer, theme, page-width, fixed-height) = {
  set text(size: 12pt, weight: "regular", top-edge: "cap-height", bottom-edge: "baseline")

  if not footer.enable { return }

  let sub-text = theme.sub-text

  let c-authors = if footer.authors.len() > 0 {
    text(fill: sub-text)[
      #grid(
        columns: 2, align: (center+horizon, center+horizon),
        box(width: 100%, align(horizon)[
          #set par(leading: 0.2em)
          #footer.authors.join(", ")
        ]),
        box(width: 5em, footer.institute)
      )
    ]
  } else {
    align(center+horizon, text(fill: sub-text, footer.institute))
  }

  let c-title = align(horizon+center, text(fill: sub-text)[
    #v(-0.1em) #footer.title
  ])

  let c-date = grid(
    columns: 2, align: (left+horizon, right+horizon),
    box(width: 100%, text(fill: sub-text)[~#footer.date]),
    box(width: 10%, align(horizon, text(fill: sub-text)[
      #v(-0.1em)
      #context counter(page).display("1/1", both: true)
    ]))
  )

  grid(
    columns: (1fr, 1fr, 1fr),
    inset: -1pt, 
    align: bottom,
    box(
      fill: theme.primary, width: 100%, height: fixed-height,
      outset: (bottom: 3em, left: 0.5cm, top: 0.5em),
      align(horizon, move(dy: -0.3em, c-authors))
    ),
    box(
      fill: rgb("#0064A0"), width: 100%, height: fixed-height,
      outset: (bottom: 3em, top: 0.5em),
      align(horizon+center, move(dy: -0.2em, c-title))
    ),
    box(
      fill: theme.primary, width: 100%, height: fixed-height,
      outset: (bottom: 3em, top: 0.5em, right: 1cm),
      align(horizon, move(dy: -0.2em, c-date))
    ),
  )
}

#let _split-circles(section-title, circles, color) = {
  if circles.len() == 0 { return (text(fill: color)[],) }

  let title-width = measure(text(fill: color)[#section-title]).width
  if title-width == 0pt { return (text(fill: color)[#circles.join("")],) }

  let max-fit = 1
  for n in range(1, circles.len() + 1) {
    let s = circles.slice(0, n).join("")
    if measure(text(fill: color)[#s]).width <= title-width {
      max-fit = n
    } else {
      break
    }
  }

  let max-per-line = calc.max(max-fit, 6)
  if circles.len() <= max-per-line {
    return (text(fill: color)[#circles.join("")],)
  }

  let lines = ()
  let i = 0
  while i < circles.len() {
    let j = calc.min(i + max-per-line, circles.len())
    lines.push(text(fill: color)[#circles.slice(i, j).join("")])
    i = j
  }
  lines
}

/// Renders the navigation header.
#let create-header(theme) = {
  context {
    set text(size: 14pt, weight: "regular")

    let current-slide-idx = {
      let n = query(selector(heading).before(here())).len()
      if n > 0 { n - 1 } else { 0 }
    }
    let all-slides = query(selector(heading))
    let headers = ()
    
    let section = ""
    let circles = ()  
    let dim-color = theme.sub-text.rgb().transparentize(50%)
    let active-color = theme.sub-text
    let text-color = dim-color

    let make-cell(sec, circ, align-mode, outset-data, col) = {
      let circle-lines = _split-circles(sec, circ, col)
      box(width: 100%, outset: outset-data)[
        #align(align-mode, grid(
          columns: 1, align: (left, left),
          v(0.1em),
          text(fill: col)[#sec],
          v(0.2em),
          ..circle-lines
        ))
      ]
    }

    for (i, slide) in all-slides.enumerate() {
      if slide.level == 1 {
        let outset = (left: 0.1cm, bottom: 0.1cm, top: 0.1cm)
        let align-mode = center
        if headers.len() == 1 {
          align-mode = left
          outset = (left: 0.5cm, bottom: 0.1cm, top: 0.1cm)
        }

        headers.push(make-cell(section, circles, align-mode, outset, text-color))
        section = slide.body
        circles = ()
        text-color = dim-color
        continue
      }

      if i < current-slide-idx {
        circles.push("•")
      } else if i == current-slide-idx {
        circles.push("●")
        text-color = active-color
      } else {
        circles.push("◦")
      }    
    }

    headers.push(make-cell(
      section, circles, right, 
      (right: 0.5cm, bottom: 0.1cm, top: 0.1cm), 
      text-color
    ))

    grid(columns: headers.len(), ..headers.slice(1))
  }
}
