#import "error-handling.typ": check-required-argument

#let package-name = "basalt-lib"
#let package-uuid = "73d1af09-0bac-4c2c-94b0-b38f173b7a2a"
#let prefix = package-name + ":" + package-uuid + ":"

#let tag(string) = {
  check-required-argument(tag, string, "string", str)

  return prefix + string
}

#let tagged(string) = {
  check-required-argument(tagged, string, "string", str)

  return string.starts-with(prefix)
}

#let strip-tag(string) = {
  check-required-argument(tagged, string, "string", str)

  if not tagged(string) {
    panic("tried to strip tag from string, but our tag wasn't found\nstring: " + string + "\ntag: " + prefix)
  }

  return string.trim(prefix, at: start)
}
