# ultraw

**`ultraw`** is a Typst package that lets you customize raw text. It provides many features like highlighting some code, adding markers and comments, jumping over lines, several themes (including a dark one), presenting diffs and writing pseudo code.

## Overview

[![overview](assets/overview.svg)](https://github.com/JulesViennotFranca/ultraw/tree/main/assets/overview.typ)

## Getting started

The main function of the **`ultraw`** package is `uraw`. It can be used as a show rule for the whole document to format all raw blocks or per raw block to have precise settings, markers, comments, highlights, etc. The two following examples produce the same result:

[![basic](assets/basic.svg)](https://github.com/JulesViennotFranca/ultraw/tree/main/assets/basic.typ)

The `set-uraw` function enables changing the settings of `uraw` globally, for example to change the theme:

[![set-uraw-theme](assets/set-uraw-theme.svg)](https://github.com/JulesViennotFranca/ultraw/tree/main/assets/set-uraw-theme.typ)

**`ultraw`** provides a lightweight, quick and robust way to highlight raw text by typing highlight delimiters right inside the raw block:

[![highlights1](assets/highlights1.svg)](https://github.com/JulesViennotFranca/ultraw/tree/main/assets/highlights1.typ)

By default, only the base (`*:...:*`) and alert (`*!...!*`) highlights are available. Other highlights are provided and can be added using the `highlights` module. Highlights can also be defined locally when using the `uraw` function:

[![highlights2](assets/highlights2.svg)](https://github.com/JulesViennotFranca/ultraw/tree/main/assets/highlights2.typ)

Markers (lying in the numbers column), comments (between lines of code) and jumps (skipping numbers and possibly raw text lines) are available. Here is a complete example showing them:

[![markers-comments-jumps](assets/markers-comments-jumps.svg)](https://github.com/JulesViennotFranca/ultraw/tree/main/assets/markers-comments-jumps.typ)

More styling options allow customizing the whole look:

[![more-styling](assets/more-styling.svg)](https://github.com/JulesViennotFranca/ultraw/tree/main/assets/more-styling.typ)

Formatting inline raw text is also possible with the `uraw-inline` function.

Diffs are defined with the `uraw-diff` function that automatically produces the diff between two versions of some code. By default, it has the same theme as `uraw` and supports more styling options (settable via `set-uraw-diff`). Here is an example:

[![diffs](assets/diffs.svg)](https://github.com/JulesViennotFranca/ultraw/tree/main/assets/diffs.typ)

Writing pseudo code is also possible with **`ultraw`** with the `uraw-pseudo` function. It enables defining pseudo code as numbered lists (with `+`):

[![pseudo](assets/pseudo.svg)](https://github.com/JulesViennotFranca/ultraw/tree/main/assets/pseudo.typ)

Lines of `uraw`, `uraw-diff` and `uraw-pseudo` outputs inside labeled figures can be referenced (e.g. `@label.3` for the third line) **if** `#show: uraw` is used.

## Documentation

Look at the complete [Documentation](https://github.com/JulesViennotFranca/ultraw/blob/main/docs/doc.pdf) for more cool features.
