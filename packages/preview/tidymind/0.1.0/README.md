# tidymind

Horizontal mind map diagrams for [Typst](https://typst.app), built on
[CeTZ](https://typst.app/universe/package/cetz/). Each node is measured before
layout, so long labels never overlap — the common failure of fixed-spacing tree
drawers.

## Usage

````typ
#import "@preview/tidymind:0.1.0": mindmap, node

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
| `palette` | 6 colors | cor por ramo de 1º nível |
| `font` | `"Inter"` | fonte dos rótulos |
| `text-size` | `9pt` | tamanho do texto |
| `node-max-width` | `6cm` | largura máx antes de quebrar linha |
| `max-depth` | `6` | poda além desta profundidade |
| `h-gap` | `40pt` | espaço horizontal entre níveis |
| `v-gap` | `10pt` | espaço vertical mínimo entre irmãos |

## How it works

The layout is a tidy tree by subtree extent: every subtree reserves a vertical
band equal to the sum of its children's bands (or its own height, if a leaf), and
the parent is centered within that band. Because sibling subtrees occupy disjoint
bands, nodes never overlap — at any depth. Node sizes come from Typst's `measure`,
so the band accounts for the real rendered size of each (possibly wrapped) label.

## License

MIT
