//
// Description: Creating nice looking information boxes with different logos
// Author     : Silvan Zahno
//
#import "constants.typ": *
#import "i18n.typ": i18n

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
/// - box-size (length): size of the point boxes
/// -> content
#let exam-header(
  nbr-ex: 5+1,
  pts: 10,
  lang: "en", // "de" "fr"
  box-size: 1cm
) = {
  let cells = ()

  // Create exercice boxes (number, box, points)
  for i in range(1, nbr-ex) {
    let column = (
      text(small, str(i)),
      table.cell(stroke: 1pt)[],
      text(small, [(#pts)])
    )
    cells.push(column)
  }

  let name-label = i18n("exam-name", lang: lang)
  let widths = ()

  // Create grade box
  if nbr-ex > 0 {
    widths = (box-size,) * (nbr-ex - 1)
    let grade-label = i18n("exam-grade", lang: lang)

    widths.push(1.3 * box-size)
    cells.push((
      text(small, grade-label),
      table.cell(stroke: 2pt)[],
      [],
    ))
  }

  // Transpose columns -> rows
  let (labels, boxes, points) = if cells.len() == 0 {
    ((), (), ())
  } else {
    cells.first().zip(..cells.slice(1))
  }

  let columns = (2cm, 90%-widths.sum(default: 0pt), ..widths)

  return {
    v(-0.4cm)
    table(
      columns: columns,
      rows: (0.6cm, box-size, 0.6cm),
      align: (_, y) => center + (bottom, horizon, top).at(y),
      stroke: none,

      // First row
      [], [], ..labels,

      // Second row
      text(large, name-label),
      table.cell(
        inset: (y: 0pt),
        box(
          stroke: (
            bottom: (
              paint: black,
              dash: "loosely-dashed"
            )
          ),
          width: 100%,
          height: 100%,
        )
      ),
      ..boxes,

      // Third row
      [], [], ..points,
    )
  }
}
