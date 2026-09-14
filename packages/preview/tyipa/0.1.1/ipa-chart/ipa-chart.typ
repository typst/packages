#let title = "The International Phonetic Alphabet"
#let title-addon = "(revised to 2015)"
#let author = "International Phonetic Association"
#let author-short = "IPA"
#let date = datetime(day: 1, month: 1, year: 2015)
#let copyright = sym.copyright + " " + str(date.year()) + " " + author-short
#let keywords = "IPA, International Phonetic Alphabet, transcription"
#let description = "Chart illustrating the International Phonetic Alphabet revised to 2015."

#let base-size = 8.5pt
#let title-size = 12.5pt
#let heading-size = 8.5pt
#let small-label-size = 7.5pt
#let symbol-size = 14pt
#let typeface = "Doulos SIL" // Try these: Doulos SIL, Gentium, Charis, Brill, Andika (use slightly smaller font sizes for Andika)
#let table-stroke = 0.2mm

#import "../src/lib.typ" as ipa

#let make-title(
  title,
  addon: ""
) = {
  set align(center)
  set text(size: title-size)
  [
    #upper(title)
    #addon
  ]
}

#let make-heading(
  body,
  addon: ""
) = {
  set text(size: heading-size)
  [
    #upper(body)
    #h(1fr)
    #addon
  ]
}

#let th(content, colspan: 1, align: left, size: heading-size, bottom-stroke: true, right-stroke: true) = {
  let cell-stroke = (
    right: table-stroke * int(right-stroke),
    bottom: table-stroke * int(bottom-stroke),
  )
  table.cell(
    [
      #set text(size: size)
      #content
    ],
    align: align,
    colspan: colspan,
    stroke: cell-stroke,
  )
}

#let th-h(content, size: heading-size, bottom-stroke: true) = {
  th(content, colspan: 2, align: center, size: size, bottom-stroke: bottom-stroke)
}

#let th-v(content, size: heading-size, bottom-stroke: true, right-stroke: true, colspan: 1) = {
  th(content, size: size, bottom-stroke: bottom-stroke, right-stroke: right-stroke, colspan: colspan)
}

#let tc-pair(first, second, colspan: 2) = {
  table.cell(
    [
      #set text(size: symbol-size)
      #grid(
        columns: (1fr, 1fr),
        grid.cell(align: center, first),
        grid.cell(align: center, second),
      )
    ],
    colspan: colspan
  )
}

#let tc-single(content, left-stroke: false, right-stroke: true, bottom-stroke: true) = {
  let cell-stroke = (
    left: table-stroke * int(left-stroke),
    right: table-stroke * int(right-stroke),
    bottom: table-stroke * int(bottom-stroke),
  )
  table.cell(
    [
      #set text(size: symbol-size)
      #set align(center)
      #content
    ],
    stroke: cell-stroke,
  )
}

#let tc-empty(colspan: 1, left-stroke: true, right-stroke: true) = {
  let cell-stroke = (
    left: table-stroke * int(left-stroke),
    right: table-stroke * int(right-stroke),
  )
  table.cell(hide["x"], colspan: colspan, stroke: cell-stroke)
}

#let tc-gray(colspan: 1) = {
  table.cell(hide["x"], fill: rgb("#ddd"), colspan: colspan)
}

#set document(
  author: author,
  date: date,
  description: description,
  keywords: keywords,
  title: title + " " + title-addon,
)

#set page(
  paper: "a4",
  header: none,
  footer: [
      #set align(center)
      #set text(fill: gray, size: small-label-size)
      Typeface: #typeface
    ],
  numbering: none,
  margin: (
    top: 1.2cm,
    left: 1.75cm,
    right: 1.75cm,
    bottom: 1.0cm
  )
)


#show table: set block(above: 5pt, below: 5pt)


#set text(size: base-size, font: typeface)

#make-title(title, addon: title-addon)

#make-heading("Consonants (pulmonic)", addon: copyright)

