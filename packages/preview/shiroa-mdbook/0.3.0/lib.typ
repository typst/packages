
#import "mod.typ": set-slot

#let social-links(
  github: none,
  discord: none,
) = {
  if github != none { ((href: github, label: "GitHub", icon: "github"),) }
  if discord != none { ((href: discord, label: "Discord", icon: "discord"),) }
}

#let mdbook(
  book,
  body,
  title: [Shiroa Site],
  description: none,
  enable-search: true,
  extra-assets: (),
  meta-title: (title, site-title) => if title != "" [#title -- #site-title] else { site-title },
  social-links: social-links,
  right-group: none,
) = {
  import "@preview/shiroa:0.3.0": get-book-meta, is-html-target, paged-load-trampoline, x-current, x-target, x-url-base
  import "mod.typ": inline-assets, replace-raw
  import "html.typ": a, div, meta
  import "icons.typ": builtin-icon

  if not is-html-target() {
    return body
  }
  let print-enable = false
  let git-repository-icon = "github"
  let git-repository-edit-icon = "edit"

  let trampoline = paged-load-trampoline()

  let site-title() = get-book-meta(mapper: it => if it != none {
    if "raw-title" in it {
      it.raw-title
    } else if "title" in it {
      if type(it.title) == str {
        it.title
      } else {
        it.title.content
      }
    }
  })

  // import "html-bindings-h.typ": span

  show: set-slot("sa:head-meta", {
    // <meta title>
    context html.elem("title", meta-title(title, site-title()))
    // <meta description>
    if description != none { meta(name: "description", content: description) }
  })

  show: set-slot("main-title", html.elem("h1", attrs: (class: "menu-title"), title))
  // todo: determine a good name of html wrapper
  show: set-slot("main-content", if x-target.starts-with("html-wrapper") { trampoline } else { body })

  // show: set-slot("header", include "page-header.typ")
  show: set-slot("sl:book-meta", book + inline-assets(extra-assets.join()))
  // show: set-slot("sl:search", if enable-search { include "site-search.typ" })

  let right-buttons() = get-book-meta(mapper: it => if it != none {
    let repository = it.at("repository", default: none)
    let repository-edit = it.at("repository_edit", default: if repository != none {
      let repository = repository
      if repository.ends-with("/") {
        repository = repository.slice(0, -1)
      }
      repository + "/edit/main/github-pages/docs/{path}"
    })
    let discord = it.at("discord", default: none)

    if print-enable {
      a.with(
        href: "{{ path_to_root }}theme/print.html",
        title: "Print this book",
        aria-label: "Print this book",
      )({
        builtin-icon("print", class: "fa", id: "print-button")
      })
    }
    if repository != none {
      a.with(href: repository, title: "Git repository", aria-label: "Git repository")({
        builtin-icon(git-repository-icon, class: "fa", id: "git-repository-button")
      })
    }

    if repository-edit != none {
      let current = if x-current != none { x-current } else { "" }
      if current.starts-with("/") {
        current = current.slice(1)
      }
      let repository-edit = repository-edit.replace("{path}", current)
      a.with(href: repository-edit, title: "Suggest an edit", aria-label: "Suggest an edit")({
        builtin-icon(git-repository-edit-icon, class: "fa", id: "git-edit-button")
      })
    }
  })

  show: set-slot("sa:right-buttons", div(class: "right-buttons", right-buttons()))

  // div(class: "sl-flex social-icons", virt-slot("social-icons")),
  // // virt-slot("theme-select"),
  // // virt-slot("language-select"),
  include "index.typ"
}
