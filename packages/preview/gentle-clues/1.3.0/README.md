# gentle-clues

Simple admonitions for typst. Use predefined ones or define your own.

Inspired from [mdbook-admonish](https://tommilligan.github.io/mdbook-admonish/).

## Overview of all predefined clues
![Overview of the predefined clues](./gc-overview.svg)

## Usage

For detailed information, see the [documentation (PDF)](https://github.com/jomaway/typst-gentle-clues/blob/main/docs.pdf).

To use this package, simply add the following code to your document:
```typst
#import "@preview/gentle-clues:1.3.0": *

// add an info clue
#info[ This is the info clue ... ]

// or a tip with custom title
#tip(title: "Best tip ever")[Check out this cool package]
```

This will create an _info_ and _tip_ clue in your document. See the [overview](#overview-of-all-predefined-clues) for all available clues.

### Features

This package provides some features which help to customize the clues to your liking.

- Set global default for all clues
- Overwrite each parameter on a single clue for changing the title, color, etc.
- Show or hide a counter value on tasks.
- Define your own clues very easily.
- ...

For a full list see the [documentation (PDF)](https://github.com/jomaway/typst-gentle-clues/blob/main/docs.pdf).

## Language support

This package does use [linguify](https://github.com/jomaway/typst-linguify) to support multiple languages.

**Header titles:**
The language of the header titles is detected automatically from the `context text.lang`.
See the file [lang.toml](https://github.com/jomaway/typst-gentle-clues/blob/main/lib/lang.toml) for currently supported languages.

If an unsupported language is set, it will fall back to English as default.
Feel free to open a PR with your language added to the `lang.toml` file.

## License

[MIT License](LICENSE)

## Changelog

[See CHANGELOG.md](CHANGELOG.md)
