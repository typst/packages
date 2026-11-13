// Shared HTML5 document shell, 404 error page renderer, and conditional code-block
// copy handler for the `blog` preset, built directly atop `core.typ`'s `render-core-shell`.

#import "@preview/cheq:0.4.0": checklist
#import "@preview/zebraw:0.6.3": zebraw-init
#import "../core.typ": render-core-shell
#import "../paths.typ": with-smart-refs
#import "../text.typ": to-plain-text
#import "theme.typ": css-hex, stylesheet-css, stylesheet-href, theme-default

/// Minimal event-delegated copy-button handler for `zebraw` code listings.
#let clipboard-script = "document.addEventListener('click', (ev) => {
  const btn = ev.target.closest('.expressive-code .copy-button');
  if (!btn) return;
  const box = btn.closest('.expressive-code');
  if (!box) return;
  const lines = Array.from(box.querySelectorAll('.ec-line .code')).map(el => el.textContent);
  if (navigator.clipboard && lines.length) {
    navigator.clipboard.writeText(lines.join('\\n')).then(() => {
      btn.setAttribute('data-state', 'copied');
      setTimeout(() => btn.setAttribute('data-state', 'idle'), 1600);
    });
  }
});"

// Determine whether `doc-el` contains any `zebraw` code blocks inside `context`.
#let doc-has-code(doc-el) = {
  if doc-el != none {
    query(selector(<blog-has-code>).within(doc-el.location())).len() > 0
  } else {
    query(<blog-has-code>).len() > 0
  }
}

/// HTML5 document shell for `blog` pages and posts, delegating `<head>` metadata,
/// canonical/alternate links, favicons, stylesheets, and feed discovery to `render-core-shell`.
#let render-html-shell(
  title: [Blog],
  site-title: none,
  description: none,
  author: none,
  site-url: none,
  doc-path: none,
  doc-el: none,
  langs: ("en",),
  alternates: none,
  stylesheet-paths: auto,
  theme-override-css: none,
  favicon-href: none,
  favicon-type: none,
  source-href: none,
  source-label: ".typ",
  back-content: none,
  render-topbar: false,
  theme-config: theme-default,
  copy-button: auto,
  include-feeds: false,
  rss-path: "rss.xml",
  atom-path: "atom.xml",
  created: none,
  modified: none,
  monograph: none,
  tags: (),
  is-article: false,
  open-graph: false,
  scholar-meta: false,
  extra-head: none,
  body,
) = {
  let in-bundle = doc-path != none
  let eff-sheets = if not in-bundle {
    ()
  } else if stylesheet-paths == auto {
    (stylesheet-href(theme: theme-config),)
  } else {
    stylesheet-paths
  }
  let inline-css = (
    ..if not in-bundle { (stylesheet-css(theme: theme-config),) } else { () },
    ..if theme-override-css != none { (theme-override-css,) } else { () },
  )
  let emit-copy-js = if copy-button == auto {
    doc-has-code(doc-el)
  } else {
    copy-button == true
  }

  counter("zebraw-html-styles").update(1)
  counter("zebraw-html-clipboard").update(1)

  render-core-shell(
    title: title,
    site-title: site-title,
    description: description,
    author: author,
    site-url: site-url,
    doc-path: doc-path,
    langs: langs,
    alternates: alternates,
    stylesheet-paths: eff-sheets,
    inline-styles: inline-css,
    include-core-topbar-css: false,
    favicon-href: favicon-href,
    favicon-type: favicon-type,
    source-href: source-href,
    source-label: source-label,
    back-content: back-content,
    render-topbar: render-topbar,
    theme-config: theme-config,
    include-feeds: include-feeds,
    rss-path: rss-path,
    atom-path: atom-path,
    created: created,
    modified: modified,
    monograph: monograph,
    tags: tags,
    is-article: is-article,
    open-graph: open-graph,
    scholar-meta: scholar-meta,
    extra-head: {
      if emit-copy-js {
        html.script(clipboard-script)
      }
      if extra-head != none {
        extra-head
      }
    },
    body-wrapper: inner => {
      show: zebraw-init
      show: checklist
      show: with-smart-refs.with(
        ink: theme-config.text-light,
        muted: theme-config.muted-light,
      )
      inner
    },
    wrap-main: true,
    body,
  )
}

/// Render a root-relative `404.html` error page styled with the active monochrome theme.
#let render-not-found-page(
  site-title: [Blog],
  home-text: "/..",
  lang: "en",
  stylesheet-paths: auto,
  theme-config: theme-default,
) = {
  let sheets = if stylesheet-paths == auto {
    (stylesheet-href(theme: theme-config),)
  } else {
    stylesheet-paths
  }
  html.html(lang: lang, {
    html.head({
      html.meta(charset: "utf-8")
      html.meta(
        name: "viewport",
        content: "width=device-width, initial-scale=1",
      )
      html.meta(name: "robots", content: "noindex")
      html.title("404 - " + to-plain-text(site-title, lang: lang))
      html.meta(
        name: "theme-color",
        content: css-hex(theme-config.paper-light),
        media: "(prefers-color-scheme: light)",
      )
      html.meta(
        name: "theme-color",
        content: css-hex(theme-config.paper-dark),
        media: "(prefers-color-scheme: dark)",
      )
      for css-p in sheets {
        let p-str = str(css-p)
        let href = if (
          p-str.starts-with("http://") or p-str.starts-with("https://") or p-str.starts-with("/")
        ) {
          p-str
        } else {
          "/" + p-str.trim("/")
        }
        html.link(rel: "stylesheet", href: href)
      }
    })
    html.body({
      html.main({
        html.elem(
          "nav",
          attrs: (class: "back-home", "aria-label": "Site navigation"),
          html.a(href: "/", home-text),
        )
        html.h1("404")
        html.p(class: "lede", "No such page.")
      })
    })
  })
}
