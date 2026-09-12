// ITU Graduate Thesis Template — Typst edition
// Istanbul Technical University · Graduate School
//
// This template is a Typst rewrite of the official LaTeX class
// (itutez.cls v1.7.1, January 2025). It produces the official elements:
//   · Outer cover + Turkish inner cover + English inner cover
//   · Jury approval/signature page ("KABUL VE ONAY")
//   · Dedication, Foreword, Table of Contents, Abbreviations, Symbols
//   · List of Tables, List of Figures
//   · Özet / Summary (Turkish and English abstracts)
//   · Roman page numbers (i, ii, …) in front matter, Arabic (1, 2, …) in body
//   · Numbered chapters and unnumbered front/back-matter headings
//   · Appendices (+ "EKLER" cover), Bibliography, Curriculum Vitae

#let thesis(
  // ===== PERSONAL INFORMATION =====
  name: "",
  surname: "",
  student-id: "",

  // ===== THESIS TITLES (up to 3 lines) =====
  title-tr: ("", "", ""),   // Turkish (outer cover + Turkish inner cover)
  title-en: ("", "", ""),   // English (English inner cover + approval page)

  // ===== ACADEMIC INFORMATION =====
  department-tr: "",
  department-en: "",
  program-tr: "",
  program-en: "",
  // institute: "graduate" | "informatics" | "science" | "social-sciences" | "energy" | "eurasia"
  institute: "graduate",

  // ===== ADVISOR =====
  advisor-tr: "",
  advisor-univ-tr: "",
  advisor-en: "",
  advisor-univ-en: "",
  co-advisor-tr: "",
  co-advisor-univ-tr: "",
  co-advisor-en: "",
  co-advisor-univ-en: "",

  // ===== JURY MEMBERS =====
  // Array of (name: "...", univ: "...") dictionaries
  jury: (),

  // ===== DATES =====
  cover-date-tr: "",        // Date on the covers (e.g. "Aralık 2024")
  cover-date-en: "",
  submission-date-tr: "",   // Submission date on the approval page (e.g. "22 Eylül 2024")
  submission-date-en: "",
  defense-date-tr: "",      // Defense date on the approval page (e.g. "21 Aralık 2024")
  defense-date-en: "",

  // ===== SETTINGS =====
  lang: "tr",               // "tr" | "en"
  degree: "masters",        // "masters" | "phd"
  binding: "hardcover",     // "hardcover" (cloth/bez) | "softcover" (cardboard/karton)
  // printing: "two-sided" (blank pages + gutter margins, cls default)
  //           "one-sided" (no blank pages, fixed left margin)
  printing: "two-sided",

  // ===== FRONT/BACK MATTER (content blocks) =====
  dedication: none,         // Dedication text (e.g. "Aileme,")
  foreword: none,           // Foreword content
  abbreviations: none,      // Abbreviations table/content
  symbols: none,            // Symbols table/content
  abstract-tr: none,        // Turkish abstract (ÖZET) content, incl. keywords
  abstract-en: none,        // English abstract (SUMMARY) content, incl. keywords
  list-of-figures: true,    // Produce the List of Figures?
  list-of-tables: true,     // Produce the List of Tables?
  bibliography: none,       // Pass a bibliography(...) call here
  appendices: none,         // Appendices content
  cv: none,                 // Curriculum vitae content

  body,
) = {
  // ---- Language ----
  let is-english = lang == "en" or lang == "english"
  let lang-code = if is-english { "en" } else { "tr" }

  // ---- Printing (two-/one-sided) ----
  // cls onluarkali = twoside: chapters/covers start on a recto (right) page,
  // blank pages are inserted and margins alternate for binding (\BolumSagdaKalsin).
  let twoside = printing != "one-sided"
  // Advance to the next recto (odd) page, inserting a blank verso if needed.
  // In one-sided printing this is just a regular page break.
  let next-recto-page = if twoside { pagebreak(to: "odd", weak: true) } else { pagebreak(weak: true) }

  // ---- Institute names ----
  let institute-tr = (
    "graduate": "Lisansüstü Eğitim Enstitüsü",
    "informatics": "Bilişim Enstitüsü",
    "science": "Fen Bilimleri Enstitüsü",
    "social-sciences": "Sosyal Bilimler Enstitüsü",
    "energy": "Enerji Enstitüsü",
    "eurasia": "Avrasya Yer Bilimleri Enstitüsü",
  ).at(institute, default: "Lisansüstü Eğitim Enstitüsü")
  let institute-en = (
    "graduate": "Graduate School",
    "informatics": "Informatics Institute",
    "science": "Graduate School of Science Engineering and Technology",
    "social-sciences": "Graduate School of Social Sciences",
    "energy": "Energy Institute",
    "eurasia": "Eurasia Institute of Earth Sciences",
  ).at(institute, default: "Graduate School")

  // ---- Uppercase conversion ----
  // upper() uses the Unicode default mapping and does not apply the Turkish
  // "i → İ" rule (it would produce the wrong "İÇINDEKILER"). General fix:
  // replace the only problematic letter "i" with "İ" before upper(); the other
  // letters (ç, ş, ğ, ö, ü, ı) are converted correctly by upper() already.
  // English text uses plain upper().
  let tr-upper(s) = upper(str(s).replace("i", "İ"))
  let en-upper(s) = upper(str(s))

  let institute-header-tr = tr-upper("İstanbul Teknik Üniversitesi ★ " + institute-tr)
  let institute-header-en = en-upper("İstanbul Technical University ★ " + institute-en)

  // ---- Thesis level ----
  let degree-label-tr = if degree == "phd" { "DOKTORA TEZİ" } else { "YÜKSEK LİSANS TEZİ" }
  let degree-label-en = if degree == "phd" { "Ph.D. THESIS" } else { "M.Sc. THESIS" }

  let full-name = (name + " " + surname).trim()

  // ---- Helper joining the title lines (case-fn: case-conversion function) ----
  let title-block(lines, case-fn) = {
    let cleaned = lines.filter(s => s != none and str(s).trim() != "")
    text(size: 14pt, weight: "bold")[
      #cleaned.map(s => case-fn(s)).join(linebreak())
    ]
  }

  // =====================================================================
  //  GLOBAL SETTINGS
  // =====================================================================
  set document(title: title-tr.at(0, default: ""), author: full-name)
  set text(
    font: ("Times New Roman", "Libertinus Serif"),
    size: 12pt,
    lang: lang-code,
    hyphenate: false,   // as in the LaTeX template (hyphenpenalty=10000): no hyphenation
  )
  set par(leading: 1.45em, spacing: 0.6em, justify: true)
  show math.equation: set block(spacing: 0.65em)

  // ---- Heading styles ----
  // Per LaTeX itutez.cls (\@makechapterhead): body chapters appear as "1. TITLE"
  // (NO "BÖLÜM" prefix), 12pt bold, left-aligned. Front/back-matter headings unnumbered.
  show heading: it => {
    let numbered = it.numbering != none
    if it.level == 1 {
      // cls: level-1 headings (chapters / front-back matter) start on a recto page
      next-recto-page
      v(18.5mm)
      if numbered {
        text(weight: "bold", size: 12pt)[#counter(heading).display() #it.body]
      } else {
        text(weight: "bold", size: 12pt)[#it.body]
      }
      v(12pt)
    } else if it.level == 2 {
      v(12pt)
      if numbered {
        text(weight: "bold", size: 12pt)[#counter(heading).display() #it.body]
      } else {
        text(weight: "bold", size: 12pt)[#it.body]
      }
      v(8pt)
    } else if it.level == 3 {
      v(8pt)
      if numbered {
        text(weight: "bold", size: 12pt)[#counter(heading).display() #it.body]
      } else {
        text(weight: "bold", size: 12pt)[#it.body]
      }
      v(4pt)
    } else {
      v(6pt)
      if numbered {
        text(weight: "bold", size: 12pt)[#counter(heading).display() #it.body]
      } else {
        text(weight: "bold", size: 12pt)[#it.body]
      }
    }
  }

  // ---- Figures and tables ----
  let figure-supplement = if is-english { "Figure" } else { "Şekil" }
  let table-supplement = if is-english { "Table" } else { "Çizelge" }
  show figure.where(kind: image): set figure(supplement: figure-supplement)
  show figure.where(kind: table): set figure(supplement: table-supplement)
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.caption: it => {
    text(weight: "bold")[#it.supplement #it.counter.display(): #it.body]
  }

  // =====================================================================
  //  COVERS  (unnumbered pages, narrow margins)
  // =====================================================================
  set page(
    paper: "a4",
    margin: (left: 2cm, right: 2cm, top: 2cm, bottom: 2cm),
    numbering: none,
  )

  // ---- Skeleton for a single cover page ----
  // Vertical gaps follow the cls th@DisKapak/IcKapak values (55/55/27/14/22 mm)
  // so that the date sits at the bottom of the page.
  let cover(header, title-content, degree-label, author-line, department, program, advisor-line, date) = {
    set par(justify: false, leading: 0.65em)
    align(center)[
      #underline(text(weight: "bold")[#header])
      #v(55mm)
      #title-content
      #v(55mm)
      #text(weight: "bold")[#degree-label]
      #v(8mm)
      #text(weight: "bold")[#author-line]
      #v(27mm)
      #text(weight: "bold")[#department]
      #v(2mm)
      #text(weight: "bold")[#program]
      #if advisor-line != none {
        v(14mm)
        advisor-line
      } else {
        v(14mm)
      }
      #v(22mm)
      #text(weight: "bold")[#date]
    ]
  }

  // (1) OUTER COVER
  cover(
    if is-english { institute-header-en } else { institute-header-tr },
    if is-english { title-block(title-en, en-upper) } else { title-block(title-tr, tr-upper) },
    if is-english { degree-label-en } else { degree-label-tr },
    full-name,
    if is-english { department-en } else { department-tr },
    if is-english { program-en } else { program-tr },
    // Hardcover has no advisor on the outer cover; softcover does
    if binding == "softcover" {
      let label = if is-english { "Thesis Advisor" } else { "Tez Danışmanı" }
      text(weight: "bold")[#label: #(if is-english { advisor-en } else { advisor-tr })]
    } else { none },
    if is-english { cover-date-en } else { cover-date-tr },
  )
  next-recto-page

  // (2) TURKISH INNER COVER
  let advisor-block-tr = {
    text(weight: "bold")[Tez Danışmanı: #advisor-tr]
    if co-advisor-tr.trim() != "" {
      linebreak()
      text(weight: "bold")[Eş Danışman: #co-advisor-tr]
    }
  }
  cover(
    institute-header-tr, title-block(title-tr, tr-upper), degree-label-tr,
    [#full-name (#student-id)],
    department-tr, program-tr, advisor-block-tr, cover-date-tr,
  )
  next-recto-page

  // (3) ENGLISH INNER COVER
  let advisor-block-en = {
    text(weight: "bold")[Thesis Advisor: #advisor-en]
    if co-advisor-en.trim() != "" {
      linebreak()
      text(weight: "bold")[Co-Advisor: #co-advisor-en]
    }
  }
  cover(
    institute-header-en, title-block(title-en, en-upper), degree-label-en,
    [#full-name (#student-id)],
    department-en, program-en, advisor-block-en, cover-date-en,
  )

  // =====================================================================
  //  JURY APPROVAL / SIGNATURE PAGE  ("KABUL VE ONAY")
  // =====================================================================
  {
    set par(justify: true, leading: 1.1em)
    next-recto-page
    v(18mm)

    // Statement paragraph
    let degree-word-tr = if degree == "phd" { "Doktora" } else { "Yüksek Lisans" }
    let degree-word-en = if degree == "phd" { "Ph.D." } else { "M.Sc." }
    let quoted-title-tr = title-tr.filter(s => str(s).trim() != "").map(s => tr-upper(s)).join(" ")
    let quoted-title-en = title-en.filter(s => str(s).trim() != "").map(s => en-upper(s)).join(" ")

    if is-english {
      [#full-name, a #degree-word-en student of ITU #institute-en student ID #student-id, successfully defended the thesis entitled "#quoted-title-en", which he/she prepared after fulfilling the requirements specified in the associated legislations, before the jury whose signatures are below.]
    } else {
      [İTÜ #institute-tr'nün #student-id numaralı #degree-word-tr Öğrencisi #full-name, ilgili yönetmeliklerin belirlediği gerekli tüm şartları yerine getirdikten sonra hazırladığı "#quoted-title-tr" başlıklı tezini aşağıda imzaları olan jüri önünde başarı ile sunmuştur.]
    }

    v(14mm)

    // Signature rows
    let dots = "."*30
    let signature-row(role, person, univ) = (
      text(weight: "bold")[#role], [#text(weight: "bold")[#person] \ #univ], align(right)[#dots],
    )
    let empty-row = ([], [], [])

    let advisor-role = if is-english { "Thesis Advisor :" } else { "Tez Danışmanı :" }
    let co-advisor-role = if is-english { "Co-advisor :" } else { "Eş Danışman :" }
    let jury-role = if is-english { "Jury Members :" } else { "Jüri Üyeleri :" }

    let rows = ()
    rows += signature-row(advisor-role,
      if is-english { advisor-en } else { advisor-tr },
      if is-english { advisor-univ-en } else { advisor-univ-tr })
    if (if is-english { co-advisor-en } else { co-advisor-tr }).trim() != "" {
      rows += empty-row
      rows += signature-row(co-advisor-role,
        if is-english { co-advisor-en } else { co-advisor-tr },
        if is-english { co-advisor-univ-en } else { co-advisor-univ-tr })
    }
    // Jury members
    for (i, member) in jury.enumerate() {
      rows += empty-row
      rows += signature-row(if i == 0 { jury-role } else { "" }, member.name, member.at("univ", default: ""))
    }

    grid(
      columns: (34mm, 1fr, auto),
      row-gutter: 10pt,
      column-gutter: 4pt,
      align: (left + top, left + top, right + bottom),
      ..rows,
    )

    v(8mm)
    let submission-label = if is-english { "Date of Submission :" } else { "Teslim Tarihi :" }
    let defense-label = if is-english { "Date of Defense :" } else { "Savunma Tarihi :" }
    grid(
      columns: (auto, auto),
      row-gutter: 6pt,
      column-gutter: 8pt,
      text(weight: "bold")[#submission-label],
      text(weight: "bold")[#(if is-english { submission-date-en } else { submission-date-tr })],
      text(weight: "bold")[#defense-label],
      text(weight: "bold")[#(if is-english { defense-date-en } else { defense-date-tr })],
    )
  }

  // =====================================================================
  //  FRONT MATTER  (roman numerals, regular margins)
  // =====================================================================
  // Advance to a recto page BEFORE resetting the page counter so that the
  // visible roman numbers stay aligned with the physical page parity.
  next-recto-page
  // Two-sided: inner (binding) 4 cm / outer 2.5 cm gutter; one-sided: fixed left 4 cm
  set page(
    margin: if twoside {
      (inside: 4cm, outside: 2.5cm, top: 2.5cm, bottom: 2.5cm)
    } else {
      (left: 4cm, right: 2.5cm, top: 2.5cm, bottom: 2.5cm)
    },
    numbering: "i",
    number-align: center + bottom,
  )
  counter(page).update(1)

  // Front/back-matter headings are unnumbered
  set heading(numbering: none)
  // LaTeX uses single spacing in front matter (\singlespacing); body is 1.5 (\oneandonehalf)
  set par(leading: 0.65em)
  // cls uses \leaders with spaced dot fill (TOC + list of tables/figures);
  // Typst's default fill is too dense, so add a gap between the dots.
  set outline.entry(fill: repeat(gap: 2.5pt)[.])

  // "Sayfa" / "Page" column header (cls: \cftaftertoctitle ... \bf\underline{Sayfa})
  let page-label = if is-english { "Page" } else { "Sayfa" }

  // ---- DEDICATION ---- (cls: \vspace*{0.4\textheight}, then right-aligned)
  if dedication != none and str(dedication).trim() != "" {
    v(40%)
    align(right)[#emph(strong(dedication))]
    pagebreak(weak: true)
  }

  // ---- FOREWORD ----
  if foreword != none {
    heading(level: 1, if is-english { "FOREWORD" } else { "ÖNSÖZ" })
    foreword
  }

  // ---- TABLE OF CONTENTS ----
  // cls adds the TOC to its own list as well (\addcontentsline{toc}{chapter}{...\contentsnameToC})
  heading(level: 1, if is-english { "TABLE OF CONTENTS" } else { "İÇİNDEKİLER" })
  align(right)[#strong(underline(page-label))]
  [
    // Chapter and front/back-matter (level-1) entries are bold — as in the cls
    #show outline.entry.where(level: 1): strong
    #outline(title: none, depth: 4, indent: auto)
  ]

  // ---- ABBREVIATIONS ----
  if abbreviations != none {
    heading(level: 1, if is-english { "ABBREVIATIONS" } else { "KISALTMALAR" })
    abbreviations
  }

  // ---- SYMBOLS ----
  if symbols != none {
    heading(level: 1, if is-english { "SYMBOLS" } else { "SEMBOLLER" })
    symbols
  }

  // ---- LIST OF TABLES ----
  if list-of-tables {
    heading(level: 1, if is-english { "LIST OF TABLES" } else { "ÇİZELGE LİSTESİ" })
    align(right)[#strong(underline(page-label))]
    outline(title: none, target: figure.where(kind: table))
  }

  // ---- LIST OF FIGURES ----
  if list-of-figures {
    heading(level: 1, if is-english { "LIST OF FIGURES" } else { "ŞEKİL LİSTESİ" })
    align(right)[#strong(underline(page-label))]
    outline(title: none, target: figure.where(kind: image))
  }

  // ---- ÖZET / SUMMARY ----
  // Turkish theses put ÖZET first; English theses put SUMMARY first
  let abstract-tr-block = if abstract-tr != none {
    heading(level: 1, "ÖZET")
    abstract-tr
  }
  let abstract-en-block = if abstract-en != none {
    heading(level: 1, "SUMMARY")
    abstract-en
  }
  if is-english {
    abstract-en-block
    abstract-tr-block
  } else {
    abstract-tr-block
    abstract-en-block
  }

  // Body and everything after (bibliography, appendices, CV) return to 1.5 line spacing
  set par(leading: 1.45em)

  // =====================================================================
  //  BODY  (arabic numerals, numbered chapters — first chapter on a recto page)
  // =====================================================================
  // Reset the counter on a physical odd page (parity alignment) — first chapter starts recto
  next-recto-page
  set page(numbering: "1")
  counter(page).update(1)
  counter(heading).update(0)
  [
    // cls: chapters (level 1) are "1.", subheadings "1.1", "1.1.1", ...
    // The trailing dot is built into the numbering so body and TOC look the same.
    #set heading(numbering: (..n) => {
      let p = n.pos()
      if p.len() == 1 { numbering("1.", p.at(0)) } else { numbering("1.1.1.1", ..p) }
    })
    #set par(leading: 1.45em)   // body: 1.5 line spacing (\oneandonehalf)
    #body
  ]

  // =====================================================================
  //  BIBLIOGRAPHY
  // =====================================================================
  if bibliography != none {
    bibliography
  }

  // =====================================================================
  //  APPENDICES
  // =====================================================================
  if appendices != none {
    heading(level: 1, if is-english { "APPENDICES" } else { "EKLER" })
    appendices
  }

  // =====================================================================
  //  CURRICULUM VITAE
  // =====================================================================
  if cv != none {
    heading(level: 1, if is-english { "CURRICULUM VITAE" } else { "ÖZGEÇMİŞ" })
    // In the cls the CV is plain text; keep any headings inside it out of the TOC.
    {
      set heading(outlined: false)
      cv
    }
  }
}
