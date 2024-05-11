// imports
#import "@preview/cetz:0.2.2": canvas, plot
#import "@preview/glossarium:0.4.0": make-glossary, print-glossary, gls, glspl 
#import "@preview/mitex:0.2.3": *

// add
// - subpar for sub-figures
#import "@preview/equate:0.1.0": equate

#show: make-glossary


//#import "templates/tudapub/tudapub.typ": tudapub
//#import "templates/tudapub/tudacolors.typ": tuda_colors
#import "templates/lib.typ": *

// equation sub numbering
#show: equate.with(sub-numbering: true, number-mode: "label")


// setup the template
#show: tudapub.with(
  title: [
    TUDa Thesis
    With Typst
  ],
  author: "Albert Author",

  // to deactivate the sub logo text set logo_sub_content_text: none,
  logo_sub_content_text: [
    field of study: \
    Some Field of Study \
    \
    Institute ABC
  ],

  accentcolor: "9c",
 
  abstract: [
    This is a template to write your thesis with the corporate design of #link("https://www.tu-darmstadt.de/")[TU Darmstadt].
    For instructions on how to set up this template see @sec_usage.
  ],

  bib: bibliography("tests/latex_ref/DEMO-TUDaBibliography.bib", full: true), //, style: "spie")

  logo_tuda: image("templates/tudapub/logos/tuda_logo.svg"),
  
  // logo_institute: image("templates/tudapub/logos/iasLogo.jpeg"),
  // logo_institute_sizeing_type: "width",

  // Set the margins of the content pages.
  // The title page is not affected by this.
  // Some example margins are defined in 'common/props.typ':
  //  - tud_page_margin_small  // same as title page margin
  //  - tud_page_margin_big
  // E.g.   margin: tud_page_margin_small,
  // E.g.   margin: (
  //   top: 30mm,
  //   left: 31.5mm,
  //   right: 31.5mm,
  //   bottom: 56mm
  // ),


  //outline_table_of_contents_style: "adapted",
  //reduce_heading_space_when_first_on_page: false
  //figure_numbering_per_chapter: false

  // Which pages to insert
  // Pages can be disabled individually.
  show_pages: (
    title_page: true,
    outline_table_of_contents: true,
    // "Erklärung zur Abschlussarbeit"
    thesis_statement_pursuant: true
  ),

  thesis_statement_pursuant_include_english_translation: false,

  // pages after outline that will not be included in the outline
  additional_pages_after_outline_table_of_contents: [
    == List of Symbols
    - $t$ - time
    == List of Figures
  ]
)






// test content
= Demo of the Template Style
This chapter contains lots of demo content to see how the template looks.
For usage instructions go to to @sec_usage.

== Demo Paragraphs
Here is some demo text. #lorem(50)

#lorem(110)

#lorem(60)


== Some Basic Elements
This text contains two#footnote[The number two can also be written as 2.] footnotes#footnote[This is a first footnote. \ It has a second line.].

=== Figures
The following @fig_test represents a demo Figure. 
#figure(
  rect(inset: 20pt, fill: gray)[
    Here should be an Image
  ],
  caption: [The figure caption.]
) <fig_test>

We can also make tables, as in @fig_tab_test.
#figure(
  table(
    columns: 2,
    [A], [B],
    [1], [2]
  ),
  caption: [This is the table title.]
) <fig_tab_test>
The text continues normally after the Figures.


#pagebreak()
== Test Coding
Let's autogenerate some stuff:
//#let x = (1, 2, 3)
#let x = range(0, 3)
#for (i, el) in x.map(el => el*2).enumerate() [
  - Element Nr. #i has value #el 
    #circle(fill: color.linear-rgb(100, 100, el*20), width: 12pt)
    //$circle$
]

== Lists
This is a list:
 + an item
 + another item

This is another list
 - an item
 - another item
 - yet another item


#pagebreak()


== Let's do some math
Bla _blub_ *bold*.
Math: $x + y (a+b)/2$.


$
"Align:"& \
        & x+y^2    && != 27 sum_(n=0)^N e^(i dot pi dot n) \
        & "s.t. "  && b c
        \
        \
        & mat(
            1,3 ;
            3, 4
          )^T
          && = 
          alpha 
          mat(
            x ,y ;
            x_2, y_2
          )^T
          \
          \
          & underbrace( cal(B) >= B , "This is fancy!")
\
x &= y^2 + 12  & "(This does A)"
\
y &= z \/ 2  =  z / 2 & "(This does B)" #<eq.last>
$ 
In @eq.last we can see cool stuff.

