#let light-gray = luma(100)
#let ultralight-gray = luma(240)
#let mainfont = "Source Sans Pro"
// #let mainfont = "Linux Biolinum Keyboard"


#let entries(..args) = {
  grid(
    stroke: (bottom: (paint: ultralight-gray, dash: "dotted")),
    inset: (left: 0pt, rest: 4pt),
    ..args.pos().map(((label, value)) => [#smallcaps(lower(label)) #value]),
    ..args.named()
  )
}

#let meeting-header(name: none, date: none, time: none, location: none, invited: none) = grid(
  columns:(auto, 1fr, auto),
  [#text(size:14pt, weight: "bold")[Agenda: #name] 
  #entries(
  (text(fill: light-gray)[Invited:], invited),
)],[],entries(
  (text(fill: light-gray)[Date:], date),
  (text(fill: light-gray)[Time:], time),
  (text(fill: light-gray)[Location:], location),
))

#let meeting-topic(topic, time: none, purpose: none, lead: none) = entries(
  (none, strong(topic)),
  (text(fill: light-gray)[Time:], time),
  (text(fill: light-gray)[Lead:], lead),
  (text(fill: light-gray)[Purpose:], purpose),
  stroke: (_, y) => if y == 0 { (bottom: (paint: ultralight-gray, dash: "dotted")) } else { (bottom: (paint: ultralight-gray, dash: "dotted")) }
)


#let agenda-row(index, topic: none, time: none, purpose: none, lead: none, preparation: none, process: none) = {
  (
    text(fill: light-gray)[*#index* |],
    [
      #pad(left: -10pt, top: -0.4em, meeting-topic(topic, time: time, purpose: purpose, lead: lead))
    ],
    preparation,
    process
  )
}

#let agenda-table(data) = {
 
 let data-rows = data.pairs().map((item) => {
 let contents = item.at(1)
  (
      topic: [#eval(contents.Topic, mode: "markup")],
      time: [#eval(contents.Time, mode: "markup")],
      purpose: [#eval(contents.Purpose, mode: "markup")],
      lead: [#eval(contents.Lead, mode: "markup")],
      preparation: [
        #eval(contents.Preparation, mode: "markup")
      ],
      process: [
        #eval(contents.Process, mode: "markup")
      ]
    )
  })
  
  table(
    columns: (auto,auto,auto, 1fr) ,
    align: (right,left, left, left),
    stroke: (top: none, bottom: black + 0.6pt, right: (paint: gray, dash: "dotted", thickness: 0.4pt)),
    inset: (x, _) => if x == 0 { (left: -25pt, rest: 10pt) } else { 10pt },

    table.vline(stroke: none),
    table.header(
      [],
      pad(left:-10pt)[*Topic*],
      [*Preparation*],
      [*Proposed process*]
    ),
    table.vline(stroke: none),

    ..data-rows.enumerate().map(((index, row)) => agenda-row(index + 1, ..row)).join(),
    table.hline(stroke: none),

  )
}




#let agenda(name: none, 
date: none, 
time: none, 
location: none, 
invited: none,
  doc,
) = {
  
set text(font: mainfont, size: 10pt, weight: "regular")

set page("a4",
  margin:(top: 2cm,
  bottom: 2cm,
  left: 2.5cm, right: 2cm), flipped: true)
  
set page(footer: context [
  #set text(size: 8pt)
  #line(length: 100%,stroke: 0.2pt + gray)
  #name meeting — #date
  #h(1fr)
  #counter(page).display(
    "1/1",
    both: true,
  )
])

meeting-header(name: name, date: date, time: time, location: location, invited: invited)


set text(font: mainfont, size: 10pt, weight: "regular")

doc

}
