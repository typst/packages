[中文](README-zh.md) | English

# jastylest-zh
jastylest is a template for Japanese typesetting in Typst, and jastylest-zh is optimized for Chinese typesetting based on it.

## Usage
Add the following code at the very beginning of your file:
```typ
#import "@preview/jastylest-zh:0.1.0": *
```

Then use the configuration file:
```typ
#let (article, textsf) = template(
  seriffont: "STIX Two Text",             // Western serif font
  seriffont-cjk: "Noto Serif CJK SC",     // Chinese serif font
  sansfont: "Noto Serif",                 // Western sans-serif font
  sansfont-cjk: "Noto Sans CJK SC",       // Chinese sans-serif font
  monofont: "Fira Mono",                  // Western monospaced font
  monofont-cjk: "Noto Sans Mono CJK SC",  // Chinese monospaced font
  mathfont: "STIX Two Math",              // Mathematical font
  kaiti-cjk: "FandolKai",                 // Kai font, default is FandolKai (needs to be imported)
  paper: "a4",              // Paper size, default is a4
  font-size: 12pt,          // Font size, can also be used with other packages to import Chinese font sizes
  code-font-size: 11pt,     // Code font size
  font-weight: "regular",   // Font weight, default is regular
  cols: 1,                  // Multi-column, default is 1 column
  titlepage: false,         // Whether to display the title page, default is not to display
  title: [*Title*],         // Title, can use formatting
  office: [Organization],   // Organization, can use formatting, can also serve as a subtitle
  author: [Author],         // Author, can use formatting
  // date: none,            // Date, default is the current date
)
#show: article  // Display the document
```

## Fonts
The default fonts are STIX Two Text/Math, Fira Sans/Mono, and Noto Serif/Sans CJK SC. You can also modify them yourself.

The default Chinese font for italics is FandolKai (you need to upload it yourself). You can also change it in the above configuration. The Fandol font series can be downloaded at <https://ctan.org/pkg/fandol>.

## Functions
There are two built-in functions: `#textsf[]` and `#noindent[]`. `#textsf[]` allows the part enclosed in parentheses to use the sans-serif font, while `#noindent[]` allows the part enclosed in parentheses to cancel the indentation.

## Examples
The `document.typ` file contains a document example with all configurable parameters.
