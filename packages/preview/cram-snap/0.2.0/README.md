# cram-snap

Simple cheatsheet template for [Typst](https://typst.app/) that allows you to
snap a quick picture of essential information and cram it into a useful
cheatsheet format.

## Usage

You can use this template in the Typst web app by clicking "Start from template"
on the dashboard and searching for `cram-snap`.

Alternatively, you can use the CLI to kick this project off using the command

```
typst init @preview/cram-snap
```

Typst will create a new directory with all the files needed to get you started.

## Configuration

This template exports the `cram-snap` function with the following named
arguments:

- `title`: Title of the document
- `subtitle`: Subtitle of the document
- `icon`: Image that appears next to the title
- `column-number`: Number of columns

The `theader` function is a wrapper around the `table.header` function that
creates a header and takes `colspan` as argument to span the header across
multiple table columns (by default it spans across two)

If you want to change an existing project to use this template, you can add a
show rule like this at the top of your file:

```typst
#import "@preview/cram-snap:0.2.0": *

#set page(paper: "a4", flipped: true, margin: 1cm)
#set text(font: "Arial", size: 11pt)

#show: cram-snap.with(
  title: [Cheatsheet],
  subtitle: [Cheatsheet for an amazing program],
  icon: image("icon.png"),
  column-number: 3,
)

// Use it if you want different table columns (the default are: (2fr, 3fr))
#set table(columns: (2fr, 3fr, 3fr))

#table(
  theader(colspan: 3)[Great heading that is really looooong],
  [Closing the program], [Type `:q`], [You can also type `QQ`]
)
```
