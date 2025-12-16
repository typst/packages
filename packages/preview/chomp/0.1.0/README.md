# Chomp

This dead-simple, small utility _chomps_ on a text input but iteratively shortening it until its content fits within
the specified size constraints.

It can take a `content`-producing function and shortens the output until the produced content fits.

NOTE: No clever optimisation has been undertaken. It works simply by shortening the string by one character at a time and seeing if it fits.
It terminates when the content fits, or panics if it cannot be made to fit.

Hopefully a more performant way of doing this is developed in the future.

## Usage

```typ
#import "@preview/chomp:0.1.0": truncate-to-fit

// Set up example page
#set page(width: 100pt, height: auto, margin: 1mm)
#let s = lorem(50)

#truncate-to-fit(s, height: 2em, suffix: "...")

// Alternatively you can pass in a function which renders the content
#let renderer(color, s) = {
    circle(stroke: color)[
      #set align(center + horizon)
      #s
    ]
}

#truncate-to-fit(
  s,
  func: renderer.with(red),
  height: 5em,
  suffix: "...",
)

// Full function signature
// Prefix is added and an error is raised if truncation would start eating into it
// This example below is constrained by the width in practice, but both width and height can be given.
// The output is the first that fits within both constraints.
#truncate-to-fit(
  s,
  func: renderer.with(blue),
  height: 7em,
  width: 6em,
  prefix: "Start: ",
  suffix: "...",
)
```

Which produces:

![Output](./demo.svg)
