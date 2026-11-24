// Thesis template for the Faculty of Mathematics and Computer Science
// at the Friedrich Schiller University Jena.

// Colors used across the template.
#let stroke-color = luma(200)
#let fill-color = luma(250)

// Small caps and upper case with increased spacing between characters.
// Default tracking is 0pt.
#let tracked-smallcaps(body) = smallcaps(text(tracking: 0.6pt, body))
#let tracked-upper(body) = upper(text(tracking: 0.6pt, body))

// Strings the template inserts itself, by language. Anything that is not German
// falls back to English.
#let translations = (
  en: (
    abstract: "Abstract",
    preface: "Preface",
    abbreviations: "Abbreviations",
    bibliography: "Bibliography",
    appendix: "Appendix",
    figures: "List of Figures",
    tables: "List of Tables",
    listings: "List of Listings",
    declaration: "Declaration of Academic Integrity",
    place-and-date: "Place and date",
    signature: "Signature",
  ),
  de: (
    abstract: "Zusammenfassung",
    preface: "Vorwort",
    abbreviations: "Abkürzungsverzeichnis",
    bibliography: "Literaturverzeichnis",
    appendix: "Anlagen",
    figures: "Abbildungsverzeichnis",
    tables: "Tabellenverzeichnis",
    listings: "Quelltextverzeichnis",
    declaration: "Eigenständigkeitserklärung",
    place-and-date: "Ort, Datum",
    signature: "Unterschrift",
  ),
)

// Look up a translated string for the current text language. Needs context.
#let translate(key) = translations.at(text.lang, default: translations.en).at(key)

// The fields of a cover page. All of them are optional.
#let cover-fields = (
  faculty: none,
  university: none,
  type-of-work: none,
  academic-degree: none,
  field-of-study: none,
  author-info: none,
  assessor: none,
  place-and-submission-date: none,
)

// The declaration of academic integrity (English version).
#let declaration-en = [
  + I hereby confirm that this work — or in case of group work, the contribution for which I am responsible and which I have clearly identified as such — is my own work and that I have not used any sources or resources other than those referenced.

    I take responsibility for the quality of this text and its content and have ensured that all information and arguments provided are substantiated with or supported by appropriate academic sources. I have clearly identified and fully referenced any material such as text passages, thoughts, concepts or graphics that I have directly or indirectly copied from the work of others or my own previous work. Except where stated otherwise by reference or acknowledgement, the work presented is my own in terms of copyright.

  + I understand that this declaration also applies to generative AI tools which cannot be cited (hereinafter referred to as "generative AI").

    I understand that the use of generative AI is not permitted unless the examiner has explicitly authorised its use (Declaration of Permitted Resources). Where the use of generative AI was permitted, I confirm that I have only used it as a resource and that this work is largely my own original work. I take full responsibility for any AI-generated content I included in my work.

    Where the use of generative AI was permitted to compose this work, I have acknowledged its use in a separate appendix. This appendix includes information about which AI tool was used or a detailed description of how it was used in accordance with the requirements specified in the examiner's Declaration of Permitted Resources. I have read and understood the requirements contained therein and any use of generative AI in this work has been acknowledged accordingly (e.g. type, purpose and scope as well as specific instructions on how to acknowledge its use).

  + I also confirm that this work has not been previously submitted in an identical or similar form to any other examination authority in Germany or abroad, and that it has not been previously published in German or any other language.

  + I am aware that any failure to observe the aforementioned points may lead to the imposition of penalties in accordance with the relevant examination regulations. In particular, this may include that my work will be classified as deception and marked as failed. Repeated or severe attempts to deceive may also lead to a temporary or permanent exclusion from further assessments in my degree programme.
]

