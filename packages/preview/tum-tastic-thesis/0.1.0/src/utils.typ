#import "page-conf.typ": content-page-margins, first-line-indent, tum-page
#import "tum-font.typ": font-sizes

#let check-keys(error-preamble, expected-keys, dict) = {
  for key in expected-keys [
    #if key not in dict {
      let error-msg = "[" + error-preamble + "] Missing required key: " + key
      panic(error-msg)
    }
  ]
}

#let format-title-section-before-chapters(title: [Title]) = [
  #set heading(numbering: none)

  #show heading.where(level: 1): it => {
    set text(size: font-sizes.h1)
    v(2em)
    strong(it)
    v(1em)
  }

  = #title
]

#let print-section-before-chapters(title: [Title], body) = [
  // --------------  Sets  --------------
  #set text(size: font-sizes.base)

  #let margins = content-page-margins
  #set page(
    paper: tum-page.type,
    margin: margins,
  )

  #set par(justify: true, first-line-indent: first-line-indent)
  // -------------- Content --------------

  #format-title-section-before-chapters(title: title)
  #body
]
