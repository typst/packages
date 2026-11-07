// `adapter`, which `lib.typ` re-exports as a module: the helpers in
// `adapter-helpers.typ`, and nothing else. Typst re-exports every name
// a module imports, so the helpers' own imports would otherwise show
// up as `adapter.*` too.

#import "adapter-helpers.typ": (
  basics-contacts, custom, entries, entry-type, fluency-rating, format-date,
  group-by-type, labels, location-parts, preferences,
)
