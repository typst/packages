# num2words

A Typst package that converts numbers to their written word form.

## Usage

Check out the [package manual][manual] for detailed documentation. Here's a quick example:

```typst
#import "@preview/num2words:0.1.0": num2words

// Uses the current text language (auto-detection)
#num2words(42) // "forty-two"

// Explicit language code
#num2words(100, lang: "en") // "one hundred"
```

The `num2words` function accepts:

- `number` (int) — the number to convert.
- `lang` (str or auto) — the language code. When `auto` (the default), uses the current `text.lang`.

## Supported languages

| Language | Code |
| --- | --- |
| English (US) | `en` |

More languages are planned. Contributions are welcome!

## Contributing

Feel free to open an [issue][issues] to report bugs, request features, or suggest support for new languages. Pull
requests are also appreciated.

### Development environment

The easiest way to set up the development environment is with [devenv][devenv] (Nix-based). Once installed, run `devenv
shell` to enter the dev shell with all tooling available.

If you prefer a manual setup, you will need the following tools:

- [Typst][typst] (>=0.14.0): the Typst compiler.
- [just][just]: command runner for common tasks.
- [tytanic][tytanic] (`tt`): test runner for Typst.
- [typstyle][typstyle]: Typst formatter.
- [prek][prek]: pre-commit hook manager. Run `prek install -t pre-commit -t commit-msg` to install hooks.

### Key commands

As mentioned, the `just` command runner is used to simplify common tasks. Here are some key commands:

- `just test`: run all tests.
- `just format-typst` (or `just ft`): format Typst files.

Check the [justfile](/justfile) for the full list of commands.

### Commit conventions

This project follows [Conventional Commits][conventional-commits]. The convention is enforced by a
[commitizen][commitizen] pre-commit hook, so make sure hooks are installed before committing.

## License

This project is licensed under the GNU Lesser General Public License v3.0. See the [LICENSE](/LICENSE) file for details.

<!-- External links -->

[manual]: https://mariovagomarzal.github.io/typst-num2words/manual.pdf
[typst]: https://typst.app/
[issues]: https://github.com/mariovagomarzal/typst-num2words/issues
[devenv]: https://devenv.sh/
[just]: https://just.systems/
[tytanic]: https://typst-community.github.io/tytanic/
[typstyle]: https://github.com/Enter-tainer/typstyle
[prek]: https://github.com/j178/prek
[conventional-commits]: https://www.conventionalcommits.org/
[commitizen]: https://commitizen-tools.github.io/commitizen/
