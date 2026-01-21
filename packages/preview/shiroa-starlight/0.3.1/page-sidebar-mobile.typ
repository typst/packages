#import "mod.typ": *

#import "icons.typ": builtin-icon

#let links = (
  (id: "open", label: "Open Sidebar Menu", icon: "menu"),
  (id: "close", label: "Close Sidebar Menu", icon: "cross-mark"),
)

// ---

#div(
  id: "sidebar-mobile-toggle",
  aria-controls: "starlight__sidebar",
  aria-expanded: "false",
)[
  #for (id: id, label: theme-label, icon: icon) in links {
    button.with(
      id: "sidebar-" + id,
      class: "sl-flex sidebar-toggle-button",
      onclick: "this.parentElement.setAttribute('aria-expanded', "
        + if id == "open" { "'true'" } else { "'false'" }
        + "); document.body.toggleAttribute('data-mobile-menu-expanded', "
        + if id == "open" { "true" } else { "false" }
        + ");",
    )({
      span(class: "sr-only", theme-label)
      if type(icon) == str { builtin-icon(icon) } else { icon }
    })
  }
]

#add-styles(
  ```css
  #sidebar-mobile-toggle[aria-expanded="true"] #sidebar-open {
    display: none;
  }
  #sidebar-mobile-toggle[aria-expanded="false"] #sidebar-close {
    display: none;
  }

  .sidebar-toggle-button {
    background: none;
    border: none;
    padding: 0.5em;
    margin: -0.2em;
  }
  .sidebar-toggle-button:hover {
    opacity: 0.66;
  }
  ```,
)
