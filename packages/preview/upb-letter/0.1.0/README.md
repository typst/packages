# Typst Letter Template for Paderborn University

This package allows for using Typst for creating letters using the official letter format of [Paderborn University](https://www.uni-paderborn.de). This repository contains the required Typst templates, additional assets, and usage examples.

You can use the template either with the **web application** [typst.app](https://typst.app) or with the **Typst command line interface (CLI)**.


### Fonts

Paderborn University uses _Karla_ as font for its official document, which is not installed by default on most systems. Therefore, you need to install the font on your system to use the template. The font is available as a variable-width font, but Typst does not yet support variable-width fonts. Therefore, you need to install the static font weights. The template uses the following font weights Regular (400) and Bold (700). You need to install at these weights in addition to any other weights you want to use.

 For legal reasons, the font cannot be included in this repository, but you can download the font from [Google Fonts](https://fonts.google.com/specimen/Karla). To install the font, download the font files and extract them to a directory of your choice and make them available to Typst by setting the `TYPST_FONT_DIR` environment variable. You can check whether the required variants are installed and accessible by typst by running

```
typst fonts --variants
```

## How to use the template with the CLI

You can use the template by installing it from the Typst package registry with the following command:

```bash
typst init @preview/upb-letter:0.1.0 my-letter
```

Adapt the template in `my-letter/main.typ` to your liking to configure the sender/receiver address, subject, date, etc.

You can compile the document with the following command:

```bash
typst compile my-letter/main.typ
```
This will create a PDF file in the `my-letter` directory. You can also use the `typst watch` command to automatically compile the document whenever you save changes.

### How to use the template with the web application

You can use the template by creating a new document in the Typst web application and search for the package `@preview/upb-letter`. This will create a new document with the template. You can then adapt the template to your liking.

# Author
Christian Plessl <christian.plessl@uni-paderborn.de>
