# progressive-outline

This package provides a Typst function, `progressive-outline`, to generate a dynamic table of contents, similar to what is found in some LaTeX's Beamer presentations.

## Context and Ultimate Goal

This function was developed to meet a need within the Typst community for displaying partial or progressive outlines, especially in presentations. It is inspired by the following discussions:

-   [GitHub Issue (touying)](https://github.com/touying-typ/touying/issues/137)
-   [Typst Forum](https://forum.typst.app/t/how-to-display-partial-outlines-with-touying/5526)

The ultimate goal would be to integrate this functionality directly into a presentation package like **[`polylux`](https://typst.app/universe/package/polylux/)**, **[`touying`](https://typst.app/universe/package/touying/)**, or **[`presentate`](https://typst.app/universe/package/presentate/)**. This would allow for the creation of "Beamer-like" presentations where the outline unfolds flexibly as you progress through the slides. Feel free to draw inspiration from this code to contribute to these projects!

## Function Usage

To use the function, import the package and call `progressive-outline` where you want the outline to appear.

```typst
#import "@preview/progressive-layout:1.0.0": progressive-outline

#progressive-outline(
  h1-style: "all",
  h2-style: "current-and-grayed",
  h3-style: "current",
  show-numbering: true,
)
```

## Example: The `progressive-layout` Template

This package also contains a simple template, `progressive-layout`, which shows an example of how to use the function. Here is a minimal code example to test it:

```typst
// Import the template
#import "@preview/progressive-layout:1.0.0": progressive-layout, progressive-outline

// Apply the template to your document
#show: doc => progressive-layout(doc)

// Your headings...
= Chapter 1
== Section 1.1
= Chapter 2
```

## Examples

This package includes two files to demonstrate its usage:

-   [`example.typ`](https://github.com/eusebe/progressive-layout/blob/main/example.typ): This file shows how the `progressive-outline` function works with different options.
-   [`demo.typ`](https://github.com/eusebe/progressive-layout/blob/main/demo.typ): This file provides an example of how to use the `progressive-layout` template.

## `progressive-outline` Parameters

| Parameter | Description | Options | Default | 
| :--- | :--- | :--- | :--- |
| `h1-style` | Controls the display of level 1 headings. | `"all"`, `"current"`, `"current-and-grayed"`, `"none"` | `"all"` |
| `h2-style` | Controls the display of level 2 headings. | `"all"`, `"current"`, `"current-and-grayed"`, `"none"` | `"all"` |
| `h3-style` | Controls the display of level 3 headings. | `"all"`, `"current"`, `"current-and-grayed"`, `"none"` | `"all"` |
| `scope-h2` | Restricts the display of level 2 headings. | `"all"`, `"current-h1"` | `"current-h1"` |
| `scope-h3` | Restricts the display of level 3 headings. | `"all"`, `"current-h2"` | `"current-h2"` |
| `show-numbering` | Shows or hides the numbering of headings. | `true`, `false` | `true` |

---

## Note on Code Generation

This package was initially generated with the help of a Large Language Model (LLM). It is a demonstration of what I would like to see one day included in a typst package dedicated to creating presentations, but I am unable to integrate such a feature into the packages I mentioned above in the readme. While functional, it may contain errors, inefficiencies, or programming practices that could be improved. Please use it with discretion and feel free to suggest improvements!
