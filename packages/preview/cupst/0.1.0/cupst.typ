// ----------------------------------------------------------------------
// cupst.typ
// Email: sunjiao19@mails.ucas.ac.cn
//
// License: MIT License
// ----------------------------------------------------------------------
//
// ACKNOWLEDGEMENTS & DESIGN ORIGIN:
// The visual layout and design rules implemented in this Typst template
// are inspired by the `cup-journal.cls` LaTeX class for Cambridge
// University Press journals, originally developed by Paul Gessler
// (Overleaf) and others under the LPPL v1.3c license.
//
// This Typst implementation is a reimplementation of Cambridge University
// Press's Visual Layout. It is not officially associated with or
// endorsed by Cambridge University Press.
//
// ----------------------------------------------------------------------

#import "@preview/orchid:0.1.0"

// ============================================================
// Multi-language support
// ============================================================

#let lang-data = (
  en: (
    received: "Received",
    revised: "Revised",
    accepted: "Accepted",
    published: "Published",
    editor: "Editor",
    reviewers: "Reviewers",
    abstract: "Abstract",
    keywords: "Keywords",
    corresponding-author: [*\*Corresponding author:*],
    et-al: [~_et al._],
    acknowledgement: "Acknowledgements",
    reproducibility: "Reproducibility statement",
    opendata: "Open data statement",
    funding: "Funding statement",
    credit: "Author contributions",
    appendix: "Appendix",
    appendices: "Appendices",
    the-author-s: "The Author(s)",
    open-access-statement: "This is an Open Access article, distributed under the terms of the Creative Commons Attribution 4.0 International (CC BY 4.0) licence",
    which-permits: "which permits unrestricted re-use, distribution and reproduction, provided the original article is properly cited.",
    cite-article: [*Cite this article:*],
    preprint: "Preprint",
    vol: "Vol.",
    and0: "and",
    continued: " (continued)",
  ),
  zh: (
    received: "收稿",
    revised: "修订",
    accepted: "接收",
    published: "发表",
    editor: "责任编辑",
    reviewers: "审稿人",
    abstract: "摘要",
    keywords: "关键词",
    corresponding-author: [*\*通讯作者：*],
    et-al: [~等],
    acknowledgement: "致谢",
    reproducibility: "可重复性声明",
    opendata: "开放数据声明",
    funding: "资助声明",
    credit: "作者贡献",
    appendix: "附录",
    appendices: "附录",
    the-author-s: "作者",
    open-access-statement: "这是一篇开放获取文章，根据知识共享署名 4.0 国际 (CC BY 4.0) 许可协议的条款分发",
    which-permits: "允许不受限制地重复使用、分发和复制，前提是原文章被正确引用。",
    cite-article: [*引用本文：*],
    preprint: "预印本",
    vol: "卷",
    and0: "和",
    continued: "（续）",
  ),
  fr: (
    received: "Reçu",
    revised: "Révisé",
    accepted: "Accepté",
    published: "Publié",
    editor: "Éditeur",
    reviewers: "Examinateurs",
    abstract: "Résumé",
    keywords: "Mots-clés",
    corresponding-author: [*\*Auteur correspondant :*],
    et-al: [~_et al._],
    acknowledgement: "Remerciements",
    reproducibility: "Déclaration de reproductibilité",
    opendata: "Déclaration de données ouvertes",
    funding: "Déclaration de financement",
    credit: "Contributions des auteurs",
    appendix: "Annexe",
    appendices: "Annexes",
    the-author-s: "L'auteur / Les auteurs",
    open-access-statement: "Ceci est un article en libre accès, distribué selon les termes de la licence Creative Commons Attribution 4.0 International (CC BY 4.0)",
    which-permits: "qui permet une réutilisation, une distribution et une reproduction sans restriction, à condition que l'article original soit correctement cité.",
    cite-article: [*Citer cet article :*],
    preprint: "Prétirage",
    vol: "Vol.",
    and0: "et",
    continued: " (suite)",
  ),
  de: (
    received: "Eingegangen",
    revised: "Überarbeitet",
    accepted: "Akzeptiert",
    published: "Veröffentlicht",
    editor: "Redakteur",
    reviewers: "Gutachter",
    abstract: "Zusammenfassung",
    keywords: "Schlüsselwörter",
    corresponding-author: [*\*Korrespondierender Autor:*],
    et-al: [~_et al._],
    acknowledgement: "Danksagung",
    reproducibility: "Reproduzierbarkeitserklärung",
    opendata: "Open-Data-Erklärung",
    funding: "Förderungserklärung",
    credit: "Autorenbeiträge",
    appendix: "Anhang",
    appendices: "Anhänge",
    the-author-s: "Der Autor / Die Autoren",
    open-access-statement: "Dies ist ein Open-Access-Artikel, der unter den Bedingungen der Creative Commons Attribution 4.0 International (CC BY 4.0) Lizenz verbreitet wird",
    which-permits: "die uneingeschränkte Weiterverwendung, Verbreitung und Vervielfältigung gestattet, sofern der Originalartikel ordnungsgemäß zitiert wird.",
    cite-article: [*Diesen Artikel zitieren:*],
    preprint: "Vorabdruck",
    vol: "Bd.",
    and0: "und",
    continued: " (Fortsetzung)",
  ),
  es: (
    received: "Recibido",
    revised: "Revisado",
    accepted: "Aceptado",
    published: "Publicado",
    editor: "Editor",
    reviewers: "Revisores",
    abstract: "Resumen",
    keywords: "Palabras clave",
    corresponding-author: [*\*Autor de correspondencia:*],
    et-al: [~_et al._],
    acknowledgement: "Agradecimientos",
    reproducibility: "Declaración de reproducibilidad",
    opendata: "Declaración de datos abiertos",
    funding: "Declaración de financiación",
    credit: "Contribuciones de los autores",
    appendix: "Apéndice",
    appendices: "Apéndices",
    the-author-s: "El autor / Los autores",
    open-access-statement: "Este es un artículo de acceso abierto, distribuido bajo los términos de la licencia Creative Commons Attribution 4.0 International (CC BY 4.0)",
    which-permits: "que permite la reutilización, distribución y reproducción sin restricciones, siempre que se cite correctamente el artículo original.",
    cite-article: [*Citar este artículo:*],
    preprint: "Preimpresión",
    vol: "Vol.",
    and0: "y",
    continued: " (continuación)",
  ),
  ja: (
    received: "受領",
    revised: "改訂",
    accepted: "受理",
    published: "出版",
    editor: "編集者",
    reviewers: "査読者",
    abstract: "要旨",
    keywords: "キーワード",
    corresponding-author: [*\*責任著者：*],
    et-al: [~他],
    acknowledgement: "謝辞",
    reproducibility: "再現性声明",
    opendata: "オープンデータ声明",
    funding: "資金提供声明",
    credit: "著者の貢献",
    appendix: "付録",
    appendices: "付録",
    the-author-s: "著者",
    open-access-statement: "これはクリエイティブ・コモンズ 表示 4.0 国際 (CC BY 4.0) ライセンスの条件に従って配布されるオープンアクセス記事です",
    which-permits: "元の記事が適切に引用されている限り、無制限の再利用、配布、複製が許可されます。",
    cite-article: [*この記事を引用：*],
    preprint: "プレプリント",
    vol: "巻",
    and0: "および",
    continued: "（続き）",
  ),
  ru: (
    received: "Получено",
    revised: "Переработано",
    accepted: "Принято",
    published: "Опубликовано",
    editor: "Редактор",
    reviewers: "Рецензенты",
    abstract: "Аннотация",
    keywords: "Ключевые слова",
    corresponding-author: [*\*Ответственный автор:*],
    et-al: [~_и др._],
    acknowledgement: "Благодарности",
    reproducibility: "Заявление о воспроизводимости",
    opendata: "Заявление об открытых данных",
    funding: "Заявление о финансировании",
    credit: "Вклад авторов",
    appendix: "Приложение",
    appendices: "Приложения",
    the-author-s: "Автор(ы)",
    open-access-statement: "Это статья в открытом доступе, распространяемая на условиях лицензии Creative Commons Attribution 4.0 International (CC BY 4.0)",
    which-permits: "которая разрешает неограниченное повторное использование, распространение и воспроизведение при условии надлежащего цитирования оригинальной статьи.",
    cite-article: [*Цитировать эту статью:*],
    preprint: "Препринт",
    vol: "Т.",
    and0: "и",
    continued: " (продолжение)",
  ),
)

