#import "./themes.typ": *
#import "./layouts.typ": *


// column-box
#let column-box(
  body,
  heading: none,
) = context {

  let pt = _state-poster-theme.get()
  let pl = _state-poster-layout.get()
  let heading-color = pt.at("heading-color", default: rgb(64, 115, 158))
  let heading-size = pt.at("heading-size", default: 42pt)
  let body-size = pt.at("body-size", default: 40pt)
  let lang = pt.at("lang", default: "ja")
  let font = pt.at("font", default: ("Lato", "Noto Sans CJK JP"))

  let heading-content = if heading==none { none } else {[
    #set text(
      fill: heading-color,
      size: heading-size,
      lang: lang,
      font: font,
      weight: "medium",
    )
    #set align(center)
    #box(width: 100%)[#heading]
    #v(-0.75em)
    #rect(width: 100%, height: 1.5pt, fill: black)
    #v(0.5em)
  ]}

  let body-content = if body==none { none } else {[
    #set text(
      fill: black,
      size: body-size,
      lang: "ja",
      font: ("Lato", "Noto Sans CJK JP"),
      weight: "light",
    )
    #body
  ]}

  stack(dir: ttb,
    heading-content,
    box(stroke: none)[#body-content],
  )
}

// title-box
#let title-box(
  title,
  authors: none,
  institutes: none,
) = context {

  let pt = _state-poster-theme.get()
  let pl = _state-poster-layout.get()
  let text-color = pt.at("text-color", default: white)
  let fill-color = pt.at("fill-color", default: rgb(64, 115, 158))
  let stroke-color = pt.at("stroke-color", default: rgb(39, 60, 117))
  let title-size = pt.at("title-size", default: 75pt)
  let authors-size = pt.at("authors-size", default: 55pt)
  let institutes-size = pt.at("institutes-size", default: 40pt)
  let lang = pt.at("lang", default: "ja")
  let font = pt.at("font", default: ("Raleway", "Noto Sans CJK JP"))
  let weight = pt.at("weight", default: "regular")
  
  /// Generate body of box
  let text-content = [
    #set align(center)
    #v(24.0pt)
    #set text(size: title-size)
    #title\
    #v(0.75em, weak: true)
    #set text(size: authors-size)
    #if authors!=none {[#authors\ ]}
    #if institutes!=none {[
      #set text(size: institutes-size)
      #institutes
    ]}
    #v(20.0pt)
  ]

  rect(
    inset: 0.5em,
    width: 100%,
    fill: fill-color,
    stroke: stroke-color,
  )[
    #set text(
      lang: lang,
      fill: text-color,
      font: font,
      weight: weight,
    )
    #align(center, box(text-content, width: 100%))
  ]
}

#let bottom-box(
  body,
  text-relative-width: 70%,
  x-inset: 2.0cm,
  bottom-inset: 2.0cm,
) = context {

  let pt = _state-poster-theme.get()
  let pl = _state-poster-layout.get()
  let text-color = pt.at("text-color", default: black)
  let body-size = pt.at("body-size", default: 40pt)
  let lang = pt.at("lang", default: "ja")
  let font = pt.at("font", default: ("Lato", "Noto Sans CJK JP"))
  let weight = pt.at("weight", default: "light")
  
  if body==none {
    none
  } else {
    let content = [
      // draw a line
      #rect(width: 100%, height: 1.5pt, fill: gray)
      #v(-0.5em)
      #set text(
        fill: text-color,
        size: body-size,
        lang: lang,
        font: font,
        weight: weight,
      )
      #set align(top+left)
      #body
    ]
    let r = box(stroke: none, width: 100%, inset: (x: x-inset, y: bottom-inset))[#content]
    align(bottom, r)
  }
}