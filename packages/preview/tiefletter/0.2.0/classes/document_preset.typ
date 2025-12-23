/// Base document preset with optional banner and three-part footer.
/// Parameters:
/// - footer-left/footer-middle/footer-right: content blocks or none
/// - banner-image: optional element placed at top
/// - body: content to render in the document
#let document-preset(
  footer-left: none,
  footer-middle: none,
  footer-right: none,
  banner-image: none,
  body,
) = {
  context {
    let has-footer = footer-left != none or footer-middle != none or footer-right != none

    set page(
      paper: "a4",
      margin: (top: 2cm, right: 2cm, bottom: if has-footer { 3.5cm } else { 2cm }, left: 2cm),
      footer-descent: 0.5cm,
      footer: context {
        set text(size: 9pt)
        if has-footer {
          box(width: 100%, inset: 10pt, grid(
            align: center,
            columns: 3,
            if footer-left != none {
              box(width: 1fr, align(center, footer-left))
            },
            grid.vline(stroke: 0.3pt),
            if footer-middle != none {
              box(width: 1fr, align(center, footer-middle))
            },
            grid.vline(stroke: 0.3pt),
            if footer-right != none {
              box(width: 1fr, align(center, footer-right))
            },
          ))
        }
      },
    )

    set text(font: "Cormorant Garamond", number-type: "lining", size: 12pt)

    context {
      box(width: page.width, place(top + left, dx: -here().position().x, dy: -here().position().y, [
        #banner-image
      ]))
    }

    [#body]
  }
}
