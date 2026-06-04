# Typst-lasaveur

This is a Typst package for speedy mathematical input, inspired by [vim-latex](https://github.com/vim-latex/vim-latex).  This project is named after my Vim plugin [vimtex-lasaveur](https://github.com/yangwenbo99/vimtex-lasaveur), which ports the operations in vim-latex to [vimtex](https://github.com/lervag/vimtex). 

## Usages in Typst

Either use the file released in "Releases" or import using the following command:

```typst
#import "@preview/lasaveur:0.1.3": *
```

This script generates a Typst library that defines shorthand commands for various mathematical symbols and functions. Here's an overview of what it provides and how a user can use it:

1. Mathematical Functions:
   - Usage: `f<key>(argument)`
   - Examples: `fh(x)` for hat, `ft(x)` for tilde, `f2(x)` for square root
2. Font Styles:
   - Usage: `f<key>(argument)`
   - Examples: `fb(x)` for bold, `fbb(x)` for blackboard bold, `fca(x)` for calligraphic
3. Greek Letters:
   - Usage: `k<key>`
   - Examples: `ka` for α (alpha), `kb` for β (beta), `kG` for Γ (capital Gamma)
4. Common Mathematical Symbols:
   - Usage: `g<key>`
   - Examples: `g8` for ∞ (infinity), `gU` for ∪ (union), `gI` for ∩ (intersection)
5. LaTeX-compatible Symbols:
   - Usage: Direct LaTeX command names
   - Examples: `partial` for ∂, `infty` for ∞, `cdot` for ⋅
6. Arrows:
   - Usage: `ar.<key>`
   - Examples: `ar.l` for ←, `ar.r` for →, `ar.lr` for ↔

Users can employ these shorthands in their Typst documents to quickly input mathematical symbols and functions. The exact prefix for each category (like `f` for functions or `k` for Greek letters) can be customized using command-line arguments when running the script.

For instance, in a Typst document, after importing the generated library, a user could write:

```typst
$fh(x) + ka + g8 + ar.r$
```

This would produce: x̂ + α + ∞ + →

The script provides a wide range of symbols covering most common mathematical notations, making it easier and faster to type complex mathematical expressions in Typst -- especially for users migrating from vim-latex.

## Accompanying Vim Syntax File

The syntax file provides more advanced and correct concealing for both Typst's built-in math syntax and the lasaveur shorthands.  Download the syntax file from the "Releases" section and place it in your `~/.vim/after/syntax/` directory.  The `syntax.vim` file in the repo is supposed to be used by the generation script and it _will not work_ if directly sourced in Vim.
