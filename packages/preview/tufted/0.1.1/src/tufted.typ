#import "math.typ": template-math
#import "refs.typ": template-refs
#import "notes.typ": template-notes
#import "figures.typ": template-figures
#import "layout.typ": full-width, margin-note

#let make-header(links) = html.header(
  if links != none {
    html.nav(
      for (href, title) in links {
        html.a(href: href, title)
      },
    )
  },
)

#let tufted-web(
  header-links: none,
  title: "Tufted",
  lang: "en",
  css: (
    "https://cdnjs.cloudflare.com/ajax/libs/tufte-css/1.8.0/tufte.min.css",
    "/assets/tufted.css",
    "/assets/custom.css",
  ),
  content,
) = {
  // Apply styling
  show: template-math
  show: template-refs
  show: template-notes
  show: template-figures

  set text(lang: lang)

  html.html(
    lang: lang,
    {
      // Head
      html.head({
        html.meta(charset: "utf-8")
        html.meta(name: "viewport", content: "width=device-width, initial-scale=1")
        html.title(title)

        // Stylesheets
        for (css-link) in css {
          html.link(rel: "stylesheet", href: css-link)
        }
      })

      // Body
      html.body({
        // Add website header
        make-header(header-links)

        // Main content
        html.article(
          html.section(content),
        )
      })
    },
  )
}
