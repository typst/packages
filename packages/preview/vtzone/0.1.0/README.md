## Abstract

This package provides a basic vertical layout environment for CJK text.

Features are limited. Code quality is suspicious. API design is unstable. Use with caution.



## Usage

```typ
// Basic usage
#vtzone.vtzone(
  x-scale: 100%,
  max-height: auto,
  horizontal: rtl,
  row-gutter: 0.37em,
  col-gutter: 0.5em,
  custom-parbreak: none,
  initial-skip: 0mm,
  inner-alignment: center,
  debug: false,
)[REAL TEXT HERE]
//
// Option: use this show rule to enhance punctuation positions
#show: vtzone.fix-cjk-punct-vertical
```

## Parameters

- `x-scale`: Apply a horizontal scale to internal elements.
- `max-height`: Limit the height of each column.
- `horizontal`: Direction to horizontally arrange columns.
- `row-gutter`: Inter-character vertical spacing.
- `col-gutter`: Inter-column horizontal spacing.
- `custom-parbreak`: What to do when a `parbreak()` occurs in the input stream.
- `initial-skip`: Skip some horizontal space before the first column. In the current version, zones refuse to horizontally neighbor each other, so you may use this feature to `place()` stuff like chapter heading.
- `inner-alignment`: The alignment inside each single-character cell.
- `debug`: Show debugging hints. Will make underhang characters red.



