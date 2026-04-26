#import "../utils/utils.typ"
#import "@preview/cetz:0.3.4"

#let left-parenthesis-anchor(parenthesis, ctx) = {
  let anchor = if parenthesis.body.at(0).type == "fragment" {
    let name = parenthesis.body.at(0).name
    parenthesis.body.at(0).name = name
    (name: name, anchor: "west")
  } else if parenthesis.body.at(0).type == "link" {
    let name = parenthesis.body.at(0).at("name")
    parenthesis.body.at(0).name = name
    (name + "-start-anchor", 45%, name + "-end-anchor")
  } else if not left { } else {
    panic("The first element of a parenthesis must be a molecule fragment or a link")
  }
  (ctx, parenthesis, anchor)
}

#let right-parenthesis-anchor(parenthesis, ctx) = {
  let right-name = parenthesis.at("right")
  let right-type = ""
  if right-name != none {
    right-type = utils.get-element-type(parenthesis.body, right-name)
    if right-type == none {
      panic("The right element of the parenthesis does not exist")
    }
  } else {
    right-type = parenthesis.body.at(-1).type
    right-name = parenthesis.body.at(-1).at("name", default: none)
  }

  let anchor = if right-type == "fragment" {
    (name: right-name, anchor: "east")
  } else if right-type == "link" {
    (right-name + "-start-anchor", 55%, right-name + "-end-anchor")
  } else {
    panic("The last element of a parenthesis must be a molecule fragment or a link but got " + right-type)
  }
  (ctx, parenthesis, anchor)
}

#let parenthesis-content(parenthesis, height, cetz-ctx) = {
  let block = block(height: height * cetz-ctx.length * 1.2, width: 0pt)
  let left-parenthesis = {
    set text(top-edge: "bounds", bottom-edge: "bounds")
    math.lr($parenthesis.l block$, size: 100%)
  }
  let right-parenthesis = {
    set text(top-edge: "bounds", bottom-edge: "bounds")
    math.lr($block parenthesis.r$, size: 100%)
  }

  let right-parenthesis-with-attach = {
    set text(top-edge: "bounds", bottom-edge: "bounds")
    math.attach(right-parenthesis, br: parenthesis.br, tr: parenthesis.tr)
  }

  (left-parenthesis, right-parenthesis, right-parenthesis-with-attach)
}

