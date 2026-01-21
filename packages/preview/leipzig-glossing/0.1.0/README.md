# Leipzig Glossing in Typst

`leipzig-glossing` is a [Typst](https://github.com/typst/typst) library for
creating interlinear morpheme-by-morpheme glosses according to the [Leipzig
glossing rules](https://www.eva.mpg.de/lingua/pdf/Glossing-Rules.pdf).


The canonical repository for this project is on the [Gitea
instance](https://code.everydayimshuflin.com/greg/typst-lepizig-glossing). The
repository is also [mirrored on
Github](https://github.com/neunenak/typst-leipzig-glossing/). Bug reports and
code contributions are welcome from all users.


Run `typst compile leipzig-gloss-examples.typ` in the root of the repository to
generate a pdf file with examples and documentation. This command is also
codified in the accompanying [justfile](https://github.com/casey/just) as `just
build-example`.

The definitions intended for use by end users are the `#gloss` and
`#numbered_gloss` functions.

## Example

An example gloss entry:

```
#import "@preview/leipzig-glossing:0.1.0: gloss"

#gloss(
  header_text: [Hittite (Lehmann 1982:211)],
  source_text: ([n=an], [apedani], [mehuni],[essandu.]),
  morphemes: ([#smallcaps[conn]=him], [that.#dat.#sg], [time.#dat.#sg], [eat.they.shall]),
  translation: "They shall celebrate him on that date",
)

```

# License
This library uses the MIT license; see `LICENSE.txt`.
