# Label Arrows
Draw and style arrows between labels.

# Example
```typst
#import "@preview/larrow:1.0.0": *
#set page(width: 16cm, height: 5cm, margin: (left: 1cm))

#let lal = arrow-label.with(dx: -2mm, dy: -1.5mm)

#lal(<end-left>) *This is an example for label arrows:*
+ This package allows drawing arrows between labels. ~ <start-1>
+ The arrows can be styled in different ways to suit your needs.
+ It's easy to curve the arrow to your liking with the `bend` parameter.
+ Now let's get to the end.
+ This really didn't need to be another point but hey,#sym.zws <end-2> we just
  needed to fill some space. #al(<end-1>) ~

#lal(<start-left>) Everything clear? If not, start from the beginning.
~ <start-2>

#label-arrow(<start-1>, <end-1>, bend: -40, tip: "o", stroke: 1.5pt + red,
             both-offset: (1mm, 2mm))
#label-arrow(<start-left>, <end-left>, bend: -20)
#label-arrow(<start-2>, <end-2>, from-offset: (0pt, 3pt), tip: "straight",
             to-offset: (0pt, -4pt))
```

![Example output of larrow](./example/example.png)

# Quick overview
- Import via `#import "@preview/larrow:1.0.0"`.
- Use `label-arrow(<from-lbl>, <to-lbl>)` to draw an arrow between two labels.
- Use the `bend` parameter to curve the arrow. Positive values make a
  right-handed curve, negative ones a left-handed one.
- Create labels with inbuilt position offsets with
  `arrow-label(<lbl>, dx: 2mm, dy: 4mm)`. Use `#al()` as a shorthand.
- If arrows come out wrong with normal labels, try using `arrow-labels` in
  their stead, which fix their positions better.
- If there is too much whitespace at the location of a label, remove spaces
  around it.

# Usage
## Import
`#import "@preview/larrow:1.0.0": *`

## Functionality
The package makes available two key functions. `label-arrow()` draws arrows
between labels in your document. `arrow-label()` is a special kind of label
that you can define spacial offsets on for your position anchors. Standard
labels and arrow labels can be used either-or or mixed.

One important thing to keep in mind is that all labels used for drawing arrows
should be unique, as otherwise only the first occurence will be found as a
target.

### label-arrow()
This function draws a directional arrow from the provided starting point
(argument `from`) to the provided stopping point (argument `to`).

`from` and `to` are both either standard typst labels (e.g. `<mark>`) or
special `arrow-label`s provided by this package.

The most important optional argument is `bend`, which controls if the arrow
should be curved. A positive value for `bend` will result in a right-handed
curve where a negative value will give a left-handed curve in the arrow.

Other optional parameters are available and listed under the previously
discussed ones below:

- `from` (required) - Starting point of the arrow. Either a typst label like
  `<mark>` or a special `arrow-label` provided by this package.
- `to` (required) - End point of the arrow. Either a typst label or an
  `arrow-label`.
- `bend` (optional) - Curvature control of the arrow. A value of `0` will
  result in a straight arrow. Growing positive values give the arrow an
  increasing right-handed curvature. Shrinking negative values give the arrow
  an increasing left-handed curvature.
    - Default value: `0`
- `tip` (optional) - Defines the tip the arrow will use at its end. Default is
  an unfilled triangle. Any possible value for a cetz mark can be used here.
    - Default value: `"straight"`
    - Possible values: See the
      [CeTZ documentation](https://cetz-package.github.io/docs/basics/marks/)
- `from-tip` (optional) - Defines a tip on the starting side of the arrow.
  The same values are possible as for `tip`, though the default is not to have
  a tip on the starting side.
    - Default value: `none`
    - Possible values: See the
      [CeTZ documentation](https://cetz-package.github.io/docs/basics/marks/)
- `stroke` (optional) - How to stroke the arrow, providing access to color and
  thickness controls. Any value suitable for normal typst stroke fields is
  accepted.
    - Default value: `auto`
- `from-offset` (optional) - An array of two lengths can be given here to
  adjust the position of the starting point of the arrow. This is independent
  of the individual offsets an `arrow-label` might define on its own.
    - Default value: `(0pt, 0pt)`
- `to-offset` (optional) - Offset of the same kind as for `from-offset` but
  applying the adjustment to the ending position of the arrow.
    - Default value: `(0pt, 0pt)`
- `both-offset` (optional) - An offset applied to both the starting and ending
  positions of the arrow. All offsets can be used in combination or
  individually.
    - Default value: `(0pt, 0pt)`
- `debug` (optional): A boolean flag to display the start position, end
  position and control point resulting from the bend parameter of the arrow.
  The start is displayed in green, the end in red and the control point in
  blue.
    - Default value: `false`

### arrow-label()
This function creates a label with attached metadata about offsets for the
position it indicates. None, either or both offsets can be given.

This can also be used to create custom types of arrow labels that have fixed
offsets: `#let list-al = arrow-label.with(dx: -6mm, dy: -1mm)`. This custom
arrow label could be used to automatically move the arrow positioning in front
of bullet or numbered list entries.

Parameters for arrow labels are as follows:

- `lbl` (required) - Label to use for the arrow label.
- `dx` (optional) - X-axis offset for the arrow label. This offset is applied
  in conjunction with any other offsets defined for the whole `label-arrow`.
    - Default value: `0pt`
- `dy` (optional) - Y-axis offset for the arrow label. Works the same as `dx`.
    - Default value: `0pt`

### Shorthands
There are shortened aliases for both `label-arrow` and `arrow-label`.

- `label-arrow()` can also be called as `larw()`.
- `arrow-label()` can also be called as `al()`.

## Set and show alternatives
Neither `#set` nor `#show` can be used with `label-arrow()` or `arrow-label()`.
To set default values or make custom variants with defaults, you can use `#let`
instead to overwrite them with given parameter values:

```typst
#import "@preview/larrow:1.0.0": *

// Make the default tip for arrows a triangle.
#let label-arrow = label-arrow.with(tip: ">")

// Give all arrow-labels a standard Y-axis offset.
#let arrow-label = arrow-label.with(dy: -1mm)
```

# Limitations
Drawing arrows across multiple pages is not supported. If labels are separated
by page boundaries, the resulting drawing will be unpredictable.

If a label is placed before or between content, you may have to do so without a
space in between, to prevent more than necessary whitespace from being created,
e.g. `#al(<start>)This is #al(<end>)my sentence.` This is because even thought
the labels have zero width in the content, spaces between them and other
content still don't get reduced as unecessary whitespace.

When using normal typst labels, the resulting positions may end up somewhere
other than intended. This is because normal labels might attach themselves to
elements other than the word or symbol directly preceeding them, for example
the whole preceeding paragraph. Use `arrow-label`s to prevent this or put `~`
or `#sym.zws` before or after the specific labels to try and give them
something to attach to at the correct position.

# Local package
If you want to use the package locally, you have two options:

1. Download and extract the package folder to your chosen package namespace.
   Check the
   [official documentation](https://github.com/typst/packages?tab=readme-ov-file#local-packages)
   for where to find and create a namespace. Then simply import the package
   from that namespace. The following example assumes a namespace named `local`
   to be used: `#import "@local/larrow:1.0.0": *`

   This makes the package available anywhere on your system via the namespace
   import.
4. Download only the single file named `larrow.typ` and place it next to
   the typst file you wish to use the package in. Then simply import the file
   as follows: `#import "larrow.typ": *`
   
   This method will make the package available only to files that you directly
   copy the source file next to.
