#import "header.typ": *

#let range-sign(range) = {
  let (left, right) = range
  assert(left <= right)
  return if left >= 0 {
    1
  } else if right <= 0 {
    -1
  } else {
    panic()
  }
}

#let is-finite(num) = {
  not (std.float(num).is-nan() or std.float(num).is-infinite())
}

#let is-finite-point(point) = {
  let (x, y) = point
  is-finite(x) and is-finite(y)
}

#let is-finite-interval(interval) = {
  let (left, right) = interval
  is-finite-point(left) and is-finite-point(right)
}

#let get-point-at(t, vector-fn: none, t-range: none) = {
  // `t-range` determines which direction `epsilon-for-float` uses when `t == 0`.
  assert.ne(t-range, none)
  let (x, y) = vector-fn(t + epsilon-for-float * range-sign(t-range))
  return Point(t: t, x: x, y: y)
}

#let get-uniform-grids(start, end, count: none) = {
  let step = (end - start) / (count - 1)
  range(count).map(
    i => start + i * step,
  )
}



#let simplify-point(point, include-t: true) = {
  let (t, x, y) = point
  return if include-t {
    (t: t, x: x, y: y)
  } else {
    (x: x, y: y)
  }
}

#let simplify-interval(interval, include-t: true) = {
  let (left, right) = interval
  left = simplify-point(left, include-t: include-t)
  right = simplify-point(right, include-t: include-t)
  return (left, right)
}

#let unwindows(windows) = {
  if windows == () { return () }
  (..windows.first(), ..windows.slice(1).map(it => it.last()))
}

// 必须传入一个长度为2的数组
#let is-empty-range(range) = {
  // 不可数集： range.first() < range.last()
  // 单点集： range.first() == range.last()
  return range.first() > range.last()
}

// 必须传入一个长度为2的数组
#let is-full-range(range) = {
  import float.inf
  return range.first() == -inf and range.last() == inf
}

#let resolve-range(range, none-to: none) = {
  // 不需要处理 is-full-range, 因为 full-range 就一种
  assert.ne(none-to, none)
  return if range == none {
    none-to
  } else if is-empty-range(range) {
    empty-range
  } else {
    range
  }
}

// clip-box: (x: x-bounds, y: y-bounds)
// -> Rect
#let resolve-clip-box(clip-box) = {
  return if clip-box == none {
    // 不裁切，即裁切盒为全平面
    full-rect
  } else {
    axes-to-rect(Axes(
      ..dims.zip(dims.map(dim => { resolve-range(clip-box.at(dim), none-to: full-range) })).to-dict(),
    ))
  }
}
#let resolve-bounds(bounds) = {
  return if bounds == none {
    empty-rect
  } else {
    axes-to-rect(Axes(
      ..dims.zip(dims.map(dim => { resolve-range(bounds.at(dim), none-to: empty-range) })).to-dict(),
    ))
  }
}
#let resolve-viewport(viewport, bounds: Rect) = {
  return if viewport == auto {
    assert.ne(bounds, Rect)
    bounds
  } else {
    let temp = viewport.map(it => if it == auto { none } else { it })
    axes-to-rect(Axes(
      ..dims
        .zip(dims.map(
          dim => {
            resolve-range(temp.at(dim), none-to: bounds.at(dim))
          },
        ))
        .to-dict(),
    ))
  }
}

#let range-union(..ranges) = {
  import calc: max, min
  assert.eq(ranges.named().len(), 0)
  let ranges = ranges
    .pos()
    .map(
      range => {
        assert.eq(type(range), array)
        range
      },
    )
  let left = min(..ranges.map(range => range.first()))
  let right = max(..ranges.map(range => range.last()))
  return (left, right)
}

// AABB is short for axis-aligned bounding box
#let get-aabb(..vertices) = {
  import calc: max, min
  assert.eq(vertices.named().len(), 0)
  vertices = vertices.pos()
  let x = vertices.map(
    vertex => vertex.first(),
  )
  let y = vertices.map(
    vertex => vertex.last(),
  )
  let x-bounds = (min(..x), max(..x))
  let y-bounds = (min(..y), max(..y))
  return axes-to-rect(Axes(x: x-bounds, y: y-bounds))
}

#let dict-to-pair(dict) = {
  let (x, y) = dict
  return (x, y)
}
