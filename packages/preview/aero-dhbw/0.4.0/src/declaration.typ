#let declaration(
  title: [],
  authors: (),
  project: [],
  project-type: [],
  place-of-authorship: [],
  date: [],
  lang: "de"
) = {
  set align(left)

  let plural = authors.len() > 1

  // Localization: language-specific strings assigned here, layout written once.
  let heading-title = ""
  let regulation = []
  let intro = []
  let closing = []
  let date-line = []

  if lang == "en" {
    heading-title = "Declaration of Authorship"
    regulation = [In accordance with Section 1.1.14 of Appendix 1 to §§ 3, 4 and 5 of the Study and Examination Regulations for Bachelor's Degree Programs in the Technical Field of the Baden-Württemberg Cooperative State University dated September 2017, as amended on July 24, 2023.]
    if plural {
      intro = [We hereby declare that we have authored our #project-type #project on the topic:]
      closing = [independently and have used no other sources or aids than those indicated. We also declare that the submitted electronic version corresponds to the printed version.]
    } else {
      intro = [I hereby declare that I have authored my #project-type #project on the topic:]
      closing = [independently and have used no other sources or aids than those indicated. I also declare that the submitted electronic version corresponds to the printed version.]
    }
    date-line = [#place-of-authorship, #datetime.display(date, "[month repr:long] [day], [year]")]
  } else {
    heading-title = "Erklärung"
    regulation = [gemäß Ziffer 1.1.14 der Anlage 1 zu §§ 3, 4 und 5 der Studien- und Prüfungsordnung für die Bachelorstudiengänge im Studienbereich Technik der Dualen Hochschule Baden-Württemberg vom 29.09.2017 in der Fassung vom 24.07.2023.]
    if plural {
      intro = [Wir versichern hiermit, dass wir unsere #project-type #project mit dem Thema:]
      closing = [selbstständig verfasst und keine anderen als die angegebenen Quellen und Hilfsmittel benutzt haben. Wir versichern zudem, dass alle eingereichten Fassungen übereinstimmen.]
    } else {
      intro = [Ich versichere hiermit, dass ich meine #project-type #project mit dem Thema:]
      closing = [selbstständig verfasst und keine anderen als die angegebenen Quellen und Hilfsmittel benutzt habe. Ich versichere zudem, dass alle eingereichten Fassungen übereinstimmen.]
    }
    date-line = [#place-of-authorship, den #datetime.display(date, "[day].[month].[year]")]
  }

  // One shared place/date line, then signatures: a single author signs on a
  // stacked block; multiple authors sign in a two-column grid so they fit on
  // one page.
  let signatures = if authors.len() > 1 {
    v(2em) + grid(
      columns: (1fr, 1fr),
      column-gutter: 2em,
      row-gutter: 2.5em,
      ..authors.map(a => [
        #line(length: 80%, stroke: 0.5pt)
        #v(0.75em)
        #a.name
      ]),
    )
  } else {
    authors.map(a => [

      #v(4em)

      #line(length: 14em, stroke: 0.5pt)

      #v(2em)

      #a.name
    ]).join()
  }

  // Tighter gap before the signatures when they form a grid, so up to 6 fit.
  let date-gap = if authors.len() > 1 { 2.5em } else { 6em }

  set text(lang: lang)
  [
    #heading(heading-title, outlined: false)
    #set par(justify: true)

    #regulation

    #v(2em)
    #intro

    #v(2em)
    #align(center, block(inset: (x: 3em), emph(title)))
    #v(2em)

    #closing

    #v(date-gap)

    #date-line
    #signatures
  ]
}