#table(
  columns: (3fr, 1fr, 1fr, 1.3fr, 1.3fr, 1fr, 1fr, 1fr, 1fr, 1.3fr, 1.3fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1.25fr, 1.25fr, 1fr, 1fr),
  rows: (2.5em, 2.5em, 2.5em, 2.5em, 2.5em, 2.5em, 2.5em, 2.5em, 2.5em),
  align: center + horizon,
  stroke: table-stroke,
  // Horizontal headings
  [], th-h("Bilabial"), th-h("Labiodental"), th-h("Dental"), th-h("Alveolar"), th-h("Postalveolar"), th-h("Retroflex"), th-h("Palatal"), th-h("Velar"), th-h("Uvular"), th-h("Pharyngeal"), th-h("Glottal"),
  // Plosives
  th-v("Plosives"), tc-pair(ipa.sym.p, ipa.sym.b), tc-empty(colspan: 2), tc-empty(colspan: 2, right-stroke: false), tc-pair(ipa.sym.t, ipa.sym.d), tc-empty(colspan: 2, left-stroke: false), tc-pair(ipa.sym.t.tail.right, ipa.sym.d.tail.right), tc-pair(ipa.sym.c, ipa.sym.j.dotless.barred), tc-pair(ipa.sym.k, ipa.sym.g), tc-pair(ipa.sym.q, ipa.sym.G), tc-empty(), tc-gray(), tc-single(ipa.sym.glottal-stop, left-stroke: true), tc-gray(),
  // Nasals
  th-v("Nasal"), tc-empty(), tc-single(ipa.sym.m), tc-empty(), tc-single(ipa.sym.mengma), tc-empty(colspan: 3, right-stroke: false), tc-single(ipa.sym.n), tc-empty(colspan: 2, left-stroke: false), tc-empty(), tc-single(ipa.sym.n.tail.right), tc-empty(colspan: 1), tc-single(ipa.sym.n.tail.left), tc-empty(), tc-single(ipa.sym.engma), tc-empty(), tc-single(ipa.sym.N), tc-gray(colspan: 2), tc-gray(colspan: 2),
  // Trills
  th-v("Trill"), tc-empty(), tc-single(ipa.sym.B), tc-empty(colspan: 2), tc-empty(colspan: 3, right-stroke: false), tc-single(ipa.sym.r), tc-empty(colspan: 2, left-stroke: false), tc-empty(colspan: 2), tc-empty(colspan: 2), tc-gray(colspan: 2), tc-empty(), tc-single(ipa.sym.R), tc-empty(colspan: 2), tc-gray(colspan: 2),
  // Taps and Flaps
  th-v("Tap or Flap"), tc-empty(colspan: 2), tc-empty(), tc-single(ipa.sym.v.hook-top), tc-empty(colspan: 3, right-stroke: false), tc-single(ipa.sym.r.fish-hook), tc-empty(colspan: 2, left-stroke: false), tc-empty(), tc-single(ipa.sym.r.tail.right), tc-empty(colspan: 2), tc-gray(colspan: 2), tc-empty(colspan: 2), tc-empty(colspan: 2), tc-gray(colspan: 2),
  // Fricatives
  th-v("Fricative"), tc-pair(ipa.sym.phi, ipa.sym.beta), tc-pair(ipa.sym.f, ipa.sym.v), tc-pair(ipa.sym.theta, ipa.sym.eth), tc-pair(ipa.sym.s, ipa.sym.z), tc-pair(ipa.sym.esh, ipa.sym.ezh), tc-pair(ipa.sym.s.tail.right, ipa.sym.z.tail.right), tc-pair(ipa.sym.c.cedilla, ipa.sym.j.tail.curly), tc-pair(ipa.sym.x, ipa.sym.gamma), tc-pair(ipa.sym.chi, ipa.sym.R.inverted), tc-pair(ipa.sym.h.barred, ipa.sym.glottal-stop.reversed), tc-pair(ipa.sym.h, ipa.sym.h.hook-top),
  // Lateral fricatives
  th-v("Lateral fricative"), tc-gray(colspan: 2), tc-gray(colspan: 2), tc-empty(colspan: 2, right-stroke: false), tc-pair(ipa.sym.l.belted, ipa.sym.lezh), tc-empty(colspan: 2, left-stroke: false), tc-empty(colspan: 2), tc-empty(colspan: 2), tc-empty(colspan: 2), tc-empty(colspan: 2), tc-gray(colspan: 2), tc-gray(colspan: 2),
  // Approximants
  th-v("Approximant"), tc-empty(colspan: 2), tc-empty(), tc-single(ipa.sym.v.cursive), tc-empty(colspan: 3, right-stroke: false), tc-single(ipa.sym.r.turned), tc-empty(colspan: 2, left-stroke: false), tc-empty(), tc-single(ipa.sym.r.turned.tail.right), tc-empty(), tc-single(ipa.sym.j), tc-empty(), tc-single(ipa.sym.m.turned.right-leg), tc-empty(colspan: 2), tc-empty(colspan: 2), tc-gray(colspan: 2),
  // Lateral approximants
  th-v("Lateral approximant"), tc-gray(colspan: 2), tc-gray(colspan: 2), tc-empty(colspan: 3, right-stroke: false), tc-single(ipa.sym.l), tc-empty(colspan: 2, left-stroke: false), tc-empty(), tc-single(ipa.sym.l.tail.right), tc-empty(), tc-single(ipa.sym.y.turned), tc-empty(), tc-single(ipa.sym.L), tc-empty(colspan: 2), tc-gray(colspan: 2), tc-gray(colspan: 2)
)

