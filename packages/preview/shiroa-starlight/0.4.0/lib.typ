
#import "mod.typ": set-slot
#import "page-header.typ": right-group-item
#import "icons.typ": builtin-icon

#let social-links(
  github: none,
  discord: none,
) = {
  if github != none { ((href: github, label: "GitHub", icon: "github"),) }
  if discord != none { ((href: discord, label: "Discord", icon: "discord"),) }
}

#let title-text(it) = {
  import "@preview/shiroa:0.4.0": plain-text
  if it == none {
    ""
  } else {
    plain-text(it).trim()
  }
}

#let default-meta-title(title, site-title) = {
  let title = title-text(title)
  let site-title = title-text(site-title)
  if title != "" and site-title != "" {
    title-text([#title -- #site-title])
  } else if title != "" {
    title
  } else if site-title != "" {
    site-title
  } else {
    ""
  }
}

#let book-site-title(it) = {
  let title = ""
  if it != none {
    if "raw-title" in it {
      title = if it.raw-title == none { "" } else { it.raw-title }
    } else if "title" in it {
      title = if type(it.title) == str {
        it.title
      } else {
        it.title.content
      }
    }
  }
  title
}

#let starlight(
  book,
  body,
  title: "",
  description: none,
  plain-body: auto,
  enable-search: true,
  extra-assets: (),
  meta-title: default-meta-title,
  social-links: social-links,
  social-icons: {
    import "social-icons.typ": social-icons
    social-icons
  },
  right-group: none,
) = {
  import "@preview/shiroa:0.4.0": get-book-meta, is-html-target, paged-load-trampoline, plain-text, prepare-description, x-current, x-target
  import "html.typ": inline-assets, meta, span
  import "mod.typ": replace-raw

  if not is-html-target() {
    panic(
      "Starlight theme is only available with `--mode=static-html`. Either change theme to mdbook or turn mode into `static-html`.",
    )
    return body
  }

  let trampoline = paged-load-trampoline()
  let plain-body = if plain-body == auto { body } else { plain-body }
  let description = prepare-description(description, plain-body: plain-body)

  let site-title() = get-book-meta(mapper: book-site-title)

  let default-right-group() = get-book-meta(mapper: it => if it != none {
    let github-link = it.at("repository", default: none)
    let discord-link = it.at("discord", default: none)

    right-group-item(class: "social-icons", social-icons(social-links(github: github-link, discord: discord-link)))
    right-group-item(include "theme-select.typ")
    right-group-item(class: "md:sl-hidden", include "page-sidebar-mobile.typ")
  })

  show: set-slot("sa:head-meta", {
    // <meta title>
    get-book-meta(mapper: it => {
      let resolved-site-title = book-site-title(it)
      html.elem("title", plain-text(meta-title(title, resolved-site-title)).trim())
    })
    // <meta description>
    if description != none { meta(name: "description", content: description) }
  })

  show: set-slot("main-title", html.elem("h1", title))
  // todo: determine a good name of html wrapper
  show: set-slot("main-content", if x-target.starts-with("html-wrapper") { trampoline } else { body })

  show: set-slot("header", include "page-header.typ")
  show: set-slot("site-title", context span(class: "site-title", site-title()))
  show: set-slot("sl:book-meta", book + inline-assets(extra-assets.join()))
  show: set-slot("sl:search", if enable-search { include "site-search.typ" })
  show: set-slot("sl:search-results", if enable-search { include "site-search-results.typ" })
  show: set-slot("sl:right-group", if right-group != none { right-group } else { default-right-group() })

  // div(class: "sl-flex social-icons", virt-slot("social-icons")),
  // // virt-slot("theme-select"),
  // // virt-slot("language-select"),
  include "index.typ"
}
