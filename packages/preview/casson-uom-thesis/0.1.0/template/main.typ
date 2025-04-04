// ------ TEMPLATE SETUP ------------------------------------------------
#import "@preview/casson-uom-thesis:0.1.0": *

// Set up the project. Commented out fields are optional
#show: uom-thesis.with(
  title: "A data reduction algorithm incorporating a low power continuous wavelet transform for use in wearable electroencephalography systems",
  author: "Alexander J. Casson",
  faculty: "Science and Engineering",
  school: "School of Engineering",
  departmentordivision: "Department of Electrical and Electronic Engineering",
  abstract: [Abstract goes here],
  publications: [Publications go here.],
  //termsandabbreviations: [Enter terms and abbreviations as table or similar], // uncomment if want in thesis
  // layabstract: [Lay abstract goes here], // uncomment if want in thesis
  acknowledgements: [Acknowledgements go here.],
  // theauthor: [If desired, a brief statement for External Examiners giving the candidate’s degree(s) and research experience, even if the latter consists only of the work done for this thesis.], // uncomment if want in thesis
  year: "2024",
  font: "times", // choices are: "times", "palatino", "roboto", "noto_sans" 
  fontsize: 11pt, // can be any reasonable value
)



// ------ MAIN BODY -----------------------------------------------------
= Introduction
#lorem(60) // add dummy text as a placeholder


#pagebreak() // need to add by hand at the moment for each chapter to start on a new page
= Literature review
== Introduction
#lorem(60) // add dummy text as a placeholder

== Example display items
This is an example of providing a cross-reference to @sec:really_good_work. Similarly, this is an example cross-reference to a sub-section, @sec:content.

This is an example of adding references @ref:jCAS09 @ref:jCAS09a @ref:jCAS10. If you want the author name, or similar, you can use: #cite(<ref:jCAS09>, form: "author") in #cite(<ref:jCAS09>, form: "year") introduced a really good idea. (This is for when you primarily use numbered citations, but occasionally need an author’s name. If using author names as the reference everywhere, change style=ieee in the biblatex setup above to whatever reference style you want, and then just use the cite command.)

For adding #emph[emphasis] use the emph command or underscores such as _emphasis_.

An example table is given in @table:example_tabular. Note that the headings are inside a table.header environment to tell screen readers which cells are headers and which cells have the table content. Also, at the moment the template only adds the top horizontal line to the table. The others are added by hand in the table definition below. Ideally the template should detect the end of the header, and the end of the table, and add these horizontal lines automatically, but this doesn't work yet. 
#figure(
table(
  columns: 5,
  table.hline(stroke: 1.5pt),
  table.header(
    table.cell(align: horizon, rowspan: 2, [Participant]),
    table.cell(colspan: 2,[Number (%)]),
    table.cell(colspan: 2,[Duration (%)]),
    [Prime dresses], [Non-prime dresses], [Prime dresses], [Non-prime dresses],
  ),
  table.hline(stroke: 1.5pt), // note added by hand, whereas top is done in template
  [1], [33.33], [33.91], [20.83], [18.42],
  [2], [13.04], [17.50], [04.93], [07.62],
  [3], [22.73], [20.10], [13.00], [08.20],
  [4], [31.34], [21.88], [10.57], [11.09],
  [5], [08.47], [19.32], [03.04], [09.73],
  table.hline(),
  [Mean], [16.4], [16.5], [07.8], [07.5],
  [Standard deviation], [09.7], [06.6], [05.4], [03.3],
  table.hline(stroke: 1.5pt), // note added by hand, whereas top is done in template
),
caption: [Probe results for design A.],
)<table:example_tabular>

This is an example equation in text $2 sin omega t$. @equ:example_equation is an example of a displayed equation.

$ a^2 + b^2 = c^2 $ <equ:example_equation>

Note that numbers are displayed differently in the text depending on how they are entered. Compare for example 123456 vs. $123456$. Entering numbers directly, such as 1955, should be used for _text mode_ numbers. That is, those representing text (dates, page numbers, and similar). Numbers representing maths, or variables or similar, should be entered inside \$ \$ so they are typeset in the same way as they appear in an equation. (This requires a bit of discipline, but helps ensure consistent use of number styles throughout.)

This is an example of a quote in text #quote(attribution: cite(<ref:jCAS10>))[The electroencephalogram (EEG) is a classic non-invasive method for measuring a person’s brainwaves]. Below is an example of a displayed quote. 

#quote(block: true, attribution: cite(<ref:jCAS10>))[
  Electrodes are placed on the scalp to detect the microvolt-sized signals that result from synchronized neuronal activity within the brain.
]

@fig:uom_logo is an example figure. Sub-figures are not currently supported by the temp;ate. There is an example commented out below which uses the subpar package, however the way subpar re-labels the captions is incompatible with how they've been re-labelled already in the template. The commented out example gets relatively close to being correct, but isn't perfect. This will need to be re-visited in a future release. 

#figure(
  image("image.svg", width: 30%, alt: "Put short description for screen readers here"), caption: [
    Example figure. Full caption goes here. Often a short caption in \[\] is used as well as the main caption to keep the list of figures tidy; it gets messy if there are long captions going over more than one line.
  ],
) <fig:uom_logo>

// #import "@preview/subpar:0.2.0"
// #subpar.grid(
//   figure(
//     image("image.svg", width: 100%, alt: "Put short description for screen readers here"), caption: []
//   ), <fig:subfig_a>,
//   figure(
//     image("image.svg", width: 100%, alt: "Put short description for screen readers here"), caption: []
//   ), <fig:subfig_b>,
//   figure(
//     image("image.svg", width: 100%, alt: "Put short description for screen readers here"), caption: []
//   ), <fig:subfig_c>,
//   columns: (1fr, 1fr, 1fr),
//   caption: [Three copies of the University logo. (a) Copy one. (b) Copy two. (c) Copy three.],
//   label: <fig:uom_logo_in_subfig>,
//   numbering: num => (
//     numbering("1.1", counter(heading).get().first(), num)
//   ),
// )


An example code listing is given below. Code in the body of the text can be included as `for` or `while` or `main`. This is just using the built in Typst functionality which is fairly limited. Could look at #link("https://typst.app/universe/package/codly/") or similar to give more functionality such as line numbers, ability to link to a piece of code, and similar.

```python
import numpy as np

def my_filter(in,f_obj):
    y = filter(f_obj,in)

    return y
``` <code:example>


== Summary
#lorem(60)

#pagebreak() // need to add by hand at the moment for each chapter to start on a new page
= Really good work <sec:really_good_work>
== Introduction
#lorem(60)

== Content <sec:content>
#lorem(60)

=== Introduction
#lorem(60)

=== Detail
#lorem(60)

=== More detail
#lorem(60)

=== Summary
#lorem(60)

== Summary
#lorem(60)

#pagebreak()
= Conclusions
#lorem(60)



// ------ REFERENCES ----------------------------------------------------
#pagebreak()
#bibliography("references.yml", style: "ieee", title: "References")



// ------ APPENDICIES ---------------------------------------------------
#pagebreak() // need to add by hand at the moment for each chapter to start on a new page
#show: uom-appendix
= First Appendix <first-appendix>
== Section in Appendix <section-in-appendix>
#figure(
  image("image.svg", width: 30%, alt: "Put short description for screen readers here"), caption: [
    Example figure in Appendix.
  ],
) <fig:uom_logo2>

#pagebreak()
= Second Appendix <second-appendix>
== Section in Appendix <section-in-appendix-1>
