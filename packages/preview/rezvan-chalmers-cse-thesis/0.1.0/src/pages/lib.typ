// If the first argument is an array, `.join`s it with the given arguments. Else, the argument is returned as-is
#let join(val, ..args) = if type(val) == array {
  val.join(..args)
} else {
  val
}
