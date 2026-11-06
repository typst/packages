# ANSI Escape Sequence Renderer

<a href="https://github.com/8LWXpg/typst-ansi-render/tags">
  <img alt="GitHub manifest version (path)" src="https://img.shields.io/github/v/tag/8LWXpg/typst-ansi-render">
</a>
<a href="https://github.com/8LWXpg/typst-ansi-render">
  <img src="https://img.shields.io/github/stars/8LWXpg/typst-ansi-render" alt="GitHub Repo stars">
</a>
<a href="https://github.com/8LWXpg/typst-ansi-render/blob/master/LICENSE">
  <img alt="GitHub" src="https://img.shields.io/github/license/8LWXpg/typst-ansi-render">
</a>

This script provides a simple way to render text with ANSI escape sequences. It uses the `ansi-render` function from the `ansi-render.typ` module to render text with various formatting options, including font, font size and theme.

contribution is welcomed!

## Usage

```typst
#import "@preview/ansi-render:0.2.0": *

#ansi-render(string, font: string, size: length, theme: terminal-themes.theme)
```

## Demo

see [demo.typ](https://github.com/8LWXpg/typst-ansi-render/blob/master/demo.typ) [demo.pdf](https://github.com/8LWXpg/typst-ansi-render/blob/master/demo.pdf)

```typst
#ansi-render(
"\u{1b}[38;2;255;0;0mThis text is red.\u{1b}[0m
\u{1b}[48;2;0;255;0mThis background is green.\u{1b}[0m
\u{1b}[38;2;255;255;255m\u{1b}[48;2;0;0;255mThis text is white on a blue background.\u{1b}[0m
\u{1b}[1mThis text is bold.\u{1b}[0m
\u{1b}[4mThis text is underlined.\u{1b}[0m
\u{1b}[38;2;255;165;0m\u{1b}[48;2;255;255;0mThis text is orange on a yellow background.\u{1b}[0m
"
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
\u{1b}[38;5;255;48;5;0mWhite text on black background\u{1b}[0m"
)
```

![2.png](https://github.com/8LWXpg/typst-ansi-render/blob/master/img/2.png)

```typst
#ansi-render(
"\u{1b}[31;1mHello \u{1b}[7mWorld\u{1b}[0m

\u{1b}[53;4;36mOver  and \u{1b}[35m Under!
\u{1b}[7;90mreverse\u{1b}[101m and \u{1b}[94;27mreverse"
)
```

![3.png](https://github.com/8LWXpg/typst-ansi-render/blob/master/img/3.png)

```typst
// uses the font that supports ligatures
#ansi-render(read("test.txt"), font: "CaskaydiaCove Nerd Font Mono", theme: terminal-themes.putty)
```

![4.png](https://github.com/8LWXpg/typst-ansi-render/blob/master/img/4.png)
