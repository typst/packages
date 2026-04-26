#import "@preview/tidy:0.2.0"

#import "template.typ": *

#import "../src/lib.typ" as sp

#let package-meta = toml("../typst.toml").package
// #let date = none
#let date = datetime(year: 2024, month: 2, day: 23)

#show: project.with(
  title: "Stack Pointer",
  // subtitle: "...",
  authors: package-meta.authors.map(a => a.split("<").at(0).trim()),
  abstract: [
    _Stack Pointer_ is a library for visualizing the execution of (imperative) computer programs, particularly in terms of effects on the call stack: stack frames and local variables therein.
  ],
  url: package-meta.repository,
  version: package-meta.version,
  date: date,
)

// the scope for evaluating expressions and documentation
#let scope = (sp: sp)

#let exec-example(sim-code, typst-code, render) = {
  let preamble = ```typc
  import sp: *

  ```
  let steps = eval(mode: "code", scope: scope, preamble.text + typst-code.text)
  block(breakable: false, {
    grid(columns: (2fr, 3fr), sim-code, typst-code)
  })
  render(steps)
}

#let exec-grid-render(columns: none, steps) = {
  if columns == none { columns = steps.len() }
  let steps = steps.enumerate(start: 1)

  let render((n, step), width: auto, height: auto) = block(
    width: width,
    height: height,
    fill: gray.lighten(80%),
    radius: 0.2em,
    inset: 0.4em,
    breakable: false,
    {
      [Step #n: ]
      if step.step.line != none [line #step.step.line]
      else [(no line)]
      v(-0.5em)
      list(..step.state.stack.map(frame => {
        frame.name
        if frame.vars.len() != 0 {
          [: ]
          frame.vars.pairs().map(((name, value)) => [#name~=~#value]).join[, ]
        }
      }))
    }
  )


  style(styles => {
    let rows = range(steps.len(), step: columns).map(i => {
      steps.slice(i, calc.min(steps.len(), i + columns))
    })

    grid(
      columns: (1fr,) * columns,
      column-gutter: 0.4em,
      row-gutter: 0.4em,
      ..for row in rows {
        let height = row.map(step => measure(render(step), styles).height).fold(0pt, calc.max)
        row.map(render.with(width: 100%, height: height))
      }
    )
  })
}

#show raw: it => {
  if it.lang == none {
    let (text, lang: _, lines: _, ..fields) = it.fields()
    raw(text, lang: "typc", ..fields)
  } else {
    it
  }
}
#let ref-line(n) = {
  show raw: set text(fill: gray, size: 0.9em)
  raw(lang: "", "("+str(n)+")")
}

= Introduction

_Stack Pointer_ provides tools for visualizing program execution. Its main use case is for presentations using frameworks such as #link("https://polylux.dev/book/")[Polylux], but it tries to be as general as possible.

There are two main concepts that underpin Stack Pointer: _effects_ and _steps_. An effect is something that changes program state, for example a variable assignment. Right now, the effects that are modeled by this library are limited to ones that affect the stack, giving it its name, but more possibilities would be interesting as well. A step is an instant during program execution at which the current program state should be visualized.

Collectively, these (and a few similar but distinct entities) make up _execution sequences_. In this documentation, _sequence item_ or just _item_ means either an effect or a step, or depending on context also one of these similar entities.

Stack Pointer helps build these execution sequences, calculating the list of states at the steps of interest, and visualizing these states.

= Examples

As the typical use case is presentations, where the program execution would be visualized as a sequence of slides, the examples here will necessarily be displayed differently. So, don't let the basic appearance here fool you: it is up to you how to display Stack Pointer's results.

== Setting a variable

The possibly simplest example would be visualizing assigning a single variable, then returning . Let's do this and look at what's happening exactly:

#exec-example(
  ```c
  int main() {
    int a = 0;
    return 0;
  }
  ```,
  ```typc
  execute({
    l(1, call("main"))
    l(2); l(2, push("a", 0))
    l(3); l(none, ret())
  })
  ```,
  exec-grid-render.with(columns: 5),
)

