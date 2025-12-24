#import "src/lib.typ" as patatrac

#let primary = rgb("#f63b3b")

#show title: it => {
  set text(size: 50pt, fill: primary)
  align(center, link("https://github.com/ZaninDavide/patatrac", it))
}

#show quote: it => {
  set text(style: "italic", size: 15pt, fill: primary)
  align(center, pad(it, top: 0pt, bottom: 20pt))
}

#set text(size: 12pt)
#set page(margin: (left: 4cm, top: 3cm, bottom: 3cm, right: 4cm), numbering: none)
#set par(justify: true, spacing: 0.8em)
#set heading(numbering: "1.1")
#show heading.where(level: 1): it => {
  set text(size: 21pt)
  pagebreak(weak: true)
  it
}

#import "@preview/zebraw:0.6.1": zebraw
#show raw.where(block: false): set raw(lang: "typc")
#show raw.where(block: true): zebraw.with(background-color: luma(96%), numbering-separator: true, lang: false)

#import "@preview/tidy:0.4.3" as tidy
#let objects-names = {
  read("src/objects/mod.typ")
  .matches(regex("#import\s+\"([^\"]+)\""))
  .filter(obj => obj.captures.at(0) != "object.typ")
  .map(obj => "src/objects/" + obj.captures.at(0))
  .sorted()
  .map(filename => tidy.parse-module(read(filename)).functions.map(f => f.name))
  .flatten()
}
#let object-related-functions-names = {
  tidy.parse-module(read("src/objects/object.typ")).functions.map(f => f.name)
}
#let doc-fun(fun, description: false, label: false) = {
  {
    [#raw({
      str(fun.name)
      "("
      for (key, value) in fun.args {
        (str(key) + if "default" in value {
          ": " + str(value.default)
        }, )
      }.join(", ")
      ")"
      if fun.return-types != none {
        " -> "
        for rt in fun.return-types {
          str(rt)
        }
      }
    }).#if label { std.label(fun.name) }]
    [#" "]
  }
  
  if description and fun.description != none and fun.description != "" {
    let add-fullstop(string) = if string.at(-1) == "." { string } else { string + "." } 
    eval(
      "[" + add-fullstop(
        fun.description.trim().split(regex("\n\s+\n")).at(0).replace("\n", "").trim()
      )  + "]"
    )
  }
}
#let find-constructor(obj-name) = doc-fun(tidy.parse-module(read("src/objects/" + obj-name + ".typ")).functions.filter(f => f.name == obj-name).at(0))

#show raw.where(block: false): it => {
  if it.text in objects-names {
    link(label(it.text), it)
  } else if it.text in object-related-functions-names {
    link(label(it.text), it)
  } else if it.text == "cetz.standard" or it.text == "patatrac.cetz.standard" {
    link(label("cetz.standard"), it)
  } else if it.text == "cetz.debug" or it.text == "patatrac.cetz.debug" {
    link(label("cetz.debug"), it)
  } else {
    it
  }
}

#let canvas = (..args) => {
  set text(size: 15pt)
  align(center, patatrac.cetz.canvas(length: 0.5mm, ..args))
}

#place(top + center, scope: "parent", float: true, {
  v(1fr)

  title[patatrac]

  v(-20pt)
  text(size: 20pt, fill: luma(70%))[|pataˈtrak|]

  v(-10pt)
  image("gallery/incline.pdf")

  v(-15pt)

  quote[
    a user-friendly Typst package for drawing physics\ diagrams
    fast and without trigonometry
    // italian onomatopeia describing crashing and cracking
    // the funny sound of something messy\ suddenly collapsing onto itself
  ]

  v(10pt)

  v(3fr)
})

#pagebreak()

#outline(title: "Index")

#pagebreak()

#set page(footer:  context {
  set align(center)
  v(1fr)
  counter(page).display("1")
  v(1fr)
})

= Philosophy
This Typst package provides help with the typesetting of physics diagrams depicting classical mechanical systems. It was born out of necessity, with the intention of filling a gap not only in the Typst ecosystem but more broadly in the space of computer-generated graphics. In particular, there are two ways in which these pictures are drawn traditionally: either using graphic design software with a visual user interface or writing code. Both methods have pros and cons. 

