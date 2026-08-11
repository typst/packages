#import "author-info.typ": check-author-info
#import "tum-colors.typ": tum-colors
#import "tum-font.typ": font-sizes
#import "page-conf.typ": cover-page-margins, tum-page
#import "tum-header.typ": three-liner-headline-with-logo, tum-logo-height

#let print-cover(
  author-info: (
    name: "Your Name Here",
    group-name: "Your Group Or Chair Here",
    school-name: "Your School Here",
  ),
  title: [Your Title Here],
  subtitle: none,
  cover-image: none,
) = [
  // -------------- Checks --------------
  #check-author-info(author-info)

  // --------------  Sets  --------------
  #let margins = cover-page-margins
  #set page(
    paper: tum-page.type,
    header: three-liner-headline-with-logo(author-info, bottom + left),
    margin: margins,
  )

  // -------------- Content --------------
  #let make_title = (my-title, subtitle: none) => [
    #v(tum-logo-height)
    #text(size: font-sizes.h1, weight: "bold")[
      #align(left)[#my-title]
    ]

    #v(0.8em)
    #if subtitle != none {
      set text(size: font-sizes.h2)
      subtitle
    }
    #v(6em)
    #text(
      size: font-sizes.h2,
      fill: tum-colors.blue,
      weight: "bold",
    )[#author-info.name]
  ]

  #make_title(title, subtitle: subtitle)

  #let content-height = tum-page.height - margins.top - margins.bottom
  #let content-width = tum-page.width - margins.left - margins.right
  #let half-page = 0.5 * content-height

  #if cover-image != none {
    let tum-cover-image = align(right)[
      #set image(width: 0.6 * content-width, height: 0.5 * content-height)
      #cover-image
    ]

    place(top + left, dx: 0pt, dy: content-height / 2, box(
      height: half-page,
      width: content-width,
    )[
      #place(bottom + right, tum-cover-image)
    ])
  }

]

#print-cover()
#print-cover(subtitle: [Subtitle goes here]))
