// Author: Dani Balague Guardia
// d.balagueguardia@tudelft.nl

#import "@preview/touying:0.6.3": *
#import "@preview/great-theorems:0.1.2": *

#let default_font_size = 26pt
#let default_title_font_size = 36pt

#let heading-fonts = ("Lato")
#let normal-fonts = ("Lato")

#let tudelft-colors = (
      primary: rgb("#3d98de"),
      secondary: rgb("#3d98de"),
      tertiary: rgb("#3d98de"),
      neutral-lightest: rgb("#ffffff"),
      neutral-darkest: rgb("#000000"),
)

#let common_icons = (
  academic_reasoning: image("../assets/Common/Common Icons/academic_reasoning.png"),
  arrow_down: image("../assets/Common/Common Icons/arrow_down.png"),
  tick_mark: image("../assets/Common/Common Icons/tick_mark.png"),
  arrows_pointing_out: image("../assets/Common/Common Icons/arrows_pointing_out.png", height: 1.73cm, width: 1.73cm),
  book_reference: image("../assets/Common/Common Icons/book_reference.png", height: 1.73cm, width: 1.73cm),
  list: image("../assets/Common/Common Icons/list.svg", height: 1.73cm, width: 1.73cm),
  looking_glass: image("../assets/Common/Common Icons/looking_glass.png",height: 1.73cm, width: 1.73cm),
  puzzle_piece: image("../assets/Common/Common Icons/puzzle_piece.png", height: 1.73cm, width: 1.73cm),
  question_mark: image("../assets/Common/Common Icons/question_mark.svg",height: 1.73cm, width: 1.73cm),
  target: image("../assets/Common/Common Icons/target.png", width: 1.73cm, height: 1.73cm)
)

#let probstats_icons = (
  bar_graphics_white: image("../assets/Common/ProbStats/icons/bar_graphics_white.svg",width: 1.44cm, height: 1.44cm),
  bar_graphics_yellow: image("../assets/Common/ProbStats/icons/bar_graphics_yellow.svg",width: 2.07cm, height: 2.07cm),
  dice_green: image("../assets/Common/ProbStats/icons/dice_green.svg",width: 2.07cm, height: 2.07cm),
  dice_white: image("../assets/Common/ProbStats/icons/dice_white.svg",width: 1.44cm, height: 1.44cm),
  regression_orange: image("../assets/Common/ProbStats/icons/regression_orange.svg",width: 2.07cm, height: 2.07cm),
  regression_white: image("../assets/Common/ProbStats/icons/regression_white.svg",width: 1.44cm, height: 1.44cm),
  idea_slide_icon: image("../assets/Common/ProbStats/icons/idea_slide_icon.svg",width: 1.73cm, height: 1.73cm),
  discussion_slide_item: image("../assets/Common/ProbStats/icons/discussion_slide_item.svg",width: 1.73cm, height: 1.73cm),
  collaboration_slide_item: image("../assets/Common/ProbStats/icons/collaboration_slide_item.svg",width: 1.73cm, height: 1.73cm)
)


#let MOOCgrey = rgb(217,217,217)
#let MOOCGray = rgb(191,191,191)
#let MOOCblue = rgb(8,138,224)
#let MOOCdarkblue = rgb(32,39,79)
#let MOOCorange = rgb(240,98,23) //234 95 28
#let MOOCred = rgb(110,16,15)
#let MOOCpurple = rgb(100,42,11)
#let MOOCyellow = rgb(254,199,8) //253,189 13
#let MOOCyellowBar = rgb(255,184,28)
#let MOOCgreen = rgb(108,194,74)

#let color(x, color) = text(fill: color, x)

#let PrimeItem(it) = {
  text(fill: tudelft-colors.primary)[#strong[#numbering("A.", it)]]
}

