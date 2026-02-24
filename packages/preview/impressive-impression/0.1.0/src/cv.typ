#import "theme.typ": theme-helper
#import "themes/forty-seconds.typ": theme-fortyseconds

/// Create a CV with the specified theme and paper size
#let cv(
  /// Theme dictionary to use for styling.
  /// See src/themes/forty-seconds.typ for an example.
  /// -> dictionary
  theme: none,
  /// Paper size to use for the CV.
  /// -> string
  paper: "a4",
  /// Main contents of the CV.
  /// Each element in the array can be either content or a dictionary set up as
  /// - (left: content, main: content) -> This corresponds to a left aside and a main section
  /// - (right: content, main: content) -> This corresponds to a right aside and a main section
  /// - (main: content) -> This corresponds to a main section without an aside
  pages-content: (),
) = {
  /// Helper function to get key from theme
  let th = theme-helper(theme)

  set page(
    paper: paper,
    margin: 0pt,
  )

  set text(..th("base-text"))

  // Set up show functions
  let _aside-heading(it) = {
    if it.level == 1 {
      // Name
      set align(center)
      set text(
        ..th("aside-name-text"),
      )
      it
    } else if it.level == 2 {
      set text(
        ..th("aside-heading-text"),
      )

      if th("aside-heading-line-enable") {
        box(it) + box(context {

          let size = measure(it)

          let a = here().position()

          let start = a.x + size.width

          let left-over-space = th("aside-width") - th("margin") - size.width
          let gap = th("aside-heading-line-gap")

          let stroke-line = (
            paint: th("aside-heading-text").fill,
            thickness: th("aside-heading-line-thickness"),
            cap: "butt",
          )
          let stroke-line-end = (
            paint: th("aside-heading-text").fill,
            thickness: th("aside-heading-line-thickness"),
            cap: "round",
          )
          let _line = line(start: (gap, 0%), length: left-over-space - gap, stroke: stroke-line)
          let _boxed-line = box(_line, height: size.height)
          let _line2 = line(start: (gap, 0%), length: 0pt, stroke: stroke-line-end)
          let _boxed-line2 = box(_line2, height: size.height)

          // let _line = align(box(line(length: left-over-space), height: size.height), horizon)
          align(_boxed-line + _boxed-line2, horizon)
          // [#_line]
        }, width: 0pt)
      } else {
        it
      }

    } else {
      it
    }
  }

  let _main-heading(it) = {
    if it.level == 2 {
      set text(..th("main-heading-text"))
      it
    } else if it.level == 3 {
      set text(..th("main-subheading-text"))
      it
    }
  }

  // Set up wrap functions
  let wrap-aside(aside, side) = {
    let _aside-inset = (
      top: th("margin"),
      bottom: th("margin"),
    )
    if side == "right" {
      _aside-inset.right = th("margin")
      _aside-inset.left = th("gutter-margin")
    } else if side == "left" {
      _aside-inset.right = th("gutter-margin")
      _aside-inset.left = th("margin")
    }

    let _aside = [
      #set text(..th("aside-text"))
      #show heading: _aside-heading
      #aside
    ]

    block(
      inset: _aside-inset,
      width: th("aside-width"),
      height: 100%,
      fill: th("aside-background-color"),
      _aside,
    )
  }

  let wrap-main(main, aside-side) = {
    let _main-inset = (
      top: th("margin"),
      bottom: th("margin"),
    )
    if aside-side == "right" {
      _main-inset.left = th("margin")
      _main-inset.right = th("gutter-margin")
    } else if aside-side == "left" {
      _main-inset.left = th("gutter-margin")
      _main-inset.right = th("margin")
    } else if aside-side == none {
      _main-inset.left = th("margin")
      _main-inset.right = th("margin")
    }

    let _main = [
      #set text(..th("main-text"))
      #show heading: set block(above: 1em)
      #show heading: _main-heading
      #main
    ]

    block(
      inset: _main-inset,
      width: 100%,
      height: 100%,
      fill: none,
      _main,
    )
  }

  // Generate main content
  let final-contents = ()
  for (index, entry) in pages-content.enumerate() {
    let grid-contents = ()

    if type(entry) == dictionary {
      assert(entry.at("main", default: none) != none, message: "Main content must be provided in the dictionary entry")
    }

    if type(entry) == content {
      // Single main content
      grid-contents.push(grid.cell(wrap-main(entry, none), rowspan: 2))
    } else if type(entry) == dictionary and entry.len() == 1{
      // Single main content
      grid-contents.push(grid.cell(wrap-main(entry.at("main"), none), rowspan: 2))
    } else if type(entry) == dictionary {
      if entry.at("left", default: none) != none {
        // Left aside and main content
        grid-contents += (
          wrap-aside(entry.at("left"), "left"),
          grid.vline(stroke: th("gutter-stroke")),
          wrap-main(entry.at("main"), "left"),
        )
      } else if entry.at("right", default: none) != none {
        // Right aside and main content
        grid-contents += (
          wrap-main(entry.at("main"), "right"),
          grid.vline(stroke: th("gutter-stroke")),
          wrap-aside(entry.at("right"), "right"),
        )
      } else {
        panic("No aside (right/left) found in page " + (index + 1))
      }

    } else {
      panic("Invalid entry type in pages-content: " + type(entry))
    }

    if index != 0 {
      final-contents.push(pagebreak())
    }

    final-contents.push(grid(
      columns: 2,
      ..grid-contents,
    ))
  }

  // Spit out content
  [
    #set text(..th("base-text"))
    #final-contents.join()
  ]
}
