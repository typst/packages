# kauderwelsch

An organic, multilingual dummy text and document generator for Typst, heavily inspired by the classic LaTeX blindtext package. 

Unlike static "Lorem Ipsum" generators, kauderwelsch provides meaningful, flowing public-domain literature across multiple languages, realistic asymmetrical section nesting, and automated distribution of advanced document features (like multi-level lists, tables, mathematical formulas, and raw code blocks).

## Features

- **Puristic & Organic:** No forced pagebreaks. Layout flow is entirely organic, allowing you to test your custom show-rules and document structures precisely.
- **Multilingual Support:** Switch seamlessly between English ("en" - *The 39 Steps*), German ("de" - *Winnetou*), French ("fr" - *Arsène Lupin*), and classical Latin ("la" - Ovid's *Metamorphoses*).
- **Deterministic Smart Distribution:** Even in a small document layout, the package guarantees that all activated features (code snippets, tables, nested lists) are rendered at least once and distributed evenly across your headings.
- **Strict Validation:** Integrated assertions safeguard your compilation against invalid arguments.

## Usage

### Basic Text Generation
Generate quick paragraphs with optional math formulas:

```typst
#import "@local/kauderwelsch:0.1.0": *

// Generate 3 medium-sized paragraphs in German
#blindtext(paragraphs: 3, length: "medium", lang: "de")

// Generate short paragraphs with inline math formulas embedded every 2 paragraphs
#blindtext(paragraphs: 5, length: "short", lang: "en", math: true, math-frequency: 2)
```

### Full Document Mocking
Test complex templates, styling, headers, and outlines with a deeply structured document:

```typst
#import "@local/kauderwelsch:0.1.0": *

// Generate a massive 10+ page document to test complex document constraints
#blinddocument(
  size: "large",
  length: "long",
  lang: "de",
  math: true,
  lists: true,
  tables: true,
  figures: true,
  code: true
)
```

## Function Reference

### blindtext
- `paragraphs` (int): Number of paragraphs to generate. Default is 3.
- `length` (string): Length of each paragraph ("short", "medium", "long"). Default is "long".
- `lang` (string): Language identifier ("en", "de", "fr", "la"). Default is "en".
- `math` (boolean): Whether to scatter mathematical formulas into the text. Default is false.
- `math-frequency` (int): Density of formulas. Default is 1.
- `offset` (int): Shifts the starting index within the text arrays. Default is 0.

### blinddocument
- `size` (string): Overall structure size ("small", "medium", "large"). Default is "medium".
- `length` (string): Individual paragraph length inside the sections. Default is "long".
- `lang` (string): Language identifier ("en", "de", "fr", "la"). Default is "en".
- `math` (boolean): Scatters math formulas into the document text blocks. Default is false.
- `lists` (boolean): Includes simple, nested, and definition lists. Default is true.
- `tables` (boolean): Includes standard and large matrix data tables. Default is true.
- `figures` (boolean): Includes grey layout rects wrapped in captioned figures. Default is false.
- `code` (boolean): Includes highlighted raw programming snippets (Python / R). Default is false.

## License
This project is licensed under the MIT License.