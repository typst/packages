# dsviz

[![CI](https://github.com/wesleyel/dsviz/actions/workflows/ci.yml/badge.svg)](https://github.com/wesleyel/dsviz/actions/workflows/ci.yml)
[![Typst Universe](https://img.shields.io/badge/Typst_Universe-0.2.0-239dad)](https://typst.app/universe/package/dsviz)
[![Typst](https://img.shields.io/badge/Typst-%E2%89%A50.13-239dad)](https://typst.app)
[![Rust/WASM](https://img.shields.io/badge/plugin-Rust%2FWASM-555555)](https://github.com/wesleyel/dsviz/tree/main/plugin)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue)](LICENSE)

**English** · [中文](README.zh-CN.md)

Draw data-structure and computer-systems diagrams in [Typst](https://typst.app) from a few lines of text. The style is plain and traditional: square corners and thin black lines, with restrained color. A grayscale palette keeps every figure clear in black-and-white printing.

Labels are typeset by Typst itself, so diagrams align with any font and match your document.

![Overview of all 22 diagram kinds: trees, B-trees, lists, arrays, stacks, ring buffers, matrices, tables, graphs, adjacency structures, bit fields, pipeline charts, Gantt charts, sequence diagrams, waveforms and block diagrams](docs/images/gallery.png)

## Usage

````typ
#import "@preview/dsviz:0.2.0": ds

// Every ```ds block becomes a diagram.
#show raw.where(lang: "ds"): ds

```ds
bintree thread=in
A
  B
    _
    D
  C
```
````

The first line names the kind and its options; the rest describes the structure. You can also call the function directly:

````typ
#ds(width: 5cm, spacing: 1.2)[```
wave grid=on bits=1 0 1
CLK: c c c
Data: 10 01 10
```]
````

### Palettes

Diagrams use color by default. Pass `palette: "gray"` for black-and-white printing, per diagram or for a whole document:

```typ
#show raw.where(lang: "ds"): ds.with(palette: "gray")
```

![The same red-black tree, digraph and array in the gray and color palettes](docs/images/palette.png)

| Kinds | |
|---|---|
| Trees | `tree` `forest` `bintree` `rbtree` `btree` `bplus` |
| Linear | `list` `array` `stack` `ring` `matrix` `table` |
| Graphs | `graph` `digraph` `orthlist` `multilist` |
| Systems | `fields` `pipeline` `gantt` `ladder` `wave` `block` |

Full syntax and `ds` parameters: [docs/syntax.md](https://github.com/wesleyel/dsviz/blob/main/docs/syntax.md).

## Gallery

![Huffman-style binary tree with 0/1 edge labels, a red-black tree with NIL leaves, a decision tree, a forest and a B+ tree](docs/images/trees.png)

![Linked lists, an adjacency list, sorting passes, a stack, a circular queue and a KMP next table](docs/images/linear.png)

![Undirected and directed graphs, an adjacency matrix, an orthogonal list and an adjacency multilist](docs/images/graphs.png)

Sources are in [`examples/`](https://github.com/wesleyel/dsviz/tree/main/examples).

## Development

Requires Rust with the `wasm32-unknown-unknown` target.

```sh
make wasm    # build the plugin into src/dsviz.wasm
make test    # unit tests, gallery and examples
make images  # regenerate docs/images/
```

Release notes: [CHANGELOG.md](https://github.com/wesleyel/dsviz/blob/main/CHANGELOG.md). License: [MIT](LICENSE).
