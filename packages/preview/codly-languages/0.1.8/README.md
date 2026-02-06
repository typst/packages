# `codly-languages` - Language configurations for `codly`

Provides a set of predefined language configurations for use with the `codly`
code listing package. For each supported language, this package defines a
name, icon, and color to use when displaying code.

## Usage

Pretty simple. Import `codly`. Initialize it. Import `codly-languages`.
Configure `codly` with the languages. Like this:

```typst
#import "@preview/codly:1.2.0": *
#show: codly-init

#import "@preview/codly-languages:0.1.8": *
#codly(languages: codly-languages)
```

Then use code blocks as you normally would and the output, for supported
languages, should look like this:

![Example code listings](thumbnail.png)

## Contributing

Some languages are still missing. All contributions welcome.

## Icon Attribution

| **Icon** | **Source**                    | **License**                  |
|----------|-------------------------------|------------------------------|
| BibTeX   | [Wikimedia][bibtex-source]    | Public Use                   |
| JQ       | [Wikimedia][jq-source]        | [CC 3.0][jq-license]         |
| Lean     | [WIkimedia][lean-source]      | [Apache 2.0][lean-license]   |
| Strace   | [Wikimedia][strace-source]    | CC 4.0                       |
| Typst    | [Typst Website][typst-source] | [Free to use][typst-license] |

[bibtex-source]: https://commons.wikimedia.org/wiki/Category:BibTeX#/media/File:BibTeX_logo.svg

[jq-source]: https://commons.wikimedia.org/wiki/File:Jq_logo.svg

[jq-license]: https://github.com/itchyny/jq/blob/master/COPYING

[lean-source]: https://commons.wikimedia.org/wiki/File:Lean_logo2.svg

[lean-license]: https://github.com/leanprover/lean4/blob/master/LICENSE

[strace-source]: https://commons.wikimedia.org/wiki/File:Strace_logo.svg

[typst-source]: https://typst.app/

[typst-license]: https://typst.app/legal/brand/

All icons that are not listed in the table come from one of the following icon sets.
Which one can be taken from [`lib.typ`](./lib.typ).

| **Iconset**  | **Source**                   | **License**                |
|--------------|------------------------------|----------------------------|
| Devicon      | [Github][devicon-source]     | [MIT][devicon-license]     |
| VSCode Icons | [Github][vscodeicons-source] | [MIT][vscodeicons-license] |

[devicon-source]: https://github.com/devicons/devicon/

[devicon-license]: https://github.com/devicons/devicon/blob/master/LICENSE

[vscodeicons-source]: https://github.com/vscode-icons/vscode-icons

[vscodeicons-license]: https://github.com/vscode-icons/vscode-icons/blob/master/LICENSE

## License

This package is released under the [MIT License](LICENSE).
