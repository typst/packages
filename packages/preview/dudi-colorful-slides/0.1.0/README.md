# 🎨 dudi-colorful-slides

A vibrant, modern presentation template for **Typst** featuring dynamic geometric triangle patterns and a clean two-column layout.

---

## ✨ Features

* **Impactful Title Slide:** Full-page interactive triangle grid background.
* **Structured Content:** Two-column slides with elegant header and footer triangle borders.
* **Fully Customizable:** Easily tweak colors, font sizes, and column ratios to match your branding.
* **Perfect Format:** Built natively for 16:9 widescreen presentations.

---

## 🚀 Installation & Setup

Follow these **three simple steps** to integrate the template into your Typst project:

1️⃣ **Import** the template at the very top of your `.typ` file:
```typst
#import "@preview/dudi-colorful-slides:0.1.0": *
```
2️⃣ **Configure** the page and document text settings:
```typst
#set page(
  paper: "presentation-16-9",
  margin: 0cm
)
#set text(
  font: "Helvetica"
)
```
## 💻 Quick Start Example (example.typ)
Here is a complete, ready-to-run example to kickstart your presentation:
```typst
#import "@preview/dudi-colorful-slides:0.1.0": *

#set page(
  paper: "presentation-16-9",
  margin: 0cm
)
#set text(
  font: "Helvetica",
  size: 24pt
)

// Define your custom brand colors
#let my-color1 = rgb("#1a5276")
#let my-color2 = rgb("#2ecc71")

// 1. Title Slide
#title-slide([Генерация синтетических данных], 42pt, [Иванов Иван], [АС-24-05], color1: my-color1, color2: my-color2)

// 2. Content Slide
#slide([Постановка задачи], [Левый столбец], [Правый столбец], color1: my-color1, color2: my-color2)

// 3. Final Slide (Inverted Pattern)
#slide([Заключение], [Итоги], [Выводы], color1: my-color1, color2: my-color2, is-last: true)
```
## 🛠️ API Reference
### 🖼️ title-slide(...)
Creates a striking title slide with a full-bleed triangle grid background and a centered title card.
Parameter	|Type	|Default	|Description
--- | --- | --- | ---
title	|content	|Required	|Presentation title
title-size	|length	|Required	|Font size for the main title
author1	|content|	Required|	Left-aligned author name / credentials
author2	|content|	Required|	Right-aligned group ID / institution
n	|int|	6|	Grid density (number of columns/rows)
### 📊 slide(...)
Creates a standard two-column content slide framed by triangle header and footer borders.
Parameter|Type|Default|Description
--- | --- | --- | ---
title|content|Required|Slide title
column1|content|Required|Left column content
column2|content|Required|Right column content
text-color|color|black|Title and body text color
ratio1|float|0.5|Triangle pattern ratio 1
ratio2|float|0.5|Triangle pattern ratio 2
title-size|length|42pt|Title font size
text-size|length|24pt|Body text font size
is-last|bool|false|Set to true on the last slide to invert background

⚠️ Important: For the border pattern to render correctly, ensure that your ratios satisfy:
```ratio1 + ratio2 == 1```
### 🧩 Core Utilities (Internal)
- regular-pattern(color1, color2, n, small-part, big-part, h) Generates a horizontal band of alternating colored triangles used for header/footer borders.
- triangle-grid(color1, color2, n) Generates the full-page checkerboard triangle pattern used for the title slide background.
