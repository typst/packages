// CogSci Conference Paper Template

#import "@preview/cogsci-conference:0.1.0": cogsci, format-authors

#let anonymize = true // Set to false for the final submission

#let hyphenate = true // Set to false to disable hyphenation (useful for proofreading)

#let authors = (
  (
    name: [Morton Ann Gernsbacher],
    email: "MAG@Macc.Wisc.Edu",
    affiliation: [Department of Psychology, 1202 W. Johnson Street\
      Madison, WI 53706 USA],
  ),
  (
    name: [Sharon J. Derry],
    email: "SDJ@Macc.Wisc.Edu",
    affiliation: [Department of Educational Psychology, 1025 W. Johnson Street\
      Madison, WI 53706 USA],
  ),
)

#show: cogsci.with(
  title: [How to Make a Proceedings Paper Submission],
  authors: format-authors(authors),
  abstract: [
    Include no author information in the initial submission, to facilitate blind review. The abstract should be one paragraph, indented 1/8 inch on both sides, in 9 point font with single spacing. The heading "*Abstract*" should be 10 point, bold, centered, with one line of space below it. This one-paragraph abstract section is required only for standard six page proceedings papers. Following the abstract should be a blank line, followed by the header "*Keywords:*" and a list of descriptive keywords separated by semicolons, all in 9 point font, as shown below.
  ],
  keywords: (
    "add your choice of indexing terms or keywords",
    "kindly use a semicolon",
    "between each term",
  ),
  anonymize: anonymize,
  hyphenate: hyphenate,
)

= General Formatting Instructions

The entire content of a paper (including figures and anything else) can be no longer than six pages in the *initial submission*. In the *final submission*, the text of the paper, including an author line, must fit on six pages. An unlimited number of pages can be used for acknowledgements and references.

The text of the paper should be formatted in two columns with an overall width of 7 inches (17.8 cm) and length of 9.25 inches (23.5 cm), with 0.25 inches between the columns. Leave two line spaces between the last author listed and the text of the paper; the text of the paper (starting with the abstract) should begin no less than 2.75 inches below the top of the page. The left margin should be 0.75 inches and the top margin should be 1 inch. *The right and bottom margins will depend on whether you use U.S. letter or A4 paper, so you must be sure to measure the width of the printed text.* Use 10 point Times Roman with 12 point vertical spacing, unless otherwise specified.

The title should be in 14 point bold font, centered. The title should be formatted with initial caps (the first letter of content words capitalized and the rest lower case). In the initial submission, the phrase "Anonymous CogSci submission" should appear below the title, centered, in 11 point bold font. In the final submission, each author's name should appear on a separate line, 11 point bold, and centered, with the author's email address in parentheses. Under each author's name list the author's affiliation and postal address in ordinary 10 point type.

Indent the first line of each paragraph by 1/8 inch (except for the first paragraph of a new section). Do not add extra vertical space between paragraphs.

= First Level Headings

First level headings should be in 12 point, initial caps, bold and centered. Leave one line space above the heading and 1/4 line space below the heading.

== Second Level Headings

Second level headings should be 11 point, initial caps, bold, and flush left. Leave one line space above the heading and 1/4 line space below the heading.

=== Third Level Headings
//
Third level headings should be 10 point, initial caps, bold, and flush left. Leave one line space above the heading, but no space after the heading.

= Formalities, Footnotes, and Floats

Use standard APA citation format. Citations within the text should include the author's last name and year. If the authors' names are included in the sentence, place only the year in parentheses, as in @NewellSimon1972a, but otherwise place the entire reference in parentheses with the authors and year separated by a comma @ChalnickBillman1988a. List multiple references alphabetically and separate them by semicolons @ChalnickBillman1988a @NewellSimon1972a. Use the "et al." construction only after listing all the authors to a publication in an earlier reference and for citations with four or more authors.

== Footnotes

Indicate footnotes with a number#footnote[Sample of the first footnote.] in the text. Place the footnotes in 9 point font at the bottom of the column on which they appear. Precede the footnote block with a horizontal rule.#footnote[Sample of the second footnote.]

== Tables

Number tables consecutively. Place the table number and title (in 10 point font) above the table with one line space above the caption and one line space below it, as in @sample-table. You may float tables to the top or bottom of a column, and you may set wide tables across both columns.

#figure(
  table(
    columns: 2,
    stroke: (x, y) => if y == 0 or y == 5 { (top: 0.5pt, bottom: 0.5pt) } else if y == 1 { (bottom: 0.5pt) } else {
      none
    },
    align: left,
    [Error type], [Example],
    [Take smaller], [63 - 44 = 21],
    [Always borrow], [96 - 42 = 34],
    [0 - N = N], [70 - 47 = 37],
    [0 - N = 0], [70 - 47 = 30],
  ),
  caption: [Sample table title.],
  kind: table,
) <sample-table>

== Figures

All artwork must be very dark for purposes of reproduction and should not be hand drawn. Number figures sequentially, placing the figure number and caption, in 10 point, after the figure with one line space above the caption and one line space below it, as in @sample-figure. If necessary, leave extra white space at the bottom of the page to avoid splitting the figure and figure caption. You may float figures to the top or bottom of a column, and you may set wide figures across both columns.

#figure(
  rect(stroke: 0.5pt)[CoGNiTiVe ScIeNcE],
  caption: [This is a figure.],
  kind: image,
) <sample-figure>

= Acknowledgments

In the *initial submission*, please *do not include acknowledgements*, to preserve anonymity. In the *final submission*, place acknowledgments (including funding information) in a section *at the end of the paper*.

= References Instructions

Follow the APA Publication Manual for citation format, both within the text and in the reference list, with the following exceptions: (a) do not cite the page numbers of any book, including chapters in edited volumes; (b) use the same format for unpublished references as for published ones. Alphabetize references by the surnames of the authors, with single author entries preceding multiple author entries. Order references by the same authors by the year of publication, with the earliest first.

Use a first level section heading, "References", as shown below. Use a hanging indent style, with the first line of the reference flush against the left margin and subsequent lines indented by 1/8 inch. Below are example references for a conference paper, book chapter, journal article, dissertation, book, technical report, and edited volume, respectively.

// Include additional entries in bibliography without citing them in text
// Equivalent to LaTeX \nocite{}
#hide[
  @Feigenbaum1963a
  @Hill1983a
  @OhlssonLangley1985a
  @Matlock2001
  @ShragerLangley1990a
]

// Bibliography (uses BibLaTeX .bib file and APA style)
#bibliography("bibliography.bib", style: "apa")
