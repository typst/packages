#import "@preview/triple-aaai:0.8.0": aaai, appendix
#import "/logo.typ": LaTeX, LaTeXe as LaTeX2e, TeX

#let authors = (
  (name: "Firstname1 Lastname1",
   affl: "skoltech",
   email: "author@example.org",
   equal: true),
  (name: "Firstname2 Lastname2", affl: ("airi", "skoltech"), equal: true),
)

#let affilations = (
  airi: (institution: "AIRI", location: "Moscow", country: "Russia"),
  skoltech: (
    department: "AI Center",
    institution: "Skoltech",
    location: "Moscow",
    country: "Russia",
  ),
)

#show: aaai.with(
  title: [
    AAAI Press Anonymous Submission\ Instructions for Authors Using #LaTeX
  ],
  authors: (authors, affilations),
  keywords: ("aaai", ),
  abstract: [
    AAAI creates proceedings, working notes, and technical reports directly
    from electronic source furnished by the authors. To ensure that all papers
    in the publication have a uniform appearance, authors must adhere to the
    following instructions.
  ],
  bibliography: bibliography("main.bib", full: true),
  accepted: false,
  numbering: none,
)

#show raw.where(block: true): it => block(spacing: 1em, {
  set text(size: 7pt)
  it
})

= Preparing an Anonymous Submission

This document details the formatting requirements for anonymous submissions.
The requirements are the same as for camera ready papers but with a few notable
differences:

- Anonymous submissions must not include the author names and affiliations.
  Write "Anonymous Submission" as the "sole author" and leave the
  affiliations empty.
- The PDF document's metadata should be cleared with a metadata-cleaning tool
  before submitting it. This is to prevent leaked information from revealing
  your identity.
- References must be anonymized whenever the reader can infer that they are to
  the authors' previous work.
- AAAI's copyright notice should not be included as a footer in the first page.
- Only the PDF version is required at this stage. No source versions will be
  requested, nor any copyright transfer form.

You can achieve all of the above by enabling the `submission` option when
loading the `aaai2026` package:

```tex
  \documentclass[letterpaper]{article}
  \usepackage[submission]{aaai2026}
```

The remainder of this document are the original camera- ready instructions. Any
contradiction of the above points ought to be ignored while preparing anonymous
submissions.

= Camera-Ready Guidelines

Congratulations on having a paper selected for inclusion in an AAAI Press
proceedings or technical report! This document details the requirements
necessary to get your accepted paper published using PDF#LaTeX. If you are
using Microsoft Word, instructions are provided in a different document. AAAI
Press does not support any other formatting software.

The instructions herein are provided as a general guide for experienced #LaTeX
users. If you do not know how to use #LaTeX, please obtain assistance locally.
AAAI cannot provide you with support and the accompanying style files are *not*
guaranteed to work. If the results you obtain are not in accordance with the
specifications you received, you must correct your source file to achieve the
correct result.

These instructions are generic. Consequently, they do not include specific
dates, page charges, and so forth. Please consult your specific written
conference instructions for details regarding your submission. Please review
the entire document for specific instructions that might apply to your
particular situation. All authors must comply with the following:

- You must use the 2026 AAAI Press #LaTeX style file and the `aaai2026.bst`
  bibliography style files, which are located in the 2026 AAAI Author Kit
  (`aaai2026.sty`, `aaai2026.bst`).
- You must complete, sign, and return by the deadline the AAAI copyright form
  (unless directed by AAAI Press to use the AAAI Distribution License instead).
- You must read and format your paper source and PDF according to the
  formatting instructions for authors.
- You must submit your electronic files and abstract using our electronic
  submission form *on time*.
- You must pay any required page or formatting charges to AAAI Press so that
  they are received by the deadline.
- You must check your paper before submitting it, ensuring that it compiles
  without error, and complies with the guidelines found in the AAAI Author Kit.

= Copyright

All papers submitted for publication by AAAI Press must be accompanied by a
valid signed copyright form. They must also contain the AAAI copyright notice
at the bottom of the first page of the paper. There are no exceptions to these
requirements. If you fail to provide us with a signed copyright form or disable
the copyright notice, we will be unable to publish your paper. There are *no
exceptions* to this policy. You will find a PDF version of the AAAI copyright
form in the AAAI AuthorKit. Please see the specific instructions for your
conference for submission details.

= Formatting Requirements in Brief

We need source and PDF files that can be used in a variety of ways and can be
output on a variety of devices. The design and appearance of the paper is
strictly governed by the aaai style file (`aaai2026.sty`). *You must not make any
changes to the aaai style file, nor use any commands, packages, style files, or
macros within your own paper that alter that design, including, but not limited
to spacing, floats, margins, fonts, font size, and appearance.* AAAI imposes
requirements on your source and PDF files that must be followed. Most of these
requirements are based on our efforts to standardize conference manuscript
properties and layout. All papers submitted to AAAI for publication will be
recompiled for standardization purposes. Consequently, every paper submission
must comply with the following requirements:

