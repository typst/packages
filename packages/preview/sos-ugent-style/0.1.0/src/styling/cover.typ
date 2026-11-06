// Basic layout elements of the UGent house style
#import "colors.typ": *
#import "../logos/logo.typ": *
#import "../i18n.typ"

// Define lengths based on UGent document grid
// See: https://styleguide.ugent.be/basic-principles/grid-and-layout.html
///
/// -> length
#let gridunit(size) = {
  let longedge = calc.max(size.width, size.height)
  let gridunit = longedge/28 // Divide by 7, then by 4
  gridunit
}

// TODO: When using this multiple times, the documents don't converge anymore :(

/// For courses, doctorates, ... even beamer
/// In accordance with UGent styleguide
///
/// The header/footer get appended *with* the same bounding box as the logo's.
/// This means that all supplied content (images) should have NO (vertical)
/// white bounding box.
/// If they do, you can crop them: https://github.com/typst/typst/issues/3147
/// See for example how it is done for the ugent logos further down ('BOXING').
///
/// The header/footer should be inline-content. Wrap it in #box if needed.
///
/// -> content (needs to be put in container OR #page.with(margin: 0)
///    OR page(background: ...))
#let ugent-cover-layout(
  faculty: none,
  secondary-faculty: none,
  header: none,
  footer: none,
  background-color: auto,
  // E.g. image
  background-content: none,
  logos-left-margin: 1, // gridunits
  main,
) = {
  if faculty == none and header != none {
    panic("Header without faculty not yet supported.")
  }
  if faculty == none and secondary-faculty != none {
    panic("Secondary faculty without primary faculty not supported.")
  }
  let has-header = faculty != none or header != none
  // TODO: let color depend on faculty?
  let background-color = if background-color == auto { ugent-blue }
                         else { background-color }

  // BOXING: needed to keep consecutive logos (header/footer) on the same line.
  // The negative inset is how much the image can grow outside the container,
  // which itself is defined by the grid inset (see cell-margins).
  // The goal in this grid layout is to keep the white image bounding box
  // (see the .png files) outside the container, such that the supplied
  // header/footer don't have to think about whitespace, *unless* it's already
  // part of their image file. The inset percentage here is the height of the 1-sided
  // bounding box relative to the content supposed to be inside the container.
  // The image itself should just be `height: 100%`.

  layout(size => {
    let gridunit = gridunit(size)
    // Needs to be inside context (== inside `#layout()`)
    let fac-logo  = select-faculty-logo(faculty: faculty,           height: 100%)
    let fac2-logo = select-faculty-logo(faculty: secondary-faculty, height: 100%)
    let fac-logo-box   = if fac-logo  != none { box(fac-logo, inset: (y: -100%)) }
    let ugent-logo-box = box(select-ugent-logo(height: 100%), inset: (y:  -50%))
    let fac2-logo-box  = if fac2-logo != none	{
      h(1fr)
      box(fac2-logo, inset: (
        y: -100%,
        left: -gridunit, // allow overlap of faculty bounding boxes
        // only remove bounding box when no following header present
        right: if header == none { -gridunit } else { 0pt }
      ))
    }

    // For the logos, enable top/bottom/right margins (see header/footer remark
    // in documentation). The left part is kept for the logo bounding box itself.
    // For the background & type area, only define the left margin.
    // The type area content will be overlayed WITH right(/top) margin.
    let cell-margins(x, y) = {
      if has-header {
        if y == 1 { (left: gridunit) }
        else { (left: (logos-left-margin -1)*gridunit, rest: gridunit) }
      } else {
        if y == 0 { (left: gridunit) }
        else { (left: (logos-left-margin -1)*gridunit, rest: gridunit) }
      }
    }
    // For the type area (Dutch: zetspiegel), enable right (& top) margin.
    let block-cover = block.with(width: 100%, height: 100%)
    let type-area = block-cover.with(
      // When type area extends to top, add top margin
      inset: (right: gridunit, top: if has-header { 0pt } else { gridunit }),
    )
    let main = if type(main) == content {
      main
    } else if type(main) == function {
      main(gridunit: gridunit) // use layout to access the container in main()
    } else { panic("The body of ugent-cover-layout should be content or a function") }

    // Use this to show visually how the grid cells & their insets exactly interact
    //import "../utils/debug.typ": *; show grid.cell: show-grid-cell
    grid(
      align: left,
      columns: 100%,
      //                     (faculty logo) | type area | UGent logo
      rows: if has-header { (3*gridunit,) } + (1fr, 4*gridunit),
      // It's a choice to define the inset here. Could also be defined in the cells.
      inset: cell-margins,

      ..if has-header {
        (// Array, to spread
         // The header could be wider than allowed... :(
         // Inspiration: https://forum.typst.app/t/how-to-auto-size-text-and-images/1290
         layout(size => {
           let it = fac-logo-box + fac2-logo-box + header
           let w = measure(height: size.height, it).width
           if w  >= size.width {
             // The header would be wider than allowed, adjust the height to compensate
             // TODO: At the moment, top aligned. Also left margin might be invaded.
             // Also, should we allow overlap between the bounding boxes?
             block(it, height: size.width/w * 100%)
           } else {
             it
           }
         }),
        )
      },
      {
       // TODO: once Typst has a z-order argument/element, make sure the background
       // is placed even before the header: https://github.com/typst/typst/issues/682
       place( // Background includes the margins
         block-cover(background-content, fill: background-color)
       )
       type-area(main) // Applies an inset to provide margins
      },
      ugent-logo-box + footer
    )
  })
}

