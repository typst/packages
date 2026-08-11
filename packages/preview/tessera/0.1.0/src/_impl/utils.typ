#import "@preview/elembic:1.1.1" as e
#import "item.typ": scalable

#let div = calc.div-euclid
#let mod = calc.rem-euclid

#let cdiv(a, b) = {
  let q = div(a, b)
  let r = mod(a, b)
  if r == 0 { q } else { q + 1 }
}

/// argument parser for `elembic` elements that accepts an arbitrary number of positional arguments.
#let arbitrary-pos-arg-parser(default-parser, fields: none, typecheck: none) = {
  (args, include-required: false) => {
    let args = if include-required {
      // receive items as an arbitrary number of positional arguments
      let pos-args = args.pos()
      arguments(pos-args, ..args.named())
    } else if args.pos() == () {
      args
    } else {
      return (false, "unexpected positional arguments\n  hint: these can only be passed to the constructor")
    }
    default-parser(args, include-required: include-required)
  }
}

/// Calculate the aspect ratio of a `content` item.
///
/// - item (content | bytes | str): a `content`, or path to an image, or source bytes of an image
/// -> float
#let aspect-ratio(item, reci: false) = {
  assert.eq(e.eid(item), e.eid(scalable))
  let fields = e.fields(item)
  if "aspect-ratio" in fields {
    let aspect-ratio = fields.aspect-ratio
    if (reci) { 1 / aspect-ratio } else { aspect-ratio }
  } else {
    let (width, height) = measure(item)
    if (reci) { width / height } else { height / width }
  }
}

#let dir-is-inv(dir) = {
  let start = dir.start()
  start == right or start == bottom
}

#let transpose(arr) = {
  if arr.len() == 0 { arr }
  else { arr.at(0).zip(..arr.slice(1)) }
}

#let reflow(arr, flow: (ltr, ttb)) = {
  let arr = arr
  let n-rows = arr.len()

  let (dir1, dir2) = flow
  // the two directions must have different axes
  assert.ne(dir1.axis(), dir2.axis())

  let dir1-is-inv = dir-is-inv(dir1)
  let dir2-is-inv = dir-is-inv(dir2)
  let should-transpose = dir1.axis() == "vertical"
  if should-transpose {
    // needs transpose
    arr = arr.join().chunks(n-rows)
  }
  if dir1-is-inv { arr = arr.map(array.rev) }
  if dir2-is-inv { arr = arr.rev() }
  if should-transpose {
    arr = transpose(arr)
  }
  arr
}

#let reshape(arr, n-rows: auto, n-cols: auto, pad: none) = {
  let arr = arr
  let n-eles = arr.len()
  let n-rows = n-rows
  let n-cols = n-cols

  if n-rows == auto {
    if n-cols == auto {
      n-rows = arr
      n-cols = 1
    } else {
      n-rows = cdiv(n-eles, n-cols)
      arr += (pad,) * (n-rows * n-cols - n-eles)
    }
  } else if n-cols == auto {
    n-cols = cdiv(n-eles, n-rows)
    arr += (pad,) * (n-rows * n-cols - n-eles)
  } else {
    let n-grids = n-rows * n-cols
    if n-grids < n-eles {
      arr = arr.slice(0, n-grids)
    } else {
      arr += (pad,) * (n-grids - n-eles)
    }
  }
  arr.chunks(n-cols)
}

#let resolve-gutter1(
  gutter: auto,
  n: 1,
  default-gutter: 0pt,
  inv: false
) = {
  let gutter-sum = 0pt
  let gutter = gutter
  if gutter == auto {
    gutter-sum = default-gutter.to-absolute() * (n - 1)
    gutter = default-gutter
  } else if type(gutter) == length {
    gutter-sum = gutter * (n - 1)
  } else if type(gutter) == array {
    gutter = range(n - 1).map(i => gutter.at(mod(i, gutter.len())).to-absolute())
    gutter-sum = gutter.sum(default: 0pt)
    if inv { gutter = gutter.rev() }
  } else {
    assert.eq(type(gutter), function)
    gutter = range(n - 1).map(gutter)
    gutter-sum = gutter.sum(default: 0pt)
    if inv { gutter = gutter.rev() }
  }
  (gutter: gutter, sum: gutter-sum)
}

#let resolve-gutter2(
  gutter: auto,
  n-primary: none,
  n: 1,
  default-gutter: 0pt,
  dir1-inv: false,
  dir2-inv: false
) = {
  let n = n
  let gutter = gutter
  if type(gutter) == array {
    assert.eq(n, gutter.len())
  }

  // resolve row gutters and calculate the sum of row gutters in each column
  if type(gutter) == function {
    gutter = n-primary
      .enumerate()
      .map(((j, m)) => range(m - 1).map(i => gutter(j, i)))
  } else if gutter == auto {
    gutter = (gutter,) * n
  } else if type(gutter) == length {
    gutter = (gutter,) * n
  }
  // `row-gutter` is now of type `array`
  let temp = gutter
    .zip(n-primary)
    .map(
      ((g, n)) => resolve-gutter1(
        gutter: g,
        n: n,
        default-gutter: default-gutter,
        inv: dir1-inv,
      )
    )

  if dir2-inv { temp = temp.rev() }
  gutter = temp.map(item => item.gutter)
  let gutter-sums = temp.map(item => item.sum)
  (gutter: gutter, sum: gutter-sums)
}
