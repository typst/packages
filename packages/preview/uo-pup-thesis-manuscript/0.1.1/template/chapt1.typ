#import "@preview/uo-pup-thesis-manuscript:0.1.1": *


// the template will transform this to uppercase
#let title = "The problem and its setting"
#let chaptNumber = 1


#chapter(chaptNumber, title)

// Start of chapter
== Introduction

This is an example introduction. Assume that your `.bib` file already have some contents, add some citations using `@<citekey>` format like this: @debondt2012computationalcomplexityminesweeper. To know more about Typst's syntax, head over to their #underline[#link("https://typst.app/docs")[documentation]]\u{1f517}.

#figure(
  table(
    columns: 3,
    table.header(
      [Substance],
      [Subcritical °C],
      [Supercritical °C],
    ),
    [Hydrochloric Acid],
    [12.0], [92.1],
    [Sodium Myreth Sulfate],
    [16.6], [104],
    [Potassium Hydroxide],
    table.cell(colspan: 2)[24.7],
  ),
  caption: [Sample Table],
)

#lorem(100)

#figure(
  table(
    columns: 3,
    table.header(
      [Substance],
      [Subcritical °C],
      [Supercritical °C],
    ),
    [Hydrochloric Acid],
    [12.0], [92.1],
    [Sodium Myreth Sulfate],
    [16.6], [104],
    [Potassium Hydroxide],
    table.cell(colspan: 2)[24.7],
  ),
  caption: [Another Table],
) <another-table>

#lorem(50)

#figure(
  rect(image("images/typst.svg", width: 50%)),
  caption: [Sample Image],
) <sample-image> // image label for referencing

You can reference an image with `@<image-label>` like this: @sample-image; also with tables: @another-table. #lorem(50)

// If you think it's necessary to add page break, just call this
#pagebreak()

== Significance of the Study <sig-study>

I highly recommend to use `#description()` function for this section. This provides an already formatted setup that follows the university thesis manual.

#description((
  (
    term: [Society],
    desc: [This study speaks a lot about our society. #lorem(20)],
  ),
  (
    term: [Environment],
    desc: [This study aims to eradicate the existence of plastic straws to save all the turtles. #lorem(20)],
  ),
  (term: [And more], desc: [#lorem(40)]),
))

== Definition of Terms

This section follows the same format from #link(<sig-study>)[Significance of the Study].

#description((
  (
    term: [Ohio],
    desc: [Ohio is a state in the Midwestern region of the United States. It borders Lake Erie to the north, Pennsylvania to the east, West Virginia to the southeast, Kentucky to the southwest, Indiana to the west, and Michigan to the northwest.],
  ),
  (
    term: [Sigma],
    desc: [Sigma is the eighteenth letter of the Greek alphabet. In the system of Greek numerals, it has a value of 200. In general mathematics, uppercase $Sigma$ is used as an operator for summation.],
  ),
))

// End of chapter
