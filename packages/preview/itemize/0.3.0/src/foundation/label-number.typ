#import "../util/parse-args.typ": *

#let parse-step(
  rel-level,
  curr-level,
  level-item,
  step-f,
  step-f-e,
  step-item,
  args-with-tags-item,
) = {
  if step-item != none {
    parse-general-args-with-level(
      step-item,
      level-item,
      none,
      0,
      ..args-with-tags-item,
    )
  } else {
    parse-general-args-with-level(
      step-f,
      rel-level,
      step-f-e,
      curr-level,
      ..args-with-tags-item,
    )
  }
}

#let get-enum-numbers(
  step,
  child-numbers,
  item-skipped,
  start: 0,
  reversed: false,
  len: 0,
) = {
  // fix(ver0.3.0): enum.reverse
  let numbers = ()
  let cur = if start == auto { if reversed { len + 1 } else { 0 } } else { start - 1 }
  if step == auto {
    // native behavior
    let increment = if reversed { -1 } else { 1 }
    for (i, num) in child-numbers.enumerate() {
      if num == auto {
        if item-skipped(i) == false {
          cur += increment
          if cur < 0 {
            cur = 0
          }
        }
        numbers.push(cur)
      } else {
        // typst 0.14
        numbers.push(num)
        cur = num
      }
    }
  } else if type(step) == int {
    let increment = step
    for (i, num) in child-numbers.enumerate() {
      if num == auto {
        if item-skipped(i) == false {
          cur += increment
          if cur < 0 {
            cur = 0
          }
        }
        numbers.push(cur)
      } else {
        // typst 0.14
        numbers.push(num)
        cur = num
      }
    }
  } else if type(step) == function {
    for (i, num) in child-numbers.enumerate() {
      let increment = if reversed { -1 } else { 1 }
      if num == auto {
        if item-skipped(i) == false {
          let cur-n = step(..numbers)
          if cur-n in (none, auto) {
            cur += increment
          } else if type(cur-n) == int {
            cur = cur-n
          } else {
            panic(
              "The return value of step function must be `int`, `none` or `auto`."
                + "\nBut found: "
                + repr(cur-n)
                + ".",
            )
          }
          if cur < 0 {
            cur = 0
          }
        }
        numbers.push(cur)
      } else {
        // typst 0.14
        numbers.push(num)
        cur = num
      }
    }
  } else {
    panic("The `step` must be `int`, `function` or `auto`.\nBut found: " + repr(step) + ".")
  }

  return numbers
}
