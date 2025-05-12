#import "../translations.typ": translations

#let create_abstract_page(
  abstract: none,
  keywords: (),
  lang: "en",
  title: none,
  authors: ()
) = {
  // Localization
  let t = translations.at(if lang in translations.keys() { lang } else { "en" })
  
  // Add heading for the abstract - changed outlined to true
  heading(t.at("abstract"), numbering: none, outlined: true)

  set par(justify: true)

  stack(
    spacing: 10mm,
    
    // Add title and author(s) before keywords
    if title != none {
      text(size: 14pt, weight: "bold", title)
    },
    
    if authors.len() > 0 {
      let formatted_authors = if authors.len() == 1 { 
        authors.at(0) 
      } else { 
        authors.join(", ", last: " & ") 
      }
      text(size: 12pt, weight: "bold", formatted_authors)
    },
    
    // Keywords section
    if keywords.len() > 0 {
      stack(
        spacing: 6mm,
        text(weight: "bold", t.at("keywords")),
        {
          let keywords_text = if type(keywords) == str {
            keywords
          } else if keywords.len() == 0 {
            ""
          } else {
            keywords.join(", ")
          }
          keywords_text
        }
      )
    },
    
    // Abstract text
    abstract
  )
}