- Your .tex file must compile in PDF#LaTeX --- (you may not include .ps or .eps
  figure files.)
- All fonts must be embedded in the PDF file --- including your figures.
- Modifications to the style file, whether directly or via commands in your
  document may not ever be made, most especially when made in an effort to
  avoid extra page charges or make your paper fit in a specific number of
  pages.
- No type 3 fonts may be used (even in illustrations).
- You may not alter the spacing above and below captions, figures, headings,
  and subheadings.
- You may not alter the font sizes of text elements, footnotes, heading
  elements, captions, or title information (for references and mathematics,
  please see the limited exceptions provided herein).
- You may not alter the line spacing of text.
- Your title must follow Title Case capitalization rules (not sentence case).
- #LaTeX documents must use the Times or Nimbus font package (you may not use
  Computer Modern for the text of your paper).
- No #LaTeX 209 documents may be used or submitted.
- Your source must not require use of fonts for non-Roman alphabets within the
  text itself. If your paper includes symbols in other languages (such as, but
  not limited to, Arabic, Chinese, Hebrew, Japanese, Thai, Russian and other
  Cyrillic languages), you must restrict their use to bit-mapped figures. Fonts
  that require non-English language support (CID and Identity-H) must be
  converted to outlines or 300 dpi bitmap or removed from the document (even if
  they are in a graphics file embedded in the document).
- Two-column format in AAAI style is required for all papers.
- The paper size for final submission must be US letter without exception.
- The source file must exactly match the PDF.
- The document margins may not be exceeded (no overfull boxes).
- The number of pages and the file size must be as specified for your event.
- No document may be password protected.
- Neither the PDFs nor the source may contain any embedded links or bookmarks
  (no hyperref or navigator packages).
- Your source and PDF must not have any page numbers, footers, or headers (no
  pagestyle commands).
- Your PDF must be compatible with Acrobat 5 or higher.
- Your #LaTeX source file (excluding references) must consist of a *single*
  file (use of the "input" command is not allowed.
- Your graphics must be sized appropriately outside of #LaTeX (do not use the
  "clip" or "trim" command).

If you do not follow these requirements, your paper will be returned to you to
correct the deficiencies.

= What Files to Submit

You must submit the following items to ensure that your paper is published:

- A fully-compliant PDF file.
- Your #LaTeX source file submitted as a *single* .tex file (do not use the
  "input" command to include sections of your paper --- every section must be
  in the single source file). (The only allowable exception is .bib file, which
  should be included separately).
- The bibliography (.bib) file(s).
- Your source must compile on our system, which includes only standard #LaTeX
  2020 TeXLive support files.
- Only the graphics files used in compiling paper.
- The #LaTeX\-generated files (e.g. .aux, .bbl file, PDF, etc.).

Your #LaTeX source will be reviewed and recompiled on our system (if it does
not compile, your paper will be returned to you. *Do not submit your source in
multiple text files.* Your single #LaTeX source file must include all your
text, your bibliography (formatted using `aaai2026.bst`), and any custom macros.

Your files should work without any supporting files (other than the program
itself) on any computer with a standard #LaTeX distribution.

*Do not send files that are not actually used in the paper.* Avoid including
any files not needed for compiling your paper, including, for example, this
instructions file, unused graphics files, style files, additional material sent
for the purpose of the paper review, intermediate build files and so forth.

*Obsolete style files.* The commands for some common packages (such as some
used for algorithms), may have changed. Please be certain that you are not
compiling your paper using old or obsolete style files.

*Final Archive.* Place your source files in a single archive which should be
compressed using .zip. The final file size may not exceed 10 MB. Name your
source file with the last (family) name of the first author, even if that is
not you.

= Using #LaTeX to Format Your Paper

The latest version of the AAAI style file is available on AAAI's website.
Download this file and place it in the #TeX search path. Placing it in the same
directory as the paper should also work. You must download the latest version
of the complete AAAI Author Kit so that you will have the latest instruction
set and style file.

== Document Preamble

In the #LaTeX source for your paper, you *must* place the following lines as
shown in the example in this subsection. This command set-up is for three
authors. Add or subtract author and address lines as necessary, and uncomment
the portions that apply to you. In most instances, this is all you need to do
to format your paper in the Times font. The helvet package will cause Helvetica
to be used for sans serif. These files are part of the PSNFSS2e package, which
is freely available from many Internet sites (and is often part of a standard
installation).

Leave the setcounter for section number depth commented out and set at 0 unless
you want to add section numbers to your paper. If you do add section numbers,
you must uncomment this line and change the number to 1 (for section numbers),
or 2 (for section and subsection numbers). The style file will not work
properly with numbering of subsubsections, so do not use a number higher than
2.