#let poll_answers(rows: 2, cols : 2, column-gutter: 1em, row-gutter: 1.4em, correct_answer : 0, students : false, font_size: default_font_size ,it) = {

    set enum(numbering: PrimeItem, indent: 0em)
  
    let list_items = it.children.enumerate().filter( x => calc.rem-euclid(x.at(0),2) == 1 ).map(x=> x.at(1))
  
    let answer_list = ()
    if type(correct_answer) == int{
        answer_list.push(correct_answer)
    }else{
      answer_list = correct_answer
    }
    
    grid(
      columns: cols,
      rows: rows,
      align: top + left,
      column-gutter: column-gutter,
      row-gutter: row-gutter,
      ..list_items.enumerate().map( x => {

            if answer_list.contains(x.at(0)+1) {
              if students {
                grid(columns : (1cm,auto),none, text(size: font_size,x.at(1)))
              }else{
                grid(columns : (1cm,auto),uncover("2-")[#common_icons.tick_mark], text(size: font_size, x.at(1)))
                v(-.4em)
              }
            }
            else{
               grid(columns: (1cm, auto), none, text(size: font_size, x.at(1)))
            }      
        }
      ).flatten()
    )
}

#let _tblock(self: none, blocktitle: none, title: none, header-size : default_font_size,  text-size : default_font_size , border : true , hscaling: 1,it) = {
  title = {
    if title != none and blocktitle != none {
      blocktitle + " (" + title + ")" + ":"
    } else if blocktitle != none {
      blocktitle + ":"
    } else {
      title
    }
  }
  let thickness = {
    if border {
      3pt
    }else{
      0pt
    }
  }
  let left_inset = {
    if border{
      0.5em
    }else{
      0em
    }
  }
  grid(
    columns: 1,
    rows : 1,
    row-gutter: 0pt,
    block(
      width: 29.33cm * hscaling,
      inset: (top: 0.4em, bottom: 0.5em, left: left_inset, right: 0.5em),
      stroke: (thickness: thickness , paint: tudelft-colors.primary),[
          #text(fill: tudelft-colors.neutral-darkest, size: header-size , weight: "bold")[#title]\
          #text(size: text-size)[#it]
      ]
    ),
  )
}

#let _dblock(self: none, blocktitle: none, title: none, header-size : default_font_size, text-size : default_font_size , it) = {
  title = {
    if title != none and blocktitle != none {
      blocktitle + " (" + title + ")" + ":"
    } else if blocktitle != none {
      blocktitle + ":"
    } else {
      title
    }
  }
  grid(
    stroke: (thickness: 2pt, paint: tudelft-colors.primary),
    columns: 1,
    rows : 1,
    row-gutter: 0pt,
    fill: tudelft-colors.primary,
    block(
      width: 29.33cm,
      inset: (top: 0.4em, bottom: 0.5em, left: 0.5em, right: 0.5em),[        
        #text(fill: tudelft-colors.neutral-lightest, size: header-size ,
        weight: "bold")[#title] \
          #text(size: text-size, fill: tudelft-colors.neutral-lightest)[#it]
        ]
    ),
  )
}

#let _blue_block(self: none,  text-size : default_font_size , it) = {

  grid(
    columns: 1,
    rows : 1,
    row-gutter: 0pt,
    block(
      width: 29.33cm,
      inset: (top: 0.4em, bottom: 0.5em, left: 0.5em, right: 0.5em),
      stroke: (thickness: 3pt, paint: tudelft-colors.primary),[
          #text(size: text-size)[#it]
      ]
    ),
  )
}

#let _grey_block(self: none, text-size : default_font_size, it) = {
  block(
    inset: (top: 0.5em, bottom: 0.5em, left: 0.5em, right: 0.5em),
    width: 29.33cm,
    fill : MOOCgrey,
    text(size: text-size)[#it]
  )
}

#let gray_block(text-size : default_font_size, it) = touying-fn-wrapper(
  _grey_block.with(text-size : text-size, it))
)

#let blue_block( text-size : default_font_size, it) = touying-fn-wrapper(_blue_block.with(text-size : text-size, it))