#let draw-parenthesis(parenthesis, ctx, draw-molecules-and-link) = {
  let (parenthesis-ctx, drawing, cetz-rec) = draw-molecules-and-link(
    ctx,
    parenthesis.body,
  )
  ctx = parenthesis-ctx


  drawing += {
    import cetz.draw: *
    get-ctx(cetz-ctx => {
      let (ctx: cetz-ctx, bounds, drawables) = cetz.process.many(
        cetz-ctx,
        {
          drawing
        },
      )
      let sub-bounds = cetz.util.revert-transform(cetz-ctx.transform, bounds)

      let sub-height = utils.bounding-box-height(sub-bounds)
      let sub-v-mid = sub-bounds.low.at(1) - sub-height / 2

      let sub-width = utils.bounding-box-width(sub-bounds)

      let (ctx, parenthesis, left-anchor) = left-parenthesis-anchor(parenthesis, ctx)

      let (ctx, parenthesis, right-anchor) = right-parenthesis-anchor(parenthesis, ctx)

      let height = parenthesis.at("height")
      if height == none {
        if not parenthesis.align {
          panic("You must specify the height of the parenthesis if they are not aligned")
        }
        height = sub-height
      } else {
        height = utils.convert-length(cetz-ctx, height)
      }

      let (left-parenthesis, right-parenthesis, right-parenthesis-with-attach) = parenthesis-content(
        parenthesis,
        height,
        cetz-ctx,
      )

      let (_, (lx, ly, _)) = cetz.coordinate.resolve(cetz-ctx, update: false, left-anchor)
      let (_, (rx, ry, _)) = cetz.coordinate.resolve(cetz-ctx, update: false, right-anchor)

      if ctx.config.debug {
        circle((lx, ly), radius: 1pt, fill: orange, stroke: orange)
        circle((rx, ry), radius: 1pt, fill: orange, stroke: orange)
        rect((lx, sub-bounds.low.at(1)), (rx, sub-bounds.high.at(1)), stroke: green)
        line((lx, sub-v-mid), (rx, sub-v-mid), stroke: green)
      }

      let hoffset = calc.abs(sub-width - calc.abs(rx - lx))

      if parenthesis.align {
        ly -= ly - sub-v-mid
        ry = ly
      } else if type(parenthesis.yoffset) == array {
        if parenthesis.yoffset.len() != 2 {
          panic("The parenthesis yoffset must be a list of length 2 or a number")
        }
        ly += utils.convert-length(cetz-ctx, parenthesis.yoffset.at(0))
        ry += utils.convert-length(cetz-ctx, parenthesis.yoffset.at(1))
      } else if parenthesis.yoffset != none {
        let offset = utils.convert-length(cetz-ctx, parenthesis.yoffset)
        ly += offset
        ry += offset
      }

      if type(parenthesis.xoffset) == array {
        if parenthesis.xoffset.len() != 2 {
          panic("The parenthesis xoffset must be a list of length 2 or a number")
        }
        lx += utils.convert-length(cetz-ctx, parenthesis.xoffset.at(0))
        rx += utils.convert-length(cetz-ctx, parenthesis.xoffset.at(1))
      } else if parenthesis.xoffset != none {
        let offset = utils.convert-length(cetz-ctx, parenthesis.xoffset)
        lx -= offset
        rx += offset
      }

      let right-bounds = cetz.process.many(cetz-ctx, content((0, 0), right-parenthesis, auto-scale: false)).bounds
      let right-with-attach-bounds = cetz
        .process
        .many(cetz-ctx, content((0, 0), right-parenthesis-with-attach, auto-scale: false))
        .bounds
      let right-voffset = calc.abs(right-bounds.low.at(1) - right-with-attach-bounds.low.at(1))
      if parenthesis.tr != none and parenthesis.br != none {
        right-voffset /= 2
      } else if (parenthesis.tr != none) {
        right-voffset *= -1
      }

      (
        _ => (
          ctx: cetz-ctx,
          drawables: drawables,
          bounds: bounds,
        ),
      )
      content((lx, ly), anchor: "mid-east", left-parenthesis, auto-scale: false)
      content((rx, ry - right-voffset), anchor: "mid-west", right-parenthesis-with-attach, auto-scale: false)
    })
  }

  (ctx, drawing, cetz-rec)
}


#let draw-resonance-parenthesis(parenthesis, draw-function, ctx) = {
  import cetz.draw: *
  let left-name = "parenthesis-" + str(ctx.id)
  let right-name = "parenthesis-" + str(ctx.id + 1)
  ctx.id += 2
  let last-anchor = ctx.last-anchor
  let (drawing, ctx) = draw-function(ctx, parenthesis.body, after-operator: true)

  let drawing = get-ctx(cetz-ctx => {
    let (ctx: cetz-ctx, bounds, drawables) = cetz.process.many(
      cetz-ctx,
      drawing,
    )
    let sub-bounds = cetz.util.revert-transform(cetz-ctx.transform, bounds)
    let height = parenthesis.height
    if height == none {
      height = utils.bounding-box-height(sub-bounds)
    } else {
      height = utils.convert-length(cetz-ctx, height)
    }
    let width = utils.bounding-box-width(sub-bounds)

    let (left-parenthesis, _, right-parenthesis-with-attach) = parenthesis-content(parenthesis, height, cetz-ctx)

    let right-anchor = (rel: (width, 0), to: (name: left-name, anchor: "east"))
    on-layer(
      1,
      {
        content(last-anchor.anchor, name: left-name, anchor: "mid-east", left-parenthesis, auto-scale: false)
        content(right-anchor, name: right-name, anchor: "mid-west", right-parenthesis-with-attach, auto-scale: false)
      },
    )
    (
      ctx => (
        ctx: cetz-ctx,
        drawables: drawables,
        bounds: bounds,
      ),
    )
  })

  ctx.last-anchor = (type: "coord", anchor: (name: right-name, anchor: "mid-east"))
  (ctx, drawing)
}
