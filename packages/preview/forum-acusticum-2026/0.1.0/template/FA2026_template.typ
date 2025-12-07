#import "@preview/forum-acusticum-2026:0.1.0": fa2026
#import "@preview/unify:0.7.1": *

#show: fa2026.with(
  title: [Title],
  authors: (
    (
      name: "First Author",
      corresponding: true,
      email: "first.author@email.ad",
      affiliations: (
        "Department of Computer Science, University, Country"
      ),
    ),
    (
      name: "Second Author",
      affiliations: (
        "Department of Computer Science, University, Country"
      ),
    ),
    (
      name: "Third Author",
      affiliations: (
        "International Laboratories, City, Country"
      ),
    ),
    (
      name: "Fourth Author",
      affiliations: (
        "Company, Address"
      ),
    ),
    (
      name: "Fifth Author",
      affiliations: (
        "International Laboratories, City, Country",
        "Company, Address",
      ),
    ),
  ),

  abstract: [
    The abstract should be placed below the title, list of Authors and affiliations. It should contain a maximum of 200 words.
  ],
  keywords: ("MANDATORY", "3 to 5 keywords", "separated by a comma", "italic", "not bold", "no capitalized letters"),
  peer-review: true,
  bibliography: bibliography("fa2026_template.bib"),
)

= Introduction <sec:introduction>

This template includes all the information about formatting manuscripts for the Forum Acusticum Conference. Please follow these guidelines carefully to give the final proceedings a uniform look. Most of the required formatting is achieved automatically by using the supplied style file (LaTeX) or template (Word). If you have any questions related to the template, please contact with #link("mailto:papers2026@forum-acusticum.org", "papers2026@forum-acusticum.org").


= Paper Length AND File Size
The authors can submit papers to the EAA Forum Acusticum 2026 with 4 to 6 pages length overall, including figures, tables, and references. All papers must be original works, all written in English, and not previously published.

Papers should be submitted as PDF files. The file size should not exceed 25 MB. Please compress images and figures as necessary before submitting.


= Page Size and template formatting <sec:page_size>

The proceedings will be formatted for
A4-size paper (#qty("21.0", "cm") $#sym.times$ #qty("29.7", "cm")), portrait layout.
All material on each page should fit within a rectangle of #qty("17.0", "cm") x #qty("24.2", "cm"),
centered on the page, beginning #qty("2.0", "cm")
from the top of the page and ending with #qty("3.5", "cm") from the bottom.
The left and right margins should be #qty("2.0", "cm").
The text should be in two #qty("8.1", "cm") columns with a #qty("0.8", "cm") gutter.
All text must be in a two-column format. Text must be fully justified. It is fundamental not to change the predefined position of the header and footer banners in the template, nor to add any additional information above the header or below the footer banners. The skip between text body and footer should be set to #qty("43", "pt").
*All papers must be compliant with the formatting guidelines provided in this template for papers indexing purposes and timely reviews. Any paper that varies from this format will be returned to the author(s) for re-formatting using the presented guidance. Only papers conforming to the template guidelines will be included in the proceedings.*


= Typeset Text <sec:typeset_text>

== Normal or body text <subsec:body>

Please use a #qty("10", "pt") (point) Latin Modern Roman font with 0.95 line spacing. Do not use any font other than the one indicated, to ensure compatibility between different PDF reading systems.

== Title and authors

The following is for making a camera-ready version.
The title is #qty("14.4", "pt") Latin Modern Roman, bold, caps, upper case, and centered.
Authors' names are centered as well. The lead author's name is to be listed first (left-most), and the co-authors' names after.
If the addresses for all authors are the same, include the address only once. If the authors have different addresses, put the addresses as multiple affiliations. This is done automatically in the LaTeX template when using the `author` and `affil` commands.
To avoid duplicities of authors, please make sure that each author's identification name is consistent among all submitted papers.

== Peer-review notice

A header indicating the peer-review status of the paper is to be included below the authors' names, as shown in the template. The text should be justified with #qty("8", "pt") font size. Additionally, logos in grayscale are used for contributions without peer review.

== Abstract and keywords

Be sure to include the abstract and keywords at the beginning of your paper. The section title for the abstract should be formatted like a first level heading, but without numbering and centered. The abstract should be a concise summary of the work described in the paper, and should not exceed 200 words.

The keywords should be placed #qty("8", "pt") below the abstract, preceded by the a bold in-line heading #quote[Keywords:], followed by 3 to 5 keywords in italic, are separated by a comma. Use a font size of #qty("9", "pt") for the keywords.

== First page copyright notice
Please include the copyright notice exactly as it appears here in the lower left-hand corner of the page. Make sure to update the first author’s name in the copyright notice accordingly. It is set in #qty("8", "pt") Latin Modern Roman.

== Page numbering, headers and footers
Do not modify headers, footers or page numbers in your submission. These will be added electronically at a later stage, when the publications are assembled.

Section headers are numbered using arabic numerals, followed by a period. An additional spacing of #qty("5", "pt") is used after the numbering.

=== First level headings
First level headings are in Latin Modern Roman #qty("12", "pt"), bold and capital, flush left, with #qty("8", "pt") space before, and #qty("1", "pt") space after it.

=== Second level headings
Second level headings are in Latin Modern Roman #qty("10", "pt"), bold, flush left, with #qty("6", "pt") space before, and #qty("1", "pt") space after it.

=== Third level headings

Third level headings are in Latin Modern Roman #qty("10", "pt"), italic, flush left, with #qty("4", "pt") space before, and #qty("1", "pt") space after it. Using more than three levels of headings is highly discouraged.


= Footnotes and Figures

== Normal or body text

Indicate footnotes with a number in the text.#footnote[This is a footnote.]
Use #qty("8", "pt") font size for footnotes. Place the footnotes at the bottom of the page on which they appear.

== Figures, tables and captions

All artworks must be centered, neat, clean, and legible.
All lines should be very dark for purposes of reproduction and artworks should not be hand-drawn.

Proceedings will only be supplied in electronic form, so color figures are acceptable. However, for sustainability reasons it is suggested to make artworks (figures and graphs) comprehensible and clear also for black and white print. In this case a best effort should be made to remove all references to colors in figures in the text.

Please ensure sufficient resolution to avoid pixelation and compression effects. Captions for figures and tables appear below and above the object, respectively.
Each figure or table is numbered consecutively and is introduced in the text before appearing on the page. Captions should be Latin Modern Roman #qty("9", "pt") font size. Single line captions are centered, multi-line captions justified. Place tables/figures in text as close to the reference as possible.

References to tables and figures should be capitalized, e.g. see @fig:example and @tab:example. Figures and tables may extend on a single column to a maximum width of #qty("8.1", "cm") and across both columns to a maximum width of #qty("17.0", "cm").


#figure(
  square(width: 7.8cm),
  placement: auto,
  caption: "Figure captions should be placed below the figure.",
)<fig:example>