The first approach requires no mathematics -- and in particular no trigonometric calculations -- but generally lacks the precision and repeatability of code. Our goal here is to provide a tool that takes the best of both worlds: the precision of code and the simplicity of visual manipulation. For this reason, writing `patatrac` code should feel like controlling a graphic design software; the scene is built step by step. The real-time compilation offered by Typst really conveys this feeling. At the same time, this is not what you get when using graphic libraries directly: commands correspond to draw calls and this pushes you to make somewhat elaborate calculations to determine upfront where everything should be.

Crucially, a feature that no respectable graphic design software lacks is _snapping_: when dragging elements around, this feature makes it easy to place objects in perfect contact with each other. We borrowed this concept and turned it into `place`ing, `match`ing and `stick`ing. Already in the earliest stages, this choice proved fruitful. In fact, code written with `patatrac` was expressive enough to be almost always non-destructive, meaning that tuning values at the start of the code would not break the final picture.

We made the decision to keep composition and rendering (styling) completely separate. This was motivated by the observation that the best and fastest way of styling a diagram is most often messy; there are just too many options that have to be specified. Surely taming this chaos is something `patatrac` should try its best at, but we acknowledge that this messiness is fine as long as it doesn't creep into the logic used for composition. 

With this discussion, we hoped to establish clear design principles to follow going forward. Any advice or critique is not only welcomed but encouraged: just open an issue on #link("https://github.com/ZaninDavide/patatrac")[GitHub]. If you are ready, why don't you move on to our decidedly more colloquial tutorial? Have fun doing physics!

= Tutorial
In this tutorial we will assume that `cetz` is the rendering engine of choice, which at the moment is the only one supported out of the box. The goal is to draw the figure below: two boxes connected by a spring laying on a sloped surface. 

#canvas({
  import patatrac: *
  let draw = patatrac.cetz.standard()
  let floor = incline(100, 20deg)
  let A = rect(15, 15)
  let B = rect(15, 15)

  A = stick(A("bl"), floor("tl"))
  B = stick(B("br"), floor("tr"))

  A = slide(A, -20, 0)
  B = slide(B, +20, 0)
  
  let k = spring(A("r"), B("l"))

  draw(floor, fill: luma(90%), stroke: none)
  draw(k, radius: 6, pitch: 4, pad: 3)
  draw(A, stroke: 2pt, fill: red)
  draw(B, stroke: 2pt, fill: blue)
})

== Getting started
Let's start with the boilerplate required to import `patatrac` and set up a canvas. Under the namespace `patatrac.cetz`, the package exposes a complete `cetz` version plus all cetz-based renderers.

```typ
#import "@preview/patatrac:0.5.0"

#patatrac.cetz.canvas(length: 0.5mm, {
  import patatrac: *
  let draw = cetz.standard()

  // Composition & Rendering
})
```

At line 3, we create a new cetz canvas. At line 5, we define draw to be the cetz standard renderer provided by `patatrac` without giving any default styling option: we will go back to defaults later in the tutorial. The function `draw` will take care of outputting `cetz` elements that the canvas can print. From now on, we will only show what goes in the place of line 7, but remember that the boilerplate is still there. Let's start by adding a floor to our scene.

```typc
let floor = rect(100, 20)
draw(floor)
```

Line 1 creates a new patatrac `object` of type `"rect"`, which under the hood is a special function that represents our $100 times 20$ rectangle. The output of `draw` is a cetz-element that is then picked up by the canvas and printed.

#canvas({
  import patatrac: *
  let draw = cetz.standard()
  let floor = rect(100, 20)
  draw(floor)
})

== Introducing anchors
Every object carries with it a set of anchors. Every anchor is a point in space with a specified orientation. As anticipated, objects are functions. In particular, if you call an object on the string `"anchors"`, a complete dictionary of all its anchors is returned. For example, `floor("anchors")` gives

#raw(repr(patatrac.rect(100,20)("anchors")), lang: "typc")

As a general rule of thumb, anchors are placed both at the vertices and at the centers of the sides of the objects and their rotations specify the tangent direction at every point./* If you pay attention you will see that the rotation of the anchors is an angle which increases as one rotates counter-clockwise and with zero corresponding to the right direction. */ If you use the renderer `patatrac.cetz.debug` you will see exactly where and how the anchors are placed: red corresponds to the tangent (local-$x$) direction and green to the normal (local-$y$) direction.

