# ThesIST

ThesIST (pronounced "desist") is an unofficial Master's thesis template for Instituto Superior Técnico written in Typst.

This template fully meets the official formatting requirements as outlined [here](https://tecnico.ulisboa.pt/files/2021/09/guia-disserta-o-mestrado.pdf), and also attempts to follow most unwritten conventions. Regardless, you can be on the lookout for things you may want to see added.

## Usage

If you are in the Typst web app, simply click on "Start from template" and pick this template.

If you want to develop locally:

1. Make sure you have the **TeX Gyre Heros** font family installed.
2. Install the package with `typst init @preview/thesist`.

## Overview

**Please read the "Quick guide" chapter included in this template to get set up. You can keep it as a reference if you want.**

This template's source files, hidden from the user view, are the following:

- `layout.typ`: The main configuration file, which initializes the thesis and contains its general formatting rules.

- `figure-numbering.typ`: This file contains a function to set a chapter-relative numbering for the various types of figures. The function is called once or twice depending on whether the user decides to include appendices.

- `utils.typ`: General functions that you may want to import and use for QoL improvements.

### A sidenote about subfigures
Since subfigures are not yet native to Typst, the current implementation, present in `utils.typ`, needs the user to manually input whether each called subfigure figure (aka subfigure grid) is in an appendix or not. This is because the numbering is different in appendices, and because the functionality of `figure-numbering.typ` can't be applied to subfigure grids, since they are imported with their default numbering once in every chapter. `context` expressions also don't work across imports, so location within the document couldn't be used as a parameter (unless the user called `context` themselves, which would be unintuitive). **Regardless, the workaround that was found, which is explained in the quick guide, doesn't need much thinking from the user, so you can see this as a more technical note that shouldn't matter when you're writing the thesis.**

## Final remarks

This template is not necessarily (or hopefully) a finished product. Feel free to open issues or pull requests!

Also thanks to the Typst community members for the help in some of the functionalities, and for the extensions used here.
