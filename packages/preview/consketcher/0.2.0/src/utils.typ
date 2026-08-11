// font style
// chinese text
#let ctext(
  label,
  size: .8em,
  font: "Songti SC",
  ..options,
) = text(
  label,
  size: size,
  font: font,
  ..options,
)

#let label-length(body, fallback: 1) = if body == none {
  fallback
} else if type(body) == content {
  body.body.children.len()
} else if type(body) == str {
  body.len()
} else {
  fallback
}

#let auto-gap(body, scale: 1, fallback: 1) = {
  let measured = label-length(body, fallback: fallback) * scale
  if measured < fallback {
    fallback
  } else {
    measured
  }
}
