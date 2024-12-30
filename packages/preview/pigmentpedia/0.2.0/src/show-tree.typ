#let show-pigmentpedia-tree() = {
  set page(
    columns: 2,
    margin: (top: 1in, bottom: 0.5in),
    height: 13in,
    width: 8in,
    header: align(center)[#raw("pigmentpedia displayed as ASCII tree") \ \ ],
  )

  raw("Below is a flat ASCII tree type representation of the dictionary structure of pigmentpedia.

If a group contains a \".\", it means that some or all pigments can be accessed at the base level of the pigment group.


CSS
└── .

Pantone
├── .
├── Process
├── Gray
└── Grey

Pantone-C
├── .
├── Gray
└── Grey

Pantone-CP
└── .

Pantone-U
└── .

Pantone-UP
└── .

Pantone-XGC
└── .

Pantone-PMS
├── .
├── Process
├── Hexachrome
├── Gray
├── Grey
├── Metallic
├── Pastel
└── SkinTone

DIC
├── CG-Vol1
├── CG-Vol2
├── TC-Japan
├── TC-France
└── TC-China

RAL (RAL Classic named colors)
└── .

RAL-Classic
└── .

RAL-Design
└── .

RAL-Effect
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

NipponPaint
└── .

NordTheme
└── .

Crayola
├── Standard
│   └── Metallic
└── Fluorescent
")
}