```typc
let debug = cetz.debug()
draw(floor)
debug(floor)
```
#canvas({
  import patatrac: *
  let draw = patatrac.cetz.standard()
  let debug = patatrac.cetz.debug()
  let floor = rect(100, 20)
  draw(floor)
  debug(floor)
})

As you can see, the central anchor is drawn a bit bigger and thicker. The reason is that `c` is, by default, what we call the _active anchor_. We can change the active anchor of an object by calling the object itself on the name of the anchor. For example if we instead draw the anchors of the object `floor("t")` what we get is the following.

```typc
let debug = cetz.debug()
draw(floor)
debug(floor("t"))
```
#canvas({
  import patatrac: *
  let draw = patatrac.cetz.standard()
  let debug = patatrac.cetz.debug()
  let floor = rect(100, 20)
  draw(floor)
  debug(floor("t"))
})

When doing so, we have to remember that Typst functions are pure: don't forget to reassign your objects if you want the active anchor to change "permanently"! 

== Composition
Now, let's add in the two blocks. First of all, we need to place the blocks on top of the floor. To do so we use the `place` function which takes two objects and gives as a result the first object translated such that its active anchor location overlaps with that of the second object.
```typc
let floor = rect(100, 20)

let A = rect(15, 15)
let B = rect(15, 15)

A = place(A("bl"), floor("tl"))
B = place(B("br"), floor("tr"))

draw(floor, A, B)
```

#canvas({
  import patatrac: *
  let draw = patatrac.cetz.standard()
  let floor = rect(100, 20)
  let A = rect(15, 15)
  let B = rect(15, 15)

  A = place(A("bl"), floor("tl"))
  B = place(B("br"), floor("tr"))
  
  draw(floor, A, B)
})


Now we should move the blocks a bit closer and add the spring.
```typc
let floor = rect(100, 20)
let A = rect(15, 15)
let B = rect(15, 15)

A = place(A("bl"), floor("tl"))
B = place(B("br"), floor("tr"))

A = move(A, +20, 0)
B = move(B, -20, 0)

let k = spring(A("r"), B("l"))

draw(floor, A, B, k)
```

#canvas({
  import patatrac: *
  let draw = patatrac.cetz.standard()
  let floor = rect(100, 20)
  let A = rect(15, 15)
  let B = rect(15, 15)

  A = place(A("bl"), floor("tl"))
  B = place(B("br"), floor("tr"))

  A = move(A, +20, 0)
  B = move(B, -20, 0)
  
  let k = spring(A("r"), B("l"))

  draw(floor, A, B, k)
})

== Styling
The styling is pretty self-explanatory. The only thing to notice is that objects drawn with the same call to `draw` share the same styling options, therefore multiple calls to `draw` are required for total stylistic freedom.
```typc
// ...

draw(floor, fill: luma(90%), stroke: none)
draw(k, radius: 6, pitch: 4, pad: 3)
draw(A, stroke: 2pt, fill: red)
draw(B, stroke: 2pt, fill: blue)
```

#canvas({
  import patatrac: *
  let draw = patatrac.cetz.standard()
  let floor = rect(100, 20)
  let A = rect(15, 15)
  let B = rect(15, 15)

  A = place(A("bl"), floor("tl"))
  B = place(B("br"), floor("tr"))

  A = move(A, +20, 0)
  B = move(B, -20, 0)
  
  let k = spring(A("r"), B("l"))

  draw(floor, fill: luma(90%), stroke: none)
  draw(k, radius: 6, pitch: 4, pad: 3)
  draw(A, stroke: 2pt, fill: red)
  draw(B, stroke: 2pt, fill: blue)
})

Remember that since you are inside a `cetz` canvas you are free to add whatever detail you like to make your picture more expressive. 

