<div align="center">
  <img alt="Quill" src="docs/images/logo.svg">
</div>

<div align="center">

[![Typst Package](https://img.shields.io/badge/dynamic/toml?url=https%3A%2F%2Fraw.githubusercontent.com%2FMc-Zen%2Fquill%2Fmain%2Ftypst.toml&query=%24.package.version&prefix=v&logo=typst&label=package&color=239DAD)](https://typst.app/universe/package/quill)
[![Test Status](https://github.com/Mc-Zen/quill/actions/workflows/run_tests.yml/badge.svg)](https://github.com/Mc-Zen/quill/actions/workflows/run_tests.yml)
[![MIT License](https://img.shields.io/badge/license-MIT-blue)](https://github.com/Mc-Zen/quill/blob/main/LICENSE)
[![User Manual](https://img.shields.io/badge/manual-.pdf-purple)][guide]

</div>


**Quill** is a package for creating quantum circuit diagrams in [Typst](https://typst.app/). 


_Note, that this package is in beta and may still be undergoing breaking changes. As new features like data types and scoped functions will be added to Typst, this package will be adapted to profit from the new paradigms._

_Meanwhile, we suggest importing everything from the package in a local scope to avoid polluting the global namespace (see example below)._

- [**Usage**](#basic-usage) _quick introduction_
- [**Cheat sheet**](#cheat-sheet) _gallery for quickly viewing all kinds of gates_
- [**Tequila**](#tequila) _building (sub-)circuits in a way similar to QASM or Qiskit_
- [**Examples**](#examples)
- [**Changelog**](#changelog)


## Basic usage

The function `quantum-circuit()` takes any number of positional gates and works somewhat similarly to the built-int Typst functions `table()` or `grid()`. A variety of different gate and instruction commands are available for adding elements and integers can be used to produce any number of empty cells (filled with the current wire style). A new wire is started by adding a `[\ ]` item. 

```typ
#{
  import "@preview/quill:0.4.0": *

  quantum-circuit(
    lstick($|0〉$), $H$, ctrl(1), rstick($(|00〉+|11〉)/√2$, n: 2), [\ ],
    lstick($|0〉$), 1, targ(), 1
  )
}
```
<h3 align="center">
  <img alt="Bell Circuit" src="docs/images/bell.svg">
</h3>

Plain quantum gates — such as a Hadamard gate — can be written with the shorthand notation `$H$` instead of the more lengthy `gate($H$)`. The latter offers more options, however. 

Refer to the [user guide][guide] for a full documentation of this package. You can also look up the documentation of any function by calling the help module, e.g., `help("gate")` in order to print the signature and description of the `gate` command, just where you are currently typing (powered by [tidy][tidy]). 

## Cheat Sheet

Instead of listing every featured gate (as is done in the [user guide][guide]), this gallery quickly showcases a large selection of possible gates and decorations that can be added to any quantum circuit. 

<h3 align="center">
  <img alt="Gallery" src="docs/images/gallery.svg" />
</h3>


## Tequila

_Tequila_ is a submodule that adds a completely different way of building circuits. 

```typ
#import "@preview/quill:0.4.0" as quill: tequila as tq

#quill.quantum-circuit(
  ..tq.build(
    tq.h(0),
    tq.cx(0, 1),
    tq.cx(0, 2),
  ),
  quill.gategroup(x: 2, y: 0, 3, 2)
)
```
This is similar to how _QASM_ and _Qiskit_ work: gates are successively applied to the circuit which is then layed out automatically by packing gates as tightly as possible. We start by calling the `tq.build()` function and filling it with quantum operations. This returns a collection of gates which we expand into the circuit with the `..` syntax. 
Now, we still have the option to add annotations, groups, slices, or even more gates via manual placement. 

The syntax works analog to Qiskit. Available gates are `x`, `y`, `z`, `h`, `s`, `sdg`, `sx`, `sxdg`, `t`, `tdg`, `p`, `rx`, `ry`, `rz`, `u`, `cx`, `cz`, and `swap`. With `barrier`, an invisible barrier can be inserted to prevent gates on different qubits to be packed tightly. Finally, with `tq.gate` and `tq.mqgate`, a generic gate can be created. These two accept the same styling arguments as the normal `gate` (or `mqgate`).

Also like Qiskit, all qubit arguments support ranges, e.g., `tq.h(range(5))` adds a Hadamard gate on the first five qubits and `tq.cx((0, 1), (1, 2))` adds two CX gates: one from qubit 0 to 1 and one from qubit 1 to 2. 

With Tequila, it is easy to build templates for quantum circuits and to compose circuits of various building blocks. For this purpose, `tq.build()` and the built-in templates all feature optional `x` and `y` arguments to allow placing a subcircuit at an arbitrary position of the circuit. 
As an example, Tequila provides a `tq.graph-state()` template for quickly drawing graph state preparation circuits. 

The following example demonstrates how to compose multiple subcircuits. 


```typ
#import tequila as tq

#quantum-circuit(
  ..tq.graph-state((0, 1), (1, 2)),
  ..tq.build(y: 3, 
      tq.p($pi$, 0), 
      tq.cx(0, (1, 2)), 
    ),
  ..tq.graph-state(x: 6, y: 2, invert: true, (0, 1), (0, 2)),
  gategroup(x: 1, 3, 3),
  gategroup(x: 1, y: 3, 3, 3),
  gategroup(x: 6, y: 2, 3, 3),
  slice(x: 5)
)
```
<div align="center">
  <img alt="Gallery" src="docs/images/composition.svg" />
</div>


## Examples

Some show-off examples, loosely replicating figures from [Quantum Computation and Quantum Information by M. Nielsen and I. Chuang](https://www.cambridge.org/highereducation/books/quantum-computation-and-quantum-information/01E10196D0A682A6AEFFEA52D53BE9AE#overview). The code for these examples can be found in the [example folder](./examples/) or in the [user guide][guide]. 

<h3 align="center">
  <img alt="Quantum teleportation circuit" src="docs/images/teleportation.svg">
</h3>
<h3 align="center">
  <img alt="Quantum circuit for phase estimation" src="docs/images/phase-estimation.svg">
</h3>
<h3 align="center">
  <img alt="Quantum fourier transformation circuit" src="docs/images/qft.svg">
</h3>

## Contribution

If you spot an issue or have a suggestion, you are invited to [post it](https://github.com/Mc-Zen/quill/issues) or to contribute. In [architecture.md](docs/architecture.md), you can also find a description of the algorithm that forms the base of `quantum-circuit()`. 

## Tests
This package uses [typst-test](https://github.com/tingerrr/typst-test/) for running [tests](tests/). 


## Changelog
### v0.4.0
- Alternative model for creating and composing circuits: [Tequila](#tequila). 

### v0.3.0
- New features
  - Enable manual placement of gates, `gate($X$, x: 3, y: 1)`, similar to built-in `table()` in addition to automatic placement. This works for most elements, not only gates. 
  - Add parameter `pad` to `lstick()` and `rstick()`. 
  - Add parameter `fill-wires` to `quantum-circuit()`. All wires are filled unto the end (determined by the longest wire) by default (breaking change ⚠️). This behavior can be reverted by setting `fill-wires: false`. 
  - `gategroup()` `slice()` and `annotate()` can now be placed above or below the circuit with `z: "above"` and `z: "below"`.
  - `help()` command for quickly displaying the documentation of a given function, e.g., `help("gate")`. Powered by [tidy][tidy]. 
- Improvements:
  - Complete rework of circuit layout implementation
    - allows transparent gates since wires are not drawn through gates anymore. The default fill is now `auto` and using `none` sets the background to transparent. 
    - `midstick` is now transparent by default. 
  - `setwire()` can now be used to override only partial wire settings, such as wire color `setwire(1, stroke: blue)`, width `setwire(1, stroke: 1pt)` or wire distance, all separately. Before, some settings were reset. 
- Fixes:
  - Fixed `lstick`/`rstick` when equation numbering is turned on. 
- Removed:
  - The already deprecated `scale-factor` (use `scale` instead)

### v0.2.1
- Improvements:
  - Add `fill` parameter to `midstick()`. 
  - Add `bend` parameter to `permute()`. 
  - Add `separation` parameter to `permute()`. 
- Fixes:
  - With Typst 0.11.0, `scale()` now takes into account outer alignment. This broke the positioning of centered/right-aligned circuits, e.g., ones put into a `figure()`. 
  - Change wires to be drawn all through `ctrl()`, making it consistent to `swap()` and `targ()`. 


### v0.2.0
- New features:
  - Add arbitrary labels to any `gate` (also derived gates such as `meter`, `ctrl`, ...), `gategroup` or `slice` that can be anchored to any of the nine 2d alignments. 
  - Add optional gate inputs and outputs for multi-qubit gates (see gallery).
  - Implicit gates (breaking change ⚠️): a content item automatically becomes a gate, so you can just type `$H$` instead of `gate($H$)` (of course, the `gate()` function is still important in order to use the many available options). 
- Other breaking changes ⚠️: 
  - `slice()` has no `dx` and `dy` parameters anymore. Instead, labels are handled through `label` exactly as in `gate()`. Also the `wires` parameter is replaced with `n` for consistency with other multi-qubit gates. 
  - Swap order of row and column parameters in `annotate()` to make it consistent with built-in Typst functions. 
- Improvements: 
  - Improve layout (allow row/column spacing and min lengths to be specified in em-lengths).
  - Automatic bounds computation, even for labels. 
  - Improve meter (allow multi-qubit gate meters and respect global (per-circuit) gate padding).d
- Fixes:
  - `lstick`/`rstick` braces broke with Typst 0.7.0.
  - `lstick`/`rstick` bounds.
- Documentation
  - Add section on creating custom gates. 
  - Add section on using labels. 
  - Explain usage of `slice()` and `gategroup()`.

### v0.1.0

Initial Release


[guide]: https://github.com/Mc-Zen/quill/releases/download/v0.4.0/quill-guide.pdf
[tidy]: https://github.com/Mc-Zen/tidy