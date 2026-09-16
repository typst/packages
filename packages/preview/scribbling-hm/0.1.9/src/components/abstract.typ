#import "../utils.typ": *

#let abstract-page(
  abstract: none,
  abstract-translation: none,
) = {  
  context {
    if text.lang == "en" {
      heading("Abstract")
      text(if abstract != none { abstract } else { todo[Abstract] })
      
    } else if text.lang == "de" {
      heading("Zusammenfassung")
      text(if abstract != none { abstract } else { todo[Zusammenfassung] })
      
      if abstract-translation != none {
        heading("Abstract")
        text(abstract-translation)
      }
    }
  }
}