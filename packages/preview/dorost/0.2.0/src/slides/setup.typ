#import "../config.typ": default-colors, default-text

// Scoped native page settings; language/direction/fonts stay caller-controlled.
#let slides(body, ratio: "16:9", show-counter: true, footer: none) = {
  if ratio not in ("16:9", "4:3") {
    panic("dorost: slide ratio must be \"16:9\" or \"4:3\"")
  }
  if type(show-counter) != bool {
    panic("dorost: show-counter must be a boolean")
  }
  let footer-content = if footer != none or show-counter { context {
    let start = if text.dir == rtl { right } else { left }
    let end = if text.dir == rtl { left } else { right }
    text(size: 10pt, fill: default-colors.muted, grid(
      columns: (1fr, auto), column-gutter: 1em,
      align(start, if footer != none { footer }),
      align(end, if show-counter { counter(page).display("1") }),
    ))
  } }
  set page(
    width: 320mm, height: if ratio == "16:9" { 180mm } else { 240mm },
    margin: 14mm, header: none, footer: footer-content, numbering: none,
  )
  set text(size: 20pt)
  set par(leading: default-text.leading, spacing: default-text.paragraph-spacing)
  body
}
