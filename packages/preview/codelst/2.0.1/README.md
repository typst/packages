# codelst (v2.0.1)

**codelst** is a [Typst](https://github.com/typst/typst) package for rendering sourcecode with line numbers and some other additions.

## Usage

Import the package from the typst preview repository:

```js
#import "@preview/codelst:2.0.1": sourcecode
```

After importing the package, simply wrap any fenced code block in a call to `#sourcecode()`:

````js
#import "@preview/codelst:2.0.1": sourcecode

#sourcecode[```typ
#show "ArtosFlow": name => box[
  #box(image(
    "logo.svg",
    height: 0.7em,
  ))
  #name
]

This report is embedded in the
ArtosFlow project. ArtosFlow is a
project of the Artos Institute.
```]
````

## Further documentation

See `manual.pdf` for a comprehensive manual of the package.

See `example.typ` for some quick usage examples.

## Development

The documentation is created using [Mantys](https://github.com/jneug/typst-mantys), a Typst template for creating package documentation.

To compile the manual, Mantys needs to be available as a local package. Refer to Mantys' manual for instructions on how to do so.

## Changelog

### v2.0.1

This version makes `codelst` compatible to Typst 0.11.0. Version 2.0.1 now requires Typst 0.11.0, since there are some breaking changes to the way counters work.

Thanks to @kilpkonn for theses changes.

### v2.0.0

Version 2 requires Typst 0.9.0 or newer. Rendering is now done using the new
`raw.line` elements get consistent line numbers and syntax highlighting (even
if `showrange` is used). Rendering is now done in a `#table`.

- Added `theme` and `syntaxes` options to overwrite passed in `#raw` values.
- Breaking: Renamed `tab-indend` to `tab-size`, to conform with the Typst option.
- Breaking: Removed `continue-numbering` option for now. (The feature failed in combination with label parsing and line highlights.)
- Breaking: Removed styling of line numbers via a `show`-rule.

### v1.0.0

- Complete rewrite of code rendering.
- New options for `#sourcecode()`:
	- `lang`: Overwrite code language setting.
	- `numbers-first`: First line number to show.
	- `numbers-step`: Only show every n-th number.
	- `frame`: Set a frame (replaces `<codelst>` label.)
	- Merged `line-numbers` and `numbering` options.
- Removed `#numbers-style()` function.
	- `numbers-style` option now gets passed `counter.display()`.
- Removed `<codelst>` label.
- `codelst-style` only sets `breakable` for figures.
- New `codelst` function to setup a catchall show rules for `raw` text.
- `label-regex: none` disables labels parsing.
- Code improvements and refactorings.

### v0.0.5

- Fixed insets for line highlights.
- Added `numbers-width` option to manually set width of line numbers column.
	- This allows line numbers on margins by setting `numbers-width` to `0pt` or a negative number like `-1em`.

### v0.0.4

- Fixed issue with context unaware syntax highlighting.

### v0.0.3

- Removed call to `#read()` from `#sourcefile()`.
- Added `continue-numbering` argument to `#sourcecode()`.
- Fixed problem with `showrange` having out of range line numbers.

### v0.0.2

- Added a comprehensive manual.
- Fixed crash for missing `lang` attribute in `raw` element.

### v0.0.1

- Initial version submitted to typst/packages.
