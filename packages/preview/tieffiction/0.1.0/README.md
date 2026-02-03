# TiefFiction

The most opinionated Typst template for writing fiction. Did you ever wonder how people format books? Well, look no further.

TiefFiction serves primarily myself. I have a great many projects, but this is close to my daily workflow. I require uniform formatting between my various novels/stories and thus, I decided to make a typst template.

This template strongly orients itself on [LiX](https://github.com/NicklasVraa/LiX), a templating system by [NicklasVraa](https://github.com/NicklasVraa). Specifically, TiefFiction mimics and improves upon the styling of the `novel` class.

TiefFiction, however, tries to be annoying about it, and opinionates everything.

## Getting started

It's simple. Import and use:

```typst
#import "@preview/tieffiction:0.1.0": book

#show: book.with(
  title: "Your Title",
  author: ("Author 1", "Author 2"),
  publisher: "Your Publisher",
  date: datetime(year: 2026, month: 2, day: 3),
  isbn: "000-0-00000-000-0",
  edition: 42,
  license: "cc-by-nc-sa",
)
```

## Languages

TiefFiction is internationalized (is that a word?) and currently has versions for the following languages:

- English US
- English UK
- Deutsch DE

As TiefFiction uses TiefLang (obviously), selecting a language can either be done by passing the `language` parameter to `setup` or `book` (see below), or using TiefLang directly. Look at [TiefLang](https://github.com/Tiefseetauchner/TiefLang) for more information.

## Components

TiefFiction currently has 5 main components:

1. The Title Page `title-page`
2. The Copyright Block `copyright-block`
3. The Table of Content (ToC) `table-of-content`
4. The Blurb `blurb-block`

## Reference

### `setup`

```typst
#show: setup.with(
  title: "Your Title", // Title used for metadata and title page
  author: ("Author 1", "Author 2"), // Author name or array of names
  publisher: "Your Publisher", // Publisher name(s)
  date: datetime(year: 2026, month: 2, day: 3), // datetime for publication (defaults to today)
  isbn: "000-0-00000-000-0", // ISBN string
  edition: 1, // Edition number or label
  blurb: "Back cover blurb.", // Blurb text stored in metadata
  dedication: "For someone.", // Dedication text stored in metadata
  license: "cc-by-nc-sa", // Creative Commons license id (e.g. "cc-by-nc-sa")
  paper: "a5", // Paper size when width/height not set
  margin: (x: 18mm, y: 20mm), // Page margin override
  width: none, // Page width override
  height: none, // Page height override
  language: languages.english-us, // TiefLang language key
)
```

### `book`

```typst
#show: book.with(
  title: "Your Title", // Title used for metadata and title page
  author: ("Author 1", "Author 2"), // Author name or array of names
  publisher: "Your Publisher", // Publisher name(s)
  date: datetime(year: 2026, month: 2, day: 3), // datetime for publication (defaults to today)
  isbn: "000-0-00000-000-0", // ISBN string
  edition: 1, // Edition number or label
  blurb: "Back cover blurb.", // Blurb text stored in metadata
  dedication: "For someone.", // Dedication text stored in metadata
  license: "cc-by-nc-sa", // Creative Commons license id (e.g. "cc-by-nc-sa")
  paper: "a5", // Paper size when width/height not set
  margin: (x: 18mm, y: 20mm), // Page margin override
  width: none, // Page width override
  height: none, // Page height override
  language: languages.english-us, // TiefLang language key
  show-title-page: true, // Show the title page before front matter
  toc-settings: (style: "num-first", show-chapter-nums: false), // ToC style options
  copyright-block-settings: (settings: (text-size: 8.5pt)), // Copyright block options
)
```

### `start-preamble`

```typst
#show: start-preamble

// Your preamble content here.
```

### `start-before-main`

```typst
#show: start-before-main

// Your front matter here.
```

### `start-main`

```typst
#show: start-main

// Your main matter here.
```

### `start-after-main`

```typst
#show: start-after-main

// Your back matter here.
```

### `title-page`

```typst
#title-page() // Uses metadata state for title/author
```

### `copyright-block`

```typst
#copyright-block(
  holder: "Your Name", // Copyright holder (defaults to author)
  publisher: "Your Publisher", // Publisher name(s)
  year: 2026, // Year override
  date: datetime(year: 2026, month: 2, day: 3), // datetime used to derive year
  isbn: "000-0-00000-000-0", // ISBN string
  edition: 1, // Edition number or label
  dedication: "For someone.", // Dedication text shown on page
  license: "cc-by-nc-sa", // Creative Commons license id
  extra-lines: ("Printed in Someplace",), // Extra lines appended
  settings: (text-size: 8.5pt, line-spacing: 2pt), // Visual settings
)
```

### `table-of-content`

```typst
#table-of-content(
  style: "underlined", // "num-first" | "underlined" | "dotted"
  show-chapter-nums: true, // Show chapter numbering column
)
```

### `blurb-block`

```typst
#blurb-block(
  blurb: "Back cover blurb.", // Blurb text override
  title: "Your Title", // Title text override
)
```
