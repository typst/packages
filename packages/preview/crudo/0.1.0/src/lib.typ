/// _raw-to-lines_: extract lines and properties from a `raw` element.
///
/// #example(ratio: 1.1, scale-preview: 100%, ````
/// crudo.r2l(```txt
/// first line
/// second line
/// ```)
/// ````)
///
/// Note that even though you will usually want to use this on raw _blocks_,
/// this is not a necessity:
///
/// #example(ratio: 1.1, scale-preview: 100%, ````
/// crudo.r2l(
///   raw("first line\nsecond line")
/// )
/// ````)
///
/// - raw-block (content): a single `raw` element
/// -> array
#let r2l(raw-block) = {
  let (text, ..fields) = raw-block.fields()
  (text.split("\n"), fields)
}

/// _lines-to-raw_: convert lines into a `raw` element. Properties for the created element can be
/// passed as parameters.
///
/// #example(ratio: 1.1, scale-preview: 100%, ````
/// crudo.l2r(
///   ("first line", "second line")
/// )
/// ````)
///
/// Note that even though you will usually want to construct raw _blocks_,
/// this is not assumed. To create blocks, pass the appropriate parameter:
///
/// #example(ratio: 1.1, scale-preview: 100%, ````
/// crudo.l2r(
///   ("first line", "second line"),
///   block: true,
/// )
/// ````)
///
/// - lines (array): an array of strings
/// - ..properties (arguments): properties for constructing the new `raw` element
/// -> content
#let l2r(lines, ..properties) = {
  raw(lines.join("\n"), ..properties)
}

/// Transforms all lines of a raw element and creates a new one with the lines. All properties of
/// the element (e.g. `block` and `lang`) are preserved.
///
/// #example(ratio: 1.1, scale-preview: 100%, ````
/// crudo.transform(
///   ```typc
///   let foo() = {
///     // some comment
///     ... do something ...
///   }
///   ```,
///   lines => lines.filter(l => {
///     // only preserve non-comment lines
///     not l.starts-with(regex("\s*//"))
///   })
/// )
/// ````)
///
/// - raw-block (content): a single `raw` element
/// - mapper (function): a function that takes an array of strings and returns a new one
/// -> content
#let transform(raw-block, mapper) = {
  let (lines, fields) = r2l(raw-block)
  lines = mapper(lines)
  l2r(lines, ..fields)
}

/// Maps individual lines of a raw element and creates a new one with the lines. All properties of
/// the element (e.g. `block` and `lang`) are preserved.
///
/// #example(ratio: 1.1, scale-preview: 100%, ````
/// crudo.map(
///   ```typc
///   let foo() = {
///     // some comment
///     ... do something ...
///   }
///   ```,
///   line => line.trim()
/// )
/// ````)
///
/// - raw-block (content): a single `raw` element
/// - mapper (function): a function that takes a string and returns a new one
/// -> content
#let map(raw-block, mapper) = {
  transform(raw-block, lines => lines.map(mapper))
}

/// Filters lines of a raw element and creates a new one with the lines. All properties of the
/// element (e.g. `block` and `lang`) are preserved.
///
/// #example(ratio: 1.1, scale-preview: 100%, ````
/// crudo.filter(
///   ```typc
///   let foo() = {
///     // some comment
///     ... do something ...
///   }
///   ```,
///   l => not l.starts-with(regex("\s*//"))
/// )
/// ````)
///
/// - raw-block (content): a single `raw` element
/// - test (function): a function that takes a string and returns a new one
/// -> content
#let filter(raw-block, test) = {
  transform(raw-block, lines => lines.filter(test))
}

