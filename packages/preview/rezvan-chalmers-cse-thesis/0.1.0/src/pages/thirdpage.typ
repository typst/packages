#import "lib.typ": join
#import "../font-sizes.typ": *

#let thirdpage(faith, school, year, title, subtitle, authors, department, city, titlepage-logo) = {
  set page(margin: (left: 2.25cm, right: 2.25cm, top: 3cm, bottom: 3cm))

  align(center + horizon,
    grid(
      rows: (auto, 1fr, auto),
      large(smallcaps[#("Master's Thesis " + str(year))]),
      {
        v(-2cm)
        x-large(weight: "semibold", title)
        v(10pt)
        large(subtitle)
        v(24pt)
        if faith {
          large(upper(authors))
        } else {
          large(smallcaps(authors))
        }
      },
      [
        #if titlepage-logo == none {
          image("../img/logos-vertical.png", width: 26%)
        } else {
          titlepage-logo
        }
        #v(5mm)
        #department\
        #smallcaps(join(school, [\ ]))\
        #city, #year
      ],
    ),
  )
}
