# Changelog

This file documents all notable changes to the [`pc-letter`](https://github.com/thatfloflo/pc-letter) project.

## v0.4.0

### Added

- New Italian localisation and example (see [examples/example-it.typ](./examples/example-it.typ)) (thanks to Biagio and Giulia)
- New vertical alignment options (`top` \[default\], `horizon`, `bottom`) for the `address-field`.

### Changes

- The implementation of vertical alignment for the `address-field` has changed subtly along with the implementation of new alignment options. This should normally not be noticeable when migrating, unless the template style was heavily customised beforehand.

## v0.3.1

### Added

- New Romanian localisation and example (see [examples/example-ro.typ](./examples/example-ro.typ)) (thanks to [KoNickss](https://github.com/KoNickss))

## v0.3.0

### Added

- New options to configure the letterhead:
  - The `alignment.letterhead` style-option allows the letterhead to be aligned to the `left`, `center`, or `right`. The default remains `center`.
  - The `components.letterhead.ascent` style-option allows the spacing between the letterhead and the content below (typically the address field) to be overwritten, which might help with better accommodating slightly larger logos, if used.
  - `pc-letter.init` now accepts a `logo` argument which can be used to add a logo to the letterhead.
- New example documents:
  - [examples/example-logo.typ](./examples/example-logo.typ) shows how to use a logo in the letterhead.
  - [examples/example-signature.typ](./examples/example-lsignature.typ) shows how to use a image as a signature.

### Changed

- The readme now contains a "How do I ...?" section with examples for things users might want to know how to do without reading all the configuration options. More items can be added to this in the future.

### Fixed

- A typo in the French letter example in [examples/example-fr.typ](./examples/example-fr.typ) (thanks to [gasche](https://github.com/gasche)).


## v0.2.0

### Added

- Author's details (`author` argument of `pc-letter.init`) now also accepts a `web` argument where an author can include their homepage address.

### Changed

- The default `medium` (`style` argument of `pc-letter.init`) is now `"print"` (previously `"digital"`), because a letter set for printing will work digitally without problems, but one set for digital-only use (with background fill and such) may well produce problems when printing.
- Author's address (`author.address` argument of `pc-letter.init`) is now optional.
- Author's contact details (phone, email, web) (`author.phone`, `author.email`, `author.web` arguments of `pc-letter.init`) are now all optional and break across two lines iff more than two of them are specified.
- Headings (used for subject lines and as section separators) now get 1.25em spacing above and below (previously 1em), making them subtly more prominent as separators in the text body.
- Internal calculations for spacing of different fields is now relative to page dimensions and margins, which will help with implementing different paper sizes (e.g. `us-letter`) in future versions of `pc-letter`.
- The package now has full [`tidy`](https://typst.app/universe/package/tidy/) 0.4.0-compatible doc comments. While `tinymist` still only parses the pre-0.4.0 style comments, it is expected that this will also enhance hinting for users once `tinymist` implements the up-to-date doc comment style. The dictionary-passing method of initialisation may still pose a problem for this, but the change should generally aid in future-proofing the package.

### Fixed

- Missing translation of pagination for non-Austrian German fixed.
