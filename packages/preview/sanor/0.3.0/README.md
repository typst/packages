# Sanor 

Precise animated presentation framework in Typst. 
Check the [manual](./docs/sanor-manual.pdf) for details.

## Examples
Click on the image to jump to the source code.

<table>
  <tr>
    <td><a href="./gallery/example-math.typ"><img src="./gallery/example-math.gif" alt="math animation example"></a></td>
    <td><a href="./gallery/example-case.typ"><img src="./gallery/example-case.gif" alt="example for multiple case display"></a></td>
  </tr>
  <tr>
    <td><a href="./gallery/example-sync.typ"><img src="./gallery/example-sync.gif" alt="Synchronize animation between elements"></a></td>
    <td><a href="./gallery/example-code.typ"><img src="./gallery/example-code.gif" alt="Code animation with comment insertion"></a></td>
  </tr>
  <tr>
    <td><a href="./gallery/example-chem.typ"><img src="./gallery/example-chem.gif" alt="Chemical reaction animation"></a></td>
  </tr>
</table>

Sanor provides a framework for creating highly animated PDF presentations by step-by-step reveal controls over each element in a Typst document. 

## Features

- **Step-by-Step Reveals**: Control content visibility with `pause()` for narrative flow or tagged animations for interactive elements
- **Content Tagging System**: Use `tag()` to mark elements that can be animated, revealed, or transformed
- **Animation Rules**: Apply transformations to the elements with `apply()` (persistent), `once()` (single step), `cover()` (hide), `revert()` (reset), or `clear()` (remove prior modifiers)
- **Reusable Objects**: Create components with `object()` that can have multiple visual states via named cases
- **Cases System**: Define semantic transformations with `case()` that can be referenced by name instead of repeating properties
- **Predefined Components**: Import `mcomps` or `ccomps` for reusable object wrappers that integrate directly with `tag()`.
- **Simultaneous Actions**: Coordinate animations across multiple elements by grouping rules in an array
- **Handout Support**: Generate static handouts from animated presentations with `set-option(handout: true)`
- **Pdfpc Integration**: Integrates Pdfpc functionality from [Polylux](https://github.com/polylux-typ) package.

To demostrate these fearures, take a look at [examples](./docs/example.pdf) file.

## Core Concepts

### Tags & Rules
A **tag** marks content for animation. Rules define what happens to tagged content at each step:
- `tag("name", content)` marks content with a unique identifier
- `apply("name", ...)` applies a transformation from now on (persists across steps)
- `once("name", ...)` applies a transformation for just this step
- `cover("name", ...)` hides content by applying a hidden case
- `revert("name", ...)` resets content to a base state without inheritance
- `clear("name")` resets content to base state and clear all previous modifiers to base case.

### Cases
A **case** is a named transformation that can be applied to content:
- `case(fill: red)` — Styling properties that modify content appearance
- `case(text.with(weight: "bold"))` — Wrapper functions that transform structure
- Cases can be defined when creating objects for reuse: `object(text, red: case(fill: red))`
- Reference cases by name: `apply("elem", "red")` instead of `apply("elem", text.with(fill: red))`

### Objects
An **object** is a reusable component with built-in state management:
- `object(func, case1: case(...), case2: case(...))` — Define multiple named cases
- Objects cache transformations, so multiple `apply()` calls accumulate effects
- Use `revert()` or `cover()` to change behavior between steps

### Animation Workflow
1. Define slide content using 
  ```typst
  #slide(s => ([
    #let tag = tag.with(s)
    // Your content goes here
  ], s))
  ```
  
2. Mark elements with `tag("name", content)` that you want to animate
3. Push animation rules with `s.push()`:
   - Single rule: `s.push(apply("name"))`
   - Multiple rules at once: `s.push((apply("left"), apply("right")))`
   - Advance without animation: `s.push(1)`
4. Each presentation step corresponds to one or more calls to `s.push()`

## Presentation Package Comparison

There are several Typst presentation packages, each with different strengths. Choose Sanor if you need fine-grained animation control and incremental content reveals.

- **Touying**: Sanor provides fine-grained animation controls that are applicable to *any* packages, not only CeTZ or Fletcher. Since Sanor does not inspect content, it can be used with any functions, even in `context` blocks.
- **Touying, Polylux**: You can arrange the steps of the animation of each element **without knowing the subslide index**. Unlike traditional PDF presentation packages that animate contents based on either the subslide index or the position where they are put in the source code, Sanor separates the *declaration* and *animation* of the content: put the content in the code wherever you think it's good, and then animate it later.
- **Presentate**: This functionality is closely related to Presentate's `motion` and `tag` functions. However, the framework provided there cannot interact well with `pause` and has less flexibility (e.g., managing the showing state of the element). So, I implemented it here in a separate package, created specifically for *animations*.

## Installation

Add the package to your Typst project:

```typst
#import "@preview/sanor:0.3.0": *
```

## Quick Start

```typst
#import "@preview/sanor:0.3.0": *

#slide(s => ([
  // A short hand to avoid repeating `s`.
  #let tag = tag.with(s)

  = Hello World
  // Tag an element with a name.
  #tag("title")[This is a presentation slide]
  // Apply it on your slide.
  #s.push(apply("title", text.with(fill: blue)))
], s))
```

## Basic Examples

### Basic Pause Example

Reveal bullet points one at a time:

```typst
#slide(s => ([
  = My Points
  #s.push(1)
  #pause(s, [- First point])
  #s.push(1)
  #pause(s, [- Second point])
  #s.push(1)
  #pause(s, [- Third point])
  #s.push(1)
], s))
```

### Tagging and Animation

Mark content and apply transformations:

```typst
#slide(s => ([
  #let tag = tag.with(s)
  = Animated Content
  
  #tag("title")[Hello World!]
  #tag("subtitle")[Step-by-step animation]
  
  // Step 1: Show title
  #s.push(apply("title", text.with(size: 32pt)))
  
  // Step 2: Show subtitle 
  #s.push(apply("subtitle", text.with(style: "italic")))

  // Step 3: Make the title blue
  #s.push(apply("title", text.with(fill: blue)))
], s))
```

### Using Objects and Cases

Create a reusable component with named states:

```typst
#let fancy-box = object(
  rect,
  normal: case(width: 3cm, height: 2cm, fill: blue),
  highlight: case(width: 3cm, height: 2cm, fill: yellow, stroke: black),
  large: case(width: 5cm, height: 4cm),
)

#slide(s => ([
  #let tag = tag.with(s)
  #tag("box", fancy-box[Content])
  
  #s.push(apply("box", "normal"))
  #s.push(apply("box", "highlight"))
  #s.push(apply("box", "large"))
], s))
```

### Simultaneous Changes

Coordinate animations across multiple elements:

```typst
#slide(s => ([
  #let tag = tag.with(s)
  
  #grid(columns: 2fr, gutter: 1em)[
    #tag("left")[Left item]
  ][
    #tag("right")[Right item]
  ]
  
  // Both appear together
  #s.push((
    apply("left", text.with(fill: red)),
    apply("right", text.with(fill: green)),
  ))
  
  // Both change together
  #s.push((
    once("left", text.with(weight: "bold")),
    once("right", text.with(weight: "bold")),
  ))
], s))
```

### Slide-Level Cases

Define global cases available throughout a slide:

```typst
#slide(
  defined-cases: (
    "error": case(text.with(fill: red, weight: "bold")),
    "success": case(text.with(fill: green, weight: "bold")),
    "highlight": case(block.with(fill: yellow.transparentize(80%))),
  ),
  s => ([
    #let tag = tag.with(s)
    
    #tag("msg1")[Operation completed]
    #tag("msg2")[Check the results]
    
    #s.push(apply("msg1", "success"))
    #s.push(apply("msg2", "highlight"))
  ], s),
)
```

### Handout Mode

Generate a static version showing all steps:

```typst
// Enable handout mode globally
#let (slide,) = set-option(handout: true)

// Now all slides generate multi-page handouts with all steps visible
#slide(s => ([
  #let tag = tag.with(s)
  #tag("content")[This content evolves]
  #s.push(apply("content", text.with(fill: red)))
  #s.push(apply("content", text.with(weight: "bold")))
], s))
```


## Inspiration and Possibilities

The inspiration for the Sanor package came from an amazing animation library for creating mathematical animations in Python called [Manim](https://www.manim.community/).
I always wanted to include such transformation of elements into Typst presentations. This is because Typst provides good defaults for laying out elements; I don't need to specify coordinates or calculate much where to put something on a slide, and Typst packages are awesome (don't you agree?). Moreover, animated PDF files can be opened *anywhere*. I just need a thumb drive and put it on any computer to present my slides. Therefore, based on the UI of Manim, I created this package.

Then, when I started creating some slides with it, I thought of a way to integrate this package with [Tanim](https://github.com/OrangeX4/tanim), a program that lets you create animations from Typst documents. Since the frame-by-frame specification is already implemented, the only remaining (VERY complex) task is to interpolate those discrete animations over a period of time. Since Typst HTML export is starting to mature, I think it is possible to upgrade this package into a tool for animated HTML presentations like [Manim-Slides](https://github.com/jeertmans/manim-slides). 

## Change Log
- **0.3.0** Updated documentation for the new release.
  - Added support for `tag(name, body)` callbacks that receive a non-hidden tagging helper for nested tagging.
  - Documented predefined component imports and usage via `mcomps` and `ccomps`.
  - Updated installation examples and gallery reference snippets for version `0.3.0`.
  - Added magic selector `select` for a smart selector used with show rules.
- **0.2.1** Refractored the whole animation control system.
  - The `slide` function is now accepting a function that returns an array of content and slide context `s => ([body], s)` **breaking change**.
  - The `slide` control is moved to a more favorable `#s.push(rule)` than the `controls` argument, thus `controls` argument is removed. **breaking change**.
  - The `hider` is now named as `hidden`, representing the modifier when the element is hidden **breaking change**.
  - Introduced `case` function that can accept more flexible modifiers.
  - Integrated with `pause` function to incrementally show content without tags and control the flow of animation with `#s.push(int)`.
  - Added `pdfpc` module from Polylux/Touying to support pdfpc integrations.
  - Arguments of `slide` function are renamed as follows:
    - `info` to `options` **breaking change**
    - `defined-states` to `defined-cases` **breaking change**.
- **0.1.0** First Release

## License

MIT License - see LICENSE file for details.

## Contributing

Contributions welcome! Please feel free to submit issues and pull requests.
