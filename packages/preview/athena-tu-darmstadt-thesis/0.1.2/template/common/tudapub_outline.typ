

#let tudapub-make-outline-table-of-contents(
  // How the table of contents outline is displayed.
  // Either "adapted":    use the default typst outline and adapt the style 
  // or     "rewritten":  use own custom outline implementation which better reproduces the look of the original latex template.
  //                      Note that this may be less stable than "adapted", thus when you notice visual problems with the outline switch to "adapted".
  outline_table_of_contents_style: "rewritten",

  // style/layout parameters
  fill_dot_space: 3pt,
  heading_numbering_intent: 1em,
  heading_numbering_width_per_level: 0.65em,
  heading_first_level_v_space: 15pt,
  heading_page_number_width: 1.5em,

  // all headings with a level larger than this number will be excluded from the outline
  heading_numbering_max_level: none
) = {

  // check args
  if not (outline_table_of_contents_style == "adapted" or outline_table_of_contents_style == "rewritten") {
    panic("outline_table_of_contents_style has to be either 'adapted' or 'rewritten'")
  }




  // alternative (simpler than next solution)
  if outline_table_of_contents_style == "adapted" {
    show outline.entry.where(
      level: 1
    ): it => {
      // prevent recursion
      if it.fill != none {
        // new outline entry without fill
        let params = it.fields()
        params.fill = none
        //params.page = [#params.page]
        strong[
          #set text(
            font: "Roboto",
            fallback: false,
          )
          #v(14pt, weak: true)
          #outline.entry(..params.values())
        ]
      } else {
        it
      }
    }

    outline(
      target: heading.where(outlined: true),
      depth: heading_numbering_max_level,
      indent: 1em,
      fill: block(width: 100% - 1em)[
        #repeat[ #h(fill_dot_space) . #h(fill_dot_space) ] 
      ]
    )
  }
  //*/

  
  // own outline elements
  // @deprecated
  /*
  let mem-lengths = state("mem-lengths", ())
  let space = 1em
  show outline.entry: it => style(styles => {
      locate(loc => {
          let el = it.element
          let c-heading = numbering(el.numbering, ..counter(heading).at(el.location()))

          let indent = if it.level > 1 {
              mem-lengths.at(loc).at(it.level - 2)
          } else {0pt}

          let preamb = [#h(indent)#c-heading#h(space)]
          let size = measure(preamb, styles)

          mem-lengths.update(array => {
              if array.len() > it.level - 1 {
                  array.at(it.level - 1) = size.width
              } else {
                  array.push(size.width)
              }
              array
          })

          /*
          let text_params = ()
          if it.level == 1 {
            text_params = (
              font: "Roboto",
              fallback: false,
              weight: "bold"
            )
          }
          set text(
            ..text_params
          )*/
          [
            #preamb#el.body 
            #box(width: 1fr, repeat[ #h(fill_dot_space) . #h(fill_dot_space)]) 
            #box(width: 1.5em)[
              #align(right)[#it.page]
            ] 
            //#it.page
          ]
      })
  })
  */
  


  
  // own rewritten outline
  if outline_table_of_contents_style == "rewritten" {
    heading(
      level: 1, outlined: false
    )[Contents]


    context {
      let headings = query(selector(heading.where(outlined: true)).after(here()))


      
      // outline params
      let heading_numbering_intent = 1em
      let heading_numbering_width_per_level = 0.65em
      let heading_first_level_v_space = 15pt
      let heading_page_number_width = 1.5em

      // go over all headings
      for it in headings {
        if it.level > heading_numbering_max_level {
          continue
        }

        

        // save location and page of current heading
        let it_loc = it.location()
        //let it_page = numbering(it_loc.page-numbering(), ..counter(page).at(it_loc))
        let page = counter(page).at(it.location())
        let it_counter_arr = counter(heading).at(it_loc)

        let numbering_width = heading_numbering_width_per_level*it.level


        let sum_prev_levels = range(it.level).sum()
        let padd = (  (it.level - 1) * heading_numbering_intent 
                    + (sum_prev_levels) * heading_numbering_width_per_level*1 
                    )
        // box[#pad(left: padd)
        let preamb = box(fill: none)[#pad(left: padd)[
          #box(width: numbering_width + heading_numbering_intent, fill: none, {
            // if heading has numbering
            if it.numbering != none {
              numbering(it.numbering, ..it_counter_arr) //.display(it.numbering)
            }
            else {
              //numbering("1.1", ..it_counter_arr) + "?"
            }
          })
          //#h(1em)
        ]]

        //let t = 0
        //t = measure(preamb, styles).width
        //[#t]

        // only count, if the heading is numbered!
        let text_params = ()
        let fill_dots = box(width: 1fr, repeat[ #h(fill_dot_space) . #h(fill_dot_space)]) 

        // heading with level 1 has different styling
        if it.level == 1 {
          text_params = (
            font: "Roboto",
            fallback: false,
            weight: "bold"
          )
          fill_dots = box(width: 1fr)//, repeat(str.from-unicode(32)))
          v(heading_first_level_v_space, weak: true)
        }
        set text(
          ..text_params
        )
        link(it_loc)[
          #preamb#it.body 
          #fill_dots
          #box(width: heading_page_number_width)[
            #align(right)[#page.join()]
          ] 
          //#it.page
          //\
          //#it.fields()
          //#outline.entry(it.level, it, [Test], [], [])
          \
        ]
      }
    }

  }

}