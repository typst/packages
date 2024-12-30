# pigmentpedia (v0.2.0)

An extended color library for Typst.

> Contains approximately 21,950 pigments at the time of current release.

## Quick Start

```typ
// a sample document to familiarize yourself with pigmentpedia

#import "@preview/pigmentpedia:0.2.0": *

#set page(background: rotate(-45deg, text(160pt, fill: Pantone.Gray.Cool-Gray-1)[SAMPLE]))
#show heading: it => [#v(5mm) #it #v(2mm)]
#set par(justify: true)

// uncomment to view Crayola colors
// #view-pigments(Crayola)

// uncomment to search for a specific color
// #find-pigment("gray")
// #find-pigment("orange", scope: Crayola) // search within scope

= #text(Crayola.Standard.Maximum-Red, 2em)[A Journey Through Hope]

== #pigment(Crayola.Standard.Burnt-Orange)[A Healthy Diet Starts With You]

#pigment(Crayola.Standard.Orange, lorem(80))

== #pigment(Crayola.Standard.Maximum-Blue)[Enough Sleep For A Lifetime]

#pigment(Crayola.Standard.Cerulean-Blue)[
  #lorem(100) \ \
  #lorem(100)
]

== #pigment(Crayola.Standard.Maximum-Green)[No Better Time Than The Present]

#pigment(Crayola.Standard.Asparagus, lorem(35))

#align(bottom)[
  #line(length: 100%, stroke: 0.2pt + grey)
  #emph(
    pigment(Pantone.Gray.Cool-Gray-11)[
      This is a sample document showcasing the use of pigmentpedia in text application. The pigments in pigmentpedia are not solely for text; they can be used anywhere you need a more diverse range of color in your documentation.

      Это образец документа, демонстрирующий использование pigmentpedia в текстовом приложении. Пигменты в pigmentpedia предназначены не только для текста; их можно использовать везде, где вам нужен более разнообразный диапазон цветов в вашей документации.

      这是一个示例文档，展示了在文本应用程序中使用pigmentpedia。pigmentpedia中的颜料不仅仅用于文本；它们可以用在文档中需要更多样化颜色的任何地方。
    ],
  )
]

// --- SCROLL TO VIEW BELOW ---

// find a nice green color
// #find-pigment("G20Y") // search with NCS partial color name
// uncomment to view a nice green color
// #view-pigment(NCS.S-1070-G20Y)
```

## Usage

Add pigmentpedia to your project with the following code.

```typ
#import "@preview/pigmentpedia:0.2.0": *
```

Pigment text with either `text()` or the custom `pigment()` wrapper that does the same job but only for color.

> I wanted to **only** set a color to a specific group text so I created this wrapper function. It also makes it easier to find/select in search among other `text()` elements. #petpeeve

```typ
#text(DIC.CG456.DIC-2001)[This text has a DIC 2001 pigment.]
// ---
#pigment(NCS.S-0570-Y)[This text is has a NCS S-0570-Y pigment.]
```

### Display all pigments from (...)

There are a lot of colors included within pigmentpedia and it would be a hassle to remember the names of them all. Luckily, you can do a quick search through the list to view and find a color you want to use in your project/document.

```typ
// show all 20k+ pigments
#show-pigmentpedia() // dedicated wrapper function
#view-pigments(pigmentpedia) // directly using the `pigmentpedia` list

// show all pigments from a specific group
#view-pigments(NordTheme)

// show only a specific subset of pigments from a group
#view-pigments(Zhongguo.en.Blue)
```

<!--
> [!TIP]
> If you're unfamiliar with the standards or pigments here in pigmentpedia, I would recommend viewing the pigment groups to discover their names.
-->

### View a specific pigment from pigmentpedia

If you want to have a look at a single pigment, you can isolate it on a single page.

```typ
// just remove the "s" from `view-pigments`
#view-pigment(Catppuccin.Latte.Mauve)
```

You can also use `view-pigment()` to display custom colors.

```typ
#view-pigment(rgb(23,56,129)) // RGB color
#view-pigment(luma(24)) // Luma color
#view-pigment(color.hsl(30deg, 50%, 60%)) // HSL color
```

### Search for a specific pigment

Find a pigment you're familiar with, or one even better. You can search with either the partial name or HEX code. Search is not case-sensitive, but multiple keywords strictly reserves the order of precedence.

```typ
// find Zhongguo.en.Red.Blood-Flowing-Red
#find-pigment("blood flowing")

// find pigment match with a partial or complete HEX code
#find-pigment("#d68")
```

<!--
You can also search within a `scope` of pigments to narrow down your results.

```typ
// find orange pigments within Crayola
#find-pigment("orange", scope: Crayola)
```

> [!CAUTION]
> While the option for a "scoped search" is available, you could end up with duplicate pigments in the results which could lead to the search taking an arbitrarily long time to complete, or even not complete at all.
>
> It's recommended to avoid using the `scope` parameter until the bugs are fixed.
>
> **_Apart from this, the search feature_ is _functional._**
-->

## Pigment Groups

### Color standards

- Web/CSS Colors
- PANTONE® Colors
  - Pantone C (Coated)
  - Pantone CP (Coated Process)
  - Pantone U (Uncoated)
  - Pantone UP (Uncoated Process)
  - Pantone XGC (Extended Gamut Coated)
  - Pantone PMS (Pantone Matching System)
- DIC Digital Color Guide®
- Natural Color System®
- RAL Colors
  - RAL Classic
  - RAL Design
  - RAL Effect
- HKS® Colors (Hostmann-Steinberg Druckfarben, Kast & Ehinger Druckfarben and H. Schmincke & Co.)
  - HKS-E (Coated)
  - HKS-K (Coated)
  - HKS-N (Uncoated)
  - HKS-Z (Special)
- ISCC–NBS System of Color Designation
- Nippon Paint Colors

### Other pigments

- Catppuccin [⧉](https://github.com/catppuccin/catppuccin)
- Nord Theme [⧉](https://github.com/nordtheme/nord)
- Crayola Colors
- Chinese Traditional Colors
- Japanese Traditional Colors

## Navigating through pigmentpedia

Below is a flat ASCII tree type representation of the dictionary structure of pigmentpedia.

If a group contains a `"."`, it means that some or all pigments can be accessed at the base level of the pigment group.

Use `show-pigmentpedia-tree()` to view this information within your document.

> CSS contains basic colors and can be used normally by referencing the color name `red`, `chocolate`, `rebeccapurple` etc., without having to reference the group (similar to HTML). However, you can still access it within `view-pigments()`, `find-pigment()` etc.
>
> **This is only for CSS.**
>
> ```typ
> #pigment(firebrick)[This text has CSS firebrick color.]
> ```

### pigmentpedia displayed as ASCII tree

```
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
```

# License

pigmentpedia is licensed under the MIT license.
