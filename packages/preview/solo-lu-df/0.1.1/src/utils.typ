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
  align(center, upper(text(size: 14pt, [
    #university\
    #faculty
  ])))

  v(1fr)

  align(center, upper(text(16pt, weight: "bold", title)))

  v(0.2fr)

  align(center, upper(text(size: 14pt, thesis-type)))

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

#let make-documentary-page(
  title,
  authors,
  advisors,
  reviewer,
  thesis-type,
  date,
) = {
  let vspace = 1fr
  set page(numbering: none)

  let formatted-date = strong(date.display("[day].[month].[year]."))

  heading(level: 1, outlined: false, numbering: none, "Dokumentārā lapa")
  [
    #thesis-type "*#title*" ir
    izstrādāts Latvijas Universitātes Eksakto zinātņu un tehnoloģiju fakultātē,
    Datorikas nodaļā.

    #v(vspace / 3)
    Ar savu parakstu apliecinu, ka darbs izstrādāts patstāvīgi, izmantoti tikai tajā
    norādītie informācijas avoti un iesniegtā darba elektroniskā kopija atbilst
    izdrukai un/vai recenzentam uzrādītajai darba versijai.
  ]

  context {
    set par(
      first-line-indent: 1cm,
      hanging-indent: 1cm,
    )

    v(vspace / 2)

    [
      #if authors.len() > 1 { "Autori: " } else { "Autors: " }
      #authors.map(author => [*#author.name, #author.code*]).join(", ")
      ~ #formatted-date
    ]

    v(vspace)
    [
      Rekomendēju darbu aizstāvēšanai\
      #if advisors.len() > 0 [
        Darba #if advisors.len() > 1 { "vadītāji:" } else { "vadītājs:" }
        #advisors.map(advisor => [*#advisor.title #advisor.name*]).join("\n")
        ~ #formatted-date
      ]
    ]

    v(vspace)
    [Recenzents: *#reviewer.name*]


    v(vspace)
    [
      Darbs iesniegts #formatted-date\
      Kvalifikācijas darbu pārbaudījumu komisijas sekretārs (elektronisks paraksts)
    ]

    v(vspace)
  }
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
