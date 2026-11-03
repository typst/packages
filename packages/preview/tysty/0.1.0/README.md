# Tysty

Tysty is a library for organizing linked notes, inspired by Emacs Org-mode.
It provides document metadata, tags, cross-references, outlines, and navigation.
Render the same source as PDF, HTML, or a static website.

## Usage

API reference: [English](doc/README.api.en.md) · [简体中文](doc/README.api.zh_cn.md)

```typst
// Save this example as notebook.typ.
// Compile with: typst compile --root . notebook.typ
// Requires Typst 0.15.1 or later.
#import "@preview/tysty:0.1.0": *
// Top-level APIs automatically select PDF or HTML at the call site.
// Explicit pdf.* and html.* APIs remain available.
// Export this source as HTML with: typst compile --features html notebook.typ notebook.html
#show: template

// Set the prefix for document file-path links.
#set-base("file:///path/to/project/")

// Register a namespace and its nested tags.
#let topics = (tag.register)("notebook", (
  science: (physics: (:),),
))
#let physics = topics.children.science.children.physics.tag
// Attach a tag to a document by adding tags: (physics,) to its entry call.

// Declare and render a document with entry.
// Set cover: true to render a cover instead of the document heading.
// id, title, and authors are required; authors is an array of names or author records.
// Each document id must be unique within one compilation.
// Omitting parent-id inherits the current document, if one exists.
// Use parent-id: auto to declare an independent root.
#entry(
  id: "notebook",
  cover: true,
  title: [Book],
  authors: ("Alice",),
  date: datetime(year: 2026, month: 10, day: 30),
  tags: (physics,),
)[
  // Automatic outline: headings in PDF/single HTML, document routes in bundles.
  #mkoutline()
]

// entry renders a heading and body, registers the document as a reference
// target, and adds it to the prev/next reading sequence.
#entry(
  id: "note 1",
  parent-id: auto,
  title: [Note 1],
  authors: ("Alice",),
  date: datetime(year: 2026, month: 10, day: 30),
)[
  // embed increases the heading offset in PDF and restores the outer document context.
  // For a separate source file, use #embed(include "child.typ").
  // Semantic parent relationships are declared explicitly with parent-id.
  #embed[
    #entry(
      id: "sub note 1",
      parent-id: "note 1",
      title: [Sub Note 1],
      authors: ("Alice",),
      date: datetime(year: 2026, month: 10, day: 30, hour: 23, minute: 46, second: 0),
    )[
      sub note 1 content
    ]
  ]
  // entry can declare and render a document directly, without embed.
  #entry(
    id: "sub note 2",
    parent-id: "note 1",
    title: [Sub Note 2],
    authors: ("Alice",),
    date: datetime(year: 2026, month: 10, day: 30, hour: 23, minute: 46, second: 0),
  )[
    sub note 2 content
    #mkindex("label")[content shown]
  ]

  #render-children[Children]
  // List the direct children of the current document.
]

// A semantic child can also appear outside an embedded body.
#entry(
  id: "sub note 3",
  parent-id: "note 1",
  title: [Sub Note 3],
  authors: ("Alice",),
  date: datetime(year: 2026, month: 10, day: 30, hour: 23, minute: 46, second: 0),
)[
  sub note 3 content
  #lookup("label")[reference]
]

#let alice = (author.new)(
  name: "Alice",
  home: "https://example.com/",
  email: "no.reply@github.com",
  affiliation: "",
  orcid: "",
)

#let topics2 = (tag.register)(
  // register tag namespace
  "topics:root",
  (
  // two sub tag
    index: (:),
    about: (:),
  ),
)

#let index = topics2.children.index.tag
#let about = topics2.children.about.tag

#entry(
  id: "note 2",
  parent-id: auto,
  title: [Note 2],
  authors: (alice,),
  date: datetime(year: 2026, month: 10, day: 30, hour: 23, minute: 46, second: 0),
  // you can define category for a document
  category: (category.book)(
    publisher: "github",
    isbn: "(none)",
    edition: "0.1.0",
  ),
  tags: (index,),
)[
  Create and render a new document
]

#render-tags(topics)

// Reference a registered target with #lookup("sub note 1", [Sub Note 1]).
// In a context block, backlinks("sub note 1") returns its recorded references.
// render-children([Child notes]) lists children of the current document.
// render-tags(topics) renders the registered tag tree and its rendered notes.
// These views resolve registered targets even when they appear later in the source.
```

### Static site generation

```typst
// Save as site.typ. Requires Typst 0.15.1 or later.
// Compile with: typst compile --root . --features html,bundle --format bundle site.typ output
#import "@preview/tysty:0.1.0": *
#show: template

// Declare and render the root page explicitly, just like the child pages below.
#entry(id: "home", title: [Notebook], authors: ())[Entry page]

// An embed can declare and emit its own child page. The route is computed
// from the document ID; nested ancestors become route directories.
// In bundle mode, keep page-producing entry calls outside another page's body.
#embed[
  #entry(id: "research", parent-id: "home", title: [Research], authors: ())[
    = Research questions
    Research notes.
    == Open problems
    More to explore.
    // The automatic mkoutline selects the route-aware document tree in bundles.
    #mkoutline()
  ]

  #embed[
    #entry(id: "review", parent-id: "research", title: [Review], authors: ())[
      Literature review.
      // Reuse the research page's body in this page.
      #ssg.ref("research")
    ]
  ]
]

// Outputs: index.html, research/index.html,
// research/review/index.html, and tysty.css.
// entry uses each document's metadata and parent chain to determine its route.
// Navigation and breadcrumbs are in the top bar; section links appear in the right sidebar.
// mkoutline() uses Typst's outline for PDF/single HTML and SSG routes for bundles.
// Keep page-producing entry calls outside another page's entry body.
```

### Output previews

#### Static site generation

The generated site includes page navigation, breadcrumbs, section outlines, and reusable page content.

| Home | Research | Review with reused research content |
| --- | --- | --- |
| ![SSG home page](imgs/Screenshot%20from%202026-11-02%2011-41-26.png) | ![SSG research page with document tree and section outline](imgs/Screenshot%20from%202026-11-02%2011-41-36.png) | ![SSG review page reusing the research page body](imgs/Screenshot%20from%202026-11-02%2011-41-44.png) |

#### PDF

Document headings, metadata, navigation, nested notes, and tag listings in the PDF output.

| Book | Note heading |
| --- | --- |
| ![PDF book heading and metadata](imgs/Screenshot%20from%202026-11-02%2011-44-57.png) | ![PDF note heading](imgs/Screenshot%20from%202026-11-02%2011-45-04.png) |

| Note navigation | Nested note |
| --- | --- |
| ![PDF note with previous and next navigation](imgs/Screenshot%20from%202026-11-02%2011-45-11.png) | ![PDF nested note with breadcrumbs and back link](imgs/Screenshot%20from%202026-11-02%2011-45-21.png) |

![PDF publication metadata and hierarchical tag listing](imgs/Screenshot%20from%202026-11-02%2011-45-37.png)

#### Single-file HTML

The same notebook rendered as HTML, with a cover, automatic outline, and document navigation.

![Single-file HTML notebook with cover, contents, and nested notes](imgs/Screenshot%20from%202026-11-02%2011-46-37.png)

## Maintainers

[github@mujiu555(暮玖)](https://github.com/mujiu555)

## License

[Apache License 2.0](LICENSE).
