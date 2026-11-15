# Changelog

## 0.2.0

This release fixes a series of bugs from 0.1.0, makes most of the layout configurable, and refreshes the typography. Typst 0.14.0 or newer is required.

### Upgrading from 0.1.0

Typst copies the template files into your project only once, when you create it. So besides changing the import to `@preview/benplate:0.2.0`, please update the project files too. The easiest way is to create a new project with `typst init @preview/benplate:0.2.0` and copy your content over. Alternatively, replace `frontmatter.typ`, `backmatter.typ`, `frontmatter/titlepage.typ`, `frontmatter/outline.typ` and `frontmatter/declaration-of-authorship.typ` with their new versions.

If you keep your old files, the document still compiles, but the blank pages after the title page, the declaration and the table of contents show a page number. The title appears in Typst's default style instead of the spaced-out capitals as well.

Breaking changes:

- `default-frontmatter` and `default-backmatter` are no longer exported by the package. They now only exist in your project's `frontmatter.typ` and `backmatter.typ`.
- The page layout now defaults to centered text for reading on a screen. For the previous layout with a wider inner margin for binding, set `print: true`, or compile the template's `main.typ` with `--input print=true`.
- Math uses Libertinus Math instead of STIX Two Math. Script letters (`cal`, `scr`) and integral signs come from New Computer Modern Math, which also stands in if Libertinus Math isn't installed.
- Line and paragraph spacing changed, so existing documents re-flow. Check your page breaks and figure placement.

### New options

- `thesis()` has new arguments: `lang`, which also sets hyphenation and Typst's built-in terms, `body-font`, `heading-font`, `caption-font`, `math-font`, `code-font`, `body-size`, `accent-color` and `print`.
- `default-frontmatter` has new arguments: `accent-color` for the university name, and `date-format`, which sets one date format for the title page and the declaration.
- `default-backmatter` now defaults to `bib-style: "ieee"`.

### Bug fixes

- Unnumbered headings such as `#heading(numbering: none)[Preface]` no longer crash the build, and no longer show a chapter number of "0".
- Appendix figures and equations are numbered A.1, A.2, etc. instead of continuing the chapter numbers.
- The list of figures shows chapter numbers ("Figure 2.1" instead of "Figure 1").
- Code listings are referenced as "Listing" instead of "Figure".
- Subfigure references use the parent figure's type, for example "Table 1.1a", and keep their chapter when referenced from another chapter.
- The words of the document title are no longer restyled wherever they appear in the text.
- `comment()` no longer fails to compile, and its `color` argument works.
- Long title pages no longer overflow onto a second page.
- Front matter pages show page numbers, while blank pages and chapter opening pages stay clean.
- Headings in the back matter are no longer numbered as further appendix chapters.
- Citations color names, years and numbers in any citation style, not only the parts inside brackets.
- Updated `hydra` to 0.6.3, which no longer fails on Typst 0.15 when a custom page margin sets neither `top` nor `y`.

### Design changes

- Captions behave more consistently in terms of their placement and font size.
- Equation numbers use the body font.
- Code is set in IBM Plex Mono, and code blocks get a light frame.
- Tables without their own styling get horizontal rules only.
- More open line spacing and tighter paragraph spacing for better readability.

## 0.1.0 (2026-03-23)

Initial release.