#let tblock(title: none, blocktitle: none, header-size: default_font_size, text-size : default_font_size, border: true, hscaling: 1, it) = touying-fn-wrapper(_tblock.with(title: title, blocktitle: blocktitle, text-size : text-size, border: border, hscaling: hscaling, it))

#let dblock(title: none, blocktitle: none, header-size : default_font_size, text-size : default_font_size , it) = touying-fn-wrapper(_dblock.with(title: title, blocktitle: blocktitle, header-size : header-size ,text-size : text-size,it))

#let theorem = tblock.with(blocktitle: "Theorem")
#let corollary = tblock.with(blocktitle: "Corollary")
#let remark = tblock.with(blocktitle: "Remark")
#let definition = dblock.with(blocktitle: "Definition")
#let definitions = dblock.with(blocktitle: "Definitions")


// Section Slide
#let new-section-slide(self: none, slide-type : none, subtype: (), body) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-page(
      fill: self.colors.primary,
      margin: 0cm,
    ),
  )
  let subtype_size = 20pt // Size of subtype text
  let main-body = {
    set align(center + horizon)
    set text(size: 42pt, fill: tudelft-colors.neutral-lightest)

    let subtype_list = ()
    if type(subtype) == str{
        subtype_list.push(subtype)
    }else{
        subtype_list = subtype
    }
    for stype in subtype_list{
      if stype == "estimation"{
        place(
          dx: 23.91cm, 
          dy: 10.98cm, 
          grid(
            columns: 2,
            column-gutter: 5mm,
            block[#probstats_icons.regression_white],
            block[#text("Estimation",size: subtype_size)]
          )
        )
      }
      if stype == "probability"{
        place(
          dx: 23.91cm, 
          dy: 13.1cm, 
          grid(
            columns: 2,
            column-gutter: 5mm,
            block[#probstats_icons.dice_white],
            block[#text("Probability",size: subtype_size)]
          )
        )
      }
      if stype == "models"{
        place(
          dx: 23.91cm, 
          dy: 15.06cm, 
          grid(
            columns: 2,
            column-gutter: 5mm,
            block[#probstats_icons.bar_graphics_white],
            block[#text("Models",size: subtype_size)]
          )
        )
      }
    }
    
    if slide-type == "probstats" {
      body
    }
    utils.display-current-heading(level: 1)
  }
  touying-slide(self: self, main-body)
})

// SLIDES:

#let title-slide(..args) = touying-slide-wrapper(self => {
  let info = self.info + args.named()
  let visual = info.title-visual != none


  self = utils.merge-dicts(
    self,
    config-page(
      margin: (left: 0pt, top: 0pt),
      
      footer: none
    )
  )
  touying-slide(self: self, {
    let titles-width = 16cm

    if type(info.background) == content {
        place(dx: 0.0cm, dy: 0.0cm, info.background)
    }else{
        place(dx: 0.0cm, dy: 0.0cm, image({"../assets/Common/" + info.background}, height: 19.05cm, width: 33.9cm))
    }

    if visual {
      titles-width = 11.8cm

      place(dx: 13.95cm, dy: 1.9cm, block(width: 12cm, height: 11cm, align(center + horizon, info.title-visual)))
    }

    if type(info.logo) == content {
        place(dx: 0.87cm, dy: 0.85cm, info.logo)
    }else{
        place(dx: 0.87cm, dy: 0.85cm, image("../assets/Common/" + info.logo,height: 4.11cm) )
    }
    place(dx: 0cm, dy: 0cm, image("../assets/Common/Common Icons/prime_white_rect_title.png", width :33.87cm))
    place(dx: 5.75cm, dy: 1.74cm, text(font: heading-fonts, size: default_title_font_size, fill: tudelft-colors.primary, weight: "bold", info.title))
    place(dx: 5.75cm, dy: 3.37cm, text(font: heading-fonts, size: default_font_size, fill: black, info.subtitle, weight: "light"))
  })
})


#let programme_slide(title: auto, book_sections : none, ..args) = touying-slide-wrapper(self => {
  let section_string = ""
  let count = 0
  let _book_sections = ()
  if title != auto {
    self.store.title = title
  }
  if type(book_sections) != array {
      _book_sections = (book_sections,)
  }
  else{
    _book_sections = book_sections
  }
  if book_sections != none {
    // convert the array into an array of strings
    //_book_sections = _book_sections.map(it => str(it));
    count = _book_sections.len();
  }
  
  self = utils.merge-dicts(
    self,
    config-page(
      margin: (left: 0pt, top: 0pt),
    ),
  )
  touying-slide(self: self, {
          if count == 0 {
            section_string = ""
          } else if count == 1 {
            section_string = "Section " + str(_book_sections.first())
          } else if count == 2 {
            section_string = "Sections " + str(_book_sections.first()) + " and " + str(book_sections.last())
          } else {
            section_string = "Sections " + _book_sections.map(it => str(it)).slice(0, count - 1).join(", ") + ", and " + str(_book_sections.last())
          }
          place(dx: 0cm, dy: 0cm, rect(width: 1.44cm, height: 4.37cm, fill: tudelft-colors.primary))
          place(dx: 2.23cm, dy: 1.82cm, text(size: default_title_font_size, utils.display-current-heading(level : 2), fill: tudelft-colors.primary, weight: "bold"))

          place(dx: .2cm, dy: 3.3cm, rect( stroke: none,height: 1.1cm,
          text( context utils.slide-counter.display(), fill: tudelft-colors.neutral-lightest, size: 22pt )))
          place(dx: 2.26cm, dy: 16.94cm, image("../assets/Common/Common Icons/book_reference.png", height: 1.69cm, width: 1.69cm))
          place(dx: 4.29cm, dy: 17.53cm, text(size: default_font_size,section_string))
          place(dx: 2.02cm, dy: 4.50cm, block(width: 29.32cm, height: 20.5cm, align(top + left, text(font: heading-fonts, size: default_font_size, fill: black,..args))))

  })
})