=== The Following Must Appear in Your Preamble
```tex
  \documentclass[letterpaper]{article}
  % DO NOT CHANGE THIS
  % DO NOT CHANGE THESE PACKAGES
  \usepackage[submission]{aaai2026}
  \usepackage{times} % DO NOT CHANGE THIS
  \usepackage{helvet} % DO NOT CHANGE THIS
  \usepackage{courier} % DO NOT CHANGE THIS
  \usepackage[hyphens]{url}
  \usepackage{graphicx} % DO NOT CHANGE THIS
  \urlstyle{rm} % DO NOT CHANGE THIS
  \def\UrlFont{\rm} % DO NOT CHANGE THIS
  \usepackage{graphicx}  % DO NOT CHANGE THIS
  \usepackage{natbib}  % DO NOT CHANGE THIS
  \usepackage{caption}  % DO NOT CHANGE THIS
  \frenchspacing % DO NOT CHANGE THIS
  % DO NOT CHANGE THE PAGE SIZE
  \setlength{\pdfpagewidth}{8.5in}
  \setlength{\pdfpageheight}{11in}
  %
  % Keep the \pdfinfo as shown here.
  % Do not add /Title and /Author tags.
  \pdfinfo{
  /TemplateVersion (2026.1)
  }
```

== Preparing Your Paper

After the preamble above, you should prepare your paper as follows:

```tex
  \begin{document}
  \maketitle
  \begin{abstract}
  %...
  \end{abstract}
```

You should then continue with the body of your paper. Your paper must conclude
with the references, which should be inserted as follows:

```tex
  % References and End of Paper
  % Place these lines at the end of the paper.
  \bibliography{Bibliography-File}
  \end{document}
```

== Commands and Packages That May Not Be Used

#figure(
  caption: [Commands that must not be used],
  placement: top,
  scope: "parent",
  table(
    columns: (1fr, 1fr, 1fr, 1fr),
    align: left,
    stroke: none,
    `\abovecaption`, `\abovedisplay`,    `\addevensidemargin`, `\addsidemargin`,
    `\addtolength`,  `\baselinestretch`, `\belowcaption`,      `\belowdisplay`,
    `\break`,        `\clearpage`,       `\clip`,              `\columnsep`,
    `\float`,        `\input`,           `\input`,             `\linespread`,
    `\newpage`,      `\pagebreak`,       `\renewcommand`,      `\setlength`,
    `\textheight`,   `\tiny`,            `\topmargin`,         `\trim`,
    `\vskip{-`,      `\vspace{-`,
  )) <table1>

#figure(
  caption: [LaTeX style packages that must not be used.],
  placement: top,
  table(
    columns: (1fr, 1fr, 1fr, 1fr),
    align: left,
    stroke: none,
    `authblk`,   `babel`,      `cjk`,      `dvips`,
    `epsf`,      `epsfig`,     `euler`,    `float`,
    `fullpage`,  `geometry`,   `graphics`, `hyperref`,
    `layout`,    `linespread`, `lmodern`,  `maltepaper`,
    `navigator`, `pdfcomment`, `pgfplots`, `psfig`,
    `pstricks`,  `t1enc`,      `titlesec`, `tocbind`,
    `ulem`,
  )) <table2>

There are a number of packages, commands, scripts, and macros that are
incompatable with `aaai2026.sty`. The common ones are listed in tables
#ref(<table1>, supplement: none) and #ref(<table2>, supplement: none).
Generally, if a command, package, script, or macro alters floats, margins,
fonts, sizing, linespacing, or the presentation of the references and
citations, it is unacceptable. Note that negative vskip and vspace may not be
used except in certain rare occurances, and may never be used around tables,
figures, captions, sections, subsections, subsubsections, or references.

== Page Breaks

For your final camera ready copy, you must not use any page break commands.
References must flow directly after the text without breaks. Note that some
conferences require references to be on a separate page during the review
process. AAAI Press, however, does not require this condition for the final
paper.

== Paper Size, Margins, and Column Width

Papers must be formatted to print in two-column format on 8.5 x 11 inch US
letter-sized paper. The margins must be exactly as follows:

- Top margin: 1.25 inches (first page), .75 inches (others)
- Left margin: .75 inches
- Right margin: .75 inches
- Bottom margin: 1.25 inches

The default paper size in most installations of #LaTeX is A4. However, because
we require that your electronic paper be formatted in US letter size, the
preamble we have provided includes commands that alter the default to US letter
size. Please note that using any other package to alter page size (such as, but
not limited to the Geometry package) will result in your final paper being
returned to you for correction.

=== Column Width and Margins
To ensure maximum readability, your paper must include two columns. Each column
should be 3.3 inches wide (slightly more than 3.25 inches), with a .375 inch
(.952 cm) gutter of white space between the two columns. The `aaai2026.sty` file
will automatically create these columns for you.

== Overlength Papers

If your paper is too long and you resort to formatting tricks to make it fit,
it is quite likely that it will be returned to you. The best way to retain
readability if the paper is overlength is to cut text, figures, or tables.
There are a few acceptable ways to reduce paper size that don't affect
readability. First, turn on `\frenchspacing`, which will reduce the space after
periods. Next, move all your figures and tables to the top of the page.
Consider removing less important portions of a figure. If you use `\centering`
instead of `\begin{center}` in your figure environment, you can also buy some
space. For mathematical environments, you may reduce fontsize *but not below
6.5 point*.

