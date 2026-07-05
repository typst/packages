#let get-text(it) = {
  if type(it) == str {
    return it
  }
  if type(it) == content {
    if it.has("text") {
      return it.text
    }
    panic("Content must contain field `text`")
  }
  panic("Invalid type `" + type(it) + "`")
}

#let get-svg-image(..args) = image(format: "svg", ..args)

#let get-svg-array(s) = {
  let matches = str(s).matches("</svg>")
  if matches.len() == 0 {
    panic("Cannot find svg images")
  }
  let start = 0
  let svgs = ()
  for match in matches {
    let end = match.end
    svgs.push(s.slice(start, end))
    start = end + 2
  }
  return svgs
}
