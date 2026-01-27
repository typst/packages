# buaa-unofficial-gradient
[中文文档](./README_zh.md)

[English Document](./README.md)

---

A BUAA [typst](https://github.com/typst/typst) template developed based on [touying](https://github.com/touying-typ/touying).

![Example-Title](https://github.com/user-attachments/assets/677171e2-439d-4065-9c4c-b14aa1def913)

| Outline                                                                                                  | Section                                                                                                        |
| :------------------------------------------------------------------------------------------------------: | :------------------------------------------------------------------------------------------------------------: |
| ![Example-Outline](https://github.com/user-attachments/assets/ae07e1a7-162e-455c-a091-433d953dd23a)      | ![Example-Section](https://github.com/user-attachments/assets/02c3759d-5c76-424b-b3ff-80d74be366cc)          |

| Content                                                                                                  | End                                                                                                          |
| :------------------------------------------------------------------------------------------------------: | :----------------------------------------------------------------------------------------------------------: |
| ![Example-Slide](https://github.com/user-attachments/assets/3f7ef484-cf92-4244-892d-7e0304e82f0d)        | ![Example-End](https://github.com/user-attachments/assets/84bdfe48-40b7-4c9c-ae72-d53ed45c51f2)              |

## Introduction
This project aims to provide BUAAers with an easy-to-use and beautiful slide template.

## Features
**Beautiful & Concise:** 
- Uses gradients, the university logo, and blocks to keep the page content from being too monotonous and flat.
- More elements are added only at the cover, outline, and section transitions. Content pages are kept as simple as possible to avoid interfering with content output.
- Integrates some handy typesetting [Utilities](#utilities).

**BUAA Visual Identity:**
- Incorporates BUAA university logo elements into the page layout.
- The color scheme of this template comes from [BUAA Color Specifications](https://xcb.buaa.edu.cn/info/1091/2057.htm), specific colors are as follows:
```typst
#let buaa-blue = rgb(0, 61, 166)
#let sky-blue = rgb(0, 155, 222)
#let chinese-red = rgb(195, 13, 35)
#let quality-grey = rgb(135, 135, 135)
#let pro-gold = rgb(210, 160, 95)
#let pro-silver = rgb(209, 211, 211)
```

## Quick Start
Create a typst file and import the template at the beginning of the file using `#import "@preview/buaa-unofficial-gradient:0.1.0": *`. Use `#show: buaa-theme.with()` to set basic information and initialize the slides.
```typst
#import "@preview/buaa-unofficial-gradient:0.1.0": *

#show: buaa-theme.with(
  config-info(
    title: [Buaa in Touying: Customize Your Slide Title Here],
    subtitle: [Customize Your Slide Subtitle Here],
    author: [Authors],
    date: datetime.today(),
    institution: [Institution],
  ),
)


#title-slide()

#outline-slide()

= Section 1

== Slide 1


#end-slide()
```

## Utilities
Some utilities have been developed based on needs.

### Color Text Block
Color text blocks based on BUAA color scheme.

Example:
```typst
== Section 2.1
#lorem(20)
#tblock(title: [Title])[#lorem(20)]
#rblock(title: [Title])[#lorem(20)]

== Section 2.2
#lorem(20)
#gblock(title: [Title])[#lorem(20)]
#sblock(title: [Title])[#lorem(20)]
```
![Color-Block](https://github.com/user-attachments/assets/976b71d6-0e28-45d7-a145-6b61c14ae3d4)

### Article Info Page
Based on literature reporting needs, `#article-title()` can quickly create a page displaying article information.

Example:
```typst
== Article title

#let example-article-fig = block(
  stroke: 1pt,
  height: 100%,
  width: 50%,
  [Article Figure],
)

#article-title(
  article-fig: example-article-fig,
  journal: [Science],
  impf: [45.8],
  pub-date: [20XX-XX-XX],
  quartile: [CAS Q1 General Journal],
  core-research: [#lorem(10)],
  authors: [#lorem(10)],
  institution: [#lorem(10)],
)
```
![Article-Title](https://github.com/user-attachments/assets/787cfe20-e906-48ac-b359-fae9f05d0645)

### Content Side-by-Side
`#horz-block()` will automatically wrap the passed content blocks (`#horz-block()[Content 1][Content 2]`) in wireframes and display them side by side in the slide.

Example:
```typst
== Section 3.1
#lorem(10)
#horz-block()[
  #image("./figures/bar_chart.svg")
  #lorem(10)
][
  #image("./figures/heatmap_field.svg")
  #lorem(10)
][
  #image("./figures/line_comparison.svg")
  #lorem(10)
]

== Section 3.1
#lorem(20)
#horz-block()[
  #image("./figures/bar_chart.svg")
  #lorem(10)
][
  #image("./figures/bar_chart.svg")
  #lorem(10)
][
  #image("./figures/bar_chart.svg")
  #lorem(10)
][
  #image("./figures/bar_chart.svg")
  #lorem(10)
]
```

![Horz-Block](https://github.com/user-attachments/assets/aed200e7-5f9b-4708-8014-514b20d445e8)

## License
The code of this project is licensed under the GPL-3.0 License. See the [LICENSE](./LICENSE) file for details.
The Beihang University (BUAA) logo and visual identity assets included in this repository are NOT covered by the open-source license. They belong to Beihang University and are strictly for demonstration or non-commercial academic use only.

## Acknowledgements
- This template is implemented based on [typst](https://github.com/typst/typst) and [touying](https://github.com/touying-typ/touying).
- This template references [sdu-touying-simpl](https://github.com/Dregen-Yor/sdu-touying-simpl) and [diatypst](https://github.com/skriptum/diatypst).
