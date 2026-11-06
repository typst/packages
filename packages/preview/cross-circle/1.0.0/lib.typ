#set page(width: auto, height: auto, margin: 5mm)

#let sanitize-input(string) = {
  return if string == "" {()} else {for c in string { if c in ("1","2","3","4","5","6","7","8","9") {(c)}}}
}

#let purge-duplicates(string) = {
  let result = ""

  for c in string {
    if c not in result {
      result += c
    }
  }
  return result
}

#let line-stroke(paint: none, thickness: 0.5em) = (stroke: (paint: paint, thickness: thickness, cap: "round"))

#let win-conditions = (
  // horizontal
  // - top
  (pattern: ("1","2","3"), coord: (width,height) => (start: (0pt,0pt), end: (width/1.5,0pt)), offset: (width,height) => (dy: -height/3)),
  // - middle
  (pattern: ("4","5","6"), coord: (width,height) => (start: (0pt,0pt), end: (width/1.5,0pt)), offset: (width,height) => (dy: 0pt)),
  // - bottom
  (pattern: ("7","8","9"), coord: (width,height) => (start: (0pt,0pt), end: (width/1.5,0pt)), offset: (width,height) => (dy: height/3)),
  
  // vertical
  // - left
  (pattern: ("1","4","7"), coord: (width,height) => (start: (0pt,0pt), end: (0pt,height/1.5)), offset: (width,height) => (dx: -width/3)),
  // - center
  (pattern: ("2","5","8"), coord: (width,height) => (start: (0pt,0pt), end: (0pt,height/1.5)), offset: (width,height) => (dx: 0pt)),
  // - right
  (pattern: ("3","6","9"), coord: (width,height) => (start: (0pt,0pt), end: (0pt,height/1.5)), offset: (width,height) => (dx: width/3)),
  
  // diagonals
  // - top-left bottom-right (down diagonal)
  (pattern: ("1","5","9"), coord: (width,height) => (start: (0pt,0pt), end: (width/1.5,height/1.5)), offset: (width,height) => (dx: 0pt, dy: 0pt)),
  // - bottom-left top-right (up diagonal)
  (pattern: ("3","5","7"), coord: (width,height) => (start: (width/1.5,0pt), end: (0pt,height/1.5)), offset: (width,height) => (dx: 0pt, dy: 0pt)),
)


/// Play tictactoe (or non-canonical cross-circle). The function returns 0 if there are no winner so far, 1 for player 1, 2 for player 2 and 3 for tie
///
#let cross-circle(input, width: 3cm, height: 3cm, helper: true, icons: (
  emoji.crossmark, emoji.circle.green
), color: (player1: rgb("#dd2e44"), player2: rgb("#78b159"), draw: orange)) = {

  // sanitize input and filter duplicates
  
  let commands = if input != [] {purge-duplicates(sanitize-input(input.text))} else {""}


  

  // placeholder values
  let entries = (none,) * 9
  
  let statistic = (
    player1: (),
    player2: ()
  )

  let winner-player = none // who won -> none = tie
  let winner-cond = none // who won -> none = tie
  let winner-steps = 0 // when the winning condition was met!

  for i in range(commands.len()) {
    let c = commands.at(i)
    let current-player = calc.rem(i,2) + 1 

    statistic.at("player" + str(current-player)) += (c,)

    entries.at(int(c)-1) = icons.at(current-player - 1)

    // check winning conditions
    let filter-win = win-conditions.map(cond => {
      cond.pattern.map(c => {
        c in statistic.at("player" + str(current-player))
      }).all(n=>n)
    })

    // get the index of the winner condition
    let win-cond = filter-win.position(n => n)

    if win-cond != none {
      winner-player = current-player
      winner-steps = i
      winner-cond = win-conditions.at(win-cond)
      break
    }
  }

  
  if helper and winner-player == none {
    for (i,entry) in entries.enumerate() {
      if entries.at(i) == none {
        entries.at(i) = text(calc.min(width,height)/3,gray,[#(i+1)])   
      }
    }
  } else if winner-player != none {
    entries = entries.map(x => if x == none {[]} else {x})
  }

  
  (
    field:
    box(stroke: if winner-player != none {
      color.at("player" + str(winner-player))
    } else if winner-player == none and commands.len() == 9 {
      color.at("draw")
    },{
    grid(
      columns: (width/3,) * 3,
      rows: (height/3,) * 3,
      align: horizon+center,
      stroke: (x,y) => {
        if x > 0 {
          (left: black)
        }
        if y > 0 {
          (top: black)
        }
      },
      ..entries,
      
    )
    place(
      center+horizon,
      ..if winner-player != none {
        arguments(..(winner-cond.offset)(width,height),
        line(..line-stroke(
          paint: color.at("player" + str(winner-player)),
          thickness: calc.min(width,height)/12
        ), ..(winner-cond.coord)(width,height)))
      } else {
        arguments(none)
      }
    )
  }),
  winner: if winner-player != none {icons.at(winner-player - 1)} else if winner-player == none and commands.len() == 9 {"draw"},
  current: if winner-player == none {icons.at(calc.rem(commands.len(),2))}
  )
}
