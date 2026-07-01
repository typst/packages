#import "basic_formatting.typ": typst-preview
#import "@preview/dhbw-oderso:2.2.0": caption-with-source

= Advanced Elements

== Figures
Inserting figures and code blocks into your Typst document enhances its informational depth. When specifying a `caption` for a figure, the template will automatically generate a list of figures, making it easy to navigate your document.

/ Note: When using "ieee" Sorting for bibliography, the sources for figures will be evaluated before the text. To prevent "false sorting", you can use `#caption-with-source("Text", [@source])` instead. This will display the caption in outlines without source and will evaluate the source at the time the figure is displayed

=== Image Figures
#typst-preview(
  "Image Figures in Typst",
  "#import \"@preview/dhbw-oderso:2.2.0\": caption-with-source
#figure(
  image(\"../assets/placeholder-company-logo.svg\"),
  caption: caption-with-source(\"Company Logo\", [@electronic]),
)",
)

=== Tables

Similar to images you can insert table figures. See more table examples and more advanced usage in @appendix-table-examples.

#typst-preview(
  "Table Figures in Typst",
  "#import \"@preview/dhbw-oderso:2.2.0\": tablefigure
#tablefigure(
  columns: 3,
  caption: [Example table],
  table-content: (
    table.header([Name], [Age], [Gender]),
    [Alice], [28], [Female],
    [Bob], [34], [Male],
    [Charlie], [22], [Male],
  )
)",
)


=== Code Snippets

This template uses #link("https://typst.app/universe/package/codly")[Codly] for code snippets. Look at their documentation on how to further customize and control your code blocks.

Code blocks can be created using three backticks:

#typst-preview(
  "Code Blocks in Typst",
  "```js
console.log(\"Hello World\")
```",
)

You can also wrap a code block in a figure to create a code figure, which will be listed in "List of Code":

#typst-preview(
  "Code Figures in Typst",
  "#figure(caption: [My Code])[```rust
fn main() {
  println!(\"Hello World!\");
}
```]",
)

If you want to create a _normal_ figure containing raw text that should not be classified as a code figure (for example command line output), set the `kind` property to `image` explicitly:

#typst-preview(
  "Non-Code-Code-Figure in Typst",
  "#figure(caption: [My Command Line Output], kind: image)[```
> echo \"Hello World\"
Hello World
```]",
)

With `kind: image`, the figure is not listed in "List of Code", but in "List of Figures" instead.

== Math
The math syntax is a loose interpretation of LaTeX, allowing you to create complex mathematical equations with ease.
See #link("https://typst.app/docs/reference/math/", "the Typst documentation") for a detailed overview of the math syntax.

#typst-preview(
  "Math in Typst",
  "$
  sum_(k=0)^n k
  &= 1 + ... + n \
  &= (n(n+1)) / 2 \
$<math-figure>",
)

You can reference labeled equations like other figures. @math-figure shows the sum of the first $n$ natural numbers.

== Block Quotes

#typst-preview(
  "Quotes in Typst",
  "#quote(
  attribution: [Frankling D. Roosevelt @fdr_inaugural_address]
)[
  The only thing we have to fear is fear itself.
]",
)

== Inline Glossary

If you want to include parts of your glossary in your documents content this is possible using the `inline-glossary` function. This is useful if you need word definitions directly in a chapter and want the reader to explicitly read those definitions. The `group` parameter can be used to only show parts of the glossary. In the following example the _Dependency_ group of the example glossary defined in `glossary.typ` is shown. The _Dependency_ group contains definitions for @glossarium, @drafting, @codly, @hydra and @linguify, which are the packages used by this template.

#typst-preview(
  "Inline Glossary Showing the Templates Dependencies",
  "#import \"@preview/dhbw-oderso:2.2.0\": inline-glossary
#import \"../glossary.typ\": glossary

#inline-glossary(glossary, (\"Dependencies\",), show-all: true)",
)


== Notes

#import "@preview/drafting:0.2.2": inline-note, margin-note

This template uses #link("https://typst.app/universe/package/drafting/")[Drafting] for notes.
Using `margin-note` you can add notes to #margin-note("Anywhere in your document!") the margin of your document.

#inline-note[You can also add inline notes to your document with `inline-note`]

Check out their documentation for more advanced use casese.

You might have noticed the notes listing on the first page of this document.
This listing reminds you of the notes still present in your document. Once you remove all notes, the listing will disapear.
