// Copyright (C) 2025 Adam McKellar
//
// This source code is licensed under the Unlicense license.


/// This function creates the a title page that fulfills the requirements
/// that the Institut für Informatik of Heidelberg University has for a bachelor or master thesis.
#let cs-thesis-cover(
  /// Your name [string]
  author: "Max Mustermann",
  /// Your matriculation number (Matrikelnummer) [string]
  matriculation-number: "12345678",
  /// What your thesis is (bachelor/master) [string]
  thesis-type: "Bachelor-Arbeit",
  /// The title of your thesis [string]
  title: "What are ducks?",
  /// Your university [string]
  university: "Universität Heidelberg",
  /// Your institute [string]
  institute: "Institut für Informatik",
  /// The working group that supervises your thesis [string]
  working-group: "Duck Feather Laboratory",
  /// Your supervisor [string]
  supervisor: "Professor Einstein",
  /// The date of your submission [anything]
  date-submission: [#datetime.today().display()],
  /// Language of your thesis ["en" OR "de"]
  language: "de",
) = {
  let error-message-lang = block(
    fill: red,
    inset: 2pt,
  )[Unsupported language "#language". Supported languages "de", "en".]

  [
    #set page(numbering: none)

    #set align(center + top)
    #set text(size: 18pt)

    #university \
    #institute \
    #working-group

    #v(20%)

    #text(size: 11pt)[#thesis-type]\
    #text(size: 26pt)[#title]

    #set align(left + bottom)
    #set text(size: 12pt)

    #if language == "de" [
      #grid(
        align: left,
        columns: 2,
        inset: 8pt,
        rows: (auto, 20pt),
        "Name:", author,
        "Matrikelnummer:", matriculation-number,
        "Betreuer:", supervisor,
        "Datum der Abgabe:", date-submission,
      )
    ] else if language == "en" [
      #grid(
        align: left,
        columns: 2,
        inset: 8pt,
        rows: (auto, 20pt),
        "Name:", author,
        "Matriculation number:", matriculation-number,
        "Supervisor:", supervisor,
        "Date of submission:", date-submission,
      )
    ] else [
      #error-message-lang
    ]


    #pagebreak()

    #set align(left + top)

    #if language == "de" [
      Hiermit versichere ich, dass ich die Arbeit selbst verfasst und keine anderen als die
      angegebenen Quellen und Hilfsmittel benutzt und wörtlich oder inhaltlich aus fremden
      Werken Übernommenes als fremd kenntlich gemacht habe. Ferner versichere ich, dass die
      übermittelte elektronische Version in Inhalt und Wortlaut mit der gedruckten Version
      meiner Arbeit vollständig übereinstimmt. Ich bin einverstanden, dass diese elektronische
      Fassung universitätsintern anhand einer Plagiatssoftware auf Plagiate überprüft wird.
    ] else if language == "en" [
      I hereby certify that I have written the work myself and that I have not used any sources or aids other than those specified and that I have marked what has been taken over from other people's works, either verbatim or in terms of content, as foreign. I also certify that the electronic version of my thesis transmitted completely corresponds in content and wording to the printed version. I agree that this electronic version is being checked for plagiarism at the university using plagiarism software.
    ] else [
      #error-message-lang
    ]


    #v(10%)
    #line(length: 50%, stroke: (thickness: 0.6pt))
    #if language == "de" [
      #text(size: 10pt)[Abgabedatum: #date-submission]
    ] else if language == "en" [
      #text(size: 10pt)[Date of submission: #date-submission]
    ] else [
      #error-message-lang
    ]

    #pagebreak()
  ]
}
