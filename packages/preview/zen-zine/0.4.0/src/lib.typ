/// the base container for a single page in the final (folded or digital) zine
///
/// This is an attempt to replicate the behavior of a `page` container including
/// allowing the user to define the height, width, margins, header, footer, and
/// page numbering. The one caveat to this replication is that since the zine-pages
/// in a printer zine are rendered in their grid order (and not their final folded
/// order), we need to manually specify the page number for a zine page.
///
/// -> content
#let zine-page(
  /// width of a page in the zine
  /// -> length
  width: 100%,
  /// height of a page in the zine
  /// -> length
  height: 100%,
  /// margin of each page in the zine
  ///
  /// This margin is passed directly to block.inset so it
  /// cannot use the zine margin names in @zine-margin-names.
  ///
  /// -> length
  margin: auto,
  /// content to put on the header of each page
  ///
  /// overrides the page numbers. Pass a function
  /// to `numbering` and use `number-align: top`
  /// if you wish to style the page numbers in
  /// the header in a custom way.
  ///
  /// -> content
  header: none,
  /// distance between top of page and bottom of header content
  /// -> length
  header-ascent: 30% + 0pt,
  /// content to put on the footer of each page
  ///
  /// overrides the page numbers. Pass a function
  /// to `numbering` and use `number-align: bottom`
  /// if you wish to style the page numbers in
  /// the footer in a custom way.
  ///
  /// -> content
  footer: none,
  /// distance between bottom of page and top of footer content
  /// -> length
  footer-descent: 30% + 0pt,
  /// number for this zine-page
  ///
  /// if none, then the page number is not rendered
  /// -> int
  page-number: none,
  /// how the page numbers should be displayed
  ///
  /// Passed into the Typst `numbering` function.
  /// -> str, function
  numbering: none,
  /// how to align the page numbers relative to the page
  /// -> align
  number-align: center+bottom,
  /// whether to draw the border of the zine pages
  /// 
  /// This border is sometimes helpful for seeing the placement of
  /// content on the final printer-ready page and seeing the margins
  /// of the zine pages
  /// -> boolean
  draw-border: false,
  /// content to put into page
  /// -> content
  body
) = {
  let numbering = if numbering == auto {
    "1"
  } else {
    numbering
  }

  let body-block-kwargs = (
    width: 100%,
    height: 100%
  )
  if margin != auto {
    body-block-kwargs.insert("inset", margin)
  }
  if draw-border {
    body-block-kwargs.insert("stroke", black)
  }

  block(
    width: width,
    height: height,
  )[
    #block(..body-block-kwargs, body)

    #if numbering != none {
      if number-align.y == horizon {
        error("horizon number-align is forbidden")
      } else if number-align.y == bottom {
        footer = if footer == none {
          align(number-align.x + top, std.numbering(numbering, page-number))
        } else {
          footer
        }
      } else if number-align.y == top {
        header = if header == none {
          align(number-align.x + bottom, std.numbering(numbering, page-number))
        } else {
          header
        }
      }
    }

    #place(
      top,
      block(
        width: 100%,
        height: if type(margin) == length { 
          margin
        } else if type(margin) == dictionary {
          margin.at("top", default: margin.at("rest"))
        } else {
          auto
        },
        inset: (bottom: header-ascent),
        header
      )
    )
    #place(
      bottom,
      block(
        width: 100%,
        height: if type(margin) == length { 
          margin
        } else if type(margin) == dictionary {
          margin.at("bottom", default: margin.at("rest"))
        } else {
          auto
        },
        inset: (top: footer-descent),
        footer
      )
    )
  ]
}

// internal function
// break content into an array of pages
//
// Perhaps in a future version of Typst, we can call some kind of internal
// function given the current `page` configuration and it will inform
// us of the array of page contents, but for now, we simply require the
// user to manually insert `pagebreak()` calls where they wish the
// zine-page boundaries to be.
// -> array
#let break-content-into-page-array(content) = {
  // allow super-users to provide an array of content directly
  if type(content) == array {
    return content
  }

  let contents = ()
  let current-content = []
  for child in content.at("children") {
    if child.func() == pagebreak {
      contents.push(current-content)
      current-content = []
    } else {
      current-content = current-content + child
    }
  }

  if current-content != [] {
    contents.push(current-content)
  }

  contents
}

