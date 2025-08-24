Fervojo
=======

Use [railroads](https://github.com/lukaslueg/railroad_dsl) in your documents.


You use the function by calling `render(diagram-text, css)` which renders the diagram. There, `diagram-text` contains is the diagram itself and css is the one used for the style, `css` is `default-css()` if you don't pass it. Both fields can be strings, bytes or a raw  [raw](https://typst.app/docs/reference/text/raw/) block.

