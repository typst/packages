#let signature-line(length: 6em) = box(
  width: length,
  stroke: (bottom: 0.5pt),
  height: 0.65em,
)

#let fmt-date(date) = strong(date.display("[day].[month].[year]."))

#let thesis-config = (
  bachelor: (
    label: "Bakalaura darbs",
    intro-suffix: "",
    make-footer: (date, presentation-date) => [
      Darbs iesniegts Datorikas nodaļā #date \
      Pilnvarotā persona: vecākā metodiķe: Ārija Sproģe ~#signature-line()

      #v(1fr)

      Darbs aizstāvēts bakalaura gala pārbaudījuma komisijas sēdē ~#signature-line() \
      #presentation-date prot. Nr. #signature-line(length: 4em) \
      Komisijas sekretārs(-e): #signature-line(length: 15em)
    ],
  ),
  master: (
    label: "Maģistra darbs",
    intro-suffix: "",
    make-footer: (date, presentation-date) => [
      Darbs iesniegts Datorikas nodaļā #date \
      Pilnvarotā persona: vecākā metodiķe: Ārija Sproģe ~#signature-line()

      #v(1fr)

      Darbs aizstāvēts maģistra gala pārbaudījuma komisijas sēdē ~#signature-line() \
      #presentation-date prot. Nr. #signature-line(length: 4em) \
      Komisijas sekretārs(-e): #signature-line(length: 15em)
    ],
  ),
  course: (
    label: "Kursa darbs",
    intro-suffix: "",
    make-footer: (date, _) => [
      Darbs iesniegts Datorikas nodaļā #date \
      Kursa darbu pārbaudīja komisijas sekretārs (elektronisks paraksts)
    ],
  ),
  qualification: (
    label: "Kvalifikācijas darbs",
    intro-suffix: " un/vai recenzentam uzrādītajai darba versijai",
    make-footer: (date, _) => [
      Darbs iesniegts Datorikas nodaļā #date \
      Kvalifikācijas darbu pārbaudījumu komisijas sekretārs (elektronisks paraksts)
    ],
  ),
)

#let get-thesis-label(thesis-type) = (
  thesis-config
    .at(thesis-type, default: (
      label: str(thesis-type),
    ))
    .label
)

#let get-thesis-config(thesis-type) = {
  thesis-config.at(thesis-type, default: (
    label: str(thesis-type),
    intro-suffix: "",
    make-footer: (date, _) => [],
  ))
}

#let make-author-lines(authors, date) = {
  if authors.len() > 1 [Autori:\ ] else [Autors: ]
  authors.map(it => [*#it.name, #it.code* ~#signature-line()~ #date]).join(", ")
}

#let make-advisor-lines(advisors, date) = {
  if advisors.len() > 0 [
    #if advisors.len() > 1 [Vadītāji:\ ] else [Vadītājs:]
    #(
      advisors
        .map(it => [*#it.title #it.name* ~#signature-line()~ #date])
        .join("\n")
    )
  ]
}

#let make-dokumentary(
  title,
  authors,
  advisors,
  reviewer,
  thesis-type,
  date,
  presentation-date,
) = {
  let cfg = get-thesis-config(thesis-type)

  [
    #cfg.label "*#title*" izstrādāts
    Latvijas Universitātes Eksakto zinātņu un tehnoloģiju fakultātē.

    Ar savu parakstu apliecinu, ka darbs izstrādāts patstāvīgi, izmantoti tikai
    tajā norādītie informācijas avoti un iesniegtā darba elektroniskā kopija
    atbilst izdrukai#cfg.intro-suffix.
    #set par(hanging-indent: 1cm)

    #v(0.2fr)

    #make-author-lines(authors, date)

    #v(1fr)

    Rekomendēju/nerekomendēju darbu aizstāvēšanai _(nederīgo svītro vadītājs)_\
    #make-advisor-lines(advisors, date)

    #v(1fr)

    #if reviewer != none [
      Recenzents: *#reviewer.title  #reviewer.name*
      #v(1fr)
    ]

    #(cfg.make-footer)(date, presentation-date)

    #v(1fr)
  ]
}

#let make-documentary-page(
  title,
  authors,
  advisors,
  reviewer,
  thesis-type,
  date,
  presentation-date,
) = {
  set page(numbering: none)
  heading(level: 1, outlined: false, numbering: none, "Dokumentārā lapa")
  set par(spacing: 2em)

  make-dokumentary(
    title,
    authors,
    advisors,
    reviewer,
    thesis-type,
    fmt-date(date),
    fmt-date(presentation-date),
  )
}
