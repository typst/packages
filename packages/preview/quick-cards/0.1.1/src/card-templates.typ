#import "utils.typ": if-auto-then

#let database = state("quick-cards-database", (:))
#let cardnumber = counter("quick-cards-cardnumber")

#let set-category-database(data) = {
  assert.eq(type(data), dictionary, message: "expected data to be a dictionary, found " + str(type(data)))

  database.update(data);
}

#let reset-category-database() = {
  database.update((:))
}


#let get-category(category: "", default: auto)={
  context {
    let category-content = database.get().at(category, default:none)
    if category-content == none{
      if-auto-then(default, category-content)
    } else{
      category-content
    }
  }
}

#let flashcard-simple(
  question: [],
  answer: [],
  hint: [],
  category: "",
  numbering: "1/1",
  both: true,
)=(
    front:{
      cardnumber.step()
      place(get-category(category: category))
      place(right, context(cardnumber.display(numbering, both: both)))
      v(1fr)
      align(center, question)
      v(1fr, weak: true)
      if hint != [] and hint != none{
        v(1em)
        set text(size: 8pt, fill: gray)
        align(center, hint)
      }
    },
    back:{
      v(1fr)
      answer
      v(1fr)
    }
)

#let flashcard-modern(
  question: [],
  answer: [],
  hint: [],
  category: "",
  color-primary: aqua,
  color-secondary : luma(90%),
  rounding: 1em,
)=(
    front:{
      show text: set text(font: "Roboto")
      cardnumber.step()
      
      box(fill: color-secondary, height: 15%, width: 100%, radius: rounding, [
        #place(horizon, dx: 0.5em, box(inset: -15%, get-category(category: category, default: none)))
        #align(center + horizon, category)
      ])

      align(center + horizon)[
        #box(fill:color-primary, width: auto, height: auto, radius: rounding, outset: 1.5em, align(center + horizon, question))

        #if hint != [] and hint != none{
          set text(size: 0.5em)
          let hint-color = color-primary.lighten(70%)
          place(center, dy: 3em, box(fill:hint-color, width: auto, height: 2em, radius:(bottom:rounding), pad(x: 1em, y:0.5em, [Hint: #hint])))
        }
      ]
    },
    back:{
      show text: set text(font: "Roboto")
      box(fill: color-secondary, height: auto, width: 100%, radius: rounding, [
        #align(center + horizon, pad(y:0.75em,question))
      ])
      show text: set text(size: 1.5em)
      align(center + horizon,answer)
    }
)

#let flashcard-classic(
  question: [],
  answer: [],
  hint: [],
  category: "",
  numbering: "1/1",
  both: true,
  line-outset: 2em,
  line-count: 8,
  force-center: false,
)=(
    front:{
      let half = int(line-count / 2)-1
      layout(size =>{
        show par: set par(leading: (size.height - line-outset)/(line-count ) )
        pad(-line-outset,[
          #for value in range(0, line-count) {
            v(0.5fr)
            line(length: 100%, stroke: gray.opacify(-50%))
            v(0.5fr)
            if value == 0{
              place(center, heading( text(fill: gray, category)))
            }
            if value == half{
              place(center, question)
            }
            if value == line-count - 2{
              
              place(center, text(size: 0.75em, fill: gray, baseline: 0.6em, hint))
            }
          }
        ])
      })
    },
    back:{
      cardnumber.step()
      let half = int(line-count / 2) - 1
      place(
      layout(size =>{
        show par: set par(leading: (size.height - line-outset)/(line-count ) )
        pad(-line-outset,[
          #for value in range(0, line-count) {
            v(0.5fr)
            line(length: 100%, stroke: gray.opacify(-50%))
            v(0.5fr)
            if value == 0{
              place(center, text(fill: gray, question))
            }
            if value == half and not force-center{
              place(center,align(left, answer))
            }
            if value == line-count - 1{
              place(right, dx: -.9em, dy:-1.5em, box(fill: white, outset: 0.2em, context(text(cardnumber.display(numbering, both: both), fill: gray))))
            }
          }
        ])
      }))
      if force-center{
        align(center + horizon)[
          #v(1.5em)
          #box(fill: white.opacify(-50%), outset: 0.2em, answer)
        ]
      }
    }
)