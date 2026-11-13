// ITU Graduate Thesis Template — Typst edition
// Istanbul Technical University · Graduate School
//
// This template is a Typst rewrite of the official LaTeX class
// (itutez.cls, template v2.0.0, October 2026 — generated from the official
// MS Word templates). It produces the official elements:
//   · Outer cover + inner covers (thesis language first, then the other one)
//   · Jury approval page + academic integrity declaration
//   · Dedication, Preface, Table of Contents, Abbreviations, Symbols
//   · List of Tables, List of Figures
//   · Özet / Abstract (Turkish and English abstracts)
//   · Roman page numbers (i, ii, …) in front matter, Arabic (1, 2, …) in body
//   · Numbered chapters and unnumbered front/back-matter headings
//   · Appendices (+ "EKLER" heading), Bibliography, Curriculum Vitae

// ---- Line spacing (cls: \defbaselineskip = 13.8pt, Word single spacing for 12 pt Times) ----
// Typst measures leading from the baseline to the cap height of the next line
// (Times cap height = 7.945pt at 12 pt), so leading = baseline distance − 7.945pt.
#let _single = 5.855pt     // single spacing:  13.8 pt baseline-to-baseline
#let _onehalf = 12.755pt   // 1.5 spacing:     20.7 pt baseline-to-baseline
#let _parskip = 12pt       // cls \parskip: 6 pt before + 6 pt after each paragraph

// =====================================================================
//  HELPERS FOR CONTENT FILES (exported)
// =====================================================================

/// Abbreviation / symbol list entry (cls \kisaltma, \sembol): bold "term:" in a
/// 25 mm column; continuation lines of the description align with its first line.
#let abbreviation(term, description) = context {
  let label = strong[#term:]
  par(hanging-indent: 25mm, {
    if measure(label).width < 25mm { box(width: 25mm, label) } else { label + [ ] }
    description
  })
}
#let symbol-entry = abbreviation

/// CV section heading (cls \cvbaslik), e.g. #cv-heading[ÖĞRENİM GEÇMİŞİ]
#let cv-heading(title) = block(above: 12pt + _single + _parskip, below: _single, sticky: true, strong(title))
/// CV education line (cls \cvogrenim): bold degree in a 30 mm column, bold colon, details.
#let cv-education(degree, details) = par(hanging-indent: 30mm)[#box(width: 30mm, strong(degree))*:* #details]
/// CV publication entry (cls \cvyayin): 1.25 cm hanging indent.
#let cv-publication(entry) = par(hanging-indent: 12.5mm, entry)

// =====================================================================
//  INPUT CHECKS (poka-yoke)
//  Reject values that would silently produce a wrong thesis (e.g. a typo in
//  `degree` printing "YÜKSEK LİSANS TEZİ" on a PhD cover) and accept common
//  alternative spellings, including the LaTeX class option names.
//  Only definite mistakes are errors: Typst has no warnings, and an error
//  stops compilation, so incomplete drafts (empty fields) are allowed.
// =====================================================================
#let _fail(msg) = panic("community-itu-thesis: " + msg)

#let _has(x) = if x == none { false } else if type(x) == str { x.trim() != "" } else if type(x) == content { x != [] } else { true }

// Lowercase, drop Turkish diacritics and unify separators: "Yüksek Lisans" → "yuksek-lisans"
#let _norm(s) = {
  let s = lower(s.trim()).replace("\u{307}", "")
  for (a, b) in (("ı", "i"), ("ü", "u"), ("ş", "s"), ("ç", "c"), ("ğ", "g"), ("ö", "o"), (" ", "-"), ("_", "-")) {
    s = s.replace(a, b)
  }
  s
}

// Map a setting to its canonical value; options: (canonical: (alias, ...), ...)
#let _choice(param, value, options) = {
  let key = if type(value) == str { _norm(value) } else { value }
  for (canonical, aliases) in options {
    if key == canonical or key in aliases { return canonical }
  }
  _fail("invalid `" + param + "`: " + repr(value) + ". Valid values: "
    + options.keys().map(k => "\"" + k + "\"").join(", ") + ".")
}

