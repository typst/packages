#import "@preview/cetz:0.3.1"

#let marks(markly-context) = {

  // Extract from markly-context
  let stock-width = markly-context.at("stock-width")
  let stock-height = markly-context.at("stock-height")

  let content-width = markly-context.at("content-width")
  let content-height = markly-context.at("content-height")

  let bleed = markly-context.at("bleed")



  let mark-length=10pt
  let mark-standoff=bleed + 2pt
  let cut-mark-color = black
  let bleed-mark-color = red

  let slug-width=(stock-width - content-width) / 2
  let slug-height=(stock-height - content-height) / 2

  cetz.canvas(
    length: 1pt,
    {
      import cetz.draw: *

      // This just ensures that we have a coordinate system that covers the whole page
      // grid((0,0), (612,792), stroke:none, step: 72)
      grid((0,0), (stock-width.pt(),stock-height.pt()), stroke:none, step: 72)

      let draw-marks(top-left, top-right, bottom-left, bottom-right, color:black) = {
        // Top Left
        let from = top-left
        from.at(1) += mark-standoff

        let to = from
        to.at(1) += mark-length

        line(from, to, stroke: color)


        let from = top-left
        from.at(0) -= mark-standoff

        let to = from
        to.at(0) -= mark-length
        line(from, to, stroke: color)


        // Top Right
        let from = top-right
        from.at(1) += mark-standoff

        let to = from
        to.at(1) += mark-length

        line(from, to, stroke: color)


        let from = top-right
        from.at(0) += mark-standoff

        let to = from
        to.at(0) += mark-length
        line(from, to, stroke: color)



        // Bottom Left
        let from = bottom-left
        from.at(1) -= mark-standoff

        let to = from
        to.at(1) -= mark-length

        line(from, to, stroke: color)


        let from = bottom-left
        from.at(0) -= mark-standoff

        let to = from
        to.at(0) -= mark-length
        line(from, to, stroke: color)


        // Bottom Right
        let from = bottom-right
        from.at(1) -= mark-standoff

        let to = from
        to.at(1) -= mark-length

        line(from, to, stroke: color)


        let from = bottom-right
        from.at(0) += mark-standoff

        let to = from
        to.at(0) += mark-length
        line(from, to, stroke: color)
      }

      let cut-top-left = (slug-width, stock-height - slug-height)
      let cut-top-right = (stock-width - slug-width, stock-height - slug-height)
      let cut-bottom-left = (slug-width, slug-height)
      let cut-bottom-right = (stock-width - slug-width, slug-height)
      draw-marks(cut-top-left, cut-top-right, cut-bottom-left, cut-bottom-right)

      if bleed != 0pt {

        let bleed-top-left = (slug-width - bleed, stock-height - slug-height + bleed)
        let bleed-top-right = (stock-width - slug-width + bleed, stock-height - slug-height + bleed)
        let bleed-bottom-left = (slug-width - bleed, slug-height - bleed)
        let bleed-bottom-right = (stock-width - slug-width + bleed, slug-height - bleed)

        draw-marks(bleed-top-left, bleed-top-right, bleed-bottom-left, bleed-bottom-right, color:bleed-mark-color)
      }

      let registration-color(position, color) = {
        circle(position, radius: 6pt, stroke: .6pt + color)
        circle(position, radius: 4pt, stroke: none, fill: color)

        let from = position
        from.at(0) -= 8pt
        let to = position
        to.at(0) += 8pt
        line(from, to, stroke: .6pt + color)

        let from = position
        from.at(0) -= 4pt
        let to = position
        to.at(0) += 4pt
        line(from, to, stroke: white + .6pt)

        let from = position
        from.at(1) -= 8pt
        let to = position
        to.at(1) += 8pt
        line(from, to, stroke: .6pt + color)

        let from = position
        from.at(1) -= 4pt
        let to = position
        to.at(1) += 4pt
        line(from, to, stroke: white + .6pt)
      }

      let registration(position) = {
        // I'm not sure that this will not be sqashed before these are printing.
        registration-color(position, cmyk(100%,   0%,   0%,   0%))
        registration-color(position, cmyk(  0%, 100%,   0%,   0%))
        registration-color(position, cmyk(  0%,   0%, 100%,   0%))
        registration-color(position, cmyk(  0%,   0%,   0%, 100%))
      }


      registration((stock-width / 2, stock-height - slug-height / 2)) // Top
      registration((stock-width / 2, slug-height / 2)) //Bottom
      registration((slug-width / 2, stock-height / 2)) // Left
      registration((stock-width - slug-width / 2, stock-height / 2)) // Right
    }
  )
}

