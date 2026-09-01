# Typst Template for Harvard GSAS Dissertation
An **unofficial** template for Harvard GSAS Dissertation.

Follow formatting guidelines from https://gsas.harvard.edu/resource/dissertation-formatting-guidance.

# Changelog

## 0.1.6
- Front matter pages (title page, copyright, abstract, table of contents) are now listed in the table of contents
- Preliminary pages use lowercase Roman numerals everywhere, including in the table of contents
- Unnumbered chapters, such as the one `#bibliography()` creates, no longer repeat the previous chapter number
- `appendix()` numbers appendix chapters `A`, `B`, `C`, ..., with sections, figures, tables and equations following the letter; they are referenced as "Appendix A"
- Example expanded with a second chapter, citations and a bibliography, a code listing, and a second appendix

## 0.1.5
- `Chapter` and `Section` are used for suppliment correctly

## 0.1.4
- Added `appendix()` function for appendix, which resets numbering to start with `A.`
- fix equation numbering style to include `()`

## 0.1.3
- Improved figure caption alignment, size, and separation

## 0.1.2
- Fixed title style
- Added Numbering for equations and figures
- Improved margin

## 0.1.1
- Added `creative_commons` option for front matter
- Fixed title printing just before Abstract
- Fixed inconsistent smallcaps
- Fixed fill for entries in the TOC
- added color for reference and url to be the school color
