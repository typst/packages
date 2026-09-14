#import "@preview/zebraw:0.6.3": zebraw
#import "@preview/rowmantic:0.5.0": rowgrid, rowtable
#import "@preview/tidy:0.4.3"
#import "@preview/codly:1.3.0": *
#import "../src/lib.typ" as sanor

#let info = toml("../typst.toml")

#let mrowgrid = rowgrid.with(gutter: 0.5em)

#let footlink(url, body) = {
  link(url, body)
  footnote(link(url))
}

#let rawfmt(listing, ..args) = {
  let styles = args.named()
  let vars = args.pos()
  let fields = listing.fields()
  let text = fields.remove("text")
  let formatted-text = strfmt(text, ..vars)
  raw(
    ..fields,
    formatted-text,
  )
}

#let code(body, ..args) = {
  set raw(lang: "typc", ..args)
  body
}

#let render-pdf(image-path, pages: 6, n-cols: 3, ..styles) = {
  let imgs = range(1, pages + 1).map(i => {
    place(center + horizon, text(size: 2cm, fill: gray.transparentize(80%), str(i)))
    block(image(image-path, page: i), stroke: 0.5pt + gray)
  })
  grid(gutter: 0.5em, columns: (1fr,) * n-cols, ..imgs, ..styles)
}

#let source-example(path, ..styles) = {
  let content = read(path)
  let read-lines = content.split("\n")
  let start-idx = read-lines.position(a => a.starts-with("// start-example"))
  if start-idx == none { start-idx = 0 } else { start-idx += 1 }
  raw(block: true, read-lines.slice(start-idx, none).join("\n"), lang: "typ", ..styles)
}

#let zebraw = zebraw.with(lang: false)

#let run = eval.with(mode: "code", scope: dictionary(sanor))

#set raw(lang: "typst")
#set par(justify: true)

#show: zebraw
#show raw.where(block: false): box.with(
  fill: gray.transparentize(80%),
  outset: (y: 0.2em),
  inset: (x: 0.3em),
  radius: 0.2em,
)
#show link: set text(fill: blue)
#show link: underline

#align(center)[
  #v(1fr)
  #title[Sanor #info.package.version]
  #info.package.description

  #link("https://github.com/pacaunt/sanor")

  \@pacaunt
  #v(.7in)

  Documentation

  #datetime.today().display()
  #v(.7in)

  *Sanor* is a Thai word meaning 'to present'. \
  This package aims to provide high flexibility in creating animated, rich pdf presentation \ from a small set of simple primitives, that are compatible for any Typst environment.

  #v(0.7in)
  #outline(depth: 2)
  #v(1fr)
]

#pagebreak()

#set page(numbering: "1")
#set heading(numbering: "1.1 ")
#show heading: set block(below: 1.2em)
#show heading.where(level: 3): set heading(numbering: none)

= Introduction

PDF presentation has been there for many decades; it is one of the most basic file that can be shared across platform, and almost all computer can display it. However, pdf cannot display moving components, as it is usually be able to in Powerpoint or other programs.

Therefore, the _animated_ pdf presentation means a set of slides that made from *multiple pdf pages*, each may contain some slight differences, such that when being displayed page-by-page, the elements on it evolve _as if_ they are animated.

There are many good Typst presentation packages out there, so what is the point of using Sanor, or me creating Sanor? Usually, those packages provide convenient interface and functionality for creating simple animated presentation such as `#pause`, `#uncover`, `#only`, or `#alternatives`. Those functions are powerful, it can create limitless squence of animations. However, it is usually limited to using with `#content` type, or cannot be used in `#context` environment, because the management of states that control the animation steps is usually done by _parsing_ and inspecting the content, before modifying it and creating slides.

This package uses a different philosophy: all animations are based on functions that are _pure_ and can return _any_ datatypes. Therefore, technically, Sanor can be used with any datatypes from any packages, getting rid of datatype conflict from package integration entirely.

Moreover, Sanor only have `#pause()` as a function, but all of other functionalities can be obtained through the `#tag()` and *animation rule specification*. So, this package allows user to define their own animation sequence, together with how it will evolve on each step.

A 'slide' consists of multiple frames of animation called 'subslides'. Each element that user wants to make it evolve on each stepping subslide must be covered by using the `#tag(..)` function. User must name that element so that the engine knows which element needs to be modify. Then, user can specify the 'rule' telling what to do with the element (called 'case'). The rule is then push into the animation sequence by `#s.push(rule)`. The modification specified by the rules will be present on each step in the same order according to the `#s` sequence.

