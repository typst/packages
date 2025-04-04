# Chic-header (v0.5.0)
**Chic-header** (chic-hdr) is a Typst package for creating elegant headers and footers

## Usage

To use this library through the Typst package manager (for Typst 0.6.0 or greater), write `#import "@preview/chic-hdr:0.5.0": *` at the beginning of your Typst file. Once imported, you can start using the package by writing the instruction `#show: chic.with()` and giving any of the chic functions inside the parenthesis `()`.

_**Important: If you are using a custom template that also needs the `#show` instruction to be applied, prefer to use `#show: chic()` after the template's `#show`.**_

For example, the code below...

```typst
#import "@preview/chic-hdr:0.5.0": *

#set page(paper: "a7")

#show: chic.with(
  chic-footer(
    left-side: strong(
        link("mailto:admin@chic.hdr", "admin@chic.hdr")
    ),
    right-side: chic-page-number()
  ),
  chic-header(
    left-side: emph(chic-heading-name(fill: true)),
    right-side: smallcaps("Example")
  ),
  chic-separator(1pt),
  chic-offset(7pt),
  chic-height(1.5cm)
)

= Introduction
#lorem(30)

== Details
#lorem(70)
```

...will look like this:

<h3 align="center">
  <img alt="Usage example" src="assets/usage.png" style="max-width: 100%; padding: 10px 10px; background-color: #E4E5EA; box-shadow: 1pt 1pt 10pt 0pt #AAAAAA; border-radius: 4pt">
</h3>

## Reference

_Note: For a detailed explanation of the functions and parameters, see [Chic-header's Manual.pdf](https://github.com/Pablo-Gonzalez-Calderon/chic-header-package)_

While using `#show: chic.with()`, you can give the following parameters inside the parenthesis:
- `width`: Indicates the width of headers and footers in all the document (default is `100%`).
- `skip`: Which pages must be skipped for setting its header and footer. Other properties changed with `chic-height()` or `chic-offset()` are preserved. Giving a negative index causes a skip of the last pages using last page as index -1(default is `()`).
- `even`: Header and footer for even pages. Here, only `chic-header()`, `chic-footer()` and `chic-separator()` functions will take effect. Other functions must be given as an argument of `chic()`.
- `odd`: Sets the header and footer for odd pages. Here, only `chic-header()`, `chic-footer()` and `chic-separator()` functions will take effect. Other functions must be given as an argument of `chic()`.
- `..functions()`: These are a variable number of arguments that corresponds to Chic-header’s style functions.

### Functions

1. `chic-header()` - Sets the header content.
    - `v-center`: Whether to vertically align the header content, or not (default is `false`).
    - `side-width`: Custom width for the sides. It can be an 3-element-array, length or relative length (default is `none` and widths are set to ``1fr`` if a side is present).
    - `left-side`: Content displayed in the left side of the header (default is `none`).
    - `center-side`: Content displayed in the center of the header (default is `none`).
    - `right-side`: Content displayed in the right side of the header (default is `none`).
2. `chic-footer()` - Sets the footer content.
    - `v-center`: Whether to vertically align the header content, or not (default is `false`).
    - `side-width`: Custom width for the sides. It can be an 3-element-array, length or relative length (default is `none` and widths are set to ``1fr`` if a side is present).
    - `left-side`: Content displayed in the left side of the footer (default is `none`).
    - `center-side`: Content displayed in the center of the footer (default is `none`).
    - `right-side`: Content displayed in the right side of the footer (default is `none`).
3. `chic-separator()` - Sets the separator for either the header, the footer or both.
    - `on`: Where to apply the separator. It can be `"header"`, `"footer"` or `"both"` (default is `"both"`).
    - `outset`: Space around the separator beyond the page margins (default is `0pt`).
    - `gutter`: How much spacing insert around the separator (default is `0.65em`).
    - (unnamed): A length for a `line()`, a stroke for a `line()`, or a custom content element.
4. `chic-styled-separator()` - Returns a pre-made custom separator for using it in `chic-separator()`
    - `color`: Separator's color (default is `black`).
    - (unnamed): A string indicating the separator's style. It can be `"double-line"`, `"center-dot"`, `"bold-center"`, or `"flower-end"`.
4. `chic-height()` - Sets the height of either the header, the footer or both.
    - `on`: Where to change the height. It can be `"header"`, `"footer"` or `"both"` (default is `"both"`).
    - (unnamed): A relative length (the new height value).
5. `chic-offset()` - Sets the offset of either the header, the footer or both (relative to the page content).
    - `on`: Where to change the offset It can be `"header"`, `"footer"` or `"both"` (default is `"both`).
    - (unnamed): A relative length (the new offset value).
6. `chic-page-number()` - Returns the current page number. Useful for header and footer `sides`. It doesn’t take any parameters.
7. `chic-heading-name()` - Returns the next heading name in the `dir` direction. The heading must have a lower or equal level than `level`. If there're no more headings in that direction, and `fill` is ``true``, then headings are sought in the other direction.
    - `dir`: Direction for searching the next heading: ``"next"`` (from the current page, get the next heading) or ``"prev"`` (from the current page, get the previous heading). Default is `"next"`.
    - `fill`: If there's no more headings in the `dir` direction, indicates whether to try to get a heading in the opposite direction (default is ``false``).
    - `level`: Up to what level of headings should this function search (default is ``2``).

## Gallery

<h3 align="center">
  <img alt="Example 1" src="assets/example-1.png" style="max-width: 100%; padding: 10px 10px; background-color: #E4E5EA; box-shadow: 1pt 1pt 10pt 0pt #AAAAAA; border-radius: 4pt">
</h3>

_Header with `chic-heading-name()` at left, and `chic-page-number()` at right. There's a `chic-separator()` of `1pt` only for the header._

<h3 align="center">
  <img alt="Example 2" src="assets/example-2.png" style="max-width: 100%; padding: 10px 10px; background-color: #E4E5EA; box-shadow: 1pt 1pt 10pt 0pt #AAAAAA; border-radius: 4pt">
</h3>

_Footer with `chic-page-number()` at right, and a custom `chic-separator()` showing "end of page (No. page)" between 9 `~` symbols at each side._

## Changelog

### Version 0.1.0

- Initial release
- Implemented `chic-header()`, `chic-footer()`, `chic-separator()`, `chic-height()`, `chic-offset()`, `chic-page-number()`, and `chic-heading-name()` functions

### Version 0.2.0

_Thanks to Slashformotion (<https://github.com/slashformotion>) for noticing this version bugs, and suggesting a vertical alignment for headers._

- Fix alignment error in `chic-header()` and `chic-footer()`
- Add `v-center` option for `chic-header()` and `chic-footer()`
- Add `outset` option for `chic-separator()`
- Add `chic-styled-separator()` function

### Version 0.3.0

- Add `side-width` option for `chic-header()` and `chic-footer()`

### Version 0.4.0

_Thanks to David (<https://github.com/davidleejy>) for being interested in the package and giving feedback and ideas for new parameters_

- Update ``type()`` conditionals to met Typst 0.8.0 standards
- Add `dir`, `fill`, and `level`parameters to ``chic-heading-name()``
- Allow negative indexes for skipping final pages while using `skip`
- Include some panic alerts for types mismatch
- Upload manual code in the package repository


### Version 0.5.0

_Thanks to PgBiel (<https://github.com/PgBiel>) for contributing to this version._

- Update base code to Typst 0.12.0 standards.