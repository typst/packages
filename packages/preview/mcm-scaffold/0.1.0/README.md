# mcm-scaffold
This is a Typst template for COMAP's Mathematical Contest in MCM/ICM.

## Usage
You can use this template in the Typst web app by clicking "Start from template"
on the dashboard and searching for `mcm-scaffold`.

Alternatively, you can use the CLI to kick this project off using the command
```
typst init @preview/mcm-scaffold
```

Typst will create a new directory with all the files needed to get you started.

## Configuration
This template exports the `mcm` function with the following named arguments:

- `title`: The paper's title as content.
- `problem-chosen`: The problem your team have chosen.
- `team-control-number`: Your team control number.
- `year`: When did the competition took place.
- `summary`: The content of a brief summary of the paper. Appears at the top of the first column in boldface.
- `keywords`: Keywords of the paper.
- `magic-leading`: adjust the leading of the summary.

The function also accepts a single, positional argument for the body of the
paper.

The template will initialize your package with a sample call to the `mcm`
function in a show rule. If you want to change an existing project to use this
template, you can add a show rule like this at the top of your file:

```typ
#import "@preview/mcm-scaffold:0.1.0": *

#show: mcm.with(
  title: "A Simple Example for MCM/ICM Typst Template",
  problem-chosen: "ABCDEF",
  team-control-number: "1111111",
  year: "2025",
  summary: [
    #lorem(100)
    
    #lorem(100)
    
    #lorem(100)

    #lorem(100)
  ],
  keywords: [MCM; ICM; Mathemetical; template],
  magic-leading: 0.65em,
)

// Your content goes below.
```