#let wrapup_slide(title: auto, topic: "", book_sections : (), text-size : default_font_size, ..args) = touying-slide-wrapper(self => {
  if title != auto {
    self.store.title = title
  }
  
  let book_sections = book_sections.map(it => str(it));
  let count = book_sections.len();
  let section_string = ""

  if count == 0 {
    section_string = ""
  } else if count == 1 {
    section_string = "Section " + book_sections.first()
  } else if count == 2 {
    section_string = "Sections " + book_sections.first() + " and " + book_sections.last()
  } else {
    section_string = "Sections " + book_sections.slice(0, count - 1).join(", ") + ", and " + book_sections.last()
  }
  
  self = utils.merge-dicts(
    self,
    config-page(
      margin: (left: 0pt, top: 0pt),
    ),
  )
  touying-slide(self: self, {
          place(dx: 0cm, dy: 0cm, rect(width: 1.44cm, height: 4.37cm, fill: tudelft-colors.primary))
          place(dx: 2.23cm, dy: 1.82cm, text(size: default_title_font_size, utils.display-current-heading(level : 2), fill: tudelft-colors.primary, weight: "bold"))

          // Placing slide counter in the right spot
          let slide-counter = context utils.slide-counter.display()
          
          context {
            if utils.slide-counter.get().at(0) < 9 {
            place(dx: .3cm, dy: 3.3cm, rect( stroke: none,height: 1.1cm,
          text( slide-counter, fill: tudelft-colors.neutral-lightest, size: 22pt )))    
            }else{
              place(dx: 0.05cm, dy: 3.3cm, rect( stroke: none,height: 1.1cm,
              text( slide-counter, fill: tudelft-colors.neutral-lightest, size: 22pt )))
            }
          }

          // Content block:
          context {
            let block_width = 29.78cm
            let block_height = 8.1cm
            let default_size = default_font_size
            let minimum_size = 16pt

            // Function to find the optimal font size
            let adjusted_size = {
              let size = default_size
              while measure(box(width: block_width, text(..args, size: size))).height > block_height {
                size = size * 0.9 // Reduce size iteratively
                if size < minimum_size { // Ensure readability
                  break 
                } 
              }
              size
            }

            place(dx: 2.23cm, dy: 4.38cm,
            block(
                width:  block_width, 
                height: block_height,
                text(..args, size: adjusted_size)
              )
            )
          }
          
          place(dx: 2.23cm,dy : 13.89cm, text(size: default_font_size, "Next lecture:"))
          place(dx: 2.25cm, dy: 14.93cm, common_icons.looking_glass)
          place(dx: 4.65cm, dy: 15.24cm, text(size:default_font_size,topic))
          place(dx: 2.25cm, dy: 16.95cm, common_icons.book_reference)
          place(dx: 4.65cm, dy: 17.55cm, text(size:default_font_size,section_string))

  })
})

