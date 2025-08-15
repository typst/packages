#import "@preview/layout-ltd:0.1.0": layout-limiter

#let states = state("_states", (
  pauses: 1,
  steps: 1,
  subslides: 1,
  slides: 1,
))

#let pause(body) = {
  states.update(s => {
    s.pauses += 1
    s.steps = calc.max(s.pauses, s.steps)
    return s
  })
  context {
    let s = states.get()
    if s.pauses <= s.subslides { body } else { hide(body) }
  }
}

#let loc-before-slides = state("_loc-before-slides", none)

#let save-loc() = loc-before-slides.update(here())
#let rewind-counters() = {
  let c = counter(heading)
  c.update(c.at(loc-before-slides.get()))
}

#let subslide(i, body) = {
  states.update(s => {
    s.pauses = 1
    s.steps = 1
    s.subslides = i
    return s
  })

  {
    set heading(outlined: i == 1, bookmarked: i == 1)
    body
  }

  if i > 1 { counter(page).update(n => n - 1) }
  pagebreak(weak: true)
}

#let slide(body) = {
  states.update(s => {
    s.slides += 1
    s
  })
  context save-loc()

  subslide(1, body)

  context {
    let s = states.get()
    for i in range(2, s.steps + 1) {
      rewind-counters()
      subslide(i, body)
    }
  }
}

// #import "../src/export.typ": *


#set page(paper: "presentation-16-9", numbering: "1")
#set text(size: 20pt)
#set heading(numbering: "1.1")
#show: layout-limiter.with(max-iterations: 4)

#slide[
  = First Topic
]

#for (i, v) in ([First], [Second], [Third], [Fourth], [Fifth]).enumerate() {
  slide[
    == #v
    Hello #i
    #for i in range(6) [
      #show: pause
      Hello
    ]
  ]
}

#let section-slide(body) = {
      let save-headings = state("_headings")
      context save-headings.update(query(selector.or(heading.where(level: 1, outlined: true), heading.where(level: 2, outlined: true))))
  slide[
    #{
      let found-headings() = {
        let hs = query(heading.where(outlined: true).before(here()))
        hs != () and hs.last().level == 2
      }
      // we do this to avoid more iterations
      // counter(heading).update((..n) => {
      //   n = n.pos()
      //   if n.len() >= 2 and n.all(i => i > 0) {
      //     n.at(1) -= 1
      //   }
      //   n
      // })

      // show heading: it => {
      //   if it.body.func() == { context {} }.func() {
      //     if found-headings() { it } else { none }
      //   } else {
      //     it
      //   }
      // }
      // heading(outlined: false, bookmarked: false, level: 2, context {
      //   let headings = query(heading.where(outlined: true).before(here()))
      //   if headings != () {
      //     let h = headings.last()
      //     if h.level == 2 {
      //       h.body //heading(level: 2, outlined: false, bookmarked: false, h.body)
      //     } else {
      //       []
      //       //heading(level: 2, [])
      //     }
      //   }
      // })


      context {
        let hs = save-headings.get() 
        if hs != () and hs.last().level == 2 {
          hs.last()
        }
      }
    }

    #body

  ]
}

#slide[
  = Second Topic
]

#for (i, v) in ([First], [Second], [Third], [Fourth], [Fifth]).enumerate() {
  slide[
    == #v
    Hello #i
    #for i in range(6) [
      #show: pause
      Hello
    ]
  ]
}

#section-slide[
  #show: pause
  #show: pause
  #show: pause
  #show: pause
  #show: pause
  #show: pause
  Hg
]

#for (i, v) in ([First], [Second], [Third], [Fourth], [Fifth]).enumerate() {
  slide[
    == #v
    Hello #i
    #for i in range(6) [
      #show: pause
      Hello
    ]
  ]
}

#slide[
  = Third Topic
]

#section-slide[
  #show: pause
  #show: pause
  #show: pause
  #show: pause
]

// #for (i, v) in ([First], [Second], [Third], [Fourth], [Fifth]).enumerate() {
//   section-slide[#show: pause; GH]
//   slide[
//     == #v
//     Hello #i
//     #for i in range(6) [
//       #show: pause
//       Hello
//     ]
//   ]
// }


#section-slide[
  #show: pause
  #show: pause
  #show: pause
  #show: pause
  #show: pause
  #show: pause
  Hg
]

// #slide[
//   = Fourth Topic
// ]

// #for (i, v) in ([First], [Second], [Third], [Fourth], [Fifth]).enumerate() {
//   slide[
//     == #v
//     Hello #i
//     #for i in range(6) [
//       #show: pause
//       Hello
//     ]
//   ]
// }

#section-slide[
  #show: pause
  #show: pause
  #show: pause
  #show: pause
]

#section-slide[
  #show: pause
  #show: pause
  #show: pause
  #show: pause
]

#for (i, v) in ([First], [Second], [Third], [Fourth], [Fifth]).enumerate() {
  section-slide[#show: pause; GH]
  slide[
    == #v
    Hello #i
    #for i in range(6) [
      #show: pause
      Hello
    ]
  ]
}
#section-slide[
  #show: pause
  #show: pause
  #show: pause
  #show: pause
  #show: pause
  #show: pause
  Hg
]
#section-slide[
  #show: pause
  #show: pause
  #show: pause
  #show: pause
  #show: pause
  #show: pause
  Hg
]
= Fourth Topic
#section-slide[
  #show: pause
  #show: pause
  #show: pause
  #show: pause
  #show: pause
  #show: pause
  Hg
]

= Fifth Topic
#section-slide[
  #show: pause
  #show: pause
  #show: pause
  #show: pause
  #show: pause
  #show: pause
  Hg
]
#section-slide[
  #show: pause
  #show: pause
  #show: pause
  #show: pause
  #show: pause
  #show: pause
  Hg
]
#section-slide[
  #show: pause
  #show: pause
  #show: pause
  #show: pause
  #show: pause
  #show: pause
  Hg
]

#section-slide[
  #show: pause
  #show: pause
  #show: pause
  #show: pause
  #show: pause
  #show: pause
  Hg
]
// #slide[
//   = Fifth Topic
// ]

// #for (i, v) in ([First], [Second], [Third], [Fourth], [Fifth]).enumerate() {
//   section-slide[]
//   slide[
//     == #v
//     Hello #i
//     #for i in range(6) [
//       #show: pause
//       Hello
//     ]
//   ]
// }
