# `rich-counters`

This package allows you to have **counters which depend on other counters**.

Concretely, it implements `rich-counter`, which is a counter that can _inherit_ one or more levels from another counter.

The interface is pretty much the same as the [usual counter](https://typst.app/docs/reference/introspection/counter/).
It provides a `display()`, `get()`, `final()`, `at()`, and a `step()` method.
An `update()` method will be implemented soon.

## Simple typical Showcase

In the following example, `mycounter` inherits the first level from `heading` (but not deeper levels).
```typ
#import "@preview/rich-counters:0.2.0": *

#set heading(numbering: "1.1")
#let mycounter = rich-counter(identifier: "mycounter", inherited_levels: 1)

// DOCUMENT

Displaying `mycounter` here: #context (mycounter.display)("1.1")

= First level heading

Displaying `mycounter` here: #context (mycounter.display)("1.1")

Stepping `mycounter` here. #(mycounter.step)()

Displaying `mycounter` here: #context (mycounter.display)("1.1")

= Another first level heading

Displaying `mycounter` here: #context (mycounter.display)("1.1")

Stepping `mycounter` here. #(mycounter.step)()

Displaying `mycounter` here: #context (mycounter.display)("1.1")

== Second level heading

Displaying `mycounter` here: #context (mycounter.display)("1.1")

Stepping `mycounter` here. #(mycounter.step)()

Displaying `mycounter` here: #context (mycounter.display)("1.1")

= Aaand another first level heading

Displaying `mycounter` here: #context (mycounter.display)("1.1")

Stepping `mycounter` here. #(mycounter.step)()

Displaying `mycounter` here: #context (mycounter.display)("1.1")
```
![](example.png)

## Construction of a `rich-counter`

To create a `rich-counter`, you have to call the `rich-counter(...)` function.
It accepts three arguments:

- `identifier` (required)

  Must be a unique `string` which identifies the counter.

- `inherited_levels`

  Specifies how many levels should be inherited from the parent counter.

- `inherited_from` (Default: `heading`)

  Specifies the parent counter. Can be a `rich-counter` or any key that is accepted by the [`counter(...)` constructor](https://typst.app/docs/reference/introspection/counter#constructor), such as a `label`, a `selector`, a `location`, or a `function` like `heading`.
  If not specified, defaults to `heading` (and hence it will inherit from the counter of the headings).

  If it's a `rich-counter` and `inherited_levels` is _not_ specified, then `inherited_levels` will default to one level higher than the given `rich-counter`.

For example, the following creates a `rich-counter` `foo` which inherits one level from the headings, and then another `rich-counter` `bar` which inherits two levels (implicitly) from `foo`.

```typ
#import "@preview/rich-counters:0.2.0": *

#let foo = rich-counter(identifier: "foo", inherited_levels: 1)
#let bar = rich-counter(identifier: "bar", inherited_from: foo)
```

## Usage of a `rich-counter`

- `display(numbering)` (needs `context`)

  Displays the current value of the counter with the given numbering style. Giving the numbering style is optional, with default value `"1.1"`.

- `get()` (needs `context`)

  Returns the current value of the counter (as an `array`).

- `final()` (needs `context`)

  Returns the value of the counter at the end of the document.

- `at(loc)` (needs `context`)

  Returns the value of the counter at `loc`, where `loc` can be a `label`, `selector`, `location`, or `function`.

- `step(depth: 1)`

  Steps the counter at the specified `depth` (default: `1`).
  That is, it steps the `rich-counter` at level `inherited_levels + depth`.

**Due to a Typst limitation, you have to put parentheses before you put the arguments. (See below.)**

For example, the following steps `mycounter` (at depth 1) and then displays it.
```typ
#import "@preview/rich-counters:0.2.0": *
#let mycounter = rich-counter(...)

#(mycounter.step)()
#context (mycounter.display)("1.1")
```

## Limitations

Due to current Typst limitations, there is no way to detect direct updates or steps of Typst-native counters, like `counter(heading).update(...)` or `counter(heading).step(...)`.
Only occurrences of actual `heading`s can be detected.
So make sure that after you call e.g. `counter(heading).update(...)`, you place a heading directly after it, before you call any `rich-counter`s.

## Roadmap

- implement `update()`
- use Typst custom types as soon as they become available
- adopt native Typst implementation of dependent counters as soon it becomes available
