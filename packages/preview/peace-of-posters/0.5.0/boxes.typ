#import "themes.typ": *
#import "layouts.typ": *

#let _calculate-width(b1, b2) = {
  // Get positions and width of box
  let p1 = b1.location().position()
  let p2 = b2.location().position()
  let width = p2.at("x") - p1.at("x")
  width
}

#let _calculate-vertical-distance(current-position, box, spacing) = {
  let p = box.location().position()
  // calculate distance
  let bottom-y = p.y
  let without-spacing = p.y - current-position.y
  let dist = p.y - current-position.y - spacing
  (dist, without-spacing)
}

#let _calculate-vertical-distance-to-page-end(m-loc, spacing) = {
  // Get position of end of page
  pt.at("heading-text-args", default: (:))
  100% - m-loc.y - spacing
}

// We have two boxes b1 and b2 and want to know if they will
// intersect if we increase the vertical size of box b1 while
// leaving the beginning position intact.
#let _boxes-would-intersect(b1-left, b1-right, b2-left, b2-right) = {
  let b1l = b1-left.location().position()
  let b1r = b1-right.location().position()
  let b2l = b2-left.location().position()
  let b2r = b2-right.location().position()

  // If the intervals [b1-left.x, b1-right.x] and [b2-left.x, b2-right.x]
  // do not intersect, they will never intersect when stretching the box
  if not ((b1l.at("x") <= b2r.at("x")) and (b2l.at("x") <= b1r.at("x"))) {
    return false
  } else {
  // If the x-intervals do intersect, 
    return true
  }

  let p = b1-right.location().position()
  let q = b2-left.location().position()
  let filt1 = p.at("x") > q.at("x")
  let filt2 = p.at("y") < q.at("y")
  let filt3 = b1-right.location().page() == b2-left.location().page()
  filt1 and filt2
}

#let stretch-box-to-next(box-function, location-heading-box, spacing: 1.2em, ..r) = locate(loc => {
  // Get current y location
  let m-loc = loc.position()
  let b1 = query(<COLUMN-BOX>, loc)
  let b2 = query(<COLUMN-BOX-RIGHT>, loc)

  // Find current box in all these queries
  let cb = b1.zip(b2).filter(b => {
    let (c-box, c-box-end) = b
    c-box.location().position() == location-heading-box.position()
  }).first()

  let target = b1
    .zip(b2)
    .map(b => {
      let (c-box, c-box-end) = b
      let c-loc = c-box.location().position()
      let filt = _boxes-would-intersect(cb.at(0), cb.at(1), c-box, c-box-end)
      let (dist, dist-without-spacing) = _calculate-vertical-distance(m-loc, c-box, spacing)
      (dist, filt, dist-without-spacing)
      })
    .filter(dist-filt => {dist-filt.at(1) and dist-filt.at(2) > 0.0mm})
    .sorted(key: dist-filt => {dist-filt.at(2)})

  // If we found a target, expand towards this target
  if target.len() > 0 {
    let (dist, _, _) = target.first()
    box-function(..r, height: dist)
  // Else determine the end of the page
  } else {
    let pl = _state-poster-layout.at(loc)
    let (_, height) = pl.at("size")
    let dist = height - m-loc.y - spacing
    box-function(..r, height: dist)
  }
})

