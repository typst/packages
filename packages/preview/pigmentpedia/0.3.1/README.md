<p align="center">
  <picture>
    <img src="https://github.com/user-attachments/assets/452d6416-ad69-4e43-81d5-be7e43c1082c" height="64px" alt="pigmentpedia logo">
  </picture>
</p>

<p align="center">An extensive color library for Typst.</p>

## Quick Start

1. Add Pigmentpedia to your project.

   ```typ
   #import "@preview/pigmentpedia:0.3.1": *
   ```

2. Watch your source file (if you're working offline).

   ```
   typst watch file.typ
   ```

3. Find your perfect pigment.

   ```typ
   #find-pigment("") // search by text
   #find-pigment("#") // search by HEX code
   ```

4. Optionally create a variable for your favorite pigment to use in your project/document.

   ```typ
   #let heading-text-color = zhongguo.en.yellow.apricot-red

   = #pigment(heading-text-color)[My Heading]
   ```

### An example document

Pigmentpedia can be used to apply colors elements in your project/document such as `text`, `polygon`, etc.

To get started, I recommend experimenting with this example document to help you understand the capabilities of Pigmentpedia and how to effectively use it within your projects.

View the compiled [example.pdf][example] from the GitHub repository.

<details open>
<summary>View code</summary>

```typ
// An example document to familiarize yourself with Pigmentpedia

#import "@preview/pigmentpedia:0.3.1": *

#set page(background: rotate(-45deg, text(11em, fill: luma(97%))[EXAMPLE]))
#show heading: it => [#v(5mm) #it #v(2mm)]
#set par(justify: true)

/*
  FINDING PIGMENTS BEFORE WRITING THE DOCUMENT
*/

// Uncomment to view Catppuccin Frappe palette
// #view-pigments(catppuccin.frappe)

// Uncomment to search within Crayola for a "burnt" color
// #find-pigment("burnt", scope: crayola)

/*
  VISUAL ELEMENTS
*/

#let cs-o = 100mm; #let cs-g = 200mm; #let cs-b-l = 100mm; #let cs-b-s = 30mm;
#place(dx: -80mm, dy: 40mm, circle(width: cs-o, height: cs-o, fill: zhongguo.en.grey-white.fish-maw-white))
#place(dx: 130mm, dy: -100mm, circle(width: cs-g, height: cs-g, fill: zhongguo.en.grey-white.white-tea))
#place(dx: 50mm, dy: 180mm, circle(width: cs-b-l, height: cs-b-l, fill: zhongguo.en.grey-white.snow-white))
#place(dx: 120mm, dy: 260mm, circle(width: cs-b-s, height: cs-b-s, fill: zhongguo.en.grey-white.crystal-white))

/*
  THE DOCUMENT
*/
= #text(crayola.standard.maximum-red, 2em)[A Journey Through Hope]

== #pigment(crayola.standard.burnt-orange)[A Healthy Diet Starts With You]

#pigment(crayola.standard.orange, lorem(10)) \ \
#pigment(crayola.standard.orange, lorem(90)) \ \
#pigment(crayola.standard.orange, lorem(40))

== #pigment(crayola.standard.maximum-blue)[Enough Sleep For A Lifetime]

#pigment(crayola.standard.cerulean-blue)[
  #lorem(25) \ \
  #lorem(85)
]

== #pigment(crayola.standard.maximum-green)[No Better Time Than The Present]

#pigment(crayola.standard.asparagus, lorem(35))

#align(bottom)[
  #line(length: 100%, stroke: 0.2pt + grey)
  #emph(
    pigment(pantone.c.gray.cool-gray-11)[
      This is a sample document showcasing the use of Pigmentpedia in text application. The pigments in Pigmentpedia are not solely for text; they can be used anywhere you need a more diverse range of color in your documentation.

      Это образец документа, демонстрирующий использование Pigmentpedia в текстовом приложении. Пигменты в Pigmentpedia предназначены не только для текста; их можно использовать везде, где вам нужен более разнообразный диапазон цветов в вашей документации.

      这是一个示例文档，展示了在文本应用程序中使用Pigmentpedia。Pigmentpedia中的颜料不仅仅用于文本；它们可以用在文档中需要更多样化颜色的任何地方。
    ],
  )
]

/*
  PREVIEW COLORS YOU MAY WANT TO CHANGE
*/

// Uncomment to find a nice green color
// the spaces ` ` are converted to hyphens `-` for search
// #find-pigment("70 G20Y") // search within all of pigmentpedia
// this space here ^^^ --> becomes "70-G20Y"

// Uncomment to view a nice green color
// #view-pigments(ncs.s-1070-g20y)

// View pigments on a colored background for comparison
// #view-pigments(zhongguo.en.red.blood-flowing-red, bg: crayola.standard.banana-mania)
```

</details>

## Usage

Pigmentpedia has 3 main functions:

- `pigment()`: Apply a pigment to content. Accepts data of type `color`.
- `find-pigment()`: Search for a specific pigment. Accepts data of type `str`.
- `view-pigments()`: Display an individual pigment or a specified group of pigments. Accepts data of type `dictionary` or `color`.

and 2 auxiliary functions:

- `pigment-playground()`: A sample document to test out pigments on text elements.
- `print-pgmt-tree`: Display a visual "map" of pigment groups in Pigmentpedia.

### Applying pigments to content

1. Pigment text with either the `text()` function, or use the `pigment()` function which is focused on only applying color to content.

   > `pigment()` makes it easier for me to find/select this specific formatting element in search among other `text()` elements. #petpeeve

   ```typ
   #text(dic.cg-vol-2.dic-2001)[This text has a DIC 2001 pigment.]
   // or
   #pigment(ncs.s-0570-y)[This text is has a NCS S-0570-Y pigment.]
   ```

2. As a fill color for other elements.

   ```typ
   #circle(width: 50mm, height: 50mm, fill: ncs.s-0502-b)
   //                                       ^^^^^^^^^^^^
   ```

### Display all pigments from (...) using `view-pigments()`

There are a lot of pigments included in Pigmentpedia and it would be a hassle to remember the exact names or codes of specific pigments. Fortunately, you can do a quick search through the list to view and find pigments that you want to use in your project/document.

<details>
<summary>Tip</summary>

If you're unfamiliar with the standards or pigments here in Pigmentpedia, I recommend [viewing the pigment groups](#navigating-through-pigmentpedia) to discover their names.

</details>

```typ
// show all 20k+ pigments
#view-pigments(pigmentpedia) // directly passing the `pigmentpedia` list to the function

// show all pigments from a specific group
#view-pigments(nord)

// show only a specific subset of pigments from a group
#view-pigments(zhongguo.en.blue) // set of Blue-ish colors from the English subset
```

### View an individual pigment with `view-pigments()`

<details>
<summary>Note (changes made after an unreleased <code>0.2.0</code> update)</summary>

> In the previous _unreleased_ `0.2.0` version of Pigmentpedia, there were two functions for viewing pigments: `view-pigment()` and `view-pigments()` where the former was responsible for only displaying a single pigment (accepting data of type `color`) and the latter was responsible for only displaying pigment groups (accepting data of type `dictionary`).
>
> The close similarity of their names were thought to bring confusion to the users, therefore, in order to provide a better user experience, it was decided that as of version `0.3.1`, `view-pigment()` would be made a private function and integrated within `view-pigments()` allowing for two types of input to the single function (both `color` and `dictionary`).
>
> If you as the user would prefer to have these two separate functions, feel free to provide your feedback or comments on this change.

</details>

To view a single pigment in isolation, use the `view-pigments()` function with the pigment as an argument.

This will display the pigment on its own page, allowing for a focused examination.

```typ
#view-pigments(ral.classic.raspberry-red)
```

You can also use `view-pigments()` to display custom colors.

```typ
#view-pigments(rgb(67, 23, 129)) // RGB color
#view-pigments(luma(24)) // Luma color
#view-pigments(color.hsl(30deg, 50%, 60%)) // HSL color
```

### Search for a specific pigment with `find-pigment()`

Find a pigment you're familiar with, or one even better. You can search with either the partial name or `HEX` code.

#### Search by pigment name

Search is not case-sensitive, but multiple keywords strictly reserves the order of precedence, and they are treated as a single keyword. For example, `find-pigment("foo bar")` will return results for `foo-bar` and `find-pigment("bar foo")` will return results for `bar-foo`.

Currently, `find-pigment()` will not return results for both `foo` and `bar` individually.

```typ
// find a pigment who's name matches `blood-flowing`
#find-pigment("blood flowing")
// returns `zhongguo.en.red.blood-flowing-red`
```

#### Search pigments by `HEX` code

When searching by `HEX` values, the string **must** begin with the hash symbol `#` regardless of which part of the code is being searched. The search results will show all pigments containing that `HEX` fragment at any part of the `HEX` code.

```typ
// find pigment match for the HEX fragment `d68`
#find-pigment("#d68")
```

<details>
<summary>View search result sample</summary>

```
#2D68C4
  ^^^
#006D68
    ^^^
#D68A28
 ^^^
[...]
```

</details>

#### Searching pigments within a `scope`

You can also search within a specific `scope` or subset of pigments to narrow down your results.

```typ
// find all orange-like pigments within Crayola
#find-pigment("orange", scope: crayola)

// find a pigment in `pantone.pms.skintone` matching the partial HEX code
#find-pigment("#887", scope: pantone.pms.skintone)
```

#### Understanding the search results

Search results will include the group name, a breadcrumb trail (visualizing the pigment's group hierarchy), and a list of matching pigments within that group.

Follow the breadcrumbs in dot notation to use the pigments returned from search.

```
ral → classic // `ral.classic`
// matching pigments listed below
// ...
```

View the compiled [example.pdf][example] from the GitHub repository.

### Matching pigments with a background color

You can experiment with pigment appearance on a specific background color. Both the `find-pigment()` and `view-pigments()` functions accept a `bg` parameter to specify the background color for the pages.

```typ
// find a good pigment from the group to match the background
#find-pigment("purple", scope: iscc-nbs, bg: ral.design._300-20-10)
// compare other pigments from the group to match the background
#view-pigments(iscc-nbs, bg: ral.design._300-20-10)
// view a single pigment to feel the contrast
#view-pigments(iscc-nbs.brilliant-purple, bg: ral.design._300-20-10)
```

### Try out pigments with `pigment-playground()`

Prepare a sample document to serve as a "playground" or "creative space" for experimenting with color variations. The color of the background and text elements within this document can be changed dynamically to explore the visual impact of different pigments.

Parameters for the sample document:

- `bg`: Background color of the page.
- `default-text-color`: Apply one color to all text.
- `title`: Color of the title text.
- `section-1`: Color of the first section of text. Will affect both heading and text of section 1.
- `section-1-heading`: Color of the header of the first section of text.
- `section-1-text`: Color of the text in the first section.
- `section-2`: Color of the second section of text. Will affect both heading and text of section 2.
- `section-2-heading`: Color of the header of the second section of text.
- `section-2-text`: Color of the text in the second section.
- `section-3`: Color of the third section of text. Will affect both heading and text of section 3.
- `section-3-heading`: Color of the header of the third section of text.
- `section-3-text`: Color of the text in the third section.
- `footer-text`: Color of the footer text.

```typ
// example usage
#pigment-playground(
  default-text-color: catppuccin.latte.text,
  title: catppuccin.latte.red,
  section-1-heading: catppuccin.latte.green,
  section-2-heading: catppuccin.latte.sapphire,
  section-3-heading: catppuccin.latte.maroon,
  footer-text: catppuccin.latte.subtext-1,
  bg: catppuccin.latte.base
)
```

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
- Natural Colour System®
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

### Theme palettes

- Catppuccin [⧉](https://github.com/catppuccin/catppuccin)
- Nord [⧉](https://github.com/nordtheme/nord)

### Other pigments

- Crayola Colors
- Chinese Traditional Colors
- Japanese Traditional Colors

## Navigating through pigmentpedia

Below is a flat ASCII tree representation of the structure of Pigmentpedia.

If a group contains a `"."`, it means that some or all pigments can be accessed at the base level of the pigment group.

Use `print-pgmt-tree` to view this information within your project/document.

> CSS contains basic colors and can be used normally by referencing the color names such as `red`, `chocolate`, `rebeccapurple` etc., without having to reference the group (similar to HTML). However, you can still use the `CSS` list within `find-pigment()` and `view-pigments()` as a `scope` argument, and if necessary, use dot notation to access its pigments, e.g. `CSS.red`.
>
> **This is only for CSS.**
>
> ```typ
> #pigment(firebrick)[This text has CSS firebrick color.]
> ```

<details>
<summary>View Pigmentpedia ASCII tree</summary>

```
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
```

</details>

# License

Pigmentpedia is licensed under the MIT license.

<p align="center">
  <br><picture>
    <img src="https://github.com/user-attachments/assets/762ff844-67d1-4c13-b45a-557e179c2adb" height="24px" alt="pigmentpedia icon">
  </picture>
</p>

[example]: https://github.com/neuralpain/pigmentpedia/blob/main/0.3.1/examples/example.pdf
