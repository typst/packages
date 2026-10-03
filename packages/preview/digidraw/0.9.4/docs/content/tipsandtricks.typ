
#import "../../src/exports.typ" as dd
#import "../template.typ": manual-template, myraw, mylink, tidylink

#show: manual-template


== Pre-Configuring the `#wave` Function

To preconfigure a function or set a "Global" configuration, you can use the #mylink("https://typst.app/docs/reference/foundations/function/#definitions-with")[`with`]-function to pre-apply parameters.


```vexample
#let my-wave = dd.wave.with(stroke: gradient.linear(..color.map.rainbow) + 1pt)

#my-wave(
  (signal: (
    (wave: "xzz2..0|2.0.2.x",data: ([I'm `my-wave`],[now],[hihi],)),)
  )
)
```


== Making Diagrams Referenceable

To make timing diagrams referencable, enclose it in a `#figure` element. Additionally, to make labelling (`... <a-label>`) work, define a new function or "overload" the `#wave` function:

````vexample
#let wave(..args, caption: none) = figure(
  dd.wave(
    ..args
  ),
  caption: caption,
  supplement: [Diagram],
  kind: "timing-diagrams"
)

#wave(
  (signal: (
    (wave: "x12.udx34z.5.x.",data: "Hello This is Digidraw"),)
  ),
  caption: [Use case of a timing diagram.]
) <dd:example>

//-#set align(left)
When a need to reference the @dd:example occurs, `@dd:example` can be used. And for listing the diagrams, the outline target `figure.where(kind: "timing-diagrams")` is to be used:

```typst
#outline(target: figure.where(kind: "timing-diagrams"))
```
````

#pagebreak()

== Diagram and Wave Anchors

Every diagram comes with a collection of anchors, in which you can attach `cetz` elements onto. Either via the @-wave.others parameter or the #ref(label("-subwave()")) function.

```vexample
#dd.wave(
  (signal: (
    (wave: "102..15..1.",),
    (:),
    (wave: "102..13.8..",),
  )),
  debug: "anchors"
)
```

The right big red text indicates the waves' names. `"wave"` is the diagrams name and for example `"wave.0"` is the first wave (from the top).


```vexample
#cetz.canvas({
  import cetz.draw: *
  rect((0,0), (rel: (5,3)), name: "hanspeter")

  // places the wave to the rectangle called "hanspeter" relative to its origin (bottom left corner)
  dd.subwave("hanspeter", (signal: ((wave: "10101010",),)))
})

```

To place for example a wave inside another wave, you can use the #ref(label("-subwave()")) function inside the @-wave.others parameter to place said wave over another one (essentially stacking waves on top of each other).


```vexample
#dd.wave(
  // 
  (signal: ((wave: "01010101",),(wave: "01010101",))), symbol-height: 1cm,
  others: (info) => {
    
    dd.subwave("wave.0",(signal: ((wave: "==......",),)), stroke: (paint: red,), wave-layer: -3, symbol-height: info.symbol-height / 2)

    dd.subwave("wave.1",(signal: ((wave: "10101010",),)), stroke: (paint: blue, dash: "loosely-dashed", thickness: 2pt), symbol-height: 5mm)
  }
)
```
