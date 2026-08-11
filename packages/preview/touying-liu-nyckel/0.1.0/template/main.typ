#import "@preview/touying-liu-nyckel:0.1.0": *
#import "@preview/touying:0.7.4": utils.fit-to-height

#show: liu-theme.with(
  title: [Template for LiU-Themed Slides],
  author: [First Last (first.last\@liu.se)\
    Department of Electrical Engineering\
    Linköping University\
    Sweden],
  // progress-bar: false, // Don't progress bar at sectioning slides
  // handout: true, // Flatten dynamic content for handouts
  // lang: "sv",
  // title-background: none,  // Use a theme colored background
  // title-background: image("../assets/backgrounds/background_11.jpg"), // 01-13 available
  // size: 19pt,
  config-colors(theme: liu-colors.darkblue, primary: liu-colors.darkblue), // if you prefer another color scheme
)

#title-slide()

== Features

- Template for the excellent #link("https://typst.app/universe/package/touying/", "Touying") package for creating presentation slides in Typst. See #link("https://touying-typ.github.io/docs/intro", "Touying documentation") for full functionality, including dynamic content generation.
- Template mirrors the look and feel of the official Linköping University (LiU) slides provided by the Keynote template.
- Uses free fonts, defaults to Liberation Serif (pre-installed) and Liberation Sans that can be downloaded and installed on your system.
- Include options for configuring using other fonts.
- Supports Swedish and English languages.
- See https://typst.app for more details on Typst.

= Basic Usage

== Section Slides
The previous slide was generated as a first level heading.

#text-block(
  "How to create a section slide",
  [
    ```typst
    = Basic Usage
    ```
  ],
)
It is possible to add content also to the section slide by adding content directly after the heading.
```typst
= Basic Usage
Additional content on the section slide
```

== Basic Slides
Basic slides are easily created as a second level heading with content.
#text-block(
  "How to create a basic slide",
  [
    ```typst
    == Basic Slides

    - This is a bullet point
    - And this is another
      $
        sin(x) = sum_(n=0)^infinity (-1)^n / (2 n )! x^(2n)
      $
    ```
  ],
)

== Initializing the template
First, import the template // (not yet published to the Typst universe, so use a relative path)
```typst
#import "@preview/touying-liu-nyckel:0.1.0": *
```
then initialize the template with the `liu-theme` function, setting up the title page
```typst
#show: liu-theme.with(
  title: "Presentation Title",
  author: [
    Firstname Lastname (first.last\@liu.se)\
    Department of XYZ\
    Linköping University
  ])
```

== Template options
The full list of options with their default values are
```typst
  title: "A Title",  // Main title
  subtitle: none,  // Subtitle below main title
  author: "An Author",  // Author
  lang: "en",  // Language, "en" or "sv"
  handout: false,  // If true, dynamic content is flattened for handouts
  title-font: ("Liberation Sans", "Libertinus Sans", "Helvetica"),
  body-font: ("Liberation Sans", "Libertinus Sans", "Helvetica"),
  header-font: ("Liberation Serif", "Libertinus Serif", "Georgia"),
  math-font: "New Computer Modern Math",
  title-background: image("assets/backgrounds/background_01.jpg"),
  progress-bar: true,  // If true, progress bar is shown at section slides
  size: 20pt,  // Base font size
```

== Color Themes
#grid(
  columns: (1fr, 1fr),
  fit-to-height(100%, prescale-width: 1100%, [
    Colors from the LiU graphical profile is predefined\
    #box(fill: liu-colors.blue, width: 1.5cm, height: 1.5cm)
    #box(fill: liu-colors.turquoise, width: 1.5cm, height: 1.5cm)
    #box(fill: liu-colors.green, width: 1.5cm, height: 1.5cm)
    #box(fill: liu-colors.orange, width: 1.5cm, height: 1.5cm)
    #box(fill: liu-colors.purple, width: 1.5cm, height: 1.5cm)
    #box(fill: liu-colors.yellow, width: 1.5cm, height: 1.5cm)
    #box(fill: liu-colors.gray, width: 1.5cm, height: 1.5cm)
    #box(fill: liu-colors.darkblue, width: 1.5cm, height: 1.5cm)
    ```typst
    #let liu-colors = (
      "blue": rgb("#00b9e7"),
      "turquoise": rgb("#17c7d2"),
      "green": rgb("#00cfb5"),
      "orange": rgb("#ff6442"),
      "purple": rgb("#8981d3"),
      "yellow": rgb("#fdef5d"),
      "gray": rgb("#6a7e91"),
      "darkblue": rgb(0, 153, 199),
    )
    ```
    Change the color scheme in the template, e.g.,
    ```typst
    config-colors(theme: liu-colors.green,
                  primary: liu-colors.gray)
    ```
  ]),
  [
    #align(center, text(size: 25pt, "Color options"))
    - The two main color options are `theme` and `primary`
    - `theme` sets the main color scheme, used for example for the title page and sectioning slide backgrounds
    - `primary` is used for example for *bold* text and headings in `text-block`
    #text-block("A text block", [With some text])
  ],
)

== Template Fonts
- The template, by default, uses Liberation Serif and Liberation Sans fonts
- All fonts are directly available on https://typst.app
- If you run Typst locally, Liberation Serif is pre-installed obut Liberation Sans need to be separately installed.
- You can easily configure the template with other fonts, for example #link("https://fonts.google.com/specimen/Lora", "Lora") and #link("https://fonts.google.com/specimen/Outfit", "Outfit") makes a nice pair (both freely available on https://fonts.google.com):
  ```typst
    header-font: "Lora"
    body-font: "Outfit"

  ```
