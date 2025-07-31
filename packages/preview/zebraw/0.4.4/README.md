
# 🦓 Zebraw

<a href="https://typst.app/universe/package/zebraw">
<img src="https://img.shields.io/badge/dynamic/xml?url=https%3A%2F%2Ftypst.app%2Funiverse%2Fpackage%2Fzebraw&query=%2Fhtml%2Fbody%2Fdiv%2Fmain%2Fdiv%5B2%5D%2Faside%2Fsection%5B2%5D%2Fdl%2Fdd%5B3%5D&logo=typst&label=Universe&color=%2339cccc" />
</a>

Zebraw is a lightweight and fast package for displaying code blocks with line numbers in typst, supporting code line highlighting. The term _**zebraw**_ is a combination of _**zebra**_ and _**raw**_, for the highlighted lines will be displayed in the code block like a zebra lines.

## Starting

Import `zebraw` package by `#import "@preview/zebraw:0.4.4": *` then follow with `#show: zebraw` to start using zebraw in the simplest way. To manually display some specific code blocks in zebraw, you can use `#zebraw()` function:

<p align="center"><a href="assets/1.typ"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/1_Dark.svg"><img alt="typst-block" src="assets/1_Light.svg" /></picture></a></p>

## Features

### Line Numbering

Line numbers will be displayed on the left side of the code block. By passing an integer to the `numbering-offset` parameter, you can change the starting line number. The default value is `0`.

<p align="center"><a href="assets/2.typ"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/2_Dark.svg"><img alt="typst-block" src="assets/2_Light.svg" /></picture></a></p>

### Line Highlighting

You can highlight specific lines in the code block by passing the `highlight-lines` parameter to the `zebraw` function. The `highlight-lines` parameter can be a single line number or an array of line numbers.

<p align="center"><a href="assets/3.typ"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/3_Dark.svg"><img alt="typst-block" src="assets/3_Light.svg" /></picture></a></p>

### Comment

You can add comments to the highlighted lines by passing an array of line numbers and comments to the `highlight-lines` parameter.

<p align="center"><a href="assets/4.typ"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/4_Dark.svg"><img alt="typst-block" src="assets/4_Light.svg" /></picture></a></p>

Comments can begin with a flag, which is `">"` by default. You can change the flag by passing the `comment-flag` parameter to the `zebraw` function:

<p align="center"><a href="assets/5.typ"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/5_Dark.svg"><img alt="typst-block" src="assets/5_Light.svg" /></picture></a></p>

To disable the flag feature, pass `""` to the `comment-flag` parameter (the indentation of the comment will be disabled as well):

<p align="center"><a href="assets/6.typ"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/6_Dark.svg"><img alt="typst-block" src="assets/6_Light.svg" /></picture></a></p>

### Header and Footer

Usually, the comments passing by a dictionary of line numbers and comments are used to add a header or footer to the code block:

<p align="center"><a href="assets/7.typ"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/7_Dark.svg"><img alt="typst-block" src="assets/7_Light.svg" /></picture></a></p>

Or you can use `header` and `footer` parameters to add a header or footer to the code block:

<p align="center"><a href="assets/8.typ"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/8_Dark.svg"><img alt="typst-block" src="assets/8_Light.svg" /></picture></a></p>

### Language Tab

If `lang` is set to `true`, then there will be a language tab on the top right corner of the code block:

<p align="center"><a href="assets/9.typ"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/9_Dark.svg"><img alt="typst-block" src="assets/9_Light.svg" /></picture></a></p>

Customize the language to display by pass a string or content to the `lang` parameter.

<p align="center"><a href="assets/10.typ"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/10_Dark.svg"><img alt="typst-block" src="assets/10_Light.svg" /></picture></a></p>

### Copyable

Line numbers will not be selected when selecting exported code in one page.

<p align="center"><a href="assets/11.typ"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/11_Dark.svg"><img alt="typst-block" src="assets/11_Light.svg" /></picture></a></p>

### Theme

PRs are welcome!

<p align="center"><a href="assets/12.typ"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/12_Dark.svg"><img alt="typst-block" src="assets/12_Light.svg" /></picture></a></p>

<p align="center"><a href="assets/13.typ"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/13_Dark.svg"><img alt="typst-block" src="assets/13_Light.svg" /></picture></a></p>

### (Experimental) HTML Variant

See [example-html.typ](example-html.typ) or [GitHub Pages](https://hongjr03.github.io/typst-zebraw/) for more information.

![HTML Variant](assets/html-example.png)

## Customization

There are 3 ways to customize code blocks in your document:

- Manually render some specific blocks by `#zebraw()` function and passing parameters to it.
- By passing parameters to `#show: zebraw.with()` will affect every raw block after the `#show` rule, **except** blocks created manually by `#zebraw()` function.
- By passing parameters to `#show: zebraw-init.with()` will affect every raw block after the `#show` rule, **including** blocks created manually by `#zebraw()` function. By using `zebraw-init` without any parameters, the values will be reset to default.

### Inset

Customize the inset of each line by passing a  to the `inset` parameter:

<p align="center"><a href="assets/15.typ"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/15_Dark.svg"><img alt="typst-block" src="assets/15_Light.svg" /></picture></a></p>

### Colors

Customize the background color by passing a  or an  of s to the `background-color` parameter.

<p align="center"><a href="assets/16.typ"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/16_Dark.svg"><img alt="typst-block" src="assets/16_Light.svg" /></picture></a></p>

Customize the highlight color by passing a  to the `highlight-color` parameter:

<p align="center"><a href="assets/17.typ"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/17_Dark.svg"><img alt="typst-block" src="assets/17_Light.svg" /></picture></a></p>

Customize the comments' background color by passing a  to the `comment-color` parameter:

<p align="center"><a href="assets/18.typ"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/18_Dark.svg"><img alt="typst-block" src="assets/18_Light.svg" /></picture></a></p>

Customize the language tab's background color by passing a  to the `lang-color` parameter.

<p align="center"><a href="assets/19.typ"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/19_Dark.svg"><img alt="typst-block" src="assets/19_Light.svg" /></picture></a></p>

### Font

To customize the arguments of comments' font and the language tab's font, pass a dictionary to `comment-font-args` parameter and `lang-font-args` parameter.

Language tab will be rendered as comments if nothing is passed.

<p align="center"><a href="assets/20.typ"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/20_Dark.svg"><img alt="typst-block" src="assets/20_Light.svg" /></picture></a></p>

<p align="center"><a href="assets/21.typ"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/21_Dark.svg"><img alt="typst-block" src="assets/21_Light.svg" /></picture></a></p>

### Extend

Extend at vertical is enabled at default. When there's header or footer it will be automatically disabled.

<p align="center"><a href="assets/22.typ"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/22_Dark.svg"><img alt="typst-block" src="assets/22_Light.svg" /></picture></a></p>

## Documentation

See [manual.pdf](manual.pdf) for more information.

## Example

<p align="center"><a href="assets/24.typ"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/24_Dark.svg"><img alt="typst-block" src="assets/24_Light.svg" /></picture></a></p>

## License

Zebraw is licensed under the MIT License. See the [LICENSE](LICENSE) file for more information.
