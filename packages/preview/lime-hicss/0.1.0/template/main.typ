#import "@preview/lime-hicss:0.1.0": hicss

#show: hicss.with(
  // [HICSS]: Capitalize the first letter of nouns, pronouns, verbs, adjectives, and adverbs; do not capitalize articles, coordinate conjunctions, or prepositions (unless the title begins with such a word).
  title: [Detailed Formatting Guidelines for Preparing an Initial Manuscript with No Author Names: Paper May Not Exceed Ten Pages (Including References)],
  abstract: [
    The abstract is to be in fully-justified italicized text, at the top of the left-hand column as it is here, below the author information. Use the word “Abstract” as the title, in 12-point Times, boldface type, centered relative to the column, initially capitalized. The abstract is to be in 10-point, single-spaced type, and up to 150 words in length. Leave two blank lines after the abstract, and then begin the main text.
  ],
  authors: (
    (
      name: "Jennings Zhang",
      department: [FNNDSC],
      organization: [Boston Children's Hospital],
      location: [Boston, MA],
      email: "lime-hicss@sl.jennin.xyz"
    ),
    (
      name: "Rudolph Pienaar",
      department: [FNNDSC],
      organization: [Boston Children's Hospital],
      location: [Boston, MA],
      email: "dev@babyMRI.org"
    ),
  ),
  key-words: ("Include up to five keywords that capture the main topics or themes of the paper. Separate each keyword with a comma and space.",),
  bibliography: bibliography("bibliography.yml"),
)

= Introduction

All manuscripts must be in English. _Manuscripts must not exceed 10 pages, single-spaced and double-columned_.  This includes all graphs, tables, figures and references. These guidelines include complete descriptions of the fonts, spacing, and related information for producing your proceedings manuscripts. Please follow the steps outlined below when preparing your final manuscript. _Read the following carefully. The quality of the finished product largely depends upon receiving your cooperation and help at this particular stage of the publication process._

= Formatting your paper

All printed material, including text, illustrations, and charts, must be kept within a print area of 6-1/2 inches (16.51 cm) wide by 8-7/8 inches (22.51 cm) high. Do not write or print anything outside the print area. All text must be in a two-column format. Columns are to be 3 inches (7.85 cm) wide, with a 5.1/16 inch (0.81 cm) space between them. Text must be fully justified.

This formatting guideline provides the margins, placement, and print areas. If you hold it and your printed page up to the light, you can easily check your margins to see if your print area fits within the space allowed.

= Main title

The main title (on the first page) should begin 1-3/8 inches (3.49 cm) from the top edge of the page, centered, and in Times 14-point, boldface type. Capitalize the first letter of nouns, pronouns, verbs, adjectives, and adverbs; do not capitalize articles, coordinate conjunctions, or prepositions (unless the title begins with such a word). Leave two 12-point blank lines after the title.

= Author name(s) and affiliation(s)

Author names and affiliations must be included in the submitted Final Paper for Publication. Leave two 12-point blank lines after the author’s information. 

= Second and following pages

The second and following pages should begin 1.0 inch (2.54 cm) from the top edge. On all pages, the bottom margin should be 1-1/8 inches (2.86 cm) from the bottom edge of the page for 8.5 x 11-inch paper. (Letter-size paper)

= Type-style and fonts

Please note that _Times New Roman_ is the preferred font for the text of your paper. *If you must use another font*, the following are considered base fonts. You are encouraged to limit your font selections to Helvetica, Arial, and Symbol as needed. These fonts are automatically installed with the viewing software.

= Page Numbers

Please DO NOT include page numbers in your manuscript.

= Graphics/Images

All images must be embedded in your document or included with your submission as individual source files. The type of graphics you include will affect the quality and size of your paper on the electronic document disc. In general, the use of vector graphics such as those produced by most presentation and drawing packages can be used without concern and is encouraged.

- Resolution: 600 dpi
- Color Images: Bicubic Downsampling at 300dpi
- Compression for Color Images: JPEG/Medium Quality
- Grayscale Images: Bicubic Downsampling at 300dpi
- Compression for Grayscale Images: JPEG/Medium Quality
- Monochrome Images: Bicubic Downsampling at 600dpi
- Compression for Monochrome Images: CCITT Group 4

If your paper contains many large images they will be down-sampled to reduce their size during the conversion process.  However the automated process used will not always produce the best image, and you are encouraged to perform this yourself on an image by image basis. The use of bitmapped images such as those produced when a photograph is scanned requires significant storage space and must be used with care.

= Main text

Type your main text in 10-point Times, single-spaced. Do not use double-spacing. All paragraphs should be indented 1/4 inch (approximately 0.5 cm).  Be sure your text is fully justified—that is, flush left and flush right. Please do not place any additional blank lines between paragraphs.
#linebreak()
*Figure and table captions* should be 9-point boldface Helvetica (or a similar sans-serif font).  Callouts should be 9-point non-boldface Helvetica. Initially capitalize only the first word of each figure caption and table title. Figures and tables must be numbered separately. For example: "Figure 1. Database contexts", "Table 1. Input data". Figure captions are to be centered below the figures. Table titles are to be centered above the tables.

#figure(
  image("sample-image.jpg"),
  caption: "Sample figure with caption."
)

= Figure-order headings

For example, "1. Introduction", should be Times 12-point boldface, initially capitalized, flush left, with one 12-point blank line before, and one blank line after. Use a period (".") after the heading number, not a colon. 

== Second-order headings

As in this heading, they should be Times 11-point boldface, initially capitalized, flush left, with one blank line before, and one after. 

=== Third-order headings
Third-order headings, as in this paragraph, are discouraged. However, if you must use them, use 10-point Times, boldface, initially capitalized, flush left, followed by a period and your text on the same line. 

= Footnotes

Use footnotes sparingly (or not at all) and place them at the bottom of the column on the page on which they are referenced. Use Times 8-point type, single-spaced. To help your readers, avoid using footnotes altogether and include necessary peripheral observations in the text (within parentheses, if you prefer, as in this sentence). 

= References

References and in-text citation should be in line with the format recommended by the Publication Manual of the American Psychological Association (7th edition). The style and grammar guidelines are freely available and can be found at:
#link("https://apastyle.apa.org/style-grammar-guidelines")

List and number all bibliographical references in 9-point Times, single-spaced, and in an alphabetical order at the end of your paper. For example, #cite(label("Castells2010"), form: "prose") #cite(label("Allen1997"), form: "prose") and #cite(label("Bloomberg2018"), form: "prose") and #cite(label("Allen1997"), form: "prose").
