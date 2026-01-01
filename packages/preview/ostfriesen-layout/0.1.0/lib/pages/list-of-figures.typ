#import "../translations.typ": translations

#let create-list-of-figures(title: "List of Figures", lang: "en") = {
  // Localization
  let t = translations.at(if lang in translations.keys() { lang } else { "en" })
  
  // Wrap the query in a context expression
  context {
    if query(figure.where(kind: image)).len() > 0 {
      heading(title, numbering: none, outlined: true)
      outline(
        title: none, 
        indent: auto,
        target: figure.where(kind: image),
      )
    }
  }
}
