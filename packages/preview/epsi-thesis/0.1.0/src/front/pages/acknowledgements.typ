#import "../../layout.typ": dict

#let acknowledgements-page(language: "PT", acknowledgements: []) = {
  pagebreak()
  
  heading(outlined: false)[#dict("acknowledgements", lang: language)]

  acknowledgements
}

