// Gets the string from a content data
#let parse-content(content) = {
  if content.has("text") {
    return content.at("text").codepoints()
  }
  if content.has("double") {
    return (content,)
  }
  if content.has("children") {
    for item in content.at("children") {
      parse-content(item)
    }
  }
  if content.has("body") {
    parse-content(content.at("body"))
  }
  if content.has("base") {
    parse-content(content.at("base"))
  }
  if content.has("equation") {
    parse-content(content.at("equation"))
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

// Draws a border with right angles
#let top-border-normal(size, stroke, scale) = {
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

// Draws a border with round angles
#let top-border-round(size, stroke, scale) = {
  let bezier-radius = 0.5519150244935105707435627pt * scale
  let radius = 1pt * scale

  place(
    path(
      fill: black,
      stroke: stroke,
      closed: true,
      ((0pt, -0.2pt * scale), (0pt, bezier-radius)),
      ((radius, -size.height), (-bezier-radius, 0pt)),
      ((size.width - radius, -size.height), (-bezier-radius, 0pt)),
      ((size.width, -0.2pt * scale), (0pt, -bezier-radius)),
      ((size.width, radius), (0pt, bezier-radius)),
      ((size.width - radius, 0pt), (bezier-radius, 0pt)),
      ((radius, 0pt), (bezier-radius, 0pt)),
      ((0pt, radius), (0pt, -bezier-radius)),
    )
  )
}
