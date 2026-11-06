#import "./fonts.typ": thesis_font_size, thesis_font

#let header(
  stroke: 0.5pt,
  spacing: 0.5em,
  font: thesis_font.times,
  size: thesis_font_size.tiny,
  left: none,
  right: none,
  center: none,
) = {
  set text(font: font, size: size)
  context {
    let loc = here()
    if not (query(<mzt:no-header-footer>).filter(el => el.location().page() == loc.page()) != ()) {
      if not (query(<mzt:no-header>).filter(el => el.location().page() == loc.page()) != ()) {
        let page_left = left
        let page_right = right
        if calc.even(loc.page()) {
          page_left = none
        } else {
          page_right = none
        }
        stack(
          spacing: spacing,
          grid(
            columns: (auto, 1fr, auto),
            align: (alignment.left, alignment.center, alignment.right),
            page_left, center, page_right,
          ),
          // line(length: 100%, stroke: stroke),
        )
      }
    }
  }
}

#let footer(left: none, right: none, center: none) = context {
  let loc = here()
  if not (query(<mzt:no-header-footer>).filter(el => el.location().page() == loc.page()) != ()) {
    let fleft(numbering) = {
      if type(left) == function {
        left(numbering)
      } else {
        left
      }
    }
    let fcenter(numbering) = {
      if type(center) == function {
        center(numbering)
      } else {
        center
      }
    }
    let fright(numbering) = {
      if type(right) == function {
        right(numbering)
      } else {
        right
      }
    }
    context [
      #set text(thesis_font_size.normal)
      #let page-numbering = page.numbering
      #if page-numbering == none {
        page-numbering = "1"
      }
      #let numbering = counter(page).display(page-numbering)
      #grid(
        columns: (1fr, 1fr, 1fr),
        align: (alignment.left, alignment.center, alignment.right),
        fleft(numbering), fcenter(numbering), fright(numbering),
      )
    ]
  }
}
