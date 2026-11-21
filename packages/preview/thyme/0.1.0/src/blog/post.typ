// Scholarly blog post template (`#show: post.with(...)`), inline capability-path mounter
// (`#post(path("posts/foo.typ")) <foo>`), co-located assets, Tadi `.typ` top-bar link,
// zero-JS CSS i18n integration, backlinks, chronological navigation, and paged PDF preview styling.

#import "@preview/cheq:0.4.0": checklist
#import "@preview/zebraw:0.6.3": zebraw-init
#import "../core.typ": (
  backlinks, extract-page-assets, extract-page-meta, lookup-source-href, mount, normalize-assets, page-asset,
  query-doc-tr-codes, query-pages, render-top-bar, site-config,
)
#import "../i18n.typ": assert-complete-translations, resolve-page-langs
#import "../paths.typ": (
  date-sort-key, find-doc-containing, format-date, join-path, rel-href, slug-from-path, slugify, with-html-headings,
  with-smart-refs,
)
#import "../text.typ": count-words, estimate-reading-minutes, query-body-words
#import "html.typ": render-html-shell
#import "notes.typ": is-sidenote-link, reset-sidenotes, sidenote, sidenote-bottom-guard
#import "theme.typ": active-theme, resolve-theme, theme-default, theme-override-css

#let _paged-sec-counter = counter("blog/paged-sec")

/// Declare a co-located file asset inline inside a post body
/// (`#post-asset("dfa.svg", path("dfa.svg")) <dfa>` or `read("dfa.svg", encoding: none)`).
/// -> content
#let post-asset = page-asset

/// Query all public (non-draft, non-unlisted) posts in the active bundle, sorted newest-first.
/// Must be called inside `context`.
/// -> array
/// Render chronological older / newer navigation links at the bottom of a post.
/// Emits nothing when outside a bundle or when only one public post exists.
/// -> content
#let post-nav(
  /// Label shown above the chronologically older post.
  /// -> content | str
  older-label: "← older",
  /// Label shown above the chronologically newer post.
  /// -> content | str
  newer-label: "newer →",
) = context {
  let enc-doc = find-doc-containing(here())
  if enc-doc == none or enc-doc.path == none {
    return []
  }
  let all-posts = query-pages(collection: "posts")
  let idx = all-posts.position(p => p.html-path == enc-doc.path)
  if idx == none {
    return []
  }
  // `all-posts` is sorted newest-first: `idx - 1` is newer, `idx + 1` is older
  let newer = if idx > 0 { all-posts.at(idx - 1) } else { none }
  let older = if idx + 1 < all-posts.len() { all-posts.at(idx + 1) } else {
    none
  }
  if older == none and newer == none {
    return []
  }

  if target() == "html" {
    html.elem(
      "nav",
      attrs: (class: "blog-post-nav", "aria-label": "Post navigation"),
      {
        if older != none {
          html.div(class: ("post-nav-item", "post-nav-prev"), {
            html.span(class: "post-nav-label", older-label)
            link(older.doc-loc, older.title)
          })
        }
        if newer != none {
          html.div(class: ("post-nav-item", "post-nav-next"), {
            html.span(class: "post-nav-label", newer-label)
            link(newer.doc-loc, newer.title)
          })
        }
      },
    )
  } else {
    let t = active-theme()
    v(1em)
    line(length: 100%, stroke: 0.5pt + t.border-light)
    grid(
      columns: (1fr, 1fr),
      align: (left, right),
      if older != none {
        link(older.doc-loc, older-label + [ ] + older.title)
      } else { [] },
      if newer != none {
        link(newer.doc-loc, newer.title + [ ] + newer-label)
      } else { [] },
    )
  }
}