#let lang-state = state("cupst-lang", "en")
#let paper-size-state = state("cupst-paper-size", "medium")

#let paper-sizes = (
  large:  (width: 210mm, height: 280mm, margin: (left: 15mm, right: 14mm, top: 23mm, bottom: 17mm)),
  medium: (width: 174mm, height: 247mm, margin: (left: 18mm, right: 15mm, top: 23mm, bottom: 14mm)),
  small:  (width: 152mm, height: 228mm, margin: (left: 17mm, right: 15mm, top: 20mm, bottom: 15mm)),
)

// ============================================================
// Main document template
// ============================================================

#let cupst(
  // Metadata
  title: none,
  short-title: none,
  authors: (),
  affiliations: (),
  abstract: none,
  keywords: (),
  structure-color: rgb(0, 0, 0),
  link-color: rgb(0, 0, 255),
  
  // Article metadata
  manuscript: "article", // article, rescience, data, software, editorial, proceedings, poster
  layout: "preprint", // preprint, publish
  paper-size: "medium", // large (210×280mm, two-column), medium (174×247mm), small (152×228mm)
  column-gutter: 5mm,
  journal: "PREPRINT",
  year: datetime.today().year(),
  volume: none,
  doi: none,
  conference: none,
  
  // Dates
  received: none,
  revised: none,
  accepted: none,
  published: none,
  editor: none,
  reviewers: none,
  
  // Options
  show-dates: true,
  show-copyright: true,
  show-keywords: true,
  show-email: true,
  show-line-numbers: true,
  section-numbering: true,
  equation-numbering: "(1)",

  serif-fonts: ("Linux Libertine", "Libertinus Serif", "Times New Roman"),
  sans-fonts: ("Source Sans Pro", "Source Sans 3", "Arial"),
  
  // Multi-language
  lang: "en",
  
  // Content
  body
) = {
  // ============================================================
  // Language setup
  // ============================================================
  
  let current-lang = lang
  if lang not in lang-data {
    // Fallback to English and log error visually
    block[
      #set text(fill: red)
      *ERROR: Unsupported language '#lang', falling back to English.*
    ]
    current-lang = "en"
  }
  lang-state.update(current-lang)
  paper-size-state.update(paper-size)
  let dict = lang-data.at(current-lang)
  let tr(key) = dict.at(key)

  // ============================================================
  // Paper size configuration
  // ============================================================

  let psize = paper-sizes.at(paper-size)
  let is-twocol = paper-size == "large"

  // ============================================================
  // Page setup
  // ============================================================
  
  set page(
    width: psize.width,
    height: psize.height,
    margin: (
      left: psize.margin.left,
      right: psize.margin.right,
      top: psize.margin.top,
      bottom: psize.margin.bottom,
    ),
    columns: if is-twocol { 2 } else { 1 },
    header: context {
      let page-num = counter(page).get().first()
      if page-num > 1 {
        set text(size: 9pt)
        if calc.odd(page-num) {
          h(1fr)
          text(style: "italic")[#journal]
          h(1em)
          text(size: 10pt)[#page-num]
        } else {
          text(size: 10pt)[#page-num]
          h(1em)
          if authors.len() > 0 {
            authors.at(0).name
            if authors.len() > 1 [ #tr("et-al") ]
          }
          h(1fr)
        }
      } else {
        // Journal name and DOI
        set text(size: 8pt)
        block[
          #text(style: "italic")[#journal]
          #if layout == "publish" and year != none and volume != none [
            (#year), #tr("vol")#text(weight: "semibold")[#volume]
          ]
          #linebreak()
          #if layout == "publish" and doi != none [
            doi: #link("https://doi.org/" + doi)[#doi]
          ] else [
            ~
          ]
        ]
      }
    },
  )
  
  // ============================================================
  // Text and paragraph settings
  // ============================================================
  
  set text(
    font: serif-fonts,
    size: 10pt,
    lang: current-lang,
    hyphenate: false,
  )
  
  set par(
    justify: true,
    first-line-indent: 1em,
    spacing: 0.65em,
  )
  
  // ============================================================
  // Heading styles
  // ============================================================
  
  let heading-numbering = if section-numbering { "1." } else { none }
  set heading(numbering: heading-numbering)
  
  show heading: it => {
    set par(first-line-indent: 0pt)
    v(8pt, weak: true)
    text(
      font: sans-fonts,
      weight: "semibold",
      size: 10pt,
      fill: structure-color,
    )[
        #if it.numbering != none {
          counter(heading).display(it.numbering)
          h(0.5em)
        }
        #it.body
      ]
    h(1em)
  }
  
  show heading.where(level: 1): it => {
    set par(first-line-indent: 0pt)
    v(12pt, weak: true)
    block(
      text(
        font: sans-fonts,
        weight: "semibold",
        size: 12pt,
        fill: structure-color,
      )[
        #if it.numbering != none {
          counter(heading).display(it.numbering)
          h(0.5em)
        }
        #it.body
      ]
    )
    v(8pt, weak: true)
  }
  
  show heading.where(level: 2): it => {
    set par(first-line-indent: 0pt)
    v(10pt, weak: true)
    block(
      text(
        font: sans-fonts,
        weight: "semibold",
        size: 10pt,
        fill: structure-color,
      )[
        #if it.numbering != none {
          counter(heading).display(it.numbering)
          h(0.5em)
        }
        #it.body
      ]
    )
    v(7pt, weak: true)
  }
  
  show heading.where(level: 3): it => {
    set par(first-line-indent: 0pt)
    v(8pt, weak: true)
    block(
      text(
        font: sans-fonts,
        weight: "semibold",
        size: 10pt,
        fill: structure-color,
      )[
        #if it.numbering != none {
          counter(heading).display(it.numbering)
          h(0.5em)
        }
        #it.body
      ]
    )
    v(6pt, weak: true)
  }

  show <paragraph-title>: set text(
    fill: structure-color, 
    font: sans-fonts,
    weight: "semibold"
  )
  
  // ============================================================
  // Link and reference styling
  // ============================================================  
  show link: it => text(fill: link-color)[#underline(it)]
  show ref: it => text(fill: link-color)[#it]
  show cite: set text(fill: link-color)
  
  // ============================================================
  // Math equation styling
  // ============================================================
  set math.equation(numbering: equation-numbering)
  
  // ============================================================
  // Cambridge-core-like footnote
  // ============================================================
  show footnote.entry: it => {
    let loc = it.note.location()
    let number = numbering("1", ..counter(footnote).at(loc))
    [
      #text(
        fill: structure-color, 
        font: sans-fonts, 
        weight: "semibold"
      )[#number.]
      #it.note.body
    ]
  }
  
  // ============================================================
  // Figure and table styling
  // ============================================================
  
  set figure(placement: auto)
  set figure.caption(separator: [. ])
  
  show figure.caption: it => {
    set text(size: 9pt)
    text(
      font: sans-fonts,
    )[
      #text(weight: "semibold", fill: structure-color)[#it.supplement #context it.counter.display(it.numbering)]#it.separator#it.body
    ]
  }
  
  show figure.where(kind: table): set figure.caption(position: top)
  
  // ============================================================
  // List styling
  // ============================================================
  
  set list(indent: 1em, spacing: 0.5em, marker: [•])
  set enum(indent: 1em, spacing: 0.5em)
  
  // ============================================================
  // Helper functions
  // ============================================================
  
  // Get affiliation indices for an author
  let get-author-affil-indices(author) = {
    let indices = ()
    if "affiliation" in author {
      let affils = if type(author.affiliation) == array { 
        author.affiliation 
      } else { 
        (author.affiliation,) 
      }
      for affil in affils {
        let idx = affiliations.position(a => a.id == affil)
        if idx != none {
          indices.push(idx + 1)
        }
      }
    }
    indices
  }
  
  // Check if author is corresponding
  let is-corresponding(author) = {
    "email" in author and author.email != none
  }
  
  // ============================================================
  // Title page content
  // ============================================================
  
  // Build the title area content (used for both single and two-column modes)
  let title-area = {
    set par(first-line-indent: 0pt)
    
    // Manuscript type badge
    block[
      #text(
        font: sans-fonts,
        weight: "semibold",
        tracking: 1.5pt,
        fill: structure-color,
      )[
        #upper(manuscript.replace("-", " "))
      ] 
      #if layout == "preprint" [
        #text(
          font: sans-fonts,
          weight: "semibold",
          fill: structure-color,
        )[
          (_#tr("preprint")_)
        ]
      ]
    ]
    
    v(1em)
    
    // Title
    block[
      #text(
        font: sans-fonts,
        weight: "semibold",
        size: 14pt,
        fill: structure-color,
      )[#title]
    ]
    
    v(1em)
    
    // Authors
    block[
      #let author-parts = authors.enumerate().map(((i, author)) => {
        let indices = get-author-affil-indices(author)
        
        // Build superscript markers
        let markers = ()
        
        // Email marker
        if is-corresponding(author) {
          markers.push("*")
        }
        
        // Affiliation markers (only if multiple affiliations)
        if affiliations.len() > 1 and indices.len() > 0 {
          markers += indices.map(str)
        }
        
        let marker-text = if markers.len() > 0 {
          super(markers.join(","))
        } else { none }
        
        // ORCID
        let orcid = if "orcid" in author and author.orcid != none {
          h(2pt)
          orchid.generate-link(author.orcid)
        }
        
        [#author.name#marker-text#orcid]
      })
      
      // Join authors with commas and translated "and"
      #if author-parts.len() == 1 {
        author-parts.first()
      } else if author-parts.len() == 2 {
        [#author-parts.at(0) #tr("and0") #author-parts.at(1)]
      } else {
        for (i, part) in author-parts.enumerate() {
          if i == author-parts.len() - 1 {
            [, #tr("and0") #part]
          } else if i == 0 {
            part
          } else {
            [, #part]
          }
        }
      }
    ]
    
    v(0.7em)
    
    // Affiliations
    block[
      #set text(size: 9pt)
      #for (i, affil) in affiliations.enumerate() {
        if affiliations.len() > 1 {
          super[#(i + 1)]
        }
        affil.name
        linebreak()
      }
    ]
    
    v(0.5em)
    
    // Corresponding author email
    if show-email {
      let corresponding = authors.filter(is-corresponding)
      if corresponding.len() > 0 {
        block[
          #set text(size: 9pt)
          #tr("corresponding-author") #corresponding.map(a => {
            link("mailto:" + a.email)[#a.email]
          }).join("; ")
        ]
        v(0.5em)
      }
    }
    
    // Publication dates
    if layout == "publish" and show-dates {
      block[
        #set text(size: 9pt)
        (#tr("received"): #received\; #tr("revised"): #revised\; #tr("accepted"): #accepted\; #tr("published"): #published) \
        (#tr("editor"): #editor\; #tr("reviewers"): #reviewers)
      ]
      v(0.5em)
    }
  
    // Abstract
    if abstract != none {
      block(
        fill: structure-color.lighten(90%),
        inset: (x: 10pt, top: 8pt, bottom: 10pt),
        width: 100%,
        radius: 0pt,
      )[
        #set par(first-line-indent: 0pt)
        #text(
          font: sans-fonts,
          weight: "semibold",
          size: 10pt
        )[#tr("abstract")]
        #v(3pt)
        #text(size: 9pt)[#abstract]
      ]
      v(0.5em)
    }

    // Keywords
    if show-keywords and keywords.len() > 0 {
      block[
        #set par(first-line-indent: 0pt)
        #set text(size: 9pt)
        *#tr("keywords"):* #keywords.join(", ")
      ]
      v(0.3em)
    }
  }

  // Copyright notice for page 1 bottom
  let copyright-notice = if layout == "publish" and show-copyright {
    block(width: 100%, inset: (top: 0.5em))[
      #set text(size: 7pt)
      © #tr("the-author-s"), #year.
      #tr("open-access-statement")
      (#link("https://creativecommons.org/licenses/by/4.0/")), 
      #tr("which-permits")
    ]
  } else {
    none
  }

  // ============================================================
  // Title page content (spans both columns in two-column mode)
  // ============================================================

  context {
    if is-twocol and target() != "html" {
      place(top, scope: "parent", float: true, title-area)
      if copyright-notice != none {
        place(bottom + left, scope: "parent", float: true, clearance: 1em, copyright-notice)
      }
    } else {
      title-area
      if copyright-notice != none and target() != "html" {
        place(bottom + left, float: true, clearance: 1em, copyright-notice)
      } else if copyright-notice != none {
        copyright-notice
      }
    }
  }
  
  // ============================================================
  // Line numbers and body rendering
  // ============================================================

  if layout == "preprint" and show-line-numbers {
    set par.line(numbering: "1", numbering-scope: "page")
    body
  } else {
    body
  }

  if layout == "publish" and show-copyright {
    context {
      let cite-block = block(width: 100%, inset: (top: 0.5em))[
        #line(length: 30%, stroke: 0.5pt)
        #set text(size: 7pt)
        #set align(left)
        #tr("cite-article") #{
          if authors.len() > 0 {
            authors.at(0).name
            if authors.len() > 1 [ #tr("et-al") ]
          }
        } (#year). #title. #emph(journal) *#volume*#if doi != none [ , #link("https://doi.org/" + doi) ]
      ]

      if target() != "html" {
        if is-twocol {
          place(
            bottom + left,
            scope: "parent",
            float: true,
            clearance: 1em,
            cite-block
          )
        } else {
          place(
            bottom + left,
            float: true,
            clearance: 1em,
            cite-block
          )
        }
      } else {
        cite-block
      }
    }
  }
}

// ============================================================
// Full-width spanning (for two-column mode)
// ============================================================

/// Places content spanning both columns in two-column (`large`) mode.
/// In single-column (`medium` / `small`) mode, the content is rendered normally.
///
/// - `breakable`:
///   - When `false` (default): Placed as a floating block across both columns
///     at the top of the page (using `place(top, scope: "parent", float: true)`).
///     Suitable for figures and standard single-page tables.
///   - When `true`: Switches to a dedicated single-column page region
///     (`page(columns: 1, ...)`), allowing the table to naturally break
///     across multiple pages. (Triggers page breaks before and after).
///
/// ```typ
/// // Single-page float (figure / standard table)
/// #full-width[
///   #figure(
///     table(...),
///     caption: [A wide table spanning both columns.],
///   )
/// ]
///
/// // Multi-page table (e.g. in appendix or dedicated table section)
/// #full-width(breakable: true)[
///   #figure(
///     table(
///       columns: (1fr, 2fr, 2fr),
///       ..rows,
///     ),
///     caption: [A long table that spans multiple pages.],
///   )
/// ]
/// ```
#let full-width(breakable: false, body) = context {
  if target() == "html" {
    body
  } else if breakable {
    page(columns: 1, body)
  } else {
    place(top, scope: "parent", float: true, body)
  }
}

// ============================================================
// Multi-page Split Table (for two-column mode)
// ============================================================

/// Splits a long table across multiple pages in two-column mode without
/// forcing page breaks or leaving blank spaces. Each chunk floats to the
/// top of consecutive pages, while two-column body text flows naturally
/// underneath. Continuation captions automatically append " (continued)" or " (续)".
///
/// Supports native `table` syntax with comma-separated positional cells!
///
/// - `columns`: Table column definition (e.g. `(1fr, 2fr, 2fr)` or `3`).
/// - `caption`: Caption for the table.
/// - `label`: Optional label to attach to the first figure (e.g. `<tab:params>`).
/// - `header`: Optional header cells if not using `table.header(...)`.
/// - `rows-per-page`: Number of data rows per page chunk (default: `auto`, dynamically measured based on available page height).
/// - `max-height`: Maximum height per table chunk (default: `auto`, 70% of available page body height).
/// - `stroke`: Cell border stroke (default: `none` for academic three-line table).
/// - `align`: Cell alignment (default: `auto`).
/// - `continued-suffix`: Custom continuation suffix for subsequent page captions.
/// - `repeat-caption`: Whether to repeat the full caption text on continuation
///   pages (default: `true`). If `false`, subsequent pages directly display
///   `Table 1 (continued)` or `表 1 (续)` without repeating the title.
/// - `rows`: Optional named array of rows for backward compatibility.
/// - `..args`: Native table cells and `table.header(...)` elements.
///
/// ```typ
/// // Native table syntax — write cells directly!
/// #split-table(
///   columns: (1fr, 2fr, 2fr),
///   caption: [Complete parameter inventory across all experimental runs.],
///   label: <tab:params>,
///   repeat-caption: false, // subsequent pages show Table 1 (continued)
///   // rows-per-page defaults to auto (dynamically measured based on page height!)
///
///   table.header([*ID*], [*Param Name*], [*Value*]),
///   [1], [Learning Rate], [$1.0 times 10^(-3)$],
///   [2], [Batch Size], [2048],
///   [3], [Hidden Dim], [256],
///   // ... any number of cells!
/// )
/// ```
#let split-table(
  columns: (),
  rows: auto,
  caption: none,
  label: none,
  header: none,
  rows-per-page: auto,
  max-height: auto,
  stroke: none,
  align: auto,
  repeat-caption: true,
  continued-suffix: none,
  ..args,
) = context {
  let is-twocol = paper-size-state.get() == "large"
  let lang = lang-state.get()
  let lang-dict = lang-data.at(lang, default: lang-data.en)
  let default-suffix = [#(lang-dict.at("continued", default: " (continued)"))]
  let suffix = if continued-suffix != none { continued-suffix } else { default-suffix }

  let num-cols = if type(columns) == int { columns } else { columns.len() }

  // Extract header element and data cells from positional arguments
  let header-elem = none
  let all-cells = ()

  for arg in args.pos() {
    if arg.func() == table.header {
      header-elem = arg
    } else if arg.func() == table.hline {
      // Outer hlines are handled by our standard academic table format
    } else {
      all-cells.push(arg)
    }
  }

  // Row sizing for table (e.g. auto or list of lengths)
  let row-sizing = auto

  // Check if legacy nested array rows: (([..], [..]), ...) was passed
  if type(rows) == array and rows.len() > 0 and type(rows.at(0)) == array {
    for r in rows {
      for c in r {
        all-cells.push(c)
      }
    }
  } else {
    row-sizing = rows
  }

  // Slice into rows
  let row-list = ()
  let total-rows = calc.ceil(all-cells.len() / num-cols)
  for i in range(0, total-rows) {
    let start = i * num-cols
    let end = calc.min(all-cells.len(), start + num-cols)
    row-list.push(all-cells.slice(start, end))
  }

  // Determine header to repeat on each page
  let effective-header = if header-elem != none {
    header-elem
  } else if header != none and header.len() > 0 {
    table.header(..header)
  } else {
    none
  }

  // Get caption for a specific chunk index (chunk 0 is page 1, chunk > 0 is continuation)
  let get-caption(chunk-idx) = {
    if chunk-idx == 0 {
      caption
    } else if caption != none {
      if repeat-caption {
        [#caption#suffix]
      } else {
        // Output "Table 1 (continued)" without repeating caption content
        figure.caption(separator: none)[#suffix]
      }
    } else {
      none
    }
  }

  // Build the exact figure for a given chunk
  let make-fig(chunk-idx, chunk-rows) = {
    let cap = get-caption(chunk-idx)
    let tbl = table(
      columns: columns,
      rows: row-sizing,
      align: align,
      stroke: stroke,
      table.hline(stroke: 1.2pt),
      if effective-header != none {
        effective-header
      },
      table.hline(stroke: 0.6pt),
      ..chunk-rows.flatten(),
      table.hline(stroke: 1.2pt),
    )

    if chunk-idx == 0 and label != none {
      [#figure(tbl, caption: cap) #label]
    } else {
      figure(tbl, caption: cap)
    }
  }

  if target() == "html" {
    return make-fig(0, row-list)
  }

  // Page dimensions
  let psize = paper-sizes.at(paper-size-state.get(), default: paper-sizes.large)
  let page-body-h = psize.height - psize.margin.top - psize.margin.bottom
  let avail-w = psize.width - psize.margin.left - psize.margin.right

  // In single-column mode (paper-size != "large"):
  // If the entire table can fit on a single page, keep it as an intact single page (breakable: false).
  // Only when a single page cannot fit the table, allow it to break across pages naturally (breakable: true).
  if not is-twocol {
    let tbl = table(
      columns: columns,
      rows: row-sizing,
      align: align,
      stroke: stroke,
      table.hline(stroke: 1.2pt),
      if effective-header != none {
        effective-header
      },
      table.hline(stroke: 0.6pt),
      ..all-cells,
      table.hline(stroke: 1.2pt),
    )

    let test-fig = figure(tbl, caption: caption)
    let total-h = measure(box(width: avail-w, test-fig)).height
    let max-page-h = if max-height != auto {
      max-height
    } else {
      page-body-h * 0.85
    }

    if total-h <= max-page-h {
      // If it fits on one page, it remains on that single page without being split across pages
      if label != none {
        return [#figure(tbl, caption: caption) #label]
      } else {
        return figure(tbl, caption: caption)
      }
    } else {
      // if it does not fit on one page, it is then laid out to naturally span across pages
      return [
        #show figure.where(kind: table): set figure(placement: none)
        #show figure.where(kind: table): set block(breakable: true)
        #if label != none [
          #figure(tbl, caption: caption) #label
        ] else [
          #figure(tbl, caption: caption)
        ]
      ]
    }
  }

  // Calculate target height for a specific page chunk (two-column mode)
  let get-target-h(chunk-idx) = {
    if max-height == auto {
      page-body-h
    } else if type(max-height) == dictionary {
      if chunk-idx == 0 and "first" in max-height {
        max-height.first
      } else if "rest" in max-height {
        max-height.rest
      } else {
        page-body-h
      }
    } else if type(max-height) == array {
      if chunk-idx < max-height.len() {
        max-height.at(chunk-idx)
      } else {
        max-height.last()
      }
    } else {
      max-height
    }
  }

  // Chunk rows by rows-per-page or automatically by measured height
  let chunks = ()
  let current-chunk = ()

  if rows-per-page != auto {
    for row in row-list {
      current-chunk.push(row)
      if current-chunk.len() >= rows-per-page {
        chunks.push(current-chunk)
        current-chunk = ()
      }
    }
    if current-chunk.len() > 0 {
      chunks.push(current-chunk)
    }
  } else {
    // Dynamic height calculation per page:
    // Each page is measured separately using its exact caption (full caption for page 1 vs
    // continuation caption for page 2+) and each row's actual multi-line content height!
    let avail-w = psize.width - psize.margin.left - psize.margin.right

    for row in row-list {
      let test-chunk = current-chunk + (row,)
      let chunk-idx = chunks.len()
      let target-h = get-target-h(chunk-idx)
      let trial-fig = make-fig(chunk-idx, test-chunk)
      let measured-h = measure(box(width: avail-w, trial-fig)).height

      if measured-h > target-h and current-chunk.len() > 0 {
        chunks.push(current-chunk)
        current-chunk = (row,)
      } else {
        current-chunk = test-chunk
      }
    }
    if current-chunk.len() > 0 {
      chunks.push(current-chunk)
    }
  }

  for (i, chunk) in chunks.enumerate() {
    if i > 0 {
      counter(figure.where(kind: table)).update(n => n - 1)
    }

    let fig = make-fig(i, chunk)

    if i < chunks.len() - 1 {
      // Table has not ended yet: occupy 100% height so no body text infiltrates the bottom whitespace
      place(top, scope: "parent", float: true, block(width: 100%, height: 100%, fig))
    } else {
      // Final chunk: take only natural height so body text CAN continue in the remaining space
      place(top, scope: "parent", float: true, fig)
    }
  }
}

#let full-width-table = split-table

// ============================================================
// Paragraph 
// ============================================================
#let paragraph(title, body) = context {
  if target() != "html" {
    place(hide(heading(level: 1, numbering: none)[#title]))
  }
  set par(first-line-indent: 0pt)
  v(1em)
  [#title<paragraph-title>] 
  " "
  body
}

// ============================================================
// Special sections (unnumbered)
// ============================================================

#let acknowledgement(body) = context {
  let dict = lang-data.at(lang-state.get(), default: lang-data.en)
  paragraph(dict.acknowledgement)[#body]
}

#let reproduce(body) = context {
  let dict = lang-data.at(lang-state.get(), default: lang-data.en)
  paragraph(dict.reproducibility)[#body]
}

#let opendata(body) = context {
  let dict = lang-data.at(lang-state.get(), default: lang-data.en)
  paragraph(dict.opendata)[#body]
}

#let funding(body) = context {
  let dict = lang-data.at(lang-state.get(), default: lang-data.en)
  paragraph(dict.funding)[#body]
}

#let credit(body) = context {
  let dict = lang-data.at(lang-state.get(), default: lang-data.en)
  paragraph(dict.credit)[#body]
}


#let appendix(body) = context {
  let dict = lang-data.at(lang-state.get(), default: lang-data.en)
  
  set heading(numbering: (..nums) => {
    let parts = nums.pos()
    let first = numbering("A.", parts.at(0))

    if parts.len() == 1 {
      return first
    }
    
    let rest = parts.slice(1).map(n => numbering("1.", n))
    return first + " " + rest.join(" ")
  }, supplement: dict.appendix)

  heading(dict.appendices, numbering: none)

  counter(heading).update(0)
  body
}

// ============================================================
//
// This work consists of the file cupst.typ.
// 
// End of file 'cupst.typ'.
