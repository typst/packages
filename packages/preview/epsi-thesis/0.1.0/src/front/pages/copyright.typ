#import "../../layout.typ": dict

#let copyright-page(language: "PT", copyright-content: []) = {
  pagebreak()
  
  heading(outlined: false)[#dict("copyright", lang: language)] 
  
  dict("copyright_statement", lang: language)

  v(1em)
  
  copyright-content
  
}

