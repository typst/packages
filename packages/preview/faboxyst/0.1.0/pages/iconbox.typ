// ===========================================================================
//  iconbox — dedicated preview page
//
//    typst compile pages/iconbox.typ pages/iconbox.pdf --root . --font-path fonts
// ===========================================================================

#import "/lib.typ": *

#set page(width: 18cm, height: auto, margin: 9mm)
#set text(font: "DejaVu Sans", size: 10.5pt)
#set par(leading: 0.65em)

#let titre(t) = block(above: 0.9em, below: 0.4em,
  text(size: 8pt, style: "italic", fill: rgb("#666"), t))

= iconbox — title banner + corner icon

#titre[1. the two source pictures, reproduced]

#grid(columns: (1fr, 1fr), column-gutter: 0.7cm, align: top,
  tip-card[
    Distribute each term in the first bracket to every term in the
    second bracket carefully.
  ],
  concept-card[
    If one number is increased by 2 and the other is decreased by 4,
    product remains the same.
  ],
)

#titre[2. `banner: true` / `false` — the title bar is optional]

#grid(columns: (1fr, 1fr), column-gutter: 0.55cm,
  iconbox(title: [Note], banner: true, colour: rgb("#1565C0"),
    icon: ico-bulb())[With a coloured title bar.],
  iconbox(title: [Note], banner: false, colour: rgb("#1565C0"),
    icon: ico-bulb())[Title as a heading, no bar.],
)

#titre[3. `icon` — any content; the three built-in drawings; or none]

#grid(columns: (1fr, 1fr, 1fr), column-gutter: 0.4cm,
  iconbox(title: [Pencil], banner: true, icon: ico-pencil(),
    colour: rgb("#C2185B"))[Built-in pencil.],
  iconbox(title: [Bulb], banner: true, icon: ico-bulb(),
    colour: rgb("#F9A825"), title-colour: rgb("#4E342E"))[Built-in bulb.],
  iconbox(title: [None], banner: true, icon: none,
    colour: rgb("#455A64"))[No icon at all.],
)

#titre[4. `mark` — a stamp in the trailing bottom corner]

#grid(columns: (1fr, 1fr), column-gutter: 0.55cm,
  iconbox(title: [Tip], banner: true, icon: ico-pencil(),
    mark: ico-star(), colour: rgb("#C2185B"))[A gold star.],
  iconbox(title: [Tip], banner: true, icon: ico-pencil(),
    mark: none, colour: rgb("#C2185B"))[No stamp.],
)

#titre[5. the frame stroke — `dash`, `weight`, `frame`, `stroke`, `frame-char`]

#grid(columns: (1fr, 1fr), column-gutter: 0.55cm, row-gutter: 0.45cm,
  iconbox(title: [Dashed], icon: ico-bulb(), dash: "dashed",
    colour: rgb("#3D5A80"))[dash: dashed],
  iconbox(title: [Dotted], icon: ico-bulb(), dash: "dotted",
    colour: rgb("#3D5A80"))[dash: dotted],
  iconbox(title: [Thick], icon: ico-pencil(), banner: true,
    weight: 3pt, colour: rgb("#6A1B9A"))[weight: 3pt],
  iconbox(title: [Stars], icon: ico-star(), frame-char: "*",
    colour: rgb("#C2185B"), banner: false)[frame-char: star],
)

#titre[6. `colour` is the family colour (bar, title, frame)]

#grid(columns: (1fr, 1fr, 1fr), column-gutter: 0.4cm,
  tip-card(colour: rgb("#2E7D32"), title: [Go])[Green family.],
  tip-card(colour: rgb("#E65100"), title: [Warn])[Orange family.],
  tip-card(colour: rgb("#1565C0"), title: [Info])[Blue family.],
)

#titre[7. RTL — icon and mark move to the leading-trailing edges]

#[
  #set text(lang: "ar", dir: rtl, font: ("Tajawal", "DejaVu Sans"))
  #grid(columns: (1fr, 1fr), column-gutter: 0.55cm,
    tip-card(title: [تنبيه])[
      وزّع كل حد من القوس الأول على كل حد من القوس الثاني.
    ],
    concept-card(title: [مفهوم])[
      إذا زيد أحد العددين بـ 2 ونقص الآخر بـ 4، بقي الجداء ثابتاً.
    ],
  )
]
