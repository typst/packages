
#import "mod.typ": *

// ---

#main({
  div({
    // banner
    virt-slot("sl:search-results")
    {
      show: set-slot("body", div(class: "sl-markdown-content", virt-slot("main-title")))
      include "content-panel.typ"
    }
    {
      show: set-slot("body", div(class: "sl-markdown-content", virt-slot("main-content")))
      include "content-panel.typ"
    }
  })
})
