
#import "mod.typ": *
#import "icons.typ": builtin-icon

// ---

#button(
  id: "search-toggle",
  class: "sl-flex theme-button",
  aria-expanded: "false",
  aria-keyshortcuts: "S",
  aria-controls: "searchbar",
  {
    span(class: "sr-only", "Toggle Searchbar")
    builtin-icon("search")
  },
)