// The declaration of academic integrity (German version).
#let declaration-de = [
  + Hiermit versichere ich, dass ich die vorliegende Arbeit – bei einer Gruppenarbeit meinen entsprechend gekennzeichneten Anteil der Arbeit – selbstständig verfasst und keine anderen als die angegebenen Quellen und Hilfsmittel benutzt habe.

    Ich trage die Verantwortung für die Qualität des Textes sowie die Inhalte und habe sichergestellt, dass Informationen und Argumente mit geeigneten wissenschaftlichen Quellen belegt bzw. gestützt werden. Die aus fremden oder auch eigenen, älteren Quellen wörtlich oder sinngemäß übernommenen Textstellen, Gedankengänge, Konzepte, Grafiken etc. in meinen Ausführungen habe ich als solche eindeutig gekennzeichnet und mit vollständigen Verweisen auf die jeweilige Quelle versehen. Alle weiteren Inhalte dieser Arbeit ohne entsprechende Verweise stammen im urheberrechtlichen Sinn von mir.

  + Ich weiß, dass meine Eigenständigkeitserklärung sich auch auf nicht zitierfähige generierende KI-Anwendungen (nachfolgend "generierende KI") bezieht.

    Mir ist bewusst, dass die Verwendung von generierender KI unzulässig ist, sofern nicht deren Nutzung von der prüfenden Person ausdrücklich freigegeben wurde (Freigabeerklärung). Sofern eine Zulassung als Hilfsmittel erfolgt ist, versichere ich, dass ich mich generierender KI lediglich als Hilfsmittel bedient habe und in der vorliegenden Arbeit mein gestalterischer Einfluss deutlich überwiegt. Ich verantworte die Übernahme der von mir verwendeten maschinell generierten Passagen in meiner Arbeit vollumfänglich selbst.

    Für den Fall der Freigabe der Verwendung von generierender KI für die Erstellung der vorliegenden Arbeit wird eine Verwendung in einem gesonderten Anhang meiner Arbeit kenntlich gemacht. Dieser Anhang enthält eine Angabe oder eine detaillierte Dokumentation über die Verwendung generierender KI gemäß den Vorgaben in der Freigabeerklärung der prüfenden Person. Die Details zum Gebrauch generierender KI bei der Erstellung der vorliegenden Arbeit inklusive Art, Ziel und Umfang der Verwendung sowie die Art der Nachweispflicht habe ich der Freigabeerklärung der prüfenden Person entnommen.

  + Ich versichere des Weiteren, dass die vorliegende Arbeit bisher weder im In- noch im Ausland in gleicher oder ähnlicher Form einer anderen Prüfungsbehörde vorgelegt wurde oder in deutscher oder einer anderen Sprache als Veröffentlichung erschienen ist.

  + Mir ist bekannt, dass ein Verstoß gegen die vorbenannten Punkte prüfungsrechtliche Konsequenzen haben und insbesondere dazu führen kann, dass meine Prüfungsleistung als Täuschung und damit als mit "nicht bestanden" bewertet werden kann. Bei mehrfachem oder schwerwiegendem Täuschungsversuch kann ich befristet oder sogar dauerhaft von der Erbringung weiterer Prüfungsleistungen in meinem Studiengang ausgeschlossen werden.
]

// Escape a string so that it can be used literally inside a regular expression.
#let escape-regex(s) = s.replace(regex("[\\\\.^$|?*+()\[\]{}]"), m => "\\" + m.text)

