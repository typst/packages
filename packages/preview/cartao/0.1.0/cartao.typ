// vim:ts=2:wrap:linebreak:tw=80:nonumber:norelativenumber:expandtab
#let cardnumber   = counter("cardnumber")
#let cardheader   = state("header",   "init")
#let cardfooter   = state("footer",   "init")
#let cardquestion = state("question", "init")
#let cardanswer   = state("answer",   "init")

#let card(header, footer, question, answer) = [
  #cardnumber.step()
  #cardheader.update(header)
  #cardfooter.update(footer)
  #cardquestion.update(question)
  #cardanswer.update(answer)
  <card>
]

#let letter8up = {
  let cardwidth  =  8.5in / 2
  let cardheight = 11.0in / 4
  let normal = 11pt
  let small  = normal * 0.75
  let tiny   = normal * 0.35
  let large  = normal * 1.25
  let huge   = normal * 1.65
  let accent = luma(200)
  locate(loc => {
    let elements    = query(<card>, loc)
    let questions   = ()
    let oddanswers  = ()
    let evenanswers = ()
    let answers     = ()
    for loc in elements {
      // get the value of the #card at each <card>
      let header   = cardheader.at( loc.location() )
      let footer   = cardfooter.at( loc.location() )
      let question = cardquestion.at( loc.location() )
      let answer   = cardanswer.at( loc.location() )
      let card     = cardnumber.at( loc.location() ).first()
      let cardlast = cardnumber.final( loc.location() ).first()

      // Make the questions and answers arrays
      questions.push(
        box( width: cardwidth, height: cardheight,
          {
            place(top + center, dy: 0.5cm, float: true,
              box(width: cardwidth - 1cm)[
                #text(size: normal)[
                  #smallcaps[#header] #h(0.5fr) #card/#cardlast
                ]
              ]
            )
            place(top + center, dy: 1.5cm,
              box(inset: (x: 1cm, y: 0.5cm), [
                #text(size: large, weight: "bold")[ #question ]
              ])
            )
            place(
              bottom + right, dx: -0.5cm, dy: -0.5cm, float: true,
              text(size: normal, style: "italic")[#footer],
            )
          }
        )
      )

      if calc.odd(card) {
        oddanswers.push(
          box(
            width: cardwidth, height: cardheight,
            {
              place(
                top + right, dx: -0.5cm, dy: 0.5cm, float: true,
                [
                  #set align(right)
                  #text(size: normal)[#card/#cardlast]
                ]
              )
              place(horizon + center,
                box(inset: (x: 1cm, y: 0.5cm), [
                  #set align(left)
                  #text(size: large)[#answer]
                ])
              )
            }
          )
        )
      } else {
        evenanswers.push(
          box(
            width: cardwidth, height: cardheight,
            {
              place(
                top + right, dx: -0.5cm, dy: 0.5cm, float: true,
                [
                  #set align(right)
                  #text(size: normal)[#card/#cardlast]
                ]
              )
              place(horizon + center,
                box(inset: (x: 1cm, y: 0.5cm), [
                  #set align(left)
                  #text(size: large)[#answer]
                ])
              )
            }
          )
        )
      }
    }
    if oddanswers.len() > evenanswers.len() {
      evenanswers.push( [] )
      questions.push( [] )
    }
    answers = evenanswers.zip(oddanswers).flatten()

    // split each array per whole page
    let questionspp = ()
    let answerspp   = ()
    let questionstmp = ()
    let answerstmp   = ()
    let count = 0
    let pages = calc.floor(questions.len() / 8)

    for page in range(pages) {
      for i in range(8) {
        questionstmp.push(questions.at(i + page*8))
        answerstmp.push(answers.at(i + page*8))
      }
      questionspp.push(questionstmp)
      answerspp.push(answerstmp)
      questionstmp = ()
      answerstmp   = ()
    }

    // attach non-whole pages
    if (pages*8) < questions.len() {
      for i in range(questions.len() - pages*8) {
        questionstmp.push(questions.at(pages*8 + i))
        answerstmp.push(answers.at(pages*8 + i))
      }
      questionspp.push(questionstmp)
      answerspp.push(answerstmp)
      questionstmp = ()
      answerstmp   = ()
    }

    // draw the cards in a table
    for page in range(questionspp.len()) {
      table(
        columns: (cardwidth, cardwidth), rows: cardheight,
        inset: 0pt,
        stroke: (
          thickness: 0.5pt, dash: "dashed", cap: "round",
          paint: accent.darken(30%).lighten(50%),
        ),
        ..questionspp.at(page)
      )
      pagebreak()
      table(
        columns: (cardwidth, cardwidth), rows: cardheight,
        inset: 0pt,
        stroke: (
          thickness: 0.5pt, dash: "dashed", cap: "round",
          paint: accent.darken(30%).lighten(50%),
        ),
        ..answerspp.at(page)
      )
    }

  })
}


