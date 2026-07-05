# `canonical-nthu-thesis` Change Log

## 0.2.0

- `#outline-pages()` is now to be called instead of just `#outline-pages`.
- Additional `setup-thesis(info, style)` arguments:
  - `style.fonts` (list of strings): The fonts used throughout the thesis.  Default: `("New Computer Modern", "TW-MOE-Std-Kai")`.
  - `style.math-fonts` (list of strings): The math equation fonts used throughout the thesis.  Default: `("New Computer Modern")`.
  - `style.outline-tables` (bool): Whether to show a list of tables in `outline-pages()`.  Default: `true`.
  - `style.outline-figures` (bool): Whether to show a list of tables in `outline-pages()`.  Default: `true`.
  - `style.show-draft-mark` (bool): Whether to show the "Draft version" watermark with the current date on the top right corner of each page.  Default: `false`.
  - `style.cover-row-heights` (list of lengths): The row heights for the metadata on the Chiniese cover page.  Customize this option if your name or your supervisor's name is too long to fit on a single line.  Default: `(30pt, 30pt, 30pt)`.
