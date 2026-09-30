# num2words

A Typst package that converts numbers to their written word form.

## Usage

Check out the [package manual][manual] for detailed documentation. Here's a quick example:

```typst
#import "@preview/num2words:0.2.0": num2words

// Auto-detection from `text.lang`
#set text(lang: "en")
#num2words(42) // "forty-two"

#set text(lang: "es")
#num2words(42) // "cuarenta y dos"

// Explicit language code overrides `text.lang`
#num2words(100, lang: "en") // "one hundred"
#num2words(100, lang: "es") // "cien"

// Some languages have different number forms
#num2words(1, lang: "en", form: "ordinal") // "first"
#num2words(1, lang: "es", form: "ordinal") // "primero"
```

The `num2words` function _always_ accepts:

- `number` (int) — the number to convert.
- `lang` (str or auto) — the language code. When `auto` (the default), uses the current `text.lang`.

Other langugages might support additional parameters.

## Supported languages

| Language | Code |
| --- | --- |
| English (US) | `en` |
| Spanish | `es` |
| Catalan | `ca` |

More languages are planned. Contributions are welcome!

## Contributing

Contributions are welcome! See [CONTRIBUTING.md](/CONTRIBUTING.md) for development setup and guidelines. Also, you're
always welcome to open an [issue][issues] to report bugs, request features, or suggest support for new languages.

## License

This project is licensed under the GNU Lesser General Public License v3.0. See the [LICENSE](/LICENSE) file for details.

<!-- External links -->

[manual]: https://mariovagomarzal.github.io/typst-num2words/manual.pdf
[issues]: https://github.com/mariovagomarzal/typst-num2words/issues
