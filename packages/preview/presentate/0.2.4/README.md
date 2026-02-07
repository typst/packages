# Presentate
**Presentate** is a package for creating presentation in Typst. It provides a framework for creating dynamic animation that is compatible with other packages. 
For usage, please refer to [demo.pdf](https://github.com/pacaunt/typst-presentate/blob/main/assets/docs/demo.pdf)


## Simple Usage 
Import the package with 
```typst
#import "@preview/presentate:0.2.4": *
```
and then, the functions are automatically available. 

### Creating slides 
You can create a slide using `slide` function. For simple animation, you can use `pause` function to show show some content later.
The easiest is to type `#show: pause`. For example,
```typst
#set page(paper: "presentation-16-9")
#set text(size: 25pt)

#slide[
  Hello World!
  #show: pause;

  This is `presentate`.
]
```

which results in 
<img alt="example1" src="https://github.com/user-attachments/assets/8bc0d428-cf3f-4e49-96b2-093cbbf10e2e" />

You can style the slides as you would do with normal Typst document. For example, 

```typst
#set page(paper: "presentation-16-9")
#set text(size: 25pt, font: "JetBrainsMono NF")
#set align(horizon)

#slide[
  = Welcome to Presentate! 
  \
  A lazy author \
  #datetime.today().display()
]

#set align(top)

#slide[
  == Tips for Typst.

  #set align(horizon)
  Do you know that $pi != 3.141592$?

  #show: pause 
  Yeah. Certainly.

  #show: pause 
  Also $pi != 22/7$.
]
```

<img alt="example2" src="https://github.com/pacaunt/typst-presentate/blob/main/assets/examples/example2.png" />

### Relative Index Specification 
You can use `none` and `auto`, or even `(rel: int)` to specify the index as *with previous animation*, *after previous animation*, or `int` subslides away from the current number of pauses.
```typ
// Set the cover functions to see the effect better.
#let grayed = text.with(fill: gray.transparentize(50%))

#let pause = pause.with(hider: grayed)
#let uncover = uncover.with(hider: grayed)

#slide[
  = Relative `auto`, `none`, and `(rel: int)` Indices

  This is present first

  #show: pause

  #only(auto)[This came later, but *not* preserve space.]
  _This will shift. $->$_

  #uncover(none)[This comes with current `pause`.]

  #pause[This is the second `pause`.]

  #pause[This is the third `pause`]

  #uncover((rel: -1), [But This come before.])
]
```

<img alt="image" src="https://github.com/pacaunt/typst-presentate/blob/main/assets/examples/exampleAuto.png" />

### Varying Timeline
You can specify the `update-pause` argument of dynamic functions to tell if that function will update the current number of pause or not. If set to `true`, the number of pauses will set to that value. 

This is useful for modifying steps of the animation so that some contents appear with or after another. 
One application is for showing contents in sync: 

```typst
#slide[
  = Content in Sync
  #table(columns: (1fr, 1fr), stroke: 1pt)[
    First

    #show: pause;
    I am

    #show: pause;

    in sync.
  ][
    // `[]` is a dummy content.
    #uncover(1, [], update-pause: true)
    Second

    #show: pause;
    I am

    #show: pause;

    in sync.
    
    #show: pause 
    Heheh
  ]
]
```

<img alt="image" src="https://github.com/user-attachments/assets/cfff30c3-eae0-4d8c-bcec-3d891368d662" />


### Motion Control

You can have a precise control on what should be shown on each subslide relatively without worring about their order in definition code by using `#motion` function, and tag by a unique name for each contents in `#tag` function. For example, 

```typst
#import "@preview/cetz:0.4.2": canvas, draw

#slide[
  = Drawing A Fan
  #set align(center + horizon)
  #motion(
    s => [
      #canvas({
        import draw: *
        scale(3)
        tag(s, "filled", hider: it => none, stroke(red + 5pt))
        tag(s, "arc", arc((0, 0), start: 30deg, stop: 150deg, name: "R"))
        tag(s, "line1", line("R.start", "R.origin"))
        tag(s, "line2", line("R.end", "R.origin"))
      })
    ],
    hider: draw.hide.with(bounds: true),
    controls: (
      "line2.start",
      "line1.start",
      "arc.start",
      "filled.start"
    ),
  )
]
```
<img alt="Motion Function Demonstration" src="https://github.com/pacaunt/typst-presentate/blob/main/assets/examples/exampleMotion.png">

In this example, featured with CeTZ package, each element is drawn normally, while its animation is shown differently. The precise animation control is done by specifying the tagged names in `controls` argument of `#motion` function. Note that the way of showing and hiding stuff can be modified using `hider` argument of each function.


### Package Integration 

Use can use the `render` function to create a workspace, and import the `animation` module of Presentate to create animation with other packages. 
For example, Integration with [CeTZ](https://typst.app/universe/package/cetz) and [Fletcher](https://typst.app/universe/package/fletcher)  
```typst
#import "@preview/cetz:0.4.2": canvas, draw
#import "@preview/fletcher:0.5.8": diagram, edge, node

#slide[
  = CeTZ integration
  #render(s => ({
      import animation: *
      let (pause,) = settings(hider: draw.hide.with(bounds: true))
      canvas({
        import draw: *
        pause(s, circle((0, 0), fill: green))
        s.push(auto) // update s
        pause(s, circle((1, 0), fill: red))
      })
    },s)
  )
]

#slide[
  = Fletcher integration
  #render(s => ({
    import animation: *
    diagram($
        pause(#s, A edge(->)) #s.push(auto)
          & pause(#s, B edge(->)) #s.push(auto)
            pause(#s, edge(->, "d") & C) \
          & pause(#s, D)
    $,)
  }, s,))
]
```
Results: 

<img alt="image" src="https://github.com/user-attachments/assets/971a4739-1c13-45f6-9699-308760dc34d9" />

You can incrementally show the content from other package by wrap the functions in the `animate` function, with a modifiers that modifies the function's arguments to hide the content using `modifier`. 
For example, this molecule animation is created compatible with [Alchemist](https://typst.app/universe/package/alchemist) package: 

```typst
#import "@preview/alchemist:0.1.8" as alc

#let modifier(func, ..args) = func(stroke: none, ..args) // hide the bonds with `stroke: none`
#let (single,) = animation.animate(modifier: modifier, alc.single)
#let (fragment,) = animation.animate(modifier: (func, ..args) => func(colors: (white,),..args), alc.fragment) // set atom colors to white

#slide[
  = Alchemist Molecules
  #render(s => ({
      alc.skeletize({
        fragment(s, "H_3C")
        s.push(auto)
        single(s, angle: 1)
        fragment(s, "CH_2")
        s.push(auto)
        single(s, angle: -1, from: 0)
        fragment(s, "CH_2")
        s.push(auto)
        single(s, from: 0, angle: 1)
        fragment(s, "CH_3")
      })
    },s)
  )
]
```

which results in 

<img alt="image" src="https://github.com/user-attachments/assets/af9de234-aef8-4e01-a6c4-b6d28feef41f" />



## Structured Themes

Presentate now includes a suite of **structured themes** designed to automatically handle document hierarchy (up to 3 levels of nesting), navigation, and transitions. These themes use the [navigator](https://typst.app/universe/package/navigator/) package.

### Available Themes
- `sidebar`: A persistent navigation sidebar (left or right) that tracks your progress.
- `miniframes`: A dot-based progress bar (beamer Berlin style).
- `split`: A header divided into two contrasting areas for current section and subsection titles (beamer Copenhagen style).
- `progressive-outline`: A clean, progression-focused design featuring dynamic breadcrumbs.
- `minimal`: A "content-first" theme with no persistent UI, but with automatic roadmap transitions.

### Usage
Structured themes are located in the `themes` namespace. They are applied via a `show` rule:

```typ
#import "@preview/presentate:0.2.4": themes
#show: themes.sidebar.template.with(
  title: [My Presentation],
  author: [pacaunt],
  mapping: (section: 1, subsection: 2), // Defines which heading levels trigger the structure
)

= Introduction
== Concept
#slide[ ... ]
```

### Key Features
- **Transition**: Automatically generates "roadmap" slides during section changes. Highly configurable via the `transitions` argument.
- **Auto-titling**: With `auto-title: true`, slide titles are automatically derived from the most recent structural heading.

### Examples
You can find full implementations of these themes in the `assets/examples/` directory:
- [Sidebar demo](assets/examples/example-sidebar.typ)
- [Miniframes demo](assets/examples/example-miniframes.typ)
- [Split demo](assets/examples/example-split.typ)
- [Progressive-outline demo](assets/examples/example-progressive-outline.typ)
- [Minimal demo](assets/examples/example-minimal.typ)
- [Custom transition hooks demo](assets/examples/example-minimal-custom-transition.typ)

For detailed information on customization (colors, spacing, behavior), please refer to the [Structured Themes Guide](assets/docs/themes-guide.pdf).

## Versions
### 0.2.4 
- Featured with [navigator](https://typst.app/universe/package/navigator/) package for structured themes.
### 0.2.3
- Added `#motion` and `#tag` function for precise control of animation display order. 
- Added relative index `(rel: int)` to animate elements earlier than the current number of pauses.  
### 0.2.2 
- Added `hider` argument to `#step-item` function ([#8](https://github.com/pacaunt/typst-presentate/issues/8)).
### 0.2.1 
- Added `step-item` function for revealing items step-by-step. 
- Update the packages examples.
### 0.2.0
- Change the framework of animations, using one state for all cover functions.
- Introduce `render` and `animation` for more flexible package integration.
### 0.1.0 
Initial Release

## Acknowledgement 
Thanks [Minideck package author](https://github.com/knuesel/typst-minideck) for the `minideck` package that inspires me the syntax and examples.
[Touying package authors](https://github.com/touying-typ/touying) and [Polylux author](https://github.com/polylux-typ/polylux) for inspring me the syntax and parsing method. 