// internal function
// given a look-up-table of new names, create a function that can
// rename the keys of an input dictionary accordingly
// 
// keys that are not in the look-up-table keep the same name
#let key-remapper(look-up-table) = {
  (dict) => {
    let updated = (:)
    for (key, val) in dict.pairs() {
      for new-key in look-up-table.at(key, default: (key,)) {
        updated.insert(new-key, val)
      }
    }
    updated
  }
}

#let zine8-default-margin = ("bottom": 0.5in, "rest": 0.25in)

#let zine8-margin-names = (
  ( "inner-fold": (), "outer-fold": ("left","top"), "printer-margin": ("bottom","right"), "cut": () ),
  ( "inner-fold": ("right",), "outer-fold": ("top",), "printer-margin": ("bottom", "left"), "cut": () ),
  ( "inner-fold": ("left",), "outer-fold": ("right",), "printer-margin": ("bottom",), "cut": ("top",) ),
  ( "inner-fold": ("right",), "outer-fold": ("left",), "printer-margin": ("bottom",), "cut": ("top",) ),
  ( "inner-fold": ("left",), "outer-fold": ("top",), "printer-margin": ("bottom","right"), "cut": () ),
  ( "inner-fold": ("right",), "outer-fold": ("top",), "printer-margin": ("bottom","left"), "cut": () ),
  ( "inner-fold": ("left",), "outer-fold": ("right",), "printer-margin": ("bottom",), "cut": ("top",) ),
  ( "inner-fold": (), "outer-fold": ("left","right"), "printer-margin": ("bottom",), "cut": ("top",) ),
)

/// construct an eight-page zine for the current printer page size
/// 
/// The size of the zine pages are deduced from the current page size.
/// The current page defines the size of the page that the zine would be
/// printed on.
///
/// The zine's pages are provided in the order that they should be read,
/// separated by `pagebreak()`s. They are wrapped and then moved into position
/// so that any zine-page-internal layout is preserved.
///
/// === #text(red.darken(25%), underline[Failure Mode])
/// #text(red.darken(25%), [This function will fail if there are not exactly seven `pagebreak()` calls
/// within the document (implying eight pages are defined).])
///
/// Unfortunately, we cannot render an example since zen-zine requires
/// access to the page information to be able to deduce the size of the zine
/// pages.
///
/// -> content
#let zine8(
  /// whether to be in printer mode (false) or digital (true)
  ///
  /// When creating a digital zine, the margin specified with `zine-page-margin`
  /// is divided by two so that the digital visually looks like the printed
  /// zine with the pages cut out.
  /// -> boolean
  digital: false,
  /// the margin for the zine pages
  ///
  /// These can be the normal margin names or the zine margins listed
  /// in @zine-margin-names.
  ///
  /// -> length|dictionary
  margin: auto,
  /// other named arguments are given to zine-page
  ..zine-page-kwargs,
  /// input content of zine
  /// -> content
  content
) = {

  let contents = break-content-into-page-array(content);

  assert.eq(
    contents.len(), 8,
    message: "Document content does not have exactly 8 pages (7 pagebreaks), only "+str(contents.len())+" pages were found."
  )

  // extract the margin separately so we can remap the names if necessary
  let margin = if margin == auto {
    if zine-page-kwargs.named().keys().contains("numbering") {
      zine8-default-margin
    } else {
      0.25in
    }
  } else {
    margin
  }

  // the trim margin is something we apply to the entire printer page
  // and /not/ to the zine pages themselves so we `remove` it here
  // zine-page is handling the margin, so the default parent margin 
  // should be zero (no trim)
  let trim-margin = if type(margin) == dictionary {
    margin.remove("trim-margin", default: 0pt)
  } else {
    0pt
  }

  set page(margin: trim-margin)

  context {
    // we need to be in context so we can get the full page's height and width
    // in order to deduce the zine page height and width
    let zine-page-height = (page.width - 2*trim-margin)/2;
    let zine-page-width = (page.height - 2*trim-margin)/4;
    
    // wrap pages in zine-page
    let contents = contents.enumerate().map(
      ((i, content)) => {
        let zine-page-margin = if type(margin) == dictionary {
          key-remapper(zine8-margin-names.at(i))(margin)
        } else {
          margin
        }
        zine-page(
          height: zine-page-height,
          width: zine-page-width,
          page-number: i+1,
          margin: zine-page-margin,
          ..zine-page-kwargs,
          content
        )
      }
    )
    
    if digital {
      // resize output page to be same size as zine-page
      // and set margin to 0 since the digital zine is the pages after trimming and folding
      set page(margin: 0pt, height: zine-page-height, width: zine-page-width)
      for zpage in contents {
        zpage
      }
    } else {
      // make sure page is flipped
      set page(flipped: true)
      
      // re-order and place onto printer page
      let contents = (
        contents.slice(1,5).rev()+contents.slice(5,8)+contents.slice(0,1)
      ).enumerate().map(
        // flip if on top row
        elem => {
          if elem.at(0) < 4 {
            rotate(
              180deg,
              origin: center,
              elem.at(1)
            )
          } else {
            elem.at(1)
          }
        }
      )
    
      let zine-grid = grid.with(
        columns: 4 * (zine-page-width, ),
        rows: zine-page-height,
      )
      zine-grid(..contents)
    }
  }
}

