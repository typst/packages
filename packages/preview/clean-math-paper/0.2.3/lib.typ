#import "@preview/great-theorems:0.1.2": great-theorems-init, mathblock, proofblock
#import "@preview/rich-counters:0.2.2": rich-counter
#import "@preview/i-figured:0.2.4": reset-counters, show-equation

// Language support
#let language-translations = state(
  "language-translations",
  (
    en: (
      "theorem": "Theorem",
      "proposition": "Proposition",
      "corollary": "Corollary",
      "lemma": "Lemma",
      "definition": "Definition",
      "remark": "Remark",
      "example": "Example",
      "question": "Question",
      "proof": "Proof",
      "keywords": "Keywords",
      "ams": "AMS subject classification",
      "appendix": "Appendix",
      "abstract": "Abstract",
    ),
    de: (
      "theorem": "Satz",
      "proposition": "Proposition",
      "corollary": "Korollar",
      "lemma": "Lemma",
      "definition": "Definition",
      "remark": "Anmerkung",
      "example": "Beispiel",
      "question": "Frage",
      "proof": "Beweis",
      "keywords": "Schlüsselwörter",
      "ams": "AMS-Klassifikation",
      "appendix": "Anhang",
      "abstract": "Zusammenfassung",
    ),
    fr: (
      "theorem": "Théorème",
      "proposition": "Proposition",
      "corollary": "Corollaire",
      "lemma": "Lemme",
      "definition": "Définition",
      "remark": "Remarque",
      "example": "Exemple",
      "question": "Question",
      "proof": "Preuve",
      "keywords": "Mots clés",
      "ams": "Classification AMS",
      "appendix": "Annexe",
      "abstract": "Résumé",
    ),
    es: (
      "theorem": "Teorema",
      "proposition": "Proposición",
      "corollary": "Corolario",
      "lemma": "Lema",
      "definition": "Definición",
      "remark": "Comentario",
      "example": "Ejemplo",
      "question": "Pregunta",
      "proof": "Demostración",
      "keywords": "Palabras clave",
      "ams": "Clasificación AMS",
      "appendix": "Apéndice",
      "abstract": "Resumen",
    ),
  ),
)

#let get-language-title(label) = {
  context {
    let language = str(text.lang)
    let translations = language-translations.get()
    if language in translations {
      translations.at(language).at(label, default: "Unknown")
    } else {
      translations.en.at(label, default: "Unknown")
    }
  }
}

// counter for mathblocks
#let theoremcounter = rich-counter(
  identifier: "mathblocks",
  inherited_levels: 1,
)

#let my-mathblock = mathblock.with(
  counter: theoremcounter,
  breakable: false,
  titlix: title => [(#title):],
  // suffix: [#h(1fr) $triangle.r$],
)

// theorem etc. settings
#let theorem = my-mathblock(
  blocktitle: get-language-title("theorem"),
  bodyfmt: text.with(style: "italic"),
)

#let proposition = my-mathblock(
  blocktitle: get-language-title("proposition"),
  bodyfmt: text.with(style: "italic"),
)

#let corollary = my-mathblock(
  blocktitle: get-language-title("corollary"),
  bodyfmt: text.with(style: "italic"),
)

#let lemma = my-mathblock(
  blocktitle: get-language-title("lemma"),
  bodyfmt: text.with(style: "italic"),
)

#let definition = my-mathblock(
  blocktitle: get-language-title("definition"),
  bodyfmt: text.with(style: "italic"),
)

#let remark = my-mathblock(blocktitle: [_#get-language-title("remark")_])

#let example = my-mathblock(blocktitle: [_#get-language-title("example")_])

#let question = my-mathblock(blocktitle: [_#get-language-title("question")_])

#let proof = proofblock(prefix: [_#get-language-title("proof")._])

// To also handle content (e.g. something like $dagger$) as affiliation-id,
// cf. https://github.com/typst/typst/issues/2196#issuecomment-1728135476
#let to-string(content) = {
  if type(content) in (int, float, decimal, version, bytes, label, type, str) {
    str(content)
  } else {
    if content.has("text") {
      content.text
    } else if content.has("children") {
      content.children.map(to-string).join("")
    } else if content.has("body") {
      to-string(content.body)
    } else if content == [ ] {
      " "
    }
  }
}