With this method, the elements can be hidden, displayed, or modified in limitless number of ways, replacing all conventional pdf animation functions entirely.

#pagebreak()

= Usage
Let's recall the components in an animated presentation.
A 'slide' consists of multiple animation steps shown in each frame called 'subslide'. An element can be tagged and named, and modified by 'rules', containing descriptions of how to change its appearance called 'cases'.
== Initialization
Import this package, and style the page and text as you want. In this tutorial's output, the configuration is as follows:
```
#import "@preview/sanor:0.3.0": *
// Styling
#set page(paper: "presentation-16-9")
#set text(size: 25pt)
// Your content
```

== Creating a slide
There are two methods:
+ Use the `#slide()` function. This is recommended when the `#pause()` and `#tag()` functions are used together, and you need precise control of the animation sequence.
+ Use the `#scene()` function. This is optimized to only be used with `#tag()` function. The syntax is less verbose, but you cannot control the animation sequence freely like the `#slide()` function.

The templates of those functions are as shown:

#mrowgrid(column-width: 1fr, align: center)[
  `#slide()` & `#scene()`
][
  ```
  #slide(s => ([
    // Shorthand to avoid repeating `s`
    #let tag = tag.with(s) 
    // your content goes here
  ], s))
  ```
  &
  ```
  #scene(tag => [
    // your content
  ], controls: (
    // your animation rules
  ))
  ```
]

- The `#slide()` function accepts a function that returns _an array_ of `([BODY], s)`, where `[BODY]` is the content you want to display on the slide, and `s` is the _updated_ state containing the slide's animation sequence, and *is a required* argument for both 'pause' and 'tag' as `#pause(s, ..)` and `#tag(s, ..)`. To avoid repeating `s` in `#tag(s, ..)`, we usually write `#let tag = tag.with(s)` at the beginning of the slide and use this function like `#tag(..)` directly.

- The `#scene()` function accepts a function that returns a content directly, in the form of #raw("tag => body", lang: "typc"). This 'tag' is already contains the `#s` state, so *the `s` is not required* as argument. The tag is used as `#tag(..)` directly, and thus *`#pause(..)` cannot be used in `#scene()`*.

Here is a minimal example of how to use both functions to display the same animation:
#mrowgrid(column-width: 1fr, align: center)[
  `#slide()` & `#scene()`
][
  ```
  #slide(s => ([
    #let tag = tag.with(s)
    #tag("name", [Element])
    // Update here
    #s.push(apply("name"))
  ], s))
  ```
  &
  ```
  #scene(tag => [
    #tag("name", [Element])
  ], controls: (
    apply("name"), // Update here
  ))
  ```
]
In this example, `#apply("name")` is called a _rule_. A _rule_ is a statement that tells what to do on which tagged element. In this case, the `#apply("name")` means to 'apply' (show) the element named #code(`"name"`) on the slide. In the `#slide()` function, the rule is specified in order by pushing it into `#s`, while in the `#scene()` function, it is specified in the `controls` argument instead.

The following sections will use the `#slide()`-like syntax with the shorthand 
```
#let tag = tag.with(s)
``` 
at the beginning of the slide, as it is more explicit and flexible. Please make sure to include such line of code be cause the default `tag` function *requires* the animation sequence `s` as the first positional argument. 

== Modifying Elements

Elements that can modified on the slide must be tagged and named, as
```
#tag(s, "name", [Element]) // or 
#let tag = tag.with(s)     // Shorthand applied
#tag("name", [Element])   
```
Then, it can be modified by specifying some rules. A rule has the following anatomy
```typc
rule("name", ..cases)
```
where the `cases` means the modifiers that will apply on the element named #code(`"name"`) in the subslides and alter its visibility according to the 'rule'. The modifiers can be many things, the simplest ones are
- functions to wrap the element, or
- another element to replace the original tagged element.
For example, #code(`apply("name", text.with(fill: red))`) makes the text in the element #code(`"name"`) become red from this and the subsequent subslides. Normally, the tagged elements are hidden until the rules that can reveal the element are applied. The #code(`apply("name")`) also can be used to make the  element #code(`"name"`) become visible. Moreover, the `apply` rule can be used to 'apply' more modifiers to the element in the next steps, for example,
```
#s.push(apply("name"))                       // shows [Element]
#s.push(apply("name", text.with(fill: red))) // shows red [Element]
#s.push(apply("name", strong))               // shows red and bold [Element]
```
The full example of this slide would be
#source-example("../assets/example1.typ")
#render-pdf("../assets/example1.pdf", pages: 3)

