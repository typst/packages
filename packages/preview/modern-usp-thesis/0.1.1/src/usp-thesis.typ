#import "layout.typ": setup-layout, quote-long
#import "elements.typ": cover as cover-page, title-page as make-title-page, version-page as make-version-page, catalog-card-page as make-catalog-card-page, approval-sheet, abstract-page

/// Main template function for USP theses and dissertations.
/// - title (content): The title of the thesis (in the main language).
/// - title-alt (content): The title in the secondary language (Mandatory for USP).
/// - subtitle (content): The subtitle of the thesis.
/// - author (string): The author's name.
/// - advisor (string): The advisor's name.
/// - coadvisor (string): The co-advisor's name.
/// - degree (string): The degree level ("Mestre" or "Doutor"), or a full title such as "Mestre em Engenharia".
/// - program (string): The graduate program name, e.g. "Estatística" (printed after "Programa: ").
/// - area (string): The concentration area.
/// - institute (string): The USP institute name.
/// - local (string): The city.
/// - year (string, int or auto): The year of deposit (auto: the current year).
/// - month (auto, int, string or none): The month printed with the year at the
///   foot of the title page, e.g. "November 2026" (auto: the current month when
///   `year` is auto too, otherwise none; an integer 1-12 is named in `lang`;
///   none: the year only).
/// - version (string): "Original" or "Corrigida".
/// - nature (string): Overrides the inferred "Dissertação" or "Tese".
/// - lang (string): Main document language ("pt" or "en").
/// - font (string or array): The document font, or a list of fallbacks (default: "New Computer Modern").
/// - cover (bool): Whether to print the cover.
/// - title-page (bool): Whether to print the title page.
/// - version-page (bool): Whether the "original version" statement gets its own
///   page after the title page, as in the IME-USP model ("This is the original
///   version of the dissertation prepared by the candidate ..., as submitted to
///   the Examining Committee."). It applies to `version: "Original"` only; other
///   versions, or false, print the bold version label on the title page instead.
/// - catalog-card (none, bytes or content): The ficha catalográfica
///   (cataloging-in-publication card), on the verso of the "original version"
///   page, below the CC BY 4.0 licence line (only with the title page). Give the
///   file generated at fc.ime.usp.br as bytes, a PDF or an image, read relative
///   to your document: `read("assets/ficha.pdf", encoding: none)`. It is placed at
///   the width of the text. For other sizes pass content, e.g.
///   `image("ficha.png", width: 12.5cm)` (the path is relative to the template,
///   so only bytes read in your own file can point into your project). Only the
///   first page of a PDF is used. none: the page carries a framed placeholder.
///   The page is printed for IME theses, or when a card is given.
/// - abstract-pt (content): The abstract in Portuguese (Mandatory).
/// - keywords-pt (array): List of keywords in Portuguese (Mandatory).
/// - abstract-en (content): The abstract in English (Mandatory).
/// - keywords-en (array): List of keywords in English (Mandatory).
/// - reference-pt (content): Bibliographic reference printed above the Portuguese
///   abstract (auto: built from author, Portuguese title, year, nature and institute;
///   none: omitted).
/// - reference-en (content): Same, above the English abstract, with the English title.
/// - dedication (content): Optional dedication.
/// - acknowledgments (content): Optional acknowledgments.
/// - epigraph (content): Optional epigraph.
/// - errata (content): Optional errata content.
/// - list-of-figures (bool or auto): Whether to include the list of figures (auto: show if >= 5).
/// - list-of-tables (bool or auto): Whether to include the list of tables (auto: show if >= 5).
/// - table-of-contents (bool): Whether to include the table of contents (Sumário).
/// - abbreviations (content): Optional list of abbreviations.
/// - symbols (content): Optional list of symbols.
/// - banca (array): List of jury member dictionaries ((nome: "", instituicao: "")).
/// - front-matter (bool): Whether to print the pre-textual elements (cover, title
///   page, abstracts, lists, table of contents...). With false only the body is
///   printed, in the same layout, numbered from page 1, whatever the other options.
/// - body (content): The document body.
#let usp-thesis(
  title: [Título da Dissertação],
  title-alt: none, 
  subtitle: none,
  author: "Nome do Autor",
  advisor: "Nome do Orientador",
  coadvisor: none,
  degree: "Mestre",
  program: "Nome do Programa",
  area: none,
  institute: "Instituto de Matemática e Estatística",
  local: "São Paulo",
  year: auto,
  month: auto,
  version: "Original",
  nature: none, 
  lang: "pt",
  font: "New Computer Modern",
  cover: true,
  title-page: true,
  version-page: true,
  catalog-card: none,
  abstract-pt: none,
  keywords-pt: (),
  abstract-en: none,
  keywords-en: (),
  reference-pt: auto,
  reference-en: auto,
  dedication: none,
  acknowledgments: none,
  epigraph: none,
  errata: none,
  list-of-figures: auto,
  list-of-tables: auto,
  table-of-contents: true,
  abbreviations: none,
  symbols: none,
  banca: (),
  front-matter: true,
  body,
) = {
  // Set global language for hyphenation and built-in terms (e.g. outline title),
  // and the font, before the cover so every page uses the same one.
  set text(lang: lang, font: font)

  // Dictionary for custom localized strings
  let i18n = (
    pt: (
      version: v => "Versão " + v,
      original-statement: (work, author) => [Esta é a versão original da #work elaborada pelo(a) candidato(a) #author, tal como submetida à Comissão Julgadora.],
      licence: [O conteúdo deste trabalho é publicado sob a licença CC BY 4.0 (Creative Commons Attribution 4.0 International License)],
      catalog-placeholder: [FICHA CATALOGRÁFICA NESTA PÁGINA \ ACESSE: FC.IME.USP.BR],
      work-msc: "dissertação",
      work-phd: "tese",
      program: "Programa: ",
      ime-full: "Instituto de Matemática, Estatística e Ciência da Computação",
      months: ("janeiro", "fevereiro", "março", "abril", "maio", "junho", "julho", "agosto", "setembro", "outubro", "novembro", "dezembro"),
      advisor: "Orientador: ",
      coadvisor: "Coorientador: ",
      acknowledgments: "AGRADECIMENTOS",
      nature-msc: "Dissertação",
      nature-phd: "Tese",
      errata: "ERRATA",
      figures: "Lista de Ilustrações",
      tables: "Lista de Tabelas",
      abbreviations: "Lista de Abreviaturas e Siglas",
      symbols: "Lista de Símbolos",
      abstract-title: "RESUMO",
      abstract-title-en: "ABSTRACT",
      summary-title: "Sumário",
      cover: "Capa",
      chapter: "Capítulo",
      keywords: "Palavras-chave: ",
      area: "Área de Concentração: ",
      title-msc: "Mestre em Ciências",
      title-phd: "Doutor em Ciências",
      labels: (
        author: "Autor",
        title: "Título",
        approved-on: "Aprovado em",
        banca: "Banca Examinadora",
        judgement: "Julgamento",
      ),
    ),
    en: (
      version: v => v + " Version",
      original-statement: (work, author) => [This is the original version of the #work prepared by the candidate #author, as submitted to the Examining Committee.],
      licence: [The content of this work is published under the CC BY 4.0 licence (Creative Commons Attribution 4.0 International License)],
      catalog-placeholder: [CATALOG CARD ON THIS PAGE \ — generate at fc.ime.usp.br],
      work-msc: "dissertation",
      work-phd: "thesis",
      program: "Program: ",
      ime-full: "Institute of Mathematics, Statistics and Computer Science",
      months: ("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"),
      advisor: "Advisor: ",
      coadvisor: "Co-advisor: ",
      acknowledgments: "ACKNOWLEDGMENTS",
      nature-msc: "Master's Dissertation",
      nature-phd: "Doctoral Thesis",
      errata: "ERRATA",
      figures: "List of Figures",
      tables: "List of Tables",
      abbreviations: "List of Abbreviations and Acronyms",
      symbols: "List of Symbols",
      abstract-title: "RESUMO",
      abstract-title-en: "ABSTRACT",
      summary-title: "Contents",
      cover: "Cover",
      chapter: "Chapter",
      keywords: "Keywords: ",
      area: "Concentration Area: ",
      title-msc: "Master of Science",
      title-phd: "Doctor of Science",
      labels: (
        author: "Author",
        title: "Title",
        approved-on: "Approved on",
        banca: "Examination Committee",
        judgement: "Judgement",
      ),
    ),
  ).at(lang)

  // Infer nature and institute-specifics
  // We check for "Mestre" or "Master" to identify Master's degrees
  let is-msc = degree.contains(regex("Mestr|Master"))
  let is-ime = institute.contains(regex("Matemática e Estatística|Matemática, Estatística e Ciência da Computação|Mathematics and Statistics|Mathematics, Statistics and Computer Science"))

  let actual-nature = if nature != none { nature } 
                      else if is-msc { i18n.nature-msc } 
                      else { i18n.nature-phd }

  // A bare degree level ("Mestre", "Doutor") gets the usual USP title
  // ("Mestre em Ciências"); a full title ("Mestre em Engenharia") is kept as is.
  let degree-title = if degree.contains(regex("\s(em|in|of)\s")) { degree }
                     else if is-msc { i18n.title-msc }
                     else { i18n.title-phd }

  let year-is-auto = year == auto
  let year = if year == auto { str(datetime.today().year()) } else { str(year) }

  // Month and year printed at the foot of the title page ("November 2026").
  // `month` is auto (the current month if `year` is auto too, else none), a
  // number 1-12 or a name.
  let month = if month == auto and not year-is-auto { none } else { month }
  let month-text = if month == none { none }
                   else if month == auto { i18n.months.at(datetime.today().month() - 1) }
                   else if type(month) == int { i18n.months.at(month - 1) }
                   else { month }
  let date-text = if month == none { year }
                  else if lang == "pt" { month-text + " de " + year }
                  else { month-text + " " + year }

  let version-text = (i18n.version)(version)

  // The IME gets its full name on the title page, whatever short form `institute` has.
  let institute-full = if is-ime { i18n.ime-full } else { institute }

  // Nature text, e.g. "Dissertação apresentada ao Instituto de Matemática,
  // Estatística e Ciência da Computação da Universidade de São Paulo para
  // obtenção do título de Mestre em Ciências." The program has its own line.
  let nature-text = if lang == "pt" {
    let article = if institute-full.starts-with(regex("Escola|Faculdade")) { " apresentada à " } else { " apresentada ao " }
    actual-nature + article + institute-full + " da Universidade de São Paulo para obtenção do título de " + degree-title + "."
  } else {
    actual-nature + " presented to the " + institute-full + " of the University of São Paulo in order to obtain the title of " + degree-title + "."
  }
  let program-text = i18n.program + program

  // Reference printed above each abstract, in the format of the IME-USP model:
  // "Name Surname. *Title*. Dissertação (Mestrado). Instituto de Matemática,
  // Estatística e Ciência da Computação, Universidade de São Paulo, São Paulo,
  // 2026." (the English one reads "Thesis (Master's). Institute of Mathematics,
  // Statistics and Computer Science, ...").
  // Each one carries the title in that abstract's language, so the secondary
  // one comes from `title-alt`; without it a highlighted placeholder stands in.
  let make-reference(ref-lang) = {
    let is-main = ref-lang == lang
    let ref-title = if is-main { title }
                    else if title-alt != none { title-alt }
                    else if ref-lang == "pt" { highlight[Título em português (`title-alt`)] }
                    else { highlight[Title in English (`title-alt`)] }
    let ref-subtitle = if is-main and subtitle != none [: #subtitle]
    let ref-nature = if ref-lang == "pt" {
      if is-msc { "Dissertação (Mestrado)" } else { "Tese (Doutorado)" }
    } else {
      if is-msc { "Thesis (Master's)" } else { "Thesis (Doctorate)" }
    }
    // The IME is printed with its current full name, in the language of the abstract.
    let ref-institute = if is-ime {
      if ref-lang == "pt" { "Instituto de Matemática, Estatística e Ciência da Computação" } else { "Institute of Mathematics, Statistics and Computer Science" }
    } else { institute }
    let university = if ref-lang == "pt" { "Universidade de São Paulo" } else { "University of São Paulo" }
    [#author. #strong(ref-title)#ref-subtitle. #ref-nature. #ref-institute, #university, #local, #year.]
  }
  let reference-pt = if reference-pt == auto { make-reference("pt") } else { reference-pt }
  let reference-en = if reference-en == auto { make-reference("en") } else { reference-en }

  // Without front matter only the body is printed, in the same layout.
  if front-matter {
    // 1. Cover
    if cover {
      // The cover has no heading: an invisible one gives it a PDF bookmark.
      {
        show heading: none
        heading(level: 1, numbering: none, outlined: false, bookmarked: true)[#i18n.cover]
      }
      cover-page(
        institution: if lang == "pt" { "Universidade de São Paulo\n" + institute } else { "University of São Paulo\n" + institute },
        author: author,
        title: title,
        subtitle: subtitle,
        local: local,
        year: year,
      )

      // Page numbering starts counting from title page (ABNT)
      counter(page).update(1)
    }

    // 2. Title Page
    if title-page {
      // The original version has its own page after the title page.
      let own-version-page = version-page and version == "Original"

      make-title-page(
        author: author,
        title: title,
        subtitle: subtitle,
        version: if own-version-page { none } else { version-text },
        nature: nature-text,
        program: program-text,
        area: area,
        area-label: i18n.area,
        advisor: i18n.advisor + advisor,
        coadvisor: if coadvisor != none { i18n.coadvisor + coadvisor } else { none },
        local: local,
        date: date-text,
      )

      // 2a. "Original version" page
      if own-version-page {
        make-version-page(
          author: author,
          title: title,
          subtitle: subtitle,
          statement: (i18n.original-statement)(
            if is-msc { i18n.work-msc } else { i18n.work-phd },
            author,
          ),
        )
      }

      // 2b. Catalog card (ficha catalográfica) and licence, on the verso of the
      // "original version" page (a framed placeholder without a card)
      // Only for the IME (whose model has it) or when a card is given.
      if catalog-card != none or is-ime {
        let card = if type(catalog-card) == bytes {
          image(catalog-card, width: 100%)
        } else { catalog-card }
        make-catalog-card-page(
          licence: i18n.licence,
          card: card,
          placeholder: i18n.catalog-placeholder,
        )
      }
    }
  }

  // Setup layout for pre-textual elements (margins and heading styles)
  show: setup-layout.with(lang: lang)

  if front-matter {
    // Hide page numbering until Introduction
    set page(numbering: none)

    // 3. Errata (Optional)
    if errata != none {
      heading(level: 1, numbering: none, outlined: false)[#i18n.errata]
      v(1cm)
      errata
      pagebreak()
    }

    // 4. Approval Sheet
    if banca.len() > 0 {
      approval-sheet(
        author: author,
        title: title,
        subtitle: subtitle,
        nature: nature-text + " " + program-text,
        banca: banca,
        labels: i18n.labels,
      )
    }

    // 5. Pre-textual elements
    if dedication != none {
      v(1fr)
      align(right)[#box(width: 60%, dedication)]
      pagebreak()
    }

    if acknowledgments != none {
      heading(level: 1, numbering: none, outlined: false)[#i18n.acknowledgments]
      v(1cm)
      acknowledgments
      pagebreak()
    }

    if epigraph != none {
      v(1fr)
      align(right)[#box(width: 60%, epigraph)]
      pagebreak()
    }

    if abstract-pt != none {
      abstract-page(
        i18n.abstract-title,
        abstract-pt,
        keywords-list: keywords-pt,
        keywords-label: if lang == "pt" { i18n.keywords } else { "Palavras-chave: " },
        reference: reference-pt,
      )
    }

    if abstract-en != none {
      abstract-page(
        i18n.abstract-title-en,
        abstract-en,
        keywords-list: keywords-en,
        keywords-label: if lang == "en" { i18n.keywords } else { "Keywords: " },
        reference: reference-en,
      )
    }

    // Lists (Conditional)
    context {
      let figures = query(figure.where(kind: image))
      let tables = query(figure.where(kind: table))

      let show-figures = if list-of-figures == auto { figures.len() >= 5 } else { list-of-figures }
      let show-tables = if list-of-tables == auto { tables.len() >= 5 } else { list-of-tables }

      if show-figures {
        heading(level: 1, numbering: none, outlined: false, bookmarked: true)[#i18n.figures]
        outline(title: none, target: figure.where(kind: image))
        pagebreak()
      }

      if show-tables {
        heading(level: 1, numbering: none, outlined: false, bookmarked: true)[#i18n.tables]
        outline(title: none, target: figure.where(kind: table))
        pagebreak()
      }
    }

    if abbreviations != none {
      heading(level: 1, numbering: none, outlined: false, bookmarked: true)[#i18n.abbreviations]
      v(1cm)
      abbreviations
      pagebreak()
    }

    if symbols != none {
      heading(level: 1, numbering: none, outlined: false, bookmarked: true)[#i18n.symbols]
      v(1cm)
      symbols
      pagebreak()
    }

    // Table of Contents (Sumário) - Must be the last pre-textual element
    if table-of-contents {
      heading(level: 1, numbering: none, outlined: false, bookmarked: true)[#i18n.summary-title]
      outline(title: none, indent: auto)
      pagebreak()
    }
  }

  // --- Start of Textual Elements ---
  
  // Show page numbering from here
  set page(numbering: "1", number-align: right + top)

  // Chapter (level-1) references print as "Chapter N"; `appendix` and `annex`
  // override the supplement.
  show heading.where(level: 1): set heading(supplement: i18n.chapter)

  body
}
