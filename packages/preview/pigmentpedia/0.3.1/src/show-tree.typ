/*
  File: show-tree.typ
  Author: neuralpain
  Date Modified: 2025-01-11

  Description: Display Pigmentpedia ASCII tree.
*/

/// Display the structure of `pigmentpedia` in ASCII format.
///
/// -> content
#let print-pgmt-tree = {
  set page(
    columns: 2,
    margin: (top: 20mm, bottom: 12mm, x: 25mm),
    height: 12in,
    width: 8.5in,
    header: align(center)[`Pigmentpedia ASCII tree` \ ],
    footer: align(center)[#text(9pt, `https://typst.app/universe/package/pigmentpedia`)],
  )
  set text(12.5pt, black)
  v(5mm)
  raw("This is a flat ASCII tree representation of the structure of Pigmentpedia.

If a top-level group contains a \".\", it means that some or all pigments can be accessed at the base level of the pigment group.

css
└── .

pantone
├── c
│   ├── .
│   ├── gray
│   └── grey
├── cp
├── pms
│   ├── .
│   ├── process
│   ├── hexachrome
│   ├── gray
│   ├── grey
│   ├── metallic
│   ├── pastel
│   └── skintone
├── u
├── up
└── xgc

dic
├── cg-vol-1
├── cg-vol-2
├── tc-japan
├── tc-france
└── tc-china

ral
├── classic (Named Colors)
├── design
└── effect

ral-classic (Coded Colors)
└── .

hks
└── .

iscc-nbs
└── .

ncs
└── .

catppuccin
├── latte
├── frappe
├── macchiato
└── mocha

zhongguo
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
    ├── red
    ├── yellow
    ├── green
    ├── blue
    ├── pastel
    ├── aqua
    ├── grey-white
    ├── black
    └── gold-silver

nippon
├── jp
└── romaji

nippon-paint
└── .

nord
└── .

crayola
├── standard
│   └── metallic
└── fluorescent
")
}