== Rule Specification
=== A Quick Tutorial
Let's say we want to hide an element #code(`"name"`) first, then display it after, make it red, emphasize it once, and revert it to its base form. These visible states can be specified by using _rules_. For this example, the rules that involved are
- #code(`cover("name")`) makes an element hidden in this and subsequent steps,
- #code(`apply("name", text.with(fill: red))`) for making its text red,
- #code(`once("name", emph)`) applies the `#emph()` function to the element once,
- #code(`revert("name")`) reverts the element back to its base form, before applying anything.
After creating a new slide from the template and tagging the element, we now should have
```
#slide(s => ([
  #let tag = tag.with(s)
  #tag("name", [Element])
  // We will specify the rule here
], s))
```
Actually, tagged elements are hidden by default, but for this tutorial, we will  make the element hidden by specifying an explicit rule. To do this, the #code(`cover("name")`) is added  in the animation sequence `#s`:
```
#slide(s => ([
  #let tag = tag.with(s)
  #tag("name", [Element])
  // We will specify the rule here
  #s.push(cover("name"))
], s))
```
Now, the element #code(`"name"`) is hidden on the first subslide. Then, to show the element on the next slide, just push the #code(`apply("name")`) next, as
```
#slide(s => ([
  #let tag = tag.with(s)
  #tag("name", [Element])
  // We will specify the rule here
  #s.push(cover("name"))
  #s.push(apply("name")) // <-- make it shown
], s))
```
This rule creates a new subslide, with the element shown. The other steps' modification to the element are specified in the same manner, so you should have something like (stripping the slide environment)
```
#s.push(cover("name"))                        // on subslide 1
#s.push(apply("name")) // display it          // on subslide 2
#s.push(apply("name", text.with(fill: red)))  // on subslide 3
#s.push(once("name", emph))                   // on subslide 4
#s.push(revert("name"))                       // on subslide 5
```
However, let's add a _blank_ animation, i.e., a subslide that we do not specify any rule on it, but let the animation sequence happens on its own. In the algorithm, this rule will just add a new subslide, but since #code(`once("name", emph)`) rule applies only once, adding this blank subslide will make the result clear that the modification from #code(`once("name", emph)`) is gone. We can do this by pushing an empty array to the sequence as
```
#s.push(cover("name"))                        // on subslide 1
#s.push(apply("name")) // display it          // on subslide 2
#s.push(apply("name", text.with(fill: red)))  // on subslide 3
#s.push(once("name", emph))                   // on subslide 4
// Do nothing, to see that the once's effect is gone
#s.push(())                                   // on subslide 5
#s.push(revert("name"))                       // on subslide 6
```

The full example of this usage is shown here

#source-example("../assets/example-rules.typ")
#render-pdf("../assets/example-rules.pdf", pages: 6)

=== Properties of A Rule

The more proper explanation of rules' ability is the following. A rule can control the visible state of an element by three properties:
+ _active_ : The rule that has #code(`active: true`) can make the element _visible_, #code(`active: false`) hide the element, and #code(`active: auto`) follows the visibility from the previous active rules.
+ _remain_ : Control whether the modification remains in the subsequent subslides. #code(`remain: true`) means the modification remains.
+ _inherit_ : Control whether to combine the current modification to the previous from the active rules. #code(`inherit: true`) means the modifications are comined.
These properties explain the role of the following rules:

#{
  set raw(lang: "typc")
  set align(center)
  // show table.cell.where(body: []): set table.cell(inset: 0em)
  rowtable(
    stroke: none,
    align: (left, center, center, center),
    table.hline(),
    table.header[rules][active][remain][inherit],
    table.hline(),
    [`apply(name, ..cases)` & `true` & `true` & `true`],
    [`once(name, ..cases)` & `true` & `false` & `true`],
    [`cover(name, ..cases)` & `false` & `true` & `true`],
    [`revert(name, ..cases)` & `auto` & `true` & `false`],
    [`force(name, ..cases)` & `true` & `true` & `false`],
    [`clear(name, ..cases)` & `auto` & `true` & `false`],
    table.hline(),
  )
}