#align(center)[
  Symbols to the right in a cell are voiced, to the left are voiceless. Shaded areas denote articulations judged impossible.
]

#v(0.2cm)

#rect(
  width: 9cm,
  stroke: none,
  inset: 0em,
)[
    #make-heading("Consonants (non-pulmonic)")

    #let tc-single = tc-single.with(bottom-stroke: false)
    #let th-v = th-v.with(size: small-label-size, bottom-stroke: false)

    #table(
      columns: (0.25fr, 1fr, 0.25fr, 1fr, 0.25fr, 1fr),
      rows: (2.25em, 2.25em, 2.25em, 2.25em, 2.25em, 2.25em),
      align: center + horizon,
      stroke: table-stroke,
      th-h("Clicks"), th-h("Voiced implosives"), th-h("Ejectives"),
      tc-single(ipa.sym.bulls-eye, left-stroke: true, right-stroke: false), th-v("Bilabial"), tc-single(ipa.sym.b.hook-top, left-stroke: true, right-stroke: false), th-v("Bilabial"), tc-single(ipa.diac.ejective(ipa.sym.placeholder.blank), left-stroke: true, right-stroke: false), th-v("Examples:"),
      tc-single(ipa.sym.pipe, left-stroke: true, right-stroke: false), th-v("Dental"), tc-single(ipa.sym.d.hook-top, left-stroke: true, right-stroke: false), th-v("Dental/alveolar"), tc-single(ipa.diac.ejective(ipa.sym.p), left-stroke: true, right-stroke: false), th-v("Bilabial"),
      tc-single(ipa.sym.exclamation-mark, left-stroke: true, right-stroke: false), th-v("(Post)alveolar"), tc-single(ipa.sym.j.dotless.barred.hook-top, left-stroke: true, right-stroke: false), th-v("Palatal"), tc-single(ipa.diac.ejective(ipa.sym.t), left-stroke: true, right-stroke: false), th-v("Dental/alveolar"),
      tc-single(ipa.sym.pipe.double-barred, left-stroke: true, right-stroke: false), th-v("Palatoalveolar"), tc-single(ipa.sym.g.hook-top, left-stroke: true, right-stroke: false), th-v("Velar"), tc-single(ipa.diac.ejective(ipa.sym.k), left-stroke: true, right-stroke: false), th-v("Velar"),
      tc-single(ipa.sym.pipe.double, left-stroke: true, right-stroke: false, bottom-stroke: true), th-v("Alveolar lateral", bottom-stroke: true), tc-single(ipa.sym.G.hook-top, left-stroke: true, right-stroke: false, bottom-stroke: true), th-v("Uvular", bottom-stroke: true), tc-single(ipa.diac.ejective(ipa.sym.s), left-stroke: true, right-stroke: false, bottom-stroke: true), th-v("Alveolar fricative", bottom-stroke: true),
    )
]

#v(0.2cm)

#rect(
  width: 9.2cm,
  stroke: none,
  inset: 0em,
)[
    #make-heading("Other symbols")

    #let tc-single = tc-single.with(bottom-stroke: false)
    #let th-v = th-v.with(size: small-label-size, bottom-stroke: false, right-stroke: false)

    #table(
      columns: (0.1fr, 1.1fr, 0.3fr, 1fr),
      rows: (2.25em, 2.25em, 2.25em, 2.25em, 2.25em, 2.25em),
      align: left + horizon,
      stroke: none,
      tc-single(ipa.sym.w.turned, right-stroke: false), th-v("Voiceless labial-velar fricative"),
      tc-single(ipa.sym.c.tail.curly + " " + ipa.sym.z.tail.curly, right-stroke: false), th-v("Alveolo-palatal fricatives"),
      tc-single(ipa.sym.w, right-stroke: false), th-v("Voiced labial-velar approximant"),
      tc-single(hide("x") + ipa.sym.r.long-leg.turned, right-stroke: false), th-v("Voiced alveolar lateral flap"),
      tc-single(ipa.sym.h.turned, right-stroke: false), th-v("Voiced labial-palatal approximant"),
      tc-single(ipa.sym.hengma.hook-top + hide("x"), right-stroke: false), th-v("Simultaneous " + text(size: symbol-size, ipa.sym.esh) + " and " + text(size: symbol-size, ipa.sym.x)),
      tc-single(ipa.sym.H, right-stroke: false), th-v("Voiceless epiglottal fricative"),
      tc-empty(colspan: 2, left-stroke: false, right-stroke: false),
      tc-single(ipa.sym.glottal-stop.reversed.barred, right-stroke: false), th-v("Voiced epiglottal fricative"),
      tc-empty(colspan: 2, left-stroke: false, right-stroke: false),
      tc-single(ipa.sym.glottal-stop.barred, right-stroke: false), th-v("Epiglottal plosive"),
      tc-empty(colspan: 2, left-stroke: false, right-stroke: false),
    )

]

