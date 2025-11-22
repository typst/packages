# `codly-languages` - Language configurations for `codly`

Provides a set of predefined language configurations for use with the `codly`
code listing package. For each supported language, this package defines a
name, icon, and color to use when displaying code.

## Usage

Pretty simple. Import `codly`. Initialize it. Import `codly-languages`.
Configure `codly` with the languages. Like this:

```typst
#import "@preview/codly:1.1.1": *
#show: codly-init

#import "@preview/codly-languages:0.1.5": *
#codly(languages: codly-languages)
```

Then use code blocks as you normally would and the output, for supported
languages, should look like this:

![Example code listings](thumbnail.png)

## Contributing

Some languages are still missing. All contributions welcome.

## Icon Attribution

| **Icon**          | **Source**                               | **License**                  |
| ----------------- | ---------------------------------------- | ---------------------------- |
| `css3.svg`        | [CSS-Next/logo.css][css3-source]         | [CC0][css3-license]          |
| `cuda.svg`        | [vscode-icons/vscode-icons][cuda-source] | [MIT][cuda-license]          |
| `lisp.svg`        | [Wikipedia (User:Jooja)][lisp-source]    | [CC BY-SA 4.0][lisp-license] |
| `typst-small.png` | [Dherse/codly][typst-source]             | [MIT][typst-license]         |

[css3-source]: https://github.com/CSS-Next/logo.css/blob/main/css.svg?short_path=c59d4da
[css3-license]: https://github.com/CSS-Next/logo.css/blob/main/LICENSE
[cuda-source]: https://github.com/vscode-icons/vscode-icons/tree/master
[cuda-license]: https://github.com/vscode-icons/vscode-icons/blob/master/LICENSE
[lisp-source]: https://commons.wikimedia.org/wiki/File:Lisp_logo.svg
[lisp-license]: https://commons.wikimedia.org/wiki/File:Lisp_logo.svg#Licensing
[typst-source]: https://github.com/Dherse/codly
[typst-license]: https://github.com/Dherse/codly/blob/main/LICENSE

All icons not listed in this table come from the
[devicons/devicon][default-source] project, [MIT licensed][default-license].

[default-source]: https://github.com/devicons/devicon/
[default-license]: https://github.com/devicons/devicon/blob/master/LICENSE

## License

This package is released under the [MIT License](LICENSE).