== Snapping
This picture is nice but drawing it without `patatrac` wouldn't have been much harder. I want you to see where `patatrac` shines so `stick` with me while I exchange the floor for an incline.
```typc
let floor = incline(100, 20deg)
let A = rect(15, 15)
let B = rect(15, 15)

A = stick(A("bl"), floor("tl"))
B = stick(B("br"), floor("tr"))

A = slide(A("c"), +20, 0)
B = slide(B("c"), -20, 0)

// ...
```
#canvas({
  import patatrac: *
  let draw = cetz.standard()
  let floor = incline(100, 20deg)
  let A = rect(15, 15)
  let B = rect(15, 15)

  A = stick(A("bl"), floor("tl"))
  B = stick(B("br"), floor("tr"))

  A = slide(A("c"), +20, 0)
  B = slide(B("c"), -20, 0)
  
  let k = spring(A("r"), B("l"))

  draw(floor, fill: luma(90%), stroke: none)
  draw(k, radius: 6, pitch: 4, pad: 3)
  draw(A, stroke: 2pt, fill: red)
  draw(B, stroke: 2pt, fill: blue)
})

What have I done? At line 1, I used an `incline` instead of a rectangle which I create by giving its width and steepness. Then, at lines 5 and 6, I replaced the calls to `place` with an identical call to `stick`. This function, instead of simply translating the object, also rotates it to make sure that its active anchor faces the second anchor. By doing so, I'm sure that the two blocks rest on the incline correctly. Then, at lines 8 and 9, I replaced the calls to `move` with identical (up to a change of active anchors) calls to `slide`. This function, instead of translating the objects in the global coordinate system, translates them inside the rotated coordinate system of their active anchors. By doing so, I make the two blocks slide along the incline surface.

== Defaults
The picture is done but there's another thing I'd like to show you and that will come in handy for more complex pictures. As promised, we have to go back to the boilerplate. Do you remember the line where we defined `draw`? Instead of specifying `stroke: 2pt` every time we draw a rectangle, we can put inside the call to `patatrac.cetz.standard` the information that by default all rectangles should have `2pt` of stroke. Even if we have only one spring it makes sense to do the same for the styling options of `k`, so that if we create a second spring it will look the same.
```typc
let draw = cetz.standard(
  rect: (stroke: 2pt),
  spring: (radius: 6, pitch: 4, pad: 3),
)

// ...

draw(floor, fill: luma(90%), stroke: none)
draw(k)
draw(A, fill: red)
draw(B, fill: blue)
```
Here is the full code.
```typ
#import "@preview/patatrac:0.5.0"

#patatrac.cetz.canvas(length: 0.5mm, {
  import patatrac: *
  let draw = cetz.standard(
    rect: (stroke: 2pt),
    spring: (radius: 6, pitch: 4, pad: 3),
  )

  let floor = incline(100, 20deg)
  let A = rect(15, 15)
  let B = rect(15, 15)

  A = stick(A("bl"), floor("tl"))
  B = stick(B("br"), floor("tr"))

  A = slide(A("c"), +20, 0)
  B = slide(B("c"), -20, 0)

  let k = spring(A("r"), B("l"))

  draw(floor, fill: luma(90%), stroke: none)
  draw(k)
  draw(A, fill: red)
  draw(B, fill: blue)
})
```


Okay, now that we have the final drawing we can spend a few words clarifying what's going on. Read @system to understand better.

#set enum(spacing: 15pt, indent: 15pt)
#set list(spacing: 15pt, indent: 15pt)

= Core system <system>
The whole `patatrac` package is structured around three things:
1. anchors, 
2. objects,
3. renderers.
Let's define them one by one. 

== Anchors
Anchors are simply dictionaries with three entries `x`, `y` and `rot` that are meant to specify a 2D coordinate system. The values associated with `x` and `y` are either lengths or numbers and the package assumes that this choice is unique for all the anchors used in the drawing. These two entries specify the origin of the local coordinate system on the canvas. `rot` on the other hand always takes values of type `angle` and specifies the direction in which the local-x axis is pointing. Whenever `patatrac` expects the argument of a method to be an anchor it automatically calls `anchors.to-anchor` on that argument. This allows you, the end user, to specify anchors in many different styles:
- `(x: ..., y: ..., rot: ...)`,
- `(x: ..., y: ...)`,
- `(..., ..., ...)`,
- `(..., ...)`.
All options where the rotation is not specified default to `0deg`. Moreover, objects can automatically be converted to anchors: `to-anchor` simply results in the object's active anchor. The local coordinate system is right-handed if the positive $z$-direction is taken to point from the screen towards our eyes.

