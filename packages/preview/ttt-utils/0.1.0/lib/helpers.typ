
/// if value is auto then return other value else return value itself
#let if-auto-then(val, ret) = {
  if (val == auto) {
    ret
  } else {
    val
  }
}

// #let push_and_return(a_list, value) = {
//   a_list.push(value)
//   return a_list
// }

// #let increase_last(a_list, value) = {
//   a_list.last() += value
//   return a_list
// }