# ANSI Escape Sequence Renderer

<a href="https://github.com/8LWXpg/typst-ansi-render/tags" style="text-decoration: none;">
  <img alt="GitHub manifest version (path)" src="https://img.shields.io/github/v/tag/8LWXpg/typst-ansi-render">
</a>
<a href="https://github.com/8LWXpg/typst-ansi-render" style="text-decoration: none;">
  <img src="https://img.shields.io/github/stars/8LWXpg/typst-ansi-render?style=flat" alt="GitHub Repo stars">
</a>
<a href="https://github.com/8LWXpg/typst-ansi-render/blob/master/LICENSE" style="text-decoration: none;">
  <img alt="GitHub" src="https://img.shields.io/github/license/8LWXpg/typst-ansi-render">
</a>
<a href="https://github.com/typst/packages/tree/main/packages/preview/ansi-render" style="text-decoration: none;">
  <img alt="typst package" src="https://img.shields.io/badge/typst-package-239dad">
</a>

This script provides a simple way to render text with ANSI escape sequences. Package `ansi-render` provides a function `ansi-render`, and a dictionary of themes `terminal-themes`.

contribution is welcomed!

## Usage

```typst
#import "@preview/ansi-render:0.8.0": *

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

see [themes](https://github.com/8LWXpg/typst-ansi-render/blob/master/test/themes.pdf)

## Demo

see [demo.typ](https://github.com/8LWXpg/typst-ansi-render/blob/master/test/demo.typ) [demo.pdf](https://github.com/8LWXpg/typst-ansi-render/blob/master/test/demo.pdf)

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

![1.png](https://github.com/8LWXpg/typst-ansi-render/blob/master/img/1.png)

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

![2.png](https://github.com/8LWXpg/typst-ansi-render/blob/master/img/2.png)

```typst
#ansi-render(
"\u{1b}[31;1mHello \u{1b}[7mWorld\u{1b}[0m

\u{1b}[53;4;36mOver  and \u{1b}[35m Under!
\u{1b}[7;90mreverse\u{1b}[101m and \u{1b}[94;27mreverse",
inset: 5pt, radius: 3pt,
theme: terminal-themes.vscode
)
```

![3.png](https://github.com/8LWXpg/typst-ansi-render/blob/master/img/3.png)

```typst
// uses the font that supports ligatures
#ansi-render(read("./test/test.txt"), inset: 5pt, radius: 3pt, font: "Cascadia Code", theme: terminal-themes.putty)
```

![4.png](https://github.com/8LWXpg/typst-ansi-render/blob/master/img/4.png)