// Apply theme-driven `oklch` monochrome typography to paged previews.
#let style-paged-article(
  theme-config,
  lang: "en",
  numbered-headings: true,
  body,
) = {
  set text(
    font: theme-config.serif-fonts,
    size: theme-config.font-size,
    fill: theme-config.text-light,
    lang: lang,
  )
  set par(
    leading: 0.68em,
    spacing: 1.12em,
    justify: false,
  )

  show math.equation: set text(font: theme-config.math-fonts)
  show raw: set text(font: theme-config.mono-fonts, size: 0.84em)
  show raw.where(block: false): box.with(
    fill: theme-config.surface-1-light,
    stroke: 0.45pt + theme-config.border-light,
    inset: (x: 0.3em, y: 0.12em),
    outset: (y: 0.12em),
    radius: 2pt,
  )
  show raw.where(block: true): block.with(
    width: 100%,
    fill: theme-config.surface-1-light,
    stroke: 0.55pt + theme-config.border-light,
    inset: (x: 0.9em, y: 0.75em),
    radius: 2.5pt,
  )

  show link: it => {
    if (
      type(it.dest) in (str, location, label) and not is-sidenote-link(it.body)
    ) {
      underline(stroke: 0.5pt + theme-config.muted-light, offset: 2pt, text(
        fill: theme-config.text-light,
        it,
      ))
    } else {
      it
    }
  }

  show heading: set text(
    font: theme-config.serif-fonts,
    fill: theme-config.text-light,
  )
  show heading.where(level: 1): it => {
    if numbered-headings {
      _paged-sec-counter.step()
    }
    block(
      width: 100%,
      above: 1.85em,
      below: 0.78em,
      inset: (bottom: 0.38em),
      stroke: (bottom: 0.55pt + theme-config.border-light),
      context {
        if numbered-headings {
          let n = _paged-sec-counter.get().first()
          let pad = if n < 10 { "0" + str(n) } else { str(n) }
          text(
            font: theme-config.mono-fonts,
            size: 0.78em,
            weight: "regular",
            fill: theme-config.muted-light,
            pad,
          )
          h(0.55em)
        }
        text(size: 1.38em, weight: "semibold", it.body)
      },
    )
  }
  show heading.where(level: 2): it => block(above: 1.35em, below: 0.55em, {
    text(size: 1.14em, weight: "semibold", it.body)
  })
  show heading.where(level: 3): it => block(above: 1.1em, below: 0.45em, {
    text(size: 1.02em, weight: "semibold", emph(it.body))
  })

  show quote.where(block: true): it => block(
    width: 100%,
    inset: (left: 1em, y: 0.2em),
    stroke: (left: 1.5pt + theme-config.text-light),
    above: 1.1em,
    below: 1.1em,
    {
      emph(text(fill: theme-config.muted-light, it.body))
      if it.attribution != none {
        v(0.3em)
        align(right, text(
          font: theme-config.mono-fonts,
          size: 0.78em,
          fill: theme-config.muted-light,
          "- " + it.attribution,
        ))
      }
    },
  )

  set table(
    stroke: (_, y) => (
      top: if y == 0 { 1pt + theme-config.text-light } else if y == 1 {
        0.6pt + theme-config.text-light
      } else { none },
      bottom: 1pt + theme-config.text-light,
    ),
    inset: (x: 0.65em, y: 0.46em),
  )
  show table.cell.where(y: 0): set text(weight: "semibold")

  body
}

