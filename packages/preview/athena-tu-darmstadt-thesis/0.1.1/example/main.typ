
#import "@preview/athena-tu-darmstadt-thesis:0.1.1": *

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

  logo_tuda: image("logos/tuda_logo.svg"),
  accentcolor: "9c",
 
  abstract: [
    This is a template to write your thesis with the corporate design of #link("https://www.tu-darmstadt.de/")[TU Darmstadt].
  ],

  bib: bibliography("refs.bib", full: true),

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
  margin: tud_page_margin_big,


  // outline_table_of_contents_style: "adapted",
  // figure_numbering_per_chapter: false
  // 
  // Set space above the heading to zero if it's the first element on a page.
  // This is currently implemented as a hack (check the y pos of the heading).
  // Thus when you experience compilation problems (slow, no convergence) set this to false.
  reduce_heading_space_when_first_on_page: false,


  // Which pages to insert
  // Pages can be disabled individually.
  show_pages: (
    title_page: true,
    outline_table_of_contents: true,
    // "Erklärung zur Abschlussarbeit"
    thesis_statement_pursuant: true
  ),

  // Set this to true to add the page for the translation of the statement of pursuant
  thesis_statement_pursuant_include_english_translation: false,


  // pages after outline that will not be included in the outline
  additional_pages_after_outline_table_of_contents: [
    == List of Symbols
    - $t$ - time
    == List of Figures
  ]
)





// test content
= First Chapter
A first demo chapter. 
An example reference is @TUDaGuideline.


== Some Basic Elements
This text contains two#footnote[The number two can also be written as 2.] footnotes#footnote[This is a first footnote. \ It has a second line.].

=== Figures
The following @fig_test represents a demo Figure. 
#figure(
  rect(inset: 20pt, fill: gray)[
    Image
  ],
  caption: [The figure caption.]
) <fig_test>


