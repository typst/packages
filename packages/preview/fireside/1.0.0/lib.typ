#let title_size = 44pt

#let fireside(
  background: rgb("f4f1eb"),
  title: "",
  from_details: none,
  to_details: none,
  margin: 2.1cm,
  vertical_center_level: 2,
  body
) = {
  set page(fill: background, margin: margin)
  set text(font: ("HK Grotesk", "Hanken Grotesk"))

  let body = [
    #set text(size: 11pt, weight: "medium")
    #show par: set block(spacing: 2em)
    #body
  ]

  let header = {
    grid(
      columns: (1fr, auto),
      [
        #set text(size: title_size, weight: "bold")
        #set par(leading: 0.4em)
        #title
      ],
      align(end, box(
        inset: (top: 1em),
        [
          #set text(size: 10.2pt, fill: rgb("4d4d4d"))
          #from_details
        ]
      )),
    )
    v(title_size)
    text(size: 9.2pt, to_details)
    v(title_size)
  }
  
  layout(size => context [
    #let header_sz = measure(block(width: size.width, header))
    #let body_sz = measure(block(width: size.width, body))

    #let ratio = (header_sz.height + body_sz.height) / size.height
    #let overflowing = ratio > 1

    #if overflowing or vertical_center_level == none {
      header
      body
    } else {
      // If no overflow of the first page, we do a bit of centering magic for style
      
      grid(
        rows: (auto, 1fr),
        header,
        box([
          #v(1fr * ratio)
          #body
          #v(vertical_center_level * 1fr)
        ]),
      )
    }
  ])
}
