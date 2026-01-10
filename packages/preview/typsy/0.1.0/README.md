<h1 align='center'>typsy</h1>
<h3 align='center'>Classes/structs, pattern matching, safe counters... and more!<br>Your one-stop library for programming tools not already in core Typst.</h3>

---

_Pronounced 'tipsy', because I think that's funny and it's a nice pun on 'Typst'._ 😄

Provides tools for programming geeks:

- classes (i.e. structs, custom types)
- pattern matching
- enums
- safe counters (no need to choose a unique string)
- trees-of-counters (i.e. subcounters)
- string formatting
- namespaces of objects that can be mutually referential
- runtime type checking

## Installation

Typst will autodownload packages on import:
```typst
#import "@preview/typsy:0.1.0"
```

## What's in the box?

### Classes

Classes with fields and methods:
```typst
#import "@preview/typsy:0.1.0": class

#let Adder = class(
    fields: (x: int),
    methods: (
        add: (self, y) => {self.x + y}
    )
)
#let add_three = (Adder.new)(x: 3)
#let five = (add_three.add)(2)
```

### Pattern-matching

Simple type checking:
```typst
#import "@preview/typsy:0.1.0": Array, Int, matches

// Fixed-length case.
#matches(Array(Int, Int), (3, 4)) // true
// Variable-length case.
#matches(Array(..Int), (3, 4, 5, "not an int")) // false
```

More complicated match-case statements:
```typst
#import "@preview/typsy:0.1.0": Arguments, Int, Str, case, match, matches

// Option 1: if/else
#let fn-with-multiple-signatures(..args) = {
    if matches(Arguments(Int), args) {
        // ...
    } else if matches(Arguments(Str), args) {
        // ...
    } else if matches(Arguments(Str, level: Int), args) {
        // ...
    } else {
        panic
    }
}

// Option 2: match/case
#let fn-with-multiple-signatures(..args) = {
    match(args,
        case(Arguments(Int), ()=>{
            // ...
        }),
        case(Arguments(Str), ()=>{
            // ...
        }),
        case(Arguments(Str, level: Int), ()=>{
            // ...
        }),
    )
}
```

Observe the capitalisation. All patterns are capitalised to distinguish them from their corresponding type.

### Enums

Also using the same pattern-matching capabilities as above:
```typst
#import "@preview/typsy:0.1.0": case, class, enumeration, match

#let Shape = enumeration(
    Rectangle: class(fields: (height: int, width: int)),
    Circle: class(fields: (radius: int)),
)
#let area(x) = {
    match(x,
        case(Shape.Rectangle, ()=>{
            x.height * x.width
        }),
        case(Shape.Circle, ()=>{
            calc.pi * calc.pow(x.radius, 2)
        }),
    )
}
```

### Safe counters

Counters without needing to cross your fingers and hope that you're using a unique string each time:
```typst
#import "@preview/typsy:0.1.0": safe-counter

#let my-counter1 = safe-counter(()=>{})
#let my-counter2 = safe-counter(()=>{})
// ...these are different counters!
// (All anonymous functions have different identities to the compiler.)
```

### Tree counters / subcounters

Create trees of counters, including using existing counters as starting points. This is particularly useful for creating theorem counters that increment with the heading.
```typst
#import "@preview/typsy:0.1.0": tree-counter

// Set up counters
#let heading-counter = tree-counter(heading, level: 1)
#let theorem-counter = (heading-counter.subcounter)(()=>{})  // uses safe-counter internally!
#let corollary-counter = (theorem-counter.subcounter)(()=>{})

// Usage
#set heading(numbering: "1")
#let theorem(doc) = [Theorem #(theorem-counter.take)(): #doc]
#let corollary(doc) = [Corollary #(corollary-counter.take)(): #doc]
= First Section
#theorem[Let ...]  // Theorem 1.1: Let ...
#theorem[Let ...]  // Theorem 1.2: Let ...
#corollary[Let ...] // Corollary 1.2.1: Let ...
= Second Section
#theorem[Let ...] // Theorem 2.1: Let ...
```

### String formatting

Rust-like string formatting:
```typst
#import "@preview/typsy:0.1.0": fmt, panic-fmt

#let msg = fmt("Invalid input `{}`, expected `{}`.", foo, bar)

// shorthand for `panic(fmt(...))`
#panic-fmt("Invalid input `{}`, expected `{}`.", foo, bar)
```

### Runtime type checking

Wrap functions to check their inputs and outputs. This builds on top of the pattern-matching capablities above.
```typst
#import "@preview/typsy:0.1.0": Arguments, typecheck

#let add_integers = typecheck(Arguments(Int, Int), Int, (x, y) => x + y)
#let five = add_integers(2, 3)  // ok
#add_integers("hello ", "world")  // panic!
```

### Namespaces of mutually-referential objects

Build a namespace by providing lambda functions which return their object. Access any object in a namespace via `ns(object-name)`:
```typst
#import "@preview/typsy:0.1.0": namespace

#let ns = namespace(
    foo: ns => {
        let foo(x) = if x == 0 {"FOO"} else {ns("bar")(x - 1)}
        foo
    },
    bar: ns => {
        let bar(x) = if x == 0 {"BAR"} else {ns("foo")(x - 1)}
        bar
    },
)
#let foo = ns("foo")
#assert.eq(foo(3), "BAR")
#assert.eq(foo(4), "FOO")
```
For example, this can be used to implement mutually-recursive functions.

## Documentation

All objects have detailed docstrings indicating their usage; see those for details.

The examples above demonstrate nearly every object in the public API. In addition to those above, the list of patterns that can be used for pattern-matching are:
```typst
Any, Arguments, Array, Bool, Bytes, Class, Content, Counter, Datetime, Decimal,
Dictionary, Duration, Float, Function, Int, Label, Literal, Location, Module,
Named, Never, None, Pos, Ratio, Refine, Regex, Selector, State, Str, Symbol,
Type, Union, Version
```
(They are capitalised to distinguish them from the underlying type.)

## FAQ

**Similar libraries:**

- [elembic](https://github.com/pgbiel/elembic) offers a very different way to create custom classes.
- [valkyrie](https://github.com/typst-community/valkyrie) offers object parsing that is somewhat similar to our type matching.
- [headcount](https://github.com/jbirnick/typst-headcount) and [rich-counters](https://typst.app/universe/package/rich-counters/) also offer tree counters. (Though I find our approach a bit simpler, and safer due to our `()=>{}`-using safe counters.)
- [oxifmt](https://github.com/PgBiel/typst-oxifmt) offers Rust-like string formatting. Theirs is far more developed and better than what we have; I just like avoiding dependencies.
