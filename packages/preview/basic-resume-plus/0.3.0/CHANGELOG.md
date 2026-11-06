# Basic Resume Changelog

## [v0.3.0](https://codeberg.org/ressler/basic-resume-plus-typst-template/releases/tag/v0.3.0)

### Breaking changes

- Built-in contact fields (`pronouns`, `location`, `email`, social links, `phone`, `personal-site`, and `orcid`) are no longer accepted by `resume.with(...)`. Compose contact details with `contact-section(...)`; `personal-info-position` is replaced by its `position` option.
- `dates-helper` now accepts one or two positional arguments, such as `dates-helper("Aug 2023", "May 2027")`, rather than named `start-date` and `end-date` arguments.
- `edu(...)` replaces `consistent` with the independent `institution-top` and `location-top` options; the old `gpa` argument is removed. Its positional argument order has also changed.
- `project(...)` now takes positional arguments in the order `name`, `role`, `url`, `dates`; the required `name` argument is validated.
- The component names `certificates(...)` and `extracurriculars(...)` are now singular: `certificate(...)` and `extracurricular(...)`.
- `accent-color` now takes a Typst color value (for example, `rgb("#26428b")`) rather than a hex string.

### Added and improved

- Added `contact-section(...)` with multi-row values, configurable separators, and alignment. Its default separator is a spaced middle dot.
- Added `web-link(...)`, `tel-link(...)`, and `mail-link(...)` helpers.
- Added the `empty(...)` value-check helper.
- Added `section-position` to `resume(...)` and the `institution-top` / `location-top` education layouts.
- Added `extracurricular-list(data:)` for rendering activity/date pairs as a list.
- Added `skills-table(data:, key-decorator:)` for rendering categorized skills in a two-column table.
- `certificate(...)` now validates its required name and issuer.
- `dates-helper` formats ranges with an en dash.

## [v0.2.10](https://codeberg.org/ressler/basic-resume-plus-typst-template/releases/tag/v0.2.10)

Fix svg raw block warnings by replacing scienceicons:0.1.0 with iconic-salmon-svg:3.0.0

## [v0.2.9](https://github.com/stuxf/basic-typst-resume-template/releases/tag/v0.2.9)

Make `lang` parameter configurable

## [v0.2.8](https://github.com/stuxf/basic-typst-resume-template/releases/tag/v0.2.8)

Add `font-size` and `author-font-size` configuration options

## [v0.2.7](https://github.com/stuxf/basic-typst-resume-template/releases/tag/v0.2.7)

Embarrassing version bump

## [v0.2.6](https://github.com/stuxf/basic-typst-resume-template/releases/tag/v0.2.6)

Bump typst version to 0.13.0 and above

## [v0.2.5](https://github.com/stuxf/basic-typst-resume-template/releases/tag/v0.2.5)

Bump scienceicon dep to fix #21

## [v0.2.4](https://github.com/stuxf/basic-typst-resume-template/releases/tag/v0.2.4)

Add option for consistent style of dates on upper right of components.

## [v0.2.3](https://github.com/stuxf/basic-typst-resume-template/releases/tag/v0.2.3)

User can set position of author and personal info.

## [v0.2.2](https://github.com/stuxf/basic-typst-resume-template/releases/tag/v0.2.2)

Allow changing of page sizes from us-letter to other sizes, such as A4, for Non-US folks

## [v0.2.1](https://github.com/stuxf/basic-typst-resume-template/releases/tag/v0.2.1)

Support orcid as a social link. Also fix contact-item's prefix argument.

## [v0.2.0](https://github.com/stuxf/basic-typst-resume-template/releases/tag/v0.2.0)

Modify to work with Typst version 0.12. Also extend projects function to be more robust.

## [v0.1.4](https://github.com/stuxf/basic-typst-resume-template/releases/tag/v0.1.4)

Make more resume fields optional (links in projects and certs)

## [v0.1.3](https://github.com/stuxf/basic-typst-resume-template/releases/tag/v0.1.3)

Allow for changing of fonts via initial configuration

## [v0.1.2](https://github.com/stuxf/basic-typst-resume-template/releases/tag/v0.1.2)

Version bump because I'm stupid🐛

## [v0.1.1](https://github.com/stuxf/basic-typst-resume-template/releases/tag/v0.1.1)

Make resume fields optional

## [v0.1.0](https://github.com/stuxf/basic-typst-resume-template/releases/tag/v0.1.0)

Initial Release