== Objects
Objects are special functions created with a call to an object constructor. All object constructors ultimately reduce to a call to `object`, so that all objects behave in the same way. The result is a callable function, let's call it `obj`, such that:
 - `obj()` returns the active anchor,
 - `obj("anchor-name")` returns an equivalent object but with the specified anchor as active,
 - `obj("anchors")` returns the full dictionary of anchors,
 - `obj("active")` returns the key of the active anchor,
 - `obj("type")` returns the object type,
 - `obj("data")` returns the carried metadata,
 - `obj("repr")` returns a dictionary representation of the object meant only for debugging purposes.

If you want to create an object from scratch all you need to do is to use the `object` constructor yourself.
```typc
let custom = patatrac.objects.object(
  "custom-type-name", 
  "active-anchor-name",
  dictionary-of-anchors,
  data: payload-of-metadata 
)
```

== Renderers
A renderer is a function whose job is to take default styling options and return a function capable of rendering objects. This function will take one or more objects, associate each object to a drawing function according to the object's type and return the rendered result, all of this while taking care of any styling option. The journey from a set of drawing functions to an actual drawing starts with a call to `renderer`.
```typc
let my-renderer = patatrac.renderer((
  // drawing functions
  rect: (obj, style) => { ... },
  circle: (obj, style) => { ... },
  ...
))
```
For example, this is the way in which `patatrac.cetz.standard` is defined. `my-renderer` is not yet ready to render stuff: we need to specify any default styling option. We do this by calling `my-renderer` itself.
```typc
let draw = my-renderer(rect: (stroke: 2pt))
```
The variable `draw` is the function we use to actually render objects. This step where we provide defaults is kept separate from the call to `renderer` so that the end user can put his own defaults into the renderer: the developer should expose `my-renderer` and not `draw`. Defaults that are set by the developer can simply be hardcoded inside the drawing functions definitions; and this is exactly how the package does for its own renderers. Now, use `draw` to print things.
```typc
draw(circle(10), fill: blue)
```
#align(center, patatrac.cetz.canvas(length: 0.5mm, {
  let draw = patatrac.cetz.standard()
  draw(patatrac.circle(10), fill: blue)
}))
If you want, you can extract from `my-renderer` the full dictionary of drawing functions that was used to for its definition.
```typc
my-renderer("functions")
```

#{
  patatrac.renderer((
    // drawing functions
    rect: (obj, style) => {},
    circle: (obj, style) => {},
  ))("functions")
}

This allows the user to extend, modify and combine existing renderers if needed. For example, we could start from the `cetz.standard` renderer and override the algorithm for drawing circles.
```typc
let my-renderer = renderer(cetz.standard("functions") + (
  circle: (obj, style) => { ... }
))
```

== Grouping
Currently, `patatrac` provides very basic grouping capabilities. This may change in the future, but -- at the moment -- a group is simply an array of objects. Unless specified otherwise, every function that can take an object as input can also take a group of objects. The group is treated as a rigid entity whose active anchor is the active anchor of the first object in the group.
```typc
let A = rect(30, 20)
let B = place(rect(10, 10)("bl"), A("tl"))
let G = (A("bl"), B)
G = rotate(G, 30deg)
draw(G)
draw(axes(A("bl"), 40, 40))
```
#canvas({
  import patatrac: *
  let draw = cetz.standard()
  let A = rect(30, 20)
  let B = place(rect(10, 10)("bl"), A("tl"))
  let G = (A("bl"), B)
  G = rotate(G, 30deg)
  draw(G)
  draw(axes(A("bl"), 40, 40))
})

#pagebreak()

= Objects one by one
We will now go through the various object constructors one by one. In what follows, we will omit the boilerplate and the rendering stage, in order to focus on composition.

== Rectangles <rect>
The constructor #find-constructor("rect") takes only the width and the height of the rectangle.
```typc
rect(80,300)
```
#canvas({
  import patatrac: *
  let draw = cetz.standard()
  let debug = cetz.debug()
  draw(rect(80,30))
  debug(rect(80,30))
})

== Circles <circle>
The constructor #find-constructor("circle") takes only the radius of the circle.
```typc
circle(20)
```
#canvas({
  import patatrac: *
  let draw = cetz.standard()
  let debug = cetz.debug()
  draw(circle(20))
  debug(circle(20))
})

