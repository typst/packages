// Contact information and social links components

#import "@preview/fontawesome:0.6.0": fa-icon
#import "theme.typ": __st-theme, __st-author, __stroke_length

// === Icon Helpers ===
#let __fa-icon-outline(
  icon,
  size: 1.5em,
) = (
  context {
    let theme = __st-theme.final()

    box(
      fill: theme.accent-color.lighten(10%),
      width: size,
      height: size,
      radius: size / 2,
      align(
        center + horizon,
        [
          #v(-0.15 * size)
          #fa-icon(icon, fill: white, size: size - .55em)
        ],
      ),
    )
  }
)

#let __social-link(
  icon,
  url,
  display,
  size: 1.5em,
) = (
  context {
    let theme = __st-theme.final()

    set text(size: 0.95em)

    block(width: 100%, height: size, radius: 0.6em, align(horizon, [
      #__fa-icon-outline(icon, size: size)
      #box(inset: (left: 0.2em), height: 100%, link(url)[#display])
    ]))
  }
)

// === Contact Info ===
// Displays email, phone, address with icons
#let contact-info() = (
  context [
    #let author = __st-author.final()
    #let theme = __st-theme.final()
    #let accent-color = theme.accent-color
    #let contact-items = ()

    #if "email" in author {
      contact-items += (
        [#v(-0.2em) #fa-icon("envelope", fill: accent-color)],
        link("mailto:" + author.email, author.email),
      )
    }

    #if "matrix" in author {
      contact-items += (
        [#v(-0.2em) #fa-icon("comment", fill: accent-color)],
        link("https://matrix.to/#/" + author.matrix, author.matrix),
      )
    }

    #if "phone" in author {
      contact-items += (
        [#v(-0.2em) #fa-icon("mobile-screen", fill: accent-color)],
        link("tel:" + author.phone, author.phone),
      )
    }

    #if "address" in author {
      contact-items += (
        [#v(-0.2em) #fa-icon("map", fill: accent-color)],
        author.address,
      )
    }

    #if contact-items.len() > 0 {
      table(
        columns: (1em, 1fr),
        align: (center, left),
        inset: 0pt,
        column-gutter: 0.5em,
        row-gutter: 1em,
        stroke: none,
        ..contact-items
      )
    } else {
      []
    }
  ]
)

// === Social Links ===
// Displays social media links with icons
#let social-links() = (
  context {
    let author = __st-author.final()
    let social-defs = (
      ("website", "globe", ""),
      ("twitter", "twitter", "https://twitter.com/"),
      ("mastodon", "mastodon", "https://mastodon.social/"),
      ("github", "github", "https://github.com/"),
      ("gitlab", "gitlab", "https://gitlab.com/"),
      ("linkedin", "linkedin", "https://www.linkedin.com/in/"),
      ("researchgate", "researchgate", "https://www.researchgate.net/profile/"),
      (
        "scholar",
        "google-scholar",
        "https://scholar.google.com/citations?user=",
      ),
      ("orcid", "orcid", "https://orcid.org/"),
    )

    set text(size: 0.95em, fill: luma(100))

    for (key, icon, url-prefix) in social-defs {
      if key in author {
        let url = url-prefix + author.at(key)
        let display = author.at(key)

        if key == "website" {
          display = display.replace(regex("https?://"), "")
        } else if key == "mastodon" {
          url = {
            let parts = display.split("@")
            if parts.len() >= 3 {
              "https://" + parts.at(2) + "/@" + parts.at(1)
            } else {
              url-prefix + display
            }
          }
        }

        __social-link(icon, url, display)
      }
    }

    if "custom-links" in author {
      for link-item in author.custom-links {
        __social-link(
          if "icon-name" in link-item and link-item.icon-name != none {
            link-item.icon-name
          } else {
            "link"
          },
          link-item.url,
          link-item.label,
        )
      }
    }
  }
)