// This creates a background color that extends to the bleed line on the left and right
#let to-bleed(body, markly-context, color: white, bg-color:blue.darken(30%), inset-y:12pt) = {

  // Extract from markly-context
  let margin-width = markly-context.at("margin-width")
  let bleed = markly-context.at("bleed")

  block(
    fill: bg-color,
    width: 100%,
    outset: (x: bleed+margin-width), // paints until bleed cutoff
    inset: (y:inset-y), // padding height for background color
    text(color, body)
  )
}


// This creates a background color that extends to the bleed line on the right
#let to-bleed-right(body, markly-context, color: white, bg-color:blue.darken(30%), padding:12pt) = {

  // Extract from markly-context
  let margin-width = markly-context.at("margin-width")
  let bleed = markly-context.at("bleed")

  block(
    fill: bg-color,
    width: 100%,
    outset: (right: bleed+margin-width), // paints until bleed cutoff
    inset: (left:padding, y:padding), // padding height for background color
    text(color, body)
  )
}

// This creates a background color that extends to the bleed line on the left
#let to-bleed-left(body, markly-context, color: white, bg-color:blue.darken(30%), padding:12pt) = {

  // Extract from markly-context
  let margin-width = markly-context.at("margin-width")
  let bleed = markly-context.at("bleed")

  block(
    fill: bg-color,
    width: 100%,
    outset: (left: bleed+margin-width), // paints until bleed cutoff
    inset: (right:padding, y:padding), // padding height for background color
    text(color, body)
  )
}

#let img-to-bleed(img-data, markly-context) = {

  // Extract from markly-context
  let margin-width = markly-context.at("margin-width")
  let margin-height = markly-context.at("margin-height")
  let bleed = markly-context.at("bleed")

  place(
    top + left,
    dx: -(margin-width+bleed),
    dy: -(margin-height+bleed),
    image.decode(
      img-data,
      width:100%+margin-width*2+bleed*2,
      height:100%+margin-height*2+bleed*2)
  )
}

// This just creates a dict that can be used by the other functions
// Hopefully this makes markly templates more intuitive.
#let setup(
  stock-width:8.5in,
  stock-height:11in,

  content-width:6in,
  content-height:4in,

  bleed:9pt,

  margin-width:.2in,
  margin-height:.2in
) = {

  let markly-context = (:)
  markly-context.insert("stock-height", stock-height)
  markly-context.insert("stock-width",  stock-width)

  markly-context.insert("content-height", content-height)
  markly-context.insert("content-width",  content-width)

  markly-context.insert("margin-height", margin-height)
  markly-context.insert("margin-width",  margin-width)

  markly-context.insert("bleed",  bleed)

  return markly-context
}

#let page-setup(markly-context, body) = {

  set page(
    width: markly-context.at("stock-width"),
    height: markly-context.at("stock-height"),
    margin: (
      x: (markly-context.at("stock-width") - markly-context.at("content-width")) / 2 + markly-context.at("margin-width"),
      y: (markly-context.at("stock-height") - markly-context.at("content-height")) / 2 + markly-context.at("margin-height"),
    ),
    background: marks(markly-context),
  )

  body
}
