#import "@preview/touying-ambrosia:0.1.0" as core
#import "logo-data.typ": display-data

// Opt-in project branding for the starter/gallery, with no institution logos.
#let _logo(self, background: auto) = image(bytes(display-data("touying-ambrosia",
  dark: core.palettes.prefer-light(if background == auto { self.store.at("logo-background", default: self.page.fill) } else { background }))))
#let _header(self) = {
  let flavor = core.extensions.current-flavor(self)
  let fill = if flavor.navigation == "tabs" { (flavor.navigation-background)(self) } else { (flavor.header-background)(self) }
  _logo(self, background: if fill == none { self.page.fill } else { fill })
}
#let project-theme(..args, body) = {
  let custom-primary = args.named().at("primary-logos", default: auto) != auto
  show: core.ambrosia-theme.with(
    ..((title-logo-height: 3.2em, header-logo: if custom-primary { auto } else { _header }, logos: none,
      logo-focus: if custom-primary { auto } else { self => _logo(self, background: black) }) + args.named()),
    core.config-info(logo: _logo), ..args.pos(),
  )
  body
}
