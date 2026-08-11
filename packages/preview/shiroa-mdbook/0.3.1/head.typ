
#import "mod.typ": *

// ---

#head({
  meta(charset: "utf-8")
  meta(
    name: "viewport",
    content: "width=device-width, initial-scale=1.0",
  )
  virt-slot("sa:head-meta")
  meta(name: "generator", content: "Shiroa")
  // todo: <!-- Custom HTML head -->
  meta(name: "theme-color", content: "#ffffff")
  // todo: favicon.png

  inline-assets(context (
    raw(lang: "css", read("css/chrome.css")),
    raw(lang: "css", read("css/general.css")),
    raw(lang: "css", read("css/variables.css")),
    raw(lang: "js", read("pollyfill.js")),
    // todo: esm?
    ..styles.final().values(),
  ).join())
  dyn-svg-support()

  virt-slot("sl:book-meta")
})
