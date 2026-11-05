# Basic Resume Changelog

## [v0.2.10](https://github.com/stuxf/basic-typst-resume-template/releases/tag/v0.2.10)

- Make phone numbers clickable with `tel:` links.
- Use a text symbol for the date separator to support PDF/UA accessibility.
- Allow `dates-helper` to display only the end date when the start date is omitted.
- Remove the `scienceicons` dependency and bundle the official CC0 ORCID icon directly, eliminating its Typst 0.15 warnings.
- Check the minimum supported and latest stable Typst versions on pull requests, pushes, and weekly scheduled runs. Treat compiler warnings as failures.
- Add Tytanic coverage for ORCID rendering, optional fields, and resume configuration, and check the packaged starter template with the minimum and latest Typst compilers.
- Replace the archived `typst-test` runner with Tytanic 0.4.1 for visual regression tests. Refresh the reference images for its Typst 0.15.1 renderer.
- Make repeated packaging predictable, use the manifest's exclusions, and check the isolated packaged template before release.
- Prepare registry submissions locally; tagged CI runs validate and upload the package without a registry credential.
- Refresh the package thumbnail to match the initialized starter template.

## [v0.2.9](https://github.com/stuxf/basic-typst-resume-template/releases/tag/v0.2.9)

Make `lang` parameter configurable

## [v0.2.8](https://github.com/stuxf/basic-typst-resume-template/releases/tag/v0.2.8)

Add `font-size` and `author-font-size` configuration options

## [v0.2.7](https://github.com/stuxf/basic-typst-resume-template/releases/tag/v0.2.7)

Embarassing version bump

## [v0.2.6](https://github.com/stuxf/basic-typst-resume-template/releases/tag/v0.2.6)

Bump typst version to 0.13.0 and above

## [v0.2.5](https://github.com/stuxf/basic-typst-resume-template/releases/tag/v0.2.5)

Bump scienceicon dep to fix #21

## [v0.2.4](https://github.com/stuxf/basic-typst-resume-template/releases/tag/v0.2.4)

Add option for consistent style of dates on upper right of components.

## [v0.2.3](https://github.com/stuxf/basic-typst-resume-template/releases/tag/v0.2.3)

User can set posistion of author and personal info.

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
