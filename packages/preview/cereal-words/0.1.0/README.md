# cereal-words
Oh no, the Typst guys jumbled the letters! Bring order into this mess by finding the hidden words.

This small game is playable in the Typst editor and best enjoyed with the web
app or `typst watch`. It was first released for the 24 Days to Christmas
campaign in winter of 2023.

## Usage
You can use this template in the Typst web app by clicking "Start from template"
on the dashboard and searching for `cereal-words`.

Alternatively, you can use the CLI to kick this project off using the command
```
typst init @preview/cereal-words
```

Typst will create a new directory with all the files needed to get you started.

## Configuration
This template exports the `game` function, which accepts a single positional argument for the game input.

The template will initialize your package with a sample call to the `game`
function in a show rule. If you  want to change an existing project to use this
template, you can add a show rule like this at the top of your file:

```typ
#import "@preview/cereal-words:0.1.0": game
#show: game

// Type the words here
```
