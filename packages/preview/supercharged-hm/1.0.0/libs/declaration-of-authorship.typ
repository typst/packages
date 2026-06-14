// Copyright 2024 Danny Seidel https://github.com/DannySeidel
// Copyright 2025 Felix Schladt https://github.com/FelixSchladt

#import "@preview/linguify:0.5.0": *
#import "@preview/oxifmt:1.0.0": strfmt

#import "../lang.typ": *

#import "date.typ": format-date

#let decl-of-authorship = [
  Ich versichere, dass ich die vorliegende Arbeit selbstständig und ohne fremde Hilfe angefertigt habe und keine anderen als die angegebenen Hilfsmittel benutzt und die verwendete Literatur vollständig aufgeführt sowie Zitate kenntlich gemacht habe.
  Ich versichere ferner, dass die Arbeit noch nicht zu anderen Prüfungen vorgelegt wurde.
]

#let decl-of-authorship-ai = [
  Ich versichere, dass ich die vorliegende Arbeit selbstständig und ohne fremde Hilfe angefertigt habe und keine anderen als die angegebenen Hilfsmittel benutzt habe.

  Alle übernommenen Inhalte sowie mit Unterstützung von KI generierten Inhalte wurden entsprechend den anerkannten wissenschaftlichen Grundsätzen und entsprechend den Regelungen zur   Kennzeichnung von KI- Inhalten kenntlich gemacht.
  Ausgenommen von der Kenntlichmachung sind orthografische, grammatikalische Korrekturen, Übersetzungen sowie nicht-sinnverändernde Verbesserungen von Formulierungen.

  Ich erkläre, dass ich KI-Werkzeuge als Hilfsmittel genutzt habe, die von KI generierten Inhalte und Hinweise kritisch überprüft habe und mein eigenständiger kognitiver und kreativer Einfluss in dieser Arbeit überwiegt.
  Ich versichere, dass ich die Inhalte meiner Arbeit vollständig verstanden habe und selbstständig vertreten kann.

  Ich habe die verwendete Literatur vollständig aufgeführt sowie Zitate kenntlich gemacht.
  Ich versichere ferner, dass die Arbeit noch nicht zu anderen Prüfungen vorgelegt wurde.
]


#let make-declaration-of-authorship(
  ai-usage,
  authors,
  date,
  language,
  city,
  date-format,
  signature-img,
) = {
  if (city == none) {
    panic("Declaration of authorship requires city to be set")
  }

  v(2em)
  heading(
    level: 1,
    linguify(
      "lib_declaration_of_authorship-title",
      from: lang-db
      )
  )

  v(1em)

  if (not ai-usage) { decl-of-authorship } else { decl-of-authorship-ai }

  v(2em)
  text([#city, #format-date(date, language, date-format)])
  if (signature-img != none) {
    place(
      dx: 40pt,
      dy: 10pt,
      signature-img,
    )
  }

  v(1em)

  v(4em)
  line(length: 40%)
  authors
}
