Draw backgammon board positions and display checker movement from a given position within a [Typst](https://typst.app) document.

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/img/bar-point-examples.png">
  <img alt="bar-point board examples" src="/docs/img/bar-point-examples.png">
</picture>

## usage
Add the following to the top of the file:


```typ
#import "@preview/bar-point:0.1.0": backgammon-board
```

*bar-point* uses the single function `backgammon-board` to render the board and movement arrows

## basic example
```typ
#import "@preview/bar-point:0.1.0": backgammon-board

// define a board position
#let opening-layout = (
  -2,  0,  0,  0,  0,  5,  // points 01 to 06   (light home board)
   0,  3,  0,  0,  0, -5,  // points 07 to 12
   5,  0,  0,  0, -3,  0,  // points 13 to 18
  -5,  0,  0,  0,  0,  2   // points 19 to 24   (dark home board)
)

// create a new board using the given position
#backgammon-board(opening-layout)
```

## themes
use the `theme` parameter to change the theme.
Available themes:
* `"default-green"`
* `"tournament-blue"`
* `"woodland-brown"`
* `"high-contrast-dark"`
* `"print-grayscale"`

## `backgammon-board()` parameters

| Parameter | Type | Default Value | Description |
| :--- | :--- | :--- | :--- |
| **`checkers`** | `array` | *(positional)* | A 24-integer layout matrix array mapping checker frequencies. Positive integers represent light checkers, negative integers represent dark checkers |
| **`turn`** | `string` | `"light"` | Marks the active player turn phase. Accepts either `"light"` or `"dark"` |
| **`bar`** | `array` | `(0, 0)` | A two-integer array tracking pieces trapped on the central bar column formatted as `(light, dark)` |
| **`dice`** | `array` | `(1, 1)` | A two-integer array specifying active values displayed on the dice blocks, e.g. `(4, 2)` |
| **`cube`** | `dictionary` | `(value: 64, owner: none)` | Tracks the doubling cube state using keys `value` (integer) and `owner` (`none`, `"light"`, or `"dark"`) |
| **`borne-off`** | `array` | `(0, 0)` | A two-integer array capturing pieces that have been borne off completely formatted as `(light, dark)` |
| **`clockwise`** | `boolean` | `false` | When `false`, points 1–6 sit in the lower-right quadrant; when `true`, points 1–6 move to the lower-left |
| **`swap-colours`** | `boolean` | `false` | A purely cosmetic override that swaps checker colours without altering numerical data |
| **`swap-players`** | `boolean` | `false` | When `true`, completely negates the positional matrix values to view the entire match from the opponent's seating perspective with accurate analytics |
| **`ace-point`** | `string` | `"light"` | Sets whether the 1-point belongs to `"light"` or `"dark"`, automatically positioning scoreboards and bar alignments |
| **`moves`** | `array` | `()` | A collection of integer coordinate pairs outlining active token trajectories, e.g. `((24, 20), (13, 11))` |
| **`show-bg`** | `boolean` | `true` | Toggles the solid background arena panel display |
| **`show-border`** | `boolean` | `true` | Toggles the bounding perimeter framing lines |
| **`show-pips`** | `boolean` | `true` | Toggles the center column score totals text overlay |
| **`show-labels`** | `boolean` | `true` | Toggles the 1–24 numerical point indexes around borders |
| **`show-dice`** | `boolean` | `true` | Toggles the rendering of the active player dice boxes |
| **`show-cube`** | `boolean` | `true` | Toggles the rendering of the active match doubling cube |
| **`show-home-markers`** | `boolean` | `true` | Toggles horizontal accent stripes highlighting homeboard sectors |
| **`show-tray-borders`** | `boolean` | `true` | Toggles framing borders on borne-off side slots |
| **`theme`** | `string` | `"default-green"` | Selects a predefined design profile from the built-in themes database |
| **`font`** | `string` | `none` | Applies a custom choice of monospace font asset family, or defaults to your theme's preset choice if `none` |
| **`adjust-theme`** | `dictionary` | `(:)` | Pipes a map of custom color modifications directly into the rendering pipeline to override style assets |
| **`rounded`** | `boolean` | `true` | Configures whether panels use smooth soft corners or sharp crisp square edge alignments |
| **`scale`** | `float` | `1.0` | Applies structural geometric uniform canvas multiplier adjustments |
| **`label-size`** | `length` | `9pt` | Specifies typographic font bounds for indices and score markers |
| **`marker-thickness`** | `length` | `2.5pt` | Dictates line weights for home sector bars |
| **`tray-checker-size`** | `float` | `0.0` | Introduces customizable micro-spacing gaps inside the borne-off tray blocks |
| **`arrow-mark`** | `string` | `"circle"` | Declares the arrowhead mark shape used for bezier motion paths. Supports standard cetz marks such as `"circle"`, `"arrow"`, `">"`, `"stealth"`, `"\|"`, `"x"`, and `"diamond"` |


## dependencies
*bar-point* makes use of the fantastic [CeTZ](https://typst.app/universe/package/cetz) for rendering the board and moves

## license

This project is open-source software distributed under the terms of the permissive **MIT License**. See the [LICENSE](./LICENSE)
