# Orchid

A Typst package for displaying ORCID iDs, inspired by LaTeX's `orcidlink` package.

## Quick Start

```typst
#import "@preview/orchid:0.2.0": orcid

Josiah Carberry #orcid("0000-0002-1825-0097")
```

By default, the icon and full HTTPS URL form one link to the ORCID record.

## Changelog

See [CHANGELOG.adoc](CHANGELOG.adoc) for release notes.

## Manual

For usage, options and examples, see the [manual](docs/manual.pdf).

## Issues

PAC 2026 can warn about inappropriate use of the Figure element because Typst exports the inline icon with a block placement attribute. See [Typst #9038](https://github.com/typst/typst/issues/9038).

## License

This package is licensed under the [MIT License](LICENSE.txt).
