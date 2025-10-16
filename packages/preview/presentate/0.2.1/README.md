# Presentate
**Presentate** is a package for creating presentation in Typst. It provides a framework for creating dynamic animation that is compatible with other packages. 
For usage, please refer to [demo.pdf](https://github.com/user-attachments/files/22944952/demo.pdf)


## Simple Usage 
Import the package with 
```typst
#import "@preview/presentate:0.2.1": *
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
#set text(size: 25pt, font: "FiraCode Nerd Font Mono")
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

  #show: pause 
  Yeah. Certainly.

  #show: pause 
  Also $pi != 22/7$.
]


```

<img alt="example2" src="https://github.com/user-attachments/assets/c071e008-a1eb-4c59-b693-fbeea9bf70aa" />

### Relative Index Specification 
You can use `none` and `auto` to specify the index as *with previous animation* or *after previous animation*. 
```typ
#slide[
  = Relative `auto` and `none` Indices

  This is present first 

  #show: pause 

  #only(auto)[This came later, but *not* preserve space.]
 _This will shift._

 #uncover(none)[This comes with current `pause`.]

 #show: pause 
 This is the next `pause`.
]
```

<img alt="image" src="https://github.com/user-attachments/assets/ddc51c6b-a2f6-444a-aee9-2c31dc282b59" />

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





### Package Integration 

Use can use the `render` function to create a workspace, and import the `animation` module of Presentate to create animation with other packages. 
For example, Integration with [CeTZ](https://typst.app/universe/package/cetz) and [Fletcher](https://typst.app/universe/package/fletcher)  
```typst
#import "@preview/cetz:0.4.1": canvas, draw
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



## Versions
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