Commands that alter page layout are forbidden. These include `\columnsep`,
`\float`, `\topmargin`, `\topskip`, `\textheight`, `\textwidth`,
`\oddsidemargin`, and `\evensizemargin` (this list is not exhaustive). If you
alter page layout, you will be required to pay the page fee. Other commands
that are questionable and may cause your paper to be rejected include
`\parindent`, and `\parskip`. Commands that alter the space between sections
are forbidden. The title sec package is not allowed. Regardless of the above,
if your paper is obviously "squeezed" it is not going to to be accepted.
Options for reducing the length of a paper include reducing the size of your
graphics, cutting text, or paying the extra page charge (if it is offered).

== Type Font and Size

Your paper must be formatted in Times Roman or Nimbus. We will not accept
papers formatted using Computer Modern or Palatino or some other font as the
text or heading typeface. Sans serif, when used, should be Courier. Use Symbol
or Lucida or Computer Modern for _mathematics only_.

Do not use type 3 fonts for any portion of your paper, including graphics. Type
3 bitmapped fonts are designed for fixed resolution printers. Most print at 300
dpi even if the printer resolution is 1200 dpi or higher. They also often cause
high resolution imagesetter devices to crash. Consequently, AAAI will not
accept electronic files containing obsolete type 3 fonts. Files containing
those fonts (even in graphics) will be rejected. (Authors using blackboard
symbols must avoid packages that use type 3 fonts.)

Fortunately, there are effective workarounds that will prevent your file from
embedding type 3 bitmapped fonts. The easiest workaround is to use the required
times, helvet, and courier packages with #LaTeX2e. (Note that papers formatted
in this way will still use Computer Modern for the mathematics. To make the
math look good, you'll either have to use Symbol or Lucida, or you will need to
install type 1 Computer Modern fonts --- for more on these fonts, see the
section ``Obtaining Type 1 Computer Modern.")

If you are unsure if your paper contains type 3 fonts, view the PDF in Acrobat
Reader. The Properties/Fonts window will display the font name, font type, and
encoding properties of all the fonts in the document. If you are unsure if your
graphics contain type 3 fonts (and they are PostScript or encapsulated
PostScript documents), create PDF versions of them, and consult the properties
window in Acrobat Reader.

The default size for your type must be ten-point with twelve-point leading
(line spacing). Start all pages (except the first) directly under the top
margin. (See the next section for instructions on formatting the title page.)
Indent ten points when beginning a new paragraph, unless the paragraph begins
directly below a heading or subheading.

=== Obtaining Type 1 Computer Modern for #LaTeX.
If you use Computer Modern for the mathematics in your paper (you cannot use it
for the text) you may need to download type 1 Computer fonts. They are
available without charge from the American Mathematical Society:
#link("http://www.ams.org/tex/type1-fonts.html").

=== Nonroman Fonts.
If your paper includes symbols in other languages (such as, but not limited to,
Arabic, Chinese, Hebrew, Japanese, Thai, Russian and other Cyrillic languages),
you must restrict their use to bit-mapped figures.

== Title and Authors

Your title must appear centered over both text columns in sixteen-point bold
type (twenty-four point leading). The title must be written in Title Case
according to the Chicago Manual of Style rules. The rules are a bit involved,
but in general verbs (including short verbs like be, is, using, and go), nouns,
adverbs, adjectives, and pronouns should be capitalized, (including both words
in hyphenated terms), while articles, conjunctions, and prepositions are lower
case unless they directly follow a colon or long dash. You can use the online
tool #link("https://titlecaseconverter.com/") to double-check the proper
capitalization (select the "Chicago" style and mark the "Show explanations"
checkbox).

Author's names should appear below the title of the paper, centered in
twelve-point type (with fifteen point leading), along with affiliation(s) and
complete address(es) (including electronic mail address if available) in
nine-point roman type (the twelve point leading). You should begin the
two-column format when you come to the abstract.

=== Formatting Author Information.
Author information has to be set according to the following specification
depending if you have one or more than one affiliation. You may not use a table
nor may you employ the `authorblk` package. For one or several authors from the
same institution, please separate them with commas and write all affiliation
directly below (one affiliation per line) using the macros `\author` and
`\affiliations`:

```tex
\author{
    Author 1, ..., Author n\\
}
\affiliations {
    Address line\\
    ... \\
    Address line\\
}
```

For authors from different institutions, use `\textsuperscript{\rm x}` to match
authors and affiliations. Notice that there should not be any spaces between
the author name (or comma following it) and the superscript.

```tex
\author{
    AuthorOne,\equalcontrib
    \textsuperscript{\rm 1,\rm 2}
    AuthorTwo,\equalcontrib
    \textsuperscript{\rm 2}
    AuthorThree,\textsuperscript{\rm 3}\\
    AuthorFour,\textsuperscript{\rm 4}
    AuthorFive \textsuperscript{\rm 5}}
}
\affiliations {
    \textsuperscript{\rm 1}AffiliationOne,\\
    \textsuperscript{\rm 2}AffiliationTwo,\\
    \textsuperscript{\rm 3}AffiliationThree,\\
    \textsuperscript{\rm 4}AffiliationFour,\\
    \textsuperscript{\rm 5}AffiliationFive\\
    \{email, email\}@affiliation.com,
    email@affiliation.com,
    email@affiliation.com,
    email@affiliation.com
}
```

