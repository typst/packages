#import "stick-together.typ": stick-together

// From: https://github.com/typst/typst/issues/1939#issuecomment-1680154871
#let colorize(svg, color) = {
  let blk = black.to-hex();
  if svg.contains(blk) { 
    svg.replace(blk, color.to-hex())
  } else {
    svg.replace("<svg ", "<svg fill=\""+color.to-hex()+"\" ")
  }
}

// Returns a new SVG image loaded from the specified path, filled with the specified color.
#let color-svg-path(
  path,
  color, 
  ..args,
) = {
  let data = colorize(read(path), color)
  return image.decode(data, ..args)
}

// Returns a new SVG image loaded from the specified string (SVG content), filled with the specified color.
#let color-svg-string(
  svg,
  color, 
  ..args,
) = {
  let data = colorize(svg, color)
  return image.decode(data, ..args)
}

#let admonition(
  icon-path: none,
  icon-string: none,
  icon: none,
  title: "Admonition",
  color: color.black,
  foreground-color: auto,
  background-color: none,
  children
) = block(
  width: 100%,
  inset: (left: 1.25em, right: .5em, top: .5em, bottom: .5em),
  stroke: (left: 1.75pt + color),
  fill: background-color,
  [
    #stick-together(
      context stack(
        dir: if (text.dir == auto) { ltr } else { text.dir },
        spacing: 1em,
        align(horizon, {
          assert(
            icon-path != none or
            icon-string != none or
            icon != none,
            message: "Either `icon-path`, `icon-string` or `icon` must be specified in the argument."
          )
          if (icon-path != none) {
             color-svg-path(icon-path, color, width: 1em, height: 1em)
          } 
          if (icon-string != none) {
            color-svg-string(icon-string, color, width: 1em, height: 1em)
          }
          if (icon != none) {
            icon
          }
        }),
        align(horizon, text(weight: "bold", fill: color, title))
      ),
      {
        if (foreground-color == auto) {
          text(children) 
        } else {
          text(fill: foreground-color, children) 
        }
      },
      threshold: 3.175em,
    )
  ],
)

#let note(title: "Note", children) = admonition(
  icon-path: "icons/info.svg",
  title: title,
  color: rgb(9, 105, 218),
  children
)
#let tip(title: "Tip", children) = admonition(
  icon-path: "icons/light-bulb.svg",
  title: title,
  color: rgb(31, 136, 61),
  children
)
#let important(title: "Important", children) = admonition(
  icon-path: "icons/report.svg",
  title: title,
  color: rgb(130, 80, 223),
  children
)
#let warning(title: "Warning", children) = admonition(
  icon-path: "icons/alert.svg",
  title: title,
  color: rgb(154, 103, 0),
  children
)
#let caution(title: "Caution", children) = admonition(
  icon-path: "icons/stop.svg",
  title: title,
  color: rgb(209, 36, 47),
  children
)