Sub equations:
$
 a &= "with line number" #<eq.second.sub> \
 b &= "no line number" \
 b &= "with line number" #<eq.second.sub2>
$



=== Math in Latex
This is possible with the package #link("https://github.com/mitex-rs/mitex")[mitex]:
You can include the package at the beginning of your document via 
//```typst
#raw(lang: "typst", "#import \"@preview/mitex:0.1.0\": *")
//```
.
Usage:
#block(breakable: false)[
  #table(
    columns: 2,
    ```latex
    mitex(`
    \begin{pmatrix}
      \dot{r}_x + \omega r_x - \omega p_x \\ 
      \dot{r}_x - \omega r_x + \omega p_x
    \end{pmatrix}
    =
    \begin{pmatrix}
      +\omega \xi_x - \omega p_x \\ 
      -\omega s_x + \omega p_x
    \end{pmatrix}
    `)
    ```,

    mitex(`
        \begin{pmatrix}
            \dot{r}_x + \omega r_x - \omega p_x \\ 
            \dot{r}_x - \omega r_x + \omega p_x
        \end{pmatrix}
        =
        \begin{pmatrix}
            +\omega \xi_x - \omega p_x \\ 
            -\omega s_x + \omega p_x
        \end{pmatrix}
    `)
  )
]

=== #strike[Adjust Equation spacing]
To reduce the spacing above and below block equations use:
```typst
#show math.equation: set block(spacing: 0.1em) // does not work!
```
#table(
  columns: 2,
  [With default spacing], [With reduced spacing],
  [
    This is Text.
    $
    x^2 = y^2
    $
    This is Text.
  ],
  [
    #show math.equation: set block(spacing: 0.5em)
    This is Text.
    $
    x^2 = y^2
    $
    This is Text.
  ]
)


== Another Section
Some graphics: \
#box(stroke: black, inset: 5mm)[
  test in a box
  #circle(width: 2.2cm, inset: 2mm)[
    And in the circle
  ]
]

Some more text here. #lorem(20)
In @fig.myfig we can see things.

#figure(
  [
    #rect(inset: 20.9pt)[Dummy Test]
  ],
  caption: [
    This is a figure
  ]
)<fig.myfig>


#lorem(100)




= Usage of this Template <sec_usage>
To use the template write the following in your `main.typ` file (also see the `README.md` of the repository for more details):
```typst
#import "templates/tuda-typst-templates/templates/tudapub/tudapub.typ": tudapub

#show: tudapub.with(
  title: [
    My Thesis
  ],
  author: "My Name",
  accentcolor: "3d"
)

= My First Chapter
Some Text
```
For the list of possible accent colors to select from see @sec_usage_accentcolors.

