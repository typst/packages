/** 01.typ
 *
 * This is an example introdution in a multi-file Typst project.
 *
***/

#import "../preamble.typ": *

= Introduction <introduction>

This document template conforms to the Guide to Writing a Thesis
in Tampere University @kirjoitusohje2019 @thesiswriting2019. A
thesis typically includes at least the following parts:

- Title page
- Abstract in English (and in Finnish)
- Preface
- List of abbreviations and symbols
- (Lists of figures and tables)
- Contents
- Introduction
- Theoretical background
- Research methodology and material
- Results and analysis (possibly in separate chapters)
- Conclusions
- References
- (Appendices)

Each of these is written as a new chapter, in the files in the
folder `content/`, which are included in the file `main.typ`.
Read this document template and its comments carefully. The
titles of Chapters from @introduction to @conclusions are
provided as examples only. You should use more descriptive ones.
The title page is created by inserting the relevant information
into the file `main.typ`. The table of contents lists all the
numbered headings after it, but not the preceding ones.

Introduction outlines the purpose and objectives of the presented
research. The background information, utilized methods and source
material are presented next at a level that is necessary to
understand the rest of the text. Then comes the discussion
regarding the achieved results, their significance, error
sources, deviations from the expected results, and the
reliability of your research. The conclusions form the most
important chapter. It does not repeat the details already
presented, but summarizes them and analyzes their consequences.
List of references enables your reader to find the cited sources.

An introduction ends in a paragraph, that describes what each
following chapter contains. This document is structured as
follows: Chapter @writing-practices discusses briefly the basics
of writing and presentation style regarding the text, figures,
tables and mathematical notations. Chapter @references
summarizes the referencing basics. Chapter @conclusions presents
a discussion on the discoveries made during this study.