#let practice_slide(title: auto, ..args) = touying-slide-wrapper(self => {
  if title != auto {
    self.store.title = title
  }
  
  self = utils.merge-dicts(
    self,
    config-page(
      margin: (left: 0pt, top: 0pt),
    ),
  )
  touying-slide(self: self, {
          place(dx: 0cm, dy: 0cm, rect(width: 1.44cm, height: 4.37cm, fill: tudelft-colors.primary))
          place(dx: 2.23cm, dy: 1.82cm, text(size: default_title_font_size, utils.display-current-heading(level : 2), fill: tudelft-colors.primary, weight: "bold"))
          
          place(dx: .2cm, dy: 3.3cm, rect( stroke: none,height: 1.1cm,
          text( context utils.slide-counter.display(), fill: tudelft-colors.neutral-lightest, size: 22pt )))

          place( dx : 2.26cm, dy : 4.34cm,
            grid(
              rows: 5, 
              columns: 1, 
              align: center,
              gutter: 5pt,
              block(
                common_icons.looking_glass
              ),
              block(
                common_icons.arrow_down
              ),
              block(
                common_icons.puzzle_piece
              ),
              block(
                common_icons.arrow_down
              ),
              block(
                common_icons.target
              )
            )
          )
          place(dx: 4.35cm, dy: 4.36cm, block(width: 29.32cm, height: 20.5cm, align(top + left, text(font: heading-fonts, size: default_font_size, fill: black,..args))))

  })
})

