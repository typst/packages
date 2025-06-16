# Knowledge-Key
This is a typst template for a compact cheat-sheet.

## Usage
You can use this template in the Typst web app by clicking "Start from template" on the dashboard and searching for `knowledge-key`.
Alternatively, you can use the CLI to kick this project off using the command
```
typst init @preview/knowledge-key
```

Typst will create a new directory with all the files needed to get you started.

## Configuration
This template exports the `ieee` function with the following named arguments:

- `title`: The title of the cheat-sheet
- `authors`: A string of authors

The function also accepts a single, positional argument for the body of the
paper.

The template will initialize your package with a sample call to the `knowledge-key`
function in a show rule. If you want to change an existing project to use this
template, you can add a show rule like this at the top of your file:

```typ
#import "@preview/knowledge-key:1.0.1": *

#show: knowledge-key.with(
  title: [Title],
  authors: "Author1, Author2"
)

// Your content goes below.
```
