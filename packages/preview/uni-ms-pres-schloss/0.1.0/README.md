# uni-ms-pres-schloss
*Unofficial* Typst + Polylux presentation template in the style of the University of Münster Corporate Design (Schloss Blue).
The template aims to be visually close to the official style while intentionally not being an official university template.
This package has been based on the [modern-ovgu-fma-polylux](https://typst.app/universe/package/modern-ovgu-fma-polylux) package by Jonas Danker

## License & Usage Restrictions
This project consists of distinct licensing parts covering the underlying code, the background images, and the visual corporate design. Please read carefully before using.

### 1. The Code (MIT License)
The underlying Typst code structure of this template is open-source. 
It is an adaptation of [original work](https://github.com/tibirius24/modern-ovgu-fma-polylux/tree/master) by Jonas Danker. 
The code itself is freely available under the [MIT License](LICENSE).

### 2. Background Images (MIT License)
To ensure this package remains highly accessible and conforms with open-source package requirements, the proprietary background images from the original university template have been replaced with copyright-free images of the Münster Schloss (`Schloss_Left.jpeg` and `Schloss_Right.jpeg` located in the `assets/` directory).

These specific images are explicitly included under the permissive [MIT License](LICENSE) mentioned above and are completely free to use, copy, and distribute.

### 3. Corporate Design & Logos (STRICTLY RESTRICTED)
** Important:** The visual output of this template—including the layout, color schemes, line placements, typography choices, and all SVG logo files in the `assets/` directory—constitute the **[Corporate Design](https://www.uni-muenster.de/die-universitaet/mystudy/en/cd-vorlagen.html) and Trademarks of the University of Münster**.

According to the university's usage guidelines:
* These specific design elements may **ONLY** be used within the scope of studies and university projects (*"in the context of studies and university projects"*).
* The Corporate Design and institutional logos are strictly **excluded** from the MIT License.
* You may not use the visual output of this template for commercial purposes or non-university projects, nor may you distribute these restricted assets under an open-source license.

## Quick Start
Initialize a project from Typst Universe:

```bash
typst init @preview/uni-ms-pres-schloss:0.1.0
```

Or import the package directly:

```typ
#import "@preview/uni-ms-pres-schloss:0.1.0": *

#show: pres-theme.with(
  author: [Firstname Lastname],
  title: [Presentation Title],
  date: ez-today.today(lang: "en"),
  text-lang: "en",
)

#title-slide(subtitle: [A possible subtitle])
```

Polylux documentation: <https://polylux.dev/book/>

## Theme Parameters

`pres-theme` supports these parameters:

```typ
#show: pres-theme.with(
  text-font: "Carlito",
  text-lang: "en", // "en" and "de" are currently supported in defaults
  text-size: 20pt,
  code-font: "JetBrains Mono",
  author: [],
  title: [],
  date: [],
  progressbar: true,
)
```

`author`, `title`, and `date` are reused in the page header/footer and on `#title-slide` unless explicitly overridden there.

## Fonts

For the closest visual match to the university style, use text font Carlito (<https://fonts.google.com/specimen/Carlito>)

The default code font is set as JetBrains Mono (<https://fonts.google.com/specimen/JetBrains+Mono>) but only due to personal liking.

The theme includes fallback fonts, so it still compiles when those fonts are unavailable.
In the web version you can simply copy the `.ttf` files into the project and they should be recognized automaticly.
For further help or to setup the fonts with a local compiler, please see the [typst font parameter documentation](https://typst.app/docs/reference/text/text/#parameters-font:~:text=In%20addition%2C%20you%20can%20use%20the%20%2D%2Dfont%2Dpath%20argument%20or%20TYPST_FONT_PATHS%20environment%20variable%20to%20add%20directories%20that%20should%20be%20scanned%20for%20fonts.%20The%20priority%20is%3A%20%2D%2Dfont%2Dpaths%20%3E%20system%20fonts%20%3E%20embedded%20fonts.%20Run%20typst%20fonts%20to%20see%20the%20fonts%20that%20Typst%20has%20discovered%20on%20your%20system.).
Local setups might need different configurations.

If these fonts are not to your liking you can easily replace them when calling
```typ
pres-theme(
  ...
  text-font: "Carlito",
  code-font: "JetBrains Mono",
  ...
)
```

## Slide Types

### Title Slide

![Presentation title slide for the University of Münster (Universität Münster). The background features a blue-tinted architectural photograph of the Prince Bishop's Palace in Münster. Text placeholders include "Presentation Title" in a large bold font, "Your Name," "23. April 2026," and "a possible subtitle." The university logo is in the top left corner, and the slogan "living.knowledge" is in the bottom left.](./thumbnail.png)

```typ
#title-slide(
  author: none,
  date: none,
  title: none,
  subtitle: none,
  max-width: 90%,
)
```

If `author`, `date`, or `title` stay `none`, values from `pres-theme` are used.

### Standard Slide

```typ
#slide(
  heading: none,
  show-section: true,
  block-height: none,
)[
  // content
]
```

- `heading`: slide title content.
- `show-section`: kept for API compatibility.
- `block-height`: main content area height (useful when footnotes are present).

### Outline Slide

![Presentation outline slide for the University of Münster. The slide features a numbered list: 1. Header slide, 2. Some examples of content, 3. Useful features and hints, 4. Bibliography. The university logo is top-left, "Presentation Title" is top-right, and a footer includes "Your Name" and the slide number "1 / 14."](./slide-images/outline-slide.png)

```typ
#outline-slide(
  heading: none,
  multipage: false,
  items-per-page: 8,
)
```

Uses a language-aware default heading (`Outline` / `Gliederung`) if `heading` is `none`.

If multipage is set to true, the automatically breaks page when items-per-page items are reached.
Otherwise, the text is scaled dynamically. 

### Header Slide

![Section header slide for the University of Münster. The background is a blue-tinted image of the Prince Bishop's Palace. Central text reads "Header slide" above a horizontal line and "Presentation Title." The university logo is top-left, with "Your Name" and "2/14" in the footer.](./slide-images/header-slide.png)

`#header-slide` registers the section for the outline automatically.
If you want to create a new section without it, use:
```typ
#toolbox.register-section(head)
```

## Content Examples

### Basic Slide

![Basic content slide for the University of Münster. The slide is titled "Basic Slide" and contains a paragraph of placeholder Latin text (Lorem ipsum). The university logo is top-left, "Header slide" is top-right, and the footer shows "Your Name" with slide number "3 / 14."](./slide-images/basic-slide.png)

```typ
#slide(heading: [Basic Slide])[
  #lorem(84)
]
```

### Multi-Column Layout

![Multi-column content slide for the University of Münster titled "Multi-Column-slide." It features three columns of placeholder Latin text (Lorem ipsum). The university logo is top-left, the section title "Some examples of content" is top-right, and the footer contains "Your Name" and slide number "8 / 14."](./slide-images/multi-column-slide.png)

```typ
#slide(heading: [Multi-column Slide])[
  #toolbox.side-by-side()[#lorem(42)][#lorem(27)][#lorem(35)]
]
```

### Code Slide
![Presentation slide titled "Code" for the University of Münster. It displays a code block with syntax highlighting and line numbers containing a mix of Python and non-standard syntax. The slide includes the university logo, the section title "Some examples of content," and the footer "Your Name" with slide number "5 / 14."](./slide-images/code-slide.png)

````typ
#slide(heading: [Code])[
  ```py
  import torch

  if (torch.cuda.is_available()):
  {
    print("cuda is there wohoo!")
  }
  break; # Oh no Java! // lelolalu

  variable = variable * 100.000 +- >< | && 

  ```
]
````


### Equations

![Slide titled "How to use equations" for the University of Münster. It demonstrates inline math $a + b \neq c$ and a centered, numbered equation $a^2 + b^2 = c^2$ (1). The text mentions that "eq. (1) references Pythagoras' theorem" with a citation to "1". Standard university branding and footer "7 / 14" are included.](./slide-images/math-slide.png)

```typ
#show: document => conf-equations(document)

#slide(heading: [How to use equations])[
  You can define equations like this: $a + b != c$.
  Only labeled equations are numbered:
  $a^2 + b^2 = c^2$ <pythagoras>
  The @pythagoras reference points to this equation.
]
```

### Image + Footnote

![Presentation slide for the University of Münster demonstrating how to combine images and footnotes. A central graphic shows a computer monitor icon with a line chart on the screen, captioned "Figure 1: Example image." A footnote at the bottom credits the image source. Standard university branding and footer "9 / 14" are present.](./slide-images/image-slide.png)

```typ
#slide(block-height: 85%)[
  #figure(
    caption: [Example image#footnote([Thanks to #link("https://www.svgrepo.com/") for the inspiration and Florian Bohlken for this remade image])],
  )[
    #image("example-image.svg", height: 70%)
  ]
]
```

### Bibliography Slide

![Bibliography slide for the University of Münster titled "Bibliography." It lists one reference: "1: M. Gerwig, Der Satz des Pythagoras in 365 Beweisen. Berlin: Springer Spektrum, 2021" with a linked DOI. The university logo is top-left, the section title "Bibliography" is top-right, and the footer shows "Your Name" and "14 / 14."](./slide-images/bibliography-slide.png)

```typ
#header-slide()[Bibliography]

#counter("logical-slide").step()
= Bibliography

#bibliography(
  "example.bib",
  style: "ieee",
)
```

## Useful Commands

- Reveal content step by step: `#show: later`
- Disable animations for handouts: `#enable-handout-mode(true)`
- Find symbol commands by drawing them: <https://detypify.quarticcat.com/>
