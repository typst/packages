#import "@preview/cmarker:0.1.8": render
#import "utils.typ": simplify-number

/// Make cmarker support HTML
#let config = (
  heading-labels: "jupyter", // Let it preserve cases
  h1-level: 0,
  scope: (
    image: (path, alt: none) => html.img(
      src: path,
      alt: if alt == none { "" } else { alt },
    ),
    rule: html.hr,
  ),
  html: (
    // Override `<h1>` to circumvent https://github.com/SabrinaJewson/cmarker.typ/issues/56
    h1: (attrs, body) => title(body),
    picture: (attrs, body) => html.picture(..attrs, body),
    source: ("void", attrs => html.elem("source", attrs: attrs)),
  ),
)

/// Preprocess the header and footer markdown files
#let preprocess(md, project_count: 0, category_count: 0, stars_count: 0) = {
  md
    // Fix the parsing problem of newlines in `<img>`
    .replace(regex("<img\s+src"), "<img src")
    // Evaluate macros
    .replace("{project_count}", simplify-number(project_count))
    .replace("{category_count}", simplify-number(category_count))
    .replace("{stars_count}", simplify-number(stars_count))
}
