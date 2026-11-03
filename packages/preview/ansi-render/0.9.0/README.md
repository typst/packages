# ANSI Escape Sequence Renderer

[![Tagged version](https://img.shields.io/github/v/tag/8LWXpg/typst-ansi-render)](https://github.com/8LWXpg/typst-ansi-render/tags)
[![GitHub Repo stars](https://img.shields.io/github/stars/8LWXpg/typst-ansi-render?style=flat)](https://github.com/8LWXpg/typst-ansi-render)
[![License on GitHub](https://img.shields.io/github/license/8LWXpg/typst-ansi-render)](https://github.com/8LWXpg/typst-ansi-render/blob/v0.9.0/LICENSE)
[![typst package](https://img.shields.io/badge/typst-package-239dad)](https://typst.app/universe/package/ansi-render)

This script provides a simple way to render text with ANSI escape sequences. Package `ansi-render` provides a function `ansi-render`, and a dictionary of themes `terminal-themes`.

## Usage

```typst
#import "@preview/ansi-render:0.9.0": *

#ansi-render(
  string,
  font:           string or none,
  size:           length,
  width:          auto or relative length,
  height:         auto or relative length,
  breakable:      boolean,
  radius:         relative length or dictionary,
  inset:          relative length or dictionary,
  outset:         relative length or dictionary,
  spacing:        relative length or fraction,
  above:          relative length or fraction,
  below:          relative length or fraction,
  clip:           boolean,
  bold-is-bright: boolean,
  theme:          terminal-themes.theme,
)
```

### Parameters

- `string` - string with ANSI escape sequences
- `font` - font name or none, default is `Cascadia Code`, set to `none` to use the same font as `raw`
- `size` - font size, default is `1em`
- `bold-is-bright` - boolean, whether bold text is rendered with bright colors, default is `false`
- `theme` - theme, default is `vscode-light`
- parameters from [`block`](https://typst.app/docs/reference/layout/block/) function with the same default value, only affects outmost block layout:
  - `width`
  - `height`
  - `breakable`
  - `radius`
  - `inset`
  - `outset`
  - `spacing`
  - `above`
  - `below`
  - `clip`

## Themes

see [themes](https://github.com/8LWXpg/typst-ansi-render/blob/v0.9.0/test/themes.pdf)

## Demo

see [demo.typ](https://github.com/8LWXpg/typst-ansi-render/blob/v0.9.0/test/demo.typ) [demo.pdf](https://github.com/8LWXpg/typst-ansi-render/blob/v0.9.0/test/demo.pdf)

```typst
#ansi-render(
"\u{1b}[38;2;255;0;0mThis text is red.\u{1b}[0m
\u{1b}[48;2;0;255;0mThis background is green.\u{1b}[0m
\u{1b}[38;2;255;255;255m\u{1b}[48;2;0;0;255mThis text is white on a blue background.\u{1b}[0m
\u{1b}[1mThis text is bold.\u{1b}[0m
\u{1b}[4mThis text is underlined.\u{1b}[0m
\u{1b}[38;2;255;165;0m\u{1b}[48;2;255;255;0mThis text is orange on a yellow background.\u{1b}[0m",
inset: 5pt, radius: 3pt,
theme: terminal-themes.vscode
)
```

![RGB color with bold and underlined text](https://github.com/8LWXpg/typst-ansi-render/blob/v0.9.0/img/1.png?raw=true)

```typst
#ansi-render(
"\u{1b}[38;5;196mRed text\u{1b}[0m
\u{1b}[48;5;27mBlue background\u{1b}[0m
\u{1b}[38;5;226;48;5;18mYellow text on blue background\u{1b}[0m
\u{1b}[7mInverted text\u{1b}[0m
\u{1b}[38;5;208;48;5;237mOrange text on gray background\u{1b}[0m
\u{1b}[38;5;39;48;5;208mBlue text on orange background\u{1b}[0m
\u{1b}[38;5;255;48;5;0mWhite text on black background\u{1b}[0m",
inset: 5pt, radius: 3pt,
theme: terminal-themes.vscode
)
```

![256 color](https://github.com/8LWXpg/typst-ansi-render/blob/v0.9.0/img/2.png?raw=true)

```typst
#ansi-render(
"\u{1b}[31;1mHello \u{1b}[7mWorld\u{1b}[0m

\u{1b}[53;4;36mOver  and \u{1b}[35m Under!
\u{1b}[7;90mreverse\u{1b}[101m and \u{1b}[94;27mreverse",
inset: 5pt, radius: 3pt,
theme: terminal-themes.vscode
)
```

![16 color with overline and underline and reverse](https://github.com/8LWXpg/typst-ansi-render/blob/v0.9.0/img/3.png?raw=true)

```typst
// uses the font that supports ligatures
#ansi-render(read("./test/test.txt"), inset: 5pt, radius: 3pt, font: "Cascadia Code", theme: terminal-themes.putty)
```

![render file output](https://github.com/8LWXpg/typst-ansi-render/blob/v0.9.0/img/4.png?raw=true)

## Capturing ANSI Output

### Output to File

The most straight forward way is writing to a file then read that in Typst.

```bash
command > out.txt
```

### Other Method

If writing to a file doesn't work, that means the program will detect the output and trim ANSI sequence accordingly, which means we need a pty interface to execute the script, the following should work in Linux:

```bash
script "command" out.txt
exit
```

## About Default Font

Typst's default font for `raw` is `Dejavu Sans Mono`, but it has [incorrect top-edge](https://github.com/typst/typst/issues/2231), so the default is set to `Cascadia Code`, which is included in web editor.
