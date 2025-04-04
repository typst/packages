# Noteworthy

Noteworthy is a Typst template designed for creating class notes, especially for mathematics. This 
template provides a structured and visually appealing format for documenting mathematical concepts, 
theorems, proofs, and examples.

## Features

- Customizable document metadata (title, author, contact details)
- Automatic table of contents generation
- Support for various mathematical environments (theorems, proofs, definitions, examples, notes, exercises, solutions)
- Configurable page settings (header, footer, paper size)
- Customizable text settings (font, size, language)

## Installation

You can use this template in the Typst web app by clicking "Start from template" on the dashboard
and searching for noteworthy.

Alternatively, you can use the CLI to kick this project off using the command:

```bash
typst init @preview/noteworthy:0.1.0
```

## Usage

1. Open the `main.typ` file and customize the content as needed.
2. Run the Typst compiler to generate the PDF:
```bash
typst compile main.typ
```

## Environments

This template provides some environments with the help of [theoretic](https://github.com/nleanba/typst-theoretic) package.

Please refer the sample code below for using those environments:

```typst
#definition[
    An important definition
]

#example[
    Here is an example
]

#theorem(title = "Pythagoras Theorem")[
    $"Base"^2 + "Perpendicular"^2 = "Hypotenuse"^2$
]
#note[
    A very important note to remember
]
#exercise[
    Solve it carefully
]
#solution[
    Here is a detailed solution...
]
```

## Acknowledgements

- [Typst](https://typst.app/)
- [theoretic](https://github.com/nleanba/typst-theoretic)
- [Showybox](https://github.com/Pablo-Gonzalez-Calderon/showybox-package)