#let slide(title: auto, slide-type: "blank", subtype : none, text-size : default_font_size, title-size: default_title_font_size,..args) = touying-slide-wrapper(self => {
  if title != auto {
    self.store.title = title
  }
  
  self = utils.merge-dicts(
    self,
    config-page(
      margin: (left: 0pt, top: 0pt),
    ),
  )
  touying-slide(self: self, {

          let title_color = MOOCblue
          let color_bar = title_color
          
          if slide-type == "estimation" {
            title_color = MOOCorange
            color_bar = title_color
            place(dx: 31.35cm, dy: 0.9cm, probstats_icons.regression_orange)
          }else{
            if slide-type == "probability" {
              title_color = MOOCgreen
              color_bar = title_color
              place(dx: 31.35cm, dy: 0.9cm, probstats_icons.dice_green)
            }else{
              if slide-type == "models" {
                title_color = MOOCyellow
                color_bar = MOOCyellowBar
                place(dx: 31.35cm, dy: 0.9cm, probstats_icons.bar_graphics_yellow)
              }
            }
          }

          if subtype == "reasoning" {
            place(dx: 31.88cm, dy: 16.94cm,probstats_icons.collaboration_slide_item)
          }
          if subtype == "polling" {
             place(dx: 31.88cm, dy: 16.94cm, probstats_icons.idea_slide_icon)
          }
          if subtype == "discussion" {
             place(dx: 31.88cm, dy: 16.94cm, probstats_icons.discussion_slide_item)
          }

          if slide-type == "definition" {
            place(dx: 31.88cm, dy: 16.94cm, common_icons.looking_glass)
          }
          if slide-type == "example" {
            place(dx: 31.88cm, dy: 16.94cm, common_icons.arrows_pointing_out)
          }
          
          if slide-type == "questions"{
            place(dx: 31.88cm, dy: 16.94cm, common_icons.question_mark)
          }

          if slide-type == "polling"{
            place(dx: 31.57cm, dy: 1.21cm, common_icons.list)
            place(dx: 31.81cm, dy: 16.94cm, common_icons.puzzle_piece)
          }

          if slide-type == "exercise"{
            place(dx: 31.81cm, dy: 16.94cm, common_icons.puzzle_piece)
          }

          if slide-type == "academic reasoning" {
            place(dx: 0.31cm, dy: 16.31cm, common_icons.academic_reasoning)
            place(dx: 31.81cm, dy: 16.94cm, common_icons.puzzle_piece)
          }
          
          place(dx: 0cm, dy: 0cm, rect(width: 1.44cm, height: 4.37cm, fill: color_bar))
          place(dx: 2.23cm, dy: 1.82cm, text(size: title-size, utils.display-current-heading(level : 2), fill: title_color, weight: "bold"))

          // Placing slide counter in the right spot
          let slide-counter = context utils.slide-counter.display()
          
          context {
            if utils.slide-counter.get().at(0) <= 9 {
            place(dx: .3cm, dy: 3.3cm, rect( stroke: none,height: 1.1cm,
          text( slide-counter, fill: tudelft-colors.neutral-lightest, size: 22pt )))    
            }else{
              place(dx: 0.05cm, dy: 3.3cm, rect( stroke: none,height: 1.1cm,
              text( slide-counter, fill: tudelft-colors.neutral-lightest, size: 22pt )))
            }
          }

          place(dx: 2.23cm, dy: 4.38cm, block(width: 29.79cm, height: 20.5cm, align(top + left, text(font: heading-fonts, size: text-size, fill: black, ..args))))


  })
})

#let prime-slides(
  title: "Títol de la diapositiva",
  subtitle: "Subtítol de la diapositiva",
  background: "background_title.png",
  logo : "logo.png",
  title-visual: none,
  ..args,
  body
) = {
  show: touying-slides.with(
    config-page(
      paper: "presentation-16-9",
      width: 33.87cm,
      height: 19.05cm,
      margin: (x: 2.0cm, y: 1.71cm)
    ),
    config-common(
      slide-level: 2,
      new-section-slide-fn: new-section-slide,
      slide-fn: slide
    ),
    config-info(
      title: title,
      title-visual: title-visual,
      subtitle: subtitle,
      background : background,
      logo : logo
    ),
    config-colors(
      ..tudelft-colors
    ),
    config-methods(
      init: (self: none, body) => {
        set text(font: normal-fonts, size: 16pt, weight: "regular")

        show heading: set text(font: heading-fonts)
        show heading.where(level: 2): it => {
            colbreak()
          text(size: 30pt, it)
          v(.5em)
        }

        set list(marker: (sym.circle.filled.tiny, sym.plus))

        body
      }
    ),
    ..args
  )

  title-slide(background : background, logo: logo)

  body
}

#let focus-slide(body) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-page(
      fill: self.colors.primary,
      margin: 0cm,
    ),
  )
  set text(fill: self.colors.neutral-lightest, size: 42pt)
  touying-slide(self: self, align(horizon + center, body))
})

#let break-slide(body) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-page(
      fill: self.colors.primary,
      margin: 0cm,
    ),
  )
  set text(fill: self.colors.neutral-lightest, size: 42pt)
  touying-slide(self: self, {
    
    align(center, body)
    place(dx : 13.68cm, dy : 3.78cm, image("../assets/Common/Common Icons/tea_cup.svg", height: 6.47cm, width: 7.28cm))
    place(dx : 6.24cm ,dy : 10.75cm ,text(size: 46pt, weight: "bold","The break lasts until:"))
  })
})

