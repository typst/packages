// Constructs a stack frame
#let frame(fun, args, env: none, cont: none) = (
  fun: fun,
  args: args,
  env: env,
  cont: cont,
  __frame__: (),
)

// Checks if the data is formatted like a frame.
// The surefire way of getting something that `is-frame` is to obtain
// it via the function `frame`.
#let is-frame(data) = {
  type(data) == dictionary and "__frame__" in data
}

// Halts a computation with a new frame.
#let pause(fun) = (..args) => (..env) => cont => {
  frame(fun, args, env: env, cont: cont)
}

// Tail call optimization.
#let tailcall(fun) = (..args) => {
  frame(fun, args)
}

// _ITER0 * _ITER1 bounds the number of times we can update the current stack
// frame to still guarantee termination.
#let _ITER0 = 50
#let _ITER1 = 1000

// Bounds the maximum depth of the call stack.
#let _MAXREC = 1000

// Runs a frame until completion.
#let resume(fun) = (..args) => {
  let res = fun(..args)
  if not is-frame(res) { return res }
  let (fun, args, env, cont) = res
  let stack = ((cont, env),)
  let _fun = fun
  let _args = args
  let _ret = none
  // Main loop running _ITER0 * _ITER1 times
  let _iter0 = _ITER0
  while _iter0 > 0 and stack.len() > 0 {
    _iter0 -= 1
    let _iter1 = _ITER1
    while _iter1 > 0 and stack.len() > 0 {
      _iter1 -= 1
      if stack.len() > _MAXREC { panic("Maximum recursion depth exceeded") }
      // If there is a current result, pop from the stack and evaluate
      // using that result run until the next frame.
      // If there is no result, evaluate the current `_fun`.
      let res = if _ret == none {
        _fun(.._args)
      } else {
        let frame = stack.pop()
        let (cont, env) = frame
        if cont == none { continue }
        cont(_ret.ret, ..env)
        _ret = none
      }
      // Then depending on whether the result is a new frame or a return
      // value, either push to the stack or update _ret to pop in the next pass.
      if not is-frame(res) {
        _ret = (ret: res)
      } else {
        let (fun, args, env, cont) = res
        if cont != none {
          stack.push((cont, env))
        }
        _fun = fun
        _args = args
      }
    }
  }
  // Exiting the loop means either that the stack is empty or that we've
  // exceeded the allowed number of iterations.
  if _ret != none {
    _ret.ret
  } else {
    panic("The parser seems to be taking a really long time. Check for infinite loops.")
  }
}

// Given a function written in continuation style,
// uses `resume` to hide the implementation details and make it a normal function.
#let run(fun) = (..vals) => {
  let res = resume(fun)(..vals)
  assert(not is-frame(res))
  res
}

