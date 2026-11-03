# Heading model

`src/navigation/heading-model.typ` separates document structure from outline
presentation. It has no Touying dependency. The outline UI uses its query
adapter; structural tests call the pure model directly.

```typst
#import "../src/navigation/heading-model.typ": build-heading-model

#let model = build-heading-model(
  ((id: "section", level: 1), (id: "slide", level: 3)),
  current: "slide",
)
#assert.eq(model.entries.last().path, (1, 1))
```

Every input entry needs a unique non-`none` `id` and a positive integer `level`.
Additional fields are retained. The query adapter supplies `heading`, `loc` and
`outlined` fields using actual Typst heading locations as stable IDs.

The tree includes every authored heading, including `outlined: false` headings.
A node belongs to its nearest preceding lower-level ancestor. Missing heading
levels do not create synthetic parents. Printed numbering, repeated titles,
target selectors and display filters do not change its ownership.

Each entry carries:

- `level`: the original Typst heading level.
- `depth`, `path`: normalized structural depth and sibling ordinals.
- `index`, `subtree-end`: an exclusive interval containing the node and descendants.
- `parent-index`, `parent-id`, `root-index`, `root-id`: structural ownership.
- `relation`: `same`, `parent` (any ancestor), `child` (any descendant), `sibling`
  or `unrelated`, relative to the actual current heading. Exactly one is true.
- `is-current`, `is-active`: actual position and nearest visible ancestor.
- `here-path`, `here-level`, `here-depth`: current-heading context for transforms.

The model returns `entries` for the whole tree, `visible` for the presentation
projection, `current` for the actual current heading, `section` for its structural
root and `active` for its closest visible ancestor, including itself. Before the
first heading, `current`, `section`, `active` and each `relation` are `none`.

`selected` accepts `auto` or an array of IDs. `depth` retains native outline
semantics: it limits the original absolute heading level. `filter` accepts an
annotated entry and returns a boolean. These options only change `visible`.
Filter predicates can use `is-current` and `relation`. `is-active` is computed
after selection for transforms and model output.

Call `get-heading-model(target: heading.where(outlined: true), depth: none,
filter: entry => true)` inside a Typst `context`. Targets must select headings.
The `current-heading(level: auto, outlined: true)` compatibility helper honors
both arguments. `headings-context(target: ...)` returns the visible entries and
the active heading with its index in that visible array.

## Overlays

Touying 0.7.4 emits logical-slide and physical-subslide metadata. Its authored
section and slide headings appear once, while body headings can be replicated
across overlay pages. The query adapter maps those replicas back to the first
location at the same ordinal in a logical slide's heading sequence. Two authored
headings with identical text retain distinct ordinals and IDs.

Body heading sequences must stay identical or extend as a cumulative prefix
across overlays. Removing, reordering or changing earlier headings raises an
assertion. Use ordinary styled text for conditional overlay labels, or move
headings outside overlay functions. Swapping indistinguishable conditional
headings at the same ordinal is outside this contract: Typst's query API does
not expose their original source identities. Ordinary documents have no overlay
deduplication and preserve every authored heading location.