These properties can be modified in all rule functions, except `#clear()`, by specifying #code(`active: (bool), remain: (bool), inherit: (bool)`) when calling them.
However, some rules have their own special effects:
- #code(`clear()`) will clear _all_ previous modifications done to the element.
- #code(`revert()`) will display the element in its base form, but the modification history is intact. Therefore, when the next `apply` or other rules that has #code(`inherit: true`), the old modifications will come back.
- #code(`once()`) can make the element visible only once (and hidden thereafter), if it is the last active rule of that element.
The difference of using #code(`revert("name")`) and #code(`clear("name")`) are shown in the following examples:

#source-example("../assets/example-revert.typ")
#render-pdf("../assets/example-revert.pdf", pages: 5)

So, #code(`revert("name")`) *does not clear* the modification history, as on the subslide 5 the modified element came back just like the one before the `revert` call. Let's compare this to the `clear` rule:

#source-example("../assets/example-clear.typ")
#render-pdf("../assets/example-clear.pdf", pages: 5)

The element after #code(`clear("name")`) stays like the base form. It does not change back to the modified one displayed in the subslide 3, as `clear` does clear the modification history of the element.

=== Same Tag -- Same Fate
Tagged elements in the same slide that have the same name will transform in the same way by the same rules. For example, let's say we want to show simplifying the equation
$ (x (x + 1))/(2(x + 1)) $
by showing the common parts $(x + 1)$ as
- red text in the subslide 2,
- cancel text in the subslide 3,
- eliminate text in the subslide 4
Since the $(x + 1)$ will undergo the same process, we can tag them with the same name and specify the rules with that name, like this

#source-example("../assets/example-simp-math.typ")
#render-pdf("../assets/example-simp-math.pdf", pages: 4)

=== Specifying Multiple Rules
On a slide, you may have many elements that should be transformed together in some steps. Multiple rules in the same step can be specified by using _an array of rules_ instead. Let's say we want to make the following animation
#render-pdf("../assets/example-two-rects.pdf", pages: 2)
First, initialize the slide and create the rectangle by
```
#slide(s => ([
  #let tag = tag.with(s)
  = Two Rects
  #grid(
    columns: (1fr, 1fr), align: center,
    tag("rect1", rect(width: 2in, height: 1in)),
    tag("rect2", rect(width: 2in, height: 1in)),
  )
], s))
```
Then, to show the rectangles, the `apply` rules are combined in an array and pushed into `#s` as
```
#s.push((apply("rect1"), apply("rect2")))
```
Similarly, the red and blue rectangles are also shown by replacing the old ones with another `apply` rule that contains the new rectangles. The second subslide are obtained by adding this line:
```
#s.push((
  apply("rect1", rect(width: 2in, height: 1in, fill: red)),
  apply("rect2", rect(width: 2in, height: 1in, fill: blue))
))
```
Therefore, multiple rules can be executed in the same step by *combining them in an array* before pushing it to the sequence `#s`.

The full code of this example is shown here:
#source-example("../assets/example-two-rects.typ")
Later in this documentation, the method that can actually modify the properties of tagged elements will be introduced, so that the color of the rectangles can be changed without creating new ones.

== Timeline and Pause
The animation sequence `#s` contains the sequence of rules, and also can can contain the information about the timeline of the animation. In a basic sequence that only contains the rules, each step will create one subslide except for the first step which will be shown in the first subslide (not creating a new one).

Apart from pushing `()` to create an empty rule that forces one subslide, you can pushing _integers_ like #code(`1`), #code(`2`), to create that number of subslides. For example
```
#s.push(once("A"))
#s.push(2) // shift the next subslide to execute the next rule
#s.push(once("B"))
```
will cause the element #code(`"A"`) to be visible on subslide 1, and element #code(`"B"`) to be visible on subslide 4 (2, and 3 are _skipped_ by the #code(`s.push(2)`)). This is useful for creating step-by-step reveal with `#pause()` function, like this

#source-example("../assets/example-pause.typ")
#render-pdf("../assets/example-pause.pdf", pages: 3)

The showing sequence of contents that are tagged and paused will follows the sequence in `#s`. The integer skips the subslide and push the animation to the next subslide. Moreover, the _negative_ integer also can be specified, to move the next rule/pause execute earlier than the current subslide, e.g.
```
#s.push(apply("A")) // shown on subslide 1
#s.push(apply("B")) // shown on subslide 2
#s.push(-1)         // shift the next animation to 1 subslide eariler
#pause(s)[Content]  // shown on subslide 2, instead of 3
#s.push(1)          // should create subslide 3, but got shifted to 2.
```
For a full example of this usage:
#source-example("../assets/example-negative.typ")
#render-pdf("../assets/example-negative.pdf", pages: 2)