#let zine16-default-margin = (
  "printer-margin": 0.25in,
  "rest": 0.05in
)
#let zine16-default-margin-numbers = (
  "printer-margin": 0.25in,
  "bottom": 0.5in,
  "rest": 0.1in
)
#let zine16-margin-names = (
  ( "inner-fold": (), "outer-fold": ("left","top"), "printer-margin": ("right","bottom"), "cut": ()),
  ( "inner-fold": ("right",), "outer-fold": ("top",), "printer-margin": ("left",), "cut": ("bottom",)),
  ( "inner-fold": ("left",), "outer-fold": ("bottom",), "printer-margin": (), "cut": ("top","right")),
  ( "inner-fold": ("right",), "outer-fold": ("bottom",), "printer-margin": (), "cut": ("top","left")),
  ( "inner-fold": ("left",), "outer-fold": ("top",), "printer-margin": ("right",), "cut": ("bottom",)),
  ( "inner-fold": ("right",), "outer-fold": ("top",), "printer-margin": ("left","bottom"), "cut": ()),
  ( "inner-fold": ("left",), "outer-fold": ("right",), "printer-margin": ("bottom",), "cut": ("top",)),
  ( "inner-fold": ("right",), "outer-fold": ("left",), "printer-margin": ("bottom",), "cut": ("top",)),
  ( "inner-fold": ("left",), "outer-fold": ("top",), "printer-margin": ("bottom","right"), "cut": ()),
  ( "inner-fold": ("right",), "outer-fold": ("top",), "printer-margin": ("left",), "cut": ("bottom",)),
  ( "inner-fold": ("left",), "outer-fold": ("bottom",), "printer-margin": (), "cut": ("top","right")),
  ( "inner-fold": ("right",), "outer-fold": ("bottom",), "printer-margin": (), "cut": ("top","left")),
  ( "inner-fold": ("left",), "outer-fold": ("top",), "printer-margin": ("right",), "cut": ("bottom",)),
  ( "inner-fold": ("right",), "outer-fold": ("top",), "printer-margin": ("left","bottom"), "cut": ()),
  ( "inner-fold": ("left",), "outer-fold": ("right",), "printer-margin": ("bottom",), "cut": ("top",)),
  ( "inner-fold": (), "outer-fold": ("right","left"), "printer-margin": ("bottom",), "cut": ("top",)),
)

