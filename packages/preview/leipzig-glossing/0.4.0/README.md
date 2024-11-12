# Leipzig Glossing in Typst

`leipzig-glossing` is a [Typst](https://github.com/typst/typst) library for
creating interlinear morpheme-by-morpheme glosses according to the [Leipzig
glossing rules](https://www.eva.mpg.de/lingua/pdf/Glossing-Rules.pdf).

# Documentation

Run `typst compile documentation.typ` in the root of the repository to
generate a pdf file with examples and documentation. This command is also
codified in the accompanying [justfile](https://github.com/casey/just) as `just
build-doc`.

The definitions intended for use by end users are the `gloss` and
`numbered-gloss` functions, and the `abbreviations` submodule.


# Contributing

## Repositories

The canonical repository for this project is on the [Gitea
instance](https://code.everydayimshuflin.com/greg/typst-lepizig-glossing).

There is also a [Github mirror](https://github.com/neunenak/typst-leipzig-glossing/), and
a [Radicle](https://radicle.xyz) mirror available at <rad://z2j7vQLS3EtQbPkrzi7Tn2XR7YWLw>.

Bug reports and code contributions are welcome from all users.

## License
This library uses the MIT license; see `LICENSE.txt`.

## Contributors

Thanks to [Bethany E. Toma](https://github.com/betoma) for a number of
suggestions and improvements.

Thanks to [Maja Abramski-Kronenberg](https://github.com/rwmpelstilzchen) for
the labeling functionality.
