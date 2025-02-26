# Supercharged-DHBW Changelog

## [v3.4.1] - 2025-01-07

- Fix error that page numbering style is not applied to the table of contents
- Improve docs

## [v3.4.0] - 2024-12-08

- Fix inconsistency in the header spacing
- Add option to provide the page numbering style
- Update some descriptions in the documentation

## [v3.3.2] - 2024-11-02

- Fix typo in declaration of authorship

## [v3.3.1] - 2024-10-03

- Fix expect company attribute in author if `at-university` is true

## [v3.3.0] - 2024-09-20

- Display current chapter in the header instead of the title

## [v3.2.0] - 2024-09-16

- Remove double space in confidentiality statement
- Add argument to provide keys that are ignored when highlighting links
- Remove unnecessary argument `show-appendix`

## [v3.1.1] - 2024-08-26

- Update declaration of authorship text to match the new DHBW requirements

## [v3.1.0] - 2024-08-20

- Fix typo in readme and improve contents
- Add attribute `titlepage-content` to create a custom titlepage
- Add attribute `math-numbering` to change the numbering style of math equations
- Fix typo in german confidentiality statement
- Reorder outlines and abstract
- Add glossary support
- Improve code and language handling
- Fix error when no acronyms are provided
- Add more examples to the documentation

## [v3.0.0] - 2024-08-08

- Combine header settings in a dictionary (breaking change)
- Move abstract in front of the outlines
- Refactor language handling
- Smaller improvements to the code readability
- Provide more examples
- Attribute to provide a custom declaration of authorship

## [v2.2.0] - 2024-07-29

- Change default heading numbering to `1.1`
- Add attribute to provide a heading numbering
- Add attribute `university-short` to allow other universities except DHBW
- Add attribute to provide a custom header

## [v2.1.0] - 2024-07-19

- Add confidentiality marker attribute
- Add header configuration options
-> Show title in header
-> Show left logo in header
-> Show right logo in header
-> Show header divider

## [v2.0.2] - 2024-07-04

- Display plural text in the declaration of authorship if the document has multiple authors

## [v2.0.1] - 2024-07-04

- Update and fix errors in docs
- Remove english version of the declaration of authorship as a german one is mandatory even for english projects

## [v2.0.0] - 2024-07-02

- Rename argument `at-dhbw` to `at-university`
- Add argument `city` to provide a city when no company is provided
- Add the option to provide a supervisor for the company and university
- Add `bib-style` argument
- Add an argument to provide custom confidentiality statement content
- Fix acronym linebreak bug

## [v1.5.0] - 2024-06-24

- Highlight links in blue
- Link acronyms to definitions
- Add option to define space between acronyms and there long versions
- Improve user feedback with error messages
- Remove optional arguments from main.typ template file
- Improve docs
- Improve spacing for many authors
- Change naming of `studiengang` to `kurs`
- Add `type-of-thesis` attribute
- Add `type-of-degree` attribute
- Make `acronyms` attribute optional
- Add acronym usage docs
- Add option to provide date range instead of one date
- Add attribute to specify the date format

## [v1.4.0] - 2024-06-10

- Fix typo on titlepage
- Improve header spacing
- Use alphabetical numbering for references and appendix pages
- Remove the numbering style option from the template
- Add option to change the toc depth

## [v1.3.1] - 2024-05-27

- Don't display list of tables when empty
- Don't display code snippets list when empty
- Improve spacing for many authors (>4)
- Improve paragraph spacing

## [v1.3.0] - 2024-05-23

- Fix `supervisor` on titlepage is missing when `at-dhbw` option is true
- Fix confidentiality statement page is empty instead of hidden when at-dhbw option is true
- Fix a bug the prevented the appendix content to update
- Fix and refactor acronym usage
- Fix missing translation and typo in declaration of authorship
- Refactor usage of abstract and appendix

## [v1.2.0] - 2024-05-16

- Fix bug that `course-of-studies` is displayed twice even if similar
- Fix bug where title text is not semibold
- Add option to hide page headder
- Add option to provide numbering style
- Add option to change numbering alignment

## [v1.0.0] - 2024-05-14

- Initial release