== Inclines <incline>
The constructor #find-constructor("incline") takes the incline width and the angle between base and hypotenuse.
```typc
incline(80, 20deg)
```
#canvas({
  import patatrac: *
  let draw = cetz.standard()
  let debug = cetz.debug()
  draw(incline(80, 20deg))
  debug(incline(80, 20deg))
})
If the angle is negative the incline is downhill moving left to right.
```typc
incline(80, -20deg)
```
#canvas({
  import patatrac: *
  let draw = cetz.standard()
  let debug = cetz.debug()
  draw(incline(80, -20deg))
  debug(incline(80, -20deg))
})

== Polygons <polygon>
The constructor #find-constructor("polygon") takes a series of anchors representing in clockwise order the vertices of a 2D shape.
```typc
polygon((0,0), (40,40), (80, 40))
```
#canvas({
  import patatrac: *
  let draw = cetz.standard()
  let debug = cetz.debug()
  draw(polygon((0,0), (40,40), (80, 40)))
  debug(polygon((0,0), (40,40), (80, 40)))
})

== Arrows <arrow>
The constructor #find-constructor("arrow") takes an anchor and a length. The arrow is located at the anchor's location and oriented towards the positive $y$ direction of the specified anchor. If the named parameter `angle` is set to something different from `none`, the arrow's orientation is instead determined by its value.
```typc
arrow((0,0,20deg), 20)
arrow((30,0,20deg), 20, angle: 20deg)
```
#canvas({
  import patatrac: *
  let draw = cetz.standard()
  let debug = cetz.debug()
  let a = arrow((0,0,20deg), 40)
  let b = arrow((60,0,20deg), 40, angle: 20deg)
  draw(a, b,)
  debug(a, b, fill: orange)
})

Notice how the arrow orientation is determined differently in the two cases. In the first case the angle specifies the rotation of the anchors' x-axis, in the second case it determines the angle of the anchor's y-axis.

== Springs <spring>
The constructor #find-constructor("spring") takes two anchors whose location determines where the spring starts and ends.
```typc
spring((0,0), (25,25))
```
#canvas({
  import patatrac: *
  let draw = cetz.standard()
  let debug = cetz.debug()
  draw(spring((0,0), (25,25)))
  debug(spring((0,0), (25,25)))
})

== Axes <axes>
The constructor #find-constructor("axes") takes an anchor and two lengths, for the two axes. The specified lengths are one sided, meaning that the total axis length is double that. If an axis extends into the positive and negative directions by different amounts its length must be specified as an array `(negative-extension, positive-extension)`.
```typc
axes((0,0,30deg), 20, 10)
axes((80,0,20deg), (0, 20), 10)
axes((160,0,10deg), 30, 0, rot: false)
```
#canvas({
  import patatrac: *
  let draw = cetz.standard()
  let debug = cetz.debug()
  let a = axes((0,0,30deg), 30, 20)
  let b = axes((80,0,20deg), (0,20), 20)
  let c = axes((160,0,10deg), 30, 0, rot: false)
  draw(a, b, c)
  debug(a, b, c, fill: orange)
})
As seen in the last example, a named parameter `rot` can be set to `false` to make the constructor ignore the anchor's rotation.

_Suggestion_: Apart from actual cartesian axes, this object can be used to represent lines that are normal or tangent to a surface, lines of symmetry or construction lines.
```typc
let C = circle(15)
let normal = axes(C("tl"), 0, 15)
let tangent = axes(C("tr"), 15, 0)
```
#canvas({
  import patatrac: *
  let draw = cetz.standard()
  let debug = cetz.debug()
  let C = circle(15)
  let normal = axes(C("tl"), 0, 15)
  let tangent = axes(C("r"), 15, 0)
  draw(C, stroke: (dash: "dotted"))
  draw(normal, tangent)
})

== Points <point>
The constructor #find-constructor("point") takes a single anchor. A named parameter `rot` can be set to `false` to make the constructor ignore the anchor's rotation.
```typc
point((0,0,30deg))
point((50,0,30deg), rot: false)
```
#canvas({
  import patatrac: *
  let draw = cetz.standard()
  let debug = cetz.debug()
  let a = point((0,0,30deg))
  let b = point((50,0,30deg), rot: false)
  draw(a, b)
  debug(a, b)
})

_Suggestion_: The `cetz.standard()` renderer lets you assign a label to a point. You can use this feature to place text into the scene.

== Ropes <rope>
The main idea behind how ropes work is the following:

