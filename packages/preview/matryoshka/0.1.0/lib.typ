#let _matryoshka-plugin = plugin("/matryoshka.wasm")

/// Takes typst source and returns the compiled document as an array of pages.
///
/// #example(```typ
///   grid(
///     columns: 2,
///     gutter: 1em,
///     ..matryoshka.compile-pages("
///       #set page(paper: \"a7\", flipped: true, fill: silver)
///       = Hello World
///       #pagebreak()
///       = Foo
///       #pagebreak()
///       = Bar
///       #pagebreak()
///       = Foobar
///     "),
///   )
/// ```, mode: "code")
///
/// - source (str): The typst source to compile
/// - filesystem (dictionary): A dictionary from file-paths to file contents as strings or bytes. These files will be available to the source code. Doesn't yet support nested paths.
/// - dont-fail (bool): When set to true and compilation fails this function will return the error message instead of panicking.
/// -> content
#let compile-pages(source, filesystem: (:), dont-fail: false) = {
  for (key, value) in filesystem {
    if type(value) == str {
      filesystem.at(key) = bytes(value)
    }
  }
  let arg = cbor.encode(
    (
      source: source,
      filesystem: filesystem,
      dont-fail: dont-fail,
    )
  )

  let output = _matryoshka-plugin.compile(arg)
  let result = cbor.decode(output)

  if result.errors != none {
    return result.errors
  }

  result.pages.map(it => image.decode(it))
}

/// Takes typst source and returns the compiled documents
///  This function returns opaque content.
///  If you need more control use compile-pages instead.
///
///  #example(```typ
///    matryoshka.compile("
///      #set page(fill: silver)
///      = Hello World
///    ")
///  ```, mode: "code")
///
/// - source (str): The typst source to compile
/// - filesystem (dictionary): A dictionary from file-paths to file contents as strings or bytes. These files will be available to the source code. Doesn't yet support nested paths.
/// - dont-fail (bool): When set to true and compilation fails this function will return the error message instead of panicking.
/// -> content
#let compile(source, filesystem: (:), dont-fail: false) = {
  let result = compile-pages(
    source,
    filesystem: filesystem,
    dont-fail: dont-fail
  )

  return result.join()
}
