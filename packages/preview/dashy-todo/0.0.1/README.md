# Dashy TODO

Create TODO comments, which are displayed at the sides of the page.

![Screenshot](example.svg)

## Usage

The package provides a `todo(message, position: auto | left | right)` method. Call it anywhere you need a todo message.

```typst
#import "@preview/dashy-todo:0.0.1": todo

// It automatically goes to the closer side (left or right)
A todo on the left #todo[On the left].

// You can specify a side if you want to
#todo(position: right)[Also right]

// You can add arbitrary content
#todo[We need to fix the $lim_(x -> oo)$ equation. See #link("https://example.com")[example.com]]

// And you can create an outline for the TODOs
#outline(title: "TODOs", target: figure.where(kind: "todo"))
```

## Styling

You can modify the text by wrapping it, e.g.:

```
#let small-todo = (..args) => text(size: 0.6em)[#todo(..args)]

#small-todo[This will be in fine print]
```