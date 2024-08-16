#let my-outline-row( textSize:none,
                    textWeight: "regular",
                    insetSize: 0pt,
                    textColor: blue,
                    number: "0",
                    title: none,
                    heading_page: "0",
                    location: none) = {
  set text(size: textSize, fill: textColor, weight: textWeight)
  box(width: 1.1cm, inset: (y: insetSize), align(left, number))
  h(0.1cm)
  box(inset: (y: insetSize), width: 100% - 1.2cm, )[
    #link(location, title)
    #box(width: 1fr, repeat(text(weight: "regular")[. #h(4pt)])) 
    #link(location, heading_page)
  ]
}

#let my-outline(appendix_state, part_state, part_location,part_change,part_counter, mainColor, textSize1:none, textSize2:none, textSize3:none, textSize4:none) = {
  show outline.entry: it => {
    let appendix_state = appendix_state.at(it.element.location())
    let numberingFormat = if appendix_state != none {"A.1"} else {"1.1"}
    let counterInt = counter(heading).at(it.element.location())
    let number = none
    if counterInt.first() >0 {
      number = numbering(numberingFormat, ..counterInt)
    }
    let title = it.element.body
    let heading_page = it.page

    if it.level == 1 {
      let part_state = part_state.at(it.element.location())
      let part_location = part_location.at(it.element.location())
      let part_change = part_change.at(it.element.location())
      let part_counter = part_counter.at(it.element.location())
      if (part_change){
        v(0.7cm, weak: true)
        box(width: 1.1cm, fill: mainColor.lighten(80%), inset: 5pt, align(center, text(size: textSize1, weight: "bold", fill: mainColor.lighten(30%), numbering("I",part_counter.first()))))
        h(0.1cm)
        box(width: 100% - 1.2cm, fill: mainColor.lighten(60%), inset: 5pt, align(center, link(part_location,text(size: textSize1, weight: "bold", part_state))))
        v(0.45cm, weak: true)
      }
      else{
        v(0.5cm, weak: true)
      }
      if (counterInt.first() == 1 and appendix_state != none ){
        my-outline-row(insetSize: 2pt, textWeight: "bold", textSize: textSize2, textColor:mainColor, number: none, title: appendix_state, heading_page: heading_page, location: it.element.location())
        v(0.5cm, weak: true)
      }
      my-outline-row(insetSize: 2pt, textWeight: "bold", textSize: textSize2, textColor:mainColor, number: number, title: title, heading_page: heading_page, location: it.element.location())
    }
    else if it.level ==2 {
      my-outline-row(insetSize: 2pt, textWeight: "bold", textSize: textSize3, textColor:black, number: number, title: title, heading_page: heading_page, location: it.element.location())
    } else {
       my-outline-row(textWeight: "regular", textSize: textSize4, textColor:black, number: number, title: title, heading_page: heading_page, location: it.element.location())
    }
  }
  pagebreak(to: "odd")
  outline(depth: 3, indent: false)
}

#let my-outline-small(partTitle, appendix_state, part_state, part_location,part_change,part_counter, mainColor, textSize1:none, textSize2:none, textSize3:none, textSize4:none) = {
  show outline.entry: it => {
    let appendix_state = appendix_state.at(it.element.location())
    let numberingFormat = if appendix_state != none {"A.1"} else {"1.1"}
    let counterInt = counter(heading).at(it.element.location())
    let number = none
    if counterInt.first() >0 {
      number = numbering(numberingFormat, ..counterInt)
    }
    let title = it.element.body
    let heading_page = it.page
    let part_state = part_state.at(it.element.location())
    if (part_state == partTitle and counterInt.first() >0 and appendix_state==none){
      if it.level == 1 {
        v(0.5cm, weak: true)
        my-outline-row(insetSize: 1pt, textWeight: "bold", textSize: textSize2, textColor:mainColor, number: number, title: title, heading_page: heading_page, location: it.element.location())
      }
      else if it.level ==2 {
        my-outline-row(textWeight: "regular", textSize: textSize4, textColor:black, number: number, title: text(fill: black, title), heading_page: text(fill: black, heading_page), location: it.element.location())
      }
    }
    else{
      v(-0.65em, weak: true)
    }
  }
  box(width: 9.5cm, outline(depth: 2, indent: false, title: none))
}

#let my-outline-sec(listOfFigureTitle, target, textSize) = {
  show outline.entry.where(level: 1): it => {
    let heading_page = it.page
    [
      #set text(size: textSize)
      #box(width: 0.75cm, align(right, [#it.body.at("children").at(2) #h(0.2cm)]))
      #link(it.element.location(), it.body.at("children").at(4))
      #box(width: 1fr, repeat(text(weight: "regular")[. #h(4pt)])) 
      #link(it.element.location(),heading_page)
    ]
  }
  pagebreak(to: "odd")
  outline(
    title: listOfFigureTitle,
    target: target,
  )
}