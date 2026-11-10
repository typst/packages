// Document template: cover page, table of contents, page layout.

#import "theme.typ": colors, fonts, icons

#let manual(
  title: "Document",
  subtitle: none,
  author: "",
  date: datetime.today(),
  paper: "a4",
  accent-color: colors.accent,
  cover-image: none,
  cover-line-1: none,
  cover-line-2: none,
  back-notice: none,
  version: "年月日", // Auto-format: YYYY年MM月DD日 when set to "年月日", else literal string
  menu-header: none,
  chapter-header: none,
  toc-type: "simple",
  body
) = {
  set document(title: title, author: author)
  set page(
    paper: paper,
    margin: (x: 2cm, top: 2.5cm, bottom: 2.5cm),
    header: context {
      let p = counter(page).get().first()
      if p > 1 {
        set text(font: fonts.header, size: 9pt, fill: colors.muted)
        grid(
          columns: (1fr, auto, 1fr),
          align(left, title),
          align(center)[        ],
          align(right, author)
        )
        v(-0.8em)
        line(length: 100%, stroke: 0.5pt + colors.line)
      }
    },
    footer: context {
      // Check if currently in TOC section
      let in-toc-state = state("in-toc")
      let in-toc-result = in-toc-state.get()
      let in-toc = if in-toc-result != none { in-toc-result } else { false }

      // Get current page counter value
      let page-value = counter(page).get().first()

      if page-value >= 1 {
        set text(font: fonts.header, size: 9pt, fill: colors.muted)
        grid(
          columns: (1fr, auto, 1fr),
          align(left)[    ],
          align(center)[
            #{
              let page-num = if in-toc {
                // TOC section: Roman numeral format
                "— " + counter(page).display("i") + " —"
              } else {
                // Body section: Arabic numeral format
                "— " + str(page-value) + " —"
              }
              text(page-num)
            }
          ],
          align(right)[    ]
        )
      }
    }
  )

  set text(
    font: fonts.body,
    size: 11pt,
    fill: colors.text,
    lang: "cn",
    features: (onum: 1)
  )

  // Headings
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    set align(center + horizon)
    block(width: 100%)[
      #text(font: fonts.header, weight: "bold", size: 0.9em, tracking: 2pt, fill: colors.accent, upper(chapter-header))
      #v(0.5em)
      #text(font: fonts.header, weight: "black", size: 3.5em, fill: colors.text, it.body)
    ]
  }

  show heading.where(level: 2): it => {
    pagebreak(weak: true)
    v(1em)
    text(font: fonts.header, weight: "bold", size: 2.2em, fill: colors.text, it.body)
    v(0.5em)
  }

  // Cover
  if title != none {
    page(margin: 0pt, header: none)[
      // Optional Background Image
      #if cover-image != none {
        place(top, image(cover-image, width: 100%, height: 100%, fit: "cover"))
      }

      // Top-left subtitle lines (use light fill on dark backgrounds)
      #if cover-line-1 != none or cover-line-2 != none {
        let line-fill = if cover-image != none { white } else { colors.text }
        place(top + left, dx: 10%, dy: 8%)[
          #if cover-line-1 != none [
            #text(font: fonts.sans, weight: "regular", size: 1.5em, fill: line-fill, cover-line-1)
          ]
          #if cover-line-2 != none [
            #v(0.5em)
            #text(font: fonts.sans, weight: "regular", size: 1.5em, fill: line-fill, cover-line-2)
          ]
        ]
      }

      #place(center + horizon)[
        #block(
           width: 75%,
           stroke: (
             top: 4pt + accent-color,
             bottom: if cover-image == none { 4pt + accent-color } else { none }
           ),
           inset: (y: 3em),
           fill: if cover-image != none { colors.bg-panel.lighten(10%) } else { none },
           outset: if cover-image != none { 1cm } else { 0cm }
        )[
          #par(leading: 0.35em)[
            #text(font: fonts.header, weight: "regular", size: 4.5em, fill: colors.text, title)
          ]
          #v(0.5em)
          #par(leading: 0.35em)[
            #text(font: fonts.header, weight: "light", size: 2em, fill: colors.text, subtitle)
          ]
          #v(0.8em)
          #text(font: fonts.body, style: "italic", size: 1.5em, fill: colors.muted, " " + author)
        ]
      ]

      #place(bottom + center)[
         #pad(bottom: 3cm, text(font: fonts.header, size: 0.8em, tracking: 3pt, fill: colors.muted, upper(date.display("[year]年[month]月"))))
      ]
    ]
  }

  // TOC
  if toc-type == "numbly" {
    state("in-toc").update(true)
    counter(page).update(1)
    page(
    header: none,
    )[
    #set text(font: fonts.header, size: 9pt, fill: colors.muted)
    #v(3cm)
    #align(center)[
       #text(font: fonts.header, weight: "bold", size: 1.2em, tracking: 2pt, fill: colors.accent, upper(menu-header))
       #v(1em)
       #line(length: 3cm, stroke: 0.5pt + colors.muted)
    ]
    #v(1.5cm)

    // Define TOC numbering counters
    #let h1-counter = counter("h1")
    #let h2-counter = counter("h2")
    // Define TOC entry counter
    #let entry-counter = counter("my-outline-entry")

    #h1-counter.update(1)
    #h2-counter.update(1)
    #entry-counter.update(1)
    #show outline.entry: it => {
      entry-counter.step()

      let is-first = if entry-counter.display("一") == "一" { true } else { false }
      // init TOCSkipPage
      let TOCSkipPage = state("TOCSkipPage", 0)
      if is-first {
        TOCSkipPage.update(old => old + it.element.location().page())
      }
      if it.level == 1 {
        // Level 1 heading: Chinese numeral numbering
        h1-counter.step()
        v(1.5em)
        box(width: 100%)[
          #text(font: fonts.header, weight: "black", size: 1.3em, fill: colors.text,
            h1-counter.display("一") + "、" + upper(it.element.body))
        ]
      } else {
        // Level 2 heading: Arabic numeral global numbering
        h2-counter.step()
        v(0.5em)
        box(width: 100%)[
          #text(font: fonts.body, size: 1.1em, fill: colors.text,
            h2-counter.display() + ". " + it.element.body)
          #box(width: 1fr, repeat[ #h(0.3em) #text(fill: colors.line.darken(20%), size: 0.6em)[.] #h(0.3em) ])
          #text(font: fonts.header, weight: "bold", fill: colors.muted, context it.element.location().page() - TOCSkipPage.get())
        ]
        }
      }

      #outline(title: none, indent: 0pt, depth: 2)
    ]
    } else if toc-type == "simple" {
    state("in-toc").update(true)
    counter(page).update(1)
  page(
    header: none,
  )[
    #v(3cm)
    #align(center)[
       #text(font: fonts.header, weight: "bold", size: 1.2em, tracking: 2pt, fill: colors.accent, upper(menu-header))
       #v(1em)
       #line(length: 3cm, stroke: 0.5pt + colors.muted)
    ]
    #v(1.5cm)

    #let toc-offset = 1
    #show outline.entry: it => {
      if it.level == 1 {
        // Section / Chapter Header
        v(1.5em)
        text(font: fonts.header, weight: "black", size: 1.3em, fill: colors.text, upper(it.element.body))
        h(1fr)
      } else {
        // Manual Entry
        v(0.5em)
        box(width: 100%)[
          #text(font: fonts.body, size: 1.1em, fill: colors.text, it.element.body)
          #box(width: 1fr, repeat[ #h(0.3em) #text(fill: colors.line.darken(20%), size: 0.6em)[.] #h(0.3em) ])
          #text(font: fonts.header, weight: "bold", fill: colors.muted, context it.element.location().page() - toc-offset)
        ]
        }
      }

      #outline(title: none, indent: 0pt, depth: 2)
    ]
    }

  // Reset TOC state
  state("in-toc").update(false)
  counter(page).update(1)
  body

  // Back — confidentiality notice
  if back-notice != none {
    pagebreak()
    align(bottom + left)[
      #h(2em)
      #text(weight: "bold", size: 14pt)[#back-notice]
    ]
  }
  if version != none {
    align(center + bottom)[
      #text(weight: "bold", size: 14pt)[版本日期:]
      #text(
        weight: "bold",
        size: 14pt,
        if version == "年月日" {
          upper(date.display("[year]年[month]月[day]日"))
        } else {
          version
        }
      )
    ]
  }
}
