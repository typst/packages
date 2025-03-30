# Commute
Proof-of-concept commutative diagrams library for [typst](https://typst.app/home)

See [EricWay1024/tikzcd-editor](https://github.com/EricWay1024/tikzcd-editor)
for a web-based visual diagram editor for this library!

# Example
```
#import "@preview/commute:0.3.0": node, arr, commutative-diagram

#align(center)[#commutative-diagram(
  node((0, 0), $X$),
  node((0, 1), $Y$),
  node((1, 0), $X \/ "ker"(f)$, "quot"),
  arr($X$, $Y$, $f$),
  arr("quot", (0, 1), $tilde(f)$, label-pos: right, "dashed", "inj"),
  arr($X$, "quot", $pi$),
)]
```

![screenshot](https://github.com/typst/packages/assets/20535498/71eb8d47-b6f9-43fa-a1fd-7ff58b8d0025)
   
For more usage examples look at `example.typ`

# Usage
The library provides 3 functions: `node`, `arr`, and `commutative-diagram`.
You can clone this repo and import `lib.typ`:
```
#import "path/to/commute/lib.typ": node, arr, commutative-diagram
```
Or directly use the builtin package manager:
```
#import "@preview/commute:0.3.0": node, arr, commutative-diagram
```

## `commutative-diagram`
```
commutative-diagram(
  node-padding: (70pt, 70pt),
  arr-clearance: 0.7em,
  padding: 1.5em,
  debug: false,
  ..entities
)
```
`commutative-diagram` returns a rectangular region containing the
nodes and arrows.
All the unnamed arguments passed to `commutative-diagram` are treated as
nodes or arrows of the diagram. These can be constructed using the
`node` and `arr` functions explained below.
The other arguments are as follows:
- `node-padding`: `(length, length)`. The space to leave between adjacent nodes. It's a
  tuple, `(h, v)`, containing the horizontal and vertical spacing respectively.
- `arr-clearance`: `length`. The default space between arrows' base/tip and the diagram's nodes. 
- `padding`: `length`. The padding around the whole diagram
- `debug`: `bool`. Whether or not to display debug information. 

## `node`
```
node(
  pos,
  label,
  id: label,
)
```
Creates a new diagram node. Has the following positional arguments:
- `pos`: `(integer, integer)`. The position of the node in `(row, column)` format.
  Must be integers, but can be negative, the only thing that counts is the
  difference between the coordinares of the variuos nodes in the diagram.
- `label`: `content`. The node's label.
- `id`: `any`. The node's id, defaults to its label if not specified.

## `arr`
```
arr(
  start,
  end,
  label,
  start-space: none,
  end-space: none,
  label-pos: left,
  curve: 0deg,
  stroke: 0.45pt,
  ..options
)
```
Creates an arrow. Has the following arguments:
- `start`: `(integer, integer)` or `any`. The position of the node from which the arrow starts,
  in `(row, column)` format, or its id.
- `end`: `(integer, integer)` or `any`. The position of the node where the arrow ends,
  in `(row, column)` format, or its id.
- `label`: `content`. The label to put on the arrow.
- `start-space`: `length`. The space between the start node and the beginning of the arrow.
  You can pass `none` to leave a sensible default, customizable using the
  `arr-clearance` parameter of the `commutative-diagram` function.
- `end-space`: `length`. Similar to the above.
- `label-pos`: `length` or `left` or `right`. Where to position the arrow's label relative to the arrow.
  A positive length means that, when looking towards the tip of the arrow,
  the label is on the left. `left` and `right` measure the label to automatically get a reasonable
  length. If set to `0` (`0` the number, which is different from `0pt` or `0em`)
  then the label is placed on top of the arrow, with a white background to help
  with legibility.
- `curve`: `angle`. The difference in orientation between the start and the end of the arrow.
  If positive, the arrow curves to the right, when looking towards the tip.
- `stroke`: `stroke`. The thickness and color of the arrows. The default should probably be fine.
- `options`: `string`s. After the mandatory positional arguments `start`, `end` and `label`,
  any remaining unnamed argument is treated as an extra option. Recognized options are:
  - `"inj"`, gives the arrow a hook at the start, used for injective functions
  - `"surj"`, gives the arrow a double tip, used for surjective functions
  - `"bij"`, gives the arrow a tip also at the start, used for bijective functions
  - `"def"`, gives the arrow a bar at the start, used for function definitions
  - `"nat"`, gives the arrow a double stem, used for natural transformations
  - `"two"`, draws two arrows on top of each other, used when two maps between the same objects are involved
  - All the options supported by the `dash` parameter of Typst's `stroke` type, such as
    `"dashed"`, `"densely-dotted"`, etc. These change the appearance of the arrow's stem.

  Not all combinations of the above options are compatible or supported.
