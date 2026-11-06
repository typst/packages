#import "clues.typ": clue, get-title-for, if-auto-then, increment_task_counter, get_task_number
#import quote as typst_quote  // needed for quote

// Predefined gentle clues
/* info */
#let info(title: auto, icon: "assets/info.svg", ..args) = clue(
  accent-color: rgb(29, 144, 208), // blue
  title: if-auto-then(title, get-title-for("info")), 
  icon: icon, 
  ..args
)

/* success */
#let success(title: auto, icon: "assets/checkbox.svg", ..args) = clue(
  accent-color: rgb(102, 174, 62), // green
  title: if-auto-then(title, get-title-for("success")), 
  icon: icon, 
  ..args
)

/* warning */
#let warning(title: auto, icon: "assets/warning.svg", ..args) = clue(
  accent-color: rgb(255, 145, 0), // orange 
  title: if-auto-then(title, get-title-for("warning")), 
  icon: icon, 
  ..args
)

/* error */
#let error(title: auto, icon: "assets/crossmark.svg", ..args) = clue(
  accent-color: rgb(237, 32, 84),  // red 
  title: if-auto-then(title, get-title-for("error")),
  icon: icon, 
  ..args
)

/* task */
#let task(title: auto, icon: "assets/task.svg", ..args) = {
  increment_task_counter()
  clue(
    accent-color: maroon,
    title: if-auto-then(title, get-title-for("task") + get_task_number()), 
    icon: icon, 
    ..args
  )
}

/* tip */
#let tip(title: auto, icon: "assets/tip.svg", ..args) = clue(
  accent-color: rgb(0, 191, 165),  // teal 
  title: if-auto-then(title, get-title-for("tip")),
  icon: icon, 
  ..args
)

/* abstract */
#let abstract(title: auto, icon: "assets/abstract.svg", ..args) = clue(
  accent-color: olive,
  title: if-auto-then(title, get-title-for("abstract")), 
  icon: icon, 
  ..args
)

/* conclusion */
#let conclusion(title: auto, icon: "assets/lightbulb.svg", ..args) = clue(
  accent-color: rgb(255, 201, 23), // yellow
  title: if-auto-then(title, get-title-for("conclusion")), 
  icon: icon, 
  ..args
)

/* memorize */
#let memo(title: auto, icon: "assets/excl.svg", ..args) = clue(
  accent-color: rgb(255, 82, 82), // kind of red 
  title: if-auto-then(title, get-title-for("memo")), 
  icon: icon, 
  ..args
)

/* question */
#let question(title: auto, icon: "assets/questionmark.svg", ..args) = clue(
  accent-color: rgb("#7ba10a"), // greenish
  title: if-auto-then(title, get-title-for("question")), 
  icon: icon, 
  ..args
)


/* quote */
#let quote(title: auto, icon: "assets/quote.svg", attribution: none, content, ..args) = clue(
  accent-color: eastern, 
  title: if-auto-then(title, get-title-for("quote")), 
  icon: icon, 
  ..args
)[
  #typst_quote(block: true, attribution: attribution)[#content]
]

/* example */
#let example(title: auto, icon: "assets/example.svg", ..args) = clue(
  accent-color: orange, 
  title: if-auto-then(title, get-title-for("example")),
  icon: icon, 
  ..args
)


/* aim */
#let goal(title: auto, icon: "assets/flag.svg", ..args) = clue(
  accent-color: red,
  title: if-auto-then(title, get-title-for("goal")),
  icon: icon,
  ..args
)