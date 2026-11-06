// Setup-aware dispatch for validated semantic layout records.
#import "core.typ": is-layout
#import "content.typ": resolve-content-layout
#import "image.typ": resolve-image-layout
#import "title.typ": resolve-title
#import "section.typ": resolve-section
#import "../shared.typ": fail

// The is-layout guard already pins command.name to this table's keys.
#let layout-resolvers = (
  content: resolve-content-layout,
  image: resolve-image-layout,
  title: resolve-title,
  section: resolve-section,
)

#let resolve-layout(command, settings) = {
  if not is-layout(command) {
    fail("invalid layout record")
  }
  layout-resolvers.at(command.name)(command, settings)
}
