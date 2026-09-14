#let auto-fit-image(bytes, flipped) = context {
  let img = image(bytes)
  let (width, height) = measure(img)
  if flipped {
    if width < height {
      image(width: 101%, bytes)
    } else {
      image(height: 101%, bytes)
    }
  } else {
    if width < height {
      image(height: 101%, bytes)
    } else {
      image(width: 101%, bytes)
    }
  }
}

#let divider-line(length, stroke) = {
  length = (100% - length) / 2
  line(start: (0%, length), end: (0%, 100% - length), stroke: stroke)
}

#let right-side(stamp-area, address-area) = {
  grid(
    columns: 100%,
    rows: (1fr, auto),
    align: bottom + right,
    stamp-area,
    address-area,
  )
}

#let address-area(stroke, entries, gutter, length) = {
  let address-table-args = (
    columns: length,
    row-gutter: gutter,
    align: left + bottom,
    stroke: (_, y) => { (bottom: stroke) },
  )
  if type(entries) == array {
    table(..address-table-args, ..entries)
  } else if type(entries) == int {
    address-table-args.insert("rows", entries)
    table(..address-table-args)
  } else {
    [address-lines must be either of type 'array' or 'int']
  }
}

#let stamp-area(post-stamp) = {
  if type(post-stamp) == content {
    align(top + right, post-stamp)
  }
}

#let postcard(
  motif: none,
  background-motif: none,
  margin: 10%,
  paper: "a6",
  flipped: true,
  post-stamp: none,
  footer: none,
  address-lines: 4,
  address-lines-gutter: 10pt,
  address-line-length: 90%,
  address-stroke: stroke(thickness: 0.3mm),
  divider-dx: 50%,
  divider-length: 100%,
  divider-stroke: stroke(thickness: 0.5mm),
  divider-gutter: 15%,
  body,
) = {
  set page(
    paper: paper,
    flipped: flipped,
    margin: 0%,
  )

  if type(motif) == content {
    motif
    pagebreak()
  } else if type(motif) == bytes {
    auto-fit-image(motif, flipped)
    pagebreak()
  }


  set page(
    margin: margin,
    footer: footer,
    footer-descent: 0%,
    background: background-motif,
  )

  // using layout creates a weird gap?
  context {
    // funky shit
    let width = float(repr(page.width).trim("pt"))
    let height = float(repr(page.height).trim("pt"))

    let normalize-factor = 1

    if margin != 0% {
      normalize-factor = (width * height) / ((width * height) * float(100% - 2 * margin))
    }

    place(dx: divider-dx, divider-line(
      divider-length * normalize-factor,
      divider-stroke,
    ))
  }

  grid(
    columns: (divider-dx - divider-gutter / 2, divider-gutter, auto),
    block(body),
    block(),
    right-side(
      stamp-area(post-stamp),
      address-area(
        address-stroke,
        address-lines,
        address-lines-gutter,
        address-line-length,
      ),
    ),
  )
}
