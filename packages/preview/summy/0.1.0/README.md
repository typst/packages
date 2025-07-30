# simple-cheatsheet

Simple cheatsheet template for [Typst](https://typst.app/) that allows you to
provide an overview of all coursework in an accessible, low-bloat manner with a focus on legibility and space-efficiency.

## Usage

### Web-app

In the Typst web app dashboard, select "Start from template" and search for `summy`.

Name your project and select Create.

### CLI

To build this project via the CLI, use the command

```
typst init @preview/summy
```

A sample project will be created with the template format.

## Configuration

This template exports the `cheatsheet` function with the following named optional
arguments:


- `title`: Title of document (Default = "")
- `authors`: Author Name (Default = "")
- `write_title`: Writes Title (Default = false)
- `font_size`: Size of font (Default = 5.5pt)
- `line_skip`: Size of line-skip (Default = 5.5pt)
- `x_margin`: Margin on x-axis (Default = 30pt)
- `y_margin`: Margin on y-axis (Default = 0pt)
- `num_columns`: Number of columns (Default = 5)
- `column_gutter`: Space between columns (Default = 4pt)
- `numbered_units`: Numbering of units (Default = false)

To modify an existing project using this template:
1. Import project to top of file
2. Use Show rule to create instance of cheatsheet
3. Add cheatsheet information below (Recommmended to break into separate files for simplicity)

### Example:

```typst
#import "@preview/summy:0.1.0": *

#set page(paper: "a4", flipped: true, margin: 1cm)
#set text(font: "Arial", size: 11pt)

#show: cheatsheet.with(
  title: "Cheatsheet Title", 
  authors: "Authors",
  write_title: false,
  font_size: 5.5pt,
  line_skip: 5.5pt,
  x_margin: 30pt,
  y_margin: 30pt,
  num_columns: 5,
  column_gutter: 4pt,
  numbered_units: false,
)

#include "units/00-general-formula.typ"
#include "units/01-lorem-ipsum.typ"
#include "units/02-lorem-ipsum.typ"

```

### Sub-files:
Subfiles are an organizational tool to separate various sections, to make it easier to organize.

Each new section is separated by a single heading and subsections are represented by subheadings as below:

```typst
= Trigonometry
Lorem Ipsum

== Sin Law

== Cosine law
```