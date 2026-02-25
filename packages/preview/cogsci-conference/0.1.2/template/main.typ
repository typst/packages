//
// Annual Cognitive Science Conference
// Sample Typst Paper -- Proceedings Format
//

#import "@preview/cogsci-conference:0.1.2": cogsci, format-authors

#let anonymize = true // Set to false for the final submission

#let hyphenate = true // Set to false to disable hyphenation (useful for proofreading)

#show: cogsci.with(
  title: [How to Make a Proceedings Paper Submission],
  author-info: format-authors(
    authors: (
      (
        name: [Author N. One],
        email: "a1@uni.edu",
        super: [1],
      ),
      (
        name: [Author Number Two],
        super: [2],
      ),
    ),
    affiliations: (
      (super: [1], affil: [Department of Hypothetical Sciences, University of Illustrations]),
      (super: [2], affil: [Department of Example Studies, University of Demonstrations]),
    ),
  ),
  abstract: [
    Include no author information in the initial submission, to facilitate blind review. AI tools cannot be listed as authors, and authors retain full responsibility for the accuracy, integrity, and originality of all content in their manuscripts. This includes verifying factual claims, ensuring proper attribution of ideas, and confirming that the work meets standards for academic integrity and does not contain plagiarized content. See the Acknowledgments section of the template for AI use declaration and acknowledgment. The abstract should be one paragraph, no more than 150~words, indented 1/8~inch on both sides, in 9~point font with single spacing. The heading "*Abstract*" should be 10~point, bold, centered, with one line of space below it. This one-paragraph abstract section is required only for standard proceedings papers. Following the abstract should be a blank line, followed by the header "*Keywords:*" and a list of descriptive keywords separated by semicolons, all in 9~point font, as shown below.
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

The paper can be no longer than six pages plus an unlimited number of pages for references in the *initial submission*. In the *final submission*, the text of the paper, including an author line, must fit on six pages. An unlimited number of pages can be used for acknowledgments and references.

The *title* should be in 14~point bold font, centered. The title should be formatted with initial caps (the first letter of content words capitalized and the rest lower case). In the *initial submission*, leave one space below the title and on the next line include the phrase "Anonymous CogSci submission", centered, in 11~point bold font. In the *final submission*, leave one space below the title, then list author names (on one line, though if there are many authors this will continue on subsequent lines) in 11~point bold font, and centered, with superscript numerals that will correspond to author affiliation. The *corresponding author's* email address and no other email addresses should be placed in parentheses next to their name in the author list. Starting on the next line, list authors' affiliations using the corresponding superscript numeral and including only the department/unit and organization in ordinary 10~point type, one affiliation per line.

The text of the paper should be formatted in two columns with an overall width of 7~inches (17.8~cm) and length of 9.25~inches (23.5~cm), with 0.25~inches between the columns. Leave two line spaces between the last author affiliation and the text of the paper; the text of the paper (starting with the abstract) should begin no less than 2.75~inches below the top of the page. The left margin should be 0.75~inches and the top margin should be 1~inch. *The right and bottom margins will depend on whether you use U.S. letter or A4 paper, so you must be sure to measure the width of the printed text*. Use 10~point Times Roman with 12~point vertical spacing, unless otherwise specified.

Indent the first line of each paragraph by 1/8~inch (except for the first paragraph of a new section). Do not add extra vertical space between paragraphs.


= First Level Headings

First level headings should be in 12~point, initial caps, bold and centered. Leave one line space above the heading and 1/4~line space below the heading.


== Second Level Headings

Second level headings should be 11~point, initial caps, bold, and flush left. Leave one line space above the heading and 1/4~line space below the heading.


=== Third Level Headings
//
Third level headings should be 10~point, initial caps, bold, and flush left. Leave one line space above the heading, but no space after the heading.


= Formalities, Footnotes, and Floats

Use standard APA citation format. Citations within the text should include the author's last name and year. If the authors' names are included in the sentence, place only the year in parentheses, as in #cite(<DaphneEcho2022>, form: "prose"), but otherwise place the entire reference in parentheses with the authors and year separated by a comma @DaphneEcho2022. Use the "et~al." construction for works with three or more authors. List multiple references alphabetically and separate them by semicolons @August2007 @DaphneEcho2022.


== Footnotes

Indicate footnotes with a number#footnote[Sample of the first footnote.] in the text. Place the footnotes in 9~point font at the bottom of the column on which they appear. Precede the footnote block with a horizontal rule.#footnote[Sample of the second footnote.]


== Tables

Number tables consecutively. Place the table number and title (in 10~point) above the table with one line space above the caption and one line space below it, as in @sample-table. You may float tables to the top or bottom of a column, and you may set wide tables across both columns.

#figure(
  table(
    align: left,
    columns: 2,
    table.hline(),
    [Error type], [Example],
    table.hline(),
    [Take smaller], [63 - 44 = 21],
    [Always borrow], [96 - 42 = 34],
    [0 - N = N], [70 - 47 = 37],
    [0 - N = 0], [70 - 47 = 30],
    table.hline(),
  ),
  caption: [Sample table title.],
  kind: table,
) <sample-table>


== Figures

All artwork must be very dark for purposes of reproduction and should not be hand drawn. Number figures sequentially, placing the figure number and caption, in 10~point, after the figure with one line space above the caption and one line space below it, as in @sample-figure. If necessary, leave extra white space at the bottom of the page to avoid splitting the figure and figure caption. You may float figures to the top or bottom of a column, and you may set wide figures across both columns.

#figure(
  rect(stroke: 0.5pt, inset: 3pt)[CoGNiTiVe ScIeNcE],
  caption: [This is a figure.],
  kind: image,
) <sample-figure>


= Acknowledgments

In the *initial submission*, please only include acknowledgments of AI use and no other acknowledgments to preserve anonymity. Regarding AI use: Authors may use AI tools when developing their projects and preparing their manuscripts, but such use must be described, transparently and in detail, in either the Methods or Acknowledgments section, as appropriate. Tools that are used to improve spelling, grammar, and general editing are not included in the scope of these guidelines. In the *final submission*, place acknowledgments (including human and AI contributions, and funding information) in a section *at the end of the paper*.


= References Instructions

Follow the APA Publication Manual for citation format, both within the text and in the reference list, with the following exception: use the same format for unpublished references as for published ones. Alphabetize references by the surnames of the authors, with single author entries preceding multiple author entries. Order references by the same authors by the year of publication, with the earliest first. Include DOIs if available.

Use a first level section heading, "*References*", as shown below. Use a hanging indent style, with the first line of the reference flush against the left margin and subsequent lines indented by 1/8~inch. Below are example references for a conference paper, journal article, technical report, dissertation, book chapter, edited volume, and book, respectively.


#cite(<August2007>, form: none)
#cite(<DaphneEcho2022>, form: none)
#cite(<FitzgeraldGalli1985>, form: none)
#cite(<Hakuole2001>, form: none)
#cite(<Issa1963>, form: none)
#cite(<Lobsang2023>, form: none)
#cite(<MitanniNovember1972>, form: none)


#bibliography("bibliography.bib") // Specify the path to a BibLaTeX file
