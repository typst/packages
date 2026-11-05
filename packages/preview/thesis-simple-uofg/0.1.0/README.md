# University of Glasgow PhD Thesis Template for Typst

This code repository is not affiliated with the University of Glasgow in any capacity.

This Typst template is designed based on `uofg_guidelines-2026-10-12.pdf`. In terms of the proposed content outline from the guidelines:

1. title page
2. abstract
3. table of contents
4. list of tables
5. list of figures
6. list of accompanying material
7. preface
8. acknowledgement
9. author’s declaration
10. definitions/abbreviations
11. text - in chapters
12. appendices
13. glossary
14. list of references
15. bibliography
16. index

This template automates away points one (1) and two (2). It is intended to be a minimal Typst template with no styling that goes beyond the University of Glasgow guidelines.

This template is not a replacement for reading through and adhering to the University of Glasgow thesis writing guidelines, and a student using this template at a future date is encouraged to either fork this repository and update it in accordance with newest guidance, or issue a pull request to this repository.

The entry point is the function `thesis-template`, which has all the arguments documented. The intended usage is to do `#show thesis-template.with([dict])` where `[dict]` is a Typst dictionary of named arguments.

## Dependencies

To build this project you will need to have an installation of [Typst](https://typst.app) on your system.

Additionally, due to University of Glasgow's font requirements and the associated licensing issues, you need to download your own copy of Microsoft's proprietary fonts [Times New Roman](https://en.wikipedia.org/wiki/Times_New_Roman), [Arial](https://en.wikipedia.org/wiki/Arial), and [Trebuchet MS](https://en.wikipedia.org/wiki/Trebuchet_MS).

One way of doing this is by accessing your legally purchased copy of Windows, and copying out the necessary fonts from `%WINDIR%\Fonts`.

# Technical

## Scope

This template manipulates the following variables:

- This template sets basic page properties, that is: `(page.) margin ; paper ; header`. Header is elaborated below.
- This template sets a custom header with page numbering on the outer edge, and current chapter name on the inner edge (with respect to binding).
- This template sets default text properties, that is: `(text.) hyphenate ; lang ; region ; font ; size`.
- This template sets default paragraph properties, that is `(par.) spacing ; leading`.
- This template sets default quote properties.
- This template sets up a heading numbering format, and the default heading font.
- This template makes every top-level heading (chapter) have its own page, as with LaTeX's book document class.

## Objects (figures, tables, listings, equations)

As of writing, the University of Glasgow guidelines do not specify strict requirements for object numbering, aside from each object having its own separate counter, and the usage of Arabic numerals. As such, the display options for all these elements have not been changed.

I suggest creating a macro for various numbered figures, tables, and listings.

## Footnotes & Endnotes

Footnotes, as they are by default from Typst are stylistically correct. This template makes sure that the footnote text is set to `10pt` — the same as the header.

Endnotes have not been implemented in any way, and would require a custom macro that follows University of Glasgow's guidance on endnotes.

## References

This document has zero referencing work set up. The University of Glasgow guidelines do not specify any institution-wide standards, and recommends to follow local school standards.

## Caveats & TODOs
- The template only works for left-to-right text. Needs a bit more custom coding for right-to-left text.
- On footnotes with more than 100 words the style needs to change to 12pt, this is not automated.
- The guidelines dictate a minimum font limitation. I am not experienced enough in Typst to know how to enforce such things.
- The guideline specifies no more than four (4) levels of sectioning headings, that is, an error should be raised on a section heading such as `5.4.3.2.1`. This has not been implemented.
- _Chapter-Object_ style numbering has not been implemented, i.e. "Figure 3 in Chapter 4" is not presented as "Figure 4-3."

# Legal disclaimer

All template code files (`lib.typ`) are licensed under GNU GPLv3, as seen in `LICENSE`. The template code file `main.typ` is exempt from GNU GPLv3, and all copyright possession is waived, putting the file into public domain.

All University of Glasgow material, including the University of Glasgow PhD thesis writing guidelines PDF, and University of Glasgow's blue badge (`uofg-blue-badge.svg`) are subject to the copyright of the University of Glasgow, and exempt from both GNU GPLv3 and CC-BY-NC.
