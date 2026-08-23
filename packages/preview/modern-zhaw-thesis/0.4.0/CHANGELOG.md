# Changelog

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