#place(
  top + left,
  dx: 4.65cm,
  dy: 17cm,
  rect(
      inset: 0em,
      stroke: none,
  )[
    #grid(
      columns: (4.0cm, 1.5cm),
      gutter: 0.5cm,
      align: left + horizon,
      [
        #set text(size: small-label-size)
        Affricates and double articulations
        can be represented by two symbols
        joined by a tie bar if necessary.
      ],
      [
        #set text(size: symbol-size)
        #ipa.diac.tied-below("ts") #h(.25cm) #ipa.diac.tied("kp")
      ]
    )
  ]
)

#rect(
  width: 12cm,
  stroke: none,
  inset: 0em,
)[
  #make-heading("Diacritics", addon: [
    Some diacritics may be placed above a symbol with a descender, e.g.
    #text(size: symbol-size, ipa.diac.voiceless-above(ipa.sym.engma))
    #h(2em)
  ])

  #let tc-single = tc-single.with(left-stroke: true, right-stroke: false)
  #let th-v = th-v.with(size: small-label-size, right-stroke: false)

  #table(
    columns: (0.3fr, 1fr, 0.3fr, 0.3fr, 0.3fr, 1.05fr, 0.3fr, 0.3fr, 0.3fr, 1.1fr, 0.3fr, 0.3fr),
    rows: (2.25em, 2.25em, 2.25em, 2.25em, 2.25em, 2.25em, 2.25em, 2.25em, 2.25em, 2.25em, 2.25em, 2.25em),
    stroke: table-stroke,

    tc-single(ipa.diac.voiceless(ipa.sym.placeholder.blank)), th-v("Voiceless"), tc-pair(ipa.diac.voiceless(ipa.sym.n), ipa.diac.voiceless(ipa.sym.d)),
    tc-single(ipa.diac.breathy(ipa.sym.placeholder.blank)), th-v("Breathy voiced"), tc-pair(ipa.diac.breathy(ipa.sym.b), ipa.diac.breathy(ipa.sym.a)),
    tc-single(ipa.diac.dental(ipa.sym.placeholder.blank)), th-v("Dental"), tc-pair(ipa.diac.dental(ipa.sym.t), ipa.diac.dental(ipa.sym.d)),

    tc-single(ipa.diac.voiced(ipa.sym.placeholder.blank)), th-v("Voiced"), tc-pair(ipa.diac.voiced(ipa.sym.s), ipa.diac.voiced(ipa.sym.t)),
    tc-single(ipa.diac.creaky(ipa.sym.placeholder.blank)), th-v("Creaky voiced"), tc-pair(ipa.diac.creaky(ipa.sym.b), ipa.diac.creaky(ipa.sym.a)),
    tc-single(ipa.diac.apical(ipa.sym.placeholder.blank)), th-v("Apical"), tc-pair(ipa.diac.apical(ipa.sym.t), ipa.diac.apical(ipa.sym.d)),

    tc-single(ipa.sym.h.raised), th-v("Aspirated"), tc-pair(ipa.diac.aspirated(ipa.sym.t), ipa.diac.aspirated(ipa.sym.d)),
    tc-single(ipa.diac.linguolabial(ipa.sym.placeholder.blank)), th-v("Linguolabial"), tc-pair(ipa.diac.linguolabial(ipa.sym.t), ipa.diac.linguolabial(ipa.sym.d)),
    tc-single(ipa.diac.laminal(ipa.sym.placeholder.blank)), th-v("Laminal"), tc-pair(ipa.diac.laminal(ipa.sym.t), ipa.diac.laminal(ipa.sym.d)),

    tc-single(ipa.diac.more-rounded(ipa.sym.placeholder.blank)), th-v("More rounded"), tc-pair(ipa.diac.more-rounded(ipa.sym.o.open), ""),
    tc-single(ipa.sym.w.raised), th-v("Labialized"), tc-pair(ipa.diac.labialized(ipa.sym.t), ipa.diac.labialized(ipa.sym.d)),
    tc-single(ipa.diac.nasalized(ipa.sym.placeholder.blank)), th-v("Nasalized"), tc-pair("", ipa.diac.nasalized(ipa.sym.e)),

    tc-single(ipa.diac.less-rounded(ipa.sym.placeholder.blank)), th-v("Less rounded"), tc-pair(ipa.diac.less-rounded(ipa.sym.o.open), ""),
    tc-single(ipa.sym.j.raised), th-v("Palatalized"), tc-pair(ipa.diac.palatalized(ipa.sym.t), ipa.diac.palatalized(ipa.sym.d)),
    tc-single(ipa.sym.n.raised), th-v("Nasal release"), tc-pair("", ipa.diac.nasal-release(ipa.sym.d)),

    tc-single(ipa.diac.advanced(ipa.sym.placeholder.blank)), th-v("Advanced"), tc-pair(ipa.diac.advanced(ipa.sym.u), ""),
    tc-single(ipa.sym.gamma.raised), th-v("Velarized"), tc-pair(ipa.diac.velarized(ipa.sym.t), ipa.diac.velarized(ipa.sym.d)),
    tc-single(ipa.sym.l.raised), th-v("Lateral release"), tc-pair("", ipa.diac.lateral-release(ipa.sym.d)),

    tc-single(ipa.diac.retracted(ipa.sym.placeholder.blank)), th-v("Retracted"), tc-pair(ipa.diac.retracted(ipa.sym.e), ""),
    tc-single(ipa.sym.glottal-stop.reversed.raised), th-v("Pharyngealized"), tc-pair(ipa.diac.pharyngealized(ipa.sym.t), ipa.diac.pharyngealized(ipa.sym.d)),
    tc-single(ipa.diac.no-release(ipa.sym.placeholder.blank)), th-v("No audible release", colspan: 2), tc-single(ipa.diac.no-release(ipa.sym.d) + "  ", left-stroke: false, right-stroke: true),

    tc-single(ipa.diac.centralized(ipa.sym.placeholder.blank)), th-v("Centralized"), tc-pair(ipa.diac.centralized(ipa.sym.e), ""),
    tc-single(ipa.diac.velopharyngealized(ipa.sym.placeholder.blank)), th-v("Velarized or pharyngealized", colspan: 3), tc-single(ipa.sym.l.tilde, left-stroke: false), tc-empty(colspan: 3, left-stroke: false),

    tc-single(ipa.diac.mid-centralized(ipa.sym.placeholder.blank)), th-v("Mid-centralized"), tc-pair(ipa.diac.mid-centralized(ipa.sym.e), ""),
    tc-single(ipa.diac.raised(ipa.sym.placeholder.blank)), th-v("Raised"), tc-single(ipa.diac.raised(ipa.sym.e), left-stroke: false), table.cell(colspan: 5, align: left + horizon, [
      #set text(size: small-label-size)
      ( #text(size: symbol-size, ipa.diac.raised(ipa.sym.r.turned)) = voiced alveolar fricative)
    ]),

    tc-single(ipa.diac.syllabic(ipa.sym.placeholder.blank)), th-v("Syllabic"), tc-pair(ipa.diac.syllabic(ipa.sym.e), ""),
    tc-single(ipa.diac.lowered(ipa.sym.placeholder.blank)), th-v("Lowered"), tc-single(ipa.diac.lowered(ipa.sym.e), left-stroke: false), table.cell(colspan: 5, align: left + horizon, [
      #set text(size: small-label-size)
      ( #text(size: symbol-size, ipa.diac.lowered(ipa.sym.beta)) = voiced bilabial approximant)
    ]),

    tc-single(ipa.diac.non-syllabic(ipa.sym.placeholder.blank)), th-v("Non-syllabic"), tc-pair(ipa.diac.non-syllabic(ipa.sym.e), ""),
    tc-single(ipa.diac.atr(ipa.sym.placeholder.blank)), th-v("Advanced Tongue Root", colspan: 3), tc-single(ipa.diac.atr(ipa.sym.e), left-stroke: false), tc-empty(colspan: 3, left-stroke: false),

    tc-single(ipa.diac.rhotic(ipa.sym.placeholder.blank)), th-v("Rhoticity"), tc-pair(ipa.sym.e.hook, ipa.diac.rhotic(ipa.sym.a)),
    tc-single(ipa.diac.rtr(ipa.sym.placeholder.blank)), th-v("Retracted Tongue Root", colspan: 3), tc-single(ipa.diac.rtr(ipa.sym.e), left-stroke: false), tc-empty(colspan: 3, left-stroke: false),
  )
]

