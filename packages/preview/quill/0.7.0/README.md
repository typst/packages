<div align="center">
  <img alt="Quill" src="https://github.com/user-attachments/assets/3cb87ef5-03e0-48a7-b00b-1b8277a03fe1" style="max-width: 100%; width: 300pt">
</div>

<div align="center">

[![Typst Package](https://img.shields.io/badge/dynamic/toml?url=https%3A%2F%2Fraw.githubusercontent.com%2FMc-Zen%2Fquill%2Fv0.7.0%2Ftypst.toml&query=%24.package.version&prefix=v&logo=typst&label=package&color=239DAD)](https://typst.app/universe/package/quill)
[![Test Status](https://github.com/Mc-Zen/quill/actions/workflows/run_tests.yml/badge.svg)](https://github.com/Mc-Zen/quill/actions/workflows/run_tests.yml)
[![MIT License](https://img.shields.io/badge/license-MIT-blue)](https://github.com/Mc-Zen/quill/blob/main/LICENSE)
[![User Manual](https://img.shields.io/badge/manual-.pdf-purple)][guide]

</div>


**Quill** is a package for creating quantum circuit diagrams in [Typst](https://typst.app/). 
It features two distinct creation models:
- The manual and powerful [grid model](#basic-usage-the-grid-model).
- The automatic, instruction-driven model [Tequila](#tequila) which is also useful for _composing_ sub-circuits. These circuits are then embedded into the grid model. 

Outline:


- [Usage](#basic-usage-the-grid-model): _A quick introduction_
- [Cheat sheet](#cheat-sheet): _A gallery showcasing various circuit elements_
- [Tequila](#tequila): _Building circuits similar to QASM or Qiskit_
- [Examples](#examples)
- [Changelog](#changelog)


## Basic usage (the grid model)

The function `quantum-circuit()` takes any number of positional gates and works similar to the built-in Typst functions `table()` and `grid()`. 
- A variety of different gate and instruction commands are available for adding elements. 
- Integers can be used to produce any number of empty cells (filled with the current wire style). 
- A new wire is started by adding a `[\ ]` item. 


```typ
#{
  import "@preview/quill:0.7.0": *

  quantum-circuit(
    lstick($|0〉$), $H$, ctrl(1), rstick($(|00〉+|11〉)/√2$, n: 2), [\ ],
    lstick($|0〉$), 1, targ(), 1
  )
}
```
<div align="center">
  
  ![Bell state preparation circuit](https://github.com/user-attachments/assets/f80f6041-379e-440c-bcda-95348f066f17)
  
</div>

Plain quantum gates — such as a Hadamard gate — can be written with the shorthand notation `$H$` instead of the more lengthy `gate($H$)`. The latter offers additional styling options. 

Refer to the [user guide][guide] for a full documentation of this package. You can also look up the documentation of any function by calling the help module, e.g., `#help("gate")` just where you are currently typing (powered by [tidy][tidy]). 


## Cheat Sheet

This gallery quickly showcases a large selection of possible gates and decorations that can be added to any quantum circuit. 

<div align="center">
  
  ![Gallery](https://github.com/user-attachments/assets/c7852e83-6652-4503-a52e-3a658c123a37)
  
</div>





## Tequila


_Tequila_ is a submodule that adds a completely different way of building circuits. 

```typ
#import "@preview/quill:0.7.0" as quill: tequila as tq

#quill.quantum-circuit(
  ..tq.build(
    tq.h(0),
    tq.cx(0, 1),
    tq.cx(0, 2),
  ),
  quill.gategroup(x: 2, y: 0, 3, 2)
)
```

This is similar to how _QASM_ and _Qiskit_ work: gates are successively applied to the circuit which is then laid out automatically by packing gates as tightly as possible. We start by calling the `tq.build()` function and filling it with quantum operations. This returns a collection of gates which we expand into the circuit with the `..` syntax. 
Now, we still have the option to add annotations, groups, slices, or even more gates via manual placement. 

The syntax works analogously to Qiskit. Available gates are `x`, `y`, `z`, `h`, `s`, `sdg`, `sx`, `sxdg`, `t`, `tdg`, `p`, `rx`, `ry`, `rz`, `u`, `cx`, `cz`, and `swap`. With `barrier`, an invisible barrier can be inserted to prevent gates on different qubits to be packed tightly. Finally, with `tq.gate` and `tq.mqgate`, a generic gate can be created. These two accept the same styling arguments as the normal `gate` (or `mqgate`).

Also like Qiskit, all qubit arguments support ranges, e.g., `tq.h(range(5))` adds a Hadamard gate on the first five qubits and `tq.cx((0, 1), (1, 2))` adds two CX gates: one from qubit 0 to 1 and one from qubit 1 to 2. 

With Tequila, it is easy to build templates for quantum circuits and to compose circuits of various building blocks. For this purpose, `tq.build()` and the built-in templates all feature optional `x` and `y` arguments to allow placing a sub-circuit at an arbitrary position of the circuit. 
As an example, Tequila provides a `tq.graph-state()` template for quickly drawing graph state preparation circuits. 

The following example demonstrates how to compose multiple sub-circuits. 


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
  <img alt="Gallery" src="https://github.com/user-attachments/assets/3a660b40-923f-4410-838e-322a673604e6" />
</div>


## Examples

Some show-off examples, loosely replicating figures from [Quantum Computation and Quantum Information by M. Nielsen and I. Chuang](https://www.cambridge.org/highereducation/books/quantum-computation-and-quantum-information/01E10196D0A682A6AEFFEA52D53BE9AE#overview). The code for these examples can be found in the [example folder][examples] or in the [user guide][guide]. 

<div align="center">
  <img alt="Quantum teleportation circuit" src="https://github.com/user-attachments/assets/f371d9b9-e9ab-49a7-a728-7fa94d958a8a">
</div>
<div align="center">
  <img alt="Quantum circuit for phase estimation" src="https://github.com/user-attachments/assets/1864a436-b09b-46ac-961d-f13f3a4616ec">
</div>
<div align="center">
  <img alt="Quantum fourier transformation circuit" src="https://github.com/user-attachments/assets/6dabcd87-3dfe-4d4b-9758-798855c6fee7">
</div>


## Contribution

If you spot an issue or have a suggestion, you are invited to [post it](https://github.com/Mc-Zen/quill/issues) or to contribute to this package. In [architecture.md][architecture], you can also find a description of the algorithm that forms the base of `quantum-circuit()`. 

## Tests
This package uses [tytanic](https://github.com/tingerrr/tytanic) for running [tests](tests/). 


## Changelog

### v0.7.0
- Improvements to Tequila: 
  - Exposed a `tequila.ca` gate for arbitrary single-qubit controlled gates. 
  - Added `tequila.measure` to replace `tequila.meter`. The new gate can also receive an index of a wire to send the result to via a classical wire. 
  - Addd optional `start` and `end` parameters to `tequila.barrier` that allow local barriers. 
  - Fixed problems with `multi-controlled-gate`. 
- `targ` can now take a "target" qubit as in `targ(2)` to produce a vertical wire, just like `ctrl` and `swap`. 
- Both `ctrl` and `swap` can now be used without target argument like `ctrl()`. This can replace usage like `ctrl(0)` for gates without a control wire. 
- Added position parameters `x` and `y` to the `phantom` gate. 

### v0.6.1
- Fixes braces in circuits which were broken in new Typst version 0.13. 
- Replaces usage of the now deprecated `path` element with the new `curve` element. 
- ⚠️ Requires Typst 0.13. 


### v0.6.0
- Improved support for Tequila: controlled-gates can now take additional styling parameters.
- ⚠️ Removed `targX`: use `swap(0)` instead. 
- Fixed `stroke` for the plain `gate` command. 
- Big documentation update. 

### v0.5.0
- Added support for multi-controlled gates with Tequila. 
- Switched to using `context` instead of the now deprecated `style()` for measurement. 
Note: Starting with this version, Typst 0.11.0 or higher is required. 

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
  - Improve meter (allow multi-qubit gate meters and respect global (per-circuit) gate padding).
- Fixes:
  - `lstick`/`rstick` braces broke with Typst 0.7.0.
  - `lstick`/`rstick` bounds.
- Documentation
  - Add section on creating custom gates. 
  - Add section on using labels. 
  - Explain usage of `slice()` and `gategroup()`.

### v0.1.0

Initial Release


[guide]: https://github.com/Mc-Zen/quill/releases/download/v0.7.0/quill-guide.pdf
[examples]: https://github.com/Mc-Zen/quill/tree/main/examples
[tidy]: https://github.com/Mc-Zen/tidy
[architecture]: https://github.com/Mc-Zen/quill/blob/main/docs/architecture.md




