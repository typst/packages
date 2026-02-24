![Polylux logo](https://raw.githubusercontent.com/polylux-typ/polylux/ed1e70e74f2a525e80ace9144249c9537917731c/assets/polylux-logo.svg)

# Jotter

A template for creating presentation slides with Typst and
[Polylux](https://github.com/polylux-typ/polylux/) that look like they come
straight out of your personal notebook.

Use via
```sh
typst init @preview/jotter-polylux:0.1.0 your-cool-project
```

A `slides.typ` file will be created for you and contains all the design elements
you can use.

By default, it uses the fonts
[Kalam](https://github.com/itfoundry/kalam/releases),
[Pennstander Math](https://github.com/juliusross1/Pennstander), and
[Fantastque Sans Mono](https://github.com/belluzj/fantasque-sans/releases).
Either make sure you have them installed or specify other fonts in the template.

This is an opinionated template on purpose.
However, if you like the overall handwritten asthetic but prefer not to have the
spiral binding to the left and/or the dots in the background, you can disable
them by setting the `binding` and `dots` keyword arguments to `false` in the
`setup` function.

![thumbnail](thumbnail.png)


