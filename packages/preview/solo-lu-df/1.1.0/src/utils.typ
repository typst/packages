#import "documentary-page.typ": get-thesis-label, make-documentary-page


#let merge(a, b) = {
  let result = a
  for (k, v) in b { result.at(k) = v }
  result
}

#let make-abstract(role, abstract) = {
  // Define role-based defaults
  let defaults = if role == "primary" {
    (
      lang: "lv",
      title: "Anotācija",
      keyword-title: "Atslēgvārdi",
      text: [],
      keywords: [],
    )
  } else {
    (
      lang: "en",
      title: "Abstract",
      keyword-title: "Keywords",
      text: [],
      keywords: [],
    )
  }

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
    #par(first-line-indent: 0cm)[ *#abs.keyword-title*: ]
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
  date,
  place,
  logo,
) = {
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

  align(center, upper(text(size: 14pt, get-thesis-label(thesis-type))))

  v(1fr)

  // Author information
  context [
    #set par(first-line-indent: 0pt)
    #if authors.len() > 1 { "Autori:" } else { "Autors:" }
    #authors.map(author => strong(author.name)).join(", ")

    #if authors.len() > 1 { "Studentu" } else { "Studenta" }
    apliecības Nr.: #authors.map(author => author.code).join(", ")

    #if advisors.len() > 0 [
      Darba #if advisors.len() > 1 { "vadītāji:" } else { "vadītājs:" }
      #advisors.map(advisor => [#advisor.title #advisor.name]).join("\n")
    ]
  ]

  v(0.5fr)

  align(center, upper([#place #date.year()]))
}

#let make-attachments(title, attachments) = {
  if attachments == () {
    return
  }
  heading(level: 1, title, numbering: none)

  for (i, att) in attachments.enumerate() {
    let content = att.content
    let caption = att.caption
    let user-label = att.label

    let final-label = if user-label != none {
      user-label
    } else {
      label("attachment-" + str(i + 1))
    }

    [#figure(
        content,
        caption: caption,
        kind: "attachment",
        supplement: "pielikums",
      )
      #final-label
    ]
  }
}
