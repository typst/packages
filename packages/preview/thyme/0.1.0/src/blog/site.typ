// Scholarly blog site bundler (`blog.site`, `posts`, `tag-cloud`) built directly
// atop `thyme` core (`src/core.typ`).
//
// Emits `index.html`, `404.html`, `posts/<slug>/index.html`, mounted `webpage` subpages,
// static `/tags/` & `/tags/<tag>/` archive pages, co-located post assets, Tadi Web `.typ`
// plaintext sources, content-hashed `css/style.css`, `sitemap.xml`,
// `rss.xml`, and `atom.xml`.

#import "../core.typ": (
  backlinks as render-backlinks, extract-first-h1, query-pages, render-top-bar, resolve-core-mount, site as core-site,
)
#import "../i18n.typ": resolve-page-langs
#import "../paths.typ": (
  date-sort-key, emit-doc-marker, format-date, join-path, post-html-path, rel-href, resolve-bundle-label,
  route-html-path, slugify, unwrap-typ-path, with-html-headings,
)
#import "../text.typ": count-words
#import "html.typ": render-html-shell, render-not-found-page
#import "post.typ": post
#import "theme.typ": active-theme, resolve-theme, stylesheet-asset-path, stylesheet-css, stylesheet-href

// Shared entry card renderer for both inline `#post(...)` mounts and `#posts()`.
#let _render-entry-card(
  title: none,
  dest: none,
  created-str: none,
  summary: none,
  subtitle: none,
  show-summary: true,
  wrapper-tag: "div",
  theme-config: none,
) = {
  let desc = if summary != none { summary } else { subtitle }
  if target() == "html" {
    html.elem(wrapper-tag, attrs: (class: "entry"), {
      html.div(class: "entry-head", {
        html.h3(if dest != none { link(dest, title) } else { title })
        if created-str != none {
          html.elem(
            "time",
            attrs: (datetime: created-str, class: "when"),
            created-str,
          )
        }
      })
      if show-summary and desc != none {
        html.p(class: "entry-summary", desc)
      }
    })
  } else {
    block(below: 0.65em, {
      strong(title)
      if created-str != none {
        h(1fr)
        text(font: theme-config.mono-fonts, size: 0.8em, created-str)
      }
    })
  }
}

/// Render a newest-first `<ul class="entries">` list of all public posts in the bundle.
/// -> content
#let posts(
  /// Include each post's `summary` (or `subtitle` fallback) beneath its title row.
  /// -> bool
  show-summary: true,
  /// Optional tag filter.
  /// -> str | none
  tag: none,
  /// Optional primary language filter.
  /// -> str | none
  lang: none,
) = context {
  let t = active-theme()
  let entries = query-pages(collection: "posts", tag: tag, lang: lang)
  if target() == "html" {
    html.ul(class: "entries", {
      for p in entries {
        _render-entry-card(
          title: p.title,
          dest: p.doc-loc,
          created-str: p.created-str,
          summary: p.summary,
          subtitle: p.subtitle,
          show-summary: show-summary,
          wrapper-tag: "li",
          theme-config: t,
        )
      }
    })
  } else {
    for p in entries {
      _render-entry-card(
        title: p.title,
        created-str: p.created-str,
        show-summary: show-summary,
        theme-config: t,
      )
    }
  }
}

/// Render a monochrome `#tag` index list (`<ul class="tag-cloud">`) with post counts,
/// linking to `/tags/<slug>/index.html` inside bundles.
/// -> content
#let tag-cloud(
  /// Output directory prefix for tag archive pages.
  /// -> str
  tags-dir: "tags",
) = context {
  let t = active-theme()
  let posts = query-pages(collection: "posts")
  let counts = (:)
  for p in posts {
    for tg in p.at("tags", default: ()) {
      let k = str(tg)
      counts.insert(k, counts.at(k, default: 0) + 1)
    }
  }
  let pairs = counts.pairs().sorted(key: pair => pair.at(0))
  if pairs.len() == 0 {
    return []
  }
  if target() == "html" {
    let enc-docs = query(document)
    html.ul(class: "tag-cloud", {
      for (tg, cnt) in pairs {
        let tg-slug = slugify(tg)
        let lbl-el = resolve-bundle-label(label("thyme-tag-" + tg-slug))
        let target-path = join-path(tags-dir, join-path(tg-slug, "index.html"))
        let fallback-docs = if lbl-el == none {
          enc-docs.filter(d => d.path == target-path)
        } else { () }
        html.li({
          if lbl-el != none {
            link(lbl-el.location(), "#" + tg)
          } else if fallback-docs.len() > 0 {
            link(fallback-docs.first().location(), "#" + tg)
          } else {
            html.span("#" + tg)
          }
          html.span(class: "tag-count", "(" + str(cnt) + ")")
        })
      }
    })
  } else {
    block({
      set text(font: t.mono-fonts, size: 0.82em, fill: t.muted-light)
      pairs.map(((tg, cnt)) => "#" + tg + " (" + str(cnt) + ")").join("  ·  ")
    })
  }
}

