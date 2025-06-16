# hydra
Hydra is a [typst] package allowing you to easily display the heading like elements anywhere in your
document. In short, it will show you the currently active element only when it is not visible.

Some of hydra's features rely on the size of the top-margin, if you use a different page size than
`a4` or a custom top margin for your pages, make sure to configure hydra, otherwise those cheks may
not work.

## Example
```typst
#import "@preview/hydra:0.3.0": hydra

#set page(header: hydra() + line(length: 100%))
#set heading(numbering: "1.1")
#show heading.where(level: 1): it => pagebreak(weak: true) + it

= Introduction
#lorem(750)

= Content
== First Section
#lorem(500)
== Second Section
#lorem(250)
== Third Section
#lorem(500)

= Annex
#lorem(10)
```
![ex1]
![ex2]
![ex3]
![ex4]
![ex5]

## Documentation
For a more in-depth description of hydra's functionality and the reference read its [manual].

## Contribution
### Testing
This package serves as my real-world test for [`typst-test`][typst-test], it is not required for
contributions, but encouraged as it speeds up the review process.

Other than that tests can be run using the following command structure for each test:
```bsh
test=...
typst --root . "tests/typ/${test}.typ" "tests/out/${test}/{n}.png"
# some command to compare images in tests/ref/${test} and tests/out/${test}
```

## Examples and manual
Furthermore, I use [`just`][just] and [`nushell`][nushell] to run common commands. It's once again
not required, as I'll generate those myself if you don't on a PR, but if you already use both you
can run the example and manual generation using `just gen`.

[ex1]: examples/example1.png
[ex2]: examples/example2.png
[ex3]: examples/example3.png
[ex4]: examples/example4.png
[ex5]: examples/example5.png
[manual]: docs/manual.pdf

[typst]: https://github.com/typst/typst
[typst-test]: https://github.com/tingerrr/typst-test
[just]: https://just.systems/
[nushell]: https://www.nushell.sh/
