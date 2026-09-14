#import "documentary-page.typ": make-documentary-page

#let merge(a, b) = {
  let result = a
  for (k, v) in b {
    let current = result.at(k, default: none)
    if type(current) == dictionary and type(v) == dictionary {
      result.insert(k, merge(current, v))
    } else {
      result.insert(k, v)
    }
  }
  result
}

#let make-abstract(role, abstract, defaults) = {
  let defaults = merge(
    (
      text: [],
      keywords: [],
    ),
    defaults,
  )

  // Merge defaults with overrides
  let abs = merge(defaults, abstract)

  context [
    #set text(lang: abs.lang)
    #heading(
      level: 1,
      outlined: false,
      numbering: none,
      abs.title,
    )

    // Abstract body text
    #abs.text

    // Keywords
    #par(first-line-indent: 0cm)[ *#abs.keywords-title*: ]
    #abs.keywords.join(", ").
  ]
}

// Display the paper's title and authors at the top of the page,
// spanning all columns (hence floating at the scope of the
// columns' parent, which is the page).
// The page can contain a logo if you pass one with `logo: "logo.png"`.
#let make-title(
  title,
  authors,
  advisors,
  university,
  faculty,
  thesis-type,
  submission-date,
  place,
  logo,
  labels,
) = {
  set par(justify: false)
  align(
    center,
    upper(
      text(
        size: 14pt,
        [
          #university\
          #faculty
        ],
      ),
    ),
  )

  v(1fr)

  align(
    center,
    upper(
      text(
        16pt,
        weight: "bold",
        title,
      ),
    ),
  )

  v(0.2fr)

  align(
    center,
    upper(text(size: 14pt, labels.thesis.label.at(thesis-type))),
  )

  v(1fr)

  // Author information
  context [
    #set par(first-line-indent: 0pt)
    #if authors.len() > 1 {
      labels.title.page.authors.plural
    } else {
      labels.title.page.authors.singular
    }
    #authors.map(author => strong(author.name)).join(", ")

    #if authors.len() > 1 {
      labels.title.page.student_id.prefix.plural
    } else {
      labels.title.page.student_id.prefix.singular
    }
    #labels.title.page.student_id.label: #authors.map(author => author.code).join(",\n")

    #if advisors.len() > 0 [
      #labels.title.page.advisors.prefix #if advisors.len() > 1 {
        [#labels.title.page.advisors.plural\ ]
      } else {
        labels.title.page.advisors.singular
      }
      #advisors.map(advisor => [#advisor.title #advisor.name]).join("\n")
    ]
  ]

  v(0.5fr)

  align(center, upper([#place #submission-date.year()]))
}