A lot is going on here: we're using #ref-fn("execute()") to get the result of an execution sequence, which we created with multiple #ref-fn("l()") calls. Each of these calls first applies zero or more effects, then a step that can be used to visualize the execution state. We use steps without effects to change to lines 2 and 3 before showing what these do, for example. For line 1, we don't do that and instead immediately add the `call("main")` effect, because we want the main stack frame from the beginning. For the final step that returns from main, we don't put a line number because it's not meaningful anymore. Not specifying a line number is also useful for visualizing calls into library functions.

The simple visualization here -- listing the five steps (one per `l()` call) in a grid -- is _not_ part of Stack Pointer itself; it's done directly in this manual in a way that's appropriate for this format. The information in each step -- namely, the line numbers, stack frames, and local variables for each stack frame -- _are_ provided by Stack Pointer though.

== Low-level functions for effects and steps

The `l()` function is usually the appropriate way for defining execution sequences, but sometimes it makes sense to drop down a level. Here's the same code, represented with only the low-level functions of Stack Pointer.

#exec-example(
  ```c
  int main() {
    int a = 0;
    return 0;
  }
  ```,
  ```typc
  execute({
    call("main"); step(line: 1)
    step(line: 2)
    push("a", 0); step(line: 2)
    step(line: 3)
    ret(); step(line: none)
  })
  ```,
  exec-grid-render.with(columns: 5),
)

Apart from the individual function calls, one difference can be seen: the #ref-fn("step()") function takes only named arguments; in fact, a bare step doesn't even _have_ to have a line; `l()` just has it because it's very common to need it. For use cases where line numbers are not needed but `l()` seems like a better fit, just define your own variant using the #ref-fn("bare-l()") helper, e.g.: `let l(id, ..args) = bare-l(id: id, ..args)` -- now you can call this with `id` as a positional parameter.

== Calling functions (the manual way)

Regarding the call stack, a single function is not particularly interesting; the fun begins when there are function calls and thus multiple stack frames. Without additional high-level function tools, this can be achieved as follows:

#exec-example(
  ```c
  int main() {
    foo(0);
    return 0;
  }

  void foo(int x) {
    return;
  }
  ```,
  ```typc
  execute({
    let foo(x) = {
      l(6, call("foo"), push("x", x))
      l(7); ret()  // (1)
    }
    let main() = {
      l(1, call("main"))
      l(2); foo(0); l(2)  // (2)
      l(3); l(none, ret())  // (3)
    }
    main()
  })
  ```,
  exec-grid-render.with(columns: 5),
)

As soon as we're working with functions, it makes sense to represent every example function with an actual Typst function. `foo()` comes first because of how Typst resolves names (for mutually recursive functions this doesn't work, and Typst currently #link("https://github.com/typst/typst/issues/744")[doesn't seem to support it]). The execution sequence is ultimately constructed by calling `main()` once.

The `foo()` function contains its own #ref-fn("call()") and #ref-fn("ret()") effects, so that these don't need to be handled at every call site. There's a small asymmetry though: the return effect at #ref-line(1) is not added via `l()` and thus not immediately followed by a step. After returning, the line where execution resumes depends on the caller, so the next step is generated by `main()` at #ref-line(2), with a line within the C `main()` function.

An exception to this is the `main()` function itself: at #ref-line(3), we generate a step (with line `none`) because here it is clear where execution will resume - or rather, that it _won't_ resume.

== Calling functions (the convenient way)

Some of this function setup is still boilerplate, so Stack Pointer provides a simpler way, using #ref-fn("func()"):

#exec-example(
  ```c
  int main() {
    foo(0);
    return 0;
  }

  void foo(int x) {
    return;
  }
  ```,
  ```typc
  execute({
    let foo(x) = func("foo", 5, l => {
      l(0, push("x", x))
      l(1)
    })
    let main() = func("main", 1, l => {
      l(0)
      l(1); foo(0); l(1)
      l(2)
    })
    main(); l(none)
  })
  ```,
  exec-grid-render.with(columns: 5),
)

`func()` brings two conveniences: one, you put your implementation into a closure that gets an `l()` function that interprets line numbers relative to a first line number (for example, line 5 for `foo()`). This makes it easier to adapt the Typst simulation if you change the code example it refers to. Two, the `call()` and `ret()` effects don't need to be applied manually.

