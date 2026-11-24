/// N-ary cartesian product.
///
/// ```examplec
/// cartesian(("A", "B"), (1, 2))
/// ```
///
/// #test(
/// `cartesian(("A", "B"), (1, 2)) == (("A", 1), ("A", 2), ("B", 1), ("B", 2))`,
/// )
#let cartesian(
  /// Sets to build the cartesian product of. The last set is iterated fastest.
  /// -> array
  ..args,
) = {
  if args.pos().len() == 0 { return ((),) }
  let (xs, ..xss) = args.pos()
  let rec = cartesian(..xss)
  xs.map(x => rec.map(tup => (x, ..tup))).join()
}

/// N-times cartesian product.
///
/// ```examplec
/// cartesian-power(n: 3, (0, 1))
/// ```
#let cartesian-power(
  /// How many times to build the cartesian product.
  /// -> int
  n: 1,
  /// The set to build the cartesian product of.
  /// ->  array
  xs,
) = cartesian(..(xs,) * n)

/// Combine multiple lists element-wise using a function.
///
/// When `f` is omitted, it behaves like `xs.zip(..xss)`.
/// ```examplec
/// zip-with((10, 20), (1, 2))
/// ```
/// ```examplec
/// zip-with(
///   f: (l, r) => l + r,
///   (10, 20),
///   (1, 2)
/// )
/// ```
#let zip-with(
  /// The function to combine the elements. Gets one argument of each list.
  /// -> function
  f: (..args) => args.pos(),
  xs,
  ..xss,
) = (
  xs.zip(..xss).map(args => f(..args))
)

/// Map with index.
#let imap(
  /// -> function
  f: (i, x) => (i, x),
  /// -> array
  xs,
) = xs.enumerate().map(((i, x)) => f(i, x))

/// Update value at index `i` in array `xs` using function `f`.
#let update(
  /// -> int
  i,
  /// -> function
  f,
  /// -> array
  xs,
) = imap(f: (j, x) => if i == j { f(x) } else { x }, xs)

/// The minimum of a sequence when comparing by `f`.
#let min-by(
  /// -> function
  f: x => x,
  /// -> array
  ..xs,
) = {
  xs
    .pos()
    .map(x => (fx: f(x), x: x))
    .reduce((min, curr) => if curr.fx < min.fx { curr } else { min })
    .x
}

/// The maximum of a sequence when comparing by `f`.
#let max-by(
  /// -> function
  f: x => x,
  /// -> array
  ..xs,
) = (
  xs
    .pos()
    .map(x => (fx: f(x), x: x))
    .reduce((max, curr) => if curr.fx > max.fx { curr } else { max })
    .x
)

/// Whether a sequence is unique, i.e. contains no duplicate values.
///
/// ```examplec
/// is-unique(1, 2, 3)
/// ```
/// ```examplec
/// is-unique(1, 2, 1)
/// ```
///
/// #test(
/// `is-unique(1, 2, 3) == true`,
/// `is-unique(1, 2, 1) == false`,
/// )
#let is-unique(
  /// -> any
  ..xs,
) = {
  let combinations = cartesian-power(n: 2, xs.pos().enumerate())
  return combinations.all((((i, x), (j, y))) => i == j or x != y)
}

/// Whether a string represents an integer.
///
/// #test(
///   `is-int("123") == true`,
///   `is-int("12a") == false`,
///   `is-int("") == false`,
/// )
/// -> bool
#let is-int(
  /// -> string
  str,
) = str.match(regex("^[0-9]+$")) != none

// #{
//   import "@preview/tidy:0.4.3"

//   tidy.show-module(
//     tidy.parse-module(
//       read("./util.typ"),
//       name: "Util",
//       scope: (
//         cartesian: cartesian,
//         cartesian-power: cartesian-power,
//         zip-with: zip-with,
//         imap: imap,
//         update: update,
//         min-by: min-by,
//         max-by: max-by,
//         is-unique: is-unique,
//         is-int: is-int,
//       ),
//       preamble: ```typ
//         #set text(font: "libertinus serif")

//       ```.text,
//     ),
//     first-heading-level: 1,
//     omit-private-definitions: true,
//     omit-private-parameters: true,
//     sort-functions: none,
//   )
// }

/*
    TODO: documentation!
*/

/// -> dictionary
#let mk-dict(
  /// Calculates value for each key.
  /// -> function
  f: none,
  /// -> array
  keys,
) = keys.map(k => (k, f(k))).to-dict()


#let filter-by-index(f: none, xs) = (
  xs.enumerate().filter(((i, x)) => f(i)).map(((i, x)) => x)
)
#let partition(
  f: none,
  xs,
) = (
  xs.fold(((), ()), ((ts, fs), x) => {
    if f(x) { ((..ts, x), fs) } else { (ts, (..fs, x)) }
  })
)
#let partition-by-index(
  f: none,
  xs,
) = (
  xs
    .enumerate()
    .fold(((), ()), ((ts, fs), (i, x)) => {
      if f(i) { ((..ts, x), fs) } else { (ts, (..fs, x)) }
    })
)


#let zip(xs, ..xss) = xs.zip(..xss)
#let indices(xs) = range(xs.len())
#let singleton(x) = (x,)
#let sum(xs, default: none) = xs.sum(default: default)
/// -> array | dict
#let map(
  /// -> function
  f: (..args) => args.pos().last(),
  /// -> array | dict
  xs,
) = if type(xs) == array {
  xs.map(f)
} else if type(xs) == dictionary {
  xs.pairs().map(((k, v)) => (k, f(k, v))).to-dict()
} else {
  panic("Expected array or dictionary, but found " + str(type(xs)))
}

#let all(xs, f: x => x) = xs.all(f)
#let join(xs, separator: none) = xs.join(separator)


#let _no-arg() = {}
#let call-or-return(v) = if type(v) == function { v() } else { v }
#let switch(x: none, ..cases, default: none) = {
  for (pattern, v) in cases.pos() {
    if not x == pattern { continue }
    return call-or-return(v)
  }
  if default != none { return call-or-return(default) }
  panic("No pattern matched.")
}

#let imap(xs, f: none) = xs.enumerate().map(((i, x)) => f(i, x))

#let power-set(xs) = xs.fold(((),), (acc, x) => {
  acc + acc.map(a => (..a, x))
})

#let set-difference(xs, ys) = xs.filter(x => not ys.contains(x))

#let fold-keywise(fs: (:), ..dicts) = {
  let dicts = dicts.pos()
  map(fs, f: (k, f) => f(..dicts.map()))
}