#place(
  top + right,
  dy: 8.7cm,
  rect(
    stroke: none,
    width: 7.8cm,
    height: 6.5cm,
  )[
    #make-heading("Vowels")

    #let vowel-pair(left-content, right-content, spacing: 0.2cm) = {
      [
        #set text(size: symbol-size)
        #box(
          fill: white,
          radius: 0.2cm,
          inset: 0.1cm,
          left-content
        )
        #h(spacing)
        #box(
          fill: white,
          radius: 0.2cm,
          inset: 0.1cm,
          right-content
        )
      ]
    }

    #let vowel(content) = {
      [
        #set text(size: symbol-size)
        #box(
          fill: white,
          radius: 0.2cm,
          inset: 0.1cm,
          content
        )
      ]
    }

    #let desc(content) = {
      [
        #set text(size: heading-size)
        #content
      ]
    }

    #set line(stroke: table-stroke)

    #place(
      top + left,
      line(
        start: (1.6cm, 1.1cm),
        end:   (4.4cm, 5.2cm),
      )
    )
    #place(
      top + left,
      line(
        start: (1.6cm, 1.1cm),
        end:   (7.1cm, 1.1cm),
      )
    )
    #place(
      top + left,
      line(
        start: (7.1cm, 1.1cm),
        end:   (7.1cm, 5.2cm),
      )
    )
    #place(
      top + left,
      line(
        start: (4.4cm, 5.2cm),
        end:   (7.1cm, 5.2cm),
      )
    )
    #place(
      top + left,
      line(
        start: (4.35cm, 1.1cm),
        end:   (5.75cm, 5.2cm),
      )
    )
    #place(
      top + left,
      line(
        start: (2.45cm, 2.36cm),
        end:   (7.10cm, 2.36cm),
      )
    )
    #place(
      top + left,
      line(
        start: (3.4cm, 3.73cm),
        end:   (7.1cm, 3.73cm),
      )
    )
    #let separator = circle(
          fill: black,
          radius: 0.8mm,
          outset: 0cm,
          inset: 0cm,
          stroke: none,
    )
    #place(
      top + left,
      dx: 1.53cm,
      dy: 1.02cm,
      separator
    )
    #place(
      top + left,
      dx: 4.27cm,
      dy: 1.02cm,
      separator
    )
    #place(
      top + left,
      dx: 7.02cm,
      dy: 1.02cm,
      separator
    )
    #place(
      top + left,
      dx: 2.37cm,
      dy: 2.28cm,
      separator
    )
    #place(
      top + left,
      dx: 4.7cm,
      dy: 2.28cm,
      separator
    )
    #place(
      top + left,
      dx: 7.02cm,
      dy: 2.28cm,
      separator
    )
    #place(
      top + left,
      dx: 3.32cm,
      dy: 3.65cm,
      separator
    )
    #place(
      top + left,
      dx: 5.17cm,
      dy: 3.65cm,
      separator
    )
    #place(
      top + left,
      dx: 7.02cm,
      dy: 3.65cm,
      separator
    )
    #place(
      top + left,
      dx: 4.31cm,
      dy: 5.11cm,
      separator
    )
    #place(
      top + left,
      dx: 7.02cm,
      dy: 5.11cm,
      separator
    )
    #place(
      top + left,
      dx: 1.1cm,
      dy: 0.76cm,
      vowel-pair(ipa.sym.i, ipa.sym.y)
    )
    #place(
      top + left,
      dx: 3.85cm,
      dy: 0.76cm,
      vowel-pair(ipa.sym.i.barred, ipa.sym.u.barred)
    )
    #place(
      top + left,
      dx: 6.3cm,
      dy: 0.76cm,
      vowel-pair(ipa.sym.m.turned, ipa.sym.u)
    )
    #place(
      top + left,
      dx: 2.4cm,
      dy: 1.4cm,
      vowel-pair(ipa.sym.I, ipa.sym.Y, spacing: 0cm)
    )
    #place(
      top + left,
      dx: 5.9cm,
      dy: 1.4cm,
      vowel(ipa.sym.upsilon)
    )
    #place(
      top + left,
      dx: 1.85cm,
      dy: 2.05cm,
      vowel-pair(ipa.sym.e, ipa.sym.o.slashed)
    )
    #place(
      top + left,
      dx: 4.2cm,
      dy: 2.05cm,
      vowel-pair(ipa.sym.e.reversed, ipa.sym.o.barred)
    )
    #place(
      top + left,
      dx: 6.41cm,
      dy: 2.05cm,
      vowel-pair(ipa.sym.rams-horn, ipa.sym.o)
    )
    #place(
      top + left,
      dx: 4.83cm,
      dy: 2.75cm,
      vowel(ipa.sym.schwa)
    )
    #place(
      top + left,
      dx: 2.8cm,
      dy: 3.4cm,
      vowel-pair(ipa.sym.epsilon, ipa.sym.oe)
    )
    #place(
      top + left,
      dx: 4.65cm,
      dy: 3.4cm,
      vowel-pair(ipa.sym.epsilon.reversed, ipa.sym.epsilon.reversed.closed)
    )
    #place(
      top + left,
      dx: 6.44cm,
      dy: 3.4cm,
      vowel-pair(ipa.sym.v.turned, ipa.sym.o.open)
    )
    #place(
      top + left,
      dx: 3.2cm,
      dy: 4.2cm,
      vowel(ipa.sym.ae)
    )
    #place(
      top + left,
      dx: 5.3cm,
      dy: 4.2cm,
      vowel(ipa.sym.a.turned)
    )
    #place(
      top + left,
      dx: 3.8cm,
      dy: 4.87cm,
      vowel-pair(ipa.sym.a, ipa.sym.OE)
    )
    #place(
      top + left,
      dx: 6.44cm,
      dy: 4.87cm,
      vowel-pair(ipa.sym.alpha, ipa.sym.alpha.turned)
    )
    #place(
      top + left,
      dx: 0cm,
      dy: 1cm,
      desc("Close")
    )
    #place(
      top + left,
      dx: 0cm,
      dy: 2.25cm,
      desc("Close-mid")
    )
    #place(
      top + left,
      dx: 0cm,
      dy: 3.6cm,
      desc("Open-mid")
    )
    #place(
      top + left,
      dx: 0cm,
      dy: 5.15cm,
      desc("Open")
    )
    #place(
      top + left,
      dx: 1.2cm,
      dy: 0.5cm,
      desc("Front")
    )
    #place(
      top + left,
      dx: 3.96cm,
      dy: 0.5cm,
      desc("Central")
    )
    #place(
      top + left,
      dx: 6.95cm,
      dy: 0.5cm,
      desc("Back")
    )
    #place(
      top + left,
      dx: 2.4cm,
      dy: 5.6cm,
      desc([
        Where symbols appear in pairs, the one\
        to the right represents a rounded vowel.
      ])
    )
  ]
)