The downside is that this uniform handling means that we needed to manually add the last step after returning from `main()`.

== Using return values from functions

The convenience of mapping example functions to Typst functions comes in part from mirroring the logic: instead of having to track specific parameter values in specific calls, just pass exactly those values in Typst calls. Return values are an important part of this, but they need a bit of care:

#exec-example(
  ```c
  int main() {
    int x = foo();
    return 0;
  }

  int foo() {
    return 0;
  }
  ```,
  ```typc
  execute({
    let foo() = func("foo", 6, l => {
      l(0)
      l(1); retval(0)  // (1)
    })
    let main() = func("main", 1, l => {
      l(0)
      l(1)
      let (x, ..rest) = foo(); rest  // (2)
      l(1, push("x", x))
      l(2)
    })
    main(); l(none)
  })
  ```,
  exec-grid-render.with(columns: 5),
)

In line #ref-line(1) we have the first piece of the puzzle, the #ref-fn("retval()") function. This function is emitted by the implementation closure as if it was a sequence item, but it must be handled before `execute()` could see it because it isn't actually one. In line #ref-line(2) the caller, who normally receives an array of items, now also receives the return value as the first element of that array. By destructuring, the first element is removed, and then the rest of the array needs to be emitted so that these items are part of the complete execution sequence.

== Displaying execution state

Until now the examples have concerned themselves with the actual execution of programs; how to get from #ref-fn("execute()")'s result to the gray boxes in this documentation was not addressed yet. This is potentially different between documents, and Stack Pointer doesn't do a lot for you here yet; still, here's one example for how execution state could be displayed.

The following is a function that takes the example code and _one_ step as returned by #ref-fn("execute()"). Below, you see how it looks when the four last steps of the variable assignment example are rendered next to each other using this function:

#{
  import sp: *

  let code = ```c
  int main() {
    int a = 0;
    return 0;
  }
  ```

  let steps = execute({
    let main() = func("main", 1, l => {
      l(0)
      let a = 0
      l(1); push("a", a); l(1)
      l(2)
    })
    main(); l(none)
  })
  let steps = steps

  let render-code = ```typc
  let render(code, step) = {
    let line = step.step.line
    let stack = step.state.stack
    block[
      #code
      #if line != none {
        place(
          top,
          // dimensions are hard-coded for this specific situation
          // don't take this part as inspiration, please ;)
          dx: 0.5em, dy: 0.18em + (line - 1) * 1.31em,
          circle(radius: 0.5em)
        )
      }
    ]
    block(inset: (x: 0.9em))[
      Stack: #parbreak()
      #if stack.len() == 0 [(empty)]
      #list(..stack.map(frame => {
        frame.name
        if frame.vars.len() != 0 {
          [: ]
          frame.vars.pairs().map(((name, value)) => [#name~=~#value]).join[, ]
        }
      }))
    ]
  }
  ```

  let render = eval(mode: "code", render-code.text + "; render")

  render-code

  grid(columns: (1fr,) * 4, ..range(1, 5).map(i => render(code, steps.at(i))))
}

A more typical situation would probably put the steps on individual slides. In polylux, for example, the `only()` function can be used to only show some information (the current line markers, the stack state) on specific subslides. To do so, it makes sense to first `enumerate(start: 1)` the steps, so that each step has a subslide index attached to it. The gallery has a complete example of using Stack Pointer with Polylux.

= Module reference

Functions that return sequence items, or similar values like #ref-fn("retval()"), return a value of the following shape: `((type: "...", ...),)` -- that is, an array with a single element. That element is a dictionary with some string `type`, and any other payload fields depending on the type. The payload fields are exactly the parameters of the following helper functions, unless specified otherwise.

#{
  let module = tidy.parse-module(
    read("../src/lib.typ"),
    scope: scope,
  )
  tidy.show-module(
    module,
    sort-functions: none,
    style: tidy.styles.minimal,
  )
}

== Effects

Effects are in a separate module because they have the greatest potential for extension,
however they are also re-exported from the main module.

#{
  let module = tidy.parse-module(
    read("../src/effects.typ"),
    scope: scope,
  )
  tidy.show-module(
    module,
    sort-functions: none,
    style: tidy.styles.minimal,
  )
}
