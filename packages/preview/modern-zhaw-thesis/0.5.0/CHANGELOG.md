# Changelog

## 0.5.0

- **BREAKING**: Requires Typst 0.15.0 or later (needed by Codly 2)
- **BREAKING**: Upgraded Codly from 1.3.0 to 2.0.0. Codly 1 calls in your document (`#codly(..)`, `#codly-disable`, ...) no longer affect code blocks; use Codly 2 show rules instead (`#show: codly.set_(..)`)
- Upgraded Glossy to 0.9.2 and Datify to 1.3.0
- Emphasised text in headings, the cover title and the outline is now slanted (the header font has no italic variant)
- **Font files changed**: Fira Code is now a single variable font and the unused condensed TeX Gyre Heros files are gone. Download the fonts again from the link in the setup section
- Typst 0.15 has breaking changes of its own, see the [Typst 0.15 migration guide](https://typst.app/docs/changelog/0.15.0/)
- Added colophon to acknowledgements page, and the corresponding setting
- Added proper supplements to header labels and appendix
- Fixed header spacing convergence issue
- Fixed H4 labelling
- Fixed labels naming convention
- Fixed abstract keyword alignment
- Fixed abstract formatting
- Added `date` setting to fix the date shown on the cover, abstract and declaration pages (defaults to today)
- Added `ai-label` setting to the declaration of originality, to reference an AI usage section with a custom label
- Set PDF metadata (title, authors, keywords, date) automatically from the cover and abstract settings
- Code snippet figures are now labelled "Code Snippet" / "Code-Snippet" instead of "Listing"
- English dates now use British day-month order (e.g. "17 November 2026")
- Appendix supplement now also applies when the user sets their own heading supplements
- Exported `today` accepts an optional `date:` argument

## 0.4.0

- **BREAKING (layout shifts)**: Tweaked H1 font size and spacing based on feedback
- **BREAKING**: `biblio: (file:, style:)` replaced by `bibliography:` — pass a `bibliography()` object directly
- **BREAKING**: `hide-frontmatter` replaced by `preset` — use `preset: "draft"` for equivalent behaviour
- Added `preset` parameter: `"thesis"` (default, show everything), `"draft"` (hide all frontmatter), `"exercise"` (show cover page + TOC, hide abstract/acknowledgements/declaration)
- Replaced custom Glossy patch with official 0.9.1 release. Should not be a breaking change.

## 0.3.0

- Allow setting overrideable options to `none`
- Fixed edge cases when some options were set to `none` and caused errors
- Fixed declaration of originality appendix ref
- Fixed bug displaying supervisor names in acknowledgements page
- Fixed localisation of "Chapter" label in page header
- Fixed long H1s overlapping with next section

## 0.2.0

- Added custom quote styling
- Fixed glossary issues when no entries are provided
- Localised outline and appendix headings
- Fixed Glossy init-glossary validation bug
- Fixed empty optional supervisor fields
- Fixed translation strings
- Fixed custom declaration of originality body rendering
- Fixed README typos

## 0.1.1

Improved README

## 0.1.0

Initial release
