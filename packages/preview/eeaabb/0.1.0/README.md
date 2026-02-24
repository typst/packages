
![eeaabb](https://raw.githubusercontent.com/WenSimEHRP/eeaabb/refs/heads/main/title.png)

Visual debug helpers for Typst to extract element axis-aligned bounding boxes (AABB).

## Exports

- `eeaabb(content, unit: length.pt, precision: 3)` – Box the whole content with width & height labels.
- `ccaabb(content, unit: length.pt, precision: 3)` – Box each character separately.
- `debug-font(...)` - Test a font's x-height, cap height, bounds, etc.
  See <https://forum.typst.app/t/a-snippet-to-debug-font-by-visualize-baseline-cap-height-etc/4597> for details.

Parameters:

- `unit` conversion function for lengths.
  - default: `length.pt`. Available options: `length.{cm,mm,inches,pt}`
- `precision` decimal places (default `3`).

## Example

```typst
#import "@preview/eeaabb:0.1.0": ccaabb, eeaabb

// Explicit calls
#eeaabb(block[Hello World])\
#ccaabb(text(size: 2em)[Kerning?])

// Calling via a show rule
#[
  #set text(top-edge: "bounds")
  #show: eeaabb
  #show: ccaabb
  Asogi Genshin\
  亜双義\u{3000}玄真
]

// Calling via a show rule, this time with some extra touches
#[
  #set text(top-edge: "bounds")
  #show: eeaabb.with(unit: length.mm, precision: 4)
  #show: ccaabb.with(unit: length.mm, precision: 4)
  Asogi Kazuma\
  亜双義\u{3000}一真
]
```

```typst
#import "@preview/eeaabb:0.1.0": debug-font
#show: debug-font

// test your font here
The quick brown fox jumps over a lazy dog.
```
