#import "../config.typ": default-colors, default-text

// A caller-owned label above its value; gutter separates the two rows.
#let labeled-field(label, value, label-style: "strong", row-gutter: 0em) = {
  if label-style not in ("strong", "muted") {
    panic("dorost: label-style must be \"strong\" or \"muted\"")
  }
  let label = if label-style == "strong" { strong(label) } else {
    text(fill: default-colors.muted, label)
  }
  grid(columns: (1fr,), row-gutter: row-gutter, label, value)
}

// Items are content; selected is a zero-based index. ASCII markers remain
// extractable and do not require a symbol font: (x) selected, ( ) unselected.
#let choice-group(items, selected: none, columns: 1) = {
  if type(items) != array { panic("dorost: choice-group items must be an array of content") }
  if items.any(item => type(item) != content) {
    panic("dorost: choice-group items must be an array of content")
  }
  if type(columns) != int or columns <= 0 {
    panic("dorost: choice-group columns must be a positive integer")
  }
  if selected != none and (type(selected) != int or selected < 0 or selected >= items.len()) {
    panic("dorost: selected must be none or a zero-based item index")
  }
  grid(
    columns: columns, gutter: default-text.list-spacing,
    ..items.enumerate().map(((index, item)) => grid(
      columns: (auto, 1fr), column-gutter: 0.4em,
      text(dir: ltr, if index == selected { [(x)] } else { [( )] }),
      item,
    )),
  )
}