// Title: a single string/content or an array of up to 3 lines (official limit)
#let _title(param, value) = {
  let lines = if type(value) == array { value } else { (value,) }
  lines = lines.filter(_has)
  if lines.len() > 3 {
    _fail("`" + param + "` has " + str(lines.len()) + " lines; the official template allows at most 3.")
  }
  lines
}

// Jury: accepts (name: ..., univ: ...), ("Name", "University") or "Name" entries,
// and a single member written without the trailing comma.
#let _jury(value) = {
  let members = if type(value) == dictionary { (value,) } else { value }
  if type(members) != array {
    _fail("`jury` must be an array of (name: \"...\", univ: \"...\") entries.")
  }
  members.map(m => {
    if type(m) == dictionary {
      for k in m.keys() {
        if k not in ("name", "univ") {
          _fail("unknown key `" + k + "` in jury member " + repr(m) + "; use (name: \"...\", univ: \"...\").")
        }
      }
      if "name" not in m { _fail("jury member without `name`: " + repr(m)) }
      (name: m.name, univ: m.at("univ", default: none))
    } else if type(m) == array and m.len() in (1, 2) {
      (name: m.at(0), univ: m.at(1, default: none))
    } else if type(m) in (str, content) {
      (name: m, univ: none)
    } else {
      _fail("invalid jury member: " + repr(m) + ". Use (name: \"...\", univ: \"...\").")
    }
  }).filter(m => _has(m.name))
}

// Content parameters: catch a file name passed instead of `include "file.typ"`
#let _content(param, value) = {
  if type(value) == str and value.trim().ends-with(".typ") {
    _fail("`" + param + "` got the file name " + repr(value) + "; write `" + param
      + ": include \"" + value.trim() + "\"` to insert the file.")
  }
  value
}

