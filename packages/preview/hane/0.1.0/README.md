# typst-hane
A typst package for drawing go/baduk/weiqi diagrams

<table>
  <tr>
    <td>
      <pre>#import "@preview/hane:0.1.0": board, stone
#figure(
  board("
    . . . .
    . 1 . .
    . O X .
    . . . .
  "),
  caption: [Black's #stone(black, n: 1) is a _hane_.]
)</pre>
    </td>
    <td align=center>
      <img alt="Typst output showing a go board diagram" src="https://github.com/user-attachments/assets/89d454e0-9ed5-41e9-8437-a71a9dfe885f">
    </td>
  </tr>
  <tr>
    <td><pre>#import "@preview/hane:0.1.0": board
#board("
  $$Bc Support for Sensei's Library syntax.
  $$ | . .
  $$ | . X
  $$ | .
  $$ | . X X ,
  $$ | . O X X X
  $$ | . . O O X . X
  $$ | . O . B
  $$ --------
", board-color: rgb("eb9"))
</pre></td><td align=center>
  <img alt="Typst output showing a go board diagram" src="https://github.com/user-attachments/assets/44cd016f-cc8d-428c-8e62-7c59f3efa83a">

</td>
  </tr>
</table>

## How to use it

The `stone` function draws an inline stone of the given color:

    #stone(black)
    #stone(white, n: 4)
    #stone(black, mark: "circle")  // or "square" or "triangle" or "cross"

The `board` function draws a position diagram. The syntax is modeled after Sensei's Library's go diagram syntax, documented [here](https://senseis.xmp.net/?HowDiagramsWork).

    #board("
      O .
      . X
    ")

### Board symbols

The available symbols are:

| Symbol | Meaning |
| --- | --- |
| `.` | Empty space |
| `,` | Hoshi (star point) |
| `\|`  `-`  `+` | Edge of the board |
| `X` | Black stone |
| `O` | White stone |
| `B`  `#`  `Y`  `Z` | Marked black stone |
| `W`  `@`  `Q`  `P` | Marked white stone |
| `C`  `S`  `T`  `M` | Marked empty space |
| `1`  `2`  ... | Numbered stone |
| `a`  `b`  `c` ... | Letter-marked empty space |

### Header lines

If a line starts with `$$B` or `$$W`, it is parsed as a **header**. Example headers and their meanings are:

| Header | Meaning |
| --- | --- |
| `$$B` | 19×19 board where ① is Black. |
| `$$W7` | 7×7 board where ① is White. |
| `$$Bc13` | 13×13 board where ① is Black, with coordinates. |
| `$$BC13` | 13×13 board where ① is Black, with inverted coordinates. |
| `$$W Hello` | 19×19 board where ① is White, wrapped in a figure captioned `Hello`. |

For example:

<table>
  <tr>
    <td><pre>#board("
  $$Wc11 Example SL-style figure
  +--------
  | . . . .
  | 1 2 3 4
  | . . . .
")</pre></td>
    <td align=center>

![output](https://github.com/user-attachments/assets/c2129120-3ba3-4cd0-bf82-0047705e8671)

</td></tr></table>

## Options

### `stone`

| Parameter | Default | Description |
| --- | --- | --- |
| fill | (positional) | The color of the stone, `black` or `white`. |
| n | `none` | The number written on the stone. |
| mark | `none` | The type of mark on the stone, `"circle"` or `"square"` or `"triangle"` or `"cross"`. |
| height | `1em` | Height of the stone. |
| font | `"Inter"` | Font used for number on the stone. |
| mark-color | `rgb("#f24")` | Color used for markings on the stone. |
| mark-outline | `false` | Whether to outline the marking on the stone. |

### `board`

| Parameter | Default | Description |
| --- | --- | --- |
| notation | (positional) | The board notation string. |
| caption | `none` | If present, wrap the board in a figure with this caption. |
| scale | `1em` | The height to use for a single stone on the board. |
| font | `"Inter"` | Font of coordinates and the numbers on the stones. |
| placement | `none` | Placement of the figure, if `caption` is not `none`. |
| stroke | `0.05em` | Stroke of board grid lines. |
| edge-stroke | `0.1em` | Stroke of board grid lines at the edge of the board. |
| coordinates | `false` | Whether to draw coordinates off the side of the grid. |
| board-color | `rgb("#fff")` | Background color for the board. |
| mark-color | `rgb("#f24")` | Color used for markings on the stones. |