/// construct 16-page zine for the current printer page size
/// 
/// The size of the zine pages are deduced from the current page size.
/// The current page defines the size of the page that the zine would be
/// printed on.
///
/// The zine's pages are provided in the order that they should be read,
/// separated by `pagebreak()`s. They are wrapped and then moved into position
/// so that any zine-page-internal layout is preserved.
///
/// === #text(red.darken(25%), underline[Failure Mode])
/// #text(red.darken(25%), [This function will fail if there are not exactly fifteen `pagebreak()` calls
/// within the document (implying sixteen pages are defined).])
///
/// Unfortunately, we cannot render an example since zen-zine requires
/// access to the page information to be able to deduce the size of the zine
/// pages.
///
/// -> content
#let zine16(
  /// whether to be in printer mode (false) or digital (true)
  ///
  /// When creating a digital zine, the margin specified with `zine-page-margin`
  /// is divided by two so that the digital visually looks like the printed
  /// zine with the pages cut out.
  /// -> boolean
  digital: false,
  /// margin for the zine pages
  ///
  /// These can be the normal margin names or the zine margins listed
  /// in @zine-margin-names.
  ///
  /// -> length|dictionary
  margin: auto,
  /// other named arguments are given to zine-page
  ..zine-page-kwargs,
  /// input content of zine
  /// -> content
  content
) = {

  let contents = break-content-into-page-array(content);

  assert.eq(
    contents.len(), 16,
    message: "Document content does not have exactly 16 pages (15 pagebreaks), only "+str(contents.len())+" pages were found."
  )

  // extract the margin separately so we can remap the names if necessary
  let margin = if margin == auto {
    if zine-page-kwargs.named().keys().contains("numbering") {
      zine16-default-margin-numbers
    } else {
      zine16-default-margin
    }
  } else {
    margin
  }

  // the trim margin is something we apply to the entire printer page
  // and /not/ to the zine pages themselves so we `remove` it here
  // zine-page is handling the margin, so the default parent margin 
  // should be zero (no trim)
  let trim-margin = if type(margin) == dictionary {
    margin.remove("trim-margin", default: 0pt)
  } else {
    0pt
  }

  set page(margin: trim-margin)

  context {
    // we need to be in context so we can get the full page's height and width
    // in order to deduce the zine page height and width
    // each of the zine pages share the margin with their neighbors
    // this height/width is without margins
    let zine-page-height = (page.height - 2*trim-margin)/4;
    let zine-page-width = (page.width - 2*trim-margin)/4;

    // wrap pages in zine-page
    let contents = contents.enumerate().map(
      ((i, content)) => {
        let zine-page-margin = if type(margin) == dictionary {
          key-remapper(zine16-margin-names.at(i))(margin)
        } else {
          margin
        }
        zine-page(
          height: zine-page-height,
          width: zine-page-width,
          page-number: i+1,
          margin: zine-page-margin,
          ..zine-page-kwargs,
          content
        )
      }
    )

    if digital {
      // resize output page to be the same size as the zine-page
      // and set margin to zero since digital zine is after trimming and folding
      set page(margin: 0pt, height: zine-page-height, width: zine-page-width)
      for zpage in contents {
        zpage
      }
    } else {
      let contents = (
        contents.slice(5,9).rev()+contents.slice(9,11)+contents.slice(3,5)+contents.slice(11,13).rev()+contents.slice(1,3).rev()+contents.slice(13,16)+contents.slice(0,1)
      ).enumerate().map(
        // flip if on top row
        elem => if elem.at(0) < 4 or elem.at(0) > 7 and elem.at(0) < 12 {
          rotate(
            180deg,
            origin: center,
            elem.at(1)
          )
        } else {
          elem.at(1)
        }
      )

      let zine-grid = grid.with(
        columns: 4 * (zine-page-width, ),
        rows: zine-page-height
      )
      zine-grid(..contents)
    }
  }
}
