#import "themes.typ": *
#import "layouts.typ": *

#let _calculate_width(b1, b2) = {
  // Get positions and width of box
  let p1 = b1.location().position()
  let p2 = b2.location().position()
  let width = p2.at("x") - p1.at("x")
  width
}

#let _calculate_vertical_distance(current_position, box, spacing) = {
  let p = box.location().position()
  // calculate distance
  let bottom_y = p.y
  let without_spacing = p.y - current_position.y
  let dist = p.y - current_position.y - spacing
  (dist, without_spacing)
}

#let _calculate_vertical_distance_to_page_end(m_loc, spacing) = {
  // Get position of end of page
  pt.at("heading_text_args", default: (:))
  100% - m_loc.y - spacing
}

// We have two boxes b1 and b2 and want to know if they will
// intersect if we increase the vertical size of box b1 while
// leaving the beginning position intact.
#let _boxes_would_intersect(b1_left, b1_right, b2_left, b2_right) = {
  let b1l = b1_left.location().position()
  let b1r = b1_right.location().position()
  let b2l = b2_left.location().position()
  let b2r = b2_right.location().position()

  // If the intervals [b1_left.x, b1_right.x] and [b2_left.x, b2_right.x]
  // do not intersect, they will never intersect when stretching the box
  if not ((b1l.at("x") <= b2r.at("x")) and (b2l.at("x") <= b1r.at("x"))) {
    return false
  } else {
  // If the x-intervals do intersect, 
    return true
  }

  let p = b1_right.location().position()
  let q = b2_left.location().position()
  let filt1 = p.at("x") > q.at("x")
  let filt2 = p.at("y") < q.at("y")
  let filt3 = b1_right.location().page() == b2_left.location().page()
  filt1 and filt2
}

#let stretch_box_to_next(box_function, location_heading_box, spacing: 1.2em, ..r) = locate(loc => {
  // Get current y location
  let m_loc = loc.position()
  let b1 = query(<COLUMN_BOX>, loc)
  let b2 = query(<COLUMN_BOX_RIGHT>, loc)

  // Find current box in all these queries
  let cb = b1.zip(b2).filter(b => {
    let (c_box, c_box_end) = b
    c_box.location().position() == location_heading_box.position()
  }).first()

  let target = b1
    .zip(b2)
    .map(b => {
      let (c_box, c_box_end) = b
      let c_loc = c_box.location().position()
      let filt = _boxes_would_intersect(cb.at(0), cb.at(1), c_box, c_box_end)
      let (dist, dist_without_spacing) = _calculate_vertical_distance(m_loc, c_box, spacing)
      (dist, filt, dist_without_spacing)
      })
    .filter(dist_filt => {dist_filt.at(1) and dist_filt.at(2) > 0.0mm})
    .sorted(key: dist_filt => {dist_filt.at(2)})

  // If we found a target, expand towards this target
  if target.len() > 0 {
    let (dist, _, _) = target.first()
    box_function(..r, height: dist)
  // Else determine the end of the page
  } else {
    let pl = _state_poster_layout.at(loc)
    let (_, height) = pl.at("size")
    let dist = height - m_loc.y - spacing
    box_function(..r, height: dist)
  }
})

