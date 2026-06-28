# Prooftrees [DEPRECATED]

Deprecated in favour of [curryst](https://github.com/pauladam94/curryst). 
This package is no longer maintained and lacks many of the features of `curryst`.


# Old Description

---

# Prooftrees

This package is for constructing proof trees in the style of natural deduction or the sequent calculus, for `typst` `0.7.0`. Please do open issues for bugs etc :)

Features:
- Inferences can have arbitrarily many premises.
- Inference lines can have left and/or right labels¹
- Configurable² per tree and per line: premise spacing, the line stroke, etc... .
- They're proof trees.

¹ The placement of labels is currently very primitive, and requires much user intervention.

² Options are quite limited.

## Usage

The user interface is inspired by [bussproof](https://ctan.org/pkg/bussproofs)'s; a tree is constructed by a sequence of 'lines' that state their number of premises.
[`src/prooftrees.typ`](src/prooftrees.typ) contains the documentation and the main functions needed.

The code for some example trees can be seen in `examples/prooftree_test.typ`.

### Examples

A single inference would be:
```typst
#import "@preview/prooftrees:0.1.0"

#prooftree.tree(
    prooftree.axi[$A => A$],
    prooftree.uni[$A => A, B$]
)
```
<picture>
<img src="https://github.com/david-davies/typst-prooftree/blob/main/examples/Example1.png" width="30%" />
</picture>

A more interesting example:
```typst
#import "@preview/prooftrees:0.1.0"

#prooftree.tree(
    prooftree.axi[$B => B$],
    prooftree.uni[$B => B, A$],
    prooftree.uni[$B => A, B$],
        prooftree.axi[$A => A$],
        prooftree.uni[$A => A, B$],
    prooftree.bin[$B => A, B$]
)
```
<picture>
<img src="https://github.com/david-davies/typst-prooftree/blob/main/examples/Example2.png" width="40%" />
</picture>

An n-ary inference can be made:
```typst
#import "@preview/prooftrees:0.1.0"

#prooftrees.tree(
    prooftrees.axi(pad(bottom: 2pt, [$P_1$])),
    prooftrees.axi(pad(bottom: 2pt, [$P_2$])),
    prooftrees.axi(pad(bottom: 2pt, [$P_3$])),
    prooftrees.axi(pad(bottom: 2pt, [$P_4$])),
    prooftrees.axi(pad(bottom: 2pt, [$P_5$])),
    prooftrees.axi(pad(bottom: 2pt, [$P_6$])),
    prooftrees.nary(6)[$C$],
)
```
<picture>
<img src="https://github.com/david-davies/typst-prooftree/blob/main/examples/Example3.png" width="30%" />
</picture>

## Known Issues:

### Superscripts and subscripts clip with the line
The boundaries of blocks containing math do not expand enough for sub/pscripts; I think this is a typst issue.
Short-term fix: add manual vspace or padding in the cell.

## Implementation

The placement of the line and conclusion is calculated using `measure` on the premises and labels, and doing geometric arithmetic with these values.


