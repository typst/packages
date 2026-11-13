#import "@preview/thyme:0.1.0": *
#import blog: *

#show: post.with(
  title: [Static Sites & Tadi Source Transparency in Pure Typst],
  subtitle: [Zero-CLI bundles, typed HTML, sitemaps, and inspectable .typ sources],
  author: "Ada Lovelace",
  monograph: "EWD-01",
  created: datetime(year: 2026, month: 10, day: 18),
  modified: datetime(year: 2026, month: 10, day: 29),
  summary: [Why a static site only needs Typst's native compiler, inspectable .typ sources, semantic HTML, and zero-JS CSS.],
  tags: ("typst", "ssg", "web"),
)

Static site generators have a habit of accumulating external CLI wrappers, JavaScript bundlers, and brittle template DSLs#sidenote[A site whose build pipeline outlives its prose has inverted its priorities.]. With `thyme` and Typst's native `bundle` target, `typst watch` serves as the live-reloading dev server and `typst compile` builds the entire web root in one pass.

Cross-references work natively across files: writing `@fixed-points` links to @fixed-points, while `@kleene-fp` jumps straight to @kleene-fp inside that article.

= Tadi Web Source View & Zero-JS Features <tadi-web>

Passing capability paths (`#post(path("posts/fixed-points.typ"))`) lets `thyme` simultaneously evaluate each page and co-emit its verbatim `.typ` source alongside the rendered HTML (linked via `.typ` in the top bar). Readers who want an archival paper copy press #kbd("Ctrl+P") for a two-column `@media print` layout.

- [x] Zero custom CLI wrappers — driven purely by `typst watch` and `typst compile`
- [x] Typst's native typed `html.*` constructors, with no builder of our own
- [x] Automatic `sitemap.xml`, `robots.txt`, `rss.xml`, and `atom.xml` via `syndicate`
- [x] Tadi Web sibling `.typ` source co-emission and single-URL zero-JS CSS `#tr(...)` i18n
- [ ] Client-side JavaScript runtimes or framework lock-in

= Compilation Modes at a Glance <modes>

When a table or figure benefits from the full width of prose plus margin, wrap it in `#wide[...]`:

#wide[
  #tablem[
    | *Command* | *Target* | *Result* |
    | :--- | :--- | :--- |
    | `typst compile --features html,bundle -f bundle site.typ public` | `bundle` | `index.html`, `posts/`, `.typ` sources, `sitemap.xml`, `robots.txt`, `rss.xml`, `atom.xml` |
    | `typst watch --features html,bundle -f bundle site.typ public` | `bundle` | Built-in live-reloading HTTP dev server |
    | `typst watch posts/fixed-points.typ` | `paged` | Instant `height: auto` editor preview |
  ]
]

#example[Single-Source Fan-Out][
  Vector diagrams authored in Typst render natively in editor previews and as crisp inline `<svg>` in HTML (automatically inverted in dark mode):

  #diagram(
    caption: [One Typst source tree compiling to HTML, raw .typ sources, sitemap.xml, and RSS / Atom feeds.],
  )[
    #set text(
      font: theme-default.mono-fonts,
      size: 8.5pt,
      fill: theme-default.text-light,
    )
    #let node(lbl) = box(
      fill: theme-default.surface-1-light,
      stroke: 0.75pt + theme-default.frame-light,
      inset: (x: 0.75em, y: 0.48em),
      radius: 2.5pt,
      lbl,
    )
    #grid(
      columns: 5,
      gutter: 0.65em,
      align: horizon,
      node[`posts/*.typ`], $->$, node[`site.typ`], $->$, node[`HTML + .typ + XML`],
    )
  ]
]

Return to @site[`folio`].
