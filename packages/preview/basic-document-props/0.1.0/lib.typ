#let simple-page(author, mail, body, middle-text: "", date: true, numbering: true, supress-mail-link: false) = {
  set text(lang: "de")
  set par(justify: true)
  set text(font: "STIX Two Text")
  set document(author: author)
  set page(footer: context [
    #if (supress-mail-link) [
      #mail
    ] else [
      #link("mailto:" + mail)[#mail]
    ]
    #h(1fr)
    #if numbering {
      counter(page).display(
        "1 von 1",
        both: true,
      )
    }
  ], header: context [
    #author
    #h(1fr)
    #middle-text
    #h(1fr)
    #datetime.today().display("[day].[month].[year]")
  ], margin: (left: 2cm, right: 2cm, bottom: 3cm, top: 3cm))
  show: body
}
