#import "lib.typ": join
#import "../font-sizes.typ": *

#let default-background(inset, school, year, department, city) = block(
  inset: inset,
  grid(
    rows: (auto, 1fr, auto),
    {
      image("../img/logos-horizontal.jpg")
      v(1em)
      line(length: 100%, stroke: black + 1pt)
    },
    none,
    {
      line(length: 100%, stroke: black + 1pt)
      align(left, par(leading: 0.45em)[
        #department\
        #smallcaps(join(school, [\ ]))\
        #city, #year
      ])
    },
  ),
)

#let frontpage(
  faithful,
  title-font,
  school,
  year,
  title,
  subtitle,
  names,
  department,
  subject,
  city,
  cover-background,
) = {
  let inset = if faithful {
    (left: 60pt, right: 10pt, top: 44pt, bottom: 30pt)
  } else {
    (left: 60pt, right: 60pt, top: 44pt, bottom: 30pt)
  }

  let bg = if cover-background == none {
    default-background(inset, school, year, department, city)
  } else {
    align(center + top, cover-background)
  }
  let custom-background = cover-background != none

  set page(background: bg, margin: (left: 2.25cm, right: 2.25cm, top: 3cm, bottom: 1cm))
  set text(font: title-font)

  [
    #v(52%)

    #huge(weight: "bold", par(leading: 0.45em, title))

    #v(8pt)

    #x-large(subtitle)

    #v(22pt)

    Master's thesis in #subject

    #v(14pt)

    #if faithful {
      upper(x-large(names))
    } else {
      smallcaps(x-large(names))
    }

    #if custom-background [
      #v(1fr)
      #department\
      #smallcaps(join(school, [\ ]))\
      #city, #year
    ]
  ]
}
