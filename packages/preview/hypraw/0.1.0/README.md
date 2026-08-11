<h1>

Hypraw

</h1>

<a href="https://typst.app/universe/package/hypraw">

<img src="https://img.shields.io/badge/dynamic/xml?url=https%3A%2F%2Ftypst.app%2Funiverse%2Fpackage%2Fhypraw&amp;query=%2Fhtml%2Fbody%2Fdiv%2Fmain%2Fdiv%5B2%5D%2Faside%2Fsection%5B2%5D%2Fdl%2Fdd%5B3%5D&amp;logo=typst&amp;label=Universe&amp;color=%2339cccc" alt="Universe" />

</a> <a href="https://github.com/QuadnucYard/typst-hypraw">

<img src="https://img.shields.io/badge/dynamic/toml?url=https%3A%2F%2Fraw.githubusercontent.com%2FQuadnucYard%2Ftypst-hypraw%2Frefs%2Fheads%2Fmain%2Ftypst.toml&amp;query=package.version&amp;logo=GitHub&amp;label=GitHub" alt="GitHub" />

</a>

A lightweight package for creating headless code blocks optimized for HTML export. Inspired by [zebraw](https://github.com/hongjr03/typst-zebraw).

**Important**: This package does NOT and will NOT support non-HTML targets. In this case, it just takes no effect.

## Features

- Generates clean, semantic HTML structure
- CSS class deduplication for smaller output
- **Line numbers** — expressive-code styled gutter with proper accessibility
- **Line highlight** — expressive-code styled line highlight, customized with your CSS
- **Copy button support** — headless, accessible, and customizable

## Installation

- From [Typst Universe](https://typst.app/universe/package/hypraw)
- [typship](https://github.com/sjfhsjfh/typship) package manager
- Manual installation to local packages directory
- Git submodule in your project

## Usage

Import from `@preview/hypraw` and enable it with `#show: hypraw`.

```typst
#import "@preview/hypraw:0.1.0": *
#show: hypraw
```

Then write your code blocks as usual, and insert additional CSS styles if needed.

````typ
Here's inline code: `println!("Hello!")`

```rust
fn main() {
    println!("Hello, world!");
}
```

#hypraw-styles(read("styles.css"))
````

See `examples/` directory for complete styling implementation.

We do not provide any official CSS styles to maintain a minimal package size. You can copy our example styles from `examples/` and adapt them to your needs.

**Important**: `hypraw` is stateless and should only be used once per document. It applies globally to all code blocks in the document. Multiple `#show: hypraw` calls are unnecessary and should be avoided.

## API

### `hypraw(..)`

Enables enhanced HTML code block rendering.

```typ
// Enable hypraw for entire document (use only once)
#show: hypraw

// Enable line numbers (expressive-code style)
#show: hypraw.with(line-numbers: true)

// To disable copy button for entire document
#show: hypraw.with(copy-button: false)

// Custom settings for entire document
#show: hypraw.with(dedup-styles: false, attach-styles: false)
```

### `hypraw-set(line-numbers: auto, highlight: auto, copy-button: auto)`

Override settings for the **next** code block only (`auto` denotes default). Resets after use.

```typ
// Disable line numbers for this block (when globally enabled)
#hypraw-set(line-numbers: none)

// Start from line 2
#hypraw-set(line-numbers: 2)

// Custom labels per line (e.g., for diff display)
#hypraw-set(line-numbers: ("+", "-"))

// Highlight specific lines (1-based index)
#hypraw-set(highlight: (1, 3))          // Lines 1 and 3
#hypraw-set(highlight: (1, (3, 5)))     // Line 1 and lines 3-5

// Use specific highlight classes (ins/del/mark)
// You need to set styles for these classes in the css
#hypraw-set(highlight: (ins: (1, 3), del: (4,)))
```

### `additional-styles()`

Returns additional style strings when deduplication is enabled. Call this when you set `attach-styles` to `false`.

### `html-style(style)`

Adds custom CSS styles for HTML output. Accepts a CSS string or file content.

```typ
#html-style(".hypraw { background: #f5f5f5; }")
// Or read from file
#html-style(read("styles.css"))
```

### `html-script(script)`

Similar to `html-style`, it creates a `<script>` element.

## HTML Output

Generates headless HTML structure that you can style with your own CSS:

```html
<div class="hypraw">
  <button class="hypraw-copy-btn" aria-label="Copy code" data-copy="..." />
  <pre><code data-lang="rust">
    <span class="c0">fn</span> <span class="c1">main</span>...
  </code></pre>
</div>
```

The copy button feature provides a `data-copy` attribute with the raw code content. You need to inject your scripts to output. You can refer to the example implementation in [copy-button.css](examples/copy-button.css).

### With Line Numbers

When `line-numbers: true` is enabled, the structure includes a gutter:

```html
<div class="hypraw has-line-numbers" style="--ln-width:3ch">
  <pre><code data-lang="rust"><div class="ec-line"><div class="gutter"><div class="ln"><span aria-hidden="true">1</span></div></div><div class="code"><span class="c0">fn</span> <span class="c1">main</span>() {</div></div><!-- More lines... --></code></pre>
</div>
```

## Why Another Package

[zebraw](https://github.com/hongjr03/typst-zebraw) is a GREAT versatile package for code blocks. However, it tends to produce heavy output, which compromises load time and is hard to tweak from the outside. Therefore, I developed `hypraw`, a lightweight package where you can custom almost everything with CSS.

## License

MIT License — see [LICENSE](LICENSE) for details.
