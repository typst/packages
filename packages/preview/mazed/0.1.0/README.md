# mazed

Procedural maze generator for Typst with customizable start and finish cells.

This package generates and renders rectangular mazes using a deterministic
random generator. The maze layout is created with a depth-first search (DFS)
backtracking algorithm, producing a *perfect maze* (exactly one path between
any two cells).

## Installation

```typst
#import "@preview/mazed:0.1.0": maze
```

## Examples

### Basic maze

```typst
#maze(
  12,
  8,
  width: 10cm
)
```

### Red maze with given seed, as well as start and finish markers

```typst
#maze(
  10,
  10,
  width: 10cm,
  seed: 123,
  start: [🚩],
  finish: [🏁],
  stroke: red
)
```

## Function

### `maze`

Generates and renders a maze.

```typst
maze(
  cols,
  rows,
  width: 100%,
  height: 100%,
  seed: 0,
  stroke: auto,
  start: none,
  finish: none,
)
```

**Parameters**

- `cols` - number of maze columns  
- `rows` - number of maze rows  
- `width` - width of the rendered maze  
- `height` - height of the rendered maze  
- `seed` - random seed for deterministic generation 
- `stroke` - how to stroke the maze 
- `start` - content placed in the start cell  
- `finish` - content placed in the finish cell  

**Returns:** Content containing the rendered maze.

## Algorithm

The maze is generated using a depth-first search (DFS) backtracking algorithm, producing a *perfect maze*. The `seed` ensures deterministic generation: the same parameters always produce the same maze.

## License

[MIT](LICENSE)