#align(center, pad(5pt)[_ropes are one dimensional strings that wrap around anchors and circles._])

The constructor #find-constructor("rope") requires the list of anchors and circles that 
you want the rope to wrap around. Since there are two ways in which any given rope can wrap around a circle, the rotation of the active anchor of the circle will tell the rope from which direction to start "orbiting" around the circle.

```typc
let C1 = circle(15)
let C2 = place(circle(10), (50, 0))
let R = rope((-50, 0), C1("b"), C2("t"), (+100, 0))
```
#canvas({
  import patatrac: *
  let draw = patatrac.cetz.standard()
  
  let C1 = circle(15)
  let C2 = place(circle(10), (50, 0))
  let R = rope((-50, 0), C1("b"), C2("t"), (+100, 0))
  draw(C1, C2)
  draw(R, stroke: 2pt + blue)
})

Ropes provide many different anchors. Anchors are named with increasing whole numbers starting from one converted to strings and eventually followed by a letter `"i"`, `"m"`, `"o"`. The letter `"i"` specifies that we are either starting an arc of circumference around a circle or approaching a vertex. The letter `"m"` denotes anchors which are placed at the middle of an turn. The letter `"o"` is placed at the end of anchors that either specify the outgoing direction from a vertex or the last point on an arc. There are also two special anchors `start` and `end`, whose name is self-explanatory. Here is the full list of anchors for the previous example.

#{
  import patatrac: *
  let C1 = circle(15)
  let C2 = place(circle(10), (50, 0))
  let R = rope((-50, 0), C1("b"), C2("t"), (+100, 0))
  canvas({
    cetz.standard()(R, stroke: 2pt + blue)
    cetz.debug()(R)
  })
  [#R("anchors")]
}

== Terrains <terrain>
Terrains are objects that you can use to create arbitrarily shaped surfaces. The constructor #find-constructor("terrain") takes a function describing the profile and its domain, expressed as a tuple `(min, max)`. The named parameter `scale` is a prefactor that is applied to the coordinates before calculating the anchors' positions and before drawing.
```typc
let ground = terrain(
  x => 0.1 + x*x, (0, 1),
  scale: 100, A: 30%, B: 0.6,
)
```
#canvas({
  import patatrac: *
  let debug = cetz.debug()
  let draw = cetz.standard()
  let ground = terrain(
    x => 0.1 + x*x, (0, 1),
    A: 30%, B: 0.6, scale: 100,
  )
  draw(ground, fill: luma(90%))
  debug(ground)
})
Here we are also specifying two points $A$ and $B$, by giving their position on the specified range either as number or ratio. These points are automatically added as anchors tangent to the surface. In order to rotate the anchors correctly `patatrac` needs to differentiate numerically the given function. The named parameter `epsilon` specifies the step size for the incremental ratio used to approximate the derivative. 

== Trajectories <trajectory>
Trajectories are objects that you can use to create arbitrarily shaped curves. The constructor #find-constructor("trajectory") takes a function parametrizing the curve and its domain, expressed as a tuple `(min, max)`.
```typc
let motion = trajectory(
  t => (1.5*calc.sin(t), calc.cos(t)), (0, 2),
  scale: 50, A: 30%, B: 1.2,
)
```
#canvas({
  import patatrac: *
  let debug = cetz.debug()
  let draw = cetz.standard()
  let motion = trajectory(
    t => (1.5*calc.sin(t), calc.cos(t)), (0, 2),
    scale: 50, A: 30%, B: 1.2,
  )
  draw(motion, smooth: false, stroke: (dash: "dashed", thickness: 1pt))
  debug(motion)
})


Here we are also specifying two points $A$ and $B$, by giving their position on the specified range either as number or ratio. These points are automatically added as anchors tangent to the curve. In order to rotate the anchors correctly `patatrac` needs to differentiate numerically the given function. The named parameter `epsilon` specifies the step size for the incremental ratio used to approximate the derivative. 

#pagebreak()

= Renderers

== `patatrac.cetz.debug` <cetz.debug>
This renderer is capable of rendering objects of the following types: #patatrac.cetz.standard("functions").keys().sorted().map(k => raw(k)).join(", "). The renderer should be used for debugging purposes only. Independently of the object type, the styling options are