You can indicate that some authors contributed equally using the
`\equalcontrib` command. This will add a marker after the author names and a
footnote on the first page.

Note that you may want to  break the author list for better visualization. You
can achieve this using a simple line break (`\\`).

== #LaTeX Copyright Notice

The copyright notice automatically appears if you use `aaai2026.sty`. It has been
hardcoded and may not be disabled.

== Credits

Any credits to a sponsoring agency should appear in the acknowledgments
section, unless the agency requires different placement. If it is necessary to
include this information on the front page, use `\thanks` in either
the `\author` or `\title` commands. For example:

```tex
  \title{Very Important Results in AI
    \thanks{This work is supported
      by everybody.}}
```

Multiple `\thanks` commands can be given. Each will result in a separate
footnote indication in the author or title with the corresponding text at the
botton of the first column of the document. Note that the `\thanks` command is
fragile. You will need to use `\protect`.

Please do not include `\pubnote` commands in your document.

== Abstract

Follow the example commands in this document for creation of your abstract. The
command `\begin{abstract}` will automatically indent the text block. Please do
not indent it further. Do not include references in your abstract!

== Page Numbers

Do not print any page numbers on your paper. The use of `\pagestyle` is
forbidden.

== Text

The main body of the paper must be formatted in black, ten-point Times Roman
with twelve-point leading (line spacing). You may not reduce font size or the
linespacing. Commands that alter font size or line spacing (including, but not
limited to baselinestretch, baselineshift, linespread, and others) are
expressly forbidden. In addition, you may not use color in the text.

== Citations

Citations within the text should include the author's last name and year, for
example (Newell 1980). Append lower-case letters to the year in cases of
ambiguity. Multiple authors should be treated as follows: (Feigenbaum and
Engelmore 1988) or (Ford, Hayes, and Glymour 1992). In the case of four or more
authors, list only the first author, followed by et al. (Ford et al. 1997).

== Extracts

Long quotations and extracts should be indented ten points from the left and
right margins.

#quote(block: true)[
This is an example of an extract or quotation. Note the indent on both sides.
Quotation marks are not necessary if you offset the text in a block like this,
and properly identify and cite the quotation in the text.
]

== Footnotes

Use footnotes judiciously, taking into account that they interrupt the reading
of the text. When required, they should be consecutively numbered throughout
with superscript Arabic numbers. Footnotes should appear at the bottom of the
page, separated from the text by a blank line space and a thin, half-point
rule.

== Headings and Sections

When necessary, headings should be used to separate major sections of your
paper. Remember, you are writing a short paper, not a lengthy book! An
overabundance of headings will tend to make your paper look more like an
outline than a paper. The aaai2026.sty package will create headings for you. Do
not alter their size nor their spacing above or below.

=== Section Numbers.
The use of section numbers in AAAI Press papers is optional. To use section
numbers in #LaTeX, uncomment the setcounter line in your document preamble and
change the 0 to a 1. Section numbers should not be used in short poster papers
and/or extended abstracts.

=== Section Headings.
Sections should be arranged and headed as follows:

+ Main content sections
+ Appendices (optional)
+ Ethical Statement (optional, unnumbered)
+ Acknowledgements (optional, unnumbered)
+ References (unnumbered)

=== Appendices.
Any appendices must appear after the main content. If your main sections are
numbered, appendix sections must use letters instead of arabic numerals. In
#LaTeX you can use the `\appendix` command to achieve this effect and then use
`\section{Heading}` normally for your appendix sections.

=== Ethical Statement.
You can write a statement about the potential ethical impact of your work,
including its broad societal implications, both positive and negative. If
included, such statement must be written in an unnumbered section titled
_Ethical Statement_.

=== Acknowledgments.
The acknowledgments section, if included, appears right before the references
and is headed "Acknowledgments". It must not be numbered even if other sections
are (use `\section*{Acknowledgements}` in #LaTeX). This section includes
acknowledgments of help from associates and colleagues, credits to sponsoring
agencies, financial support, and permission to publish. Please acknowledge
other contributors, grant support, and so forth, in this section. Do not put
acknowledgments in a footnote on the first page. If your grant agency requires
acknowledgment of the grant on page 1, limit the footnote to the required
statement, and put the remaining acknowledgments at the back. Please try to
limit acknowledgments to no more than three sentences.

=== References.
The references section should be labeled "References" and must appear at the
very end of the paper (don't end the paper with references, and then put a
figure by itself on the last page). A sample list of references is given later
on in these instructions. Please use a consistent format for references. Poorly
prepared or sloppy references reflect badly on the quality of your paper and
your research. Please prepare complete and accurate citations.

== Illustrations and  Figures

#figure(
  caption: [
    Using the trim and clip commands produces fragile layers that can result in
    disasters (like this one from an actual paper) when the color space is
    corrected or the PDF combined with others for the final proceedings. Crop
    your figures properly in a graphics program -- not in #LaTeX.
  ],
  placement: top,
  image("figure1.svgz", width: 100%)) <fig1>

