# API reference

[Usage examples](../README.md#usage) · [简体中文](README.api.zh_cn.md)

## Getting started

Use Typst 0.15.1 or later with `@preview/tysty:0.1.0` installed. Import the package, select a template, and create documents with `entry`:

```typst
#import "@preview/tysty:0.1.0": *
#show: template
#entry(id: "home", title: [Notebook], authors: ())[
  #mkcover()
  Notebook content.
]
```

## Documents and metadata

`entry(..fields, content)` declares metadata and renders the document's heading and body, registers its ID as a reference target, and adds it to the reading sequence. Put `mkcover()` inside its body when a cover is needed. Document IDs must be unique within a compilation.

When `parent-id` is omitted, `entry` inherits the current document's ID if available; otherwise it creates a semantic root. Explicit `parent-id: auto` always makes the document its own root. `entry` does not restore the previous current document; use `embed` to save and restore that context. Parent relationships are separate from visual heading nesting.

| Field | Type | Default and meaning |
| --- | --- | --- |
| `id` | `str` | Required, unique |
| `title` | `content` | Required, e.g. `[Title]` |
| `authors` | `array` | Required; strings or author records; `()` allowed |
| `parent-id` | `str` or `auto` | Inherit in `entry`; explicit `auto` means root |
| `file-path` | `str` | `"(no link (uri))"`; appended to file base |
| `date` | `datetime` | `datetime.today()` |
| `lang` | `str` | `"en_US"` |
| `version` | `str` | `"0.0.1"` |
| `doi` | `str` | `"(none)"` |
| `abstract`, `description` | `str` | `""` |
| `keywords` | array of strings | `()` |
| `license` | `str` | `"apache-v2"` |
| `cover_image` | `img` | `img.null` |
| `category` | `category` | `category.null` |
| `tags` | array of tag records | `()` |
| `tlb` | `dictionary` | `(:)`; stored metadata |

`entry` accepts the metadata fields listed above. Rendering options such as `new-page` are not supported by `entry`. Optional fields still require their declared types; `none` is not a substitute for their defaults.

`meta(..fields)` is the lower-level declaration API with the same metadata fields. It publishes metadata and selects the current document without rendering or registering a heading. Unlike `entry`, omitted `parent-id` means a root. Use `entry` to declare and render a document in one call.

## Automatic rendering

Use these helpers in shared PDF, HTML, and bundle sources. They choose the appropriate rendering behavior at the call site.

| API | Behavior |
| --- | --- |
| `template(body, ..options)` | Use with `#show: template`; selects PDF, single HTML, or bundle wrapper. Options go to the selected wrapper. |
| `embed(body, offset: …)` | Saves/restores the current document; heading offset defaults to `true` in PDF and `false` in HTML/bundles. |
| `mkcover()` | Renders the current document's cover without adding another reference target or reading-sequence entry. |
| `mkoutline(..args)` | Automatically renders a heading outline for PDF/single HTML, or a document tree with page links for bundles (including calls inside bundle pages). |
| `render-children(title)` | Lists directly related children that have rendered reference targets. |
| `render-tags(tree)` | Renders a registered tag tree and rendered documents directly tagged at each node. |
| `set-base(p)` | Sets the string prefix used with document `file-path` links. |

`mkoutline()` uses the default outline title. Use `mkoutline(title: [Contents])` to customize it. PDF and single HTML accept Typst’s `outline` options; bundles accept `title` and `depth`, although bundle `depth` currently does not limit the tree.

```typst
#import "@preview/tysty:0.1.0": *
#show: template
#set-base("https://example.com/notes/")
#entry(id: "parent", title: [Parent], authors: (), file-path: "parent.typ")[
  #mkoutline()
  #embed[
    #entry(id: "child", title: [Child], authors: ())[
      Child content.
    ]
  ]
  #render-children[Children]
]
```

Use `#embed(include "child.typ")` for a separate source file. For bundles, keep page-producing `entry` calls outside another page's body, as shown in the README's static-site example.

## References and queries

| API | Result or behavior |
| --- | --- |
| `mkindex(label, content)` | Displays content and registers a unique string label at that location. Document IDs already occupy labels. |
| `lookup(label, content)` | Renders a link and records a backlink with the caller's document ID, if available. Unknown targets fail compilation; forward references are supported. |
| `indexers()` | Contextual array in document order; records have `label`, `loc`, `content`, and `lookup(content)`. |
| `backlinks(label)` | Contextual array of references with `loc`, `content`, and `ctx`; `ctx.variant` is `"doc"` (ID in `ctx.payload`) or `"null"`. |

```typst
#import "@preview/tysty:0.1.0": *
#show: template
#entry(id: "note", title: [Note], authors: ())[
  #mkindex("term")[A term]
  #lookup("term")[See the term]
  #context {
    let refs = backlinks("term")
    [References: #refs.len()]
    for item in indexers() {
      par((item.lookup)(item.content))
    }
  }
]
```

Calling an index record's `lookup` creates a plain link without recording a backlink. Navigation links likewise do not create backlinks.

## Authors, images, categories

`(author.new)(name: ..., affiliation: ..., email: ..., home: ..., orcid: ...)` requires all five string fields. Empty strings are allowed. `authors` also accepts plain names.

```typst
#let alice = (author.new)(name: "Alice", affiliation: "Lab", email: "", home: "", orcid: "")
#let bob = (author.update)(alice, name: "Bob")
#let make-author = (author.with)(affiliation: "Lab", email: "", home: "", orcid: "")
#let carol = make-author(name: "Carol")
```

| Image value | Meaning |
| --- | --- |
| `(img.path)(path("cover.png"))` | Image path |
| `(img.data)(read("cover.png", encoding: none))` | Raw image bytes |
| `img.null` | No image; a value, not a constructor |

Pass these values as `cover_image` to `entry`, then call `mkcover()` in its body.

All category constructors use named fields. Fields are strings except `volume` and `issue`, which are integers. Each constructor requires all listed fields.

| Constructor | Fields |
| --- | --- |
| `category.journal` | `journal`, `volume`, `issue`, `pages` |
| `category.conference` | `conference`, `proceedings` |
| `category.book` | `publisher`, `isbn`, `edition` |
| `category.bookChapter` | `book`, `pages` |
| `category.thesis` | `degree`, `university` |
| `category.report` | `institution`, `number` |
| `category.preprint` | `repository`, `platform` |
| `category.blogPost` | `site`, `series` |
| `category.null` | No category; a ready-made value |

Example: `(category.journal)(journal: "Example", volume: 1, issue: 2, pages: "1–8")`.

Record types such as `author` expose `new(..fields)`, `update(instance, ..fields)` (returns a validated copy), `with(..defaults)` (returns a constructor), and `compare(other-type)` (type compatibility, not instance equality). Instances expose `fields()` to recursively extract data fields. `tag` is also a record type; prefer `tag.register` and tag-instance `sub` to constructing its state fields yourself.

`img` and `category` expose `new(variant, ..args)`, `with(variant, ..defaults)`, and `compare(other-type)`. Variant constructors are shorthand for `new`. Instances expose `variant`, `payload`, and `fields()`; the latter returns a dictionary keyed by variant name. Names such as `category.null` and `img.null` are already instances.

## Tags

`(tag.register)(namespace, tree)` takes a string namespace and a nested dictionary whose leaves are `(:)`. It returns a node with `tag` and `children`; each child uses the same node shape. A tag has `id`, `name`, and parent ID `_parent`.

```typst
#let topics = (tag.register)("notes", (science: (physics: (:),),))
#let physics = topics.children.science.children.physics.tag
#let optics = (physics.sub)("optics")
// Inside entry: tags: (physics,)
#context {
  let notes = (physics.get-doc)()
  [Tagged documents: #notes.len()]
}
```

`(tag-instance.sub)(name)` creates a child tag with a deterministic ID. It does not insert that tag into an existing tree's `children` dictionary. `(tag-instance.get-doc)()` queries documents directly carrying that tag, including declared but unrendered documents; it does not include descendant tags automatically.

## Current document state

Use `current` only to read document information. Users are not expected to update it directly; `entry` and `embed` manage the current document and its scope.

Call read methods inside a context block, with parentheses around the method name, for example `#context { (current.get)().title }`.

| Method | Behavior |
| --- | --- |
| `(current.get)()` | Current record; initially `(:)` |
| `(current.at)(loc)` | Record at a Typst location |
| `(current.final)()` | Final current record |

Use `entry` to select a document and `embed` to save and restore the surrounding document context. Do not call `current.update`, `current.enter`, or `current.leave` directly in normal usage.

## Explicit renderer namespaces

Use these when the output target is known. Automatic helpers above are usually sufficient. The package's `html` module name can shadow Typst's built-in `html`; use `std.html` for built-in HTML operations when necessary.

| Namespace API | Signature and behavior |
| --- | --- |
| `pdf.template` | `(body)`; PDF page styling |
| `html.template` | `(body, title: "Notebook", lang: "en", css: html.stylesheet, css-href: none)`; inline CSS unless `css-href` is supplied |
| `pdf.embed`, `html.embed` | `(body, offset: true/false)` respectively |
| `pdf.mkdoc` | `(content, new-page: true)`; renders current metadata |
| `html.mkdoc` | `(content, new-page: true, ssg: false)`; accepts but ignores `new-page`; `ssg` selects site layout |
| `pdf.mkcover`, `html.mkcover` | `()`; current document's cover |
| `pdf.lookup`, `html.lookup` | `(label, content)`; same reference behavior as top-level helper |
| `pdf.mkindex`, `html.mkindex` | `(label, content)`; shared index registration |
| `pdf.render-children`, `html.render-children` | `(title)`; target-specific child list |
| `pdf.render-tags`, `html.render-tags` | `(tree)`; target-specific tag tree |
| `html.stylesheet` | Default CSS string |
| `html.page` | `(path, body, title: "Notebook", lang: "en")`; emits a bundle HTML page and restores document scope |
| `html.bundle` | `(body, css: html.stylesheet)`; emits shared `tysty.css` |

`html.page` requires a relative `.html` path without empty, `.` or `..` segments. For explicit paths, use the following independent bundle example:

```typst
#import "@preview/tysty:0.1.0": *
#show: html.bundle
#html.page("guide/index.html", title: "Guide")[
  #entry(id: "guide", title: [Guide], authors: ())[
    #mkcover()
    Guide content.
  ]
]
```

Compile with `typst compile --root . --features html,bundle --format bundle manual.typ output`.

## Static site generation

Use `#show: template` and compile with `--features html,bundle --format bundle`. The README contains a complete `entry`-based site example. Automatic routes follow semantic parents, omit the root's ID, and place each page at `index.html` in its route directory. Ancestor documents must exist and parent chains must not cycle. Keep generated routes unique.

| API | Behavior |
| --- | --- |
| `ssg.route(id, ancestors: (), root: false)` | Pure route calculation; `root: true` returns `"index.html"`. Otherwise joins slugged ancestors and ID, then appends `/index.html`. |
| `ssg.mkoutline(depth: none, title: [Documents])` | Site tree with relative page links; currently `depth` is accepted but does not limit the tree. |
| `ssg.ref(label)` | Inserts the generated page's stored Typst body, temporarily selecting its document context; this is content reuse, not just a link. Target must have been generated. |
| `ssg.embed(body, offset: false)` | Saves/restores current document context |
| `ssg.mkdoc(body)` | Low-level renderer: emits a routed page in bundles; otherwise uses HTML rendering |
| `ssg.is-bundle-output()` | Contextual query for bundle markers |
| `ssg.entities()` | Contextual array of generated page IDs, deduplicated |

Route examples:

```typst
#assert.eq(ssg.route("Home", root: true), "index.html")
#assert.eq(ssg.route("Review", ancestors: ("Research",)), "research/review/index.html")
```

Slugs lowercase text, keep Unicode letters and digits, replace other runs with hyphens, preserve `/` separators, and use `untitled` if empty. `route` processes exactly the ancestor list supplied; it does not query or remove a root automatically.
