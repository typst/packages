# TiefCARS

> The worst way to format *your* document

Have you ever wondered "Why did no one make a template for LCARS yet?"

Well, simply because it's a pain. There's so many curves. So much sufferage.

But fear no more: Today, We present to you **TiefCARS**! Your Typst template
to format a document in a LCARS style.

## Usage

To use TiefCARS with the Typst web app, choose “Start from template” and select TiefCARS. You will also need to include or install the `Antonio` font.

To import the package manually in your Typst project, use:

```typst
#import "@preview/tiefcars:0.1.0": default-layout, tiefcars
```

Alternatively, you can download the lib.typ file and use:

```typst
#import "lib.typ": default-layout, tiefcars
```

The easiest way to get started is to use the following lines:

```typst
/* === Set up lcars with your theme === */
#show: tiefcars.with(theme: "tng")

/* === Enable the default layout === */
#show: default-layout.with(
    /* === The title of the document, fancyful and amazing */
  title: [TiefCARS],
  subtitle-text: [
    /* === Text displayed in the top part under the title */
    Bla bla
  ]
)

Your content
```

This creates a default layout. You can also build your own layout using the `sidebar` and `buttons` components.

How I shan't explain.

## License and Contributions

TiefCARS is currently under semi active development. Feedback, bug reports, and suggestions are welcome. Please open an issue or contribute via pull requests if you have ideas for improvement.

This package is released under the MIT License.
