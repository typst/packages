#import "private.typ": *
#import "pigments.typ": *
#import "text-contrast.typ": get-contrast-color

/// View a single color pigment on a page
///
/// - color ():
/// ->
#let view-pigment(color) = {
  set page(..pigmentpage)
  counter(page).update(1)
  set text(size: 16pt, black, font: "Libertinus Serif")
  set grid(gutter: 2em)

  align(center + horizon)[
    #if type(color) != "color" {
      pigment(red)[
        #raw("Error: Not a color.") \ \
        #raw("Use `view-pigments()`") \
        #raw("for pigment groups.") \ \
        #raw("Use `rgb(\"#000000\")`") \
        #raw("to enter HEX codes.")
      ]
    } else {
      rect(
        height: 60%,
        width: 80%,
        radius: 25pt,
        fill: color,
        text(
          fill: get-contrast-color(color),
          size: 4em,
          weight: "bold",
          raw(upper(color.to-hex())),
        ),
      )
    }
  ]
}

#let get-pigments-to-display(list) = {
  if type(list) == "dictionary" {
    for i in list {
      if (type(i.at(1)) == "color") {
        let name = i.at(0)
        let color = i.at(1)
        block(
          ..colorbox-block-properties,
          stroke: 2pt + color,
          stack(
            spacing: 5mm,
            rect(..colorbox, fill: color),
            name,
            raw(upper(color.to-hex())),
          ),
        )
      } else {
        block(
          ..colorbox-block-properties,
          stack(
            rect(
              radius: 100%,
              width: 100%,
              stroke: 1pt + black,
              pad(
                y: 8mm,
                align(center)[ #pigment(black, i.at(0))],
              ),
            ),
          ),
        )
        get-pigments-to-display(i.at(1))
      }
    }
  } else {
    pigment(red)[
      #colbreak()
      #align(horizon)[
        #raw("Error: The selected item is not a valid pigment group.")
      ]
    ]
  }
}

/// Show a visual list of colors to select from
///
/// - pigment-group (): Pigment group
/// ->
#let view-pigments(pigment-group) = {
  set page(..pigmentpage, columns: 3)
  counter(page).update(1)
  set text(size: 16pt, black, font: "Libertinus Serif")
  set grid(gutter: 2em)

  get-pigments-to-display(pigment-group)
}

/// Wrapper function for attaching pigments only
///
/// ->
#let show-pigmentpedia() = {
  view-pigments(pigmentpedia)
}