== Template Options
In the following, we show the show-command of this template with all doc and default options. Note that this may not be up to date, thus always also look at the file `templates/tudapub/tudapub.typ`.
```typst
#show: tudapub.with(
  title: [Title],
  title_german: [Title German],

  // Adds an abstract page after the title page with the corresponding content.
  // E.g. abstract: [My abstract text...]
  abstract: none,

  // "master" or "bachelor" thesis
  thesis_type: "master",

  // The code of the accentcolor.
  // A list of all available accentcolors is in the list tuda_colors
  accentcolor: "9c",

  // Size of the main text font
  fontsize: 10.909pt, //11pt,

  // Currently just a4 is supported
  paper: "a4",

  // Author name as text, e.g "Albert Author"
  author: "An Author",

  // Date of submission as string
  date_of_submission: datetime(
    year: 2023,
    month: 10,
    day: 4,
  ),

  location: "Darmstadt",

  // array of the names of the reviewers
  reviewer_names: ("SuperSupervisor 1", "SuperSupervisor 2"),

  // language for correct hyphenation
  language: "eng",

  // Set the margins of the content pages.
  // The title page is not affected by this.
  // Some example margins are defined in 'common/props.typ':
  //  - tud_page_margin_small  // same as title page margin
  //  - tud_page_margin_big
  // E.g.   margin: (
  //   top: 30mm,
  //   left: 31.5mm,
  //   right: 31.5mm,
  //   bottom: 56mm
  // ),
  margin: tud_page_margin_big,

  // tuda logo - has to be a svg. E.g. image("PATH/TO/LOGO")
  logo_tuda: image("logos/tuda_logo.svg"),

  // optional sub-logo of an institute.
  // E.g. image("logos/iasLogo.jpeg")
  logo_institute: none,

  // How to set the size of the optional sub-logo
  // either "width": use tud_logo_width*(2/3)
  // or     "height": use tud_logo_height*(2/3)
  logo_institute_sizeing_type: "width",

  // Move the optional sub-logo horizontally
  logo_institute_offset_right: 0mm,

  // An additional white box with content e.g. the institute, ... below the tud logo.
  // Disable it by setting its value to none.
  // E.g. logo_sub_content_text: [ Institute A \ filed of study: \ B]
  logo_sub_content_text: [
    field of study: \
    Some Field of Study \
    \
    Institute A
  ],


  // The bibliography created with the bibliography(...) function.
  // When this is not none a references section will appear at the end of the document.
  // E.g. bib: bibliography("my_references.bib")
  bib: none,


  // Add an English translation to the "Erklärung zur Abschlussarbeit".
  thesis_statement_pursuant_include_english_translation: false,
  
  // Which pages to insert
  // Pages can be disabled individually.
  show_pages: (
    title_page: true,
    outline_table_of_contents: true,
    // "Erklärung zur Abschlussarbeit"
    thesis_statement_pursuant: true
  ),



  // Insert additional pages directly after the title page.
  // E.g. additional_pages_after_title_page: [
  //   = Notes
  //   #pagebreak()
  //   = Another Page
  // ]
  additional_pages_after_title_page: none,

  // Insert additional pages directly after the title page.
  // E.g. additional_pages_after_title_page: [
  //   = Notes
  //   #pagebreak()
  //   = Another Page
  // ]
  additional_pages_before_outline_table_of_contents: none,

  // Insert additional pages directly after the title page.
  // E.g. additional_pages_after_title_page: [
  //   = Notes
  //   #pagebreak()
  //   = Another Page
  // ]
  additional_pages_after_outline_table_of_contents: none,



  // For headings with a height level than this number no number will be shown.
  // The heading with the lowest level has level 1.
  // Note that the numbers of the first two levels will always be shown.
  heading_numbering_max_level: 3,

  // In the outline the max heading level will be shown.
  // The heading with the lowest level has level 1.
  outline_table_of_contents_max_level: 3,

  // Set space above the heading to zero if it's the first element on a page.
  // This is currently implemented as a hack (check the y pos of the heading).
  // Thus when you experience compilation problems (slow, no convergence) set this to false.
  reduce_heading_space_when_first_on_page: true,


  // How the table of contents outline is displayed.
  // Either "adapted":    use the default typst outline and adapt the style 
  // or     "rewritten":  use own custom outline implementation which better reproduces the look of the original latex template.
  //                      Note that this may be less stable than "adapted", thus when you notice visual problems with the outline switch to "adapted".
  outline_table_of_contents_style: "rewritten",

  // Use own rewritten footnote display implementation.
  // This may be less stable than the built-in footnote display impl.
  // Thus when having problems with the rendering of footnote disable this option.
  footnote_rewritten_fix_alignment: true,

  // When footnote_rewritten_fix_alignment is true, add a hanging intent to multiline footnotes.
  footnote_rewritten_fix_alignment_hanging_indent: true,

  // Use 'Roboto Slab' instead of 'Robot' font for figure captions.
  figure_caption_font_roboto_slab: true,

  // Figures have the numbering <chapter-nr>.<figure-nr>
  figure_numbering_per_chapter: true,

  // Equations have the numbering <chapter-nr>.<equation-nr>
  // @todo This seems to increase the equation number in steps of 2 instead of one
  equation_numbering_per_chapter: false,
)
```


== TUDa Accent Color List <sec_usage_accentcolors>
The list of colors that can be used in the template argument `accentcolor`:
#grid(
  columns: auto,
  rows: auto,
  for (key, color) in tuda_colors {
    box(
      inset: 3pt,
      width: 100% / 3,
      box(
        height: auto,
        inset: 4pt,
        outset: 0pt,
        width: 100%,
        fill: rgb(color)
      )[
        #set align(center)
        #key
      ]
    )
  }
)




 


= Glossary
#print-glossary((
  // minimal term
  (key: "kuleuven", short: "KU Leuven"),
  // a term with a long form
  (key: "unamur", short: "UNamur", long: "Université de Namur"),
  // no long form here
  (key: "kdecom", short: "KDE Community", desc:"An international team developing and distributing Open Source software."),
  // a full term with description containing markup
  (
    key: "oidc", 
    short: "OIDC", 
    long: "OpenID Connect", 
    desc: [OpenID is an open standard and decentralized authentication protocol promoted by the non-profit
     #link("https://en.wikipedia.org/wiki/OpenID#OpenID_Foundation")[OpenID Foundation].]),
),
  show-all: true
)