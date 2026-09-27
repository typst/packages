// Déclaration sur l'honneur — Travail de Bachelor
// Filière Informatique et systèmes de communication (ISC)
// Haute École d'Ingénierie — HES-SO Valais-Wallis
//
// Bilingual page: the language is taken from the document language passed to
// project(). The identity fields are auto-filled from the thesis metadata and
// the signature image is mandatory (passed to project() via `signature:`).
//
// NOTE: the declaration *wording* below is a first draft and will be refined.
//
#import "@preview/isc-hei-bthesis:0.7.9" : *

#page-title(context i18n(inc.global-language.get(), "honour-title"))

#context {
  let lang = inc.global-language.get()
  let meta = inc.global-thesis-meta.get()

  let signature = meta.at("signature", default: none)
  let title     = meta.at("title", default: "")
  let author    = meta.at("author", default: "")
  let year      = meta.at("academic-year", default: "")
  let date      = meta.at("date", default: none)

  let date-str = if date != none {
    inc.custom-date-format(date, pattern: i18n(lang, "date-format"), lang: lang)
  } else { "" }

  // Per-language strings. Keep `en` as the fallback for any other language.
  let t = if lang == "fr" {
    (
      subtitle: [Travail de Bachelor],
      labels: ("Auteur·e", "Titre du travail", "Année académique"),
      intro-prefix: [Moi,],
      intro: [déclare sur l'honneur :],
      items: (
        [avoir pris connaissance des règles relatives à la prévention du plagiat dans le cadre du travail de Bachelor de la filière ISC, et m'engager à les respecter ;],
        [que le travail soumis est le fruit de ma réflexion personnelle et qu'il a été réalisé de manière autonome ;],
        [que toute formulation, idée, raisonnement, analyse, donnée, image, schéma ou fragment de code source empruntés à un tiers — y compris à un outil d'intelligence artificielle générative — sont clairement signalés comme tels et que leur source est précisément indiquée, conformément aux règles de citation en vigueur ;],
        [avoir déclaré de manière transparente tout recours à un outil d'intelligence artificielle générative, en précisant l'outil utilisé, les finalités et les passages concernés ;],
        [ne pas avoir eu recours au plagiat, à l'autoplagiat, au _ghostwriting_ ni à toute autre forme de fraude académique ;],
        [avoir conscience que la transgression des règles ci-dessus peut entraîner des sanctions allant de la note de 1.0 à l'exclusion de la formation, voire au retrait du titre obtenu ;],
        [accepter que mon travail puisse être analysé au moyen d'un logiciel de détection de similitudes ou par tout autre moyen approprié.],
      ),
      place-date: [Fait à Sion, le #date-str],
      signature-label: [Signature],
      note: [Document inspiré de la Directive 0.3 de l'Université de Lausanne, de la Directive en matière de plagiat des étudiant·e·s de l'Université de Genève, et du formulaire de Déclaration sur l'honneur de l'Université de Neuchâtel.],
    )
  } else {
    (
      subtitle: [Bachelor Thesis],
      labels: ("Author", "Thesis title", "Academic year"),
      intro-prefix: [I,],
      intro: [hereby declare on my honour:],
      items: (
        [that I have read the rules on the prevention of plagiarism applicable to the ISC Bachelor thesis, and undertake to comply with them;],
        [that the submitted work is the result of my own reflection and was carried out independently;],
        [that any wording, idea, line of reasoning, analysis, data, image, diagram or fragment of source code borrowed from a third party — including from a generative artificial-intelligence tool — is clearly identified as such and its source is precisely indicated, in accordance with the citation rules in force;],
        [that I have transparently declared any use of a generative artificial-intelligence tool, specifying the tool used, the purposes and the passages concerned;],
        [that I have not engaged in plagiarism, self-plagiarism, _ghostwriting_ or any other form of academic fraud;],
        [that I am aware that breaching the above rules may lead to sanctions ranging from a grade of 1.0 to exclusion from the programme, or even withdrawal of the awarded degree;],
        [that I accept that my work may be analysed using similarity-detection software or by any other appropriate means.],
      ),
      place-date: [Done in Sion, on #date-str],
      signature-label: [Signature],
      note: [Document inspired by Directive 0.3 of the University of Lausanne, by the University of Geneva's student plagiarism directive, and by the University of Neuchâtel's declaration-of-honour form.],
    )
  }

  set par(justify: true)

  // Sub-title block under the page title.
  text(size: 10pt, style: "italic")[
    #t.subtitle \
    Filière Informatique et systèmes de communication (ISC) · Haute École d'Ingénierie, HES-SO Valais-Wallis
  ]

  v(1.5em)

  // Auto-filled identity fields: bold label + value, aligned in two columns.
  let fields = (
    (t.labels.at(0), author),
    (t.labels.at(1), title),
    (t.labels.at(2), year),
  )
  grid(
    columns: (auto, 1fr),
    column-gutter: 1em,
    row-gutter: 0.6em,
    ..fields.map(((label, value)) => (strong(label + " :"), value)).flatten(),
  )

  v(1.2em)

  [#t.intro-prefix #author, #t.intro]

  v(0.6em)

  set enum(numbering: "1.", indent: 0pt, body-indent: 0.8em, spacing: 0.7em)
  enum(..t.items)

  v(2em)

  t.place-date

  v(1.5em)

  // Signature image, sitting next to its label. A missing image is flagged here
  // (and on the cover page) rather than aborting the compile, so drafts still build.
  grid(
    columns: (auto, auto),
    column-gutter: 1em,
    align: (left + horizon, left + bottom),
    strong(t.signature-label + " :"),
    if signature != none { signature } else {
      text(fill: red, style: "italic", if lang == "fr" [⟨ signature manquante ⟩] else [⟨ signature missing ⟩])
    },
  )

  v(1fr)

  line(length: 100%, stroke: 0.3pt)
  v(0.5em)
  text(size: 8pt, style: "italic")[#t.note]
}
