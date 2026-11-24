# tidymind

Horizontal mind map diagrams for [Typst](https://typst.app), built on
[CeTZ](https://typst.app/universe/package/cetz/). Every node is measured before
the layout runs, so long labels never overlap — the common failure of
fixed-spacing tree drawers.

![A mind map with a filled root and rounded, colored nodes](https://raw.githubusercontent.com/pierryangelo/tidymind/v0.2.0/img/shallow.png)

## Usage

````typ
#import "@preview/tidymind:0.2.0": mindmap, node

#mindmap(node([Root],
  node([Branch A], node([A1]), node([A2])),
  node([Branch B]),
))
````

`node(content, ..children)` builds a tree node; `content` is the label and the
remaining positional arguments are its children (each one another `node(...)` or
raw content). A raw dictionary `(content: .., children: (..))` is also accepted.

## Long labels

This is the case that pushed the package into existence. Node sizes come from
Typst's `measure`, so a label that wraps reserves the vertical band it actually
needs — at any depth, with no manual offsets.

![Two long labels wrapped at node-max-width, neither overlapping the other](https://raw.githubusercontent.com/pierryangelo/tidymind/v0.2.0/img/long_labels.png)

## Styles

`style: "boxed"` (the default) draws every node as a rounded box, the root
filled with its branch color.

`style: "outline"` drops the boxes entirely: the root becomes a heading over a
baseline rule, each first-level branch a label resting on a rule in its own
color, and everything deeper is plain text. Hierarchy comes from size, weight
and color instead of from frames — useful when the map sits inside a document
and boxes would fight with the surrounding text.

![The same tree in the outline style, with no boxes around any node](https://raw.githubusercontent.com/pierryangelo/tidymind/v0.2.0/img/outline.png)

## Roles and branch colors

A node can carry an `emphasis` — its role — and a `branch` index that overrides
the color it would inherit from its position. Both are given by **name**: the
document says what a node *means*, and the package resolves the color.

````typ
#mindmap(
  node([SQL privileges],
    node([GRANT],
      node([Idempotent], emphasis: "definition"),
      node([Cascades to dependents], emphasis: "warning"),
    ),
    node([REVOKE], branch: 5,
      node([RESTRICT is the default], emphasis: "highlight"),
    ),
  ),
  style: "outline",
)
````

![A map whose leaves are colored by role: definition, warning, highlight and example](https://raw.githubusercontent.com/pierryangelo/tidymind/v0.2.0/img/emphasis.png)

## Options

| Option | Default | Meaning |
|--------|---------|---------|
| `style` | `"boxed"` | `"boxed"` or `"outline"` (see above) |
| `palette` | 6 colors | color per first-level branch, cycled |
| `font` | `"Inter"` | label font, or a fallback list |
| `text-size` | `9pt` | base label size; the root and first level scale up from it |
| `node-max-width` | `6cm` | max width before a label wraps |
| `max-depth` | `6` | prune nodes deeper than this |
| `h-gap` | `40pt` | horizontal gap between levels |
| `v-gap` | `10pt` | minimum vertical gap between siblings |
| `ink` | `(strong, soft)` | label colors; partial dictionaries merge over the defaults |
| `emphasis-colors` | 4 roles | `highlight`, `warning`, `definition`, `example` |

Labels take arbitrary Typst content, so markup and emoji work — pass a color
emoji font in the `font` fallback list to get the second one:

````typ
#mindmap(node([Git: #strong[what gets graded]], node([🥇 #strong[Remote sync] (35%)])),
  font: ("Inter", "Noto Color Emoji"))
````

## How it works

The layout is a tidy tree by subtree extent: every subtree reserves a vertical
band equal to the sum of its children's bands (or its own height, if a leaf), and
the parent is centered within that band. Because sibling subtrees occupy disjoint
bands, nodes never overlap — at any depth. It runs in O(n), in two passes: one
up the tree to size the bands, one down to place the nodes.

Node sizes come from Typst's `measure`, so a band accounts for the real rendered
size of each (possibly wrapped) label. Measuring and drawing go through a single
description of the node body (`src/style.typ`), which is what keeps an edge
landing exactly on the node it points at.

## Examples

Every file under [`examples/`](examples) compiles on its own. Files named
`visual_*` produce the images above; files named `_assert_*` exercise the logic
through `#assert`, so compiling them **is** the test suite.

```sh
sh examples/render.sh    # runs the asserts, then regenerates img/
```

| Example | What it covers |
|---------|----------------|
| [`visual_shallow`](examples/visual_shallow.typ) | a root with three leaves |
| [`visual_deep`](examples/visual_deep.typ) | several levels of nesting |
| [`visual_many_siblings`](examples/visual_many_siblings.typ) | vertical spacing under pressure |
| [`visual_long_labels`](examples/visual_long_labels.typ) | labels wrapping at `node-max-width` |
| [`visual_outline`](examples/visual_outline.typ) | the `"outline"` style |
| [`visual_emphasis`](examples/visual_emphasis.typ) | roles and branch overrides |
| [`visual_markdown_emoji`](examples/visual_markdown_emoji.typ) | markup and emoji in labels |
| [`visual_single`](examples/visual_single.typ) | a lone root |
| [`visual_empty`](examples/visual_empty.typ) | empty labels |

## Changelog

**0.2.0** — adds `style: "outline"`, the `branch` and `emphasis` attributes on
`node`, and the `ink` / `emphasis-colors` options. The default output is
unchanged: `style: "boxed"` renders exactly what 0.1.1 rendered.

**0.1.1** — long labels wrap instead of overflowing their measured width.

## License

MIT
