// =============================================================
//  community-pens-report — PENS final-project report template
//  Mirrors the LaTeX `report` class with mirrored book margins,
//  Times-like fonts, per-chapter figure/table numbering, and the
//  cover / approval / frontmatter pages required at Politeknik
//  Elektronika Negeri Surabaya (PENS).
//
//  Everything personal (author, advisors, institution, colours,
//  abstract texts, ...) is a parameter of `thesis` with PENS-style
//  defaults, so the template can be re-used by anyone.
// =============================================================

#let body-font = "Times New Roman"   // Times New Roman
#let mono-font = "Courier New"      // Courier New

// ---------- Helpers exposed to chapter files ----------

// Force the next content onto an odd (recto) page. Any verso filler that
// Typst auto-inserts gets a centered "intentionally left blank" notice
// stamped on it via the page background (which only shows up where no
// other content covers it).
#let to-odd-page() = {
  pagebreak(to: "odd", weak: true)
}

// Blank verso page (kept as an alias for explicit use in frontmatter).
#let blankpage() = to-odd-page()

// `chapter` shows "CHAPTER N" + the title, centered, all caps.
// We rely on Typst's level-1 heading numbering for N.
#let chapter(title) = {
  to-odd-page()
  heading(level: 1, numbering: "1", title)
}

// Convenience aliases that compile to plain headings.
#let section(title) = heading(level: 2, title)
#let subsection(title) = heading(level: 3, title)
#let subsubsection(title) = heading(level: 4, title)

// `cref` keeps the source LaTeX-style \cite{key} round.
#let cref(key) = cite(label(key), form: "normal")

// Wrap to mimic LaTeX `\begin{quote}`.
#let quote-block(body) = block(
  inset: (left: 1cm, right: 1cm, top: 0.4em, bottom: 0.4em),
  text(style: "italic", body),
)

// Centered heading line for unnumbered front-matter pages.
// Emits a metadata marker so the verso-blank detector sees this as content.
#let frontmatter-title(title) = {
  [#metadata("frontmatter-page") <fm-page>]
  align(center, text(weight: "bold", size: 14pt, upper(title)))
}

// Hidden, outline-visible heading for TOC entries pointing at frontmatter
// pages. The body never renders (a global show rule in `thesis()` turns it
// into a zero-size placeholder); only the TOC pulls it in.
#let fm-toc-entry(title) = {
  heading(level: 1, numbering: none, outlined: true,
          supplement: [FM], upper(title))
}

// Person record helper: (name: "...", id: "NIP./NRP. ...")
#let person(name, id) = (name: name, id: id)

// =============================================================
//  Frontmatter pages (used internally by `thesis`)
// =============================================================

// Coloured cover page.
#let cover-page(
  colors,
  logo,
  document-type,
  title,
  author,
  student-id,
  advisors,
  study-program,
  department,
  institution,
  year,
) = {
  set page(numbering: none, header: none, footer: none)
  set par(justify: false, leading: 0.65em)

  place(
    top + left,
    dx: -13mm,
    dy: -21mm,
    image(logo, width: 3.881cm, height: 3.5cm, fit: "stretch"),
  )
  place(
    top + left,
    dx: -40mm,
    dy: 24mm,
    rect(width: 210mm, height: 7mm, fill: colors.accent, stroke: none),
  )
  place(
    top + left,
    dx: -40mm,
    dy: 30mm,
    rect(width: 210mm, height: 260mm, fill: colors.primary, stroke: none),
  )

  align(center)[
    #align(right)[#text(weight: "bold", size: 20pt, fill: colors.primary)[#upper(document-type)]]
    #v(1em*6)
    #text(weight: "bold", size: 18pt, fill: white)[#title]
    #v(13mm)
    #text(weight: "bold", size: 16pt, fill: white)[#author \ #student-id]
    #v(4.5mm)
    #text(weight: "bold", size: 16pt, fill: white)[
      DOSEN PEMBIMBING
      #for a in advisors [\ #a.name \ #a.id]
    ]
    #v(8mm)
    #text(weight: "bold", size: 16pt, fill: white)[
      #upper(study-program) \ #upper(department) \ #upper(institution) \ #year
    ]
  ]
}

