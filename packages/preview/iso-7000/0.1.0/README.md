# ISO 7000 Icons for Typst

This package provides access to 2197 of the most common ISO 7000 / IEC 60417 graphical symbols for use in Typst documents. All symbols are sourced from Wikimedia Commons and made available under their respective open licenses.

For a complete list of supported icons see the [demo PDF](https://github.com/gauravmm/typst-iso-7000-generator/releases/tag/v0.1.0).

## Installation

```typst
#import "@preview/iso-7000:0.1.0": iso-7000
```

## Usage

The package exports a single function `iso-7000()` that displays an ISO 7000 symbol by its reference number. It forwards all other arguments to `image`:

```typst
// Basic usage
#iso-7000("0222")

// With size options
#iso-7000("0222", width: 2cm)
#iso-7000("3884", height: 1em)

// Inline in a sentence
Click #iso-7000("0222", height: 1em) to continue.
```

## License

All symbols are sourced from Wikimedia Commons and retain their original licenses. The code to scrape, clean, optimize, and package the icons is online here [typst-iso-7000-generator](https://github.com/gauravmm/typst-iso-7000-generator).
