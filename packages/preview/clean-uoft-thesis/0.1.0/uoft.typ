#import "@preview/wordometer:0.1.4": word-count, total-words, word-count-of, string-word-count
#show: word-count

// parse_page_dims() // {{{
#let parse_page_dims(page_size_style) = {
  let (page_width, page_height) = if page_size_style == "metric" {
    (21.5cm, 28cm)
  } else if (page_size_style == "imperial") {
    (8.5in, 11in)
  } else {
    panic([Parameter `page_size_style` must be either `metric` or `imperial`])
  }
  (page_width, page_height)
}
//  // }}}

// parse_margin_dims() // {{{
#let parse_margin_dims(page_margin_style) = {
  let (margin_t, margin_b, margin_l, margin_r) = if (page_margin_style == "left_metric") {
    (20mm, 20mm, 32mm, 20mm)
  } else if (page_margin_style == "left_imperial") {
    (0.75in, 0.75in, 1.25in, 0.75in)
  } else if (page_margin_style == "metric") {
    (20mm, 20mm, 20mm, 20mm)
  } else if (page_margin_style == "imperial") {
    (0.75in, 0.75in, 0.75in, 0.75in)
  } else {
    panic([Parameter `page_margin_style` must be one of `left_metric`, `left_imperial`, `metric`, or `imperial`])
  }
  (margin_t, margin_b, margin_l, margin_r)
}

//  // }}}

// parse_font() // {{{
#let parse_font(font_size) = {
  if font_size < 10pt {
    panic([Font font_size must be at least 10pt])
  } else {
    font_size
  }
}
//  // }}}

// init_title_page() // {{{
#let init_title_page(title,
                author,
                department,
                degree,
                graduation_year,
                title_page_top_margin,
                title_page_gap_1_height,
                title_page_gap_2_height,
                title_page_gap_3_height,
                title_page_gap_4_height,
                title_page_bottom_margin,
                page_size_style
              ) = {
  set par(spacing: 0em)

  let top_margin = if title_page_top_margin in (2in, 5cm) {
    title_page_top_margin
  } else {
    panic([Parameter `title_page_top_margin` must be either `2in` or `5cm`])
  }

  let gap_1_height = if title_page_gap_1_height in (1.5in, 4cm) {
    title_page_gap_1_height
  } else {
    panic([Parameter `title_page_gap_1_height` must be either `1.5in` or `4cm`])
  }

  let gap_2_height = if title_page_gap_2_height in (1.5in, 4cm) {
    title_page_gap_2_height
  } else {
    panic([Parameter `title_page_gap_2_height` must be either `1.5in` or `4cm`])
  }

  let gap_3_height = if title_page_gap_3_height in (2in, 5cm) {
    title_page_gap_3_height
  } else {
    panic([Parameter `title_page_gap_3_height` must be either `2in` or `5cm`])
  }

  let gap_4_height = if title_page_gap_4_height in (1.25in, 3cm) {
    title_page_gap_4_height
  } else {
    panic([Parameter `title_page_gap_4_height` must be either `1.25in` or `3cm`])
  }

  let bottom_margin = if title_page_bottom_margin in (1.25in, 3cm) {
    title_page_bottom_margin
  } else {
    panic([Parameter `title_page_bottom_margin` must be either `1.25in` or `3cm`])
  }

  let (width, height) = parse_page_dims(page_size_style)
  set page(
    width: width,    
    height: height,
    margin: (
      top: top_margin,
      bottom: bottom_margin,
      left: 0cm,
      right: 0cm
    ),
  ) 

  align(center)[
    #text(size: 1.4em)[#title]
    #v(gap_1_height)
    by
    #v(gap_2_height)
    #author
    #v(gap_3_height)
    A thesis submitted in conformity with the requirements \ for the degree of #degree \
    Department of #department \
    University of Toronto
    #v(gap_4_height)
    #sym.copyright Copyright by #author #graduation_year
  ]
}
//  // }}}

// init_abstract() // {{{
#let init_abstract(abstract,
                   title,
                   author,
                   degree,
                   department,
                   graduation_year) = {

  show heading: set block(above: 0em, below: 1em)

  let wc = word-count-of(abstract).words

  let within_d_lim = (int(wc) <= 350)
  let within_m_lim = (int(wc) <= 150)
  let is_d = degree.first() == "D"
  let is_m = degree.first() == "M"
  let abstract = if (is_d and not within_d_lim) {
    [Abstract exceeds doctoral word limit (350).]; panic()
  } else if (is_m and not within_m_lim) {
    [Abstract exceeds masters word limit (150).]; panic()
  } else {
    abstract
  }

  set align(center)
  text(1.4em)[#title]

  linebreak()
  linebreak()

  author
  linebreak()
  degree

  linebreak()
  linebreak()

  "Department of " + department
  linebreak()
  "University of Toronto"
  linebreak()
  graduation_year

  set text(top-edge: 0.7em, bottom-edge: -0.3em)

  v(2em)

  heading("Abstract", outlined: false)

  set align(left)
  set par(justify: true, leading: 1.3em)

  abstract
}
//  // }}}

// init_acknowledgements() // {{{
#let init_acknowledgements(acknowledgements) = {
  show heading: set block(above: 0em, below: 1em)
  heading("Acknowledgements")
  acknowledgements
}
//  // }}}

