
#import "mod.typ": *
#import "icons.typ": builtin-icon
#import "@preview/shiroa:0.3.1": cross-link-path-label, get-book-meta, x-url-base

#let render-sidebar(summary-items, visit) = {
  let part = none
  let items = ()
  for summary-item in summary-items {
    if summary-item.kind == "chapter" {
      let v = none

      let link = summary-item.link
      if link != none {
        items.push(
          visit.at("inc")("/" + link, {
            if "raw-title" in summary-item {
              summary-item.raw-title
            } else {
              summary-item.title.content
            }
          }),
        )
      }

      if "sub" in summary-item {
        items.push(visit.at("sub")(render-sidebar(summary-item.sub, visit)))
      }
    } else if summary-item.kind == "part" {
      // todo: more than plain text

      if part != none or items.len() > 0 {
        visit.at("part")(part, items)
      }

      part = summary-item.at("title").at("content")
      items = ()
    } else {
      // repr(x)
    }
  }


  if part != none or items.len() > 0 {
    visit.at("part")(part, items)
  }
}

#let cross-link2(current, dest, it) = {
  // todo: url-base
  let aria-current = if dest == current {
    (aria-current: "page")
  } else {
    (:)
  }

  assert(
    type(it) == str or type(it) == content,
    message: "invalid type of sidebar item, want str or content, got " + repr(it),
  )


  let dest = cross-link-path-label(dest)
  if dest.starts-with("/") {
    dest = dest.slice(1)
  }
  dest = x-url-base + dest

  a(..aria-current, href: dest, it)
}

#let onclick = ```js
this.parentElement.classList.toggle("open");
```

// ---

#let current = sys.inputs.at("x-current", default: none)
#context {
  let book-meta = query(<shiroa-book-meta>).at(0, default: none)
  if book-meta != none {
    let sm = book-meta.value.summary

    let styles = (
      inc: (link, it) => cross-link2(current, link, it),
      sub: it => li(ol(it)),
      part: (part, items) => if part != none {
        li(class: "sidebar-part open", {
          div.with(class: "sidebar-part-header", onclick: "javascript:" + onclick.text)({
            div(class: "sidebar-part-title", span(part))
            builtin-icon("right-caret", class: "sidebar-part-caret")
          })
          ol(class: "sidebar-part-chapters", items.sum())
        })
      } else {
        items.sum()
      },
    )

    ul(render-sidebar(sm, styles))
  }
}

#add-styles(
  ```css
  .sidebar-content {
    --sl-sidebar-item-padding-inline: 0.5rem;
  }
  .sidebar-content ul > li {
    padding: 0;
  }
  .sidebar-content .sidebar-part li {
    margin-inline-start: var(--sl-sidebar-item-padding-inline);
    border-inline-start: 1px solid var(--sl-color-hairline-light);
    padding-inline-start: var(--sl-sidebar-item-padding-inline);
  }

  .sidebar-part-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: .2em var(--sl-sidebar-item-padding-inline);
    background-color: var(--sl-color-gray-7);
    line-height: 1.4;
    cursor: pointer;
  }

  .sidebar-part-caret {
    transition: transform 0.2s ease-in-out;
    flex-shrink: 0;
    font-size: 1.25rem;
  }
  .sidebar-part.open > .sidebar-part-header .sidebar-part-caret {
    transform: rotateZ(90deg);
  }
  .sidebar-part.open > .sidebar-part-chapters {
    display: block;
  }
  .sidebar-part-chapters {
    display: none;
  }

  .sidebar-content ul, .sidebar-content ol {
    list-style: none;
    padding: 0;
  }
  .sidebar-content li {
    overflow-wrap: anywhere;
  }

  li.sidebar-part {
    margin-top: 0.5rem;
    padding: .2em var(--sl-sidebar-item-padding-inline);
  }

  .sidebar-part-title {
    font-weight: 600;
    color: var(--sl-color-white);
  }

  .sidebar-content a {
    font-size: var(--sl-text-sm);
    display:block;
    border-radius: .25rem;
    text-decoration: none;
    color: var(--sl-color-gray-2);
    padding: .3em var(--sl-sidebar-item-padding-inline);
    line-height: 1.4
  }

  .sidebar-content a:hover,
  .sidebar-content a:focus {
    color: var(--sl-color-white);
  }

  .sidebar-content a[aria-current='page'],
  .sidebar-content a[aria-current='page']:hover,
  .sidebar-content a[aria-current='page']:focus {
    font-weight: 600;
    color: var(--sl-color-text-invert);
    background-color: var(--sl-color-text-accent);
  }
  ```,
)
