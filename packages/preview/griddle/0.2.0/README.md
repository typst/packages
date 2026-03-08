# Griddle

<a href="https://github.com/typst/packages/tree/main/packages/preview/griddle" style="text-decoration: none;"><img src="https://img.shields.io/badge/typst-package-239dad?style=flat" alt="Typst package Griddle" /></a>
<a href="https://www.gnu.org/licenses/gpl-3.0.en.html" style="text-decoration: none;"><img src="https://img.shields.io/badge/license-GPLv3-brightgreen?style=flat" alt="License GPLv3.0" /></a>

A customizable tool for designing and visualizing **crossword puzzles** in [Typst](https://typst.app/).
The name _"Griddle"_ mixes _"grid"_ and _"riddle"_, which kinda fit the idea of a crossword puzzle. ✏️

![An example of what can be obtained with Griddle](docs/example_init.png)

<details>
  <summary><i><u>See the code for this example</u></i></summary>

```typ
#import "@preview/griddle:0.2.0": *

#let cw = load-crossword(yaml("../examples/data_init.yaml"))

= #h(10pt) A Simple Crossword Example

#table(columns: (auto, 1fr), stroke: none, inset: 10pt,
	[
		#show-schema(cw.schema, 
		cell-fill: auto, 
		wall-fill: gradient.linear(..color.map.crest, relative: "parent", angle: -15deg),
		)
	],
	[
		#v(2em)
		== Across
		#show-definitions(cw.definitions.across)
		== Down
		#show-definitions(cw.definitions.down)
	]
)
```
</details>

## Usage
_Griddle_ comes with three main functionalities: 
1. a function to **load your crossword** from a YAML file;
2. a second function to **visualize the grid**;
3. and a third function for **printing the definitions**.

As long as your YAML file is well-formatted, using _Griddle_ is as simple as writing three function calls in your Typst document.

### 1. Writing the data file
The words and their relative definitions and positions must be defined in a single file with the [YAML](https://en.wikipedia.org/wiki/YAML) format. This file should contains a list of entries for the crossword puzzle, and may be structured in two ways:
- as a **flat list of entries**, each of one specifying the direction of the word in the grid;
- or **grouped into two lists** of entries, associated respectively with _across_ (horizontal) and _down_ (vertical) definitions.

Here are two examples of the same crossword definitions structured in both ways:

```yaml
# File `data_flat.yaml`
# Entries are listed with no particular structure nor order.
- {number: 1, row: 0, col: 3, direction: "down", word: noodles, definition: 'Long, thin pieces of cooked dough'}
- {number: 2, row: 0, col: 5, direction: "down", word: ukulele, definition: 'A small four-string instrument'}
- {number: 3, row: 1, col: 3, direction: "across", word: oak, definition: 'A strong tree with hard wood'}
- {number: 4, row: 2, col: 1, direction: "down", word: bread, definition: 'Baked food made from flour and water'}
- {number: 5, row: 3, col: 0, direction: "across", word: griddle, definition: 'A Typst package for crossword puzzles', solved: true}
- {number: 6, row: 5, col: 0, direction: "across", word: wave, definition: 'A moving swell of water or a hand gesture'}
```
In the example above, notice how each entry has to specify the `direction` of the word in the grid. In the next example, this information is written once at the beginning of each group:

```yaml
# File `data_grouped.yaml`
# Entries are grouped in two sets, based on their direction.
across:
  - {number: 3, row: 1, col: 3, word: oak, definition: 'A strong tree with hard wood'}
  - {number: 5, row: 3, col: 0, word: griddle, definition: 'A Typst package for crossword puzzles', solved: true}
  - {number: 6, row: 5, col: 0, word: wave, definition: 'A moving swell of water or a hand gesture'}
down:
  - {number: 1, row: 0, col: 3, word: noodles, definition: 'Long, thin pieces of cooked dough'}
  - {number: 2, row: 0, col: 5, word: ukulele, definition: 'A small four-string instrument'}
  - {number: 4, row: 2, col: 1, word: bread, definition: 'Baked food made from flour and water'}
```

As it can be observed, each entry is composed by some mandatory and optional fields:
- `number`: *(mandatory)* the number of the entry in the grid, used to associate the word to its definition.
- `row`: *(mandatory)* the row-index of the word starting cell in the grid. Indices in the grid start from 0 in both horizontal and vertical directions.
- `col`: *(mandatory)* the column-index of the word starting cell in the grid.
- `word`: *(mandatory)* the string containing the word of this entry.
- `definition`: *(mandatory for now, might become optional in the future)* the string containing the description/riddle for this entry.
- `solved`: *(optional; default: false)* a boolean flag indicating whether this entry is already solved in the puzzle (i.e. the schema would show its letters) or not.


### 2. Loading the crossword puzzle
To load the crossword data into your Typst document, use the `load-crossword` function from the _Griddle_ library:
```typ
#import "@preview/griddle:0.2.0": load-crossword

#let cw = load-crossword(yaml("path/to/data.yaml"))
```

This functions requires in input the data read from your YAML file. It is mandatory to pass the content of the file as a **YAML data structure**, which can be done using the [`yaml()`](https://typst.app/docs/reference/data-loading/yaml/) function in Typst.

The `load-crossword` function returns a data structure with the following fields:

```yaml
cw: the whole crossword data; 
  ☼ schema: represents the "table" with cells and walls (dictionary);
    - rows: the number of rows in the schema (int);
    - cols: the number of columns in the schema (int);
    - grid: the content of each cell of the grid, as a flat array;
  ☼ definitions: (dictionary);
    - across: the list of horizontal entries;
    - down: the list of vertical entries.
```

This data structure contains all the information needed to visualize the crossword schema and definitions in your document. This means that _Griddle_ processes your data file **only once**, allowing the user to call the visualization functions multiple time in their document with no processing downtime. 

### 3. Visualizing the schema

To visualize the schema of your crossword, just call the `show-schema` function where you want it to appear in your document. 

```typ
#import "@preview/griddle:0.2.0": show-schema
// [... Load the crossword data as before ...]
= Crossword
#show-schema(cw.schema)
```

This function requires the `schema` field of your crossword data structure as input, and produces a grid with the letters of the solved entries and empty cells for the unsolved ones.
The grid is automatically styled to have a standard size, but you can customize it by passing additional parameters to the function.

```typ
#show-schema(cw.schema, cell-fill: yellow, cell-stroke: green + 2pt, wall-fill: none, wall-stroke: none)
```
You can compare the two versions in the following figures:

| Default style | "Fancy" style |
| :---: | :---: |
|<img src="docs/example_mini.png" alt="drawing" width="200"/> | <img src="docs/example_mini_fancy.png" alt="drawing" width="200"/> | 

The `show-schema` functionality accepts the following parameters:

- `cell-size` *(pair of lenghts):* This parameter allows you to set the size of each cell in the grid, by editing the width and height of the cells. The default value is `(24pt, 24pt)`, which is a good size for most crosswords. If the value `(1fr, 1fr)` is chosen, the grid would cover the whole page.

- `cell-fill` *(color or gradient):* The color of the cells that have to be filled. Default value is `none`, which corresponds to the page background.

- `cell-stroke` *(color, length):* The style of the cells border. Default value is `black + 1pt`.

- `wall-fill` *(color or gradient):* The color or gradient used to fill the "blocked" cells in the grid. It is `black` by default.

- `wall-stroke` *(color, length):* The style of the wall-cells border. Default value is equal to letter-cells' border: `black + 1pt`.

- `solved` *(bool):* A boolean flag used to solve the grid by filling each cell with the correct letter. This is commonly used for debug purposed when creating the puzzle.

### 4. Printing the definitions
To print the definitions of your crossword, you can use the `print-definitions` function. This function takes a list of entries of your crossword data structure as input and prints each of them in a nicely formatted way.

Notice that, in order to print all the definitions, you would call the function on both the `cw.definitions.across` and `cw.definitions.down` fields of your crossword data structure.

```typ
#import "@preview/griddle:0.2.0": show-definitions
// [... Load the crossword data as before ...]
== Across
#show-definitions(cw.definitions.across)
== Down
#show-definitions(cw.definitions.down)
```

The `show-definitions` function automatically formats the entries in an **ordered list**, with the number of the entry and its definition. It also changes the style of the definition text based on whether the entry is solved or not, adding a strikethrough effect to the solved entries and the solution word next to the definition.

## Gallery

### Example 1
Here is a complete example of a Typst document using _Griddle_ to visualize a crossword puzzle:

```typ
#import "@preview/griddle:0.2.0": *

#let cw = load-crossword(yaml("path/to/data.yaml"))
// Data file is the one from the previous examples

#show heading.where(level: 1): set align(center)
#show table: set align(center)

= Crossword
#v(20pt)
#show-schema(cw.schema, wall-fill: none, wall-stroke: none)

== Across #emoji.arrow.r
#show-definitions(cw.definitions.across)
== Down #emoji.arrow.b
#show-definitions(cw.definitions.down)
```
![The complete example from before](docs/example1.png)

### Example 2
Here's another example, with another data file and some customizations.

```yaml
# File `data.yaml`
across:
  - {number: 2, row: 0, col: 2, word: elk, definition: 'You can ride one in "The Legend of Zelda: Breath of the Wild"'}
  - {number: 5, row: 1, col: 0, word: ar, definition: 'New "space" for immersive games (Abbr.)'}
  - {number: 7, row: 1, col: 3, word: ur, definition: 'Recent trend in visually stunning games (Abbr.)'}
  - {number: 8, row: 2, col: 0, word: mario, definition: 'Red cap wearer'}
  - {number: 9, row: 3, col: 0, word: if, definition: 'Simple conditional statement, in most programming languages'}
  - {number: 10, row: 3, col: 3, word: go, definition: 'Word that follows "3, 2, 1..." in many racing game'}
  - {number: 11, row: 4, col: 1, word: tail, definition: "Sonic's friend has two of them, for one"}
down:
  - {number: 1, row: 0, col: 0, word: fami, definition: "First word of the NES's Japanese name"}
  - {number: 3, row: 0, col: 3, word: luigi, definition: "[8-Across]'s brother"}
  - {number: 4, row: 0, col: 4, word: krool, definition: "Evil crocodile in the \"Donkey Kong\" series"}
  - {number: 6, row: 1, col: 1, word: raft, definition: "You can ride one in \"Super Mario Party\""}
# Original schema from the Open-Crossword project by Alexis Andrew Martel.
```

```typ
#import "@preview/griddle:0.2.0": *

#let cw = load-crossword(yaml("path/to/data.yaml"))

#show heading.where(level: 1): set align(center)
#set text(font: "Arial")

#heading(level: 1)[Videogame-themed Crossword]
#v(1em)
Here is the same crossword schema in three different styles: the default one, with rainbow walls, and with a solved state.
#table(columns: (1fr,)*3, rows: 1, stroke: none, align: left, inset: 0pt,
	show-schema(cw.schema), // Default
	show-schema(cw.schema, wall-fill: gradient.conic(..color.map.rainbow, angle: -60deg)), // With fancy rainbow gradient
	show-schema(cw.schema, cell-fill: lime.lighten(80%), solved: true) // solved
	)

#table(columns: 2, rows: 1, stroke: none, inset: 0pt, gutter: 20pt,
	[
		== Across
		#show-definitions(cw.definitions.across)
	],
	[
		== Down
		#show-definitions(cw.definitions.down)
	]
)
```

![The 'crossword16' schema from the Open-Crossword project by Alexis Andrew Martel](docs/example_crossword16.png)

**Credits**: this puzzle was created by [Alexis Andrew Martel](https://github.com/alexis-martel) and is contained in the [Open-Crossword project](https://github.com/alexis-martel/Open-Crossword) repository on GitHub ([`crossword16`](https://github.com/alexis-martel/Open-Crossword/blob/master/data/puzzles/crossword16.json)), licensed under the _GNU General Public License v3.0 (GPL-3.0)_.

### Example 3
A more complex example of a crossword puzzle within a 30x30 grid, easily build and rendered with _Griddle_ in Typst:

![A more complex example of a 30x30 grid](docs/example3.png)

In this example definitions are not provided. The schema is rendered with default style. 

### Example 4
And finally, here is an example of the famous [Sator Square](https://en.wikipedia.org/wiki/Sator_Square) crossword, which is a 5x5 grid with the same words in both horizontal and vertical directions. The inscription _"Sator arepo tenet opera rotas"_ is a five-word palindrome in Latin, meaning "The farmer Arepo holds the wheels with care".

```typ
#import "@preview/griddle:0.2.0": *

#let cw = load-crossword(yaml("path/to/data.yaml"))

// We set the `solved` flag as true, in order to see the grid filled
#show-schema(cw.schema, solved: true)
```

```yaml
# In this example, the entries are listed in a flat structure. Furthermore, in order to have both horizontal and vertical entries, the same word is listed twice, once for each direction.
- {number: 1, row: 0, col: 0, direction: horizontal, word: sator, definition: ""}
- {number: 1, row: 0, col: 0, direction: vertical, word: sator, definition: ""}
- {number: 2, row: 1, col: 0, direction: horizontal, word: arepo, definition: ""}
- {number: 2, row: 0, col: 1, direction: vertical, word: arepo, definition: ""}
- {number: 3, row: 2, col: 0, direction: horizontal, word: tenet, definition: ""}
- {number: 3, row: 0, col: 2, direction: vertical, word: tenet, definition: ""}
- {number: 4, row: 3, col: 0, direction: horizontal, word: opera, definition: ""}
- {number: 4, row: 0, col: 3, direction: vertical, word: opera, definition: ""}
- {number: 5, row: 4, col: 0, direction: horizontal, word: rotas, definition: ""}
- {number: 5, row: 0, col: 4, direction: vertical, word: rotas, definition: ""}
```

![The classical latin square "Sator arepo tenet opera rotas"](docs/example_sator.png)


## License
This package is released under the GNU General Public License v3.0 (GPL-3.0). You can find the full license text in the [LICENSE](LICENSE) file.

## Contributing
If you want to contribute to this project, feel free to open an **issue** or a **pull request** on the [GitHub repository](https://github.com/micheledusi/Griddle).

If you use this package to create something that deserves to be shared with the world, let me know! I'd be glad to add your work to this gallery.

### Credits
This package is created by [Michele Dusi](https://github.com/micheledusi).