#let template(
  title: "",
  authors: (),
  affiliations: (),
  date: datetime.today().display(),
  abstract: none,
  keywords: (),
  AMS: (),
  lang: "en",
  translations: none,
  heading-color: rgb("#000000"),
  link-color: rgb("#000000"),
  lines: true,
  body,
) = {
  // Set the document's basic properties.
  set document(author: authors.map(a => a.name), title: title)
  set page(
    margin: (left: 25mm, right: 25mm, top: 25mm, bottom: 30mm),
    numbering: "1",
    number-align: center,
  )
  set text(font: "New Computer Modern", lang: lang)
  set enum(numbering: "(i)")
  set outline(indent: 2em) // indent: auto does not work well with appendices
  show: great-theorems-init

  // Overrides the current translations
  if lang != none and translations != none {
    language-translations.update(value => {
      if lang in value {
        value.insert(lang, value.at(lang) + translations)
      } else {
        value.insert(lang, translations)
      }
      value
    })
  }

  // table label on top and not below the table
  show figure.where(kind: table): set figure.caption(position: top)

  // Heading settings.
  set heading(numbering: "1.1")
  show heading.where(level: 1): set text(size: 14pt, fill: heading-color)
  show heading.where(level: 2): set text(size: 12pt, fill: heading-color)

  // Equation settings.
  // Using i-figured:
  show heading: reset-counters
  show math.equation: show-equation.with(prefix: "eq:", only-labeled: true)

  // Using headcount:
  // show heading: reset-counter(counter(math.equation))
  // set math.equation(numbering: dependent-numbering("(1.1)"))
  set math.equation(supplement: none)
  show math.equation: box // no line breaks in inline math

  if lines {
    line(length: 100%, stroke: 2pt)
  }
  // Title row.
  pad(
    bottom: 4pt,
    top: 4pt,
    align(center)[
      #block(text(weight: 500, fill: heading-color, 1.75em, title))
      #v(1em, weak: true)
    ],
  )
  if lines {
    line(length: 100%, stroke: 2pt)
  }

  // Author information.
  pad(
    top: 0.5em,
    x: 2em,
    grid(
      columns: (1fr,) * calc.min(3, authors.len()),
      gutter: 1.5em,
      ..authors.map(author => align(center)[
        #let affiliation-id = if "affiliation-id" in author {
          author.affiliation-id
        } else {
          ""
        }
        #if author.keys().contains("orcid") {
          link("http://orcid.org/" + author.orcid)[
            #pad(
              bottom: -8pt,
              grid(
                columns: (8pt, auto, 8pt),
                rows: 10pt,
                [],
                [*#author.name*#super(to-string(affiliation-id))],
                [
                  #pad(left: 4pt, top: -4pt, image("orcid.svg", width: 8pt))
                ],
              ),
            )
          ]
        } else {
          grid(
            columns: auto,
            rows: 2pt,
            [*#author.name*#super(to-string(affiliation-id))],
          )
        }
      ]),
    ),
  )

  // Affiliation information.
  pad(
    top: 0.5em,
    x: 2em,
    if affiliations != none {
      for affiliation in affiliations {
        align(center)[
          #super(to-string(affiliation.id))#affiliation.name
        ]
      }
    },
  )

  align(center)[#date]

  // Set the color for links and references after the authors to not overwrite the text color in the case of an available orcid.
  show link: set text(fill: link-color)
  show ref: set text(fill: link-color)

  // Abstract.
  if abstract != none {
    pad(
      x: 3em,
      top: 1em,
      bottom: 0.4em,
      align(center)[
        #heading(
          outlined: false,
          numbering: none,
          text(0.85em, smallcaps(get-language-title("abstract"))),
        )
        #set par(justify: true)
        #set text(hyphenate: false)

        #abstract
      ],
    )
  }

  // Keywords
  if keywords.len() > 0 {
    [*_#get-language-title("keywords")_*. #h(0.3cm)] + keywords.map(str).join(" · ")
    linebreak()
  }
  // AMS
  if AMS.len() > 0 {
    [*#get-language-title("ams")*. #h(0.3cm)] + AMS.map(str).join(", ")
  }
  // Main body.
  set par(justify: true)
  set text(hyphenate: false)

  body
}

#let appendices(body) = {
  counter(heading).update(0)
  counter("appendices").update(1)

  set heading(
    numbering: (..nums) => {
      let vals = nums.pos()
      let value = "ABCDEFGHIJ".at(vals.at(0) - 1)
      if vals.len() == 1 {
        return get-language-title("appendix") + " " + value
      } else {
        return value + "." + nums.pos().slice(1).map(str).join(".")
      }
    },
  )
  [#pagebreak() #body]
}