#figure(
  table(
    columns: 2,
    align: (left, left),

    table.header([String value], [Numeric value]),
    [Value1], [2026],
  ),
  placement: auto,
  caption: "Table captions should be placed above the table.",
)<tab:example>


= Equations

Equations should not appear in the main body of the text, should be placed on separate lines and should be numbered.
The number should be on the right side, in parentheses, as in @eq:relativity.

$ E = m c^(2) $ <eq:relativity>


= Citations

All bibliographical references should be listed at the end, inside a section named #quote[References], numbered and in order of appearance. All references listed should be cited in the text.

The #link("https://ieee-dataport.org/sites/default/files/analysis/27/IEEE%20Citation%20Guidelines.pdf", [IEEE Citation Guidelines]) citation style is used for these proceedings. When referring to a document, type the number in square brackets @Author:00, or for a range @Author:00 @Someone:10 @Someone:04.

Standard abbreviations should be used in your bibliography. When the following words appear in the references, please abbreviate them:

- Proceedings #sym.arrow Proc.
- Record #sym.arrow Rec.
- Symposium #sym.arrow Symp.
- Technical Digest #sym.arrow Tech. Dig.
- Technical Paper #sym.arrow Tech. Paper
- First #sym.arrow 1#super[st]
- Second #sym.arrow 2#super[nd]
- Third #sym.arrow 3#super[rd]
- Fourth/nth #sym.arrow 4#super[th]/n#super[th].


The LaTeX template uses the `biblatex` package with biber backend for bibliography management.


= Inspecting the PDF File
Carefully inspect your PDF file before submission to be sure that the PDF conversion was done properly and that there are no error messages when you open the PDF file. Common problems are: missing or incorrectly converted symbols especially mathematical symbols, failure of figures to reproduce, and incomplete legends in figures. Identification and correction of these problems is the responsibility of the authors. For paper indexing reasons it is essential that the generated PDF is neither encrypted nor password protected.

= Acknowledgments
In this section, you can acknowledge any support given which is not covered by the author contribution or funding sections. This may include administrative and technical support, or donations in kind (e.g., materials used for experiments).
