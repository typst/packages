# Typst Hidden-Bib

[GitHub Repository including Examples](https://github.com/pklaschka/typst-hidden-bib)

A Typst package to create hidden bibliographies or bibliographies with unmentioned (hidden) citations.

## Use Cases

### Hidden Bibliographies

In some documents, such as a letter, you may want to cite a reference without printing a bibliography.

This can easily be achieved by wrapping your `bibliography(...)` with the `hidden-bibliography` function after importing the `hidden-bib` package.

The code then looks like this:

```typ
#import "@preview/hidden-bib:0.1.0": hidden-bibliography

#lorem(20) @example1
#lorem(40) @example2[p. 2]

#hidden-bibliography(
  bibliography("/refs.yml")
)
```

_Note that this automatically sets the `style` option to `"chicago-notes"` unless you specify a different style._

### Hidden Citations

In some documents, it may be necessary to include items in your bibliography which weren't explicitly cited at any specific point in your document.

The code then looks like this:

```typ
#import "@preview/hidden-bib:0.1.0": hidden-cite

#hidden-cite("example1")
```

### Multiple Hidden Citations

If you want to include a large number of items in your bibliography without having to use `hidden-cite` (to still get autocompletion in the web editor), you can use the `hidden-citations` environment.

The code then looks like this:

```typ
#import "@preview/hidden-bib:0.1.0": hidden-citations

#hidden-citations[
  @example1
  @example2
]
```

## FAQ

### Why would I want to have hidden citations and a hidden bibliography?

You don't. While this package solves both (related) problems, you should only use one of them at a time. Otherwise, you'll simply see nothing at all.

### Why would I want to have hidden citations?

That's for you to decide. It essentially enables you to include "uncited references", similar to LaTeX's `\nocite{}` command.

## License

This package is licensed under the MIT license. See the [LICENSE](./LICENSE) file for details.
