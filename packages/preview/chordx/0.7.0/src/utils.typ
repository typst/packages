// Gets the relative scale from a size of length type
#let size-to-scale(size, default) = {
  let length-type = repr(size).match(regex("pt|mm|cm|in|em")).text

  if length-type == "em" {
    size.em
  } else {
    size / default
  }
}

// Gets the string from a content data
#let parse-content(content-data) = {
  if content-data.has("text") {
    return content-data.at("text").codepoints()
  }
  if content-data.has("double") {
    return (content-data,)
  }
  if content-data.has("children") {
    for item in content-data.at("children") {
      parse-content(item)
    }
  }
  if content-data.has("body") {
    parse-content(content-data.at("body"))
  }
  if content-data.has("base") {
    parse-content(content-data.at("base"))
  }
  if content-data.has("equation") {
    parse-content(content-data.at("equation"))
  }
}

// Checks if the string contains only numbers
#let has-number(string) = {
  if string.trim().matches(regex("^\d+$")).len() != 0 {
    true
  } else {
    false
  }
}

// Parses different string inputs to array
//
// 123|234 == 1,2,3 | 2,3,4 => ((1,2,3), (2,3,4))
// "x32o1o" == x,3,2,o,1,o => ("x",3,2,"o",1,"o")
#let parse-input-string(string) = {
  let to-int-or-ignore(s) = {
    if s.matches(regex("^\d+$")).len() != 0 {int(s)} else {s}
  }

  string = string.trim().replace(regex("\s"), "")

  if string.contains("|") {
      string.split("|").map(parse-input-string)
  } else if string.contains(",") {
      string.split(",").map(to-int-or-ignore)
  } else {
      string.codepoints().map(to-int-or-ignore)
  }
}

// Draws a border with sharp corners
#let top-border-sharp(size, stroke, scale) = {
  place(
    dy: -size.height,
    rect(
      width: size.width,
      height: size.height,
      stroke: stroke,
      fill: black
    )
  )
}

// Draws a border with round corners
#let top-border-round(size, stroke, scale, radius) = {
  // radius
  let r = radius
  // Bézier control segment
  let n = 4 / 3 * r * calc.tan(90deg / 4)

  place(
    dy: r - size.height,
    curve(
      fill: black,
      stroke: stroke,
      curve.move((0pt, 0pt)),
      curve.cubic((0pt, -n), (r - n, -r), (r, -r), relative: true),
      curve.line((size.width - r * 2, 0pt), relative: true),
      curve.cubic((n , 0pt), (r, n), (r, r), relative: true),
      curve.line((0pt, size.height), relative: true),
      curve.cubic((0pt, -n), (-n , -r), (-r, -r), relative: true),
      curve.line((r * 2 - size.width, 0pt), relative: true),
      curve.cubic((-n, 0pt), (-r, n), (-r, r), relative: true),
      curve.line((0pt, -size.height), relative: true),
      curve.close()
    )
  )
}

#let total-bounds(b1, b2) = {
  let dx = calc.min(b1.dx, b2.dx)
  let dy = calc.min(b1.dy, b2.dy)

  return (
    dx: dx,
    dy: dy,
    width: calc.max(b1.dx + b1.width, b2.dx + b2.width) - dx,
    height: calc.max(b1.dy + b1.height, b2.dy + b2.height) - dy
  )
}

#let set-default-arguments(args) = {
  let size = 12pt
  let font = "Libertinus Serif"

  if "size" in args.keys() {
    (size,) = args
  }

  if "font" in args.keys() {
    (font,) = args
  }

  return (
    ..args,
    size: size,
    font: font
  )
}
