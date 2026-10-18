#import "../core.typ" as core
#import "legacy.typ": render-legacy-title-slide

// GREYC contributes only its own geometry; general flavors come from the core.
#let legacy = core.ambrosia-flavor(base: core.extensions.flavor-defaults, name: "legacy",
  top-margin: 2.4em,
  title-renderer: render-legacy-title-slide,
  header-title-inset-right: 0em,
  header-logo: true,
  header-logo-style: "traits",
  header-logo-placement: "edge",
  header-logo-fade: 1.5em,
  ending-empty-header: true,
)
#let flavor-names = ("legacy",) + core.extensions.flavor-names
#let get-flavor(value) = {
  let definition = if value == "legacy" { legacy } else { core.extensions.get-flavor(value) }
  // Lab artwork belongs at the top edge; footer-branded layouts retain
  // their own treatments. Explicit descriptors can override placement.
  if type(value) == str and value in ("simple", "minimal", "dewdrop", "stargazer", "portico") {
    definition + (header-logo: true, header-logo-placement: "edge", header-logo-style: "traits", header-logo-fade: 1.5em)
  } else { definition }
}
