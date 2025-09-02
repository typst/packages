# Pergamon: BibLaTeX-style bibliographies for Typst

Pergamon is a package for typesetting bibliographies in Typst.
It is inspired by [BibLaTeX](https://ctan.org/pkg/biblatex), in that 
the way in which it typesets bibliographies can be easily customized
through Typst code. Like Typst's regular bibliography management model,
Pergamon can be configured to use different styles for typesetting
references and citations; unlike it, these styles are all defined through
Typst code, rather than CSL. 

Pergamon is documented in the [user guide](https://github.com/alexanderkoller/pergamon/blob/main/docs/pergamon-0.2.0.pdf).
See a somewhat complex example: [Typst](https://github.com/alexanderkoller/pergamon/blob/main/example.typ), [PDF](https://github.com/alexanderkoller/pergamon/blob/main/example.pdf).

Pergamon has a number of advantages over the builtin Typst bibliographies:

- Pergamon styles are simply pieces of Typst code and can be easily configured or modified.
- The document can be easily split into different `refsection`s, each of which can have its own bibliography
  (similar to [Alexandria](https://typst.app/universe/package/alexandria/)).
- Paper titles can be automatically made into hyperlinks - as in [blinky](https://typst.app/universe/package/blinky/), but much more flexibly and correctly.
- Bibliographies can be filtered, and bibliography entries programmatically highlighted, which is useful e.g. for CVs.
- References retain nonstandard Bibtex fields ([unlike in Hayagriva](https://github.com/typst/hayagriva/issues/240)),
  making it e.g. possible to split bibliographies based on keywords.

At the same time, Pergamon is very new and has a number of important limitations compared to
the builtin system. I have implemented those parts of Pergamon that I need for my own writing,
but I would welcome your pull request to make it more feature-complete.

- Pergamon currently supports only bibliographies in Bibtex format, not the Hayagriva YAML format. 
- Only a handful of styles are supported at this point, in contrast to the large number of available CSL styles. Pergamon comes with implementations of the BibLaTeX styles `numeric`, `alphabetic`, and `authoryear`.
- Pergamon still requires a lot of testing and tweaking.

[Pergamon](https://en.wikipedia.org/wiki/Pergamon) was an ancient Greek city state in Asia Minor.
Its library was second only to the Library of Alexandria around 200 BC.



## Example

The following piece of code typesets a bibliography using Pergamon.

  ```typ
#import "@preview/pergamon:0.2.0": *

#let style = format-citation-numeric()

#add-bib-resource(read("bibliography.bib"))

#refsection(format-citation: style.format-citation)[
  ... some text here ...
  #cite("bender20:_climb_nlu")

  #print-bibliography(
       format-reference: format-reference(reference-label: style.reference-label), 
       label-generator: style.label-generator)
]
  ```

It generates citations and a bibliography that look like this:

<img src="https://github.com/alexanderkoller/pergamon/blob/main/doc-materials/example-output.png" style='border:1px solid #000000' />

You can try out [a more complex example](https://github.com/alexanderkoller/pergamon/blob/main/example.typ) yourself;
here's [the PDF it generates](https://github.com/alexanderkoller/pergamon/blob/main/example.pdf).

## Documentation

Please see the [Pergamon guide](https://github.com/alexanderkoller/pergamon/blob/main/docs/pergamon-0.2.0.pdf) for more details.

