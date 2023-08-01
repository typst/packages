# typst-xarrow

Variable-length arrows in Typst, fitting the width of a given content.

## Usage

This library mainly provides the `xarrow` functions. This function takes one
positional argument, which is the content to display on top of the arrow.
Additionnaly, the library provides the following arrow styles:

- `xarrowDashed` using arrow `sym.arrow.dashed`.
- `xarrowDouble` using arrow `sym.arrow.double.long`;
- `xarrowHook` using arrow `sym.arrow.hook`;
- `xarrowSquiggly` using arrow `sym.arrow.long.squiggly`;
- `xarrowTwoHead` using arrow `sym.arrow.twohead`;

These names use camlCase in order to be simply called from math mode. This may
change in the future, if it becomes possible to have the function names
reflect the name of the symbols themselves.

### Example

```
#import "@preview/xarrow:0.1.1": xarrow, xarrowSquiggly

$
  a xarrow(QQ\, 1 + 1^4) b \
  c xarrowSquiggly("very long boi") d
$
```

## Customisation

The `xarrow` function has several named arguments which serve to create new
arrow designs:

- `sym`, the base symbol arrow to use;
- `margins`, the spacing on each side of the `body` argument.
- `sections`, a tuple describing how the symbol is divided by the function. This
  takes two ratios, which cut the symbol in three parts. The central part is
  repeated. This is the parameter that has to be tweaked if observing artefacts.
- `reducible`, a boolean telling whether the symbol can be shorter than the
  original if the given body is too narrow.
- `partial_repeats`, a boolean telling whether the central part of the symbol
  can be partially repeated at the end in order to match the exact desired
  width. This has to be disabled when the repeated part has a clear period (like
  the squiggly arrow).

For the exact default values and customisation examples (using the `with`
method), please refer to the source file.

