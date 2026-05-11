#import "../../layout.typ": dict

#let copyright-page(language: "PT", copyright_content: []) = {
  pagebreak()
  
  heading(outlined: false)[#dict("copyright", lang: language)] 
  
  dict("copyright_statement", lang: language)

  v(1em)
  
  copyright_content
  
}

