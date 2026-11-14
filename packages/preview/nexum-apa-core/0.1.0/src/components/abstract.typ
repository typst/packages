// Abstract and keyword page.
#let make-abstract(
  body,
  keywords: (),
  heading-title: [Abstract],
  keywords-label: [Keywords:],
) = [
  #heading(level: 1)[#heading-title]
  #block[
    #set par(first-line-indent: 0pt)
    #body
  ]
  #if keywords.len() > 0 [
    #block[
      #set par(first-line-indent: 0.5in)
      #emph[#keywords-label]
      #h(0.25em)
      #keywords.join(", ")
    ]
  ]
]
