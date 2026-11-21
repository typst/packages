#import "config.typ": spacing-state

#let linked-text(value, link-prefix: "", text: "") = {
  if value != "" {
    let display = if text != "" { text } else { value }
    if link-prefix != "" {
      link(link-prefix + value)[#display]
    } else {
      display
    }
  }
}

#let header-block(body, spacing) = context {
  let s = spacing-state.get()
  if spacing == auto {
    block(
      width: 100%,
      above: s.at("block-spacing"),
      below: s.at("item-spacing"),
      body,
    )
  } else {
    block(width: 100%, spacing: spacing, body)
  }
}

#let generic-two-by-two(
  top-left: "",
  top-right: "",
  bottom-left: "",
  bottom-right: "",
  spacing: auto,
) = header-block(
  [
    #top-left #h(1fr) #top-right \
    #bottom-left #h(1fr) #bottom-right
  ],
  spacing,
)

#let generic-one-by-two(
  left: "",
  right: "",
  spacing: auto,
) = header-block([#left #h(1fr) #right], spacing)

#let dates-helper(
  start-date: "",
  end-date: "",
) = {
  if start-date == "" {
    end-date
  } else {
    start-date + " " + sym.dash.en + " " + end-date
  }
}
