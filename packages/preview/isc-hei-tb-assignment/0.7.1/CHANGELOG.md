# Changelog

# [v0.7.1](https://github.com/ISC-HEI/isc-hei-report/releases/tag/0.7.1), March 2026

## Added
- New `fancy-chapter-rule` option in the bachelor thesis template
- Dedicated assignment cover renderer in `lib/pages/cover_assignment.typ` for clearer TB assignment sheet composition
- Template-local `typst.toml` package metadata across templates for version management

## Changed
- Updated templates and dependencies to version `0.7.1`
- Refactored TB assignment translation handling and document title retrieval in cover rendering
- Improved TB assignment variable naming and comments for better readability and consistency
- Updated README and contributor-facing documentation links
- Refreshed generated examples and preview thumbnails for the `0.7.1` submission

# [v0.7.0]((https://github.com/ISC-HEI/isc-hei-report/releases/tag/0.7.0)), March 2026

## Added
- New **TB assignment sheet** template (`tb-assignment`) with full rendering logic, i18n support (FR/EN/DE), and addendum section
- `project-types` dictionary exported from the template for type-safe project type selection (`exploratoire` / `implementation`)
- Revision field in i18n and enhanced template styling
- Additional document examples in README

## Changed
- Improved and unified date formatting logic across all templates
- Nicer title display for bachelor thesis
- Refactored TOC inclusion
- Updated ISC logo across all README files
- Code structure refactored for improved readability

# [v0.6.0](https://github.com/ISC-HEI/isc-hei-report/releases/tag/0.6.0)
- Changes after the first student handout
- Document check script (for fonts & info)
- Added template version in document template metadata
- Panic message if no URL for repos
- Panic message if no document ID
- Typos fixed
- Header modified for right and left pages
- Header modifier for executive summary, only space for 2 lines
- Subtitles for long titles
- README.md corrected with correct refs, image of templates corrected as well for Typst universe

# [v0.5.3](https://github.com/ISC-HEI/isc-hei-report/releases/tag/0.5.3)
- Official repository field and official ID of the thesis added
- Title page of bachelor thesis now shows the official thesis ID
- The abstract / résumé display the keywords as well as the official repos, with a function a no clutter
- Minor tweaks to the first and second page of the bachelor thesis
- Corrected typos in README.MD

# [v0.5.2](https://github.com/ISC-HEI/isc-hei-report/releases/tag/0.5.2)
- Executive summary template added
- Title page 2 for `b-thesis` has now correct colons for `fr` and `en`, corrected typo in `fr` (thanks M. Ribeiro)
- Lorem-ipsum paragraphs to have a better representation of final output
- Minor changes in template declaration comments
- Updated repos URL

# [v0.3.1](https://github.com/ISC-HEI/isc-hei-report/releases/tag/0.3.1)
- Rewrote most of the template because it is now merged with the bachelor thesis as well
- using `Justfile` for building, based on https://github.com/typst-community/typst-package-template/tree/main
- update process for pushing to typst universe
- much cleaner user experience in file and more flexibility for printing out table of contents etc...
- `typst` v0.13.1 now supported
- removed extra spaces
- removed eval calls
- updated `codelst` and `showybox`

# [v0.1.5](https://github.com/ISC-HEI/isc-hei-report/releases/tag/0.1.5)
- Cover image kind and supplement
- `toc-title` project parameter
- multi-language support
- captions as markdown
- multi-pages code listings
- new listing format for line numbers
- headers

# [v0.1.3](https://github.com/ISC-HEI/isc-hei-report/releases/tag/0.1.3)
Cosmetic and minor changes only

# [v0.1.0](https://github.com/ISC-HEI/isc-hei-report/releases/tag/0.1.0)
Initial Release
