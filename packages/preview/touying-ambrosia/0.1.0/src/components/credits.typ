#import "context.typ": component-wrapper
#import "branding.typ": render-logo
#import "../assets.typ"
#import "../palettes.typ": prefer-light
#import "../utils/layout.typ": call-or-display

// Downstream themes can replace this descriptor through config-store. Artwork
// and QR bytes resolve inside their owning package, never the caller's folder.
#let default-credit-project = (
  name: "touying-ambrosia",
  url: "https://github.com/inspiros/touying-ambrosia",
  logo: self => image(assets.read-asset(assets.asset-paths.showcase.touying-ambrosia.at(
    if prefer-light(self.store.logo-background) { "dark" } else { "light" }))),
  qr: image(assets.read-asset(assets.asset-paths.credit-qr)),
)

#let render-credit-card(self: none, project: auto, qr: true, qr-size: 4.5em,
  width: 100%, title: [Made with Typst], link-label: [Source and Examples],
) = {
  let project = if project == auto { self.store.at("credit-project", default: default-credit-project) } else { project }
  assert(type(project) == dictionary and type(project.at("name", default: none)) == str
    and type(project.at("url", default: none)) == str,
    message: "Credit project must provide name and url strings, with optional logo, qr, and based-on.")
  assert(type(qr) == bool or type(qr) == content or type(qr) == function,
    message: "Credit qr must be true, false, or QR content/callback.")
  assert(type(qr-size) == length, message: "Credit qr-size must be a length, such as 4.5em.")
  let code = if qr == false { none } else if qr == true { project.at("qr", default: none) } else { qr }
  let logo-self = self
  logo-self.store.logo-background = self.colors.surface
  block(width: width, breakable: false, above: 0.4em, below: 0.4em,
    fill: self.colors.surface, stroke: 0.04em + self.colors.border,
    radius: 0.4em, inset: 0.8em, {
      set std.align(left)
      set par(justify: false, leading: 0.45em, spacing: 0.5em)
      set text(fill: self.colors.foreground)
      [#metadata((name: project.name, url: project.url, qr: code != none))<ambrosia-credit-card>]
      grid(columns: if code == none { (1fr,) } else { (1fr, auto) },
        column-gutter: 0.9em, align: horizon,
        {
          text(size: 0.65em, fill: self.colors.muted, title)
          let logo = project.at("logo", default: none)
          if logo != none {
            v(0.35em)
            link(project.url, render-logo(logo-self, logo, 2.1em, left, kind: "credit"))
          }
          v(0.4em)
          text(size: 0.8em, weight: "semibold", link(project.url, project.name))
          let base = project.at("based-on", default: none)
          if base != none {
            parbreak()
            text(size: 0.6em, fill: self.colors.muted)[Built on #link(base.url, base.name)]
          }
          parbreak()
          text(size: 0.6em, fill: self.colors.primary, link(project.url, link-label))
        },
        ..if code == none { () } else {
          (context {
            assert(qr-size.to-absolute() > 0pt, message: "Credit qr-size must be positive.")
            let body = box(call-or-display(logo-self, code))
            let size = measure(body, width: qr-size, height: qr-size)
            assert(size.width > 0pt and size.height > 0pt, message: "Credit QR content must have a positive size.")
            let factor = calc.min(qr-size.to-absolute() / size.width, qr-size.to-absolute() / size.height) * 100%
            link(project.url, box(width: qr-size, height: qr-size, {
              [#metadata((width: qr-size.to-absolute().pt(), height: qr-size.to-absolute().pt(), url: project.url))<ambrosia-credit-qr>]
              std.align(center + horizon, scale(x: factor, y: factor, reflow: true,
                box(width: size.width, height: size.height, body)))
            }))
          },)
        },
      )
    })
}

/// Optional package credit; never inserted automatically. Native PDF links and
/// bundled QR artwork work in both online Typst and local IDE previews.
#let ambrosia-credit-card(..args) = component-wrapper(render-credit-card, ..args)
