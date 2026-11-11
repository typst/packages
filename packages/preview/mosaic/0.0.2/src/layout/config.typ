// Validation shared by setup, themes, slides, and the deck compiler.
#import "../shared.typ": fail, validate-keys
#import "../grid/model.typ": is-node
#import "core.typ": is-layout, make-layout
#import "api.typ" as base-layouts

// Configurable layouts: the names `setup(layouts:)` and themes may supply,
// because headings create these slides automatically and so need a default.
#let layout-names = ("content", "title", "section")
#let standard-layouts = (
  content: base-layouts.content(variant: "header-body"),
  title: base-layouts.title(),
  section: base-layouts.section(),
)

// Selectable-but-not-configurable layouts. Nothing creates an image slide
// automatically, so there is no default worth configuring and no reason to
// make every theme define one — but `slide(layout: "image", ..)` still needs a
// record for its named fields to refine. The constructor cannot build this
// stub, since it rejects a missing image; the resolver validates the merged
// result instead, so omitting `image:` still reports itself.
#let unconfigured-layouts = (
  image: make-layout("image", (
    caption: none,
    fit: auto,
    image: none,
    tracks: auto,
    variant: "figure",
  )),
)

#let selectable-layout-names = layout-names + unconfigured-layouts.keys()

#let validate-layout-value(value, name) = {
  if not is-node(value) and not is-layout(value) {
    fail(name + " must be a Mosaic grid tree or layout")
  }
  value
}

#let validate-layouts(value, name: "setup layouts", partial: false) = {
  if type(value) != dictionary {
    fail(name + " must be a dictionary")
  }
  _ = validate-keys(value, layout-names, name)
  if not partial {
    for layout-name in layout-names {
      if layout-name not in value {
        fail(name + " requires " + repr(layout-name))
      }
    }
  }
  for (layout-name, layout) in value {
    _ = validate-layout-value(layout, name + " " + repr(layout-name))
  }
  value
}
