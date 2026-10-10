# Presentate
**Presentate** is a package for creating presentation in Typst. It provides a framework for creating dynamic animation that is compatible with other packages. 
For comprehensive usage, please refer to [manual.pdf](https://github.com/pacaunt/typst-presentate/blob/3c510564c7ff1882085f46e7f1a9b94c08966495/assets/manual/manual.pdf)

## Highlights (0.3.0)
Compared to the last version (0.2.x), Presentate shipped with a lot of improvements.
- **Simpler Syntax**: Presentate now uses `#pause`, `#meanwhile`, `#jump()`, to control step-by-step reveal instead of `#show: pause`.
- **Faster Compilation**: All internal representation of animation framework was revised and reworked to minimize use of `state` and `counter`, so it is significantly faster and easier to use. 
- **Named Index**: You can use `#marker(<name>)` to name the current number of pauses as an index, and use the `<name>` like an index of that subslide. So it is possible to specify `#uncover(<name>)[Something]` or `#only((rel: 1, to: <name>))[Another thing]`. 
- **Extensible Package Integration**: With `interface`, `bridge`, and settable parse mode in `uncover`, `only`, they can be fully integrated within CeTZ canvas, Fletcher diagram, or even in nested `branch`, `cycle` of Alchemist package! 
- **Extensible Internal Elements**: Since the rework contains almost all implementation of manual context and state's read-write functions, presentate provides all internal access to the states by using`getter` to get internal states, and `updater` to update the states. All element parsing and reconstructions are *recursive*, meaning that you can nested Presentate's animation functions/markers as much as you want. Like, 
  ```typst 
  #uncover(2)[It is #alert(3)[important], #pause right?]
  ```

## Simple Usage 
Import the package with 
```typst
#import "@preview/presentate:0.3.0": *
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
  #pause

  This is `presentate`.
]
```
which results in 

![simple pause animation](https://github.com/pacaunt/typst-presentate/blob/3c510564c7ff1882085f46e7f1a9b94c08966495/assets/examples/features/example-simple-pause.png)

You can style the slides as you would do with normal Typst document. For example, 

```typst
#set page(paper: "presentation-16-9")
#set text(size: 25pt, font: "JetBrainsMono NF")
#set align(horizon)

#slide[
  = Welcome to Presentate! 
  \ A lazy author \
  #datetime.today().display()
]

#set align(top)

#slide[
  == Tips for Typst.

  #set align(horizon)
  Do you know that $pi != 3.141592$?

  #pause
  Yeah. Certainly.

  #pause
  Also $pi != 22/7$.
]
```

![example using Typst styling](https://github.com/pacaunt/typst-presentate/blob/3c510564c7ff1882085f46e7f1a9b94c08966495/assets/examples/features/example-styling.png)

### Relative Index Specification 
You can use `none` and `auto`, or even `(rel: int)` to specify the index as *with previous animation*, *after previous animation*, or `int` subslides away from the current number of pauses.
```typ
// Set the cover functions to see the effect better.
#let grayed = text.with(fill: gray.transparentize(50%))

#let pause = jump(auto, hider: grayed)
#let uncover = uncover.with(hider: grayed)

#slide[
  = Relative `auto`, `none`, and `(rel: int)` Indices
  This is present first

  #pause
  #only(auto)[This came later, but *not* preserve space.]
  _This will shift. $->$_

  #uncover(none)[This comes with current `pause`.]

  #pause This is the second `pause`.

  #pause This is the third `pause`

  #jump((rel: -1), hider: grayed)

  But this come before.
]
```

![relative index specification example](https://github.com/pacaunt/typst-presentate/blob/3c510564c7ff1882085f46e7f1a9b94c08966495/assets/examples/features/example-relative-indices.png)

### Varying Timeline
You can specify the `update` argument of dynamic functions to tell if that function will update the current number of pause or not. If set to `true`, the number of pauses will set to that value. 

This is useful for modifying steps of the animation so that some contents appear with or after another. 

Since 0.3.0, the named index were introduced. You can name a step by using `#marker(<name>)` and use the `<name>` as the index where the marker is revealed by pauses.

```typst
#slide[
  = Combination
  Derive an equation of displacement vs time for a free-falling object from height $h$ at initial velocity of $u$.
  #pause #marker(<solution>)

  *Solution.* #pause
  $
    v = u - g t quad "and" quad s = ((u + v)/2) t \
    #pause
    s = ((u + (u - g t))/2) t quad pause => quad s = u t - 1/2 g t^2
    #marker(<end>)
  $
  #jump(<solution>)
  #uncover(from: (to:<solution>, rel: 1), to: <end>)[_Comments:_]
  #only(auto, update: true)[From definitions.]
  #only(auto, update: true)[Distribute the terms.]
  #only(<end>)[That's it.]
]
```
![Example of using markers and relative indices to synchronize the animation](https://github.com/pacaunt/typst-presentate/blob/3c510564c7ff1882085f46e7f1a9b94c08966495/assets/examples/features/example-marker.png)

### Motion Control

You can have a precise control on what should be shown on each subslide relatively without worring about their order in definition code by using `#motion` function, and tag by a unique name for each contents in `#tag` function. For example, 

```typst
#import "@preview/cetz:0.5.2": canvas, draw

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
![motion function demonstration](https://github.com/pacaunt/typst-presentate/blob/3c510564c7ff1882085f46e7f1a9b94c08966495/assets/examples/features/example-motion.png)

In this example, featured with CeTZ package, each element is drawn normally, while its animation is shown differently. The precise animation control is done by specifying the tagged names in `controls` argument of `#motion` function. Note that the way of showing and hiding stuff can be modified using `hider` argument of each function.


### Package Integration 

For example, Integration with [CeTZ](https://typst.app/universe/package/cetz) and [Fletcher](https://typst.app/universe/package/fletcher) can be done by using `interface` and modify hider and wrapper mode:

```typst
#import "@preview/cetz:0.5.2": canvas, draw
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node

#slide[
  = CeTZ integration using `interface`

  #let canvas = interface(canvas, inner: "array", hider: draw.hide.with(bounds: true))
  #canvas({
    // You can use pause and animations inside CeTZ.
    import draw: *
    let uncover = uncover.with(mode: "array", hider: draw.hide.with(bounds: true))
    circle((0, 0), radius: 2)
    (pause,)
    circle((4, 0), radius: 2)
    uncover(3, circle((8, 0), radius: 2))
  })
]

#slide[
  = Fletcher integration

  #let diagram = interface(diagram, hider: fletcher.hide)
  #let f-uncover = uncover.with(hider: fletcher.hide)
  #diagram(
    node((0, 0), [First Node], name: <1>),
    pause,
    node((1, 0), [Second Node], name: <2>),
    f-uncover(3, edge(<1>, "d,r", <2>, "->")),
  )
]
```
![Example of using CeTZ and Fletcher inegration by interface function.](https://github.com/pacaunt/typst-presentate/blob/3c510564c7ff1882085f46e7f1a9b94c08966495/assets/examples/features/example-cetz-interface.png)

The nested scope can be accessed by using `bridge` function, for example, in [Alchemist](https://typst.app/universe/package/alchemist)'s cycle: 

```typst 
#import "@preview/alchemist:0.2.0" as alc: skeletize

#slide[
  = Alchemist Nested Interface

  #let skeletize = interface(skeletize, inner: "array", hider: alc.hide) 
  #let m-cycle = bridge(alc.cycle)
  #skeletize({
    import alc: *
    fragment("HO")
    single(angle: 1) 
    (pause,)
    m-cycle(5, {
      single() 
      (pause,)
      single() 
      single() 
      (pause,)
      single() 
      single()
    })
  })
]
```
![Alchemist animation by using bridge and interface](https://github.com/pacaunt/typst-presentate/blob/3c510564c7ff1882085f46e7f1a9b94c08966495/assets/examples/features/example-alchemist-bridge.png)

You can use the `render` function to create a workspace, and import the `animation` module of Presentate to create animation with other packages. 

```typst
#import "@preview/cetz:0.5.2": canvas, draw
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

![CeTZ and fletcher integration example](https://github.com/pacaunt/typst-presentate/blob/3c510564c7ff1882085f46e7f1a9b94c08966495/assets/examples/features/example-cetz.png)

You can incrementally show the content from other package by wrap the functions in the `animate` function, with a modifiers that modifies the function's arguments to hide the content using `modifier`. 
For example, this molecule animation is created compatible with [Alchemist](https://typst.app/universe/package/alchemist) package: 

```typst
#import "@preview/alchemist:0.2.0" as alc

// set stroke to `gray`
#let modifier(func, ..args) = func(stroke: gray + 1pt, ..args) 
#let (single, double) = animation.animate(modifier: modifier, alc.single, alc.double)
#let (fragment,) = animation.animate(
  // set atom color to gray
  modifier: (func, ..args) => func(colors: (gray,), ..args), 
  alc.fragment
)

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

![incrementally show the molecule using alchemist package](https://github.com/pacaunt/typst-presentate/blob/3c510564c7ff1882085f46e7f1a9b94c08966495/assets/examples/features/example-alchemist.png)



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
#import "@preview/presentate:0.2.6": *
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
- [Sidebar demo](https://github.com/pacaunt/typst-presentate/blob/3c510564c7ff1882085f46e7f1a9b94c08966495/assets/examples/themes/example-sidebar.typ)
- [Miniframes demo](https://github.com/pacaunt/typst-presentate/blob/3c510564c7ff1882085f46e7f1a9b94c08966495/assets/examples/themes/example-miniframes.typ)
- [Split demo](https://github.com/pacaunt/typst-presentate/blob/3c510564c7ff1882085f46e7f1a9b94c08966495/assets/examples/themes/example-split.typ)
- [Progressive-outline demo](https://github.com/pacaunt/typst-presentate/blob/3c510564c7ff1882085f46e7f1a9b94c08966495/assets/examples/themes/example-progressive-outline.typ)
- [Minimal demo](https://github.com/pacaunt/typst-presentate/blob/3c510564c7ff1882085f46e7f1a9b94c08966495/assets/examples/themes/example-minimal.typ)
- [Custom transition hooks demo](https://github.com/pacaunt/typst-presentate/blob/3c510564c7ff1882085f46e7f1a9b94c08966495/assets/examples/themes/example-minimal-custom-transition.typ)

For detailed information on customization (colors, spacing, behavior), please refer to the [Structured Themes Guide](https://github.com/pacaunt/typst-presentate/blob/3c510564c7ff1882085f46e7f1a9b94c08966495/assets/manual/themes-guide.pdf).

## Versions
### 0.3.0 
- Major revision of the core animation principles. The `pause` mechanism was changed to `#pause` marker like in 0.1.0, **(breaking change)**
- Introduce `#jump(index)` to set the pause to that index 
- Introduce named index, which can be registered by using `#marker(<name>)`.
- Rename `update-pause` to `update` argument **(breaking change)**
- Introduce another package integration framework using `interface` and `bridge`, together with specifying mode of parsing so that the animation mechanism does not require manual state updates.
- Remove `before-func` argument of `transform` **(breaking change)**
### 0.2.7 
- Fix bugs where nested pause does not interact properly.
### 0.2.6 
- added `start` argument to `reveal-item` and `step-item` function.
- added reference section to the manual.
### 0.2.5 
- refactor structured themes to use [navigator](https://typst.app/universe/package/navigator/) 0.1.3 simplified API
- update themes guide with navigation improvements (short titles and title truncation)
- added `reveal-item` function to display list/enum group by group. 
- added new control rule syntax in `motion` function to be able to modify content on each animation step. 
- added `classic` theme.
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
