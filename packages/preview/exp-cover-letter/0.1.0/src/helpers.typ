#let linked-text(value, link-prefix: "", text: "") = {
  if value != "" {
    let display = if text != "" {
      text
    } else {
      value
    }

    if link-prefix != "" {
      link(link-prefix + value)[#display]
    } else {
      display
    }
  }
}