// A common box that makes up all other boxes
#let common-box(
  body: none,
  heading: none,
  heading-size: none,
  heading-box-args: none,
  heading-text-args: none,
  heading-box-function: none,
  body-size: none,
  body-box-args: none,
  body-text-args: none,
  body-box-function: none,
  stretch-to-next: false,
  spacing: none,
  bottom-box: false,
) = {
  locate(loc => {
    let pt = _state-poster-theme.at(loc)
    let pl = _state-poster-layout.at(loc)

    let spacing = if spacing==none {pl.at("spacing")} else {spacing}

    /// #####################################################
    /// ###################### HEADING ######################
    /// #####################################################
    // Sort out arguments for heading box
    let heading-box-args = heading-box-args
    if heading-box-args==none {
      heading-box-args = pt.at("heading-box-args", default: (:))
      if body!=none {
        heading-box-args = pt.at("heading-box-args-with-body", default: heading-box-args)
      }
    }

    // Sort out arguments for heading text
    let heading-text-args = heading-text-args
    if heading-text-args==none {
      heading-text-args = pt.at("heading-text-args", default: (:))
      if body!=none {
        heading-text-args = pt.at("heading-text-args-with-body", default: heading-text-args)
      }
    }

    // Define which function to use for heading box
    let heading-box-function = heading-box-function
    if heading-box-function==none {
      heading-box-function = pt.at("heading-box-function", default: rect)
    }

    // Determine the size of the heading
    let heading-size = pl.at("heading-size", default: heading-size)
    if heading-size!=none {
      heading-text-args.insert("size", heading-size)
    }

    /// CONSTRUCT HEADING IF NOT EMPTY
    let heading-box = box(width: 0%, height: 0%)
    let heading = if heading!=none {
      [
        #set text(..heading-text-args)
        #heading
      ]
    } else {
      none
    }

    if heading!=none {
      heading-box = heading-box-function(
        ..heading-box-args,
      )[#heading]
    }

    /// #####################################################
    /// ####################### BODY ########################
    /// #####################################################
    // Sort out arguments for body box
    let body-box-args = body-box-args
    if body-box-args==none {
      body-box-args = pt.at("body-box-args", default: (:))
      if heading==none {
        body-box-args = pt.at("body-box-args-with-heading", default: body-box-args)
      }
    }

    // Sort out arguments for body text
    let body-text-args = body-text-args
    if body-text-args==none {
      body-text-args = pt.at("body-text-args", default: (:))
      if heading==none {
        body-text-args = pt.at("body-text-args-with-heading", default: body-text-args)
      }
    }

    // Define which function to use for body box
    let body-box-function = body-box-function
    if body-box-function==none {
      body-box-function = pt.at("body-box-function", default: rect)
    }

    // Determine the size of the body
    let body-size = pl.at("body-size", default: body-size)
    if body-size!=none {
      body-text-args.insert("size", body-size)
    }

    /// CONSTRUCT BODY IF NOT EMPTY
    let body-box = box(width: 0%, height: 0%)
    let body = if body!=none {
      [
        #set text(..body-text-args)
        #body
      ]
    } else {
      none
    }
    if body!=none {
      body-box = body-box-function(
        ..body-box-args,
      )[#body]
    }

    /// #####################################################
    /// ##################### COMBINE #######################
    /// #####################################################
    /// IF THIS BOX SHOULD BE STRETCHED TO THE NEXT POSSIBLE POINT WE HAVE TO ADJUST ITS SIZE
    if stretch-to-next==true {
      if body!=none {
        body-box = stretch-box-to-next(
          body-box-function,
          loc,
          spacing: spacing,
          body,
          ..body-box-args,
        )
      } else {
        heading-box = stretch-box-to-next(
          heading-box-function,
          loc,
          spacing: spacing,
          heading,
          ..heading-box-args,
        )
      }
    }
    box([#stack(dir: ltr, [#stack(dir:ttb,
      heading-box,
      body-box,
    )], [#box(width: 0pt, height: 0pt)<COLUMN-BOX-RIGHT>])<COLUMN-BOX>])
  })
}


// Write a function to creata a box with heading
#let column-box(
  body,
  ..args
) = {
  common-box(body: body, ..args)
}

// Function to display the title of the document
#let title-box(
  title,
  subtitle: none,
  authors: none,
  institutes: none,
  keywords: none,
  image: none,
  text-relative-width: 80%,
  spacing: 5%,
  title-size: none,
  subtitle-size: none,
  authors-size: none,
  keywords-size: none,
) = {
  locate(loc => {
    let text-relative-width = text-relative-width
    /// Get theme and layout state
    let pl = _state-poster-layout.at(loc)

    /// Layout specific options
    let title-size = if title-size==none {pl.at("title-size")} else {title-size}
    let subtitle-size = if subtitle-size==none {pl.at("subtitle-size")} else {subtitle-size}
    let authors-size = if authors-size==none {pl.at("authors-size")} else {authors-size}
    let keywords-size = if keywords-size==none {pl.at("keywords-size")} else {keywords-size}

    /// Generate body of box
    let text-content = [
      #set text(size: title-size)
      #title\
      #set text(size: subtitle-size)
      #if subtitle!=none {[#subtitle\ ]}
      #v(1.25em, weak: true)
      #set text(size: authors-size)
      #if authors!=none {[#authors\ ]}
      #if institutes!=none {[#institutes\ ]}
      #if keywords!=none {[
        #v(1em, weak: true)
        #set text(size: keywords-size)
        #keywords
      ]}
    ]

    /// Expand to full width of no image is specified
    if image==none {
      text-relative-width=100%
    }

    /// Finally construct the main rectangle
    common-box(heading:
      stack(dir: ltr,
        box(text-content, width: text-relative-width),
        align(right, box(image, width: 100% - spacing - text-relative-width))
      ))
  })
}

#let bottom-box(body, text-relative-width: 70%, logo: none, ..args) = {
  let body = [
    #set align(top+left)
    #if logo==none {
      box(width: 100%, body)
    } else {
      stack(dir: ltr,
        box(width: text-relative-width, body),
        align(right+horizon, logo),
      )
    }
  ]
  let r = common-box(heading: body, bottom-box: true, ..args)
  align(bottom, r)
}

/// TODO
#let bibliography-box(bib-file, body-size: 24pt, title: none, style: "ieee", stretch-to-next: false) = {
  if title==none {
    title = "References"
  }
  column-box(heading: title, stretch-to-next: stretch-to-next)[
    #set text(size: body-size)
    #bibliography(bib-file, title: none, style: style)
  ]
}