- `length`: length of the tangent line,
- `stroke`: stroke used to draw the tangent and normal lines,
- `fill`: fill color for the label with the anchor's name.

== `patatrac.cetz.standard` <cetz.standard>
This renderer is capable of rendering objects of the following types: #patatrac.cetz.standard("functions").keys().sorted().map(k => raw(k)).join(", "). At the moment, this is the only renderer capable of producing final drawings. We will now list all styling options available for each object type, together with a brief description. (These lists are written by hand, please report any mistake.)

`arrow`:
 - `stroke`: stroke used to draw the arrow body,
 - `mark`: cetz-style mark used to specify how the tail and the tip of the arrow should look.

`axes`:
 - `stroke`: x and y axes stroke,
 - `mark`: x and y axes cetz-style mark,
 - `xstroke`: x axis stroke,
 - `xmark`: x axis mark,
 - `ystroke`: y axis stroke,
 - `ymark`: y axis mark.

`circle`:
 - `stroke`: outline stroke,
 - `fill`: circle's fill,

`incline`:
 - `stroke`: outline stroke,
 - `fill`: incline's fill,

`point`:
 - `radius`: radius of the dot,
 - `stroke`: stroke of the dot,
 - `fill`: fill of the dot,
 - `label`: content of the label,
 - `align`: alignment of the label with respect to the center of the dot (technically it's the opposite but the label position is what is changing),
 - `lx`: after-alignment shift of the label in the global x direction,
 - `ly`: after-alignment shift of the label in the global y direction.

`polygon`:
 - `stroke`: outline stroke,
 - `fill`: polygon's fill.

`rect`:
 - `stroke`: outline stroke (expressed in the style of `std.rect`, see #link("https://typst.app/docs/reference/visualize/rect/#parameters-stroke")[here]),
 - `fill`: rectangle's fill,
 - `radius`: how much to round the corners (expressed in the style of `std.rect`, see #link("https://typst.app/docs/reference/visualize/rect/#parameters-radius")[here]).

`rope`:
 - `stroke`: rope's stroke,

`spring`:
 - `stroke`: curve's stroke,
 - `pitch`: distance between rings,
 - `n`: number of rings,
 - `pad`: minimum amount of space between at start and at the end of the curve which must be occupied, on each side, by a linear segment,
 - `radius`: radius of the rings,
 - `curliness`: how much the rings are visible (either a `ratio` or `none` to indicate that a zig-zag pattern should be used instead of the default coil-like shape),

`terrain`:
 - `stroke`: outline's stroke, 
 - `fill`: terrain's fill, 
 - `epsilon`: distance in domain-space between the points used to approximate the graph (can be a `ratio` or either a number or a length, matching the units used for the domain of the function), 
 - `smooth`: whether to use a hobby curve to smooth between points or interpolate linearly (boolean).


`trajectory`:
 - `stroke`: outline's stroke, 
 - `epsilon`: distance in domain-space between the points used to approximate the curve (can be a `ratio` or either a number or a length, matching the units used for the domain of the function), 
 - `smooth`: whether to use a hobby curve to smooth between points or interpolate linearly (boolean).

#pagebreak()

= Useful lists
In this section you'll find a few useful lists. These lists are generated semi-automatically. 

#let doc(filename, descriptions: false, labels: false) = {
  let docs = tidy.parse-module(read(filename))
  for fun in docs.functions.sorted(key: fun => fun.name) {
    (doc-fun(fun, description: descriptions, label: labels),)
  }
}

== All renderers
This is the complete list of available renderers

- `patatrac.cetz.debug` 
- `patatrac.cetz.standard` 

== All objects and related functions
Here is the list of all object constructors. These are all available directly under the namespace `patatrac`.
#{
  let str = read("src/objects/mod.typ")
  let objects = str.matches(regex("#import\s+\"([^\"]+)\""))
  list(
    ..objects
    .filter(obj => obj.captures.at(0) != "object.typ")
    .map(obj => "src/objects/" + obj.captures.at(0))
    .sorted()
    .map(filename => doc(filename))
    .flatten()
  )
}
Here is the list of all object related functions. These are all available directly under the namespace `patatrac`.
#list(..doc("src/objects/object.typ", descriptions: true, labels: true))

== All anchors related functions
Under the namespace `patatrac.anchors` you can find

#list(..doc("src/anchors.typ", descriptions: true))