// init_body() // {{{
#let init_body(body) = {
  set heading(numbering: "1.1.1.a")
  body
}
//  // }}}

// init_table_of_contents() // {{{
#let init_table_of_contents() = {
  show heading: set block(above: 0em, below: 0.5em)
  heading("Table of Contents") 
  outline(
    title: []
  )
}
//  // }}}

// init_list_of_tables() // {{{
#let init_list_of_tables() = {
  show heading: set block(above: 0em, below: 0.5em)
  heading("List of Tables")
  outline(
    title: [],
    target: figure.where(kind: table)
  )
}
//  // }}}

// init_list_of_plates() // {{{
#let init_list_of_plates() = {
  show heading: set block(above: 0em, below: 0.5em)
  heading("List of Plates")
  outline(
    title: [],
    target: figure.where(kind: "plate")
  )
}
//  // }}}

// init_list_of_figures() // {{{
#let init_list_of_figures() = {
  show heading: set block(above: 0em, below: 0.5em)
  heading("List of Figures")
  outline(
    title: [],
    target: figure.where(kind: image)
  )
} 
//  // }}}

// init_list_of_appendices() // {{{
#let init_list_of_appendices() = {
  show heading: set block(above: 0em, below: 0.5em)
  heading("List of Appendices")
  outline(
    title: [Appendix],
    target: heading.where(supplement: [Appendix])
  )
}
//  // }}}

// check_valid_degree() // {{{
#let check_valid_degree(degree) = {
  let not_doctoral = not degree.slice(0, 6) == "Doctor"
  let not_masters = not degree.slice(0, 6) == "Master"
  if (not_doctoral and not_masters)  {
    [`degree` parameter must start with "Doctor" or "Master"]; panic()
  }
}
//  // }}}

// uoft() // {{{
// title:
// - The title of the thesis.
//
// author:
// - The author of the thesis.
//
// department:
// - The department for which the thesis is submitted.
//
// main_margin_style: 
// - "left_metric": (default) Applies 32 mm left margin and 20 mm top,
//   right, and bottom margin to the main text.
// - "left_imperial": Applies 1.25 in left margin and 0.75 in top, right,
//   and bottom margin to the main text.
// - "metric": Applies 20 mm margin to all sides of the main text.
// - "imperial": Applies 0.75 in margin to all sides of the main text.
#let uoft(title: none,
          author: [*missing_param_author*],
          department: [*missing_param_department*],
          degree: [*missing_param_degree*],
          graduation_year: [*missing_param_year*],
          abstract: [],
          acknowledgements: [],
          body: [],
          show_acknowledgements: true,
          show_list_of_tables: true,
          show_list_of_plates: false,
          show_list_of_figures: true,
          show_list_of_appendices: true,
          title_page_top_margin: 5cm,
          title_page_gap_1_height: 4cm,
          title_page_gap_2_height: 4cm,
          title_page_gap_3_height: 5cm,
          title_page_gap_4_height: 3cm,
          title_page_bottom_margin: 3cm,
          page_size_style: "metric",
          main_margin_style: "left_metric",
          font_size: 12pt,
          doc) = {
  let (page_width, page_height) = parse_page_dims(
    page_size_style
  )
  let (margin_t, margin_b, margin_l, margin_r) = parse_margin_dims(
    main_margin_style
  )
  set page(
    width: page_width,
    height: page_height,
    margin: (top: margin_t, bottom: margin_b, left: margin_l, right: margin_r),
  )
  let font_size = parse_font(font_size)
  set text(size: font_size)

  show heading: it => block(width: 100%)[
    #set text(weight: "regular")
    #(it.body)
  ]

  check_valid_degree(degree)

  init_title_page(
    title,
    author,
    department,
    degree,
    graduation_year,
    title_page_top_margin,
    title_page_gap_1_height,
    title_page_gap_2_height,
    title_page_gap_3_height,
    title_page_gap_4_height,
    title_page_bottom_margin,
    page_size_style,
  )

  pagebreak()

  set page(numbering: "i")

  init_abstract(
    abstract,
    title,
    author,
    degree,
    department,
    graduation_year
  )

  set par(leading: 0.75em)

  pagebreak()

  if (show_acknowledgements) {
    init_acknowledgements(acknowledgements)
    pagebreak()
  }

  init_table_of_contents()

  pagebreak()

  if (show_list_of_tables) {
    init_list_of_tables()
    pagebreak()
  }

  if (show_list_of_plates) {
    init_list_of_plates()
    pagebreak()
  }

  if (show_list_of_figures) {
    init_list_of_figures()
    pagebreak()
  }

  if (show_list_of_appendices) {
    init_list_of_appendices()
    pagebreak()
  }

  set page(numbering: "1")
  counter(page).update(1)

  init_body(body)

  doc
  //set page(margin: 10cm)
}
// // }}}