== Objects and Cases
=== Animate with Objects
*Objects* are reusable element that can have multiple forms called _cases_ and can be modified from the ground up. To create an object, use the `#object(func)` where `func` is any element function which will be used to create the display. For example,
```
#let my-rect = object(rect)
```
`my-rect` becomes a Sanor object that will use `rect` function to display. Objects cannot display directly on the slide, they have to be inside a `#tag()` function. So, `my-rect` needs to be displayed as
```
// Don't forget `#let tag = tag.with(s)` for `#slide(..)`.
#tag("name", my-rect())
```
The advantage of using object as element in the tag is the element can be modified way more flexible. The apparent thing that objects can do but other elements cannot is modifying the properties that must be specified as arguments like `stroke` and  `fill`. To do this, you can write
```
#s.push(apply("name", fill: red))
```
to make the `my-rect` red filled! Thus, *any keyword properties in the defined object can be modified through rules*. Revisting the example of changing the rectangles' colors, we can write
```
#let my-rect = object(rect.with(width: 2in, height: 1in))
```
and use it as
```
#grid(
  columns: (1fr, 1fr), align: center,
  tag("rect1", my-rect()),
  tag("rect2", my-rect())
)
#s.push((apply("rect1"), apply("rect2")))
#s.push((
  apply("rect1", fill: red),  // Change the fill directly!
  apply("rect2", fill: blue),
))
```
Note that the created object is used as if it is a normal element. You can add the styling arguments or positional argument as usual.
From the snippet, the following result is obtained.
#render-pdf("../assets/example-objects.pdf", pages: 2)

=== Advanced Modification: `#case()` function
The created object can also be modified by wrapping it with functions. To combine the keyword properties like #code(`stroke: red, fill: green`) and functions like #code(`rotate()`), #code(`align()`), the `#case()` function is used as
```typc
case(stroke: red, fill: green, rotate.with(45deg), align.with(center)
```
- The functions are positional argumets, and
- keyword properties are keyword arguments of the `case` function.
Then, the created case can be used in rules like
```
#s.push(apply(
  "name",
  case(stroke: red, fill: green, rotate.with(45deg), align.with(center)
))
```
=== Predefined Cases
Some modification that are used very often can be named within the object/tag so that it can be applied by calling the case's name. Let's see this usage from the following example.
#zebraw(source-example("../assets/example-named-case.typ"), line-range: (5, 18))
#render-pdf("../assets/example-named-case.pdf", pages: 3)
There are some important cases that are predefined by default for all tagged elements:
+ #code(`"hidden"`) case: the modification when the element is hidden. It is some kind of `hide` function by default, but you can change it by redefining this in object initialization.
+ #code(`"base"`) case: no modification. This is the case that will be used whenever the object is display but no modification is specified.

=== Components -- Object's Shortcut
Since the created object must be used with `tag` function, so why don't we combine them?---Here it is, the `#component` module. This module will let you create object that can be used directly in one function. You can use `#component.new(name, func)` to create a new component function, where `name` is the _default_ name of the created (internal) object and `func` is the element function like initializing a new object. For example,
```
#let my-rect = component.new("rect", rect.with(fill: green))
// Change `s` to `tag` if you are using `#scene()`
#my-rect(s, [MY GREEN RECT])
#my-rect(s, [MY RED RECT], fill: green, name: "red-rect")
```
Note that all component will have `name` keyword argument for naming the object and being used internally by tag. The default is the one declared in the #code(`component.new()`). Like objects, you can define cases and modify it with rules in the same way, e.g.
```
#s.push(apply("rect")) // shows the MY GREEN RECT
#s.push(apply("red-rect", rotate.with(45deg)))
```

=== Predefined Components
You can import the 'mcomps' module containing predefined markup components for drawing basic stuff like rectangle, circle, block, etc. These defined components have the same name as the standard Typst's but are prefixed with `m`, like `mrect` for `rect`, `mcircle` for circle, `mline` for `line`.

This package also contains predefined components from CeTZ package. All element drawing functions in the 'draw' module of CeTZ are available with prefix of `c` like `ccontent`, `ccircle`, `cline`, `crect`. The CeTZ elements are hidden by CeTZ's `hide` function by default, and *you can use the element's name* to refer in the rule specification too.
#zebraw(source-example("../assets/example-ccomps.typ"), line-range: (2, -1))
#render-pdf("../assets/example-ccomps.pdf", pages: 4, n-cols: 2)
// Don't forget to tell about the ccomps and mcomps

== Utility
=== Magic selector
#code(`select(element)`) function accepts common elements that are created with element functions and generates a selector that is precise for styling specific element. For example,
#let src = ```
#show select($a$): set text(fill: red)
a // not selected
$a$ // selected

