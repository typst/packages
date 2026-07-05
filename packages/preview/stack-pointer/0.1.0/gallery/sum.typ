#import "@preview/stack-pointer:0.1.0"
// #import "@local/stack-pointer:0.1.0"
// #import "../src/lib.typ" as stack-pointer

#import "@preview/polylux:0.3.1": *
#import themes.simple: *

// make the PDF reproducible to ease version control
#set document(date: none)

#show: simple-theme

#{
  import stack-pointer: *

  let code = ```java
    void main(String[] args) {
      int a = 2, b = 3, c = 4;
      int d = sum(a, b, c);
      System.out.println(d);
    }
    void sum(int x, int y, int z) {
      int result = add(x, y);
      result = add(result, z);
      return result;
    }
    void add(int x, int y) {
      int result = x + y;
      return result; }
  ```

  // This is where the magic happens: we simulate the above Java code, generating an array of steps
  // with all the execution information at that point in time.
  let steps = execute({
    // println returns nothing, so it's easy to define and use it's also not part of the shown code,
    // so the line numbers are `none`
    let println(x) = func("println", none, l => {
      // always begin with adding the parameter variables
      l(none, push("x", x))

      l(none, call("...")); l(none, ret())

      // there's no retval() here, so the result is a regular execution sequence
    })

    // this is a function with return value. calling it needs some care
    let add(x, y) = func("add", 11, l => {
      l(0, push("x", x), push("y", y))

      // int result = x + y;
      let result = x + y
      // first step to the line, then show its effect: push the new variable
      l(1); l(1, push("result", result))

      // return result;
      // The return value will be first in the result of `add()`, i.e. the result is not just an
      // execution sequence. The return value needs to be removed by the caller.
      l(2); retval(result)
    })

    let sum(x, y, z) = func("sum", 6, l => {
      l(0, push("x", x), push("y", y), push("z", z))

      // int result = add(x, y);
      // Here we call a function with return value. We separate the return value from the steps.
      // The result is kept in a variable and inserted...
      let (result, ..steps) = add(x, y)
      l(1); steps; l(1, push("result", result))
      //    ^^^^^ ... here at the right position into the sequence

      // result = add(result, z);
      let (result, ..steps) = add(result, z)
      l(2); steps; l(2, assign("result", result))

      // return result;
      l(3); retval(result)
    })

    let main() = func("main", 1, l => {
      l(0, push("args", [_\<reference\>_]))

      // int a = 2, b = 3, c = 4;
      l(1)
      let a = 2
      l(1, push("a", a))
      let b = 3
      l(1, push("b", b))
      let c = 4
      l(1, push("c", c))

      // int d = sum(a, b, c);
      let (d, ..steps) = sum(a, b, c)
      l(2); steps; l(2, push("d", d))

      // System.out.println(d);
      // Here we call a function without return value. We can just write it as-is.
      // the second `l(3)` shows the stack after returning from `println()`
      l(3); println(d); l(3)
    })

    // call the main function, which returns all steps for generating the subslides
    // after the main() call, I also want to show the empty stack, so add a subslide on the final
    // line of main()
    main(); l(5)
  })
  // for polylux subslides, we also need to have a "time" to know when to show what information
  let steps = steps.enumerate(start: 1)

  // when generating the slide in Polylux, it's crucial to specify the max-repetitions
  polylux-slide(max-repetitions: steps.len())[
    == Program execution and the stack

    #set text(size: 0.8em)
    #grid(columns: (50%, 1fr), {
      for (when, step) in steps {
        let line = step.step.line
        // in some subslides, there are no lines to highlight
        if line == none { continue }
        // render the highlight only in the specific subslide:
        // place an arrow where the code will be rendered
        only(when, place(
          dx: -1em,
          // this is hard-coded for the specific font - could be more flexible
          dy: -0.0em + (line - 1) * 1.12em,
          sym.arrow
        ))
      }

      code
    }, {
      [Stack:]
      for (when, step) in steps {
        let stack = step.state.stack
        // make a list of all stack frames of the current state
        only(when, list(
          ..stack.map(frame => {
            frame.name
            if frame.vars.len() != 0 {
              [: ]
              frame.vars.pairs().map(((name, value)) => [#name~=~#value]).join[, ]
            }
          })
        ))
      }
    })
  ]
}