// Render an inline `#post(...)` mount as a homepage entry card right where `#post(...)` sits.
#let _render-mounted-entry(
  rec,
  site-typ-path: none,
  default-route-fn: none,
  show-summary: true,
) = {
  let m = resolve-core-mount(
    rec,
    site-typ-path: site-typ-path,
    default-route-fn: default-route-fn,
  )
  let pm = m.meta
  let is-post = pm.at("collection", default: "posts") == "posts"
  if (
    not is-post or pm.at("draft", default: false) or pm.at("unlisted", default: false)
  ) {
    return []
  }
  context {
    let t = active-theme()
    let target-el = if target() == "html" {
      resolve-bundle-label(m.label)
    } else { none }
    _render-entry-card(
      title: m.title,
      dest: if target-el != none { target-el.location() } else { none },
      created-str: pm.at("created-str", default: none),
      summary: pm.at("summary", default: none),
      subtitle: pm.at("subtitle", default: none),
      show-summary: show-summary,
      wrapper-tag: "div",
      theme-config: t,
    )
  }
}

/// Scholarly monochrome blog bundler (`#show: site.with(...)` after `#import blog: *`,
/// or `#show: blog.site.with(...)`).
///
/// Renders `site.typ`'s body as `index.html` (`<site>`), emits every mounted
/// `#post(path("posts/foo.typ")) <foo>` as `<posts-dir>/foo/index.html` (`<foo>`) and any
/// `#mount(path("about.typ")) <about>` subpages, generates static `/tags/` archive pages,
/// co-emits sibling Tadi Web `.typ` plaintext sources, and builds content-hashed `css/style.css`
/// (`<stylesheet>`), `404.html`, `sitemap.xml` (`<sitemap>`), `rss.xml` (`<rss>`),
/// and `atom.xml` (`<atom>`).
/// -> content
#let site(
  /// Site title (`auto` infers from the first `= ...` heading in `body`, or pass any `str` / rich `content`).
  /// -> auto | content | str
  title: auto,
  /// Short site description for `<meta name="description">` and feed subtitles.
  /// -> content | str | none
  description: none,
  /// Canonical origin URL (without trailing slash) for canonical links, `sitemap.xml`, and feeds.
  /// -> str
  url: "https://example.com",
  /// Default author inherited by posts that omit `author` and emitted in Atom `<author>`.
  /// -> content | str | none
  author: none,
  /// Default site language (`"en"` or `("en", "de")`).
  /// -> str | array
  lang: "en",
  /// Optional `hreflang` alternate URLs for the site root (`(de: "/de/")`).
  /// -> dictionary | array | none
  alternates: none,
  /// Output directory prefix for emitted post pages (`posts/<slug>/index.html`).
  /// -> str
  posts-dir: "posts",
  /// Generate static `/tags/index.html` and `/tags/<tag>/index.html` archive pages and link `#tag` badges.
  /// -> bool
  tag-pages: true,
  /// Output directory prefix for static tag archive pages (`tags/<tag>/index.html`).
  /// -> str
  tags-dir: "tags",
  /// Capability `path("site.typ")` (or `str`) of the root entrypoint so Tadi Web source view emits `/site.typ`.
  /// -> path | str | none
  src: none,
  /// Co-emit sibling `.typ` plaintext source files (`/site.typ`, `/posts/<slug>.typ`) and render a top-right `.typ` link (`true` uses `".typ"`, `false` disables, or pass custom label `str`).
  /// -> bool | str
  expose-source: true,
  /// Additional user stylesheets (`path("extra.css")`) appended after `css/style.css`.
  /// -> array
  stylesheets: (),
  /// Optional site favicon (`path("favicon.svg")` or `(path: "favicon.svg", data: ...)`).
  /// -> path | dictionary | none
  favicon: none,
  /// Additional standalone HTML pages `(slug: "about", title: [About], body: [...])`.
  /// -> array
  pages: (),
  /// Site-wide static assets `(path: "pgp.txt", data: ..., label: none)`.
  /// -> array
  assets: (),
  /// Emit `404.html` styled with the active monochrome palette and typography.
  /// -> bool | content
  not-found-page: true,
  /// Output bundle path for the XML sitemap (`"sitemap.xml"`), or `none` to disable.
  /// -> str | none
  sitemap-path: "sitemap.xml",
  /// `robots.txt`. `path(...)` copies your file into the bundle root; `none` emits no file.
  /// -> path | none
  robots: none,
  /// `llms.txt`. `path(...)` copies your file into the bundle root; `none` emits no file.
  /// -> path | none
  llms: none,
  /// Output bundle path for the RSS 2.0 feed, or `none` to disable RSS generation.
  /// -> str | none
  rss-path: "rss.xml",
  /// Output bundle path for the Atom 1.0 feed, or `none` to disable Atom generation.
  /// -> str | none
  atom-path: "atom.xml",
  /// Feed payload mode (`"summary"` for compact descriptions or `"full"` for full semantic HTML).
  /// -> str
  feed-content: "summary",
  /// Optional RFC 4151 feed `<id>` minting date (`auto` derives from earliest post).
  /// -> auto | datetime
  feed-epoch: auto,
  /// Append `§` hover permalinks on section headings (`h2`–`h6`) across posts and pages.
  /// -> bool
  heading-permalinks: false,
  /// Render compile-time backlinks footers across posts and pages by default.
  /// -> bool
  backlinks: false,
  /// Render chronological older / newer navigation links at the bottom of posts by default.
  /// -> bool
  post-nav: false,
  /// Inject copy-button JavaScript (`auto` injects only on pages containing `#zebraw` code blocks).
  /// -> auto | bool
  copy-button: auto,
  /// Emit OpenGraph `<meta property="og:*">` tags across pages and posts by default.
  /// -> bool
  open-graph: false,
  /// Emit Google Scholar Highwire `<meta name="citation_*">` tags on posts by default.
  /// -> bool
  scholar-meta: false,
  /// Additional `<head>` elements injected on `index.html`.
  /// -> content | none
  head: none,
  /// Theme overrides merged onto `theme-default` across both HTML CSS and paged previews.
  /// -> dictionary
  theme: (:),
  /// Homepage markup (`= Heading`, `#links(direction: "row", ...)`, and mounted `#post(path("...")) <slug>` entries).
  /// -> content
  body,
) = {
  let theme-config = resolve-theme(theme)
  let built-css = stylesheet-css(theme: theme-config)
  let built-css-href = stylesheet-href(css: built-css, theme: theme-config)
  let site-typ-path = if type(src) == path { unwrap-typ-path(src) } else {
    none
  }
  let source-label = if expose-source == false or expose-source == none {
    none
  } else if expose-source == true {
    ".typ"
  } else {
    str(expose-source)
  }

  let default-route = (slug, rel-typ, meta) => {
    if meta.at("collection", default: "posts") == "posts" {
      post-html-path(slug, posts-dir: posts-dir)
    } else if rel-typ != none {
      route-html-path(rel-typ)
    } else {
      join-path(slug, "index.html")
    }
  }

  let h1-in-body = extract-first-h1(body)
  let resolved-blog-title = if title != auto {
    title
  } else if h1-in-body != none {
    h1-in-body
  } else {
    [Blog]
  }

  let blog-config = (
    title: resolved-blog-title,
    description: description,
    url: url,
    author: author,
    lang: lang,
    posts-dir: posts-dir,
    tag-pages: tag-pages,
    tags-dir: tags-dir,
    source-label: source-label,
    theme: theme-config,
    sitemap-path: sitemap-path,
    rss-path: rss-path,
    atom-path: atom-path,
    heading-permalinks: heading-permalinks,
    backlinks: backlinks,
    post-nav: post-nav,
    copy-button: copy-button,
    open-graph: open-graph,
    scholar-meta: scholar-meta,
  )

  let merged-stylesheets = (
    (
      path: stylesheet-asset-path,
      href: built-css-href,
      data: built-css,
      label: <stylesheet>,
    ),
    ..stylesheets,
  )

  core-site(
    title: title,
    description: description,
    url: url,
    author: author,
    lang: lang,
    alternates: alternates,
    stylesheets: merged-stylesheets,
    favicon: favicon,
    assets: assets,
    src: src,
    expose-source: expose-source,
    not-found-page: not-found-page,
    sitemap-path: sitemap-path,
    robots: robots,
    llms: llms,
    rss-path: rss-path,
    atom-path: atom-path,
    feed-content: feed-content,
    feed-epoch: feed-epoch,
    heading-permalinks: heading-permalinks,
    backlinks: backlinks,
    open-graph: open-graph,
    scholar-meta: scholar-meta,
    head: head,
    _default-title: [Blog],
    _feed-collection: "posts",
    _preset-config: blog-config,
    _default-route-fn: default-route,
    _mount-card-fn: rec => _render-mounted-entry(
      rec,
      site-typ-path: site-typ-path,
      default-route-fn: default-route,
    ),
    _shell-fn: (
      title: [Blog],
      site-title: none,
      description: none,
      author: none,
      site-url: none,
      doc-path: none,
      langs: ("en",),
      alternates: none,
      stylesheet-paths: (),
      favicon-href: none,
      favicon-type: none,
      source-href: none,
      source-label: source-label,
      include-feeds: false,
      rss-path: none,
      atom-path: none,
      open-graph: false,
      extra-head: none,
      inner-body,
    ) => {
      let site-docs = query(<site>)
      let home-doc = if site-docs.len() > 0 { site-docs.first() } else { none }
      render-html-shell(
        title: title,
        site-title: site-title,
        description: description,
        author: author,
        site-url: site-url,
        doc-path: doc-path,
        doc-el: home-doc,
        langs: langs,
        alternates: alternates,
        stylesheet-paths: stylesheet-paths,
        favicon-href: favicon-href,
        favicon-type: favicon-type,
        source-href: source-href,
        source-label: source-label,
        render-topbar: true,
        theme-config: theme-config,
        copy-button: copy-button,
        include-feeds: include-feeds,
        rss-path: rss-path,
        atom-path: atom-path,
        open-graph: open-graph,
        extra-head: extra-head,
        inner-body,
      )
    },
    _not-found-fn: (
      res-title,
      primary-lang,
      sheet-hrefs,
    ) => render-not-found-page(
      site-title: res-title,
      lang: primary-lang,
      stylesheet-paths: sheet-hrefs,
      theme-config: theme-config,
    ),
    _extra-docs-fn: (
      all-mounts: (),
      resolved-title: [Blog],
      site-url: "https://example.com",
      author: none,
      default-lang: "en",
      sheet-hrefs: (),
      favicon-href: none,
      favicon-type: none,
    ) => {
      // 1. Legacy `pages: (...)` array (with full `webpage` parity: dates, word count, heading anchors, backlinks)
      for pg in pages {
        let slug = pg.slug
        let pg-lbl = label(slug)
        let pg-title = pg.at("title", default: resolved-title)
        let pg-path = pg.at("path", default: join-path(slug, "index.html"))
        let pg-created = pg.at("created", default: none)
        let pg-modified = pg.at("modified", default: none)
        let pg-langs = resolve-page-langs(
          auto,
          default-lang: lang,
          scan-nodes: (pg-title, pg.body),
        )
        let pg-meta = (
          title: pg-title,
          subtitle: none,
          description: pg.at("description", default: none),
          summary: pg.at("description", default: none),
          created: pg-created,
          created-str: format-date(pg-created),
          modified: pg-modified,
          modified-str: format-date(pg-modified),
          sort-key: date-sort-key(pg-created),
          author: author,
          monograph: none,
          tags: pg.at("tags", default: ()),
          alternates: pg.at("alternates", default: none),
          collection: "pages",
          langs: pg-langs,
          primary-lang: pg-langs.first(),
          assets: (),
          slug: slug,
          base-words: count-words(pg.body),
          wpm: 200,
          raw-body: pg.body,
          draft: pg.at("draft", default: false),
          unlisted: pg.at("unlisted", default: false),
          is-wrapped-page: true,
        )
        [#document(
            pg-path,
            title: pg-title,
            {
              emit-doc-marker(pg-path, pg-lbl)
              [#metadata(pg-meta)<thyme-page-meta>]
              context {
                let pg-el = resolve-bundle-label(pg-lbl)
                let home-docs = query(<site>)
                let back-node = if home-docs.len() > 0 {
                  link(home-docs.first().location(), "/..")
                } else { html.a(href: "/", "/..") }
                render-html-shell(
                  title: pg-title,
                  site-title: resolved-title,
                  description: pg.at("description", default: none),
                  author: author,
                  site-url: site-url,
                  doc-path: pg-path,
                  doc-el: pg-el,
                  langs: pg-langs,
                  alternates: pg.at("alternates", default: none),
                  stylesheet-paths: sheet-hrefs,
                  favicon-href: favicon-href,
                  favicon-type: favicon-type,
                  back-content: back-node,
                  render-topbar: true,
                  theme-config: theme-config,
                  copy-button: copy-button,
                  include-feeds: false,
                  created: pg-created,
                  modified: pg-modified,
                  open-graph: open-graph,
                  {
                    show: with-html-headings.with(
                      shift: 0,
                      permalinks: heading-permalinks,
                    )
                    set text(lang: pg-langs.first())
                    [#metadata(none)<thyme-body-start>]
                    pg.body
                    [#metadata(none)<thyme-body-end>]
                    if backlinks {
                      render-backlinks()
                    }
                  },
                )
              }
            },
          )#pg-lbl]
      }

      // 2. Static `/tags/index.html` and `/tags/<slug>/index.html` archive pages
      if tag-pages {
        let unique-tags = ()
        for m in all-mounts {
          let pm = m.meta
          if (
            pm.at("collection", default: "posts") == "posts"
              and not pm.at("draft", default: false)
              and not pm.at("unlisted", default: false)
          ) {
            for t in pm.at("tags", default: ()) {
              let t-str = str(t)
              if t-str not in unique-tags {
                unique-tags.push(t-str)
              }
            }
          }
        }
        let sorted-tags = unique-tags.sorted()
        if sorted-tags.len() > 0 {
          let idx-path = join-path(tags-dir, "index.html")
          [#document(
            idx-path,
            title: [Tags],
            {
              emit-doc-marker(idx-path, <tags>)
              context {
                let home-docs = query(<site>)
                let back-node = if home-docs.len() > 0 {
                  link(home-docs.first().location(), "/..")
                } else { html.a(href: "/", "/..") }
                render-html-shell(
                  title: [Tags],
                  site-title: resolved-title,
                  author: author,
                  site-url: site-url,
                  doc-path: idx-path,
                  langs: (default-lang,),
                  stylesheet-paths: sheet-hrefs,
                  favicon-href: favicon-href,
                  favicon-type: favicon-type,
                  back-content: back-node,
                  render-topbar: true,
                  theme-config: theme-config,
                  copy-button: false,
                  include-feeds: false,
                  {
                    html.h1("Tags")
                    tag-cloud(tags-dir: tags-dir)
                  },
                )
              }
            },
          )<tags>]

          for tg in sorted-tags {
            let tg-slug = slugify(tg)
            let tg-lbl = label("thyme-tag-" + tg-slug)
            let tg-path = join-path(tags-dir, join-path(tg-slug, "index.html"))
            let tg-title = "#" + tg
            [#document(
                tg-path,
                title: tg-title,
                {
                  emit-doc-marker(tg-path, tg-lbl)
                  context {
                    let tag-idx-docs = query(<tags>)
                    let back-node = if tag-idx-docs.len() > 0 {
                      link(tag-idx-docs.first().location(), "/tags")
                    } else {
                      html.a(href: "/", "/..")
                    }
                    render-html-shell(
                      title: raw(tg-title),
                      site-title: resolved-title,
                      author: author,
                      site-url: site-url,
                      doc-path: tg-path,
                      langs: (default-lang,),
                      stylesheet-paths: sheet-hrefs,
                      favicon-href: favicon-href,
                      favicon-type: favicon-type,
                      back-content: back-node,
                      render-topbar: true,
                      theme-config: theme-config,
                      copy-button: false,
                      include-feeds: false,
                      {
                        html.h1(html.code(tg-title))
                        posts(tag: tg)
                      },
                    )
                  }
                },
              )#tg-lbl]
          }
        }
      }
    },
    _paged-fallback-fn: (
      all-mounts,
      pre-els,
      primary-lang,
      emit-auto-h1,
      res-title,
      clean-body,
    ) => {
      if all-mounts.len() > 0 {
        all-mounts.first().body
        for m in all-mounts.slice(1) {
          if pre-els.all(el => el.at("label", default: none) != m.label) {
            [#metadata((thyme-paged-ref: true, meta: m.orig.meta))#m.label]
          }
        }
      } else {
        set text(lang: primary-lang)
        if emit-auto-h1 {
          heading(level: 1, res-title)
        }
        clean-body
      }
    },
    body,
  )
}
