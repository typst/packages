# tudelft-tools-novanext

This package provides some Utility functions to be used by tudelft-thesis-novanext and tudelft-presentation-novanext:

- `#multicite` removes all square brackets from the argument, and adds an outer pair of square brackets, to replace, e.g. `[1], [2]` by `[1, 2]`.
- `#ipsum` generates lorem ipsum, but removes a number of words from the beginning. For example, `#ipsum(2, 1)` returns `Ipsum dolor`
- `#if-classic-else` is a simple switch to choose contents depending on whether the style is 'classic'. It is used, e.g., in the last slide of the template `tudelft-presentation-novanext`
- `#tud-logo(full: true, U: tud-blue, font: none, fill: black, ..args)` inserts the TUDelft logo.
  - `full` determines whether the text 'Delft University of Technology' is inserted on the right of the logo.
  - `U` determines the color of the 'U', which is TUDelft blue by default.
  - `font` can be used to change the font family.
  - `fill` determines the color of everything but the 'U'.
  - `..args` are passed to the function `image(..)` which inserts the logo.
- `#flame(fill: black, ..args)` inserts only the flame from the logo.

- `#set-fonts(it)` applies most font settings following the TUDelft corporate style
- `#set-fonts-classic(it)` replaces the fonts by a more default-Typst look, which is compatible with the templates
- `#aspect-ratio-symbol` is an [elembic](https://pgbiel.github.io/elembic/) element inserting a wing aspect ratio symbol as used, e.g., by https://arc.aiaa.org/doi/10.2514/3.9252
- `#AR` is a more practical function to use the wing aspect ratio symbol in a mathematical formula

Submodules `tud-color-cmyk` and `tud-color-rgb` define the colors of the TUDelft corporate style in cmyk and rgb color space, respectively.

Licensed under the MIT-0 License. No attribution is required, but it is appreciated.