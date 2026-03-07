#import "tum-colors.typ": tum-colors
#import "tum-logo.typ": draw-tum-logo
#import "university-names.typ": tum-name

#let tum-logo-height = 10mm

#let three-liner-headline-with-logo(author-info, origin) = [
  #let three-liner-headline(author-info) = [
    #set text(fill: tum-colors.blue, size: 2.9mm)
    #author-info.group-name\
    #author-info.school-name\
    #tum-name.english
  ]

  #grid(
    columns: (1fr, auto),
    gutter: tum-logo-height,
    [#three-liner-headline(author-info)],
    [#draw-tum-logo(tum-logo-height, origin: origin)],
  )]

#let two-liner-headline-with-logo(author-info, origin) = [
  #let two-liner-headline(author-info) = [
    #set text(fill: tum-colors.blue, size: 2.9mm)
    #author-info.school-name\
    #tum-name.german
  ]

  #grid(
    columns: (1fr, auto),
    gutter: tum-logo-height,
    [#two-liner-headline(author-info)],
    [#draw-tum-logo(tum-logo-height, origin: origin)],
  )]