#figure(
  caption: [
    Adjusting the bounding box instead of actually removing the unwanted data
    resulted multiple layers in this paper. It also needlessly increased the
    PDF size. In this case, the size of the unwanted layer doubled the paper's
    size, and produced the following surprising results in final production.
    Crop your figures properly in a graphics program. Don't just alter the
    bounding box.
  ],
  placement: top,
  scope: "parent",
  image("figure2.svgz")) <fig2>

// Using the \centering command instead of \begin{center} ... \end{center} will
// save space Positioning your figure at the top of the page will save space
// and make the paper more readable Using 0.95\columnwidth in conjunction with
// the

Your paper must compile in PDF#LaTeX. Consequently, all your figures must be
.jpg, .png, or .pdf. You may not use the .gif (the resolution is too low), .ps,
or .eps file format for your figures.

Figures, drawings, tables, and photographs should be placed throughout the
paper on the page (or the subsequent page) where they are first discussed. Do
not group them together at the end of the paper. If placed at the top of the
paper, illustrations may run across both columns. Figures must not invade the
top, bottom, or side margin areas. Figures must be inserted using the
`\usepackage{graphicx}`. Number figures sequentially, for example, figure 1,
and so on. Do not use minipage to group figures.

If you normally create your figures using `pgfplots`, please create the figures
first, and then import them as pdfs with proper bounding boxes, as the bounding
and trim boxes created by pfgplots are fragile and not valid.

When you include your figures, you must crop them *outside* of #LaTeX. The
command `\includegraphics*[clip=true, viewport 0 0 10 10]{...}` might result in
a PDF that looks great, but the image is *not really cropped*. The full image
can reappear (and obscure whatever it is overlapping) when page numbers are
applied or color space is standardized. @fig1 and @fig2 display some unwanted
results that often occur.

If your paper includes illustrations that are not compatible with PDF#TeX (such
as .eps or .ps documents), you will need to convert them. The epstopdf package
will usually work for eps files. You will need to convert your ps files to PDF
in either case.

=== Figure Captions.
The illustration number and caption must appear _under_ the illustration.
Labels and other text with the actual illustration must be at least nine-point
type. However, the font and size of figure captions must be 10 point roman. Do
not make them smaller, bold, or italic. (Individual words may be italicized if
the context requires differentiation.)

== Tables

Tables should be presented in 10 point roman type. If necessary, they may be
altered to 9 point type. You may not use any commands that further reduce point
size below nine points. Tables that do not fit in a single column must be
placed across double columns. If your table won't fit within the margins even
when spanning both columns, you must split it. Do not use minipage to group
tables.

=== Table Captions.
The number and caption for your table must appear _under_ (not above) the
table. Additionally, the font and size of table captions must be 10 point roman
and must be placed beneath the figure. Do not make them smaller, bold, or
italic. (Individual words may be italicized if the context requires
differentiation.)

=== Low-Resolution Bitmaps.
You may not use low-resolution (such as 72 dpi) screen-dumps and GIF files ---
these files contain so few pixels that they are always blurry, and illegible
when printed. If they are color, they will become an indecipherable mess when
converted to black and white. This is always the case with gif files, which
should never be used. The resolution of screen dumps can be increased by
reducing the print size of the original file while retaining the same number of
pixels. You can also enlarge files by manipulating them in software such as
PhotoShop. Your figures should be 300 dpi when incorporated into your document.

