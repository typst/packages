# badformer
Reach the goal in this retro-inspired wireframing platformer. Play in 3
dimensions and compete for the lowest number of steps to win!

This small game is playable in the Typst editor and best enjoyed with the web
app or `typst watch`. It was first released for the 24 Days to Christmas
campaign in winter of 2023.

## Usage
You can use this template in the Typst web app by clicking "Start from template"
on the dashboard and searching for `badformer`.

Alternatively, you can use the CLI to kick this project off using the command
```
typst init @preview/badformer
```

Typst will create a new directory with all the files needed to get you started.

Move with WASD and jump with space. You can also display a minimap by pressing
E.

## Configuration
This template exports the `game` function, which accepts a positional argument
for the game input.

The template will initialize your package with a sample call to the `game`
function in a show rule. If you want to change an existing project to use this
template, you can add a show rule like this at the top of your file:

```typ
#import "@preview/badformer:0.1.0": game
#show: game(read("main.typ"))

// Move with WASD and jump with space.
```
