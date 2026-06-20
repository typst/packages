# tidymind

Horizontal mind map diagrams for [Typst](https://typst.app), built on
[CeTZ](https://typst.app/universe/package/cetz/). Each node is measured before
layout, so long labels never overlap — the common failure of fixed-spacing tree
drawers.

## Usage

````typ
#import "@preview/tidymind:0.1.1": mindmap, node

#mindmap(node([Root],
  node([Branch A], node([A1]), node([A2])),
  node([Branch B]),
))
````

`node(content, ..children)` builds a tree node; `content` is the label and the
remaining positional arguments are its children (each one another `node(...)` or
raw content). A raw dictionary `(content: .., children: (..))` is also accepted.

### Options

| Option | Default | Meaning |
|--------|---------|---------|
| `palette` | 6 colors | color per first-level branch |
| `font` | `"Inter"` | label font |
| `text-size` | `9pt` | label text size |
| `node-max-width` | `6cm` | max width before a label wraps |
| `max-depth` | `6` | prune nodes deeper than this |
| `h-gap` | `40pt` | horizontal gap between levels |
| `v-gap` | `10pt` | minimum vertical gap between siblings |

## Examples

- [Shallow tree](examples/visual_shallow.typ) — a root with three leaves.
- [Deep tree](examples/visual_deep.typ) — multiple levels of nesting.
- [Many siblings](examples/visual_many_siblings.typ) — a root with eight children.
- [Long labels](examples/visual_long_labels.typ) — labels wrap at `node-max-width`.

## How it works

The layout is a tidy tree by subtree extent: every subtree reserves a vertical
band equal to the sum of its children's bands (or its own height, if a leaf), and
the parent is centered within that band. Because sibling subtrees occupy disjoint
bands, nodes never overlap — at any depth. Node sizes come from Typst's `measure`,
so the band accounts for the real rendered size of each (possibly wrapped) label.

## License

MIT