=== #LaTeX Overflow.
#LaTeX users please beware: #LaTeX will sometimes put portions of the figure or
table or an equation in the margin. If this happens, you need to make the
figure or table span both columns. If absolutely necessary, you may reduce the
figure, or reformat the equation, or reconfigure the table. *Check your log
file!* You must fix any overflow into the margin (that means no overfull boxes
in #LaTeX). *Nothing is permitted to intrude into the margin or gutter.*

=== Using Color.
Use of color is restricted to figures only. It must be WACG 2.0 compliant.
(That is, the contrast ratio must be greater than 4.5:1 no matter the font
size.) It must be CMYK, NOT RGB. It may never be used for any portion of the
text of your paper. The archival version of your paper will be printed in black
and white and grayscale. The web version must be readable by persons with
disabilities. Consequently, because conversion to grayscale can cause
undesirable effects (red changes to black, yellow can disappear, and so forth),
we strongly suggest you avoid placing color figures in your document. If you do
include color figures, you must (1) use the CMYK (not RGB) colorspace and (2)
be mindful of readers who may happen to have trouble distinguishing colors.
Your paper must be decipherable without using color for distinction.

=== Drawings.
We suggest you use computer drawing software (such as Adobe Illustrator or, (if
unavoidable), the drawing tools in Microsoft Word) to create your
illustrations. Do not use Microsoft Publisher. These illustrations will look
best if all line widths are uniform (half- to two-point in size), and you do
not create labels over shaded areas. Shading should be 133 lines per inch if
possible. Use Times Roman or Helvetica for all figure call-outs. *Do not use
hairline width lines* --- be sure that the stroke width of all lines is at
least .5 pt. Zero point lines will print on a laser printer, but will
completely disappear on the high-resolution devices used by our printers.

=== Photographs and Images.
Photographs and other images should be in grayscale (color photographs will not
reproduce well; for example, red tones will reproduce as black, yellow may turn
to white, and so forth) and set to a minimum of 300 dpi. Do not prescreen
images.

=== Resizing Graphics.
Resize your graphics *before* you include them with #LaTeX. You may *not* use
trim or clip options as part of your `\includegraphics` command. Resize the
media box of your PDF using a graphics program instead.

=== Fonts in Your Illustrations.
You must embed all fonts in your graphics before including them in your LaTeX
document.

=== Algorithms.
Algorithms and/or programs are a special kind of figures. Like all
illustrations, they should appear floated to the top (preferably) or bottom of
the page. However, their caption should appear in the header, left-justified
and enclosed between horizontal lines, as shown in @algorithm. The
algorithm body should be terminated with another horizontal line. It is up to
the authors to decide whether to show line numbers or not, how to format
comments, etc.

In #LaTeX algorithms may be typeset using the `algorithm` and `algorithmic`
packages, but you can also use one of the many other packages for the task.

#figure(
  caption: [Example algorithm],
  kind: "algorithm",
  supplement: [Algorithm],
  ```tex
    \textbf{Input}: Your algorithm's input\\
    \textbf{Parameter}: Optional parameters\\
    \textbf{Output}: Your algorithm's output
    % [1] enables line numbers.
    \begin{algorithmic}[1]
    \STATE Let $t=0$.
    \WHILE{condition}
    \STATE Do some action.
    \IF {conditional}
    \STATE Perform task A.
    \ELSE
    \STATE Perform task B.
    \ENDIF
    \ENDWHILE
    \STATE \textbf{return} solution
  ```) <algorithm>

=== Listings.
Listings are much like algorithms and programs. They should also appear floated
to the top (preferably) or bottom of the page. Listing captions should appear
in the header, left-justified and enclosed between horizontal lines as shown in
@listing. Terminate the body with another horizontal line and avoid any
background color. Line numbers, if included, must appear within the text
column.

#figure(
  caption: [Example listing `quicksort.hs`],
  ```haskell
  quicksort :: Ord a => [a] -> [a]
  quicksort []     = []
  quicksort (p:xs) = quicksort lesser
                 ++ [p]
                 ++ quicksort greater
          where
                  lesser  = filter (< p) xs
                  greater = filter (>= p) xs
  ```) <listing>

== References

The AAAI style includes a set of definitions for use in formatting references
with BibTeX. These definitions make the bibliography style fairly close to the
ones  specified in the Reference Examples appendix below. To use these
definitions, you also need the BibTeX style file `aaai2026.bst`, available in the
AAAI Author Kit on the AAAI web site. Then, at the end of your paper but before
`\end{document}`, you need to put the following lines:

```tex
  \bibliography{bibfile1,bibfile2,...}
```

Please note that the `aaai2026.sty` class already sets the bibliographystyle for
you, so you do not have to place any `\bibliographystyle` command in the
document yourselves. The `aaai2026.sty` file is incompatible with the `hyperref`
and `navigator` packages. If you use either, your references will be garbled
and your paper will be returned to you.

References may be the same size as surrounding text. However, in this section
(only), you may reduce the size to `\small` if your paper exceeds the allowable
number of pages. Making it any smaller than 9 point with 10 point linespacing,
however, is not allowed. A more precise and exact method of reducing the size
of your references minimally is by means of the following command:

```tex
  \fontsize{9.8pt}{10.8pt}
  \selectfont
```

You must reduce the size equally for both font size and line spacing, and may
not reduce the size beyond `{9.0pt}{10.0pt}`.

The list of files in the `\bibliography` command should be the names of your
Bib#TeX source files (that is, the .bib files referenced in your paper).

The following commands are available for your use in citing references:

- `\cite`: Cites the given reference(s) with a full citation, for example
  @c:83 or @hcr:83.
- `\shortcite`: Cites just the year in parentheses, for example
  (#cite(<c:83>, form: "year")).
- `\citeauthor`: Cites just the author name(s), for example
  #cite(<hcr:83>, form: "author").
- `\citeyear`: Cites just the date, for example #cite(<c:83>, form: "year").

You may also use any of the `natbib` citation commands.

= Proofreading Your PDF

Please check all the pages of your PDF file. The most commonly forgotten
element is the acknowledgements --- especially the correct grant number.
Authors also commonly forget to add the metadata to the source, use the wrong
reference style file, or don't follow the capitalization rules or comma
placement for their author-title information properly. A final common problem
is text (expecially equations) that runs into the margin. You will need to fix
these common errors before submitting your file.

= Improperly Formatted Files

In the past, AAAI has corrected improperly formatted files submitted by the
authors. Unfortunately, this has become an increasingly burdensome expense that
we can no longer absorb). Consequently, if your file is improperly formatted,
it will be returned to you for correction.