#let ugent-cover-info-box() = {
  // TODO: write function for blue box

  // The title outside this blue box:
  // +- 4 gridunit inset top, 1 gridunit inset left/right

  // The blue box itself: (left bottom corner)
  // 10*gridunit high
  // 13,4 gridunit wide (1 gridunit left-margin, 5,5 gridunit right margin)
  // Insets:
  // 1 gridunit left + 0.5 gridunit right
  // +-1 gridunit top +  0.5 gridunit bottom
}
#let ugent-dissertation-box(
  /// As created by dissertation-info-to-full-sentences
  info: (:),
  gridunit: none,
) = {
  if gridunit == none { panic("Need ugent gridunit to correctly lay-out.") }

  import "elements.typ": ugent-heading-title-text, ugent-heading-rules
  v(6*gridunit)
  // put everything in a block with extra margins
  show: block.with(inset: (x: gridunit))

  show: ugent-heading-rules
  show heading: set heading(outlined: false)
  show heading: set par(leading: 0.45em)
  show heading.where(level: 1): set text(size: 25pt)
  show heading.where(level: 1): set underline(stroke: 2pt)
  show heading.where(level: 2): set text(size: 15pt, weight: "regular")
  // Destructive
  show heading.where(level: 1): h => block(
    ugent-heading-title-text(underlined: true, h),
    below: 20pt,
  )
  show heading.where(level: 2): h => block(
    ugent-heading-title-text(underlined: false, h),
  )
  //block(stroke: 1pt,
  heading(upper(info.title), level: 1)//)
  //block(stroke: 1pt,
  if info.subtitle != none { heading(upper(info.subtitle), level: 2) }//)

  set text(size: 11pt) // most used fontsize, set as default
  set par(leading: 0.65em, spacing: 2em)
  linebreak()
  info.wordcount

  v(2*gridunit) // TODO: should be a maximum value, if the next content can still fit
  text(size: 16pt, info.author)
  linebreak()
  info.student-number
  parbreak()
  text(size: 13pt, info.supervisors)
  parbreak()
  info.commissaris
  parbreak()
  info.submitted-for
  parbreak()
  info.academic-year
}

/// See ugent-cover-color
#let ugent-cover-layout-page(..args) = {
  set page(margin: 0pt)
  ugent-cover-layout(..args)
}

#let ugent-title-page(
  type: none,
  ..args,
) = {
  // Bachelorproef, masterproef, doctoraat
  if type == "dissertation" {
    ugent-cover-layout-page(background-color: none, ..args)
  } else if type == "dissertation-eduma" {
    ugent-cover-layout-page(
      header: h(1fr) + box(
        layout(size => box(
          select-faculty-logo(faculty: args.at("faculty"), height: 100%),
          // size.height ~= gridunit
          inset: (y: -100%, right: -size.height),
        ))
      ),
      background-color: none,
      logos-left-margin: 2,
      ..args,
      // Override user-provided args
      faculty: "pp",
    )
  } else {
    panic("Unknown UGent title page type: " + type)
  }
}

#let empty-title-page(..kwargs) = [
  This is an empty title-page.
  Make sure the correct cover-page function is used.
]
#let pdf-title-page(..kwargs) = {
    /*TODO: once including pdf's is supported, automatically include the correct title page (pdf from Plato)*/
}