#let thesis(
  // ===== PERSONAL INFORMATION =====
  name: "",
  surname: "",
  student-id: "",

  // ===== THESIS TITLES (up to 3 lines, printed exactly as written) =====
  title-tr: ("", "", ""),   // Turkish (Turkish covers + ÖZET page)
  title-en: ("", "", ""),   // English (English covers + ABSTRACT page)
  // Title as it appears inside the approval-page sentence (title case, italic),
  // e.g. "Tez Başlığı: Alt Başlık". Default: the thesis-language title lines joined.
  approval-title: none,

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
  cover-date-tr: "",        // Month and year on the covers (e.g. "Mayıs 2025")
  cover-date-en: "",
  defense-date-tr: "",      // Defense date on the approval page (e.g. "21 Mayıs 2025")
  defense-date-en: "",
  // No longer printed: the v2 approval page has no submission date. Kept for compatibility.
  submission-date-tr: "",
  submission-date-en: "",

  // ===== SETTINGS =====
  lang: "tr",               // "tr" | "en"
  degree: "masters",        // "masters" | "phd"
  // Degree name on the English inner cover ("for the degree of ...").
  // auto = "Master of Science" / "Doctor of Philosophy"; e.g. "Master of Arts".
  degree-name-en: auto,
  // "hardcover" (bez) | "softcover" (karton). Since v2 both versions have the same
  // covers; only the meaning of the cover date differs (defense vs. submission).
  binding: "hardcover",
  // printing: "two-sided" (chapters start on a recto page + gutter margins, cls default)
  //           "one-sided" (no recto alignment, fixed left margin)
  // The backs of the covers, approval, integrity and dedication pages are blank in both.
  printing: "two-sided",
  // Cover logo (30 × 40 mm): image("itulogo.png") with the official ITU logo in your
  // project (not bundled: trademark); auto = visible placeholder; none = empty slot.
  logo: auto,

  // ===== FRONT/BACK MATTER (content blocks) =====
  dedication: none,         // Dedication text (e.g. "Aileme,")
  foreword: none,           // Preface (ÖNSÖZ) content; the author's name is added below it
  abbreviations: none,      // Abbreviations content (use #abbreviation(...))
  symbols: none,            // Symbols content (use #symbol-entry(...))
  abstract-tr: none,        // Turkish abstract (ÖZET) content
  abstract-en: none,        // English abstract (ABSTRACT) content
  list-of-figures: true,    // Produce the List of Figures?
  list-of-tables: true,     // Produce the List of Tables?
  bibliography: none,       // Pass a bibliography(...) call here
  appendices: none,         // Appendices content
  cv: none,                 // Curriculum vitae content

  body,
) = {
  // ---- Input checks (see _choice, _title, _jury, _content above) ----
  let lang = _choice("lang", lang, (tr: ("turkish", "turkce"), en: ("english", "ingilizce")))
  let degree = _choice("degree", degree, (
    masters: ("master", "masters", "msc", "m.sc.", "ms", "yuksek-lisans", "yukseklisans"),
    phd: ("ph.d.", "doctoral", "doctorate", "doktora"),
  ))
  let binding = _choice("binding", binding, (
    hardcover: ("bez", "cloth", "ciltli"),
    softcover: ("karton", "paperback"),
  ))
  let printing = _choice("printing", printing, (
    "two-sided": ("twoside", "twosided", "double-sided", "onluarkali", "cift-yonlu"),
    "one-sided": ("oneside", "onesided", "single-sided", "tekyonlu", "tek-yonlu"),
  ))
  let institute = _choice("institute", institute, (
    graduate: ("lisansustuegitim", "lisansustu-egitim", "lisansustu", "graduate-school"),
    informatics: ("bilisim",),
    science: ("fenbilimleri", "fen-bilimleri", "fen"),
    social-sciences: ("sosyalbilimler", "sosyal-bilimler", "sosyal", "social"),
    energy: ("enerji",),
    eurasia: ("avrasya",),
  ))
  let title-tr = _title("title-tr", title-tr)
  let title-en = _title("title-en", title-en)
  let jury = _jury(jury)
  let dedication = _content("dedication", dedication)
  let foreword = _content("foreword", foreword)
  let abbreviations = _content("abbreviations", abbreviations)
  let symbols = _content("symbols", symbols)
  let abstract-tr = _content("abstract-tr", abstract-tr)
  let abstract-en = _content("abstract-en", abstract-en)
  let appendices = _content("appendices", appendices)
  let cv = _content("cv", cv)
  if type(bibliography) == str {
    _fail("`bibliography` got the string " + repr(bibliography)
      + "; write `bibliography: bibliography(\"refs.bib\", ...)` instead.")
  }
  if type(logo) == str {
    _fail("`logo` got the string " + repr(logo) + "; write `logo: image(\"" + logo + "\")` instead.")
  }

  // ---- Language ----
  let is-english = lang == "en"
  let lang-code = lang
  let tr-en(tr, en) = if is-english { en } else { tr }

  // ---- Printing (two-/one-sided) ----
  // cls onluarkali = twoside: chapters start on a recto (right) page,
  // blank pages are inserted and margins alternate for binding (\BolumSagdaKalsinNolu).
  let twoside = printing == "two-sided"
  let next-recto-page = if twoside { pagebreak(to: "odd", weak: true) } else { pagebreak(weak: true) }

  // ---- Institute names (cls \th@Enstitu / \th@Institute + \th@Instituteiki) ----
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
    "social-sciences": "Graduate School of Arts and Sciences",
    "energy": "Institute of Energy",
    "eurasia": "Eurasia Institute of Earth Sciences",
  ).at(institute, default: "Graduate School")

  let is-phd = degree == "phd"
  let degree-name-en = if degree-name-en == auto {
    if is-phd { "Doctor of Philosophy" } else { "Master of Science" }
  } else { degree-name-en }

  let full-name = if type(name) == str and type(surname) == str {
    (name + " " + surname).trim()
  } else [#name #surname]
  let has = _has
  let clean-lines(lines) = lines.filter(has)

  // =====================================================================
  //  GLOBAL SETTINGS
  // =====================================================================
  set document(
    title: (if is-english { title-en } else { title-tr }).at(0, default: none),
    author: if type(full-name) == str { full-name } else { () },
  )
  set text(
    font: ("Times New Roman", "Libertinus Serif"),
    size: 12pt,
    lang: lang-code,
    hyphenate: false,   // front matter: no hyphenation (cls \hyphenpenalty=10000)
  )
  // Front matter is single spaced; the body switches to 1.5 spacing.
  set par(leading: _single, spacing: _single + _parskip, justify: true)
  show math.equation: set block(spacing: _single + _parskip)

  // Lists (cls: text at 1.26 cm, label separation 0.4 cm, no extra space between items)
  set list(indent: 0.63cm, body-indent: 0.45cm)
  set enum(indent: 0.63cm, body-indent: 0.45cm)
  // Block quotes: 1.25 cm from the left
  show quote.where(block: true): it => block(inset: (left: 1.25cm), {
    it.body
    if it.attribution != none { linebreak(); h(1fr); [— #it.attribution] }
  })

  // ---- Page geometry (cls: text 145 × 247 mm; inner 40 mm, outer 25 mm, top/bottom 25 mm;
  //      page number 12.5 mm above the bottom edge) ----
  set page(
    paper: "a4",
    margin: if twoside {
      (inside: 40mm, outside: 25mm, top: 25mm, bottom: 25mm)
    } else {
      (left: 40mm, right: 25mm, top: 25mm, bottom: 25mm)
    },
    footer-descent: 8.8mm,
    number-align: center + bottom,
    numbering: none,
  )

  // ---- Heading styles ----
  // Per itutez.cls: chapters appear as "1. TITLE" (no "BÖLÜM" prefix); all headings
  // are 12 pt bold and left-aligned. Gaps (heading → paragraph) follow the cls:
  // level 1: 24 mm above, 24 pt below · level 2: 24 pt / 18 pt · levels 3–4: 18 pt / 12 pt.
  let heading-label(it) = {
    if it.numbering != none [#counter(heading).display(it.numbering) ]
    it.body
  }
  show heading: it => {
    set text(size: 12pt, weight: "bold")
    set par(justify: false)
    if it.level == 1 {
      // cls: chapters / front-back matter start on a recto page, 24 mm from the top
      next-recto-page
      v(24mm)
      context block(above: 0pt, below: 24pt + par.leading, sticky: true, heading-label(it))
    } else if it.level == 2 {
      context block(above: 24pt + par.leading, below: 18pt + par.leading, sticky: true, heading-label(it))
    } else if it.level <= 4 {
      context block(above: 18pt + par.leading, below: 12pt + par.leading, sticky: true, heading-label(it))
    } else {
      context block(above: 12pt + par.leading, below: 6pt + par.leading, sticky: true, heading-label(it))
    }
  }
  // Level-5 headings are not listed in the table of contents (cls)
  show heading.where(level: 5): set heading(outlined: false)

  // ---- Figures and tables ----
  // cls v2: captions ABOVE both figures and tables, bold "Şekil 1.1:" + italic text, centered.
  show figure.where(kind: image): set figure(supplement: tr-en("Şekil", "Figure"))
  show figure.where(kind: table): set figure(supplement: tr-en("Çizelge", "Table"))
  set figure(gap: 6pt)
  show figure: set figure.caption(position: top)
  show figure.caption: it => {
    strong[#it.supplement #context it.counter.display(it.numbering):]
    [ ]
    emph(it.body)
  }

  // =====================================================================
  //  COVERS  (cls \th@KapakDis / \th@KapakIc — all positions from the top
  //  edge of the page; 145 mm wide blocks centered on the page)
  // =====================================================================
  // The ITU logo is a registered trademark and is not bundled with the package.
  // Without `logo`, a clearly visible placeholder marks the 30 × 40 mm slot so a
  // missing logo cannot go unnoticed; `logo: none` leaves the slot empty on purpose.
  let logo-content = if logo == auto {
    rect(width: 30mm, height: 40mm, stroke: (paint: luma(150), dash: "dashed", thickness: 0.6pt),
      align(center + horizon, text(size: 8pt, fill: luma(110), font: "Libertinus Serif")[
        İTÜ logo \ #v(1mm) `logo: image(...)`
      ]))
  } else if logo == none { none } else { box(width: 30mm, height: 40mm, logo) }

  // Text block with Word-like line boxes (Times ascent 0.891em / descent 0.216em),
  // so the block edges coincide with the edges of the first/last line.
  let cover-text(size, bold: false, lines) = {
    set text(size: size, weight: if bold { "bold" } else { "regular" },
      top-edge: 0.891em, bottom-edge: -0.216em)
    set par(leading: 0.043em, justify: false)   // 16.1 pt (14 pt) / 13.8 pt (12 pt) line pitch
    align(center, lines.join(linebreak()))
  }
  // anchor: top = block top at y; bottom = block bottom at y
  let cover-block(y, anchor: top, content) = if anchor == top {
    place(top + left, dx: 32.5mm, dy: y, block(width: 145mm, content))
  } else {
    place(bottom + left, dx: 32.5mm, dy: y - 297mm, block(width: 145mm, content))
  }
  let blank-page = page(margin: 0pt, numbering: none, header: none, footer: none)[]

  let cover-data(l) = if l == "tr" {(
    univ: "İSTANBUL TEKNİK ÜNİVERSİTESİ",
    title: title-tr,
    author: "Yazar", advisor-label: "Danışman", co-advisor-label: "Eş Danışman",
    advisor: advisor-tr, co-advisor: co-advisor-tr,
    kind: if is-phd { "DOKTORA TEZİ" } else { "YÜKSEK LİSANS TEZİ" },
    purpose: (
      (if is-phd { "Doktora" } else { "Yüksek lisans" }) + " derecesi gerekliliklerinin kısmen",
      "yerine getirilmesi amacıyla sunulmuştur",
    ),
    institute: institute-tr, department: department-tr, program: program-tr,
    id-label: "Öğrenci Numarası", date: cover-date-tr,
  )} else {(
    univ: "ISTANBUL TECHNICAL UNIVERSITY",
    title: title-en,
    author: "Author", advisor-label: "Advisor", co-advisor-label: "Co-Advisor",
    advisor: advisor-en, co-advisor: co-advisor-en,
    kind: if is-phd { "DOCTORAL DISSERTATION" } else { "MASTER’S THESIS" },
    purpose: (
      "Submitted in partial fulfillment of the requirements",
      "for the degree of " + degree-name-en,
    ),
    institute: institute-en, department: department-en, program: program-en,
    id-label: "Student Number", date: cover-date-en,
  )}

  // University name (30 mm), logo (55 mm), title (bottom at 130 mm)
  let cover-top(d) = {
    cover-block(30mm, cover-text(14pt, bold: true, (d.univ,)))
    if logo-content != none { place(top + left, dx: 90mm, dy: 55mm, logo-content) }
    cover-block(130mm, anchor: bottom, cover-text(14pt, bold: true, clean-lines(d.title)))
  }

  let outer-cover(l) = page(margin: 0pt, numbering: none, header: none, footer: none, {
    let d = cover-data(l)
    cover-top(d)
    cover-block(140mm, cover-text(14pt, (full-name,)))
    cover-block(190mm, cover-text(12pt, (d.kind,)))
    cover-block(240mm, cover-text(12pt, (d.institute, d.department, d.program, [], d.date)))
  })

  let inner-cover(l, first: false) = page(margin: 0pt, numbering: none, header: none, footer: none, {
    // cls: the first inner cover is page i (roman numbering starts here, unprinted)
    if first { counter(page).update(1) }
    let d = cover-data(l)
    cover-top(d)
    let people = ([#d.author: #full-name], [#d.advisor-label: #d.advisor])
    if has(d.co-advisor) { people.push([#d.co-advisor-label: #d.co-advisor]) }
    cover-block(140mm, cover-text(14pt, people))
    cover-block(190mm, cover-text(12pt, (d.kind, ..d.purpose)))
    cover-block(240mm, cover-text(12pt,
      (d.institute, d.department, d.program, [#d.id-label: #student-id], d.date)))
  })

  // Outer cover (thesis language) → inner cover (thesis language) → inner cover
  // (other language); the back of each page is left blank.
  let other-lang = if is-english { "tr" } else { "en" }
  outer-cover(lang-code)
  blank-page
  inner-cover(lang-code, first: true)
  blank-page
  inner-cover(other-lang)
  blank-page

  // =====================================================================
  //  JURY APPROVAL PAGE + ACADEMIC INTEGRITY DECLARATION
  //  (cls \th@onaypage / \th@AkademikDurustluk: text starts 50 mm from the
  //  top of the page; signature table columns 41 / 70 / 34 mm)
  // =====================================================================
  let signature-line = box(width: 32mm, height: 0.8em, baseline: 0.15em, stroke: (bottom: 0.5pt))
  let signature-row(label, person, univ: none, height: 20mm, line: true) = grid(
    columns: (41mm, 70mm, 34mm),
    rows: height,
    label,
    { person; if has(univ) { linebreak(); univ } },
    if line { signature-line },
  )
  let statement-page(content) = page(numbering: none, {
    set par(justify: true)
    set block(spacing: 0pt)
    v(25mm)
    content
  })

  let approval-title = if approval-title != none { approval-title } else {
    clean-lines(if is-english { title-en } else { title-tr }).join(" ")
  }
  let advisor = tr-en(advisor-tr, advisor-en)
  let co-advisor = tr-en(co-advisor-tr, co-advisor-en)

  statement-page({
    block(height: 40mm, width: 100%, if is-english [
      #full-name, a #(if is-phd [doctoral] else [master’s]) student at Istanbul Technical
      University #institute-en, student number #student-id, having fulfilled all the
      requirements set forth in the relevant regulations, has successfully defended the
      #(if is-phd [dissertation] else [thesis]) titled #emph(approval-title) before the jury
      whose signatures appear below; the #(if is-phd [dissertation] else [thesis]) has been
      found to meet the required standards in terms of scope and quality for a
      #(if is-phd [doctoral] else [master’s]) degree.
    ] else [
      İstanbul Teknik Üniversitesi #(institute-tr)nün #student-id numaralı
      #(if is-phd [doktora] else [yüksek lisans]) öğrencisi #full-name, ilgili yönetmeliklerde
      belirtilen tüm şartları yerine getirdikten sonra hazırladığı #emph(approval-title)
      başlıklı tezini, aşağıda imzaları bulunan jüri önünde başarıyla savunmuş; tez, kapsam ve
      nitelik bakımından #(if is-phd [doktora] else [yüksek lisans]) derecesi için yeterli
      bulunmuştur.
    ])
    signature-row(tr-en("Danışman:", "Advisor:"), advisor,
      univ: tr-en(advisor-univ-tr, advisor-univ-en))
    if has(co-advisor) {
      signature-row(tr-en("Eş Danışman:", "Co-Advisor:"), co-advisor,
        univ: tr-en(co-advisor-univ-tr, co-advisor-univ-en))
    }
    for (i, member) in jury.enumerate() {
      signature-row(if i == 0 { tr-en("Jüri Üyeleri:", "Jury Members:") }, member.name,
        univ: member.at("univ", default: none))
    }
    v(20mm)
    signature-row(tr-en("Savunma Tarihi:", "Date of Defense:"),
      tr-en(defense-date-tr, defense-date-en), line: false)
  })
  blank-page

  statement-page({
    block(height: 35mm, width: 100%, if is-english [
      I declare that all data and information in this #(if is-phd [dissertation] else [thesis])
      have been obtained and presented in accordance with the principles of academic integrity
      and ethical conduct. Furthermore, in accordance with said principles, I declare that the
      entire intellectual content of the manuscript is my own original work, except in cases
      where contributions from other individuals, institutions, or Generative AI tools are
      explicitly stated.
    ] else [
      Bu tezde yer alan tüm veri ve bilgilerin akademik dürüstlük ve etik davranış ilkeleri
      doğrultusunda elde edildiğini ve sunulduğunu beyan ederim. Ayrıca, söz konusu ilkeler
      gereğince, başka kişi, kurum veya Üretken Yapay Zekâ araçlarının katkılarının açıkça
      belirtildiği durumlar haricinde, tezin entelektüel içeriğinin tamamının tarafıma ait özgün
      bir çalışma niteliği taşıdığını da beyan ederim.
    ])
    signature-row(tr-en("Yazar:", "Author:"), full-name)
    v(65mm)
    block(height: 25mm, width: 100%, if is-english [
      I hereby declare that I have fulfilled my advisory responsibilities regarding the
      monitoring and guidance of the research and writing process of this
      #(if is-phd [dissertation] else [thesis]) in accordance with the principles of academic
      integrity and ethical conduct.
    ] else [
      Bu #(if is-phd [doktora] else [yüksek lisans]) tezinin araştırma ve yazım sürecinin
      izlenmesi ve yönlendirilmesi konusundaki danışmanlık sorumluluklarımı akademik dürüstlük
      ve etik davranış ilkeleri doğrultusunda yerine getirdiğimi beyan ederim.
    ])
    signature-row(tr-en("Danışman:", "Advisor:"), advisor, height: 15mm)
    if has(co-advisor) { signature-row(tr-en("Eş Danışman:", "Co-Advisor:"), co-advisor) }
  })
  blank-page

  // =====================================================================
  //  FRONT MATTER  (roman numerals continue from the inner cover)
  // =====================================================================
  set page(numbering: "i")
  set heading(numbering: none)
  // cls: dotted leaders in the table of contents and the lists of tables/figures
  set outline.entry(fill: repeat(gap: 2.5pt)[.])
  // cls/tocloft: chapters at 0, sections 4 mm, subsections 8.5 mm, deeper 12.7 mm
  set outline(indent: n => (0mm, 4mm, 8.5mm, 12.7mm).at(n, default: 12.7mm))

  // "Sayfa" / "Page" column header: 20 pt below the list title, 12 pt above the entries
  let page-column-label = block(above: 24pt, below: 12pt + _single, width: 100%,
    align(right, strong(underline(tr-en("Sayfa", "Page")))))

  // ---- DEDICATION ---- (130 mm from the top of the page, right-aligned, back blank)
  if has(dedication) {
    page(numbering: none, {
      v(105mm)
      align(right, text(weight: "bold", style: "italic", dedication))
    })
    blank-page
  }

  // ---- PREFACE ---- (author's name 11.24 cm from the left; right-aligned if longer)
  if foreword != none {
    heading(level: 1, tr-en("ÖNSÖZ", "PREFACE"))
    foreword
    context {
      let n = [#full-name]
      let w = measure(n).width
      block(above: _single + _parskip, width: 100%, if w < 145mm - 112.4mm { pad(left: 112.4mm, n) } else { align(right, n) })
    }
  }

  // ---- TABLE OF CONTENTS ---- (lists itself, as in the cls)
  heading(level: 1, tr-en("İÇİNDEKİLER", "TABLE OF CONTENTS"))
  page-column-label
  {
    set par(spacing: _single)
    // Chapters and front/back-matter (level-1) entries are bold
    show outline.entry.where(level: 1): strong
    outline(title: none, depth: 4)
  }

  // ---- ABBREVIATIONS / SYMBOLS ---- (single spacing, no space between entries)
  if abbreviations != none {
    heading(level: 1, tr-en("KISALTMALAR", "ABBREVIATIONS"))
    set par(spacing: _single)
    abbreviations
  }
  if symbols != none {
    heading(level: 1, tr-en("SEMBOLLER", "SYMBOLS"))
    set par(spacing: _single)
    symbols
  }

  // ---- LISTS OF TABLES / FIGURES ---- ("Şekil 1.1: " in a 5.5 em column, caption italic)
  let figure-entry(it) = link(it.element.location(), {
    let label = [#it.prefix(): ]
    let column = 66pt   // 5.5 em at 12 pt
    par(hanging-indent: column, justify: false, context {
      if measure(label).width < column { box(width: column, label) } else { label }
      emph(it.body())
      box(width: 1fr, it.fill)
      it.page()
    })
  })
  if list-of-tables {
    heading(level: 1, tr-en("ÇİZELGE LİSTESİ", "LIST OF TABLES"))
    page-column-label
    show outline.entry: figure-entry
    set par(spacing: _single)
    outline(title: none, target: figure.where(kind: table))
  }
  if list-of-figures {
    heading(level: 1, tr-en("ŞEKİL LİSTESİ", "LIST OF FIGURES"))
    page-column-label
    show outline.entry: figure-entry
    set par(spacing: _single)
    outline(title: none, target: figure.where(kind: image))
  }

  // ---- ÖZET / ABSTRACT ----
  // cls: thesis title centered (24 mm from the top), 44 pt gap, centered heading, then the text.
  // Turkish theses put ÖZET first; English theses put ABSTRACT first.
  let abstract-page(title-lines, heading-text, content) = {
    next-recto-page
    v(24mm)
    block(above: 0pt, below: 44pt + _single, width: 100%,
      cover-text(12pt, bold: true, clean-lines(title-lines)))
    {
      show heading: it => block(above: 0pt, below: 24pt + _single, width: 100%,
        align(center, text(size: 12pt, weight: "bold", it.body)))
      heading(level: 1, heading-text)
    }
    content
  }
  let abstract-tr-block = if abstract-tr != none { abstract-page(title-tr, "ÖZET", abstract-tr) }
  let abstract-en-block = if abstract-en != none { abstract-page(title-en, "ABSTRACT", abstract-en) }
  if is-english {
    abstract-en-block
    abstract-tr-block
  } else {
    abstract-tr-block
    abstract-en-block
  }

  // =====================================================================
  //  BODY  (arabic numerals, numbered chapters, 1.5 spacing — first chapter recto)
  // =====================================================================
  // Reset the counter on a physical odd page (parity alignment)
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
    // Figures and tables are numbered per chapter: Şekil 1.1, Çizelge 2.3, ...
    #set figure(numbering: n => numbering("1.1", counter(heading).get().first(), n))
    #show heading.where(level: 1): it => {
      counter(figure.where(kind: image)).update(0)
      counter(figure.where(kind: table)).update(0)
      it
    }
    // Body: 1.5 spacing; hyphenation allowed when needed (cls \hyphenpenalty=1000)
    #set par(leading: _onehalf, spacing: _onehalf + _parskip)
    #set text(hyphenate: true, costs: (hyphenation: 300%))
    #show math.equation: set block(spacing: _onehalf + _parskip)
    #body
  ]

  // =====================================================================
  //  BIBLIOGRAPHY  (single spacing, 12 pt between entries)
  // =====================================================================
  if bibliography != none {
    set par(leading: _single, spacing: _single + _parskip)
    set block(spacing: _single + _parskip)
    bibliography
  }

  // =====================================================================
  //  APPENDICES
  //  cls: "EKLER" heading; the first appendix follows on the same page 24 pt
  //  below it, each further appendix starts on a new page. Appendix titles are
  //  listed in the TOC like sections; figures/tables are numbered A.1, B.1, ...
  // =====================================================================
  if appendices != none {
    heading(level: 1, tr-en("EKLER", "APPENDICES"))
    let appendix-counter = counter("itu-thesis-appendix")
    set heading(offset: 1)
    set figure(numbering: n => numbering("A.1", appendix-counter.get().first(), n))
    show heading.where(level: 2): it => {
      appendix-counter.step()
      counter(figure.where(kind: image)).update(0)
      counter(figure.where(kind: table)).update(0)
      context if appendix-counter.get().first() > 1 { pagebreak(weak: true) }
      context block(above: 24pt + par.leading, below: 6pt + _parskip + par.leading, sticky: true,
        text(size: 12pt, weight: "bold", it.body))
    }
    appendices
  }

  // =====================================================================
  //  CURRICULUM VITAE  (single spacing)
  // =====================================================================
  if cv != none {
    heading(level: 1, tr-en("ÖZGEÇMİŞ", "CURRICULUM VITAE"))
    set par(leading: _single, spacing: _single + _parskip)
    // In the cls the CV is plain text; keep any headings inside it out of the TOC.
    set heading(outlined: false)
    cv
  }
}
