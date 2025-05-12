#import "../translations.typ": translations

#let create_declaration_of_independent_processing(
  authors: (),
  title: none,
  place: none,
  date: none,
  lang: "en"
) = {
  // Localization
  let t = translations.at(if lang in translations.keys() { lang } else { "en" })
  heading(
    outlined: true,
    numbering: none,
    bookmarked: true,
    text(t.at("declaration_of_independent_processing")),
  )
  
  // Choose the correct declaration content based on the number of authors
  if authors.len() <= 1 {
    // Single author declaration
    text(t.at("declaration_of_independent_processing_content_single"))
  } else {
    // Multiple authors declaration
    text(t.at("declaration_of_independent_processing_content_group"))
  }

  v(40pt)

  // Create signature lines for each author
  if authors.len() <= 1 {
    // Single author or no author specified
    // Display author name if it exists
    if authors.len() == 1 {
      grid(
        columns: (1fr, 2fr),
        [#text(size: 1.15em, weight: "bold", authors.at(0))],
        [],
      )
      v(5pt)
    }
    
    // Reordered columns: Name, Place, Date, Signature
    grid(
      columns: 4,
      gutter: 10pt,
      line(length: 85pt, stroke: 1pt),
      line(length: 85pt, stroke: 1pt), 
      line(length: 85pt, stroke: 1pt),
      line(length: 85pt, stroke: 1pt),
      align(center, text(t.at("name"), size: 9pt)),
      align(center, text(t.at("city"), size: 9pt)),
      align(center, text(t.at("date"), size: 9pt)),
      align(center, text(t.at("signature"), size: 9pt)),
    )
  } else {
    // Multiple authors
    for author in authors {
      grid(
        columns: (1fr, 2fr),
        [#text(size: 1.15em, weight: "bold", author)],
        [],
      )
      
      // Reordered columns: Name, Place, Date, Signature
      grid(
        columns: 4,
        gutter: 10pt,
        line(length: 85pt, stroke: 1pt),
        line(length: 85pt, stroke: 1pt),
        line(length: 85pt, stroke: 1pt),
        line(length: 85pt, stroke: 1pt),
        align(center, text(t.at("name"), size: 9pt)),
        align(center, text(t.at("city"), size: 9pt)), 
        align(center, text(t.at("date"), size: 9pt)),
        align(center, text(t.at("signature"), size: 9pt)),
      )
      
      v(20pt)
    }
  }
}