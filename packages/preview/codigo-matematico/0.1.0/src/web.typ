// HTML-specific helpers for Typst 0.15+.


#let default-web-css = read("./web.css")


#let web-document(
  body,
  theme: "dark",
  css: auto,
) = {
  let stylesheet = if css == auto { default-web-css } else { css }

  // Typst owns the root <html>, <head>, and <body> elements so that built-in
  // features such as endnotes keep working. html.style is the supported API
  // for adding CSS to that generated single-file document.
  if stylesheet != none { html.style(stylesheet) }
  html.div(class: "web-shell web-shell--" + theme)[
    #html.main(class: "web-document")[#body]
  ]
}


#let web-end-marker(marker) = html.div(
  class: "environment-end-marker",
  aria-hidden: true,
)[#marker]