```
#grid(
  columns: (1fr, .5fr),
  gutter: 1em,
  src, run(src.text, mode: "markup"),
)
This usually works with 'grouped' elements like `$a^x$`, `$a_x$`, `$(..)$`, `block`, `rect` and so on. However, the 'sequential' elements like `$x + y$` do not work as expected, because Typst may collapse the sequence with another surrounding sequence making the element not detectable. 
=== Ppfpc Integration 
This package imports the Polylux's pdfpc module and integrated within the slide function. To use this feature, please refer to their package:
#link("https://polylux.dev/book/external/pdfpc.html").

== Configuration
=== Global Options & Handout Mode
You can set some default behavior of the functions by setting the slide options as 
```
#let (slide,) = set-option(..options)
```
or 
```
#slide(
  options: (..options),
  s => ([ /* body */], s)
)
```
The available options are 
- `handout` default: #code(`false`), the handout mode. By default, the handout slide will present only the last subslide. This can be changed by setting `handout-index` to the desired subslide.
- `handout-index` default: #code(`auto`) the index of the subslide used in the handout mode. Note that the first subslide's index is #code(`1`) NOT 0.
- `..new-options` the other configuration that will passed to the slide/scene function.

=== Slide Options
The following keyword arguments can be passed to the slide/scene function to set some defaults.
- `defined-cases` accepts a dictionary in the form of 'name: case'. The name of cases defined here can be referred when applying rules.
  
- `hidden` accepts a function or a case. This will be applied on the element when it is hidden by default. The default function is a modified `hide` that can hide lists and enums.
- #code(`is-shown: false`) Whether to display the tagged elements by default. If this is set to #code(`false`), the tagged elements are hidden until any active rule is applied.

Here is an example of how to write slide-level predefined cases.

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

== Examples 
=== Syncing Animation 
#source-example("../gallery/example-sync.typ")
#render-pdf("../assets/example-sync.pdf", pages: 3, n-cols: 2)

=== Math Animation 
#source-example("../gallery/example-math.typ")
#render-pdf("../assets/example-math.pdf", pages: 4, n-cols: 2)

=== Code Animation 
Integration with Zebraw package.
#source-example("../gallery/example-code.typ")
#render-pdf("../assets/example-code.pdf", pages: 2, n-cols: 2)

=== Multiple Objects & Cases
Using rules and pauses together
#source-example("../gallery/example-case.typ")
#render-pdf("../assets/example-case.pdf", pages: 7, n-cols: 2)

=== Magic Selector Example 
Integration with chemformula.
#source-example("../gallery/example-chem.typ")
#render-pdf("../assets/example-chem.pdf", pages: 5, n-cols: 2)

= References
#set heading(numbering: none)
#show heading.where(level: 2): it => {
  set align(center)
  block(smallcaps(it), width: 100%, stroke: (bottom: 0.5pt), inset: (bottom: 0.3em))
}
#show heading.where(level: 3): it => {
  set align(center)
  raw(it.body.text)
}
== Sanor Module
#let docs-sanor = tidy.parse-module({
  read("../src/sanor.typ")
  read("../src/selector.typ")
})
#tidy.show-module(docs-sanor)

== Rules Module
#let docs-rules = tidy.parse-module(read("../src/rules.typ"))
#tidy.show-module(docs-rules, )

== Object-case Module
#let docs-object = tidy.parse-module(read("../src/object-case.typ"))
#tidy.show-module(docs-object)

== Components Module
#let docs-components = tidy.parse-module({
  read("../src/components/component.typ")
  read("../src/components/ccomps.typ")
  read("../src/components/mcomps.typ")
})
#tidy.show-module(docs-components)

== Pdfpc Module 
#let docs-pdfpc = tidy.parse-module(read("../src/pdfpc.typ"))
#tidy.show-module(docs-pdfpc)