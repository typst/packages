#import "../../helpers.typ": *

#let solution(s) = {
  let stack = ()
  let pairs = (
    ")": "(",
    "]": "[",
    "}": "{",
  )

  for char in s {
    if char in ("(", "[", "{") {
      stack.push(char)
    } else if char in pairs {
      if stack.len() == 0 or stack.at(-1) != pairs.at(char) {
        return false
      }
      let _ = stack.pop()
    }
  }

  stack.len() == 0
}