#place(
  top + right,
  dy: 15.7cm,
  rect(
    width: 5cm,
    stroke: none,
    inset: 0mm,
    [
      #set align(left)

      #make-heading("Suprasegmentals")

      #let show-symbol(s, width: 0.5cm) = {
        box(
          width: width,
          height: 1.5em,
          [
            #set text(size: symbol-size)
            #set align(center + horizon)
            #s
          ]
        )
      }

      #let desc(content, width: auto) = {
        box(
          height: 1.5em,
          width: width,
          [
            #set text(size: heading-size)
            #set align(left + horizon)
            #content
          ]
        )
      }

      #show-symbol(ipa.sym.stress-mark.primary)
      #desc("Primary stress")\
      #show-symbol(ipa.sym.stress-mark.secondary)
      #desc("Secondary stress")\
      #show-symbol(ipa.sym.length-mark.long)
      #desc("Long", width: 1.5cm)
      #show-symbol(ipa.sym.e + ipa.sym.length-mark.long)\
      #show-symbol(ipa.sym.length-mark.half-long)
      #desc("Half-long", width: 1.5cm)
      #show-symbol(ipa.sym.e + ipa.sym.length-mark.half-long)\
      #show-symbol(ipa.diac.extra-short(ipa.sym.placeholder.blank))
      #desc("Extra-short", width: 1.5cm)
      #show-symbol(ipa.diac.extra-short(ipa.sym.e))\
      #show-symbol(ipa.sym.group-mark.minor)
      #desc("Minor (foot) group")\
      #show-symbol(ipa.sym.group-mark.major)
      #desc("Major (intonation) group")\
      #show-symbol(ipa.sym.syllable-break)
      #desc("Syllable break", width: 2.25cm)
      #box(
        height: 1.5em,
        [
          #set text(size: (symbol-size + heading-size) / 2)
          #set align(left + horizon)
          #ipa.text("r.turned i syllable-break ae k t")
        ]
      )\
      #show-symbol(ipa.sym.undertie)
      #desc("Linking (absence of a break)")\

      #place(
        top + right,
        dy: 1cm,
        [
          #set text(size: (symbol-size + heading-size) / 2)
          #ipa.text("stress-mark.secondary f o upsilon n schwa stress-mark t I esh schwa n")
        ]
      )
    ]
  )
)


