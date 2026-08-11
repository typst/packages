// #import "@preview/grayness:0.3.0"
#import "@preview/elembic:1.1.1"as e
#import "utils.typ": (
  arbitrary-pos-arg-parser,
  dir-is-inv,
  div, mod, cdiv,
  reflow,
  aspect-ratio,
  resolve-gutter1,
  resolve-gutter2,
)
#import "transform.typ": (
  transformed-image,
  rescale,
)
#import "item.typ": (
  scalable,
  resolve-item,
)
#import "typing.typ": *

/// Calculate column widths for masonry image layout.
///
/// - width (length): width of the masonry layout block
/// - aspect-ratio-sums (array): an array, each element the sum of aspect ratios of images in a column
/// - column-gutter-sum (length): sum of column gaps
/// - row-gutter-sums (array): an array, each element the sum of row gaps in a column
/// -> array
#let calc-col-widths(
  width,
  aspect-ratio-sums,
  column-gutter-sum,
  row-gutter-sums
) = {
  let k_i-reci-sum = aspect-ratio-sums
    .map(k_i => 1 / k_i)
    .sum(default: 0)
  let d_i-over-k_i-sum = row-gutter-sums
    .zip(aspect-ratio-sums)
    .map(((d_i, k_i)) => d_i / k_i)
    .sum(default: 0)
  let height = (width - column-gutter-sum + d_i-over-k_i-sum) / k_i-reci-sum
  row-gutter-sums
    .zip(aspect-ratio-sums)
    .map(((d_i, k_i)) => (height - d_i) / k_i)
}

// override `calc-col-widths` with Rust impl
#import "masonry-layout-helper_wasm.typ": calc-col-widths

#let correct-item-dir(items, dir1-inv: false, dir2-inv: false) = {
  if dir1-inv {
    if dir2-inv {
      items.rev().map(item => item.rev())
    } else {
      items.map(item => item.rev())
    }
  } else if dir2-inv {
    items.rev()
  } else {
    items
  }
}

