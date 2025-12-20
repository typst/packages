# keepsake

Create printable, folding greeting cards for various occasions like birthdays, holidays, and thank-you notes. This package handles the complex layout and rotation logic required for professional-looking physical stationery.

## Usage
To use this package, import it into your Typst file:

```typst
#import "@preview/keepsake:0.1.0": bifold, quarter-fold-vertical, quarter-fold-horizontal
```

### Bifold Card

Best for a standard large card. This layout uses two pages: one for the outside (front and back) and one for the interior.

```typst
#show: bifold.with(
  paper: "us-letter",
  front: [= Happy Birthday],
  back: [
    #set align(center + bottom)
    #set text(8pt, gray)
    Made with ❤️ and Keepsake
  ],
  inside-right: [Wishing you an incredible year ahead!]
)
```

### Quarter-fold Card (Vertical and Horizontal)

Perfect for a single-sheet, one-sided print. The paper is folded in half twice (horizontally then vertically or vertically then horizontally). `keepsake` automatically rotates the top panels 180° so they are upright when folded.

```typst
#show: quarter-fold-vertical.with(
  front: [= Thank You],
  inside-bottom: [Your gift was so thoughtful!],
)
```

```typst
#show: quarter-fold-horizontal.with(
  front: [= Thank You],
  inside-left: [Your gift was so thoughtful!],
)
```

## Reference

`bifold`

A card folded once, creating four panels across two pages.

- `paper`: The paper size (default: "us-letter"). Supports any standard Typst paper string.

- `front`: Content for the front cover.

- `back`: Content for the back cover.

- `inside-left`: Content for the interior left panel.

- `inside-right`: Content for the interior right panel.

- `draw-folds`: Boolean to show a dashed guideline for folding (default: false).

- `inset`: The internal margin for each panel (default: 1in).

`quarter-fold-vertical`

A card folded twice, with all panels printed on a single side of one sheet.

- `paper`: The paper size (default: "us-letter").

- `front`: Content for the front cover (automatically rotated).

- `back`: Content for the back cover (automatically rotated).

- `inside-top`: Content for the top interior panel.

- `inside-bottom`: Content for the bottom interior panel.

- `draw-folds`: Boolean to show dashed guidelines for the cross-fold (default: false).

- `inset`: The internal margin for each panel (default: 0.5in).

`quarter-fold-horizontal`

A card folded twice, with all panels printed on a single side of one sheet.

- `paper`: The paper size (default: "us-letter").

- `front`: Content for the front cover (automatically rotated).

- `back`: Content for the back cover (automatically rotated).

- `inside-left`: Content for the left interior panel.

- `inside-right`: Content for the right interior panel.

- `draw-folds`: Boolean to show dashed guidelines for the cross-fold (default: false).

- `inset`: The internal margin for each panel (default: 0.5in).

## License

This package is licensed under the MIT License.