/// Slices lines of a raw element and creates a new one with the lines. All properties of the
/// element (e.g. `block` and `lang`) are preserved.
///
/// #example(ratio: 1.1, scale-preview: 100%, ````
/// crudo.slice(
///   ```typc
///   let foo() = {
///     // some comment
///     ... do something ...
///   }
///   ```,
///   1, 3,
/// )
/// ````)
///
/// - raw-block (content): a single `raw` element
/// - ..args (arguments): the same arguments as accepted by
///   #link("https://typst.app/docs/reference/foundations/array/#definitions-slice")[`array.slice()`]
/// -> content
#let slice(raw-block, ..args) = {
  transform(raw-block, lines => lines.slice(..args))
}

/// Extracts lines of a raw element similar to how e.g. printers select page ranges. All properties
/// of the element (e.g. `block` and `lang`) are preserved.
///
/// This function is comparable to @@slice() but doesn't have the the option to specify the _number_
/// of selected lines via `count`. On the other hand, multiple ranges of pages can be selected, and
/// indices are one-based by default, which may be more natural for line numbers.
///
/// Lines are selected by any number of parameters. Each parameter can take either of three forms:
/// - a single number: that line is included in the output
/// - an array of numbers: these lines are included in the output (a major usecase being `range()`
///   -- but beware that `range()` uses an exclusive end index)
/// - a string containing numbers (e.g. `1`) and inclusive ranges (e.g. `1-2`) separated by commas.
///   Whitespace is allowed.
///
/// All three kinds of parameters can be mixed, and lines can be selected any number of times and in
/// any order.
///
/// #example(ratio: 1.1, scale-preview: 100%, ````
/// crudo.lines(
///   ```typc
///   let foo() = {
///     // some comment
///     ... do something ...
///   }
///   ```,
///   2, "1,3-4", range(2, 4),
/// )
/// ````)
///
/// - raw-block (content): a single `raw` element
/// - ..line-numbers (arguments): any number of line number specifiers, as described above
/// - zero-based (boolean): whether the supplied numbers are one-based line numbers or zero-based
///   indices
/// -> content
#let lines(raw-block, ..line-numbers, zero-based: false) = {
  assert(line-numbers.named().len() == 0, message: "only positional arguments can be given")
  let line-numbers = line-numbers.pos()

  let offset = if zero-based { 0 } else { -1 }

  transform(raw-block, lines => {
    let l(num) = lines.at(num + offset)

    for spec in line-numbers {

      if type(spec) == int {
        // make an array with a single line number
        spec = (spec,)
      } else if type(spec) == str {
        // convert the string into an array with a single line number
        spec = {
          for part in spec.split(",") {
            let bounds = part.split("-").map(str.trim)
            if bounds.len() == 1 {
              // a single page - already in an array
              bounds.map(int)
            } else if bounds.len() == 2 {
              // a page range
              let (lower, upper) = bounds.map(int)
              // make it inclusive
              array.range(lower, upper + 1)
            } else {
              panic("invalid page range: " + spec)
            }
          }
        }
      }

      assert(type(spec) == array, message: "page range must be an int, array, or a string")
      spec.map(l)
    }
  })
}

/// Joins lines of multiple raw elements and creates a new one with the lines. All properties of the
/// `main` element (e.g. `block` and `lang`) are preserved.
///
/// #example(ratio: 1.1, scale-preview: 100%, ````
/// crudo.join(
///   ```java
///   let foo() = {
///     // some comment
///     ... do something ...
///   }
///   ```,
///   ```typc
///   let bar() = {
///     // some comment
///     ... do something ...
///   }
///   ```,
///   main: -1,
/// )
/// ````)
///
/// - ..raw-blocks (content): any number of `raw` elements
/// - main (function): the index of the `raw` element of which properties should be preserved.
///   Negative indices count from the back.
/// -> content
#let join(..raw-blocks, main: 0) = {
  assert(raw-blocks.named().len() == 0, message: "only positional arguments can be given")
  let raw-blocks = raw-blocks.pos()

  let contents = raw-blocks.map(r2l)
  let lines = contents.map(c => c.at(0)).join()
  let fields = contents.at(main).at(1)
  l2r(lines, ..fields)
}
