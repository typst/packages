#import "tokens.typ": tokens

#let page-border-styles(page-border, doc) = {
  let blue-frame = if page-border {
    rect(
      width: 100%,
      height: 100%,
      stroke: (
        paint: tokens.colour.main,
        thickness: 16pt,
        cap: "round",
      ),
    )
  } else { none }

  set page(paper: "a4", margin: tokens.margin, background: blue-frame)

  doc
}
