//
// Description: Creating nice looking information boxes with different logos
// Author     : Silvan Zahno
//
#import "constants.typ": *

//-------------------------------------
// Option Style
//
#let option-style(
  type: none,
  size: small,
  style: "italic",
  fill: gray-40,
  body) = {[
  #if type == none {
    text(size:size, style:style, fill:fill)[#body]
  } else {
    if type == "draft" {text(size:size, style:style, fill:fill)[#body]}
  }
]}

//-------------------------------------
// Todo Box
//
#let todo(body) = [
  #let rblock = block.with(stroke: red, radius: 0.5em, fill: red.lighten(80%))
  #let top-left = place.with(top + left, dx: 1em, dy: -0.35em)
  #block(inset: (top: 0.35em), {
    rblock(width: 100%, inset: 1em, body)
    top-left(rblock(fill: white, outset: 0.25em, text(fill: red)[*TODO*]))
  })
  <todo>
]

//-------------------------------------
// Title Box
//
#let titlebox(
  width: 100%,
  radius: 10pt,
  border: 1pt,
  inset: 20pt,
  outset: -10pt,
  linecolor: box-border,
  titlesize: huge,
  subtitlesize: larger,
  title: [],
  subtitle: none,
) = {
  if title != [] {
    align(center,
      rect(
        stroke: (left:linecolor+border, top:linecolor+border, rest:linecolor+(border+1pt)),
        radius: radius,
        outset: (left:outset, right:outset),
        inset: (left:inset*2, top:inset, right:inset*2, bottom:inset),
        width: width)[
          #align(center,
            [
              #if subtitle != none {
                [#text(titlesize, title) \ \ #text(subtitlesize, subtitle)]
              } else {
                text(titlesize, title)
              }
            ]
          )
        ]
    )
  }
}

//-------------------------------------
// Icon Boxes
//
#let iconbox(
  width: 100%,
  radius: 4pt,
  border: 4pt,
  inset: 10pt,
  outset: -10pt,
  linecolor: code-border,
  icon: none,
  iconheight: 1cm,
  body
) = {
  if body != none {
    align(left,
      rect(
        stroke: (left:linecolor+border, rest:code-border+0.1pt),
        radius: (left:0pt, right:radius),
        fill: code-bg,
        outset: (left:outset, right:outset),
        inset: (left:inset*2, top:inset, right:inset*2, bottom:inset),
        width: width)[
          #if icon != none {
            align(left,
              table(
                stroke:none,
                align:left+horizon,
                columns: (auto,auto),
                image(icon, height:iconheight), [#body]
              )
            )
          } else {
            body
          }
        ]
    )
  }
}

#let infobox(
  width: 100%,
  radius: 4pt,
  border: 4pt,
  inset:10pt,
  outset: -10pt,
  body
) = {
  iconbox(
    width: width,
    radius: radius,
    border: border,
    inset: inset,
    outset: outset,
    linecolor: color-info,
    icon: icon-info,
  )[#body]
}

#let warningbox(
  width: 100%,
  radius: 4pt,
  border: 4pt,
  inset:10pt,
  outset: -10pt,
  body
) = {
  iconbox(
    width: width,
    radius: radius,
    border: border,
    inset: inset,
    outset: outset,
    linecolor: color-warning,
    icon: icon-warning,
  )[#body]
}

#let ideabox(
  width: 100%,
  radius: 4pt,
  border: 4pt,
  inset:10pt,
  outset: -10pt,
  body
) = {
  iconbox(
    width: width,
    radius: radius,
    border: border,
    inset: inset,
    outset: outset,
    linecolor: color-idea,
    icon: icon-idea
  )[#body]
}

#let firebox(
  width: 100%,
  radius: 4pt,
  border: 4pt,
  inset:10pt,
  outset: -10pt,
  body
) = {
  iconbox(
    width: width,
    radius: radius,
    border: border,
    inset: inset,
    outset: outset,
    linecolor: color-fire,
    icon: icon-fire,
  )[#body]
}

#let importantbox(
  width: 100%,
  radius: 4pt,
  border: 4pt,
  inset:10pt,
  outset: -10pt,
  body
) = {
  iconbox(
    width: width,
    radius: radius,
    border: border,
    inset: inset,
    outset: outset,
    linecolor: color-important,
    icon: icon-important,
  )[#body]
}

#let rocketbox(
  width: 100%,
  radius: 4pt,
  border: 4pt,
  inset:10pt,
  outset: -10pt,
  body
) = {
  iconbox(
    width: width,
    radius: radius,
    border: border,
    inset: inset,
    outset: outset,
    linecolor: color-rocket,
    icon: icon-rocket,
  )[#body]
}

#let todobox(
  width: 100%,
  radius: 4pt,
  border: 4pt,
  inset:10pt,
  outset: -10pt,
  body
) = {
  iconbox(
    width: width,
    radius: radius,
    border: border,
    inset: inset,
    outset: outset,
    linecolor: color-todo,
    icon: icon-todo,
  )[#body]
}

// Creating nice looking information boxes with different headings
#let colorbox(
  title: "title",
  color: color-todo,
  stroke: 0.5pt,
  radius: 4pt,
  width: auto,
  body
) = {
  let strokeColor = color
  let backgroundColor = color.lighten(50%)

  return box(
    fill: backgroundColor,
    stroke: stroke + strokeColor,
    radius: radius,
    width: width
  )[
    #block(
      fill: strokeColor,
      inset: 8pt,
      radius: (top-left: radius, bottom-right: radius),
    )[
      #text(fill: white, weight: "bold")[#title]
    ]
    #block(
      width: 100%,
      inset: (x: 8pt, bottom: 8pt)
    )[
      #body
    ]
  ]
}

#let slanted-background(
  color: black, body) = {
  set text(fill: white, weight: "bold")
  context {
    let size = measure(body)
    let inset = 8pt
    [#block()[
      #polygon(
        fill: color,
        (0pt, 0pt),
        (0pt, size.height + (2*inset)),
        (size.width + (2*inset), size.height + (2*inset)),
        (size.width + (2*inset) + 6pt, 0cm)
      )
      #place(center + top, dy: size.height, dx: -3pt)[#body]
    ]]
  }
}

#let slanted-colorbox(
  title: "title",
  color: color-todo,
  stroke: 0.5pt,
  radius: 4pt,
  width: auto,
  body
) = {
  let strokeColor = color
  let backgroundColor = color.lighten(50%)

  return box(
    fill: backgroundColor,
    stroke: stroke + strokeColor,
    radius: radius,
    width: width
  )[
    #slanted-background(color: strokeColor)[#title]
    #block(
      width: 100%,
      inset: (top: -2pt, x: 10pt, bottom: 10pt)
    )[
      #body
    ]
  ]
}
