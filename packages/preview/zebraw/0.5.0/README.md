
# 🦓 Zebraw

<a href="https://typst.app/universe/package/zebraw">
<img src="https://img.shields.io/badge/dynamic/xml?url=https%3A%2F%2Ftypst.app%2Funiverse%2Fpackage%2Fzebraw&query=%2Fhtml%2Fbody%2Fdiv%2Fmain%2Fdiv%5B2%5D%2Faside%2Fsection%5B2%5D%2Fdl%2Fdd%5B3%5D&logo=typst&label=Universe&color=%2339cccc" />
</a>

Zebraw is a lightweight and fast package for displaying code blocks with line numbers in Typst, supporting code line highlighting. The term _**zebraw**_ is a combination of _**zebra**_ and _**raw**_, as the highlighted lines display in the code block with a zebra-striped pattern.

## Quick Start

Import the `zebraw` package with `#import "@preview/zebraw:0.5.0": *` then add `#show: zebraw` to start using zebraw in the simplest way.

<p align="center"><a href="assets/1.typ"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/1_Dark.svg"><img alt="typst-block" src="assets/1_Light.svg" /></picture></a></p>

To manually render specific code blocks with zebraw, use the `#zebraw()` function:

<p align="center"><a href="assets/2.typ"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/2_Dark.svg"><img alt="typst-block" src="assets/2_Light.svg" /></picture></a></p>

## Features

The `zebraw` function provides a variety of parameters to customize the appearance and behavior of code blocks. The following sections describe these parameters in detail:

- **Core Features**
  - Line numbering, with customizable offset and range slicing
  - Line highlighting and explanatory comments for code
  - Headers and footers
  - Language identifier tabs
  - The indentation line and hanging indentation (and fast preview mode for better performance)
- **Customization Options**
  - Custom colors for background, highlights, and comments
  - Custom fonts for different elements
  - Customizable insets
  - Custom themes
- **Export Options**
  - Experimental HTML export

### Line Numbering

Line numbers appear on the left side of the code block. Change the starting line number by passing an integer to the `numbering-offset` parameter. The default value is `0`.

<p align="center"><a href="assets/3.typ"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/3_Dark.svg"><img alt="typst-block" src="assets/3_Light.svg" /></picture></a></p>

To disable line numbering, pass `false` to the `numbering` parameter:

<p align="center"><a href="assets/4.typ"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/4_Dark.svg"><img alt="typst-block" src="assets/4_Light.svg" /></picture></a></p>

### Numbering Separator

You can add a separator line between line numbers and code content by setting the `numbering-separator` parameter to `true`:

<p align="center"><a href="assets/5.typ"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/5_Dark.svg"><img alt="typst-block" src="assets/5_Light.svg" /></picture></a></p>

### Line Slicing

Slice code blocks by passing the `line-range` parameter to the `zebraw` function. The `line-range` parameter can be either:

- An array of 2 integers representing the range <a href="assets/6.typ"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/6_Dark.svg"><img style="vertical-align: -0.35em" alt="typst-block" src="assets/6_Light.svg" /></picture></a> (<a href="assets/7.typ"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/7_Dark.svg"><img style="vertical-align: -0.35em" alt="typst-block" src="assets/7_Light.svg" /></picture></a> can be `none` as this feature is based on Typst array slicing)
- A dictionary with `range` and `keep-offset` keys

When `keep-offset` is set to `true`, line numbers maintain their original values. Otherwise, they reset to start from 1. By default, `keep-offset` is set to `true`.

<p align="center"><a href="assets/8.typ"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/8_Dark.svg"><img alt="typst-block" src="assets/8_Light.svg" /></picture></a></p>

### Line Highlighting

Highlight specific lines in the code block by passing the `highlight-lines` parameter to the `zebraw` function. The `highlight-lines` parameter accepts either a single line number or an array of line numbers.

<p align="center"><a href="assets/9.typ"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/9_Dark.svg"><img alt="typst-block" src="assets/9_Light.svg" /></picture></a></p>

### Comments

Add explanatory comments to highlighted lines by passing an array of line numbers and comments to the `highlight-lines` parameter.

<p align="center"><a href="assets/10.typ"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/10_Dark.svg"><img alt="typst-block" src="assets/10_Light.svg" /></picture></a></p>

Comments begin with a flag character, which is `">"` by default. Change this flag by setting the `comment-flag` parameter:

<p align="center"><a href="assets/11.typ"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/11_Dark.svg"><img alt="typst-block" src="assets/11_Light.svg" /></picture></a></p>

To disable the flag feature entirely, pass an empty string `""` to the `comment-flag` parameter (this also disables comment indentation):

<p align="center"><a href="assets/12.typ"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/12_Dark.svg"><img alt="typst-block" src="assets/12_Light.svg" /></picture></a></p>

### Headers and Footers

You can add headers and footers to code blocks. One approach is to use special keys in the `highlight-lines` parameter:

<p align="center"><a href="assets/13.typ"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/13_Dark.svg"><img alt="typst-block" src="assets/13_Light.svg" /></picture></a></p>

