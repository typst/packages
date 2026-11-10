#import "../../layout.typ": dict

#let funding-page(language: "PT", funding: []) = {
  pagebreak()
  
  heading(outlined: false)[#dict("funding", lang: language)]

  funding
}