= Naming Your Electronic File

We require that you name your #LaTeX source file with the last name (family
name) of the first author so that it can easily be differentiated from other
submissions. Complete file-naming instructions will be provided to you in the
submission instructions.

= Submitting Your Electronic Files to AAAI

Instructions on paper submittal will be provided to you in your acceptance letter.

= Inquiries

If you have any questions about the preparation or submission of your paper as
instructed in this document, please contact AAAI Press at the address given
below. If you have technical questions about implementation of the aaai style
file, please contact an expert at your site. We do not provide technical
support for #LaTeX or any other software package. To avoid problems, please
keep your paper simple, and do not incorporate complicated macros and style
files.

```tex
  \noindent AAAI Press\\
  1900 Embarcadero Road, Suite 101\\
  Palo Alto, California 94303-3310 USA\\
  \textit{Telephone:} (650) 328-3123\\
  \textit{E-mail:} See the submission
  instructions for your conference or event.
```

= Additional Resources

#LaTeX is a difficult program to master. If you've used that software, and this
document didn't help or some items were not explained clearly, we recommend you
read Michael Shell's excellent document (testflow doc.txt V1.0a 2002/08/13)
about obtaining correct PS/PDF output on #LaTeX systems. (It was written for
another purpose, but it has general application as well). It is available at
#link("https://www.ctan.org") in the tex-archive.

#show: appendix
= Reference Examples <reference_examples>

Formatted bibliographies should look like the following examples. You should
use Bib#TeX to generate the references. Missing fields are unacceptable when
compiling references, and usually indicate that you are using the wrong type of
entry (Bib#TeX class).

*Book with multiple authors.* Use the `@book` class.

#cite(<em:86>, form: "full")

*Journal and magazine articles.* Use the `@article` class.

#cite(<r:80>, form: "full")

#cite(<hcr:83>, form: "full")

*Proceedings paper published by a society, press or publisher.* Use the
`@inproceedings` class. You may
abbreviate the _booktitle_ field, but make sure that the conference edition is
clear.

#cite(<c:84>, form: "full")

#cite(<c:83>, form: "full")

*University technical report.* Use the `@techreport` class.

#cite(<r:86>, form: "full")

*Dissertation or thesis.* Use the `@phdthesis` class.

#cite(<c:79>, form: "full")

*Forthcoming publication.* Use the `@misc` class with a
`note="Forthcoming"` annotation.
```tex
  @misc(key,
    [...]
    note="Forthcoming",
  )
```
#cite(<c:21>, form: "full")

*ArXiv paper.* Fetch the BibTeX entry from the "Export
Bibtex Citation" link in the arXiv website. Notice it uses the `@misc` class
instead of the `@article` one, and that it includes the `eprint` and
`archivePrefix` keys.

```tex
  @misc(key,
    [...]
    eprint="xxxx.yyyy",
    archivePrefix="arXiv",
  )
```

#cite(<c:22>, form: "full")

*Website or online resource.* Use the `@misc` class. Add
the url in the `howpublished` field and the date of access in the `note` field:

```tex
  @misc(key,
    [...]
    howpublished="\url{http://...}",
    note="Accessed: YYYY-mm-dd",
  )
```

#cite(<c:23>, form: "full")

For the most up to date version of the AAAI reference style, please consult the
_AI Magazine_ Author Guidelines at
#link("https://aaai.org/ojs/index.php/aimagazine/about/submissions#authorGuidelines").

= Acknowledgments

AAAI is especially grateful to Peter Patel Schneider for his work in
implementing the original `aaai.sty` file, liberally using the ideas of other
style hackers, including Barbara Beeton. We also acknowledge with thanks the
work of George Ferguson for his guide to using the style and Bib#TeX files ---
which has been incorporated into this document --- and Hans Guesgen, who
provided several timely modifications, as well as the many others who have,
from time to time, sent in suggestions on improvements to the AAAI style. We
are especially grateful to Francisco Cruz, Marc Pujol-Gonzalez, and Mico
Loretan for the improvements to the Bib#TeX and #LaTeX files made in 2020.

The preparation of the #LaTeX and Bib#TeX files that implement these
instructions was supported by Schlumberger Palo Alto Research, AT&T Bell
Laboratories, Morgan Kaufmann Publishers, The Live Oak Press, LLC, and AAAI
Press. Bibliography style changes were added by Sunil Issar. `\pubnote` was
added by J. Scott Penberthy. George Ferguson added support for printing the
AAAI copyright slug. Additional changes to `aaai2026.sty` and `aaai2026.bst` have
been made by Francisco Cruz and Marc Pujol-Gonzalez.

Thank you for reading these instructions carefully. We look forward to
receiving your electronic files!
