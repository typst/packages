
#import "mod.typ": *
#import "@preview/shiroa:0.3.1": x-url-base

// ---

#add-styles(raw(lang: "css", read("styles/search.css")))
#inline-assets(raw(lang: "js", {
  "window.path_to_root = "
  json.encode(x-url-base)
}))

#div.with(id: "search-wrapper", class: "hidden")({
  form.with(id: "searchbar-outer", class: "searchbar-outer")({
    input(
      type: "search",
      id: "searchbar",
      name: "searchbar",
      placeholder: "Search this book ...",
      aria_controls: "searchresults-outer",
      aria_describedby: "searchresults-header",
    )[]
  })
  div.with(id: "searchresults-outer", class: "searchresults-outer hidden")({
    div(id: "searchresults-header", class: "searchresults-header")[]
    ul(id: "searchresults")[]
  })
})

#script(src: { x-url-base + "internal/elasticlunr.min.js" })[]
#script(src: { x-url-base + "internal/mark.min.js" })[]
#script(src: { x-url-base + "internal/searcher.js" })[]
