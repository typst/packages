#import "props.typ": *
#import "format.typ": *
#import "tudacolors.typ": tuda_colors


// note the page needs to have the correct margins.
// Set these up before
#let tudpub-make-title-page(
  title: [Title],
  title_german: [Title German],

  // "master" or "bachelor" thesis
  thesis_type: "master",

  // the code of the accentcolor.
  // A list of all available accentcolors is in the list tuda_colors
  accentcolor: "9c",

  // language for correct hyphenation
  language: "eng",


  // author name as text, e.g "Albert Author"
  author: "A Author",

  // date of submission as string
  date_of_submission: datetime(
    year: 2023,
    month: 10,
    day: 4,
  ),

  location: "Darmstadt",

  // array of the names of the reviewers
  reviewer_names: ("Super Supervisor 1", "Super Supervisor 2"),

  // tuda logo, has to be a svg. E.g. image("PATH/TO/LOGO")
  logo_tuda: none,

  // optional sub-logo of an institute.
  // E.g. image("logos/iasLogo.jpeg")
  logo_institute: none,

  // How to set the size of the optional sub-logo.
  // either "width": use tud_logo_width*(2/3)
  // or     "height": use tud_logo_height*(2/3)
  logo_institute_sizeing_type: "width",

  // Move the optional sub-logo horizontally
  logo_institute_offset_right: 0mm,

  // an additional white box with content for e.g. the institute, ... below the tud logo.
  // E.g. logo_sub_content_text: [ Institute A \ filed of study: \ B]
  logo_sub_content_text: none,

  title_height: 3.5em
) = {

  // vars
  let accentcolor_rgb = tuda_colors.at(accentcolor)
  let title_separator_spacing = 15pt
  let title = [#title]
  //let title_height = 150pt //measure(title, styles).height
  let title_page_inner_margin_left = 8pt
  let logo_tud_height = 22mm

  let submission_date = format-date(date_of_submission, location)

  let thesis_type_text = {
    if lower(thesis_type) == "master" {"Master"}
    else if lower(thesis_type) == "bachelor" {"Bachelor"}
    else {panic("thesis_type has to be either 'master' or 'bachelor'")}
  }


  ///////////////////////////////////////
  // Display the title page
  page(footer: [])[
    //#set par(leading: 1em)
    #set text(
      //font: "Comfortaa",
      font: "Roboto",
      //stretch: 50%,
      //fallback: false,
      weight: "bold",
      size: 35.86pt,
      //height: 
    )

    //#v(80pt)
    #grid(
      rows: (auto, 1fr),
      stack(
        // title
        block(
          inset: (left: title_page_inner_margin_left),
          height: title_height)[
            #set par(
              justify: false,
              leading: 20pt   // line spacing
            )
            #align(bottom)[#title]
          ],
        v(title_separator_spacing),
        line(length: 100%, stroke: tud_heading_line_thin_stroke),
        v(3mm), // title_separator_spacing
        //
        // sub block with reviewers and other text
        block(inset: (left: title_page_inner_margin_left))[
          #set text(size: 12pt)
          #set par(
            leading: 5.8pt
          )
          #title_german
          \
          #set text(weight: "regular")
          #thesis_type_text thesis by #author
          \
          Date of submission: #submission_date
          \
          \
          #for (i, reviewer_name) in reviewer_names.enumerate() [
            #(i+1). Review: #reviewer_name
            \
          ]
          #v(-8pt) // spacing optional
          #location
        ],
        v(15pt)
      ),
      // color rect with logos
      rect(
        fill: color.rgb(accentcolor_rgb),
        stroke: (
          top: tud_heading_line_thin_stroke,
          bottom: tud_heading_line_thin_stroke
        ),
        inset: 0mm,
        width: 100%,
        height: 100%//10em
      )[
        
        #v(logo_tud_height/2)
        #context {
          //let tud_logo = image(logo_tuda_path, height: logo_tud_height)
          let tud_logo = [
                #set image(height: logo_tud_height)
                #if logo_tuda == none {
                  box(fill: white)[logo_tuda \ not set!]
                } else {
                  logo_tuda
                } 
          ]
          let tud_logo_width = measure(tud_logo).width
          let tud_logo_offset_right = -6.3mm
          tud_logo_width += tud_logo_offset_right

          align(right)[
            //#natural-image(logo_tuda_path)
            #grid( 
              // tud logo
              // move logo(s) to the right
              box(inset: (right: tud_logo_offset_right), fill: black)[
                #set image(height: logo_tud_height)
                #tud_logo
              ],
              // sub logo
              v(5mm),
              // height from design guidelines
              if logo_institute != none {
                box(inset: (right: logo_institute_offset_right), fill: black)[
                  #set image(height: tud_logo_width*(2/3))
                  #{
                    if logo_institute_sizeing_type == "width" {
                      //image(logo_institute_path, width: tud_logo_width*(2/3))
                      set image(width: tud_logo_width*(2/3), height: auto)
                      logo_institute
                    }
                    else if logo_institute_sizeing_type == "height" {
                      //image(logo_institute_path, height: logo_tud_height*(2/3))
                      set image(height: logo_tud_height*(2/3))
                      logo_institute
                    }
                    else {
                      panic("logo_institute_sizeing_type has to be width or height")
                    }
                  }
                ]
              },
              // sub box with custom text
              if logo_sub_content_text != none {
                box(width: tud_logo_width, 
                    outset: 0mm, 
                    fill: white, 
                    inset: (
                      top: 6pt,
                      bottom: 6pt,
                      left: 4.5mm,
                      right: 6pt
                    ),
                    align(left)[
                    #set text(weight: "regular", size: 9.96pt)
                  #logo_sub_content_text
                ])
            }
            )
          ]
        }
        
      ]
    )
  ]
}