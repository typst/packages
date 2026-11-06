# Chribel

"Chribel" is a Swiss German word for a rough sketch (like crayon drawings drawn by babies).

![](docs/chribel-template.png)

This template can be used for summaries or, I don't know, technical documentation? It's a rather informal template.

**How to use the template** is described...

- ...in the [Manual](docs/manual.pdf)
- ...when copying this template
- ...when looking into the `template` folder in the repository

## Changelog

## 1.1.0

- Expanded `#callout` functions with support for custom render functions (via parameter `func: ..`) 
- Added `style` parameter to `#callout` with three options: `"minimal"`, `"quarto"` and `"compact"`
- Added callou type `"caution"` and `"important"`.
- Removed `sticky` parameter from raw blocks
- Adjusted heading vertical spacing

## 1.0.0

- initial release -- added functions `#callout`\ `#chribel`, `#chribel-add-callout-template`