#let masonry = e.element.declare(
  "masonry",
  prefix: "tesselate.masonry",
  fields: (
    e.field(
      "children",
      e.types.array(e.types.union(content, e.types.array(content))),
      default: (),
      named: false,
    ),
    e.field(
      "gutter",
      length,
      default: 0pt,
      named: true,
    ),
    e.field(
      "secondary-gutter",
      secondary-gutter,
      named: true,
    ),
    e.field(
      "primary-gutter",
      primary-gutter,
      named: true,
    ),
    e.field(
      "column-gutter",
      e.types.option(gutter-like),
      named: true,
    ),
    e.field(
      "row-gutter",
      e.types.option(gutter-like),
      named: true,
    ),
    e.field(
      "flow",
      e.types.array(direction),
      named: true,
      default: (ttb, ltr),
      folds: false,
    )
  ),
  allow-unknown-fields: true,
  display: el => {
    let (
      children,
      gutter,
      column-gutter,
      row-gutter,
      primary-gutter,
      secondary-gutter,
      flow: (dir1, dir2)
    ) = e.fields(el)

    // primary and secondary directions must have different axes
    assert.ne(dir1.axis(), dir2.axis())
    let dir1-inv = dir-is-inv(dir1)
    let dir2-inv = dir-is-inv(dir2)

    // convert single items to arrays
    // turn all items into `scalable` type
    let children = children.map(
      item => {
        if type(item) == array { item.map(resolve-item) }
        else { (resolve-item(item),) }
      }
    )

    // `n-rows` is calculated before direction correction
    let n-rows = children.map(array.len)
    let n-cols = children.len()

    // correct directions of items
    children = correct-item-dir(
      children,
      dir1-inv: dir1-inv,
      dir2-inv: dir2-inv,
    )

    if dir1.axis() == "horizontal" {
      // horizontal then vertical

      if row-gutter == none {
        row-gutter = secondary-gutter
      }
      if column-gutter == none {
        column-gutter = primary-gutter
      }

      let n-rows = children.len()
      let n-cols = children.map(array.len)

      let (gutter: row-gutter) = resolve-gutter1(
        gutter: row-gutter,
        n: n-rows,
        default-gutter: gutter,
        inv: dir2-inv,
      )

      let (
        gutter: column-gutter,
        sum: column-gutter-sums
      ) = resolve-gutter2(
        gutter: column-gutter,
        n: n-rows,
        n-primary: n-cols,
        default-gutter: gutter,
        dir1-inv: dir1-inv,
        dir2-inv: dir2-inv,
      )

      if (dir2-inv) { n-cols = n-cols.rev() }
      let aspect-ratio-recis = children
        .map(item => item.map(aspect-ratio.with(reci: true)))
      let aspect-ratio-reci-sums = aspect-ratio-recis
        .map(array.sum.with(default: 0))

      layout(((width,)) => {
        let heights = aspect-ratio-reci-sums
          .zip(column-gutter-sums)
          .map(
            ((aspect-ratio-reci-sum, column-gutter-sum)) =>
            (width - column-gutter-sum) / aspect-ratio-reci-sum
          )
        let rows = children
          .zip(column-gutter, aspect-ratio-recis)
          .map(
            ((items, column-gutter, aspect-ratio-recis)) => {
              let items = items.map(
                item => {
                  let fields = e.fields(item)
                  let body = fields.remove("body")
                  if "aspect-ratio" in fields {
                    fields.remove("aspect-ratio")
                  }
                  let should-rescale = if "rescale" not in fields {
                    auto
                  } else {
                    fields.remove("rescale")
                  }
                  if should-rescale == auto {
                    should-rescale = body.func() == image
                  }
                  return if should-rescale {
                    layout(
                      ((width, height)) =>
                      rescale(body, width: width, height: height, ..fields)
                    )
                  } else { body }
                }
              )
              grid(
                ..items,
                columns: aspect-ratio-recis.map(value => value * 1fr),
                column-gutter: column-gutter,
              )
            }
          )
        grid(
          ..rows,
          row-gutter: row-gutter,
          rows: heights,
        )
      })
    } else {
      // vertical then horizontal

      if column-gutter == none {
        column-gutter = secondary-gutter
      }
      if row-gutter == none {
        row-gutter = primary-gutter
      }

      layout(((width,)) => {
        let n-rows = n-rows

        // resolve column gutters and calculate the sum of column gutters
        // direction is corrected
        let (gutter: column-gutter, sum: column-gutter-sum) = resolve-gutter1(
          gutter: column-gutter,
          n: n-cols,
          default-gutter: gutter,
          inv: dir2-inv,
        )

        // resolve row gutters and calculate the sum of row gutters in each column
        let (gutter: row-gutter, sum: row-gutter-sums) = resolve-gutter2(
          gutter: row-gutter,
          n-primary: n-rows,
          n: n-cols,
          default-gutter: gutter,
          dir1-inv: dir1-inv,
          dir2-inv: dir2-inv
        )

        if (dir2-inv) { n-rows = n-rows.rev() }

        // calculate aspect ratios of each image
        let aspect-ratios = children.map(item => item.map(aspect-ratio))
        let aspect-ratio-sums = aspect-ratios.map(array.sum)

        // calculate column widths
        let column-widths = calc-col-widths(
          width,
          aspect-ratio-sums,
          column-gutter-sum,
          row-gutter-sums
        )

        // create `grid`s for each column
        let columns = row-gutter
          .zip(children, column-widths, aspect-ratios)
          .map(
            ((gutter, items, width, aspect-ratio)) => {
              let heights = aspect-ratio.map(value => width * value)
              let items = items.zip(heights).map(((item, height)) => {
                let fields = e.fields(item)
                let body = fields.remove("body")
                if "aspect-ratio" in fields {
                  fields.remove("aspect-ratio")
                }

                // decide whether this element needs to be rescaled
                // by default only images are rescaled
                let should-rescale = if "rescale" not in fields {
                  auto
                } else {
                  fields.remove("rescale")
                }
                if should-rescale == auto {
                  should-rescale = (
                    body.func() == image or
                    e.eid(body) == e.eid(transformed-image)
                  )
                }

                return if should-rescale {
                  rescale(
                    body,
                    width: width,
                    height: height,
                    ..fields,
                  )
                } else {
                  body
                }
              })
              grid(..items, row-gutter: gutter, rows: heights)
            }
          )

        grid(
          ..columns,
          column-gutter: column-gutter,
          columns: column-widths,
        )
      })
    }
  },
  parse-args: arbitrary-pos-arg-parser,
)


