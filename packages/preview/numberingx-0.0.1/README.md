# numberingx

_Extended numbering patterns using the [CSS Counter Styles] specification, along
with a number of [Ready-made Counter Styles]._

## Usage

```ts
// numberingx is expected to be imported with the syntax creating a named module
#import "@preview/numberingx:0.0.1"

// Use full-width roman numerals for titles, and lowercase ukrainian letters
#set heading(numbering: numberingx.formatter(
  "{fullwidth-upper-roman}.{fullwidth-lower-roman}.{lower-ukrainian}"
))
```

### Patterns

numberingx's patterns are similiar to typst's [numbering patterns] and use the
same notion of fragments with a prefix and a final suffix. The main difference
is that it doesn't use special characters and all numbering styles must be
written within braces. To insert a literal brace, you can double it.

A list of patterns can be found in the [Ready-made Counter Styles] document.
Additionally, numberingx allows typst's numbering characters to be used in
patterns. This way, `"{upper-roman}.{decimal})"` can be shortened to
`"{I}.{1})"`.


### API

numberingx exposes two functions, `format`and `formatter`.

#### `format(fmt, styles: (:), ..nums)`

This function uses the same api as typst's `numbering()` and takes the pattern
string as its first positional argument, and numbers as trailing arguments. An
optional `styles` argument allows for
[user-defined styles](#user-defined-styles).

#### `formatter(fmt, styles: (:))`

This function is little more than a shorter version of `format.with(..)`. It
takes a pattern string and an optional `styles` argument, and return the
matching numbering functions. This is mainly intended to be used for `#set`
rules.

## User-defined styles

Custom styles can be defined according to the [CSS Counter Styles] spec and
passed through a `styles` named argument to `format` and `formatter`. It must be a dictionary mapping style names to style descriptions.

Note that the `prefix`, `suffix`, `pad`, and `speak-as` descriptors are not supported, nor is the `extends` system.

## License

This repository is licensed under [MIT-0], which is the closest I'm legally
allowed to public domain while being OSI approved.

[CSS Counter Styles]: https://www.w3.org/TR/css-counter-styles-3/
[Ready-made Counter Styles]: https://www.w3.org/TR/predefined-counter-styles/
[numbering patterns]: https://typst.app/docs/reference/meta/numbering/
[MIT-0]: https://spdx.org/licenses/MIT-0.html