// A common box that makes up all other boxes
#let _common_box(
  body: none,
  heading: none,
  heading_size: none,
  heading_box_args: none,
  heading_text_args: none,
  heading_box_function: none,
  body_size: none,
  body_box_args: none,
  body_text_args: none,
  body_box_function: none,
  stretch_to_next: false,
  spacing: none,
  bottom_box: false,
) = {
  locate(loc => {
    let pt = _state_poster_theme.at(loc)
    let pl = _state_poster_layout.at(loc)

    let spacing = if spacing==none {pl.at("spacing")} else {spacing}

    /// #####################################################
    /// ###################### HEADING ######################
    /// #####################################################
    // Sort out arguments for heading box
    let heading_box_args = heading_box_args
    if heading_box_args==none {
      heading_box_args = pt.at("heading_box_args", default: (:))
      if body==none {
        heading_box_args = pt.at("heading_box_args_with_body", default: heading_box_args)
      }
    }

    // Sort out arguments for heading text
    let heading_text_args = heading_text_args
    if heading_text_args==none {
      heading_text_args = pt.at("heading_text_args", default: (:))
      if body==none {
        heading_text_args = pt.at("heading_text_args_with_body", default: heading_text_args)
      }
    }

    // Define which function to use for heading box
    let heading_box_function = heading_box_function
    if heading_box_function==none {
      heading_box_function = pt.at("heading_box_function", default: rect)
    }

    // Determine the size of the heading
    let heading_size = pl.at("heading_size", default: heading_size)
    if heading_size!=none {
      heading_text_args.insert("size", heading_size)
    }

    /// CONSTRUCT HEADING IF NOT EMPTY
    let heading_box = box(width: 0%, height: 0%)
    let heading = if heading!=none {
      [
        #set text(..heading_text_args)
        #heading
      ]
    } else {
      none
    }

    if heading!=none {
      heading_box = heading_box_function(
        ..heading_box_args,
      )[#heading]
    }

    /// #####################################################
    /// ####################### BODY ########################
    /// #####################################################
    // Sort out arguments for body box
    let body_box_args = body_box_args
    if body_box_args==none {
      body_box_args = pt.at("body_box_args", default: (:))
      if heading==none {
        body_box_args = pt.at("body_box_args_with_heading", default: body_box_args)
      }
    }

    // Sort out arguments for body text
    let body_text_args = body_text_args
    if body_text_args==none {
      body_text_args = pt.at("body_text_args", default: (:))
      if heading==none {
        body_text_args = pt.at("body_text_args_with_heading", default: body_text_args)
      }
    }

    // Define which function to use for body box
    let body_box_function = body_box_function
    if body_box_function==none {
      body_box_function = pt.at("body_box_function", default: rect)
    }

    // Determine the size of the body
    let body_size = pl.at("body_size", default: body_size)
    if body_size!=none {
      body_text_args.insert("size", body_size)
    }

    /// CONSTRUCT BODY IF NOT EMPTY
    let body_box = box(width: 0%, height: 0%)
    let body = if body!=none {
      [
        #set text(..body_text_args)
        #body
      ]
    } else {
      none
    }
    if body!=none {
      body_box = body_box_function(
        ..body_box_args,
      )[#body]
    }

    /// #####################################################
    /// ##################### COMBINE #######################
    /// #####################################################
    /// IF THIS BOX SHOULD BE STRETCHED TO THE NEXT POSSIBLE POINT WE HAVE TO ADJUST ITS SIZE
    if stretch_to_next==true {
      if body!=none {
        body_box = stretch_box_to_next(
          body_box_function,
          loc,
          spacing: spacing,
          body,
          ..body_box_args,
        )
      } else {
        heading_box = stretch_box_to_next(
          heading_box_function,
          loc,
          spacing: spacing,
          heading,
          ..heading_box_args,
        )
      }
    }
    box([#stack(dir: ltr, [#stack(dir:ttb,
      heading_box,
      body_box,
    )], [#box(width: 0pt, height: 0pt)<COLUMN_BOX_RIGHT>])<COLUMN_BOX>])
  })
}


// Write a function to creata a box with heading
#let column_box(
  body,
  ..args
) = {
  _common_box(body: body, ..args)
}

// Function to display the title of the document
#let title_box(
  title,
  subtitle: none,
  authors: none,
  institutes: none,
  keywords: none,
  image: none,
  text_relative_width: 80%,
  spacing: 5%,
  title_size: none,
  subtitle_size: none,
  authors_size: none,
  keywords_size: none,
) = {
  locate(loc => {
    let text_relative_width = text_relative_width
    /// Get theme and layout state
    let pl = _state_poster_layout.at(loc)

    /// Layout specific options
    let title_size = if title_size==none {pl.at("title_size")} else {title_size}
    let subtitle_size = if subtitle_size==none {pl.at("subtitle_size")} else {subtitle_size}
    let authors_size = if authors_size==none {pl.at("authors_size")} else {authors_size}
    let keywords_size = if keywords_size==none {pl.at("keywords_size")} else {keywords_size}

    /// Generate body of box
    let text_content = [
      #set text(size: title_size)
      #title\
      #set text(size: subtitle_size)
      #if subtitle!=none {[#subtitle\ ]}
      #v(1.25em, weak: true)
      #set text(size: authors_size)
      #if authors!=none {[#authors\ ]}
      #if institutes!=none {[#institutes\ ]}
      #if keywords!=none {[
        #v(1em, weak: true)
        #set text(size: keywords_size)
        #keywords
      ]}
    ]

    /// Expand to full width of no image is specified
    if image==none {
      text_relative_width=100%
    }

    /// Finally construct the main rectangle
    _common_box(heading:
      stack(dir: ltr,
        box(text_content, width: text_relative_width),
        align(right, box(image, width: 100% - spacing - text_relative_width))
      ))
  })
}

#let bottom_box(body, text_relative_width: 70%, logo: none, ..args) = {
  let body = [
    #set align(top+left)
    #if logo==none {
      box(width: 100%, body)
    } else {
      stack(dir: ltr,
        box(width: text_relative_width, body),
        align(right+horizon, logo),
      )
    }
  ]
  let r = _common_box(heading: body, bottom_box: true, ..args)
  align(bottom, r)
}

/// TODO
#let bibliography_box(bib_file, body_size: 24pt, title: none, style: "ieee", stretch_to_next: false) = {
  if title==none {
    title = "References"
  }
  column_box(heading: title, stretch_to_next: stretch_to_next)[
    #set text(size: body_size)
    #bibliography(bib_file, title: none, style: style)
  ]
}
