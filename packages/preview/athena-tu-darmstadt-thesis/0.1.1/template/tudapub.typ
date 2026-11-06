#import "common/tudacolors.typ": tuda_colors
#import "common/tudapub_outline.typ": *
#import "common/props.typ": *
#import "common/tudapub_title_page.typ": *
#import "common/thesis_statement_pursuant.typ": *
#import "common/util.typ": *

#import "@preview/i-figured:0.2.3"



// This function gets your whole document as its `body` and formats it.
#let tudapub(
  title: [Title],
  title_german: [Title German],

  // Adds an abstract page after the title page with the corresponding content.
  // E.g. abstract: [My abstract text...]
  abstract: none,

  // "master" or "bachelor" thesis
  thesis_type: "master",

  // The code of the accentcolor.
  // A list of all available accentcolors is in the list tuda_colors
  accentcolor: "9c",

  // Size of the main text font
  fontsize: 10.909pt, //11pt,

  // Currently just a4 is supported
  paper: "a4",

  // Author name as text, e.g "Albert Author"
  author: "An Author",

  // Date of submission as string
  date_of_submission: datetime(
    year: 2042,
    month: 10,
    day: 4,
  ),

  location: "Darmstadt",

  // array of the names of the reviewers
  reviewer_names: ("SuperSupervisor 1", "SuperSupervisor 2"),

  // language for correct hyphenation
  language: "eng",

  // Set the margins of the content pages.
  // The title page is not affected by this.
  // Some example margins are defined in 'common/props.typ':
  //  - tud_page_margin_small  // same as title page margin
  //  - tud_page_margin_big
  // E.g.   margin: (
  //   top: 30mm,
  //   left: 31.5mm,
  //   right: 31.5mm,
  //   bottom: 56mm
  // ),
  margin: tud_page_margin_big,

  // tuda logo - has to be a svg. E.g. image("PATH/TO/LOGO")
  logo_tuda: none,  // e.g. image("logos/tuda_logo.svg")

  // optional sub-logo of an institute.
  // E.g. image("logos/iasLogo.jpeg")
  logo_institute: none,

  // How to set the size of the optional sub-logo
  // either "width": use tud_logo_width*(2/3)
  // or     "height": use tud_logo_height*(2/3)
  logo_institute_sizeing_type: "width",

  // Move the optional sub-logo horizontally
  logo_institute_offset_right: 0mm,

  // An additional white box with content e.g. the institute, ... below the tud logo.
  // Disable it by setting its value to none.
  // E.g. logo_sub_content_text: [ Institute A \ filed of study: \ B]
  logo_sub_content_text: [
    field of study: \
    Some Field of Study \
    \
    Institute A
  ],


  // The bibliography created with the bibliography(...) function.
  // When this is not none a references section will appear at the end of the document.
  // E.g. bib: bibliography("my_references.bib")
  bib: none,


  // Add an English translation to the "Erklärung zur Abschlussarbeit".
  thesis_statement_pursuant_include_english_translation: false,
  
  // Which pages to insert
  // Pages can be disabled individually.
  show_pages: (
    title_page: true,
    outline_table_of_contents: true,
    // "Erklärung zur Abschlussarbeit"
    thesis_statement_pursuant: true
  ),



  // Insert additional pages directly after the title page.
  // E.g. additional_pages_after_title_page: [
  //   = Notes
  //   #pagebreak()
  //   = Another Page
  // ]
  additional_pages_after_title_page: none,

  // Insert additional pages directly after the title page.
  // E.g. additional_pages_after_title_page: [
  //   = Notes
  //   #pagebreak()
  //   = Another Page
  // ]
  additional_pages_before_outline_table_of_contents: none,

  // Insert additional pages directly after the title page.
  // E.g. additional_pages_after_title_page: [
  //   = Notes
  //   #pagebreak()
  //   = Another Page
  // ]
  additional_pages_after_outline_table_of_contents: none,



  // For headings with a height level than this number no number will be shown.
  // The heading with the lowest level has level 1.
  // Note that the numbers of the first two levels will always be shown.
  heading_numbering_max_level: 3,

  // In the outline the max heading level will be shown.
  // The heading with the lowest level has level 1.
  outline_table_of_contents_max_level: 3,

  // Set space above the heading to zero if it's the first element on a page.
  // This is currently implemented as a hack (check the y pos of the heading).
  // Thus when you experience compilation problems (slow, no convergence) set this to false.
  reduce_heading_space_when_first_on_page: false,


  // How the table of contents outline is displayed.
  // Either "adapted":    use the default typst outline and adapt the style 
  // or     "rewritten":  use own custom outline implementation which better reproduces the look of the original latex template.
  //                      Note that this may be less stable than "adapted", thus when you notice visual problems with the outline switch to "adapted".
  outline_table_of_contents_style: "rewritten",

  // Use own rewritten footnote display implementation.
  // This may be less stable than the built-in footnote display impl.
  // Thus when having problems with the rendering of footnote disable this option.
  footnote_rewritten_fix_alignment: true,

  // When footnote_rewritten_fix_alignment is true, add a hanging intent to multiline footnotes.
  footnote_rewritten_fix_alignment_hanging_indent: true,

  // Use 'Roboto Slab' instead of 'Robot' font for figure captions.
  figure_caption_font_roboto_slab: true,

  // Figures have the numbering <chapter-nr>.<figure-nr>
  figure_numbering_per_chapter: true,

  // Equations have the numbering <chapter-nr>.<equation-nr>
  // @todo This seems to increase the equation number in steps of 2 instead of one
  equation_numbering_per_chapter: false,

  // content.
  body
) = context {
  // checks
  //assert(tuda_colors.keys().contains(accentcolor), "accentcolor unknown")
  //assert.eq(paper, "a4", "currently just a4 is supported as paper size")
  //[#paper]

  // vars
  let accentcolor_rgb = tuda_colors.at(accentcolor)
  let heading_2_line_spacing = 5.2pt
  let heading_2_margin_before = 13.5pt // typst 0.12: 12pt
  let heading_3_margin_before = 13.5pt // typst 0.12: 12pt


  // Set document metadata.
  set document(
    title: title,
    author: author
  )

  // for typst 0.12:
  // set par(
  //  leading: 4.8pt
  //  spacing: 91%
  // )

  // Set the default body font.
  set par(
    justify: true,
    //leading: 4.8pt//0.42em//4.7pt   // line spacing
    leading: 6.25pt//0.42em//4.7pt   // line spacing
  )
  //show par: set block(below: 1.1em) // was 1.2em
  set par(spacing: 1.2em)

  set text(
    font: "XCharter",
    size: fontsize,
    fallback: false,
    lang: language,
    kerning: true,
    ligatures: false,
    //spacing: 92%  // to make it look like the latex template
    //spacing: 84%  // to make it look like the latex template
    //spacing: 91%  // to make it look like the latex template
    spacing: 95%  // to make it look like the latex template
  )

  if paper != "a4" {
    panic("currently just a4 as paper is supported")
  }


  

  ///////////////////////////////////////
  // page setup
  // with header and footer
  let header = box(//fill: white,
    grid(
    rows: auto,
    rect(
      fill: color.rgb(accentcolor_rgb),
      width: 100%,
      height: 4mm //- 0.05mm
    ),
    v(1.4mm + 0.25mm), // should be 1.4mm according to guidelines
    line(length: 100%, stroke: 1.2pt) //+ 0.1pt) // should be 1.2pt according to guidelines
  ))

  let footer = grid(
    rows: auto,
    v(0mm),
    line(length: 100%, stroke: 0.6pt), // should be 1.6pt according to guidelines
    v(2.5mm),
    text(
        font: "Roboto",
        stretch: 100%,
        fallback: false,
        weight: "regular",
        size: 10pt
    )[
      #set align(right)
      // context needed for page counter for typst >= 0.11.0
      #context [
        #let counter_disp = counter(page).display()
        //#hide(counter_disp)
        //#counter_disp
        #context {
          let after_table_of_contents = query(selector(<__after_table_of_contents>).before(here())).len() >= 1
          if after_table_of_contents {counter_disp}
          else {hide(counter_disp)}
        }
      ]
    ]
  )

  let header_height = measure(header).height
  let footer_height = measure(footer).height

  // inner page margins (from header to text and text to footer)
  let inner_page_margin_top = 22.4pt // typst 0.12: 22pt
  let inner_page_margin_bottom = 30pt

  // title page has different margins
  let margin_title_page = tud_page_margin_title_page






  ////////////////////////////
  // content page setup
  let content_page_margin_full_top = margin.top + inner_page_margin_top + 1*header_height


  ///////////////////////////////////////
  // headings
  set heading(numbering: "1.1")

  // default heading (handle cases with level >= 3 < 5)
  show heading: it => context {
    if it.level > 5 {
      panic("Just heading with a level < 4 are supported.")
    }

    let heading_font_size = {
      if it.level <= 3 {11.9pt}
      else {10.9pt}
    }

    // change heading margin depending on its the first on the page
    let (heading_margin_before, is_first_on_page) = get-spacing-zero-if-first-on-page(
      heading_3_margin_before, 
      here(), 
      content_page_margin_full_top,
      enable: reduce_heading_space_when_first_on_page
    )

    set text(
      font: "Roboto",
      fallback: false,
      weight: "bold",
      size: heading_font_size
    )
    block(breakable: false, inset: 0pt, outset: 0pt)[
      #stack(
        v(heading_margin_before),
        block[
          #if it.level <= heading_numbering_max_level and it.outlined and it.numbering != none {
            counter(heading).display(it.numbering)
            h(0.3em)
          }
          #it.body
        ],
        v(10pt)
      )
    ]
  }


  // heading level 5
  show heading.where(level: 5): it => {
    par()[]
    set text(
      font: "Roboto",
      fallback: false,
      weight: "bold",
      size: fontsize
    )
    it.body + [: ] 
    h(1mm)
  }


  // heading level 1
  show heading.where(
    level: 1
  ): it => {
    // heading font style
    set text(
      font: "Roboto",
      fallback: false,
      weight: "bold",
      size: 20.6pt,
      //height: 
    )
    [#pagebreak(weak: true)]
    block(breakable: false, inset: 0pt, outset: 0pt, fill: none)[
      #stack(
        v(20mm),
        block[
          //\ \ 
          //#v(50pt)
          #if it.outlined and it.numbering != none {
            counter(heading).display(it.numbering)
            h(4pt)
          }
          #it.body
        ],
        v(13pt),
        line(length: 100%, stroke: tud_heading_line_thin_stroke),
        v(32pt)
      )
    ]
    // rest figure/equation numbers for each chapter
    // -> manual reimplementation of the i-figured.reset-counters(...) function
    //   -> fixes: heading page is wrong due to pagebreak 
    if figure_numbering_per_chapter {
      for kind in (image, table, raw)  {
        counter(figure.where(kind: i-figured._prefix + repr(kind))).update(0)
      }
    }
    if equation_numbering_per_chapter {
        counter(math.equation).update(0)
    }
  }
  // rest figure numbers for each chapter
  // -> not working together with pagebreak of heading level 1
  //   -> heading page is wrong
  //show heading: it => if figure_numbering_per_chapter {
  //    i-figured.reset-counters.with()(it)
  //  } else {it}


  // heading level 2 
  show heading.where(
    level: 2
  ): it => context {
    // change heading margin depending if its the first on the page
    let (heading_margin_before, is_first_on_page) = get-spacing-zero-if-first-on-page(
      heading_2_margin_before, 
      here(), 
      content_page_margin_full_top,
      enable: reduce_heading_space_when_first_on_page
    )

    set text(
      font: "Roboto",
      fallback: false,
      weight: "bold",
      size: 14.3pt
    )
    //set block(below: 0.5em, above: 2em)
    block(
      breakable: false, inset: 0pt, outset: 0pt, fill: none,
      //above: heading_margin_before,
      //below: 0.6em //+ 10pt
    )[
      #stack(
        v(heading_margin_before),
        line(length: 100%, stroke: tud_heading_line_thin_stroke),
        v(heading_2_line_spacing),
        block[
          #if it.outlined and it.numbering != none {
            counter(heading).display(it.numbering)
            h(2pt)
          }
          #it.body
          //[is_first_on_page: #is_first_on_page] 
          //#loc.position() #content_page_margin_full_top
        ],
        v(heading_2_line_spacing),
        line(length: 100%, stroke: tud_heading_line_thin_stroke),
        v(10pt)
      )
    ]
  }




  ///////////////////////////////////////

  // Configure equation numbering and spacing.
  set math.equation(numbering: "(1.1.1)")
  // typst0.12:  show math.equation: set block(spacing: 0.65em)
  show math.equation: set block(spacing: 0.9em)
  // equation numbering per chapter
  show math.equation.where(block: true): it => {
    if equation_numbering_per_chapter {
      // @todo this seems to increase the equation number in steps of 2 instead of one
      i-figured.show-equation(only-labeled: false, it)
    }
    else {it}
  }

  // Configure figures.
  let figure_caption_font = "Roboto"
  if figure_caption_font_roboto_slab {
    figure_caption_font = ("Roboto Slab", "Roboto")
  }
  show figure.caption: set text(
        font: figure_caption_font,
        ligatures: false,
        stretch: 100%,
        fallback: false,
        weight: "regular"
  )
  // figure numbering per Chapter
  show figure: it => {
    if figure_numbering_per_chapter {
      i-figured.show-figure(it)
    }
    else {it}
  }


  // configure footnotes
  set footnote.entry(
    separator: line(length: 40%, stroke: 0.5pt)
  )
  show footnote.entry: it => {
    if footnote_rewritten_fix_alignment {
      let loc = it.note.location()
      let it_counter_arr = counter(footnote).at(loc)
      let idx_str = numbering(it.note.numbering, ..it_counter_arr)
      //[#it.fields()]

      stack(dir: ltr, 
        h(5pt),
        super(idx_str),
        {
          // optional add indent to multi-line footnote
          if footnote_rewritten_fix_alignment_hanging_indent {
            par(hanging-indent: 5pt)[#it.note.body]
          }
          else {
            it.note.body
          }
        }
      )
    }
    else {
      // if not footnote_rewritten_fix_alignment keep as is
      it
    }
  }


  ///////////////////////////////////////
  // Display font checks
  check-font-exists("Roboto")
  check-font-exists("XCharter")



  ///////////////////////////////////////
  // Display the title page
  set page(
    paper: paper,
    numbering: "1",
    margin: (
      left: margin_title_page.left, //15mm,
      right: margin_title_page.right, //15mm,
      //  top: inner + margin.top + header_height
      top: margin_title_page.top + inner_page_margin_top + header_height,  // 15mm
      bottom: margin_title_page.bottom //+ 0*inner_page_margin_bottom + footer_height //20mm
    ),
    // header
    header: header,
    // don't move header up -> so that upper side is at 15mm from top
    header-ascent: inner_page_margin_top,//0%,
    // footer
    footer: none,//footer,
    footer-descent: 0mm //inner_page_margin_bottom
  )

  // make image paths relative to this dir of this .typ file
  let make-path-rel-parent(path) = {
    if not path == none and not path.starts-with("/") and not path.starts-with("./") and path.starts-with("") {
      return "../" + path
    }
    else {return path}
  }

  if show_pages.title_page {
    tudpub-make-title-page(
      title: title,
      title_german: title_german,
      thesis_type: thesis_type,
      accentcolor: accentcolor,
      language: language,
      author: author,
      date_of_submission: date_of_submission,
      location: location,
      reviewer_names: reviewer_names,
      logo_tuda: logo_tuda,
      logo_institute: logo_institute,
      logo_institute_sizeing_type: logo_institute_sizeing_type,
      logo_institute_offset_right: logo_institute_offset_right,
      logo_sub_content_text: logo_sub_content_text
    )
  }




  ///////////////////////////////////////
  // Content pages
  
  // body has different margins than title page
  // @todo some bug seems to insert an empty page at the end when content (title page) appears before this second 'set page'
  set page(
    margin: (
      left: margin.left, //15mm,
      right: margin.right, //15mm,
      top: margin.top + inner_page_margin_top + 1*header_height,  // 15mm
      bottom: margin.bottom + inner_page_margin_bottom + footer_height //20mm
    ),
     // header
    header: header,
    // don't move header up -> so that upper side is at 15mm from top
    header-ascent: inner_page_margin_top,//0%,
    // footer
    footer: footer,
    footer-descent: inner_page_margin_bottom //footer_height // @todo
  )

  // disable heading outlined for outline
  set heading(outlined: false)

  // additional_pages_after_title_page
  pagebreak(weak: true)
  additional_pages_after_title_page



  ///////////////////////////////////////
  // "Erklärung zur Abschlussarbeit" and abstract
  if show_pages.thesis_statement_pursuant {
    tudapub-get-thesis-statement-pursuant(
      date: date_of_submission, 
      author: author, 
      location: location, include-english-translation: thesis_statement_pursuant_include_english_translation
    )
  }

  if abstract != none [
    = Abstract
    #abstract
  ]




  ///////////////////////////////////////
  // Display the table of contents

  // additional_pages_before_outline_table_of_contents
  pagebreak(weak: true)
  additional_pages_before_outline_table_of_contents

  //page()[
  if show_pages.outline_table_of_contents [
    #tudapub-make-outline-table-of-contents(
      outline_table_of_contents_style: outline_table_of_contents_style,
      heading_numbering_max_level: outline_table_of_contents_max_level
    )
  ]


  // main body starts at the next page after table of contents
  pagebreak(weak: true)
  additional_pages_after_outline_table_of_contents

  // mark start of body
  //box[#figure(none) <__after_table_of_contents>]
  [#metadata("After Table of Contents") <__after_table_of_contents>]
  //[abc]

  // restart page counter
  counter(page).update(1)
  // restart heading counter
  counter(heading).update(0)



  // enable heading outlined for body
  set heading(outlined: true)

  // Display the paper's contents.
  body


  ///////////////////////////////////////
  // references
  if bib != none [
    #set heading(outlined: false)
    //#set text(font: "XCharter")
    //#set heading(outlined: false)
    //#bibliography(bibliography_path, style: "ieee", ..bibliography_params_dict)
    #set bibliography(style: "ieee")
    #bib
  ]
}
