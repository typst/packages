# cmarker.typ

<!--raw-typst #align(center)[https://github.com/SabrinaJewson/cmarker.typ] -->

This package enables you to write CommonMark Markdown,
and import it directly into Typst.

<table>
<tr>
<th><code>simple.typ</code></th>
<th><code>simple.md</code></th>
</tr>
<tr>
<td>

```typ
#import "@preview/cmarker:0.1.10"

#cmarker.render(read("simple.md"))
```
</td>
<td>

```markdown
# We can write Markdown!

*Using* __lots__ ~of~ `fancy` [features](https://example.org/).
```
</td>
</tr>
</table>
<table>
<tr><th><code>simple.pdf</code></th></tr>
<tr><td><img src="./examples/simple.png" alt="`simple.md` rendered as a PDF"></td></tr>
</table>

This document is available
in [Markdown](https://github.com/SabrinaJewson/cmarker.typ/tree/release#cmarker)
and [rendered PDF](https://github.com/SabrinaJewson/cmarker.typ/blob/release/README.pdf)
formats.

## Contents

2. [API](#api)
2. [References, labels, figures and citations](#references-labels-figures-and-citations)
2. [Supported Markdown syntax](#supported-markdown-syntax)
2. [Interleaving Markdown and Typst](#interleaving-markdown-and-typst)
2. [FAQ](#faq)
2. [Development](#development)

## API

We offer two functions:
1. [render](#render)
2. [render-with-metadata](#render-with-metadata)

### render
```typc
render(
  markdown,
  smart-punctuation: true,
  math: none,
  task-list-marker: none,
  h1-level: 1,
  set-document-title: true,
  raw-typst: true,
  html: (:),
  label-prefix: "",
  prefix-label-uses: true,
  heading-labels: "github",
  scope: (:),
  show-source: false,
  blockquote: none,
) -> content
```

The `render` function renders the given Markdown and returns content.

#### `markdown`

The [CommonMark](https://spec.commonmark.org/0.30/) Markdown string to be processed.
Parsed with the [pulldown-cmark](https://docs.rs/pulldown-cmark) Rust library.
You can set this to `read("somefile.md")` to import an external markdown file;
see the
[documentation for the read function](https://typst.app/docs/reference/data-loading/read/).
- Accepted values: Strings and raw text code blocks.
- Required.

#### `smart-punctuation`

Whether to automatically convert ASCII punctuation to Unicode equivalents:
- nondirectional quotations (" and ') become directional (“” and ‘’);
- three consecutive full stops (...) become ellipses (…);
- two and three consecutive hypen-minus signs (-- and ---)
	become en and em dashes (– and —).

Note that although Typst also offers this functionality,
this conversion is done through the Markdown parser rather than Typst.
- Accepted values: Booleans.
- Default value: `true`.

#### `math`

A callback to be used when equations are encountered in the Markdown,
or `none` if it should be treated as normal text.
Because Typst does not support LaTeX equations natively,
the user must configure this.
- Accepted values:
	Functions that take a boolean argument named `block` and a positional string argument
	(often, the `mitex` function from
	[the mitex package](https://typst.app/universe/package/mitex)),
	or `none`.
- Default value: `none`.

For example, to render math equation as a Typst math block,
one can use:
```typ
#import "@preview/mitex:0.2.7": mitex
#cmarker.render(`$\int_1^2 x \mathrm{d} x$`, math: mitex)
```
<!--raw-typst
which renders as: $integral_1^2 x dif x$
-->

#### `task-list-marker`

A callback which can be used to render Markdown task lists,
or `none` if task lists are not supported.
The callback will be called with `true` if the checkbox is to be checked (`- [x]`),
and `false` if it is unchecked (`- [ ]`).

- Accepted values:
	Functions from booleans to content, or `none`.
- Default value: `none`.

You may want to use [`cheq`](https://typst.app/universe/package/cheq) to provide the checkboxes:

````typ
#import "@preview/cheq:0.3.1"

#cmarker.render(
  ```md
  - [ ] Not checked
  - [x] Checked
  ```,
  task-list-marker: checked => if checked { cheq.checked-sym() } else { cheq.unchecked-sym() },
)
````

#### `h1-level`

The level that top-level headings in Markdown should get in Typst.
When set to zero,
top-level headings are treated as titles,
`##` headings become `=` headings,
`###` headings become `==` headings,
et cetera;
when set to `2`,
`#` headings become `==` headings,
`##` headings become `===` headings,
et cetera.
- Accepted values: Integers in the range [-128, 127].
- Default value: 1.

#### `set-document-title`

Whether to emit a `#set document(title: […])` line
for `#title()`s.

If you encounter a “document set rules are not allowed inside of containers” error,
you should set this to `false`,
and potentially add a `#set document(title: […])` line manually.

This has effect when [`h1-level`](#h1-level) is zero
and you have a top-level (i.e. `#`) heading.

- Accepted values: Booleans.
- Default value: `true`.

#### `raw-typst`

Whether to allow raw Typst code to be injected into the document via HTML comments.
If disabled, the comments will act as regular HTML comments.
- Accepted values: Booleans.
- Default value: `true`.

For example, when this is enabled, `<!--raw-typst #circle(radius: 10pt) -->`
will result in a circle in the document
(but only when rendered through Typst).
See also
[`<!--typst-begin-exclude-->` and `<!--typst-end-exclude-->`](#interleaving-markdown-and-typst),
which is the inverse of this.

#### `html`

The dictionary of HTML elements that cmarker will support.
- Accepted values:
	Dictionaries whose keys are the tag name (without the surrounding `<>`)
	and whose values can be:
	- `("normal", (attrs, body) => [/* … */])`:
		Defines a normal element,
		where `attrs` is a dictionary of strings, `body` is content,
		and the function returns content.
	- `("void", (attrs) => [/* … */])`:
		Defines a void element (e.g. `<br>`, `<img>`, `<hr>`).
	- `("raw-text", (attrs, body) => [/* … */])`:
		Defines a raw text element (e.g. `<script>`, `<style>`),
		where `body` is a string.
	- `("escapable-raw-text", (attrs, body) => [/* … */])`:
		Defines an escapable raw text element (e.g. `<textarea>`),
		where `body` is a string.
	- `(attrs, body) => [/* … */]`: Shorthand for
		`("normal", (attrs, body) => [/* … */])`.
- Default value: `(:)`.
- Overridable keys:
	The following HTML elements are provided by default,
	but you are free to override them:
	`<sub>`,
	`<sup>`,
	`<mark>`,
	`<h1>`–`<h6>`,
	`<ul>`,
	`<ol>`,
	`<li>`,
	`<dl>`,
	`<dt>`,
	`<dd>`,
	`<table>`,
	`<thead>`,
	`<tfoot>`,
	`<tr>`,
	`<th>`,
	`<td>`,
	`<hr>`,
	`<a>`,
	`<em>`,
	`<strong>`,
	`<s>`,
	`<code>`,
	`<br>`,
	`<blockquote>`,
	`<figure>`,
	`<figcaption>`,
	`<svg>`,
	`<img>`.

For example, the following code
would allow you to write `<circle radius="25">` to render a 25pt circle:

```typ
#cmarker.render(read("example.md"), html: (
  circle: ("void", attrs => circle(radius: int(attrs.radius) * 1pt))
))
```

#### `label-prefix`

If present, any labels autogenerated by footnotes and headings will be prefixed by this string.
This is useful to avoid collisions.
- Accepted values: A valid label or the empty string.
- Default value: The empty string.

#### `prefix-label-uses`

Whether references to labels such as `[@label]` and `[link](#label)`
should be prefixed by `label-prefix`.
- Accepted values: Booleans.
- Default value: `true`.

#### `heading-labels`

How the cases of labels autogenerated by headings should be transformed.
The label prefix (given in `label-prefix`) will **not** be transformed.
- Accepted values:
	- `"github"`:
		Match [GitHub’s slugification algorithm](https://github.com/Flet/github-slugger):
		strip out invalid characters, lowercase everything, convert ASCII spaces to hyphens,
		and number duplicate headings to avoid collisions.
		For example, `# My heading!` will become `<my-heading>`.
	- `"jupyter"`:
		Match [Jupyter’s slugification algorithm](https://github.com/jupyterlab/jupyterlab/blob/b3094f1156ad67e23f91f0cc8cc676123c8eb448/packages/rendermime/src/renderers.ts#L400):
		just convert ASCII spaces to hyphens.
		For example, `# My heading!` will become `<My-heading!>`.
		Unlike the real Jupyter, we also number duplicate headings,
		but this shouldn’t have any difference in practice since
		Jupyter doesn’t allow referring to duplicate headings anyway.
	- `none`: Don’t add automatic labels to headings.
- Default value: `"github"`.

#### `scope`

A dictionary providing the context in which the evaluated Typst code runs.
It is useful to pass values in to code inside `<!--raw-typst-->` blocks,
but can also be used to override element functions generated by cmarker itself.
- Accepted values: Any dictionary.
- Default value: `(:)`.
- Overridable keys:
	- All built-in Typst functions.
	- `rule`:
		Deprecated!
		This used to be a function returning content
		to be used when [thematic breaks](#thematic-breaks) (`---` in Markdown) are encountered.
		Since Typst 0.15, this is just [`divider`](https://typst.app/docs/reference/model/divider/).

#### `show-source`

A debugging tool.
When set to `true`, the Typst code that would otherwise have been displayed
will be instead rendered in a code block.
- Accepted values: Booleans.
- Default value: `false`.

#### `blockquote`
Deprecated!
This used to control how blockquotes were rendered,
but we now default to `quote(block: true)`.
If you want to override how blockquotes look,
either use `#show quote.where(block: true)`
or use `scope: (quote: …)`.
- Accepted values: Functions accepting content and returning content, or `none`.
- Default value: `none`.

### render-with-metadata

```typc
render-with-metadata(
  markdown,
  smart-punctuation: true,
  math: none,
  task-list-marker: none,
  h1-level: 1,
  set-document-title: true,
  raw-typst: true,
  html: (:),
  label-prefix: "",
  prefix-label-uses: true,
  heading-labels: "github",
  scope: (:),
  show-source: false,
  blockquote: none,
  metadata-block: none,
) -> (metadata, content)
```

The `render-with-metadata` functions works the same as `render` with two exceptions:
1. This function returns `(meta, body)`. This allows the user to freely manipulate the metadata.
	```typ
	#let (meta, body) = cmarker.render-with-metadata(read("example.md"))
	// `body` will be the same as:
	#let body = cmarker.render(read("example.md"))
	```
2. This function has an extra argument: `metadata-block`. The other arguments are the same as `render`.

#### `metadata-block`

How to parse the metadata block.
Only a single metadata block at the beginning of the document is supported;
metadata blocks not at the start will be ignored.
If `none`, the metadata block will not be parsed.
The behaviour is the same as using `render`.
- Accepted values:
	- `"frontmatter-raw"`:
		Parse the metadata block and return it as a string.
	- `"frontmatter-yaml"`:
		Parsed the metadata block as YAML and return it as a dictionary.
	- `none`.
- Default value: `none`.

## References, labels, figures and citations

`cmarker.typ` integrates well with Typst’s native references and labels.
Where in Typst you would write `@foo`, in Markdown you write `[@foo]`;
where in Typst you would write `@foo[Chapter]`, in Markdown you’d write `[Chapter][@foo]`.
You can also write `[some text](#foo)` to have “some text” be a link that points at `foo`.

Headings are automatically given references according to their name,
but lowercased and with spaces replaced by hyphens
(although this can be controlled with the [`heading-labels`](#heading-labels) option):

```md
# My nice heading

We can make a link to [this section](#my-nice-heading).
We can refer you to [@my-nice-heading]. <!-- generates “We can refer you to Section 1.” -->
Or to [Chapter][@my-nice-heading]. <!-- generates “We can refer you to Chapter 1.” -->
```

If you have two headings with the same title,
they’ll be numbered sequentially in the fashion of GitHub Markdown:
`heading`, `heading-1`, `heading-2`, etc.

If you want to cite something from a bibliography,
you can do it much the same way: `[@citation]`.

If you want to customize the label of a heading from the default,
you can use `id=` in HTML, or use `raw-typst` blocks
(note that these **must** be preceded by a newline):

```md
<h1 id="my-nice-section">My nice heading</h1>

# My other nice heading
<!--raw-typst <my-other-nice-section> -->

See [@my-nice-section] and [@my-other-nice-section].
<!-- generates “See Section 1 and Section 2.” -->
```

This can also be used with figures, which is very powerful:

```md
Please refer to [@my-graph]. <!-- generates “Please refer to Figure 1.” -->

<figure id="my-graph">

![a graph](graph.png)</figure>
```

If you encounter collision errors across multiple Markdown files,
you can set [the `label-prefix` option](#label-prefix).
For example, setting
`label-prefix: "file-a-"` will convert the label of
`# My Heading` into `file-a-my-heading`.
By default, references within the file will expect the unprefixed name;
this can be changed by setting [`prefix-label-uses: false`](#prefix-label-uses).

## Supported Markdown syntax

We support CommonMark with a couple extensions.

### Line breaks

A single newline becomes a space;
two consecutive newlines (i.e. one blank line) give a paragraph break;
two spaces before a newline gives a hard line break
(used for example in poetry) –
you can also write `<br>` to the same effect.

### Formatting

- *Emphasis*: `*emphasis*` or `_emphasis_`
- **Strong**: `**strong**` or `__strong__`
- ~Strikethrough~: `~strikethrough~`
- <sub>Subscript</sub>: `<sub>subscript</sub>`
- <sup>Superscript</sup>: `<sup>superscript</sup>`
- <mark>Highlighting</mark>: `<mark>highlighted</mark>`
- Inline code blocks: `` `code here` ``
- Out-of-line code blocks:
	````
	```
	code here
	```
	````
	Syntax highlighting can be achieved by specifying a language after the opening backticks:
	````
	```rust
	let x = 5;
	```
	````
- Blockquotes:
	```md
	> Whereas recognition of the inherent dignity and of
	> the equal and inalienable rights of all members of
	> the human family is the foundation of freedom,
	> justice and peace in the world,
	```

### Links

You can link to a URL directly: `[link](https://example.org)`

Or you can reuse URLs by defining them out-of-line:

```md
[This link] and [that link][This link] go to the same place.

[This link]: https://example.org
```

See [the section on labels](#references-labels-figures-and-citations)
for using links with Typst labels and citations.

### Images

```md
![alt text here](path/to/image.png)
```

Due to the way Typst resolves paths,
in order for this to work you will need to override the `image` function in the [`scope`](#scope):

```typ
#cmarker.render(
  read("example.md"),
  scope: (image: (source, ..args) => image(source, ..args))
)
```

You can use the HTML `<img>` tag, which allows you to specify the width and height of the
image, either as a `%` or as an absolute value.
The below image will span 50% of the page and be 20pt tall:

```md
<img src="path/to/image.png" alt="alt text here" width="50%" height="20">
```

#### Spaces in image paths

Be aware that image paths that contain spaces must be wrapped in `<>`:

```md
<!-- Incorrect: Will render as text -->
![alt text](image path.png)

<!-- Correct: Will give an image -->
![alt text](<image path.png>)
```

#### External images

Since Typst compilation has no network access,
you won’t be able to include images from external URLs.
For example, the below will fail:

```md
<!-- Bad -->
![the Typst logo](https://upload.wikimedia.org/wikipedia/commons/f/f8/Typst.svg)
```

You instead need to download the image
and reference the local path.

```md
<!-- Good -->
![the Typst logo](Typst.svg)
```

#### Alt text and captions

Alt text – which is specified between the `[]` –
is used by screen readers and other assistive technologies,
and won’t be visible in the document by default.
It should provide a description of the image
that makes the document readable to anyone who can’t see the image.

If you want to add a caption to the image
that will be visible to all readers,
you should set a `<figcaption>` explicitly.
For example:

```md
<figure>

![alt text](image.png)
<figcaption>caption text</figcaption>
</figure>
```

You can alternatively transform all alt text into captions automatically:

```typ
#cmarker.render(
  read("example.md"),
  scope: (
    image: (source, alt: none, ..args) => {
      figure(image(source, alt: alt, ..args), caption: alt)
    },
  ),
)
```

However, this has disadvantage that
you can’t use markup in the caption,
because alt text is just a plain string and not content.
(In theory, Markdown supports markup in image alt text,
but our Markdown parser stringifies it anyway
because Typst only supports strings in alt text.
It’s possible we could add extra functionality for this use case.)

### Headings

Headings are denoted with hashes at the start of the line:

```md
# Title of the document
## Sub-heading
### Sub-sub-heading
```

The [h1-level](#h1-level) option controls how Markdown heading levels become Typst heading levels.

Headings will have Typst labels automatically generated from their content –
the `heading-labels` option controls this.
If you want to to specify a label explicitly, see
[the section on labels](#references-labels-figures-and-citations).

### Thematic breaks

Add a thematic break (horizontal rule) with `---`.
This corresponds to the Typst code [`#divider()`](https://typst.app/docs/reference/model/divider/):

---

### Lists

Unordered (bullet-point) lists are denoted with `-`, `+` or `*`:
```md
- Foo
- Bar
```

Ordered (numbered) lists are denoted with `1.` or `1)`:
```md
1. Foo
1. Bar
```

The numbers will be generated automatically.

### Math equations

Math formulae are denoted with dollars: `$x + y$` or `$$x + y$$`.
This requires the [`math`](#math) parameter to be set,
and the syntax of the equations is determined by that parameter.

### Tables

```md
| Column 1 | Column 2 |
| -------- | -------- |
| Row 1 Cell 1 | Row 1 Cell 2 |
| Row 2 Cell 1 | Row 2 Cell 2 |
```

You can also use HTML tables,
which has greater flexibility for elements inside tables:

```md
<table>
	<thead><tr><th>Column 1</th><th>Column 2</th></tr></thead>
	<tr><td>Row 1 Cell 1</td><td>Row 1 Cell 2</td></tr>
	<tr><td>Row 2 Cell 1</td><td>Row 2 Cell 2</td></tr>
</table>
```

### Footnotes

```md
Some text[^footnote]

[^footnote]: content
```

### Term/description lists

Term/description lists:
```md
<dl>
	<dt>Ligature</dt>
	<dd>A merged glyph.</dd>
	<dt>Kerning</dt>
	<dd>A spacing adjustment between two adjacent letters.</dd>
</dl>
```

### Figures

```md
<figure><figcaption>My lovely figure</figcaption>

![a graph](graph.png)
</figure>
```

### Inline SVG

```md
<svg version="1.1" width="100" height="100" xmlns="http://www.w3.org/2000/svg">
	<circle cx="50" cy="50" r="50" fill="blue" />
</svg>
```

### Task lists

If you set the [`task-list-marker`](#task-list-marker) parameter,
`cmarker.typ`s supports task lists:

```md
- [ ] Not checked
- [x] Checked
```

## Interleaving Markdown and Typst

Sometimes,
you might want to render a certain section of the document
only when viewed as Markdown,
or only when viewed through Typst.
To achieve the former,
you can simply wrap the section in
`<!--typst-begin-exclude-->` and `<!--typst-end-exclude-->`:

```md
<!--typst-begin-exclude-->
Hello from not Typst!
<!--typst-end-exclude-->
```

Most Markdown parsers support HTML comments,
so from their perspective this is no different
to just writing out the Markdown directly;
but `cmarker.typ` knows to search for those comments
and avoid rendering the content in between.

Note that when the opening comment is followed by the end of an element,
`cmarker.typ` will close the block for you.
For example:

```md
> <!--typst-begin-exclude-->
> One

Two
```

In this code,
“Two” will be given no matter where the document is rendered.
This is done to prevent us from generating invalid Typst code.

Conversely, one can put Typst code inside
a HTML comment of the form
`<!--raw-typst […]-->`
to have it evaluated directly as Typst code
(but only if [the `raw-typst` option](#raw-typst) is set to `true` –
which it is by default –
otherwise it will just be seen as a regular comment and removed):

```md
<!--raw-typst Hello from #text(fill:blue)[Typst]!-->
```

## FAQ

### How do I include multiple Markdown files in one project?

See [the multi-file example](https://github.com/SabrinaJewson/cmarker.typ/blob/release/examples/multi-file.typ).

Note that this example uses a _single_ call to `render` with concatenated Markdown,
i.e. `cmarker.render(read("file-a.md") + read("file-b.md"))`.
If you instead wish to use
`cmarker.render(read("file-a.md"))` followed by `cmarker.render(read("file-b.md"))`,
you may encounter collision issues if two headings have the same name.
This can be resolved in two ways:
- Giving the headings an explicit ID:
	`<h1 id="my-id">My Heading</h1>` instead of `# My Heading`.
- Setting a [label prefix](#label-prefix), e.g. `label-prefix: "my-file-"`.

### My Markdown after an open HTML tag is getting rendered as text!

This is a Markdown quirk –
in code like `<p>hello _world_</p>`
or `<!-- -->hello _world_`,
italics will not be generated.

There are two fixes:
either insert some empty inline-level HTML at the start,
e.g. `<span></span><p>hello _world_</p>`,
or insert two newlines after the opening tag:

```
<p>

hello _world_</p>
```

### How to I save the resulting Typst file?

`cmarker.typ` is not intended for one-time conversions from Markdown to Typst;
it is intended for when you want to keep the Markdown file
and continue to edit it,
but have it be rendered with Typst.
For one-time conversions,
I’d recommend using [Pandoc](https://pandoc.org/) instead.

If you still want to use it for this purpose,
you can pass in [`show-source: true`](#show-source)
and render to HTML using
`typst compile --features html --format html your-file.typ`.
Then, open `your-file.html` in a web browser and copy the code block.

Alternatively, you can attach it to the PDF as follows:

```typ
#let typst-code = cmarker.render(read("example.md"), show-source: true)
#pdf.attach("yourtypstcode.typ", bytes(typst-code.text))
```

And then extract the attachment from the generated PDF
using your preferred PDF viewer.

Since `cmarker.typ` does not attempt to make generated code readable,
you may want to use
a code formatter like [typstyle](https://github.com/typstyle-rs/typstyle)
on the result.

### How do I have headings start on a new page?

[Show rules](https://typst.app/docs/reference/styling/#show-rules) are the best way:

```typ
#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  it
}
#cmarker.render(read("example.md"))
```

For example, in the below document a pagebreak will occur before the second heading:

```md
# first heading
some content

## sub-heading

<!-- a pagebreak will be inserted here -->

# second heading
more content
```

### How do I centre tables? How do I have them span the page width?

This can be achieved via [show rules](https://typst.app/docs/reference/styling/#show-rules).
For example, centring:

```typ
#show table: t => align(center, t)
#cmarker.render("
  | a | b |
  | - | - |
  | c | d |
")
```

And having them span the page width:

```typ
#show table: t => {
  if t.columns.all(c => c == auto) {
    table(columns: (1fr,) * t.columns.len(), align: t.align, ..t.children)
  } else {
    t
  }
}
```


## Development

File structure is as follows:

<table>
<tr><td><code>lib.typ</code></td><td>
	The entrypoint of the library,
	defining its public API.
	This file only handles the Typst parts;
	the computation itself is done by the Rust plugin at <code>plugin/</code>.
</td></tr>
<tr><td><code>plugin/</code></td><td>
	The Rust plugin that is compiled to WebAssembly.
	This is mostly serialization/deserialization scaffolding
	around the real logic, which lives in <code>lib/</code>.
</td></tr>
<tr><td><code>lib/</code></td><td>
	The <code>cmarker-typst</code> pure Rust library,
	which does the grunt work of the translation itself.
</td></tr>
<tr><td><code>tests/</code></td><td>
	The test suite.
	Each Markdown or Typst file here
	is rendered and compared with the expected HTML output.
	Run all the tests with <code>cargo test --workspace</code>.
</td></tr>
<tr><td><code>test-runner/</code></td><td>
	A helper crate that runs our test suite.
	Consult <code>test-runner/main.rs</code> for a guide on writing tests.
</td></tr>
<tr><td><code>fuzz/</code></td><td>
	Fuzzing for the library.
	Run fuzzing with <code>cargo +nightly fuzz run fuzz</code>.
</td></tr>
<tr><td><code>examples/</code></td><td>
	A few examples.
	Compile them with <code>typst compile examples/{name}.typ</code>.
</td></tr>
<tr><td><code>prepare-release.sh</code></td><td>
	A small shell script that can be used to cut a release of <code>cmarker.typ</code>.
</td></tr>
</table>