/// Dual-purpose scholarly post template and inline capability-path mounter:
/// - In a post file (`posts/foo.typ` or `posts/foo/site.typ`):
///   `#show: post.with(title: [...], author: "...", created: ..., modified: ...)`
/// - In `site.typ`:
///   `#post(path("posts/foo.typ")) <foo>` (evaluates the post AND exposes `/posts/foo.typ` as Tadi Web plaintext source; `include "posts/foo.typ"` is also accepted).
/// -> content
#let post(
  /// Post title (`<h1>` in HTML, semibold heading in paged mode); `auto` detects a mounted post in `site.typ`.
  /// -> auto | content | str
  title: auto,
  /// Optional italic subtitle beneath `title` (also used as fallback summary).
  /// -> content | str | none
  subtitle: none,
  /// Creation date (`YYYY-MM-DD`); drives feed publication timestamps and newest-first sort order.
  /// -> datetime | str | none
  created: none,
  /// Last-modified date (`YYYY-MM-DD`); drives `sitemap.xml` `<lastmod>` and Atom `<updated>`.
  /// -> datetime | str | none
  modified: none,
  /// Alias for `created`.
  /// -> datetime | str | none
  date: none,
  /// Alias for `modified`.
  /// -> datetime | str | none
  updated: none,
  /// Post language (`auto` inherits from `site` and auto-detects the languages in its
  /// `#tr(...)` blocks; a code such as `"en"`, or an array such as `("en", "de", "fr")`).
  /// -> auto | str | array
  lang: auto,
  /// Optional `hreflang` alternate URLs (`(de: "de/posts/foo/index.html")`).
  /// -> dictionary | array | none
  alternates: none,
  /// Post author; falls back to `site.with(author: ...)` inside a bundle.
  /// -> content | str | none
  author: none,
  /// Optional EWD-style monograph code (e.g. `"EWD-02"`) rendered right beneath `author` in post frontmatter.
  /// -> content | str | none
  monograph: none,
  /// Plain `#tag` strings rendered in `Commit Mono` and exported as RSS / Atom `<category>`.
  /// -> array
  tags: (),
  /// Short abstract displayed on homepage entry cards and in RSS / Atom feeds.
  /// -> content | str | none
  summary: none,
  /// Co-located files (`("dfa.svg": path("dfa.svg"))`) emitted into `posts/<slug>/`.
  /// -> dictionary | array
  assets: (),
  /// Explicit slug override; defaults to `<label>` or `.typ` filename.
  /// -> auto | str
  slug: auto,
  /// Optional custom bundle output path when mounting in `site.typ` (defaults to `<posts-dir>/<slug>/index.html`).
  /// -> str | none
  path: none,
  /// Optional `.typ` source override when mounting via `include` instead of `path(...)`.
  /// -> path | str | none
  src: none,
  /// Backlink label at the top-left of HTML post pages (automatically omitted in PDF and `@media print`).
  /// -> content | str | none
  home-text: "/..",
  /// Words-per-minute reading speed used to compute `reading` minutes.
  /// -> int
  wpm: 200,
  /// Display `words` and `reading` rows in the post frontmatter block.
  /// -> bool
  show-wordcount: true,
  /// Exclude post from homepage listings, `sitemap.xml`, and RSS / Atom feeds when `true`.
  /// -> bool
  draft: false,
  /// Emit the HTML page at its URL, but omit it from homepage listings, `sitemap.xml`, and feeds.
  /// -> bool
  unlisted: false,
  /// Prefix top-level `=` sections with `01`, `02`, ... in `Commit Mono`.
  /// -> bool
  numbered-headings: true,
  /// Append `§` hover permalinks on section headings (`auto` inherits from `site`).
  /// -> auto | bool
  heading-permalinks: auto,
  /// Automatically route standard `#footnote[...]` calls into the right margin.
  /// -> bool
  footnotes-as-sidenotes: true,
  /// Automatically route normal `@bib` bibliography citations into right-margin sidenotes.
  /// -> bool
  citations-as-sidenotes: false,
  /// Render compile-time backlinks footer at the bottom of the post (`auto` inherits from `site`).
  /// -> auto | bool
  show-backlinks: auto,
  /// Render chronological older / newer navigation at the bottom of the post (`auto` inherits from `site`).
  /// -> auto | bool
  show-post-nav: auto,
  /// Inject copy-button JavaScript (`auto` injects only when the post contains `#zebraw` code blocks).
  /// -> auto | bool
  copy-button: auto,
  /// Emit OpenGraph `<meta property="og:*">` tags (`auto` inherits from `site`).
  /// -> auto | bool
  open-graph: auto,
  /// Emit Google Scholar Highwire `<meta name="citation_*">` tags (`auto` inherits from `site`).
  /// -> auto | bool
  scholar-meta: auto,
  /// Additional `<head>` elements injected into this post's HTML document.
  /// -> content | none
  head: none,
  /// Per-post theme overrides layered onto the active site theme.
  /// -> dictionary
  theme: (:),
  /// Paged preview width override (`auto` uses `theme.page-width`).
  /// -> auto | length
  page-width: auto,
  /// Paged preview margin override (`auto` uses `theme.margin`).
  /// -> auto | dictionary
  margin: auto,
  /// Post body markup (when used via `#show: post.with(...)`) or `path("posts/...")` / `include "posts/..."` (when mounted in `site.typ`).
  /// -> path | content
  body,
) = {
  if title == auto and type(body) == std.path {
    return mount(
      body,
      slug: slug,
      route: path,
      collection: "posts",
      assets: assets,
    )
  }
  let detected-meta = if title == auto { extract-page-meta(body) } else { none }
  if detected-meta != none {
    return mount(
      body,
      slug: slug,
      route: path,
      collection: "posts",
      assets: assets,
      src: src,
    )
  }

  let title = if title == auto { [Untitled Post] } else { title }
  let explicit-slug = if slug == auto { none } else { slug }
  let eff-created = if created != none { created } else { date }
  let eff-modified = if modified != none { modified } else { updated }
  let created-str = format-date(eff-created)
  let modified-str = format-date(eff-modified)
  let base-words = count-words(body)
  let norm-assets = normalize-assets(assets) + extract-page-assets(body)
  let initial-langs = resolve-page-langs(lang, scan-nodes: (
    title,
    subtitle,
    summary,
    body,
  ))

  let meta-payload = (
    title: title,
    subtitle: subtitle,
    description: if summary != none { summary } else { subtitle },
    summary: summary,
    created: eff-created,
    created-str: created-str,
    modified: eff-modified,
    modified-str: modified-str,
    sort-key: date-sort-key(eff-created),
    author: author,
    monograph: monograph,
    tags: tags,
    alternates: alternates,
    collection: "posts",
    langs: initial-langs,
    primary-lang: initial-langs.first(),
    assets: norm-assets,
    slug: explicit-slug,
    base-words: base-words,
    wpm: wpm,
    raw-body: body,
    draft: draft,
    unlisted: unlisted,
    is-wrapped-page: true,
  )

  [#metadata(meta-payload)<thyme-page-meta>]
  reset-sidenotes()
  _paged-sec-counter.update(0)

  set footnote.entry(separator: if footnotes-as-sidenotes { none } else {
    line(length: 30%, stroke: 0.5pt)
  })
  show footnote.entry: it => if footnotes-as-sidenotes { none } else { it }
  show footnote: fn => if footnotes-as-sidenotes { sidenote(fn.body) } else {
    fn
  }
  show cite.where(form: "normal"): it => if citations-as-sidenotes {
    sidenote({
      cite(it.key, form: "full")
      if it.supplement != none { [, ] + it.supplement }
    })
  } else {
    it
  }

  context {
    let enc-doc = find-doc-containing(here())
    let doc-path = if enc-doc != none { enc-doc.path } else { none }
    // Merged preset + core site metadata (preset keys win).
    let site-config = site-config()
    let base-theme = if site-config != none { site-config.theme } else {
      theme-default
    }
    let has-post-theme = theme != none and theme != (:)
    let merged-theme = resolve-theme(
      base-theme + (if has-post-theme { theme } else { (:) }),
    )
    let site-title = if site-config != none { site-config.title } else { none }
    let site-url = if site-config != none { site-config.url } else { none }
    let site-lang = if site-config != none { site-config.lang } else { "en" }
    let eff-langs = resolve-page-langs(
      lang,
      default-lang: site-lang,
      scan-nodes: (title, subtitle, summary, body),
      queried-codes: query-doc-tr-codes(enc-doc),
    )
    assert-complete-translations((title, subtitle, summary, body), eff-langs)
    let primary-lang = eff-langs.first()
    let eff-author = if author != none {
      author
    } else if site-config != none {
      site-config.at("author", default: none)
    } else {
      none
    }
    let eff-permalinks = if heading-permalinks != auto {
      heading-permalinks == true
    } else if site-config != none {
      site-config.at("heading-permalinks", default: false)
    } else {
      false
    }
    let eff-backlinks = if show-backlinks != auto {
      show-backlinks == true
    } else if site-config != none {
      site-config.at("backlinks", default: false)
    } else {
      false
    }
    let eff-post-nav = if show-post-nav != auto {
      show-post-nav == true
    } else if site-config != none {
      site-config.at("post-nav", default: false)
    } else {
      false
    }
    let eff-copy = if copy-button != auto {
      copy-button
    } else if site-config != none {
      site-config.at("copy-button", default: auto)
    } else {
      auto
    }
    let eff-og = if open-graph != auto {
      open-graph == true
    } else if site-config != none {
      site-config.at("open-graph", default: false)
    } else {
      false
    }
    let eff-scholar = if scholar-meta != auto {
      scholar-meta == true
    } else if site-config != none {
      site-config.at("scholar-meta", default: false)
    } else {
      false
    }
    let link-tags = (
      site-config != none and site-config.at("tag-pages", default: false) and doc-path != none
    )
    let tags-dir = if site-config != none {
      site-config.at("tags-dir", default: "tags")
    } else { "tags" }

    let has-props = (
      eff-author != none
        or monograph != none
        or created-str != none
        or modified-str != none
        or show-wordcount
        or tags.len() > 0
    )

    if target() == "html" {
      let home-docs = query(<site>)
      let back-node = if home-text != none {
        if home-docs.len() > 0 {
          link(home-docs.first().location(), home-text)
        } else {
          home-text
        }
      } else {
        none
      }
      let src-label = if site-config != none {
        site-config.at("source-label", default: none)
      } else { none }
      let src-href = if src-label != none {
        lookup-source-href(doc-path)
      } else { none }
      let sheet-paths = if site-config != none {
        site-config.at("stylesheet-paths", default: auto)
      } else {
        auto
      }
      let theme-override-css = if doc-path != none and has-post-theme {
        theme-override-css(merged-theme)
      } else {
        none
      }

      render-html-shell(
        title: title,
        site-title: site-title,
        description: if summary != none { summary } else { subtitle },
        author: eff-author,
        site-url: site-url,
        doc-path: doc-path,
        doc-el: enc-doc,
        langs: eff-langs,
        alternates: alternates,
        stylesheet-paths: sheet-paths,
        theme-override-css: theme-override-css,
        favicon-href: if site-config != none {
          site-config.at("favicon-href", default: none)
        } else { none },
        favicon-type: if site-config != none {
          site-config.at("favicon-type", default: none)
        } else { none },
        source-href: src-href,
        source-label: src-label,
        theme-config: merged-theme,
        copy-button: eff-copy,
        include-feeds: false,
        created: eff-created,
        modified: eff-modified,
        monograph: monograph,
        tags: tags,
        is-article: true,
        open-graph: eff-og,
        scholar-meta: eff-scholar,
        extra-head: head,
        {
          html.article(
            ..if numbered-headings { (class: "numbered-sections") } else {
              (:)
            },
            {
              render-top-bar(
                back-content: back-node,
                langs: eff-langs,
                source-href: src-href,
                source-label: src-label,
              )

              html.header(class: "article-header", {
                html.h1(title)
                if subtitle != none {
                  html.p(class: "article-subtitle", subtitle)
                }

                if has-props {
                  html.dl(class: "post-props", {
                    if eff-author != none {
                      html.dt("author")
                      html.dd(eff-author)
                    }
                    if monograph != none {
                      html.dt("monograph")
                      html.dd(monograph)
                    }
                    if created-str != none {
                      html.dt("created")
                      html.dd(html.elem(
                        "time",
                        attrs: (datetime: created-str),
                        created-str,
                      ))
                    }
                    if modified-str != none {
                      html.dt("modified")
                      html.dd(html.elem(
                        "time",
                        attrs: (datetime: modified-str),
                        modified-str,
                      ))
                    }
                    if show-wordcount {
                      html.dt("words")
                      html.dd(context str(query-body-words(
                        base-words,
                        doc-el: enc-doc,
                      )))
                      html.dt("reading")
                      html.dd(context {
                        (
                          str(estimate-reading-minutes(
                            query-body-words(base-words, doc-el: enc-doc),
                            wpm: wpm,
                          ))
                            + " min"
                        )
                      })
                    }
                    if tags.len() > 0 {
                      html.dt("tags")
                      html.dd({
                        for t in tags {
                          let t-str = str(t)
                          if link-tags {
                            let tag-target = join-path(tags-dir, join-path(
                              slugify(t-str),
                              "index.html",
                            ))
                            html.a(
                              class: "prop-tag",
                              href: rel-href(doc-path, tag-target),
                              "#" + t-str,
                            )
                          } else {
                            html.span(class: "prop-tag", "#" + t-str)
                          }
                        }
                      })
                    }
                  })
                }
              })

              show: with-html-headings.with(
                shift: 1,
                permalinks: eff-permalinks,
              )
              set text(lang: primary-lang)
              [#metadata(merged-theme)<blog-post-theme>]
              [#metadata(none)<thyme-body-start>]
              body
              [#metadata(none)<thyme-body-end>]

              if eff-backlinks {
                backlinks()
              }
              if eff-post-nav {
                post-nav()
              }
            },
          )
        },
      )
    } else {
      let eff-page-width = if page-width == auto {
        merged-theme.page-width
      } else { page-width }
      let eff-margin = if margin == auto { merged-theme.margin } else { margin }

      set page(
        width: eff-page-width,
        height: auto,
        margin: eff-margin,
        fill: merged-theme.paper-light,
      )
      show: zebraw-init
      show: checklist.with(
        marker-map: (
          " ": move(
            dy: -0.08em,
            box(
              baseline: bottom,
              circle(
                radius: 0.22em,
                stroke: 0.65pt + merged-theme.muted-light,
                fill: none,
              ),
            ),
          ),
          "x": move(
            dy: -0.08em,
            box(
              baseline: bottom,
              circle(
                radius: 0.22em,
                stroke: 0.65pt + merged-theme.text-light,
                fill: merged-theme.text-light,
              ),
            ),
          ),
        ),
      )
      show: with-smart-refs.with(
        ink: merged-theme.text-light,
        muted: merged-theme.muted-light,
      )
      show: style-paged-article.with(
        merged-theme,
        lang: primary-lang,
        numbered-headings: numbered-headings,
      )

      block(width: 100%, below: 1.65em, {
        text(
          size: 2.0em,
          weight: "semibold",
          fill: merged-theme.text-light,
          title,
        )
        if subtitle != none {
          v(0.36em)
          text(size: 1.12em, fill: merged-theme.muted-light, emph(subtitle))
        }

        if has-props {
          v(0.75em)
          let prop-cells = ()
          if eff-author != none {
            prop-cells.push(text(fill: merged-theme.muted-light)[author])
            prop-cells.push(text(fill: merged-theme.text-light, eff-author))
          }
          if monograph != none {
            prop-cells.push(text(fill: merged-theme.muted-light)[monograph])
            prop-cells.push(text(fill: merged-theme.text-light, monograph))
          }
          if created-str != none {
            prop-cells.push(text(fill: merged-theme.muted-light)[created])
            prop-cells.push(text(fill: merged-theme.text-light, created-str))
          }
          if modified-str != none {
            prop-cells.push(text(fill: merged-theme.muted-light)[modified])
            prop-cells.push(text(fill: merged-theme.text-light, modified-str))
          }
          if show-wordcount {
            prop-cells.push(text(fill: merged-theme.muted-light)[words])
            prop-cells.push(text(fill: merged-theme.text-light, context str(
              query-body-words(base-words, doc-el: enc-doc),
            )))
            prop-cells.push(text(fill: merged-theme.muted-light)[reading])
            prop-cells.push(text(fill: merged-theme.text-light, context {
              (
                str(estimate-reading-minutes(
                  query-body-words(base-words, doc-el: enc-doc),
                  wpm: wpm,
                ))
                  + " min"
              )
            }))
          }
          if tags.len() > 0 {
            prop-cells.push(text(fill: merged-theme.muted-light)[tags])
            prop-cells.push(text(
              fill: merged-theme.muted-light,
              tags.map(t => "#" + str(t)).join("  "),
            ))
          }

          block(
            width: 100%,
            stroke: (
              top: 0.55pt + merged-theme.border-light,
              bottom: 0.55pt + merged-theme.border-light,
            ),
            inset: (y: 0.5em),
            {
              set text(font: merged-theme.mono-fonts, size: 0.76em)
              grid(
                columns: (5.8em, 1fr),
                row-gutter: 0.38em,
                column-gutter: 0.9em,
                align: (left + horizon, left + horizon),
                ..prop-cells,
              )
            },
          )
        }
      })

      [#metadata(merged-theme)<blog-post-theme>]
      [#metadata(none)<thyme-body-start>]
      body
      [#metadata(none)<thyme-body-end>]

      if eff-backlinks {
        backlinks()
      }
      if eff-post-nav {
        post-nav()
      }

      sidenote-bottom-guard()
    }
  }
}
