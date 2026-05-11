#import "../../layout.typ": dict

#let integrity-page(language: "PT", integrity_content: [], ai_tools_content: []) = {
  pagebreak()
  
  heading(outlined: false)[#dict("integrity", lang: language)]
  
  dict("integrity_statement", lang: language)
  
  v(1em)
  
  integrity_content

  v(2em)

  heading(outlined: false)[#dict("ai_tools", lang: language)]
  
  dict("ai_tools_statement", lang: language)
  
  v(1em)
  
  ai_tools_content
}

