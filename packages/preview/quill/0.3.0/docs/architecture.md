# Architecture

The main algorithm used in `quantum-circuit` for circuit layout is quite intricate and is described here broadly for a better overview. The algorithm specifically takes care of the following things:
- Not drawing wires through gates: this way we can also use transparent gates. 
- Computing the bounding box of the circuit: it also treats labels that can be attached to almost anything. 
- Computing the position of automatically placed items.
- Custom spacing between rows and columns (so-called gutters). 
- Correctly adjusting the wire distance according to the gate heights: especially for the case of multi-qubit gates. 


## Notes
### Differentiation between single-qubit and multi-qubit gates
`quill` differentiates between ordinary single-qubit gates (such as a Hadmard gate) and multi-qubit-gates. The latter are generalized gates that can 
a) span across multiple qubits,
b) have a control wire towards some target qubit,
c) have both. 

This differentiation is used because multi-qubit gates require much more care and processing. 


### Anatomy of a cell

```
          cell   gutter
      ┌─────────┬──┐     ┐
      │  ┌───┐  │  │     │
wire ─┼──┤ H ├──┼──┼─    │ cell height
      │  └───┘  │  │     │   ┐  
      └─────────┴──┘     ┘   ┘ 0.5*row-spacing 
      └─────────┘
       cell width

      └──┘
 0.5*column-spacing
```
A quantum circuit is made up of a matrix of cells. Gates are by default placed in the middle of a cell (exception for example `lstick`) and wires _always_ run through vertically centered through the cell. 

The padding of the cell is determined by the value of `column-spacing` and `row-spacing`. These lengths can be specified in `quantum-circuit()` and are added to the size of the gate to compute a temporary cell size. The largest cell in a row and column determines the final cell width and height. If `equal-row-heights` is true, then all rows are resized to match the largest row. To the right of each cell (or rather column) is an optional gutter that has zero width by default. Additional row gutters can increase the spacing between rows. 

As an example, this code 
```typ
#quantum-circuit(
    1, $H$, 10pt, ctrl(1), 1, [\ ], 15pt
    2, 5pt, $X$, 1
)
```
produces a circuit according the following schematic:
```
           col 0        col 1  
        ┌─────────┬──┬─────────┬┐  
        │  ┌───┐  │  │         ││  
wire 0 ─┼──┤ H ├──┼──┼────o────┼┼─ 
        │  └───┘  │  │    │    ││  
        ├─────────┼──┼────┼────┼┤  
        ├─────────┼──┼────┼────┼┤   ← 15pt row gutter
        │         │  │  ┌─┴─┐  ││  
wire 1 ─┼─────────┼──┼──┤ X ├──┼┼─ 
        │         │  │  └───┘  ││  
        └─────────┴──┴─────────┴┘  
                   ↑            ↑
              10pt gutter   0pt gutter
```
Note, that the `5pt` gutter is overridden by the `10pt` gutter in the same column. 


## Description of the `quantum-circuit()` layout algorithm

The algorithm is roughly divided into two parts. First, we iterate over all children, determine their position and compute the layout. In the second step, the actual circuit is created by composing the different item groups:
- decorations
- horizontal and vertical wires
- single-qubit-gates and multi-qubit gates. 

### Preprocessing
First, "auto"-gates are processed, i.e., we replace `str` and `content` items (like `$H$`) with gates. 

### Build Matrix
All gates are arranged in a grid — the _matrix_. By default, gates are placed automatically, advancing the column index but gates can also be explicitly placed in a specific cell. In the first pass through all children, we:
- Determine the matrix position of automatically placed items. 
- Add an entry to the matrix for each gate that contains the `size` of the gate, whether the gate is in `box` mode and some gutter value for optional spacing after the corresponding column. Empty cells simply have a size of 0. The matrix is automatically resized to accommodate for new gates. Each cell can only host one item. 
- Store all column gutters (specified by `length` children after a gate).
- Store row gutters separately (specified by `length` children after a `[\ ]`). 
- Store all `setwire()` instructions in an array to be processed later. 
- Put all normal (non-controlled or multi-qubit) gates in an array `single-qubit-gates`. 
- Put multi-qubit-gates (including controlled gates) in an array `multi-qubit-gates`. 
- Store all decorations (such as `slice`, `gategroup`, or `annotate`) together with their cell position in an array. 

The matrix requires some post-processing to equalize the row lengths. The column gutters are computed as the maximum gutters per column across all rows. 

### Process multi-qubit gates

For all multi-qubit gates that have a `target`, a (vertical) control wire instruction is stored containing column, starting and target wire, as well as the wire style. 

If a gate spans across multiple qubits, the size-hints `width` is unconditionally set to the width of the gate for all cells that the gate contains. This is important for wire placement. Additionally, if the `size-all-wires` parameter requires it, the cell height is set to the same value as well. 

### Finish layout computation

Now the necessary height of each row and the width of each column can be computed using the size hints stored in the matrix. In both cases the maximum value per column/row is used. For ease of access the center coordinates of each column and row is computed from the row heights, column widths and row/column gutters. 

### Build circuit

In this step, the circuit is crafted from the individual components. First, the decorations (`slice`, `gategroup`, `annotate`) are drawn on two layers (one below the circuit which is applied immediately and one above the circuit which is applied later on). Afterwards, the horizontal and verticals wires are drawn. Here, we need to take care not to drawn _through_ a gate and use the size hints from the matrix cells. Then, the gates are drawn and finally the second the decoration layer is applied. 

Most items in the circuit feature the attachment of labels at each side. In order to accommodate for their size and to appropriately pad the circuit, the bounds of the circuit need to be updated for each item with labels. These contain gates, decorations, and vertical wires. 

### Apply scaling and bounds extension

Finally, the entire circuit is scaled according to the `scale` argument and padded with the bounds that were computed in the building step. 