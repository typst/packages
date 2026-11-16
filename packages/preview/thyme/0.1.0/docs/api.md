# API surface

The public surface of `@preview/thyme` is **eight names in core and thirty-nine in
`blog`**. It holds only what a site author writes by hand; everything that `site`, the
page shell or the presets apply for you is not in it.

Everything else in `src/` is a module-level function. The modules can be imported
directly (`#import "../src/text.typ": to-plain-text`) and their paths stay stable, but
the names inside them carry no guarantee.

This file is the index; `docs/manual.pdf` is the reference. If a name is listed here but
missing from the manual, treat this file as authoritative for *existence* and the source
doc-comment for *behaviour*.

## Core — `#import "@preview/thyme:<v>": *`

| Name | Purpose |
| :--- | :--- |
| `site` | Root site bundler: `#show: site.with(title:, url:, ...)`. |
| `webpage` | A mounted sub-page document: `#show: webpage.with(...)`. |
| `mount` | Mount a `.typ` file, a directory, or a literal body into the bundle. |
| `file` | Co-emit a static file at a bundle route. |
| `backlinks` | Compile-time backlinks to the pages that link here. |
| `tr` | Declare a document's text once per language: `tr(en: [...], de: [...])`. |
| `robots-txt` | Build a `robots.txt` string, as a starting point you then own. |

That is the whole core surface.

**Applied for you, so not exported:**

- Inline MathML is normalised for HTML export. No show rule to install.
- Markup that content cannot express uses Typst's own `html.elem`. There is no builder to
  learn and none to keep working.
- `sitemap.xml`, `rss.xml` and `atom.xml` are emitted by `site`. Pass `path(...)` to
  `robots` or `llms` to have your own file copied into the bundle.
- Per-page assets go in the page's `assets:` parameter, not through a helper.

## Blog preset — `#import "@preview/thyme:<v>": blog` then `#import blog: *`

### Engine

| Name | Purpose |
| :--- | :--- |
| `site` | The blog bundler: `#show: blog.site.with(...)`. |
| `webpage`, `mount`, `file`, `backlinks` | As in core. |
| `post` | One blog post, with its route, feed entry and metadata. |
| `posts` | Posts with dates, descriptions and reading times. |

### Theme

| Name | Purpose |
| :--- | :--- |
| `theme-default` | The palette dictionary, for reading a colour or font in your own markup. |

### Notes and margin material

| Name | Purpose |
| :--- | :--- |
| `sidenote` | Numbered note in the right margin. |
| `sn` | Short form of `sidenote`. |
| `mn` | Margin note without a number. |
| `mcite` | Bibliography citation placed in the margin. |

### Blocks

| Name | Purpose |
| :--- | :--- |
| `callout`, `note-box`, `tip-box`, `warning-box`, `important-box` | Boxed asides. |
| `sbox` | Generic boxed block. |
| `definition`, `theorem`, `lemma`, `proposition`, `corollary`, `example`, `recipe`, `remark`, `proof` | Academic environments. |
| `epigraph` | Opening quotation. |
| `codeblock` | Fenced code with a copy button. |
| `diagram` | Captioned figure for a diagram. |
| `wide` | Break out of the text column. |
| `kbd` | Keyboard key. |
| `hr` | Section divider. |
| `links` | Inline link row (`links(direction: "row", ...)`). |
| `toc` | Table of contents for the current document. |

### Tables

| Name | Purpose |
| :--- | :--- |
| `tablem` | Markdown-style table. |
| `three-line-table` | Booktabs-style table. |
| `grid-table` | Grid table. |
| `zebraw` | Striped table rows. |

**Applied for you by `blog.site`, so not exported:**

- `post-nav` — `blog.site(post-nav: true)` puts newer/older links under every post.
- `tag-cloud` — `blog.site` builds the `/tags/` index and the per-tag archives.
- `post-asset` — a post's `assets: ((name, bytes),)` parameter does the same job.
- `with-html-math` — applied by the page shell.

## What left the surface

| Name | Now | Why |
| :--- | :--- | :--- |
| `slugify`, `canonical-page-url`, `heading-anchor-id`, `source-path-for`, `query-backlinks` | `src/paths.typ` | `site` and `webpage` call them. A site file sets `path:` and `title:` instead. |
| `sitemap-xml`, `rss-xml`, `atom-xml`, `render-seo-meta`, `content-to-feed-html` | `src/seo.typ` | `site` emits these files. |
| `to-plain-text`, `count-words`, `estimate-reading-minutes`, `word-hint`, `short-hash` | `src/text.typ` | Internal text measurement. |
| `any-content`, `collect-content`, `find-content`, `map-containers` | `src/tree.typ` | Content-tree walks used by the engine. |
| `resolve-page-langs`, `i18n-css`, `lang-switcher`, `normalize-alternates`, `missing-translations`, `assert-complete-translations` | `src/i18n.typ` | `site` and `blog.post` drive these. `tr` is the only one a site file writes. |
| `with-html-math` | `src/core.typ` | The page shell applies it. Installing a show rule was never the author's job. |
| `htm`, `h` | removed | Typst's own `html.*` constructors do the same, so a second builder was an opinion with a parser to maintain. |
| `page-asset`, `post-asset` | `src/core.typ`, `src/blog/post.typ` | The `assets:` parameter on `webpage` and `post` replaces them. |
| `query-pages`, `post-nav`, `tag-cloud` | `src/core.typ`, `src/blog/*` | `blog.site` calls them. `posts` is the one an author writes. |
| `css-oklch`, `css-hex`, `stylesheet-css`, `stylesheet-href`, `stylesheet-asset-path`, `resolve-theme`, `active-theme`, `theme-override-css`, `default-woff2-files` | `src/blog/theme.typ` | Palette construction. `theme:` takes a dictionary. |
| `container`, `marginnote` | `src/blog/notes.typ` | `sidenote`, `sn`, `mn` and `mcite` cover the use. |
| `checklist`, `showybox`, `zebraw-init`, `zebraw-themes` | `@preview` packages | `blog` wraps them. Import them from their own package. |