// Inner cover page (B&W logo, no coloured background).
#let inner-cover-page(
  gray-logo,
  document-type,
  title,
  author,
  student-id,
  advisors,
  study-program,
  department,
  institution,
  year,
) = {
  set page(numbering: none, header: none, footer: none)
  set par(justify: false, leading: 0.65em)

  place(
    top + left,
    dx: -13mm,
    dy: -21mm,
    image(gray-logo, width: 3.881cm, height: 3.5cm, fit: "stretch"),
  )

  align(center)[
    #align(right)[#text(weight: "bold", size: 20pt)[#document-type]]
    #v(1em*6)
    #text(weight: "bold", size: 18pt)[#title]
    #v(13mm)
    #text(weight: "bold", size: 16pt)[#author \ #student-id]
    #v(4.5mm)
    #text(weight: "bold", size: 16pt)[
      DOSEN PEMBIMBING \
      #for a in advisors [\ #a.name \ #a.id \ ]
    ]
    #v(8mm)
    #text(weight: "bold", size: 16pt)[
      #study-program \ #department \ #institution \ #year
    ]
  ]
}

// Rows for the signing table on the approval page (label/id pair per person).
#let signing-rows(entries, prefix) = entries.enumerate().map(((i, a)) => (
  ([#(prefix + " " + str(i + 1))], [:], [#a.name], [(#h(2cm))]),
  ([], [], [#a.id], []),
)).flatten()

// HALAMAN PENGESAHAN (approval page).
#let approval-page(
  background-image,
  title,
  document-type,
  degree,
  institution,
  year,
  author,
  student-id,
  advisors,
  examiners,
  coordinator,
  coordinator-role,
) = {
  set page(numbering: none, header: none, footer: none)
  set par(first-line-indent: 0pt, justify: false, leading: 0.7em)
  set text(size: 14pt)
  set page(
    background: image(background-image, width: 100%, height: 100%, fit: "cover"),
  )

  align(center)[
    #text(weight: "bold", size: 20pt)[HALAMAN PENGESAHAN]
    #v(0.6em)
    #text(weight: "bold", size: 18pt)[#title]
    #v(0.3em)
    *Oleh:* \
    #author \
    #student-id
    #v(0.3em)
    #block(width: 90%)[
      #set align(center)
      *#document-type ini digunakan sebagai salah satu syarat untuk
      memperoleh #degree \
      di #institution \
      #year*
    ]
    #v(0.6em)
    *Disetujui oleh:*
  ]

  set text(weight: "regular")
  v(-0.8em)

  table(
    columns: (3.2cm, 0.2cm, 8.0cm, 2.3cm),
    stroke: none,
    align: (left, left, left, left),
    inset: 4pt,
    ..signing-rows(advisors, "Pembimbing"),
    ..signing-rows(examiners, "Penguji"),
  )

  v(0.4em)

  align(center)[
    *Mengetahui,* \
    #coordinator-role \
    #institution
    #v(3em)
    #coordinator.name \
    #coordinator.id
  ]
}

// PERNYATAAN ORISINALITAS (statement of originality).
#let originality-page(
  document-type,
  institution,
  city,
  date,
  author,
  student-id,
  text-content: none,
) = {
  align(center, text(weight: "bold", size: 20pt)[PERNYATAAN ORISINALITAS])
  v(1em)
  set par(first-line-indent: 0pt)

  if text-content != none {
    text-content
  } else {
    [
      Dengan ini saya menyatakan bahwa bagian atau keseluruhan proyek akhir ini:

      + Adalah hasil karya sendiri dan tidak mengandung unsur plagiat dari pihak lain,
      + Tidak pernah diajukan untuk mendapatkan gelar akademis pada suatu Perguruan Tinggi,
      + Tidak pernah dipublikasikan atau ditulis oleh pihak lain,
      + Mencantumkan rujukan dan kutipan dengan jujur dan benar terhadap sumber referensi lain yang menunjang pembahasan pada proyek akhir ini.

      #v(0.5em)

      Apabila ditemukan bukti bahwa pernyataan saya di atas tidak benar, maka
      saya bersedia menerima sanksi sesuai dengan ketentuan yang berlaku di #institution.

      #v(4em)

      #align(right, block(width: 45%)[
        #set par(first-line-indent: 0pt, justify: false)
        #city, #date

        #v(4em)

        *#author* \
        *#student-id*
      ])
    ]
  }
}

