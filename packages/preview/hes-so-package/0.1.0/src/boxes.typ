//
// Description: Creating nice looking information boxes with different logos
// Author     : Silvan Zahno
//
#import "constants.typ": *

/// Display some content with specific text style options
///
/// - type (str, none): target type
/// - size (length): font size
/// - style (str): font style
/// - fill (color, gradient, tiling): text color
/// - body (content): the text to display
/// -> content
#let option-style(
  type-to-display: none,
  type-of-doc: none,
  size: small,
  style: "italic",
  fill: colors.gray-40,
  body
) = {[
  #if type-to-display != none or type-of-doc != none {
    text(size:size, style:style, fill:fill)[#body]
  } else {
    if type-to-display == type-of-doc {
      text(size:size, style:style, fill:fill)[#body]
    }
  }
]}

/// Display a TODO box
/// 
/// A `<todo>` label is attached to the box for querying
///
/// - body (content): the TODO's description
/// -> content
#let todo(body) = [
  #let rblock = block.with(
    stroke: red,
    radius: 0.5em,
    fill: red.lighten(80%)
  )
  #let top-left = place.with(
    top + left,
    dx: 1em,
    dy: -0.35em
  )
  #block(
    inset: (top: 0.35em),
    {
      rblock(
        width: 100%,
        inset: 1em,
        body
      )
      top-left(
        rblock(
          fill: white,
          outset: 0.25em,
          text(fill: red)[*TODO*]
        )
      )
    }
  )
  #metadata((body: body))
  <todo>
]

/// Display a title in a box (with an optional subtitle)
///
/// - width (length, ratio): width of the box
/// - radius (length, ratio): corner radius of the box
/// - border (length): thickness of the box border
/// - inset (length): padding around the content
/// - outset (length): extra padding not affecting layout
/// - linecolor (color): box border color
/// - titlesize (length): font size of the title
/// - subtitlesize (length): font size of the subtitle
/// - title (content): the title
/// - subtitle (content, none): the subtitle
/// -> content
#let titlebox(
  width: 100%,
  radius: 10pt,
  border: 1pt,
  inset: 20pt,
  outset: -10pt,
  linecolor: colors.box.border,
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

/// Display some content in a box with an icon on the left
///
/// - width (length, ratio): width of the box
/// - radius (length, ratio): corner radius of the box
/// - border (length, stroke): thickness of the box border
/// - inset (length): padding around the content
/// - outset (length): extra padding not affecting layout
/// - linecolor (color): box border color
/// - icon (path, string): icon to display
/// - iconheight (length): height of the icon
/// - body (content): the body
/// -> content
#let iconbox(
  width: 100%,
  radius: 4pt,
  border: 4pt,
  inset: 10pt,
  outset: -10pt,
  linecolor: colors.code.border,
  icon: none,
  iconheight: 1cm,
  body
) = {
  if body != none {
    align(left,
      rect(
        stroke: (left:linecolor+border, rest:colors.code.border+0.1pt),
        radius: (left:0pt, right:radius),
        fill: colors.code.bg,
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
  linecolor: colors.icon.info,
  icon: icons.info,
)

#let warningbox = iconbox.with(
  linecolor: colors.icon.warning,
  icon: icons.warning,
)

#let ideabox = iconbox.with(
  linecolor: colors.icon.idea,
  icon: icons.idea
)

#let firebox = iconbox.with(
  linecolor: colors.icon.fire,
  icon: icons.fire,
)

#let importantbox = iconbox.with(
  linecolor: colors.icon.important,
  icon: icons.important,
)

#let rocketbox = iconbox.with(
  linecolor: colors.icon.rocket,
  icon: icons.rocket,
)

#let todobox = iconbox.with(
  linecolor: colors.icon.todo,
  icon: icons.todo,
)

#let thinkbox = iconbox.with(
  linecolor: colors.icon.think,
  icon: icons.think,
)

#let helpbox = iconbox.with(
  linecolor: colors.icon.help,
  icon: icons.help,
)

/// Display a colored box with some content and a title in the corner
///
/// - title (content): the box title
/// - color (color): box color
/// - stroke (stroke): box border stroke
/// - radius (length): box corner radius
/// - width (length, ratio, auto): box width
/// - body (content): the body
/// -> content
#let colorbox(
  title: "title",
  color: colors.icon.todo,
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

/// Display a bookmark-like slanted box with some text
///
/// - color (color): background color
/// - body (content): the body
/// -> content
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

/// Display a colorbox with slanted-background for the title
/// -> content
#let slanted-colorbox(
  title: "title",
  color: colors.icon.todo,
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

/// Display an exam header table to mark exercise scores
///
/// - nbr-ex (int): number of exercises
/// - pts (int): total number of points
/// - lang (str): display language
/// -> content
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
