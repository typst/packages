// --- COLORS AND GLOBAL VARIABLES (Light Theme) ---
#let bg-color = white
#let text-main = rgb("#1a1a1a")
#let text-muted = rgb("#666666")
#let card-bg = rgb("#fafafa")
#let card-border = rgb("#e0e0e0")

// Colors
#let accent = rgb("#008b8b")
#let warning = rgb("#e19b19")
#let example-color = rgb("#777777")
#let danger = rgb("#d32f2f")
#let zdb-color = rgb("#1976d2")
#let night-color = rgb("#7b1fa2")

// Font
#let font-mono = ("JetBrains Mono", "Fira Code", "Roboto Mono", "Consolas", "monospace")
#let font-sans = ("Syne", "Montserrat", "Segoe UI", "sans-serif")

// --- INLINE STYLES ---
#let kw(it, color: accent) = strong(text(fill: color, font: font-mono, weight: "extrabold", it))

// Hiighlight
#let hl(it, color: accent) = highlight(
  fill: color.lighten(80%),
  top-edge: 1.1em,
  bottom-edge: -0.3em
)[#text(size: 0.9em, font: font-mono)[#it]]


// --- CALLOUT ---
#let callout(title: "", icon: "", color: accent, body) = {
  block(
    width: 100%,
    fill: color.lighten(85%),
    stroke: 1pt + color.lighten(20%),
    inset: 16pt,
    radius: 10pt, 
    breakable: true,
    stack(
      spacing: 0.8em,
      grid(
        columns: (auto, 1fr),
        gutter: 10pt,
        align: (center + horizon, left + horizon),
        text(fill: color, size: 1.4em)[#icon],
        text(fill: color.darken(20%), size: 0.9em, font: font-sans, weight: 900)[#underline[#title]]
      ),
      text(fill: text-main, size: 0.95em)[
        #v(0.3em)
        #body
      ]
    )
  )
}

#let crop(img, top: 0pt, bottom: 0pt, left: 0pt, right: 0pt) = {
  block(clip: true)[
    #box(inset: (top: -top, bottom: -bottom, left: -left, right: -right))[
      #img
    ]
  ]
}

// --- CUSTOM functions ---
#let note(corpo) =[
  #hl(color: warning)[#text(fill: warning.darken(15%), weight: "bold", "👉 Note")]: #text(fill: text-main)[#corpo] \
]
#let tip(corpo) =[
  #hl(color: accent)[#text(fill: green.darken(15%), weight: "bold", "✅ Tip")]: #text(fill: text-main)[#corpo] \
]
#let problem(corpo) = [
  #hl(color: danger)[#text(fill: danger.darken(15%), weight: "bold","❗️ Problem")]: #text(fill: danger.darken(10%))[#corpo] \
]
#let why(title: "", corpo) =[
  #hl(color: night-color)[#text(fill: night-color.darken(15%), weight: "bold","🤔 Why") #title?]: #text(fill: text-main)[#corpo] \
]
#let how(title: "", corpo) =[
  #hl(color: zdb-color)[#text(fill: zdb-color.darken(15%), weight: "bold","👨🏻‍🏫 How") #title?]: #text(fill: text-main)[#corpo] \
]
#let extra(corpo) =[
  #v(-6pt)
  #set par(leading: 4pt)
  #text(style: "italic", fill: text-muted, size: 0.75em)[#corpo]
]

#let so = text()[$=>$]
#let arrow = text()[$->$]

// --- custom callout ---
#let def(title, body) = callout(title: title, icon: "📖", color: accent, body)
#let important(title, body) = callout(title: title, icon: "⚠️", color: warning, body)
#let example(title, body) = callout(title: title, icon: "📝", color: example-color, body)

#let side-note(it) = block(
  fill: accent.lighten(90%),
  stroke: (left: 3pt + accent),
  inset: 10pt,
  radius: (right: 8pt),
  width: 100%,
  text(fill: text-main)[#it]
)


