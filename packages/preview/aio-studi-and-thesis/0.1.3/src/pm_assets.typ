#import "utils.typ": *

// Persona
#let persona(
  primary-color: dark-blue,
  text-color: dark-grey,
  background-color: light-blue,
  title: txt-todo,
  img: image("images/persona.png", width: 6.5em),
  name: txt-todo,
  age: txt-todo,
  family: txt-todo,
  job: txt-todo,
  do-and-say: txt-todo,
  wishes: txt-todo,
  see-and-hear: txt-todo,
  challenges: txt-todo,
  typical-day: txt-todo,
  goals: txt-todo 
) = {
  import "dictionary.typ": txt-persona-name, txt-persona-age, txt-persona-family, txt-persona-job, txt-persona-do-and-say, txt-persona-wishes, txt-persona-see-and-hear, txt-persona-challenges, txt-persona-typical-day, txt-persona-goals
  
  rect(inset: 0.9em)[
    #set par(justify: false)
    
    #show table.cell.where(x: 0): set text(fill: primary-color, weight: "bold", size: 0.9em)
    #show table.cell.where(x: 1): set text(fill: text-color, weight: "regular", size: 1em)
    #set table(fill: (_, y) => if calc.odd(y) { background-color } else { none })
    
    #text("Persona: ", size: 1.4em, weight: "bold")#text(title, size: 1.4em, weight: "bold", fill: primary-color)
    
    #grid(
      columns: (0.7fr, 0.3fr, 0.3fr),
      [
        #table(
          columns: (auto, 1fr),
          align: (left, left),
          stroke: text-color,
      
          [#txt-persona-name], [#name],
          [#txt-persona-age], [#age],
          [#txt-persona-family], [#family],
          [#txt-persona-job], [#job]
        )
      ],
      [],
      img
    )
    
    #table(
      columns: (0.3fr, 0.7fr),
      align: (left, left),
      stroke: text-color,
      
      [#txt-persona-do-and-say], [#do-and-say],
      [#txt-persona-wishes], [#wishes],
      [#txt-persona-see-and-hear], [#see-and-hear],
      [#txt-persona-challenges], [#challenges],
      [#txt-persona-typical-day], [#typical-day],
      [#txt-persona-goals], [#goals]
    )
  ]
}

// Retro
#let retro(
  primary-color: dark-blue,
  secondary-color: blue,
  text-color: dark-grey,
  background-color: light-blue,
  heading-starts-with: 2,
  day: txt-todo,
  sprint: none,
  info: none,
  img: image("images/starfish.png", height: 100pt),
  more: none,
  keep: none,
  start: none,
  stop: none,
  less: none,
  improvements: none,
  impediments: none,
  measures: none
) = {
  import "dictionary.typ": txt-retro, txt-retro-improvements, txt-retro-impediments, txt-retro-measures
  
  set par(justify: false)

  let validate-if-na(body) = {
    return if is-not-none-or-empty(body) { body } else [#text(fill: secondary-color)[_NA_]]
  }
  
  grid(
    columns: (70%, auto),
    align: (left, right),
    gutter: 0.9em,
    [
      #heading(level: heading-starts-with)[
        #txt-retro #if is-not-none-or-empty(sprint) { "Sprint " + sprint } #if is-not-none-or-empty(day) { "(" + day + ")" }
      ]
      #if is-not-none-or-empty(info) { info }
    ],
    img
  )

  set table(fill: (x, y) => if x == 0 { background-color } else { none })
  show table.cell.where(x: 0): set text(fill: primary-color, weight: "bold", size: 0.9em)
  show table.cell.where(x: 1): set text(fill: text-color, weight: "regular", size: 1em)
  show table.cell.where(x: 1): set par(justify: false)

  table(
    columns: (auto, 10fr),
    align: (center, horizon),

    stroke: text-color,

    table.cell(rowspan: 1, align: horizon, rotate(-90deg, reflow: true)[more of]),
    [#validate-if-na(more)],

    table.cell(rowspan: 1, align: horizon, rotate(-90deg, reflow: true)[keep doing]),
    [#validate-if-na(keep)],

    table.cell(rowspan: 1, align: horizon, rotate(-90deg, reflow: true)[start doing]),
    [#validate-if-na(start)],

    table.cell(rowspan: 1, align: horizon, rotate(-90deg, reflow: true)[stop doing]),
    [#validate-if-na(stop)],

    table.cell(rowspan: 1, align: horizon, rotate(-90deg, reflow: true)[less of]),
    [#validate-if-na(less)],
  )

  if is-not-none-or-empty(improvements) [
    #heading(level: heading-starts-with + 1)[#txt-retro-improvements]
    #improvements
  ]

  if is-not-none-or-empty(impediments) [
    #heading(level: heading-starts-with + 1)[#txt-retro-impediments]
    #impediments
  ]

  if is-not-none-or-empty(measures) [
    #heading(level: heading-starts-with + 1)[#txt-retro-measures]
    #measures
  ]
}

// SMART
#let smart(
  primary-color: dark-blue,
  text-color: dark-grey,
  background-color: light-blue,
  justify: false,
  s: txt-todo,
  m: txt-todo,
  a: txt-todo,
  r: txt-todo,
  t: txt-todo
) = {
  set table(fill: (x, y) => if x == 0 { background-color } else { none })
  show table.cell.where(x: 0): set text(fill: primary-color, weight: "bold", size: 0.9em)
  show table.cell.where(x: 1): set text(fill: text-color, weight: "regular", size: 1em)
  show table.cell.where(x: 1): set par(justify: justify) 
  
  table(
    columns: (auto, 1fr),
    align: (center, left),
    stroke: text-color,
    
    [S], [#s],
    [M], [#m],
    [A], [#a],
    [R], [#r],
    [T], [#t]
  )
}

// User Story
#let user-story(
  primary-color: dark-blue,
  text-color: dark-grey,
  background-color: light-blue,
  id: txt-todo,
  title: txt-todo,
  sprint: txt-todo,
  status: txt-todo,
  description: txt-todo,
  url: "",
  url-without-id: "",
  acceptance-criteria: none,
  s: none,
  m: none,
  a: none,
  r: none,
  t: none,
  body
) = {
  import "assets.typ": button
  import "dictionary.typ": txt-user-story-title, txt-user-story-acceptance-criteria
  
  rect(inset: 0.9em)[
    #set table(fill: (x, y) => if y == 0 { background-color } else { none })
    #show table.cell.where(y: 0): set text(fill: primary-color, weight: "bold", size: 0.9em)
    #show table.cell.where(y: 1): set text(fill: text-color, weight: "regular", size: 1em)

    #table(
      columns: (0.15fr, 1fr, 0.15fr, auto),
      align: (left, left, left, left),
      stroke: text-color,

      table.header([ID], [#txt-user-story-title], [Sprint], [Status]),
      [
        #if is-not-none-or-empty(id) and is-not-none-or-empty(url-without-id) {
          link(url-without-id + id)[#id]
        } else {
          if is-not-none-or-empty(id) { id }
        }
      ],
      [ #if is-not-none-or-empty(title) { title } ],
      [ #if is-not-none-or-empty(sprint) { sprint } ],
      [ #if is-not-none-or-empty(status) { status } ]
    )
    
    #text("User Story:", size: 1.1em, weight: "bold", fill: primary-color)
    
    #if is-not-none-or-empty(description) { description }
    
    #if is-not-none-or-empty(url) { button(url: url)[#url] }
    
    #if is-not-none-or-empty(acceptance-criteria) or is-not-none-or-empty(s) or is-not-none-or-empty(m) or is-not-none-or-empty(a) or is-not-none-or-empty(r) or is-not-none-or-empty(t) {
      text(txt-user-story-acceptance-criteria + ":", size: 1.1em, weight: "bold", fill: primary-color)
      linebreak()
       
      if is-not-none-or-empty(acceptance-criteria) { acceptance-criteria }
      
      if is-not-none-or-empty(s) or is-not-none-or-empty(m) or is-not-none-or-empty(a) or is-not-none-or-empty(r) or is-not-none-or-empty(t) {
        smart(s: s, m: m, a: a, r: r, t: t)
      }
    }
    
    #body
  ]
}