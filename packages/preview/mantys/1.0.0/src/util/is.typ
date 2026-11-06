// TODO: (jneug) rename module to something else

#let str(value) = std.type(value) == std.type("")
#let dict(value) = std.type(value) == std.type((:))
#let arr(value) = std.type(value) == std.type(())
#let type(value) = std.type(value) == std.type
#let content(value) = std.type(value) == std.content

#let raw(value) = std.type(value) == std.content and value.func() == std.raw

#let _none(value) = value == none
#let _auto(value) = value == auto


#let barg(it) = {
  it.func() == metadata and it.value.kind == "barg"
}
#let sarg(it) = {
  return repr(it.func()) == "sequence" and it.children.first() == [..]
}