// --- MAIN DOCUMENT FUNCTION ---
#let project(
  title: "",
  subject: "",
  professor: "",
  author: "",
  logo-subject: none,
  logo-personal: none,
  year: { let y = datetime.today().year(); str(y - 1) + "/" + str(y) },
  bento-url: "",
  paypal-url: "",
  contact-url: "",
  lang: "en",
  body
) = {
  
  set document(author: author, title: title)
  set page(fill: bg-color)
  
  set text(font: font-mono, fill: text-main, lang: lang, size: 9pt, tracking: -0.07em, hyphenate: true)
  set heading(numbering: "1.1.")
  set par(justify: true, leading: 0.8em, spacing: 1.5em)
  
  // --- TITLES STYLES ---
  show heading: it => {
    v(1.2em)
    set text(font: font-sans, fill: rgb("#111111"), weight: 800)
    if it.level == 1 {
      text(size: 1.6em)[#it]
    } else if it.level == 2 {
      text(size: 1.3em, fill: accent)[#it]
    } else {
      text(size: 1.1em)[#it]
    }
    v(0.6em)
  }

  show link: it => underline(text(fill: accent, it))
  
  // code block style
  show raw.where(block: true): it => {
    block(
      fill: rgb("#001719"),
      inset: 12pt,
      radius: 8pt,
      width: 100%,
      stroke: 1pt + rgb("#e0e5e5"),
      {
        set text(fill: rgb("#ffffff"), size: 7.5pt, font: font-mono)
        it
      }
    )
  }

  //  Inline code style
  show raw.where(block: false): it => box(
    fill: rgb("#f0f4f4").darken(10%),
    inset: (x: 4pt, y: 0pt),
    outset: (y: 3pt),
    radius: 4pt, baseline: 15%,
    text(font: font-mono, fill: accent.darken(55%), size: 0.9em, it)
  )

  set list(marker: (text(fill: accent)[•], text(fill: text-muted)[◦], text(fill: text-muted)[--]))

  // --- TITLE PAGE ---
  page(align(center + horizon)[
    #v(18em)
    #if logo-subject != none [ #box(width: 60pt)[#logo-subject] ] else[ #box() ]
    #v(3em)
    
    #text(fill: accent, font: font-mono, size: 0.9em, weight: "bold", tracking: 0.15em)[\/\/ #subject] \
    #v(1em)
    
    #text(font: font-sans, weight: 800, size: 2.75em, fill: rgb("#111111"), title) \
    #v(0em)
    
    #block(width: 80%)[
      #text(size: 1em, fill: text-muted, style: "italic", professor)
    ]
    #v(3em)
    
    #text(size: 1.2em, fill: text-main, weight: "bold", "by " + author)
    #if logo-personal != none {
      v(0.5em)
      box(width: 30pt)[#logo-personal]
    }
    #v(1fr)
    #text(fill: text-muted, font: font-mono, "// " + year)
  ])

  pagebreak(to: "even")

  // --- DISCLAIMER / WARNING PAGE --- 
  //rewrite with your context
  page(align(center + horizon)[
    #block(width: 80%, fill: card-bg.darken(5%), stroke: 1pt + card-border.darken(20%), radius: 12pt, inset: 24pt)[
      #text(font: font-sans, weight: 800, size: 1.6em, fill: danger)[#underline[Disclaimer & Info]]
      #v(1.5em)
      #set align(left)
      #set text(size: 10pt)

      This document is a *#underline[personal]* collection based on lectures and/or educational materials provided by professors and/or collected over the years by students.
      
      #v(1em)
      #callout(title: "Attention", color: danger, icon: "❗️")[
        The author assumes no responsibility for any errors, omissions, or inaccuracies. The material is provided "as is" for educational support purposes only.
      ]
      
      #v(1.5em)
      If you want to *add* useful material or *report* errors, please do so #link(contact-url)[#underline[here]].
      
      #v(1.5em)
      #line(length: 100%, stroke: 0.5pt + card-border)
      #v(1.5em)
      
      #align(center)[
        I hope this resource proves useful to you. Good study and good luck! 👾
        
        #v(1.5em)
        If you'd like to support me with a chocolate 🍫, you can do so #link(paypal-url)[#underline[here]]. \
        #v(1.5em)
        #link(bento-url)[
          #box(fill: accent.lighten(85%), stroke: 1pt + accent, radius: 8pt, inset: 10pt)[
            #text(fill: accent.darken(10%), weight: "bold", font: font-sans)[Bento Profile]
          ]
        ]
      ]
    ]
  ])

  pagebreak(to: "odd")

  // --- Table of Contents ---
  show outline.entry.where(level: 1): it => {
    v(12pt, weak: true)
    text(font: font-sans, fill: rgb("#111111"), weight: 800, it)
  }
  show outline: set text(fill: rgb("#444444"))
  
  block(
    fill: card-bg,
    stroke: 1pt + card-border,
    radius: 12pt,
    inset: 20pt,
    width: 100%
  )[
    #text(font: font-sans, size: 1.5em, weight: 800, fill: rgb("#111111"))[Table of Contents]
    #v(1em)
    #outline(indent: auto, depth: 3, title: none)
  ]
  
  pagebreak(to: "odd")

  // --- HEADER and FOOTER ---
  set page(
    header: context {
      if counter(page).get().first() > 2 {
        grid(
          columns: (0.1fr, 1fr, 1fr),
          align(left + bottom)[
            #if logo-subject != none [ #block(width: 14pt)[#logo-subject] ] else [ #box() ]
          ],
          align(left + horizon)[
            #set text(size: 9pt, fill: text-muted, font: font-mono)
            #title
          ],
          align(right + bottom)[
             #if logo-personal != none {block(width: 14pt)[#logo-personal] }
          ]
        )
        v(-5pt)
        line(length: 100%, stroke: 1pt + card-border)
      }
    },
    footer: context {
      if counter(page).get().first() > 1 {
        align(center)[
          #text(fill: text-muted, font: font-mono, size: 9pt)[
            --- #counter(page).display() ---
          ]
        ]
      }
    }
  )

  body
}
