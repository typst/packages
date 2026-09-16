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

#let infobox = iconbox.with(
  linecolor: color-info,
  icon: icon-info,
)

#let warningbox = iconbox.with(
  linecolor: color-warning,
  icon: icon-warning,
)

#let ideabox = iconbox.with(
  linecolor: color-idea,
  icon: icon-idea
)

#let firebox = iconbox.with(
  linecolor: color-fire,
  icon: icon-fire,
)

#let importantbox = iconbox.with(
  linecolor: color-important,
  icon: icon-important,
)

#let rocketbox = iconbox.with(
  linecolor: color-rocket,
  icon: icon-rocket,
)

#let todobox = iconbox.with(
  linecolor: color-todo,
  icon: icon-todo,
)

#let thinkbox = iconbox.with(
  linecolor: color-think,
  icon: icon-think,
)

#let helpbox = iconbox.with(
  linecolor: color-think,
  icon: icon-help,
)

//-------------------------------------
// Color Boxes
//
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

//-------------------------------------
// Exam header
//
#let exam-header(
  nbr-ex: 5+1,
  pts: 10,
  lang: "en" // "de" "fr"
) = {
  if nbr-ex == 0 {
    table(
      columns: (2cm, 90%),
      align: center + top,
      stroke: none,
      if lang == "en" or lang == "de" {[#text(large, "Name:")]} else {[#text(large, "Nom:")]
      },
      [#line(start: (0cm, 0.7cm), length:(100%), stroke:(dash:"loosely-dashed"))],
    )
  } else if nbr-ex == 1 {
    table(
      columns: (2cm, 90%-1.3cm, 1.3cm),
      align: center + top,
      stroke: none,
      [], [], if lang == "en" {[#v(-0.4cm)#text(small, "Grade")]} else {[#v(-0.4cm)#text(small, "Note")]},
      if lang == "en" or lang == "de" {[#text(large, "Name:")]} else {[#text(large, "Nom:")]
      },
      [#line(start: (0cm, 0.7cm), length:(100%), stroke:(dash:"loosely-dashed"))],
      [#v(-0.3cm)#rect(height:1cm, width:1.2cm, stroke:2pt)],
    )
  } else if nbr-ex == 2 {
    table(
      columns: (2cm, 90%-2.3cm, 1cm, 1.3cm),
      align: center + top,
      stroke: none,
      [], [], [#v(-0.4cm)#text(small, "1")], if lang == "en" {[#v(-0.4cm)#text(small, "Grade")]} else {[#v(-0.4cm)#text(small, "Note")]},
      if lang == "en" or lang == "de" {[#text(large, "Name:")]} else {[#text(large, "Nom:")]
      },
      [#line(start: (0cm, 0.7cm), length:(100%), stroke:(dash:"loosely-dashed"))],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#rect(height:1cm, width:1.2cm, stroke:2pt)],
      [], [], [#v(-0.2cm)#text(small, [(#pts)])], [],
    )
  } else if nbr-ex == 3 {
    table(
      columns: (2cm, 90%-3.3cm, 1cm, 1cm, 1.3cm),
      align: center + top,
      stroke: none,
      [], [], [#v(-0.4cm)#text(small, "1")], [#v(-0.4cm)#text(small, "2")], if lang == "en" {[#v(-0.4cm)#text(small, "Grade")]} else {[#v(-0.4cm)#text(small, "Note")]},
      if lang == "en" or lang == "de" {[#text(large, "Name:")]} else {[#text(large, "Nom:")]
      },
      [#line(start: (0cm, 0.7cm), length:(100%), stroke:(dash:"loosely-dashed"))],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#rect(height:1cm, width:1.2cm, stroke:2pt)],
      [], [], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [],
    )
  } else if nbr-ex == 4 {
    table(
      columns: (2cm, 90%-4.3cm, 1cm, 1cm, 1cm, 1.3cm),
      align: center + top,
      stroke: none,
      [], [], [#v(-0.4cm)#text(small, "1")], [#v(-0.4cm)#text(small, "2")], [#v(-0.4cm)#text(small, "3")], if lang == "en" {[#v(-0.4cm)#text(small, "Grade")]} else {[#v(-0.4cm)#text(small, "Note")]},
      if lang == "en" or lang == "de" {[#text(large, "Name:")]} else {[#text(large, "Nom:")]
      },
      [#line(start: (0cm, 0.7cm), length:(100%), stroke:(dash:"loosely-dashed"))],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#rect(height:1cm, width:1.2cm, stroke:2pt)],
      [], [], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [],
    )
  } else if nbr-ex == 5 {
    table(
      columns: (2cm, 90%-5.3cm, 1cm, 1cm, 1cm, 1cm, 1.3cm),
      align: center + top,
      stroke: none,
      [], [], [#v(-0.4cm)#text(small, "1")], [#v(-0.4cm)#text(small, "2")], [#v(-0.4cm)#text(small, "3")], [#v(-0.4cm)#text(small, "4")], if lang == "en" {[#v(-0.4cm)#text(small, "Grade")]} else {[#v(-0.4cm)#text(small, "Note")]},
      if lang == "en" or lang == "de" {[#text(large, "Name:")]} else {[#text(large, "Nom:")]
      },
      [#line(start: (0cm, 0.7cm), length:(100%), stroke:(dash:"loosely-dashed"))],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#rect(height:1cm, width:1.2cm, stroke:2pt)],
      [], [], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [],
    )
  } else if nbr-ex == 6 {
    table(
      columns: (2cm, 90%-6.3cm, 1cm, 1cm, 1cm, 1cm, 1cm, 1.3cm),
      align: center + top,
      stroke: none,
      [], [], [#v(-0.4cm)#text(small, "1")], [#v(-0.4cm)#text(small, "2")], [#v(-0.4cm)#text(small, "3")], [#v(-0.4cm)#text(small, "4")], [#v(-0.4cm)#text(small, "5")], if lang == "en" {[#v(-0.4cm)#text(small, "Grade")]} else {[#v(-0.4cm)#text(small, "Note")]},
      if lang == "en" or lang == "de" {[#text(large, "Name:")]} else {[#text(large, "Nom:")]
      },
      [#line(start: (0cm, 0.7cm), length:(100%), stroke:(dash:"loosely-dashed"))],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#rect(height:1cm, width:1.2cm, stroke:2pt)],
      [], [], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [],
    )
  } else if nbr-ex == 7 {
    table(
      columns: (2cm, 90%-7.3cm, 1cm, 1cm, 1cm, 1cm, 1cm, 1cm, 1.3cm),
      align: center + top,
      stroke: none,
      [], [], [#v(-0.4cm)#text(small, "1")], [#v(-0.4cm)#text(small, "2")], [#v(-0.4cm)#text(small, "3")], [#v(-0.4cm)#text(small, "4")], [#v(-0.4cm)#text(small, "5")], [#v(-0.4cm)#text(small, "6")], if lang == "en" {[#v(-0.4cm)#text(small, "Grade")]} else {[#v(-0.4cm)#text(small, "Note")]},
      if lang == "en" or lang == "de" {[#text(large, "Name:")]} else {[#text(large, "Nom:")]
      },
      [#line(start: (0cm, 0.7cm), length:(100%), stroke:(dash:"loosely-dashed"))],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#rect(height:1cm, width:1.2cm, stroke:2pt)],
      [], [], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [],
    )
  } else if nbr-ex == 8 {
    table(
      columns: (2cm, 90%-8.3cm, 1cm, 1cm, 1cm, 1cm, 1cm, 1cm, 1cm, 1.3cm),
      align: center + top,
      stroke: none,
      [], [], [#v(-0.4cm)#text(small, "1")], [#v(-0.4cm)#text(small, "2")], [#v(-0.4cm)#text(small, "3")], [#v(-0.4cm)#text(small, "4")], [#v(-0.4cm)#text(small, "5")], [#v(-0.4cm)#text(small, "6")], [#v(-0.4cm)#text(small, "7")], if lang == "en" {[#v(-0.4cm)#text(small, "Grade")]} else {[#v(-0.4cm)#text(small, "Note")]},
      if lang == "en" or lang == "de" {[#text(large, "Name:")]} else {[#text(large, "Nom:")]
      },
      [#line(start: (0cm, 0.7cm), length:(100%), stroke:(dash:"loosely-dashed"))],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#rect(height:1cm, width:1.2cm, stroke:2pt)],
      [], [], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [],
    )
  } else if nbr-ex == 9 {
    table(
      columns: (2cm, 90%-9.3cm, 1cm, 1cm, 1cm, 1cm, 1cm, 1cm, 1cm, 1cm, 1.3cm),
      align: center + top,
      stroke: none,
      [], [], [#v(-0.4cm)#text(small, "1")], [#v(-0.4cm)#text(small, "2")], [#v(-0.4cm)#text(small, "3")], [#v(-0.4cm)#text(small, "4")], [#v(-0.4cm)#text(small, "5")], [#v(-0.4cm)#text(small, "6")], [#v(-0.4cm)#text(small, "7")], [#v(-0.4cm)#text(small, "8")], if lang == "en" {[#v(-0.4cm)#text(small, "Grade")]} else {[#v(-0.4cm)#text(small, "Note")]},
      if lang == "en" or lang == "de" {[#text(large, "Name:")]} else {[#text(large, "Nom:")]
      },
      [#line(start: (0cm, 0.7cm), length:(100%), stroke:(dash:"loosely-dashed"))],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#rect(height:1cm, width:1.2cm, stroke:2pt)],
      [], [], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [],
    )
  } else if nbr-ex == 10 {
    table(
      columns: (2cm, 90%-10.3cm, 1cm, 1cm, 1cm, 1cm, 1cm, 1cm, 1cm, 1cm, 1cm, 1.3cm),
      align: center + top,
      stroke: none,
      [], [], [#v(-0.4cm)#text(small, "1")], [#v(-0.4cm)#text(small, "2")], [#v(-0.4cm)#text(small, "3")], [#v(-0.4cm)#text(small, "4")], [#v(-0.4cm)#text(small, "5")], [#v(-0.4cm)#text(small, "6")], [#v(-0.4cm)#text(small, "7")], [#v(-0.4cm)#text(small, "8")], [#v(-0.4cm)#text(small, "9")], if lang == "en" {[#v(-0.4cm)#text(small, "Grade")]} else {[#v(-0.4cm)#text(small, "Note")]},
      if lang == "en" or lang == "de" {[#text(large, "Name:")]} else {[#text(large, "Nom:")]
      },
      [#line(start: (0cm, 0.7cm), length:(100%), stroke:(dash:"loosely-dashed"))],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#rect(height:1cm, width:1.2cm, stroke:2pt)],
      [], [], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [],
    )
  }
}
