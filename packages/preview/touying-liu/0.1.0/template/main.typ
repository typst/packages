#import "@preview/touying-liu:0.1.0": *
#import "@preview/touying:0.6.1": utils.fit-to-height

#let liu-darkblue = rgb(0, 153, 199)
#let liu-green = rgb(0, 207, 181)
#let primary-blue = rgb(46, 82, 118)

#show: liu-theme.with(
  title: [Template for LiU-Themed Slides],
  author: [First Last (first.last\@liu.se)\
    Department of Electrical Engineering\
    Linköping University\
    Sweden],
  // progress-bar: false, // Don't progress bar at sectioning slides
  // handout: true,
  // lang: "sv",
  // title-background: none,  // Use a blue background
  // title-background: "assets/backgrounds/background_11.jpg",  // 01-13 available
  title-background: "assets/backgrounds/background_01.jpg", // 01-13 available
  // size: 19pt,
  config-colors(primary: primary-blue, theme-color: liu-darkblue), // if you prefer another color scheme
)

#title-slide()

== Features

- Template for the excellent #link("https://typst.app/universe/package/touying/", "Touying") package for creating presentation slides in Typst. See #link("https://touying-typ.github.io/docs/intro", "Touying documentation") for full functionality, including dynamic content generation.
- Template that mirrors the look and feel of the official Linköping University (LiU) slides provided by the Keynote template.
- Uses free fonts, defaults to Liberation Serif (pre-installed) and Liberation Sans that can be downloaded and installed on your system.
- Include options for configuring if you want to use any font.
- Supports Swedish and English languages.
- See https://typst.app for more details on Typst.
- The package comes with one beckground image pre-installed, additional backgrounds can be downloaded from the #link("https://gitlab.liu.se/erifr93/touying-liu/-/tree/master/assets/backgrounds", "package repo") and added to the template by setting the `title-background` option.

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
Basic slides are easily created as a second level heading with content directly following.
#text-block(
  "How to create a basic slide",
  [
    ```typst
    = Basic Usage

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
#import "@preview/liu-slides:0.1.0": *
```
then initialize the template with the `liu-slides` function, setting up the title page
```typst
#show: liu-slides.with(
  title: "Presentation Title",
  author: [
    Firstname Lastname (first.last\@liu.se)\
    Department of XYZ\
    Linköping University],
```

== Template options
#fit-to-height(100%, prescale-width: 122%, [
  The full list of options with their default values are
  ```typst
    title: "A Title",  // Main title
    subtitle: none,  // Subtitle below main title
    author: "An Author",  // Author
    lang: "en",  // Language, "en" or "sv"
    handout: false,  // If true, dynamic content is removed for handouts
    title-font: ("Liberation Sans", "Libertinus Sans", "Helvetica"),
    header-font: ("Liberation Sans", "Libertinus Sans", "Helvetica"),
    body-font: ("Liberation Serif", "Libertinus Serif", "Georgia"),
    math-font: "New Computer Modern Math",
    title-background: "assets/backgrounds/background_01.jpg", // Backgrounds for title page
    progress-bar: true,  // If true, progress bar is shown at section slides
    size: 21pt,  // Base font size
  ```
  If you want to change the color scheme, you can set the primary and theme colors by:
  ```typst
    config-colors(primary: blue, theme-color: green)
  ```
])

== Template Fonts
- The template, by default, uses Liberation Serif and Liberation Sans fonts
- All fonts are directly available on https://typst.app and if you run typst locally, Liberation Sans need to be separately installed.
- Liberation Serif is pre-installed on all Typst installations.
- If you install typst locally, see https://github.com/typst/typst, then there is an excellent extension #link("https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist", "TinyMist") for #link("https://code.visualstudio.com", "Visual Studio Code") usable under MacOS, Windows, and Linux.

== Font installation instructions
+ The Liberation fonts can be downloaded from https://github.com/liberationfonts/liberation-fonts
+ Go to the #link("https://github.com/liberationfonts/liberation-fonts/releases/tag/2.1.5", "Releases") page and download the latest version, currently liberation-fonts-ttf-2.1.5.tar.gz, and extract.
+ Locate the TTF files in the extracted folder and install them on your system
  - *MacOS* -- Locate the TTF-files in Finder, select them all, right-click and select open in FontBook. Then click "_Install Font_".
  - *Windows* -- Locate the TTF-files in File Explorer, select them all, and right-click and select "_Install_".
  - *Linux*: Copy the TTF-files to `~/.local/share/fonts/`  and run `fc-cache -fv` in the terminal to update the font cache.


== Utililty functions
#align(horizon, text-block("Available utility functions", [
  - `title-slide` - create the title page as defined in the template
  - `footer-comment` - Puts a comment, e.g., a literature reference in the footer
  - `text-box` - A simple boxed expression
  - `text-block` - A box like this one with a heading. Similar to the beamer `block`
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

== Slide with bulllets and image
#grid(
  columns: (1fr, 1fr),
  gutter: 10mm,
  [
    - The famous blue marble photo from NASA
    - Photograph of Earth taken on December 7, 1972
  ],
  image("blue_marble.jpg"),
)
#footer-comment([https://en.wikipedia.org/wiki/The_Blue_Marble], size: 20pt)

== Slide that needs vertical scaling to fit (alt. 1)

#fit-to-height(100%, [
  - Utilize the touying-utility function `fit-to-height` to scale the content to fit the full slide height
    ```typst
    #fit-to-height(100%, [slide content to be scaled])

    ```
    You may also wan't to use the argument `prescale-width` to get the result you want.
  - Requires
    ```typst
    #import "@preview/touying:0.6.1": utils.fit-to-height
    ```
    See documentation on https://touying-typ.github.io/docs/utilities/fit-to for more details.
  - Expressions for $sin(x)$
    $
      sin(x) = x product_(n=1)^infinity (1 - x^2 / (n^2 pi^2))
      = sum_(n=0)^infinity (-1)^n / (2 n + 1)! x^(2n + 1)
    $
  - a bullet point
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
  - a bullet point
  - a bullet point
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
comes later
#pause
and some even later
#pause
and some comes last
#v(1fr)

== Random Placement of Images
- Any content, e.g., image or text can be randomly \
  placed using the `place` function.\
  #box(width: 63%, [
    ```typst
    #place(top + right, dx: 0mm, dy: 0mm,
           image("blue_marble.jpg", height: 80%))
    ```])
- Details on arguments for the function on\
  https://typst.app/docs/reference/layout/place/
- For example, you can easily wrap text around the image
- #lorem(6)
- #lorem(6)
- #lorem(13)
- #lorem(13)

#place(top + right, dx: 0mm, dy: -5mm, image("blue_marble.jpg", height: 80%))

#title-slide(extra: place(bottom + right, dy: 13mm, "Title slide with some extra text"))

#end-slide("liu.se")
