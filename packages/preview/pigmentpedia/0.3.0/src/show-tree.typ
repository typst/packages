/*
  File: show-tree.typ
  Author: neuralpain
  Date Modified: 2025-01-07

  Description: Display Pigmentpedia ASCII tree.
*/

/// Display the structure of `pigmentpedia` in ASCII format.
///
/// -> content
#let show-pigmentpedia-tree() = {
  set page(
    columns: 2,
    margin: (top: 20mm, bottom: 12mm, x: 25mm),
    height: 12in,
    width: 8.5in,
    header: align(center)[`pigmentpedia ASCII tree` \ ],
    footer: align(center)[#text(9pt, `https://typst.app/universe/package/pigmentpedia`)],
  )
  set text(12.5pt, black)
  v(5mm)
  raw("This is a flat ASCII tree representation of the structure of pigmentpedia.

If a top-level group contains a \".\", it means that some or all pigments can be accessed at the base level of the pigment group.

CSS
└── .

Pantone
├── C
│   ├── .
│   ├── Gray
│   └── Grey
├── CP
├── PMS
│   ├── .
│   ├── Process
│   ├── Hexachrome
│   ├── Gray
│   ├── Grey
│   ├── Metallic
│   ├── Pastel
│   └── SkinTone
├── U
├── UP
└── XGC

DIC
├── CG-Vol1
├── CG-Vol2
├── TC-Japan
├── TC-France
└── TC-China

RAL
├── Classic (Named colors)
├── Design
└── Effect

RAL-Classic (Coded colors)
└── .

HKS
└── .

ISCC-NBS
└── .

NCS
└── .

Catppuccin
├── Latte
├── Frappe
├── Macchiato
└── Mocha

Zhongguo
├── zh
│   ├── 红
│   ├── 黄
│   ├── 绿
│   ├── 蓝
│   ├── 苍
│   ├── 水
│   ├── 灰白
│   ├── 黑
│   └── 金银
├── pinyin
│   ├── hong
│   ├── huang
│   ├── lu
│   ├── lan
│   ├── cang
│   ├── shui
│   ├── huibai
│   ├── hei
│   └── jinyin
└── en
    ├── Red
    ├── Yellow
    ├── Green
    ├── Blue
    ├── Pastel
    ├── Aqua
    ├── Grey-White
    ├── Black
    └── Gold-Silver

Nippon
├── jp
└── romaji

Nippon-Paint
└── .

Nord
└── .

Crayola
├── Standard
│   └── Metallic
└── Fluorescent
")
}
