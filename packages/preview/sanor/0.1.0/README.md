# Sanor

Fast, small, but powerful presentation framework in Typst.

Sanor is a Typst package that provides utilities for creating animated presentations with incremental content reveals, state management, and flexible slide controls.

## Features

- **Incremental Reveals**: Show content step by step with `apply()`, `once()`, and `clear()` functions
- **Content Tagging**: Use `tag()` to mark content that can be animated
- **Object System**: Create reusable objects with different states using `object()`
- **Slide Controls**: Define animation sequences with the `slide()` function
- **Handout Support**: Generate static handouts from animated presentations
- **Subslide Management**: Handle multiple slides within a single frame

## Presentation Package Comparison

There are several Typst presentation packages, and Sanor is designed specifically for animated, stepwise slide control.

| Package | Best fit | Sanor comparison |
| --- | --- | --- |
| `Sanor` | Animated presentations with incremental reveals and stateful slide content | Uses `slide()`, `tag()`, `apply()`, `once()`, and object states to keep presentation logic explicit and reusable. |
| `Touying` | Lightweight slide decks with straightforward page-based slide definitions | Typically simpler than Sanor, with fewer built-in animation primitives. Sanor is stronger when you need fine-grained reveal control and custom state changes. |
| `Polylux` | Design-oriented, theme-focused presentations | Often targeted at polished layout and visual styling. Sanor is more focused on dynamic behavior and step-by-step content sequencing rather than prebuilt visual themes. |
| `presentate` | General Typst presentation framework with slide scaffolding | Usually provides a higher-level slide structure and convenience defaults. Sanor offers more explicit animation controls and handout support for presentations that evolve over multiple steps. |

Use Sanor when your presentation needs incremental content reveals, reusable tagged content, or handout generation. Use `Touying`, `Polylux`, or `presentate` when you prefer a different slide abstraction, default theme, or simpler static deck workflow.

## Installation

Add the package to your Typst project:

```typst
#import "@preview/sanor:0.1.0": *
```

## Quick Start

```typst
#import "@preview/sanor:0.1.0": *

#slide(
  s => {
    let tag = tag.with(s)
    tag("title")[= Hello World]
    tag("content")[This is my first animated slide!]
  },
  controls: (
    once("title"),  // Show title once
    apply("content"),  // Then show content
  ),
)
```

## API Reference

### Core Functions

#### `slide(info: (:), func, controls: (), hider: superhide, is-shown: false, defined-states: (:))`

Creates an animated slide with the specified controls.

- `func`: Function that takes slide info and returns the slide content
- `controls`: Array of control commands defining the animation sequence
- `hider`: Function to hide content (default: `superhide`)
- `is-shown`: Whether to show hidden content by default (default: `false`)
- `defined-states`: Predefined states for tagged content

#### `tag(s, name, body, hider: auto, ..cases)`

Tags content for animation control.

- `s`: Slide context (provided by `slide()`)
- `name`: Unique identifier for the tagged content
- `body`: Content to tag (can be text, elements, or objects)
- `hider`: Hide function (auto uses slide's hider)
- `..cases`: Additional state cases for the content

#### `apply(name, ..modifier-cases)`

Applies a modifier to tagged content for the current and subsequent steps.

- `name`: Tag name to apply to
- `..modifier-cases`: Modifiers or state names to apply

#### `once(name, ..modifier-cases)`

Applies a modifier to tagged content for only one step.

- `name`: Tag name to apply to
- `..modifier-cases`: Modifiers or state names to apply

#### `clear(name)`

Removes all modifiers from tagged content.

- `name`: Tag name to clear

#### `cover(name)` and `revert(name)`

Convenience functions:
- `cover(name)`: Equivalent to `apply(name, "hidden")`
- `revert(name)`: Equivalent to `apply(name, "__base__")`

### Object System

#### `object(func, ..modify-cases)`

Creates an object with different states.

- `func`: Base function to create the object
- `..modify-cases`: Named arguments defining different states

## Examples

For comprehensive examples demonstrating all features of Sanor, see [`docs/example.typ`](docs/example.typ). This file contains a complete presentation showcasing:

- Basic animations with `apply()` and `once()`
- Content modification and styling
- Object system with state management
- Complex multi-element animations
- Code and mathematical content presentation
- Custom states and simultaneous changes
- Handout mode generation

You can compile the examples with:

```bash
typst compile docs/example.typ
```

### Basic Animation

```typst
#slide(
  s => {
    let tag = tag.with(s)
    tag("title")[= Presentation Title]
    tag("point1")[- First point]
    tag("point2")[- Second point]
    tag("point3")[- Third point]
  },
  controls: (
    once("title"),
    apply("point1"),
    apply("point2"),
    apply("point3"),
  ),
)
```

### Content Modification

```typst
#slide(
  s => {
    let tag = tag.with(s)
    tag("equation", $ E = m c^2 $)
  },
  controls: (
    apply("equation"),
    apply("equation", it => {
      show "E": set text(fill: red)
      it
    }),
  ),
)
```

### Using Objects

```typst
#let my-box = object(
  rect,
  normal: (fill: blue),
  highlighted: (fill: yellow),
  hidden: (stroke: none, fill: none)
)

#slide(
  s => {
    let tag = tag.with(s)
    tag("box", my-box[Normal Box])
  },
  controls: (
    apply("box"),
    apply("box", "highlighted"),
  ),
)
```

### Handouts

```typst
// for globally set handout mode
#let (slide,) = set-option(handout: true) 

// for setting handout mode per-slide
#slide(
  info: (handout: true),
  s => { /* slide content */ },
  controls: (/* controls */),
)
```

## Advanced Usage

### Custom States

```typst
#slide(
  s => {
    let tag = tag.with(s)
    tag("text", [Hello], faded: text.with(fill: gray))
  },
  defined-states: (
    faded: text.with(fill: gray),
  ),
  controls: (
    apply("text"),
    apply("text", "faded"),
  ),
)
```

### Complex Animations

```typst
#slide(
  s => {
    let tag = tag.with(s)
    tag("diagram", cetz.canvas({ /* diagram code */ }))
  },
  controls: (
    apply("diagram"),
    apply("diagram", it => {
      cetz.draw.rotate(45deg)
      it
    }),
    revert("diagram"),
  ),
)
```

## License

MIT License - see LICENSE file for details.

## Contributing

Contributions welcome! Please feel free to submit issues and pull requests.
