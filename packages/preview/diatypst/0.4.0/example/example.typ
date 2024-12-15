#import "../lib.typ": *

#show: slides.with(
  title: "Diatypst", // Required
  subtitle: "easy slides in typst",
  date: "01.07.2024",
  authors: ("Marten Walk"),
  // Optional Style Options
  title-color: blue.darken(50%),
  ratio: 4/3, // aspect ratio of the slides, any valid number
  layout: "medium", // one of "small", "medium", "large"
  toc: true, 
  count: true,
  footer: true,
  // footer-title: "Custom Title", 
  // footer-subtitle: "Custom Subtitle", 
  // theme: "full" | one of "normal", "full"
)

= About _diatypst_

== General

_diatypst_ is a simple slide generator for _typst_. 

Features:

- easy delimiter for slides and sections (just use headings)
- sensible styling
- dot counter in upper right corner (like LaTeX beamer)
- adjustable color-theme
- default show rules for terms, code, lists, ... that match color-theme

This short presentation is a showcase of the features and options of _diatypst_.

== Usage

To start a presentation, initialize it in your typst document:

```typst
#import "@preview/diatypst:0.2.0": *
#show: slides.with(
  title: "Diatypst", // Required
  subtitle: "easy slides in typst",
  date: "01.07.2024",
  authors: ("John Doe"),
)
...
```

Then, insert your content.

- Level-one headings corresponds to new sections.
- Level-two headings corresponds to new slides.

== Options

To start a presentation, only the title key is needed, all else is optional!

Basic Content Options:
#table(
  columns: 3,
  [*Keyword*], [*Description*], [*Default*],
  [_title_], [Title of your Presentation, visible also in footer], [`none` (required!)],
  [_subtitle_], [Subtitle, also visible in footer], [`none`],
  [_date_], [a normal string presenting your date], [`none`],
  [_authors_], [either string or array of strings], [`none`],
  [_footer-title_], [custom text in the footer title (left)], [same as `title`],
  [_footer-subtitle_], [custom text in the footer subtitle (right)], [same as `subtitle`],
)

#pagebreak()

Advanced Styling Options:
#table(
  columns: 3,
  [*Keyword*], [*Description*], [*Default*],
  [_layout_], [one of _small, medium, large_, adjusts sizing of the elements on the slides], [`"medium"`],
  [_ratio_], [aspect ratio of the slides, e.g., 16/9], [`4/3`],
  [_title-color_], [Color to base the Elements of the Presentation on], [`blue.darken(50%)`],
  [_count_], [whether to display the dots for pages in upper right corner], [`true`],
  [_footer_], [whether to display the footer at the bottom], [`true`],
  [_toc_], [whether to display the table of contents], [`true`],
  [_theme_], [one of _normal, full_, adjusts the theme of the slide], [`"normal"`],
)

The full theme adds more styling to the slides, similar to a a full LaTeX beamer theme.

= Default Styling in diatypst

== Terms, Code, Lists

_diatypst_ defines some default styling for elements, e.g Terms created with ```typc / Term: Definition``` will look like this

/ *Term*: Definition

A code block like this

```python
// Example Code 
print("Hello World!")
```

Lists have their marker respect the `title-color`

#columns(2)[
  - A
    - AAA
      - B
  #colbreak()
  1. AAA
  2. BBB
  3. CCC
]



== Tables and Quotes



#columns(2)[
  Look at this styled table
  #table(
    columns: 3,
    [*Header*],[*Header*],[*Header*],
    [Cell],[Cell],[Cell],
    [Cell],[Cell],[Cell],
  )
  #colbreak()
  compared to an original one
  #table(
    stroke: 1pt,
    columns: 3,
    [*Header*],[*Header*],[*Header*],
    [Cell],[Cell],[Cell],
    [Cell],[Cell],[Cell],
  )
]

And here comes a quote

#quote(attribution: [Plato])[
  This is a quote
]

And finally, web links are styled like this: #link("https://typst.app")[typst.app]

= Additional

== More Info

For more information, visit the #link("www.github.com/skriptum/diatypst")[diatypst repository]. The package is also available on the #link("https://typst.app/universe/package/diatypst")[typst universe].

For Issues and Feature Requests, please use the GitHub Repo.

To find the source code for this presentation, visit the #link("https://github.com/skriptum/diatypst/tree/main/example")[example folder on GitHub]. An minimal template can also be #link("https://github.com/skriptum/diatypst/blob/main/template/main.typ")[found here]  

== Inspiration

this template is inspired by #link("https://github.com/glambrechts/slydst")[slydst], and takes part of the code from it. If you want simpler slides, look here!

The word _diatypst_ is inspired by 

#columns(2)[
  #image("diaprojektor.jpg", height: 3cm)
  the ease of use of a #link("https://de.wikipedia.org/wiki/Diaprojektor")[Diaprojektor] (German for Slide Projector)

  #colbreak()

  #image("diatype.jpg", height: 3cm) 
  and the #link("https://en.wikipedia.org/wiki/Diatype_(machine)")[Diatype] (60s typesetting machine)
]


