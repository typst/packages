# cram-snap 

Simple cheatsheet template for [Typst](https://typst.app/) that allows you to snap a quick picture of essential information and cram it into a useful cheatsheet format.

## Usage

You can use this template in the Typst web app by clicking "Start from template" on the dashboard and searching for `cram-snap`.

Alternatively, you can use the CLI to kick this project off using the command

```
typst init @preview/cram-snap
```

Typst will create a new directory with all the files needed to get you started.

## Configuration

This template exports the `cram-snap` function with the following named arguments:
- `title`: Title of the document
- `subtitle`: Subtitle of the document
- `icon`: Image that appears next to the title
- `column-number`: Number of columns

If you want to change an existing project ot use this template, you can add a show rule like this at the top of your file:

```typst
#import "@preview/cram-snap:0.1.0": *

#set page(paper: "a4", flipped: true, margin: 1cm)
#set text(font: "Arial", size: 11pt)

#show: cram-snap.with(
  title: [Cheatsheet],
  subtitle: [Cheatsheet for an amazing program],
  icon: image("icon.png"),
  column-number: 3,
)

#table(
    table.header[Great heading],
    [Closing the program], [Type `:q`]    
)
```