// PERNYATAAN PENGALIHAN HAK CIPTA (copyright transfer).
#let copyright-page(
  title,
  document-type,
  institution,
  city,
  date,
  author,
  student-id-label,
  student-id,
  text-content: none,
) = {
  align(center, text(weight: "bold", size: 20pt)[PERNYATAAN PENGALIHAN HAK CIPTA])
  v(1em)
  set par(first-line-indent: 0pt)

  if text-content != none {
    text-content
  } else {
    [
      Dengan ini, saya yang bertanda tangan di bawah ini:

      #v(0.5em)

      #table(
        columns: (4.5cm, 0.3cm, auto),
        stroke: none,
        align: left,
        inset: 4pt,
        [Nama], [:], [#author],
        [#student-id-label], [:], [#student-id],
        [Judul Proyek Akhir], [:], ["#smallcaps[#title]"],
        [Tanggal], [:], [#city, #date],
      )

      #v(1em)

      menyatakan bahwa saya selaku penulis (dan/atau mewakili seluruh penulis)
      secara sadar dan sukarela mengalihkan hak cipta (_copyright_) atas proyek
      akhir tersebut kepada #institution.

      #v(0.5em)

      Demikian pernyataan ini saya buat dengan sebenar-benarnya dan tanpa paksaan
      dari pihak mana pun.

      #v(2em)

      #align(right, block(width: 45%)[
        #set par(first-line-indent: 0pt, justify: false)
        Hormat saya,

        #v(2em)

        \[Materai\]

        #v(2em)

        *#author*
      ])
    ]
  }
}