// This function gets your whole document as its `body` and formats it as a thesis.
#let fsu(
  // The title for your work.
  title: [Your Title],

  // Author's name.
  author: "Author",

  // The paper size to use.
  paper-size: "a4",

  // The university logo shown on the cover page(s), e.g.
  // `image("Bildmarke_blue_23cm.png", width: 10cm)`.
  // The logo is not part of this package, see the README on how to obtain it.
  uni-logo: none,

  // German cover page. Pass a dictionary with the keys of `cover-fields`, or `none` to
  // omit it. Unset keys are left out. Example:
  //   cover-german: (
  //     faculty: "Fakultät für Mathematik und Informatik",
  //     university: "Friedrich-Schiller-Universität Jena",
  //     type-of-work: "Bachelorarbeit",
  //     academic-degree: [Bachelor of Science (B.Sc.)],
  //     field-of-study: "Informatik",
  //     author-info: "01. April 2000 in Wolkenkuckucksheim",
  //     assessor: "Prof. Dr. Name Hier",
  //     place-and-submission-date: "Jena, 1. April 2025",
  //   ),
  cover-german: none,

  // English cover page. Same structure as `cover-german`.
  cover-english: none,

  // An abstract for your work. Can be omitted if you don't have one.
  abstract: none,

  // A German abstract ("Zusammenfassung"), shown directly after `abstract`.
  // Mandatory if the thesis is not written in German (PO § 20 Abs. 8): the document
  // does not compile without it unless the text language is German.
  abstract-german: none,

  // The contents of the preface page. Displayed after the table of contents.
  // Can be omitted if you don't have one.
  preface: none,

  // The result of a call to the `outline` function or `none`.
  // Set this to `none`, if you want to disable the table of contents.
  // More info: https://typst.app/docs/reference/model/outline/
  table-of-contents: outline(depth: 2),

  // Content of the appendix. Use second-level headings (`==`) for its sections;
  // they are numbered A, B, C, ...
  appendix: none,

  // Abbreviations as an array of `(short, long)` pairs or as a dictionary
  // `(short: long)`. Every occurrence of an abbreviation in the body is linked to the
  // list of abbreviations.
  abbreviations: (),

  // Whether the first occurrence of an abbreviation is written out as "long (short)".
  expand-first-abbreviation: true,

  // The result of a call to the `bibliography` function or `none`.
  // Example: bibliography("refs.bib")
  // More info: https://typst.app/docs/reference/model/bibliography/
  bibliography: none,

  // The declaration of academic integrity at the end of the document.
  // `auto` uses the English or German text depending on the text language,
  // `none` omits it and content replaces it.
  declaration: auto,

  // Whether to start a chapter on a new page.
  // Note: the Gestaltungshinweise of the examination office require every part of the
  // thesis (title page, abstract, table of contents, preface, main text, bibliography,
  // appendix, declaration) to start on a new page.
  chapter-pagebreak: true,

  // Whether chapters and front matter start on odd (right-hand) pages, inserting blank
  // pages where needed. Recommended for double-sided printing.
  two-sided: true,

  // Whether to produce the print version. Turning on `print` turns off
  // `external-link-circle` and turns on `use-print-margins`. You can set those two
  // individually as you wish; they override `print`.
  print: false,

  // Whether to display a maroon circle next to external links.
  // `auto` means: on, unless `print` is on.
  external-link-circle: auto,

  // Whether to use `print-margin` instead of `screen-margin`.
  // `auto` means: on if `print` is on.
  use-print-margins: auto,

  // Page margins of the screen version.
  screen-margin: (x: 3cm, y: 2.8cm),

  // Page margins of the print version. `auto` uses the margins recommended by the
  // examination office (Gestaltungshinweise, § 5): left 40 mm, right 20 mm, top and
  // bottom 30 mm each. With `two-sided`, left and right become inside and outside.
  print-margin: auto,

  // Display a list of figures (images). `title: auto` uses a translated default.
  figure-index: (enabled: false, title: auto),

  // Display a list of tables.
  table-index: (enabled: false, title: auto),

  // Display a list of listings (code blocks).
  listing-index: (enabled: false, title: auto),

  // The content of your work.
  body,
) = {
  // Set the document's metadata.
  set document(title: title, author: author)

  // Set the body font.
  set text(font: "Libertinus Serif", size: 12pt)

  // Set raw text font.
  show raw: set text(font: "DejaVu Sans Mono", size: 8.8pt)

  // Resolve the print-dependent options.
  let external-link-circle = if external-link-circle == auto { not print } else { external-link-circle }
  let use-print-margins = if use-print-margins == auto { print } else { use-print-margins }

  // Configure page size and margins.
  let print-margin = if print-margin != auto {
    print-margin
  } else if two-sided {
    (inside: 4cm, outside: 2cm, top: 3cm, bottom: 3cm)
  } else {
    (left: 4cm, right: 2cm, top: 3cm, bottom: 3cm)
  }

  set page(
    paper: paper-size,
    margin: if use-print-margins { print-margin } else { screen-margin },
  )

  // Starts a new (odd, if two-sided) page, unless we are already at the start of one.
  let new-page = pagebreak(weak: true, to: if two-sided { "odd" })

  let cover-page(cover, labels) = {
    let cover = cover-fields + cover
    page(align(center + horizon, block(width: 90%)[
      #let v-space = v(2em, weak: true)

      #if uni-logo != none { uni-logo }

      #text(3em)[*#title*]

      #if cover.type-of-work != none { text(2em, tracked-smallcaps(cover.type-of-work)) }

      #if cover.academic-degree != none [
        #labels.degree

        #cover.academic-degree
      ]

      #if cover.field-of-study != none [#labels.field #cover.field-of-study]

      #v-space

      #if cover.university != none { tracked-smallcaps(cover.university) }

      #cover.faculty

      #v-space

      #labels.submitted-by

      #text(1.6em, author)
      #if cover.author-info != none [
        #v(-3mm)
        #labels.born #cover.author-info
      ]

      #v-space

      #if cover.assessor != none [
        #labels.assessor

        #cover.assessor
      ]

      #v(2em)

      #cover.place-and-submission-date
    ]))
  }

  // German cover page.
  if cover-german != none {
    set text(lang: "de")
    cover-page(cover-german, (
      degree: "zur Erlangung des akademischen Grades",
      field: "im Studiengang",
      submitted-by: "eingereicht von",
      born: "geboren am",
      assessor: "Betreuer",
    ))
  }

  // English cover page.
  if cover-english != none {
    set text(lang: "en")
    cover-page(cover-english, (
      degree: "for the attainment of the academic degree",
      field: "in",
      submitted-by: "submitted by",
      born: "born on",
      assessor: "assessed by",
    ))
  }

  // A thesis that is not written in German needs a German abstract (PO § 20 Abs. 8).
  context if text.lang != "de" and abstract-german == none {
    panic(
      "A German abstract is mandatory for theses not written in German (PO § 20 Abs. 8). "
        + "Please pass it as `abstract-german: [...]`.",
    )
  }

  // Abstract page(s).
  let abstract-page(body) = {
    new-page
    align(horizon + center, block(width: 90%, {
      context tracked-smallcaps(translate("abstract"))
      block(width: 80%, {
        set par(leading: 0.78em, justify: true, linebreaks: "optimized")
        body
      })
    }))
  }
  if abstract != none {
    abstract-page(abstract)
  }
  if abstract-german != none {
    set text(lang: "de")
    abstract-page(abstract-german)
  }

  // Configure paragraph properties.
  // Default leading is 0.65em.
  // Default spacing is 1.2em.
  set par(leading: 0.7em, spacing: 1.35em, justify: true, linebreaks: "optimized")

  // Add vertical space after headings.
  show heading: it => {
    it
    v(2%, weak: true)
  }
  // Do not hyphenate headings.
  show heading: set text(hyphenate: false)

  // Start chapters on a new page.
  show heading.where(level: 1): it => {
    if chapter-pagebreak { new-page }
    it
  }

  // Show a small maroon circle next to links to external websites.
  show link: it => {
    it
    if external-link-circle and type(it.dest) == str {
      sym.wj
      h(1.6pt)
      sym.wj
      super(box(height: 3.8pt, circle(radius: 1.2pt, stroke: 0.7pt + rgb("#993333"))))
    }
  }

  // Indent nested entries in the outline.
  set outline(indent: auto)

  // Display table of contents.
  if table-of-contents != none {
    new-page
    table-of-contents
  }

  // Normalize and sort abbreviations.
  let abbreviations = if type(abbreviations) == dictionary {
    abbreviations.pairs()
  } else {
    abbreviations
  }
  let abbreviations = abbreviations.sorted(key: a => lower(a.at(0)))
  let abbreviation-label(short) = label("fmi-abbreviation-" + short)

  // Display list of abbreviations directly after the table of contents, as the
  // Gestaltungshinweise ask for.
  if abbreviations.len() > 0 {
    new-page
    context heading(level: 1, numbering: none, translate("abbreviations"))
    grid(
      columns: (auto, 1fr),
      column-gutter: 2em,
      row-gutter: 0.8em,
      ..abbreviations
        .map(((short, long)) => (
          [#text(hyphenate: false, strong(short))#abbreviation-label(short)],
          long,
        ))
        .flatten(),
    )
  }

  // Display preface.
  if preface != none {
    new-page
    context heading(numbering: none, level: 1, translate("preface"))
    preface
  }

  // Configure heading numbering.
  set heading(numbering: "1.")

  show heading.where(level: 4): it => text(weight: "regular", style: "italic", it.body + [. ])
  show heading.where(level: 5): it => text(weight: "regular", style: "italic", it.body)
  show heading.where(level: 6): it => text(weight: "regular", style: "italic", it.body)
  show heading.where(level: 6): set heading(outlined: false)

  // Configure page numbering and footer.
  set page(
    footer: context {
      // Get current page number.
      let i = counter(page).get().first()

      // The declaration counts, but shows no page number (Gestaltungshinweise).
      let declaration-start = query(<fmi-declaration>)
      if declaration-start.len() > 0 and here().page() >= declaration-start.first().location().page() {
        return
      }

      // Align right for odd pages and left for even.
      let is-odd = calc.odd(i)
      let aln = if is-odd { right } else { left }

      // Are we on a page that starts a chapter?
      let target = heading.where(level: 1)
      if query(target).any(it => it.location().page() == here().page()) {
        return align(aln)[#i]
      }

      // Find the chapter of the section we are currently in.
      let before = query(target.before(here()))
      if before.len() > 0 {
        let current = before.last()
        let gap = 1.75em
        let chapter = tracked-upper(text(size: 0.68em, current.body))
        if current.numbering != none {
          if is-odd {
            align(aln)[#chapter #h(gap) #i]
          } else {
            align(aln)[#i #h(gap) #chapter]
          }
        }
      }
    },
  )

  // Configure equation numbering.
  set math.equation(numbering: "(1)")

  // Display inline code in a small box that retains the correct baseline.
  show raw.where(block: false): box.with(
    fill: fill-color.darken(2%),
    inset: (x: 3pt, y: 0pt),
    outset: (y: 3pt),
    radius: 2pt,
  )

  // Display block code with padding.
  show raw.where(block: true): block.with(inset: (x: 5pt))

  let image-width = 360pt

  set figure.caption(position: bottom)
  show figure.caption: it => box(width: image-width, text(size: .8em, it))

  // Set the default width of images in the whole document.
  set image(width: image-width)

  set table(
    // Increase the table cell's padding.
    inset: 7pt, // default is 5pt
    stroke: (0.5pt + stroke-color),
  )
  // Use smallcaps for table header row.
  show table.cell.where(y: 0): tracked-smallcaps

  // The main body. The abbreviation rule is scoped to this block.
  if abbreviations.len() == 0 {
    body
  } else {
    // Longer abbreviations are matched first, so that e.g. "C++" wins over "C".
    let pattern = abbreviations
      .map(a => a.at(0))
      .sorted(key: short => -short.len())
      .map(short => {
        // Only require a word boundary next to word characters.
        let boundary(c) = if c.match(regex("\\w")) != none { "\\b" } else { "" }
        boundary(short.first()) + escape-regex(short) + boundary(short.last())
      })
      .join("|")
    let long-forms = abbreviations.to-dict()
    show regex(pattern): it => {
      let short = it.text
      let long = long-forms.at(short)
      let occurrences = counter("fmi-abbreviation-" + short)
      occurrences.step()
      context {
        let shown = if expand-first-abbreviation and occurrences.get().first() == 1 {
          [#long (#short)]
        } else {
          short
        }
        link(abbreviation-label(short), shown)
      }
    }
    body
  }

  // Display bibliography.
  if bibliography != none {
    show std.bibliography: set text(0.85em)
    // Use default paragraph properties for bibliography.
    show std.bibliography: set par(leading: 0.65em, justify: false, linebreaks: auto)
    // The heading must read "Literaturverzeichnis" (Gestaltungshinweise). This only
    // applies if you did not pass your own `title` to `bibliography(...)`.
    context {
      set std.bibliography(title: translate("bibliography"))
      bibliography
    }
  }

  // Display indices of figures, tables, and listings.
  let fig-t(kind) = figure.where(kind: kind)
  let indices = (
    (figure-index, image, "figures"),
    (table-index, table, "tables"),
    (listing-index, raw, "listings"),
  )
  for (index, kind, key) in indices {
    if index.at("enabled", default: false) {
      context if query(fig-t(kind)).len() > 0 {
        let title = index.at("title", default: auto)
        outline(
          title: if title == auto { translate(key) } else { title },
          target: fig-t(kind),
        )
      }
    }
  }

  // Display appendix. Its sections are numbered A, B, C, ...
  if appendix != none {
    context heading(numbering: none, level: 1, translate("appendix"))
    counter(heading).update(0)
    set heading(numbering: (..nums) => {
      let nums = nums.pos().slice(1)
      if nums.len() > 0 { numbering("A.1", ..nums) }
    })
    appendix
  }

  // Display declaration of academic integrity.
  if declaration != none {
    new-page
    // Marks where the declaration starts: its pages show no page number.
    [#metadata(none) <fmi-declaration>]
    context heading(numbering: none, level: 1, translate("declaration"))
    if declaration == auto {
      context if text.lang == "de" { declaration-de } else { declaration-en }
    } else {
      declaration
    }

    v(40pt)
    context grid(
      columns: (1fr, 1fr),
      row-gutter: 1em,
      line(length: 150pt, stroke: (dash: "dashed")),
      line(length: 200pt, stroke: (dash: "dashed")),
      translate("place-and-date"),
      translate("signature"),
    )
  }
}

// This function formats its `body` (content) into a blockquote.
#let blockquote(body) = {
  block(
    width: 100%,
    fill: fill-color,
    inset: 2em,
    stroke: (y: 0.5pt + stroke-color),
    body,
  )
}

// A visible note for things that still need to be done.
#let todo(it) = text(fill: luma(50), style: "italic", size: 0.8em, [\/\/ to do: ] + it)
