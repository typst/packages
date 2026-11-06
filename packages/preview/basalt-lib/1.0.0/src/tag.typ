#let package-name = "basalt-lib"
#let package-uuid = "73d1af09-0bac-4c2c-94b0-b38f173b7a2a"
#let prefix = package-name + ":" + package-uuid + ":"

#let tag(string) = {
  return prefix + string
}

#let tagged(string) = {
  string.starts-with(prefix)
}

#let strip-tag(string) = {
  if not tagged(string) {
    panic("tried to strip tag from string, but our tag wasn't found\nstring: " + string + "\ntag: " + prefix)
  }
  string.trim(prefix, at: start)
}