#place(
  top + right,
  dy: 22.4cm,
  rect(
    width: 4.9cm,
    stroke: none,
    inset: 0mm,
    [
      #set align(left)

      #let make-subheading(content) = [
        #set align(center)
        #set text(size: small-label-size - 0.5pt)
        #upper(content)
      ]

      #let make-row(glyph-a, inter, glyph-b, desc) = {
        box(height: 0.4cm,
          grid(
            columns: (0.5fr, 0.2fr, 0.5fr, 1fr),
            inset: 0mm,
            align: center + horizon,
            column-gutter: (0mm, 0mm, 1mm),
          )[
            #set text(size: symbol-size)
            #glyph-a
          ][
            #set text(size: small-label-size)
            #inter
          ][
            #set text(size: symbol-size)
            #glyph-b
          ][
            #set par(leading: 0.3em)
            #set text(size: small-label-size)
            #set align(left)
            #desc
          ]
        )
      }

      #let make-ext-row(glyph, desc) = {
        box(height: 0.4cm,
          grid(
            columns: (0.2fr, 1fr),
            inset: 0mm,
            align: center + horizon,
            column-gutter: 2mm,
          )[
            #set text(size: symbol-size)
            #glyph
          ][
            #set text(size: small-label-size)
            #set align(left)
            #desc
          ]
        )
      }

      #make-heading[
        #set align(center)
        Tones and word accents
      ]
      #v(-0.6cm)
      #grid(
        columns: (1fr, 1fr),
        column-gutter: 4mm,
      )[
        #make-subheading[Level]
        #v(2mm, weak: true)
        #make-row(ipa.diac.extra-high(ipa.sym.e), "or", ipa.sym.tone-bar.extra-high, [Extra\ high])
        #v(2mm, weak: true)
        #make-row(ipa.diac.high(ipa.sym.e), "",   ipa.sym.tone-bar.high, [High])
        #v(2mm, weak: true)
        #make-row(ipa.diac.mid(ipa.sym.e), "",   ipa.sym.tone-bar.mid, [Mid])
        #v(2mm, weak: true)
        #make-row(ipa.diac.low(ipa.sym.e), "",   ipa.sym.tone-bar.low, [Low])
        #v(2mm, weak: true)
        #make-row(ipa.diac.extra-low(ipa.sym.e), "",   ipa.sym.tone-bar.extra-low, [Extra\ low])
        #v(2mm, weak: true)
        #make-ext-row(ipa.sym.downstep, [Downstep])
        #v(2mm, weak: true)
        #make-ext-row(ipa.sym.upstep, [Upstep])
      ][
        #make-subheading[Contour]
        #v(2mm, weak: true)
        #make-row(ipa.diac.rising(ipa.sym.e), "or", ipa.sym.tone-bar.extra-low + ipa.sym.tone-bar.extra-high, [Rising])
        #v(2mm, weak: true)
        #make-row(ipa.diac.falling(ipa.sym.e), "",   ipa.sym.tone-bar.extra-high + ipa.sym.tone-bar.extra-low, [Falling])
        #v(2mm, weak: true)
        #make-row(ipa.diac.high-rising(ipa.sym.e), "",   ipa.sym.tone-bar.mid + ipa.sym.tone-bar.extra-high, [High\ rising])
        #v(2mm, weak: true)
        #make-row(ipa.diac.low-rising(ipa.sym.e), "",   ipa.sym.tone-bar.extra-low + ipa.sym.tone-bar.mid, [Low\ rising])
        #v(2mm, weak: true)
        #make-row(ipa.diac.rising-falling(ipa.sym.e), "",   ipa.sym.tone-bar.mid + ipa.sym.tone-bar.high + ipa.sym.tone-bar.low, [Rising-\ falling])
        #v(2mm, weak: true)
        #make-ext-row(ipa.sym.global-rise, [Global rise])
        #v(2mm, weak: true)
        #make-ext-row(ipa.sym.global-fall, [Global fall])
      ]

    ]
  )
)
