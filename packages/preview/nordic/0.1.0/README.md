# nordic
![Test](https://img.shields.io/github/actions/workflow/status/jonaspleyer/nordic-typst/test.yml?style=flat-square&label=Test)

The [nordic](https://github.com/jonaspleyer/nordic) color theme was majorly inspired by the
identically named Neovim colorscheme [nordic.nvim](https://github.com/AlexvZyl/nordic.nvim).

## Usage

To simply apply the colorscheme, use the default settings.
```typst
#import "@preview/nordic:0.1.0" as nordic
#show: nordic.default
```

It is also possible to use individual colors.
For a list of them, please refer directly to the main file
[`nordic.typ`](https://github.com/jonaspleyer/nordic-typst/blob/main/nordic.typ)

```typst
#import "@preview/nordic:0.1.0" as nordic
#rect(fill: nordic.yellow-bright)[Hello World]
```

## License
Download the [MIT License](https://www.mit.edu/~amini/LICENSE.md)