Alternatively, use the dedicated `header` and `footer` parameters for cleaner code:

<p align="center"><a href="assets/14.typ"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/14_Dark.svg"><img alt="typst-block" src="assets/14_Light.svg" /></picture></a></p>

### Language Tab

Display a floating language identifier tab in the top-right corner of the code block by setting `lang` to `true`:

<p align="center"><a href="assets/15.typ"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/15_Dark.svg"><img alt="typst-block" src="assets/15_Light.svg" /></picture></a></p>

Customize the language display by passing a string or content to the `lang` parameter:

<p align="center"><a href="assets/16.typ"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/16_Dark.svg"><img alt="typst-block" src="assets/16_Light.svg" /></picture></a></p>

### Indentation Lines, Hanging Indentation and Fast Preview

Display indentation guides by passing a positive integer to the `indentation` parameter, representing the number of spaces per indentation level:

<p align="center"><a href="assets/17.typ"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/17_Dark.svg"><img alt="typst-block" src="assets/17_Light.svg" /></picture></a></p>

Enable hanging indentation by setting `hanging-indent` to `true`:

<p align="center"><a href="assets/18.typ"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/18_Dark.svg"><img alt="typst-block" src="assets/18_Light.svg" /></picture></a></p>

Indentation lines can slow down preview performance. For faster previews, enable fast preview mode by passing `true` to the `fast-preview` parameter in `zebraw-init` or by using `zebraw-fast-preview` in the CLI. This renders indentation lines as simple `|` characters:

<p align="center"><a href="assets/19.typ"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/19_Dark.svg"><img alt="typst-block" src="assets/19_Light.svg" /></picture></a></p>

### Themes

Zebraw includes built-in themes. PRs for additional themes are welcome!

<p align="center"><a href="assets/20.typ"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/20_Dark.svg"><img alt="typst-block" src="assets/20_Light.svg" /></picture></a></p>

<p align="center"><a href="assets/21.typ"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/21_Dark.svg"><img alt="typst-block" src="assets/21_Light.svg" /></picture></a></p>

### (Experimental) HTML Export

See [example-html.typ](example-html.typ) or [GitHub Pages](https://hongjr03.github.io/typst-zebraw/) for more information.

## Customization

There are three ways to customize code blocks in your document:

1. **Per-block customization**: Manually style specific blocks using the `#zebraw()` function with parameters.
2. **Local customization**: Apply styling to all subsequent raw blocks with `#show: zebraw.with()`. This affects all raw blocks after the `#show` rule, **except** those created manually with `#zebraw()`.
3. **Global customization**: Use `#show: zebraw-init.with()` to affect **all** raw blocks after the rule, **including** those created manually with `#zebraw()`. Reset to defaults by using `zebraw-init` without parameters.

### Inset

Customize the padding around each code line(numberings are not affected) by passing a dictionary to the `inset` parameter:

<p align="center"><a href="assets/22.typ"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/22_Dark.svg"><img alt="typst-block" src="assets/22_Light.svg" /></picture></a></p>

### Colors

Customize the background color with a single color or an array of alternating colors:

<p align="center"><a href="assets/23.typ"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/23_Dark.svg"><img alt="typst-block" src="assets/23_Light.svg" /></picture></a></p>

Set the highlight color for marked lines with the `highlight-color` parameter:

<p align="center"><a href="assets/24.typ"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/24_Dark.svg"><img alt="typst-block" src="assets/24_Light.svg" /></picture></a></p>

Change the comment background color with the `comment-color` parameter:

<p align="center"><a href="assets/25.typ"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/25_Dark.svg"><img alt="typst-block" src="assets/25_Light.svg" /></picture></a></p>

Set the language tab background color with the `lang-color` parameter:

<p align="center"><a href="assets/26.typ"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/26_Dark.svg"><img alt="typst-block" src="assets/26_Light.svg" /></picture></a></p>

### Font

Customize font properties for comments, language tabs, and line numbers by passing a dictionary to the `comment-font-args`, `lang-font-args`, or `numbering-font-args` parameters respectively.

If no custom `lang-font-args` are provided, language tabs inherit the comment font styling:

<p align="center"><a href="assets/27.typ"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/27_Dark.svg"><img alt="typst-block" src="assets/27_Light.svg" /></picture></a></p>

Example with custom language tab styling:

<p align="center"><a href="assets/28.typ"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/28_Dark.svg"><img alt="typst-block" src="assets/28_Light.svg" /></picture></a></p>

### Extend

Extend at vertical is enabled at default. When there's header or footer it will be automatically disabled.

<p align="center"><a href="assets/29.typ"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/29_Dark.svg"><img alt="typst-block" src="assets/29_Light.svg" /></picture></a></p>

## Example

<p align="center"><a href="assets/30.typ"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/30_Dark.svg"><img alt="typst-block" src="assets/30_Light.svg" /></picture></a></p>

## License

Zebraw is licensed under the MIT License. See the [LICENSE](LICENSE) file for more information.
