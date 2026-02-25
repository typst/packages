# conllu-tree

A fast, beautiful, and highly customizable Typst package for rendering Universal Dependencies (CoNLL-U) trees, powered by Rust/WASM and [CeTZ](https://github.com/johannes-wolf/cetz).

This package provides an elegant way to visualize dependency parsing results, syntax trees, and enhanced dependency graphs directly in Typst without relying on external Python scripts or LaTeX's `tikz-dependency`.

## Usage

Import the package and use the `dependency-tree` function. Pass your CoNLL-U text to it.

````typ
#import "@preview/conllu-tree:0.1.0": dependency-tree
#set page(width: auto, height: auto, margin: 3mm)

#let sample-conllu = ```
# sent_id = 1
# text = They buy and sell books.
1	They	they	PRON	PRP	_	2	nsubj	_	_
2	buy	buy	VERB	VBP	_	0	root	_	_
3	and	and	CCONJ	CC	_	4	cc	_	_
4	sell	sell	VERB	VBP	_	2	conj	_	_
5	books	book	NOUN	NNS	_	2	obj	_	_
6	.	.	PUNCT	.	_	2	punct	_	_
```.text

#dependency-tree(sample-conllu)
````

![Basic Tree](images/ex01.png)

## Advanced Usage & Highlighting

You can display the original sentence text, lemmas, and part-of-speech tags (UPOS, XPOS) directly around the words. Additionally, you can highlight specific dependency arcs by targeting the dependent's ID using the `highlights` dictionary.

```typ
#dependency-tree(
  sample-conllu, 
  show-text: true,
  word-spacing: 2.5, 
  show-upos: true,
  show-lemma: true,
  endpoint-spacing: 0.05,
  highlights: (
    "2": red,          // Highlight the ROOT arrow pointing to 'buy'
    "5": rgb("aa00ff") // Highlight the arc pointing to 'books'
  )
)
```

![Advanced Tree](images/ex02.png)

## API Reference

### `dependency-tree(conllu-text, ..args)`

Renders one or more sentences from a CoNLL-U formatted string.

**Parameters:**

- `conllu-text` (String): The raw text in CoNLL-U format.
- `word-spacing` (Float): Horizontal distance between words. Default: `2.0`.
- `level-height` (Float): Vertical height increment for each arc level. Default: `1.0`.
- `arc-roundness` (Float): Controls the curvature of the bezier arcs. Lower values make arcs boxier; higher values make them more elliptical. Default: `0.18`.
- `endpoint-spacing` (Float): Shifts arc endpoints horizontally to prevent multiple arrows pointing to the same token from perfectly overlapping. Default: `0.0`.
- `endpoint-angle` (Angle/Float/None): The angle at which the arcs connect to the tokens. Accepts an angle (e.g., `90deg`), a number (e.g., `90`), or `none` to rely solely on `arc-roundness`. Default: `90`.
- `show-text` (Bool): If `true`, displays the sentence text (extracted from `# text = ...` metadata) above the parsed tree. Default: `false`.
- `show-upos` (Bool): If `true`, displays the Universal POS tag (column 4) below the word. Default: `false`.
- `show-xpos` (Bool): If `true`, displays the language-specific POS tag (column 5) below the word. Default: `false`.
- `show-lemma` (Bool): If `true`, displays the lemma (column 3) below the word. Default: `false`.
- `show-enhanced-as-dashed` (Bool): If `true`, arcs derived from the `DEPS` column (enhanced graph) are drawn as blue dashed lines to distinguish them from the basic tree. Default: `true`.
- `show-root` (Bool): If `true`, renders a vertical arrow pointing from above to the root token(s). Default: `true`.
- `highlights` (Dictionary): A dictionary of `("ID": color)` pairs to apply custom stroke colors and thicker lines to specific arcs. The key must be the ID of the dependent token (e.g., `"4"`). Default: `(:)`.

## License

This project is distributed under the MIT License. See [LICENSE](LICENSE) for details.