// ABSTRACT / ABSTRAK page.
#let abstract-page(
  title,
  italic-title: false,
  italic-body: false,
  keywords-label: "Keywords:",
  keywords: none,
  content: none,
) = {
  align(
    center,
    text(
      weight: "bold",
      style: if italic-title { "italic" } else { "normal" },
      size: 14pt,
    )[#title],
  )
  v(1em)

  if italic-body {
    set text(style: "italic")
  }
  if content != none {
    content
  }
  if keywords != none {
    v(0.5em)
    par(first-line-indent: 0pt)[*#keywords-label* #keywords]
  }
}

// Generic titled frontmatter page (FOREWORD / ACKNOWLEDGEMENT).
#let frontmatter-content-page(
  title,
  body,
  basmalah: none,
) = {
  frontmatter-title(title)
  v(1em)

  if basmalah != none {
    align(center, image(basmalah, width: 45%))
    v(0.8em)
  }

  body
}

// =============================================================
//  Main document template
// =============================================================
#let thesis(
  // ---- document identity ----
  title: "Final Project Title",
  document-title: "Final Project Report",
  document-type: "PROYEK AKHIR",
  degree: "Gelar Sarjana Terapan (S.Tr.T.)",
  year: "2026",
  city: "Surabaya",
  date: "16 Juli 2026",

  // ---- author ----
  author: "Author Name",
  student-id-label: "NRP.",
  student-id: "0000000000",

  // ---- institution ----
  study-program: "PROGRAM STUDI SARJANA TERAPAN TEKNIK MEKATRONIKA",
  department: "JURUSAN TEKNIK MEKANIKA DAN ENERGI",
  institution: "POLITEKNIK ELEKTRONIKA NEGERI SURABAYA",
  coordinator-role: "Koordinator Program Studi Sarjana Terapan Teknik Mekatronika",
  coordinator: (name: "Coordinator Name, S.T., M.T.", id: "NIP. 000000000000000000"),

  // ---- people ----
  advisors: (
    (name: "Advisor 1, S.T., M.T.", id: "NIP. 000000000000000000"),
    (name: "Advisor 2, S.T., M.T.", id: "NIP. 000000000000000000"),
  ),
  examiners: (
    (name: "Examiner 1, S.T., M.T.", id: "NIP. 000000000000000000"),
    (name: "Examiner 2, S.T., M.T.", id: "NIP. 000000000000000000"),
  ),

  // ---- branding ----
  colors: (primary: rgb("#002AA6"), accent: rgb("#F2CB00")),
  logo: "assets/pens_logo.jpg",
  gray-logo: "assets/pens_logo_gray.jpg",
  background-image: "assets/pens-bg.png",
  basmalah-image: "assets/basmalah-cropped.png",
  show-basmalah: true,

  // ---- frontmatter content ----
  originality-text: none,
  copyright-text: none,
  abstract-en: none,
  abstract-en-keywords: "Keywords",
  abstract-id: none,
  abstract-id-keywords: "Kata Kunci",
  foreword: none,
  acknowledgement: none,
  author-bio: none,
  supplementary: none,

  body
) = {
  set document(title: document-title)

  // Page geometry: mirrored book margins.
  set page(
    paper: "a4",
    margin: (inside: 40mm, outside: 30mm, top: 30mm, bottom: 30mm),
    // Stamp a centered notice on auto-inserted blank verso pages.
    // We detect "blank" by checking that no heading or figure starts on
    // this page. Backgrounds run after main layout, so this is safe for
    // citations and bibliography.
    background: context {
      let p = here().page()
      if calc.even(p) {
        let here-page = p
        // Anything queryable that lands on this page = real content.
        let on-page = query(
          selector(heading).or(figure).or(math.equation).or(<content>).or(<fm-page>)
        ).filter(el => el.location().page() == here-page)

        // Bibliography spills onto extra pages whose entries aren't
        // individually queryable — treat pages from bibliography start up to
        // the last bibliography entry page (before next level-1 heading) as content.
        let bib-list = query(bibliography)
        let bib-loc = if bib-list.len() > 0 { bib-list.first().location() } else { none }
        let next-h1 = if bib-loc != none {
          query(heading.where(level: 1)).filter(h => h.location().page() > bib-loc.page())
        } else { () }
        let bib-limit = if next-h1.len() > 0 { next-h1.first().location().page() - 1 } else { 9999 }
        let in-bib = bib-loc != none and here-page >= bib-loc.page() and here-page < bib-limit

        if on-page.len() == 0 and not in-bib {
          place(
            center + horizon,
            text(size: 12pt)[
              This page is intentionally left blank
            ],
          )
        }
      }
    },
  )

  // Body font / size / line spacing / first-line indent.
  set text(font: body-font, size: 12pt, lang: "en")
  set par(
    leading: 0.85em,           // ~1.43 line spacing at 12pt
    first-line-indent: (amount: 1.27cm, all: true),
    justify: true,
  )

  // Raw / monospace font.
  show raw: set text(font: mono-font, size: 10.5pt)

  // Mark every paragraph with a queryable `<content>` label so the
  // verso-blank detector can tell prose-spillover pages apart from
  // auto-inserted blank pages.
  show par: it => {
    it
    [#metadata(none) <content>]
  }

  // Also mark table cells so multi-page table continuations aren't
  // mistaken for blank verso pages by the blank detector.
  show table.cell: it => {
    it
    [#metadata(none) <content>]
  }

  // ---------------- Headings -------------------------------
  // We use level-1 = chapter, level-2 = section, level-3 = subsection,
  // level-4 = subsubsection, matching the LaTeX `report` class.
  set heading(numbering: "1.1.1.1")

  // Chapter pages: "CHAPTER N" / uppercased title, centered, bold.
  // Skip the chapter machinery for hidden frontmatter-anchor headings.
  show heading.where(level: 1): it => {
    if it.supplement == [FM] {
      // Zero-size placeholder; only registers a location for the TOC.
    } else if it.numbering == none {
      // Unnumbered body headings like REFERENCES.
      to-odd-page()
      v(0pt)
      align(center, text(weight: "bold", size: 14pt, upper(it.body)))
      v(1.5em)
    } else {
      to-odd-page()
      counter(figure.where(kind: image)).update(0)
      counter(figure.where(kind: table)).update(0)
      counter(figure.where(kind: raw)).update(0)
      counter(math.equation).update(0)
      v(0pt)
      align(center, block(width: 100%, {
        set par(leading: 0.4em, first-line-indent: 0pt)
        text(weight: "bold", size: 14pt)[CHAPTER #counter(heading).display("1")]
        linebreak()
        text(weight: "bold", size: 14pt, upper(it.body))
      }))
      v(1.5em)
    }
  }

  show heading.where(level: 2): it => {
    v(1em, weak: true)
    let num = upper(counter(heading).display("1.1"))
    set text(weight: "bold", size: 12pt)
    grid(
      columns: (1.27cm, 1fr),
      [#num], upper(it.body),
    )
    v(0.8em, weak: true)
  }
  show heading.where(level: 3): it => {
    v(0.8em, weak: true)
    let num = counter(heading).display("1.1.1")
    set text(weight: "bold", size: 12pt)
    grid(
      columns: (1.27cm, 1fr),
      [#num], it.body,
    )
    v(0.8em, weak: true)
  }
  show heading.where(level: 4): it => {
    v(0.8em, weak: true)
    let num = counter(heading).display("1.1.1.1")
    set text(weight: "bold", size: 12pt)
    grid(
      columns: (auto, 1fr),
      column-gutter: 0.5em,
      [#num], it.body,
    )
    v(0.8em, weak: true)
  }

  // ---------------- TOC entry formatting ----------------
  // Use one dot-leader implementation for levels 1--3 so trailing dots
  // look consistent.
  let toc-line(loc, left, pgnum, indent: 0pt, hanging: 0pt, above: 0pt, below: 0pt, weight: "regular") = {
    set par(hanging-indent: hanging, first-line-indent: 0pt, justify: true)
    block(width: 100%, inset: (left: indent), link(loc, text(weight: weight)[
      #v(1.3mm)
      #left
      #box(width: 1fr, repeat[. ])
      #pgnum
      #metadata(none) <content>
      #v(1.3mm)
    ]))
  }

  let short-caption(body) = {
    // Figure captions often contain `Title \ Source: ...`.
    // The source PDF's List of Figures only uses the title line.
    if body.has("children") {
      let res = ()
      for child in body.children {
        if child.func() == linebreak { break }
        if child.func() == text and child.text == "Source" { break }
        res.push(child)
      }
      res.join()
    } else {
      body
    }
  }

  show outline.entry.where(level: 1): it => {
    let el = it.element
    let loc = el.location()

    if el.func() == heading {
      let n-page = counter(page).at(loc).first()
      let is-fm = (el.supplement == [FM])
      let is-unnumbered-body = (el.numbering == none and not is-fm)
      let pgnum = if is-fm { numbering("i", n-page) } else { str(n-page) }
      if is-fm {
        toc-line(loc, upper(el.body), pgnum, weight: "bold")
      } else if is-unnumbered-body {
        // Unnumbered body headings like REFERENCES — arabic page, no "CHAPTER N"
        toc-line(loc, upper(el.body), pgnum, weight: "bold")
      } else {
        let n = counter(heading).at(loc).first()
        toc-line(loc, upper[CHAPTER #n  #el.body], pgnum, weight: "bold")
      }
    } else if el.func() == figure {
      // List of Figures / List of Tables / List of Equations: match source TOC
      // line spacing and dot leaders instead of Typst's default compact outline style.
      let pgnum = str(counter(page).at(loc).first())
      let ch = counter(heading).at(loc).first()

      if el.supplement == [Equation] {
        // For equations, query the inner equation to get the correct counter value
        let eq = query(selector(math.equation).after(loc)).first()
        let n = counter(math.equation).at(eq.location()).first()
        let label = [#el.supplement #h(0.35em) #ch.#n]
        toc-line(loc, [#label #h(0.8em) #short-caption(el.caption.body)], pgnum, indent: 0pt, hanging: 3.0cm)
      } else {
        let n = if el.supplement == [Table] or el.kind == table {
          counter(figure.where(kind: table)).at(loc).first()
        } else if el.kind == raw {
          counter(figure.where(kind: raw)).at(loc).first()
        } else {
          counter(figure.where(kind: image)).at(loc).first()
        }
        let hang = if el.supplement == [Table] or el.kind == table { 2.2cm } else { 2.7cm }
        let label = [#el.supplement #h(0.35em) #ch.#n]
        toc-line(loc, [#label #h(0.8em) #short-caption(el.caption.body)], pgnum, indent: 0pt, hanging: hang)
      }
    } else {
      it
    }
  }

  show outline.entry.where(level: 2): it => {
    let el = it.element
    if el.func() != heading { return it }
    let loc = el.location()
    let nums = counter(heading).at(loc)
    let num = numbering("1.1", nums.at(0), nums.at(1))
    let pgnum = str(counter(page).at(loc).first())
    toc-line(loc, upper[#num #h(0.5em) #el.body], pgnum, indent: 1.2em, hanging: 0.9cm)
  }

  show outline.entry.where(level: 3): it => {
    let el = it.element
    if el.func() != heading { return it }
    let loc = el.location()
    let nums = counter(heading).at(loc)
    let num = numbering("1.1.1", nums.at(0), nums.at(1), nums.at(2))
    let pgnum = str(counter(page).at(loc).first())
    toc-line(loc, [#num #h(0.5em) #el.body], pgnum, indent: 2.4em, hanging: 1.3cm)
  }

  // ---------------- Figure / Table numbering ----------------
  // Format: <chapter>.<n>.  Counters are reset on each chapter heading.
  set figure(
    numbering: n => {
      let ch = counter(heading).at(here()).at(0)
      [#ch.#n]
    },
    gap: 0.6em,
    placement: none,
    supplement: auto,
  )
  // Allow long figures to break across pages. Tables need caption above,
  // matching thesis/Word convention; image captions stay below (Typst default).
  // Automatically wrap inline raw text inside table cells to prevent border overflow
  show table.cell: cell => {
    show raw.where(block: false): r => {
      let s = r.text.replace("/", "/\u{200b}").replace("_", "_\u{200b}").replace("-", "-\u{200b}")
      box(
        fill: rgb("#f3f4f6"),
        inset: (x: 2.5pt, y: 0pt),
        outset: (y: 2.5pt),
        radius: 2pt,
        text(
          font: "DejaVu Sans Mono",
          size: 0.82em,
          fill: rgb("#1f2937"),
          s
        )
      )
    }
    cell
  }

  show figure.where(kind: image): set block(breakable: true)
  show figure.where(kind: raw): set block(breakable: true)
  show raw: set block(breakable: true)
  show figure.where(kind: "equation"): it => {
    it.body
  }

  show figure.where(kind: table): it => {
    set block(breakable: true)
    show table: set block(breakable: true)
    [#metadata(none) <content>]
    block(breakable: true)[
      // Keep table caption attached to the first table row; otherwise Typst
      // may leave caption orphaned at page bottom while table starts next page.
      #block(sticky: true)[
        #it.caption
        #v(-0.4em)
      ]
      #it.body
    ]
  }
  // Caption: "Figure/Table N.M  Caption text"  (label + space, small font).
  show figure.caption: it => {
    set text(size: 11pt, style: "italic")
    set par(first-line-indent: 0pt, justify: true)
    align(center, block(width: 100%)[
      #text(weight: "regular")[#it.supplement #it.counter.display(it.numbering)]
      #h(0.5em)
      #it.body
    ])
  }

  // Equations numbered per chapter as well.
  set math.equation(
    numbering: n => {
      let ch = counter(heading).at(here()).at(0)
      [(#ch.#n)]
    },
  )

  // ================= FRONTMATTER =================
  // Covers (no page numbers)
  set page(numbering: none)
  cover-page(
    colors,
    logo,
    document-type,
    title,
    author,
    student-id-label + " " + student-id,
    advisors,
    study-program,
    department,
    institution,
    year,
  )
  blankpage()
  inner-cover-page(
    gray-logo,
    document-type,
    title,
    author,
    student-id-label + " " + student-id,
    advisors,
    study-program,
    department,
    institution,
    year,
  )
  blankpage()
  approval-page(
    background-image,
    title,
    document-type,
    degree,
    institution,
    year,
    author,
    student-id-label + " " + student-id,
    advisors,
    examiners,
    coordinator,
    coordinator-role,
  )
  blankpage()

  // Roman-numbered front matter
  set page(numbering: "i")
  counter(page).update(1)

  fm-toc-entry("STATEMENT OF ORIGINALITY")
  originality-page(
    document-type,
    institution,
    city,
    date,
    author,
    student-id-label + " " + student-id,
    text-content: originality-text,
  )
  blankpage()

  fm-toc-entry("PERNYATAAN PENGALIHAN HAK CIPTA")
  copyright-page(
    title,
    document-type,
    institution,
    city,
    date,
    author,
    student-id-label,
    student-id,
    text-content: copyright-text,
  )
  blankpage()

  fm-toc-entry("ABSTRACT")
  abstract-page(
    "ABSTRACT",
    content: abstract-en,
    keywords-label: "Keywords:",
    keywords: abstract-en-keywords,
  )
  blankpage()

  fm-toc-entry("ABSTRAK")
  abstract-page(
    "ABSTRAK",
    italic-title: true,
    italic-body: true,
    content: abstract-id,
    keywords-label: "Kata Kunci:",
    keywords: abstract-id-keywords,
  )
  blankpage()

  if foreword != none {
    fm-toc-entry("FOREWORD")
    frontmatter-content-page(
      "FOREWORD",
      foreword,
      basmalah: if show-basmalah { basmalah-image } else { none },
    )
    blankpage()
  }

  if acknowledgement != none {
    fm-toc-entry("ACKNOWLEDGEMENT")
    frontmatter-content-page("ACKNOWLEDGEMENT", acknowledgement)
  }

  // ---- Table of Contents ----
  pagebreak(to: "odd", weak: true)
  fm-toc-entry("TABLE OF CONTENT")
  align(center, text(weight: "bold", size: 14pt)[TABLE OF CONTENT])
  v(0.5em)
  [#metadata(none) <content>]
  outline(title: none, depth: 3, indent: auto)
  [#metadata(none) <content>]

  // ---- Table of Figures ----
  pagebreak(to: "odd", weak: true)
  fm-toc-entry("TABLE OF FIGURES")
  align(center, text(weight: "bold", size: 14pt)[TABLE OF FIGURE])
  v(0.5em)
  [#metadata(none) <content>]
  outline(title: none, target: figure.where(kind: image), indent: 0pt)
  [#metadata(none) <content>]

  // ---- List of Tables ----
  pagebreak(to: "odd", weak: true)
  fm-toc-entry("LIST OF TABLES")
  align(center, text(weight: "bold", size: 14pt)[LIST OF TABLES])
  v(0.5em)
  [#metadata(none) <content>]
  outline(title: none, target: figure.where(kind: table), indent: 0pt)
  [#metadata(none) <content>]

  // ---- List of Equations ----
  pagebreak(to: "odd", weak: true)
  fm-toc-entry("LIST OF EQUATIONS")
  align(center, text(weight: "bold", size: 14pt)[LIST OF EQUATIONS])
  v(0.5em)
  [#metadata(none) <content>]
  outline(title: none, target: figure.where(kind: "equation"), indent: 0pt)
  [#metadata(none) <content>]

  // ================= BODY (arabic numbering) =================
  pagebreak(to: "odd", weak: true)
  set page(numbering: "1")
  counter(page).update(1)

  body

  // ================= END MATTER =================
  if supplementary != none {
    pagebreak(to: "odd", weak: true)
    supplementary
  }

  if author-bio != none {
    pagebreak(to: "odd", weak: true)
    author-bio
  }
}
