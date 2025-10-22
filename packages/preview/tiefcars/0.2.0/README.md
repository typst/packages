# TiefCARS


> The worst way to format *your* document

Have you ever wondered, "Why did no one make a template for LCARS yet?"

Well, simply because it's a pain. There's so many curves. So much sufferage.

But fear no more: Today, We present to you **TiefCARS**! Your Typst template
to format a document in a LCARS style.

## Usage

To use TiefCARS with the Typst web app, choose “Start from template” and select TiefCARS. You will also need to include or install the `Antonio` font.

To import the package manually in your Typst project, use:

```typst
#import "@preview/tiefcars:0.1.0": *
```

The easiest way to get started is to use first select a theme:

```typst
#show: tiefcars.with(theme: "tng")
```

Then, you can enable layouting:

```typst
// Enables multi page layout with left bound buttons
#show: multi-page-layout(
  title: [This Document Is Amazing], // A title displayed on the first page of the mult-page-layout
)

Your content
```

This creates a default layout, giving you access to a left bound LCARS interface. Headings with level one are currently implemented to be special, but this may change.

You can also create a title page / single page document using `single-page-layout`:

```typst
#show: single-page-layout(
  title: [This Document Is Amazing], // A title displayed on the top right corner of the page
  subtitle-text: [Your subtitle text.], // A subtitle text. This should fill up the rest of the interface to avoid it looking empty.
  top-height: 4, // This defines how many buttons (rectangles) will be displayed on the left bar before 
)

Your content
```

## Examples


Example for multi-page-layout with left only binding.


Example for multi-page-layout with alternating binding.


Example for single-page-layout with different themes.

## License and Contributions

TiefCARS is currently under semi active development. Feedback, bug reports, and suggestions are welcome. Please open an issue or contribute via pull requests if you have ideas for improvement.

This package is released under the MIT License.
