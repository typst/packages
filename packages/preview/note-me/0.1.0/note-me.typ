// From: https://github.com/typst/typst/issues/1939#issuecomment-1680154871
#let colorize(svg, color) = {
  let blk = black.to-hex();
  if svg.contains(blk) { 
    svg.replace(blk, color.to-hex())
  } else {
    svg.replace("<svg ", "<svg fill=\""+color.to-hex()+"\" ")
  }
}

#let color-svg(
  path,
  color, 
  ..args,
) = {
  let data = colorize(read(path), color)
  return image.decode(data, ..args)
}

#let admonition(
  icon: "icons/info.svg",
  color: color.black,
  title: "Admonition",
  children
) = block(
  width: 100%,
  inset: (left: 1.25em, right: .5em, top: .5em, bottom: .5em),
  stroke: (left: 1.75pt + color),
  [
    #stack(
      dir: ltr,
      spacing: 1em,
      align(horizon, color-svg(icon, color, width: 1em, height: 1em)),
      align(horizon, text(weight: "bold", fill: color, title))
    )
    
    #children  
  ],
)

#let note(children) = admonition(
  icon: "icons/info.svg",
  color: rgb(9, 105, 218),
  title: "Note",
  children
)
#let tip(children) = admonition(
  icon: "icons/light-bulb.svg",
  color: rgb(31, 136, 61),
  title: "Tip",
  children
)
#let important(children) = admonition(
  icon: "icons/report.svg",
  color: rgb(130, 80, 223),
  title: "Important",
  children
)
#let warning(children) = admonition(
  icon: "icons/alert.svg",
  color: rgb(154, 103, 0),
  title: "Warning",
  children
)
#let caution(children) = admonition(
  icon: "icons/stop.svg",
  color: rgb(209, 36, 47),
  title: "Caution",
  children
)