# typst-xarrow

Variable-length arrows in Typst, fitting the width of a given content.

## Usage

This library mainly provides the `xarrow` function. This function takes one
positional argument, which is the content to display on top of the arrow.
Additionally, the library provides the following arrow styles:

- `xarrowDashed` using arrow `sym.arrow.dashed`.
- `xarrowDouble` using arrow `sym.arrow.double.long`;
- `xarrowHook` using arrow `sym.arrow.hook`;
- `xarrowSquiggly` using arrow `sym.arrow.long.squiggly`;
- `xarrowTwoHead` using arrow `sym.arrow.twohead`;
- ...

These names use camlCase in order to be simply called from math mode. This may
change in the future, if it becomes possible to have the function names
mirror the dot-separated name of the symbols themselves.

### Arguments

Users can provide the following arguments to any of the previously-mentioned
functions:

- `width` defines the width of the arrow. It defaults to `auto`, which makes the
  arrow adapt to the size of the body.
- `margins` defines the spacing on each side of the `body` argument. Ignored when
  `width` is not `auto`.
- `position` defines whether the main `body` argument will be set above or below
  the arrow. Default is `top`; the only other accepted value is `bottom`.
- `opposite` sets the content that is displayed on the other, non-default side
  of the arrow. Default is `none`.

### Example

```
#import "@preview/xarrow:0.3.0": xarrow, xarrowSquiggly, xarrowTwoHead

$
  a xarrow(sym: <--, QQ\, 1 + 1^4) b \
  c xarrowSquiggly("very long boi") d \
  c / ( a xarrowTwoHead("NP" limits(sum)^*) b times 4)
$
```

## Customisation

The `xarrow` function has several named arguments which serve to create new
arrow designs:

- `sym` is the base symbol.
- `sections` defines the way the symbol is divided. Drawing an arrow consists of
  drawing its tail, then repeating a central part that is defined by `sections`,
  then drawing the head. This is the parameter that has to be tweaked if
  observing artefacts. `sections` are given as two ratios, delimiting
  respectively the beginning and the end of the central, repeated part of the
  symbol.
- `partial_repeats` indicates whether the central part of the symbol can be
  partially repeated at the end in order to match the exact desired width. This
  has to be disabled when the repeated part has a clear period (like the
  squiggly arrow).

### Example

```
#let xarrowSquigglyBottom = xarrow.with(
  sym: sym.arrow.long.squiggly,
  sections: (20%, 45%),
  partial_repeats: false,
  position: bottom,
)
```

## Limitations

- The predefined arrows are tweaked with the Computer Modern Math font in mind.
  With different glyphs, more sophisticated arrows will require manual
  modifications (of the `sections` argument) to be rendered correctly.
- The `width` argument cannot be given ratio/fractions like other shapes. This
  would be a nice feature to have, in order to be able to create an arrow that
  takes 50% of the available line width for instance.
- I would like to make a proper manual for this library in the future, using
  something cool like [mantys](https://github.com/jneug/typst-mantys).