- If you runTypst locally, see https://github.com/typst/typst, then there is an excellent extension #link("https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist", "TinyMist") for #link("https://code.visualstudio.com", "Visual Studio Code") usable under MacOS, Windows, and Linux.

== Font installation instructions
+ The Liberation fonts can be downloaded from https://github.com/liberationfonts/liberation-fonts
+ Go to the #link("https://github.com/liberationfonts/liberation-fonts/releases/tag/2.1.5", "Releases") page and download the latest version, currently `liberation-fonts-ttf-2.1.5.tar.gz`, and extract.
+ Locate the TTF files in the extracted folder and install them on your system
  - *MacOS* -- Locate the TTF-files in Finder, select them all, right-click and select open in FontBook. Then click "_Install Font_".
  - *Windows* -- Locate the TTF-files in File Explorer, select them all, and right-click and select "_Install_".
  - *Linux/Ubuntu*: Copy the TTF-files to `~/.local/share/fonts/`  and run \
    `fc-cache -fv` in the terminal to update the font cache.


== Utililty functions
#align(horizon, text-block("Available utility functions", [
  - `title-slide` - create the title page as defined in the template
  - `footer-comment` - Puts a comment, e.g., a literature reference, in the footer
  - `text-box` - A simple boxed expression
  - `text-block` - A box like this one with a heading. Similar to the beamer environment `block`
  - `end-slide` - A simple end-of-slides page
]))

= Example slides
A few slides with examples on how to make slides and use the utility functions

== Slide with columns - the grid command
#grid(
  columns: (1fr, 2fr),
  rect(width: 100%, height: 100%, fill: aqua), rect(width: 100%, height: 100%, fill: aqua),
)
#footer-comment(alignment: right, "This is a footer comment, can be aligned left, center, and right", size: 20pt)

== Another way to do slides with columns
#slide(composer: (2fr, 1fr))[
  #rect(width: 100%, height: 100%, fill: aqua)
][
  #rect(width: 100%, height: 100%, fill: aqua)
]

== Slide with bulllets and an image
#grid(
  columns: (1fr, 1fr),
  gutter: 10mm,
  [
    - The famous blue marble photo from NASA (Public Domain)
    - Photograph of Earth taken on December 7, 1972
  ],
  image("blue_marble.jpg"),
)
#footer-comment([https://en.wikipedia.org/wiki/The_Blue_Marble], size: 18pt)

== Slide that needs vertical scaling to fit (alt. 1)

#fit-to-height(98%, [
  - Utilize the touying-utility function `fit-to-height` to scale the content to fit the full slide height
    ```typst
    #fit-to-height(100%, [slide content to be scaled])

    ```
    You may also want to use the argument `prescale-width` to get the result you want.
  - Requires
    ```typst
    #import "@preview/touying:0.7.4": utils.fit-to-height
    ```
    See documentation on https://touying-typ.github.io/docs/utilities/fit-to for more details.
  - Expressions for $sin(x)$
    $
      sin(x) = x product_(n=1)^infinity (1 - x^2 / (n^2 pi^2))
      = sum_(n=0)^infinity (-1)^n / (2 n + 1)! x^(2n + 1)
    $
  - A bullet point
])

== Slide that needs vertical scaling to fit (alt. 2)

#[
  #set text(size: 20pt)
  - Alternatively, just change the text size for the particular slide. But make sure to scope it so that you only change the font size for the specific slide
    ```typst
    #[ // start a scope
      #set text(size: 18pt)
      // slide content
    ]
    ```
  - Expressions for $sin(x)$
    $
      sin(x) = x product_(n=1)^infinity (1 - x^2 / (n^2 pi^2))
      = sum_(n=0)^infinity (-1)^n / (2 n + 1)! x^(2n + 1)
    $
  - A bullet point
  - A bullet point
]


== Dynamic slides
#grid(
  columns: (1fr, 1fr),
  [
    - With `#pause`, `#only`, `#uncover`, and `#meanwhile` you can add dynamic  to your slides
    #pause
    - See https://touying-typ.github.io/docs/intro/ for documentation.
    #pause
    - set the `handout` option to the template to #text(fill: red, `true`) to remove the dynamic content in the PDF, e.g., for distributing slide printouts.
  ],
  [
    - This is also possible in math formulas
      $
        sin(x) & = pause x product_(n=1)^infinity (1 - x^2 / (n^2 pi^2)) \
               & pause = sum_(n=0)^infinity (-1)^n / (2 n + 1)! x^(2n + 1)
      $
  ],
)
#v(1fr)
#meanwhile
Some text
#pause
comes later#pause, some later#pause, and some comes last
#pause
#pause
#place(bottom + right, dx: 0mm, dy: -5mm, box(
  stroke: 0pt,
  width: 8cm,
  height: 5cm,
  fill: liu-colors.blue,
  radius: 5mm,
  [
    #set align(center + horizon)
    #set text(fill: white, size: 25pt)
    Final step in animation!
  ],
))

#v(1fr)

== Random Placement of Images
- Any content, e.g., image or text can be randomly \
  placed using the `place` function.\
  #box(width: 63%, [
    ```typst
    #place(top + right, dx: 0mm, dy: 0mm,
        image("blue_marble.jpg", height: 72%))
    ```])
- Details on arguments for the function on\
  https://typst.app/docs/reference/layout/place/
- For example, you can wrap text around the image
- #lorem(8)
- #lorem(12)
- #lorem(24)

#place(top + right, dx: 0mm, dy: -5mm, image("blue_marble.jpg", height: 72%))

#title-slide(extra: place(bottom + right, dy: 13mm, [Title slide with some extra text]))

#end-slide("liu.se")
