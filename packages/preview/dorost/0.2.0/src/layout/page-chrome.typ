#import "../config.typ": default-colors

#let page-chrome(body, header: none, footer: none, numbering: true, rule: true) = {
  if type(numbering) != bool { panic("dorost: numbering must be a boolean") }
  if type(rule) != bool { panic("dorost: rule must be a boolean") }
  let header-content = if header != none { context {
    let start = if text.dir == rtl { right } else { left }
    align(start)[
      #header
      #if rule { line(length: 100%, stroke: 0.5pt + default-colors.rule) }
    ]
  } }
  let footer-content = if footer != none or numbering { context {
    let start = if text.dir == rtl { right } else { left }
    let end = if text.dir == rtl { left } else { right }
    if rule { line(length: 100%, stroke: 0.5pt + default-colors.rule) }
    grid(
      columns: (1fr, auto), column-gutter: 1em,
      align(start, if footer != none { footer }),
      align(end, if numbering { counter(page).display("1") }),
    )
  } }
  set page(header: header-content, footer: footer-content, numbering: if numbering { "1" })
  body
}
