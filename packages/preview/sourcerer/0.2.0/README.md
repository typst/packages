# Sourcerer
Sourcerer is a Typst package for displaying stylized source code blocks, with some extra features. Main features include:

- Rendering source code with numbering
- Rendering only a range of lines from the source code, keeping the original highlighting of the code (For example, block comments are still rendered well, even if cut)
- Adding in-code line labels which are easily referenceable (via `reference`)
- Considerable customization options for the display of the code block
- Consistent and pretty cutoff between pages
- Displaying the language used for a code block in a readable manner, in-code-block

# Usage
First, import the package via:
```typ
#import "@preview/sourcerer:0.1.0": code
```

Then, display custom code blocks via the `code` function, like so:

````typ
#code(
  lang: "Typst",
  ```typ
  Woah, that's pretty #smallcaps(cool)!
  That's neat too.
  ```
)
````

This results in:

<p align="center">
  <img src="assets/sourcerer.png" width="750"/>
</p>

To view all of the options of the `code` function, consult the [documentation](DOCS.md).