#let a48up = {
  let cardwidth  = 210mm / 2
  let cardheight = 297mm / 4
  let normal = 11pt
  let small  = normal * 0.75
  let tiny   = normal * 0.35
  let large  = normal * 1.25
  let huge   = normal * 1.65
  let accent = luma(200)
  locate(loc => {
    let elements    = query(<card>, loc)
    let questions   = ()
    let oddanswers  = ()
    let evenanswers = ()
    let answers     = ()
    for loc in elements {
      // get the value of the #card at each <card>
      let header   = cardheader.at( loc.location() )
      let footer   = cardfooter.at( loc.location() )
      let question = cardquestion.at( loc.location() )
      let answer   = cardanswer.at( loc.location() )
      let card     = cardnumber.at( loc.location() ).first()
      let cardlast = cardnumber.final( loc.location() ).first()

      // Make the questions and answers arrays
      questions.push(
        box( width: cardwidth, height: cardheight,
          {
            place(top + center, dy: 0.5cm, float: true,
              box(width: cardwidth - 1cm)[
                #text(size: normal)[
                  #smallcaps[#header] #h(0.5fr) #card/#cardlast
                ]
              ]
            )
            place(top + center, dy: 1.5cm,
              box(inset: (x: 1cm, y: 0.5cm), [
                #text(size: large, weight: "bold")[ #question ]
              ])
            )
            place(
              bottom + right, dx: -0.5cm, dy: -0.5cm, float: true,
              text(size: normal, style: "italic")[#footer],
            )
          }
        )
      )

      if calc.odd(card) {
        oddanswers.push(
          box(
            width: cardwidth, height: cardheight,
            {
              place(
                top + right, dx: -0.5cm, dy: 0.5cm, float: true,
                [
                  #set align(right)
                  #text(size: normal)[#card/#cardlast]
                ]
              )
              place(horizon + center,
                box(inset: (x: 1cm, y: 0.5cm), [
                  #set align(left)
                  #text(size: large)[#answer]
                ])
              )
            }
          )
        )
      } else {
        evenanswers.push(
          box(
            width: cardwidth, height: cardheight,
            {
              place(
                top + right, dx: -0.5cm, dy: 0.5cm, float: true,
                [
                  #set align(right)
                  #text(size: normal)[#card/#cardlast]
                ]
              )
              place(horizon + center,
                box(inset: (x: 1cm, y: 0.5cm), [
                  #set align(left)
                  #text(size: large)[#answer]
                ])
              )
            }
          )
        )
      }
    }
    if oddanswers.len() > evenanswers.len() {
      evenanswers.push( [] )
      questions.push( [] )
    }
    answers = evenanswers.zip(oddanswers).flatten()

    // split each array per whole page
    let questionspp = ()
    let answerspp   = ()
    let questionstmp = ()
    let answerstmp   = ()
    let count = 0
    let pages = calc.floor(questions.len() / 8)

    for page in range(pages) {
      for i in range(8) {
        questionstmp.push(questions.at(i + page*8))
        answerstmp.push(answers.at(i + page*8))
      }
      questionspp.push(questionstmp)
      answerspp.push(answerstmp)
      questionstmp = ()
      answerstmp   = ()
    }

    // attach non-whole pages
    if (pages*8) < questions.len() {
      for i in range(questions.len() - pages*8) {
        questionstmp.push(questions.at(pages*8 + i))
        answerstmp.push(answers.at(pages*8 + i))
      }
      questionspp.push(questionstmp)
      answerspp.push(answerstmp)
      questionstmp = ()
      answerstmp   = ()
    }

    // draw the cards in a table
    for page in range(questionspp.len()) {
      table(
        columns: (cardwidth, cardwidth), rows: cardheight,
        inset: 0pt,
        stroke: (
          thickness: 0.5pt, dash: "dashed", cap: "round",
          paint: accent.darken(30%).lighten(50%),
        ),
        ..questionspp.at(page)
      )
      pagebreak()
      table(
        columns: (cardwidth, cardwidth), rows: cardheight,
        inset: 0pt,
        stroke: (
          thickness: 0.5pt, dash: "dashed", cap: "round",
          paint: accent.darken(30%).lighten(50%),
        ),
        ..answerspp.at(page)
      )
    }

  })
}


#let present = {
  let cardwidth  = 297mm
  let cardheight = 167.0625mm
  // 297.0, 167.0625, "presentation-16-9")
  // 280.0, 210.0, "presentation-4-3"
  let normal = 20pt
  let small  = normal * 0.75
  let tiny   = normal * 0.35
  let large  = normal * 1.25
  let huge   = normal * 1.65
  let accent = luma(200)
  locate(loc => {
    let elements    = query(<card>, loc)
    let questions   = ()
    let oddanswers  = ()
    let evenanswers = ()
    let answers     = ()
    for loc in elements {
      // get the value of the #card at each <card>
      let header   = cardheader.at( loc.location() )
      let footer   = cardfooter.at( loc.location() )
      let question = cardquestion.at( loc.location() )
      let answer   = cardanswer.at( loc.location() )
      let card     = cardnumber.at( loc.location() ).first()
      let cardlast = cardnumber.final( loc.location() ).first()

      // Make the questions and answers arrays
      questions.push(
        box( width: cardwidth, height: cardheight,
          {
            place(top + center, dy: 0.5cm, float: true,
              box(width: cardwidth - 1cm)[
                #text(size: normal)[
                  #smallcaps[#header] #h(0.5fr) #card/#cardlast
                ]
              ]
            )
            place(horizon + center,
              box(inset: (x: 1cm, y: 0.5cm), [
                #text(size: large, weight: "bold")[ #question ]
              ])
            )
            place(
              bottom + right, dx: -0.5cm, dy: -0.5cm, float: true,
              text(size: normal, style: "italic")[#footer],
            )
          }
        )
      )

      answers.push(
        box(
          width: cardwidth, height: cardheight,
          {
            place(top + center, dy: 0.5cm, float: true,
              box(width: cardwidth - 1cm)[
                #text(size: normal)[
                  #smallcaps[#header] #h(0.5fr) #card/#cardlast
                ]
              ]
            )
            place(horizon + center,
              box(inset: (x: cardwidth*0.1, y: 0.5cm), [
                #set align(left)
                #text(size: large)[#answer]
              ])
            )
          }
        )
      )
    }

    for card in range(questions.len()) {
      table(
        inset: 0pt,
        stroke: none,
        columns: auto,
        questions.at(card),
        answers.at(card)
      )
    }

  })
}
