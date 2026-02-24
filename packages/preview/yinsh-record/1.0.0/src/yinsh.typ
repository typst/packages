#import "@preview/cetz:0.3.4"
#import cetz.draw: *

#let border = (
  "a": (start: 2, end: 5),
  "b": (start: 1, end: 7),
  "c": (start: 1, end: 8),
  "d": (start: 1, end: 9),
  "e": (start: 1, end: 10),
  "f": (start: 2, end: 10),
  "g": (start: 2, end: 11),
  "h": (start: 3, end: 11),
  "i": (start: 4, end: 11),
  "j": (start: 5, end: 11),
  "k": (start: 7, end: 10),
  )

#let check-index(p,q) = {
  return p.len() == 1 and p in "abcdefghijk" and q in range(border.at(p).start, border.at(p).end + 1)
}

#let coordinate-parser(p,q) = {
  let x = -4*calc.sqrt(3)
  let y = -4
  let _p = 0
  let _q = 0
  p = lower(p)
  if check-index(p,q) {
  _p = "abcdefghijk".position(p) - 1  
  _q = q - 2
  }
  else {
    panic("Index Error!")
  } 
  return (x + calc.sqrt(3)*_p, y - _p + 2*_q)
  }


#let line-parser(st, ed) = {
  let delta = 0
  let (sp, sq) = (st.at(0), int(st.slice(1,)))
  let (ep, eq) = (ed.at(0), int(ed.slice(1,)))
  let line = ()
  let start = sp.to-unicode()
  let end = ep.to-unicode()
  if check-index(sp,sq) and check-index(ep,eq) {
    if (sp,sq) == (ep,eq) {
      panic("The ending point must differ from the starting point.")
    }
    if ep > sp {
        if eq - sq == end - start {
          for p in range(end - start + 1) {
            line.push(str.from-unicode(start + p) + str(sq + p))
          }
        }
        else if eq == sq {
          for p in range(end - start + 1) {
            line.push(str.from-unicode(start + p) + str(sq))
          }
        }
        else {
          panic("The starting point and the ending point must be on the same line.")
        }
    }
    else if ep == sp {
      if eq > sq {
        for q in range(eq - sq + 1) {
          line.push(sp + str(sq + q))
        }
      }
      else {
        for q in range(sq - eq + 1) {
          line.push(sp + str(sq - q))
        }
      }
    }
    else {
        if sq - eq == start - end {
          for p in range(start - end + 1) {
            line.push(str.from-unicode(start - p) + str(sq - p))
          }
        }
        else if sq == eq {
          for p in range(start - end + 1) {
            line.push(str.from-unicode(start - p) + str(sq))
          }
        } 
        else {
          panic("The starting point and the ending point must be on the same line.")
        }       
      }
    }
  else {
    panic("Index Error!")
  } 
  return line
}

#let ring = (b: (radius: 15pt, fill: rgb(0,0,0,0), stroke: (paint: black, thickness: 5pt)), w: (radius: 15pt, fill: rgb(99,99,99,30), stroke: (paint: gray, thickness: 5pt)))

#let stone = (b: (radius:9pt, fill: black, stroke:black), w: (radius:9pt, fill: gray.lighten(70%), stroke: black))

#let place-piece((p,q), piece-type, color-type) = {
  circle(coordinate-parser(p,q), ..piece-type.at(color-type))
}

#let board(board-color) = {
  set-style(stroke:(paint: board-color))

  for p in "abcdefghijk" {

    let coor = coordinate-parser(p,border.at(p).start)
    let coo = coordinate-parser(p,border.at(p).end)
    line((rel: (0, -0.5), to: coor), (rel: (0, 0.5), to: coo))
    content((rel: (0, -1.2), to: coor), text(upper(p), fill: board-color.lighten(50%), size: 2em))
  }

  for q in range(1,12) {
    let first = ""
    for p in "abcdefghijk" {
      if q in range(border.at(p).start,border.at(p).end + 1) {
      first = p
      break
      }
    }
    let last = ""
    for p in "kjihgfedcba" {
      if q in range(border.at(p).start,border.at(p).end + 1) {
      last = p
      break
      }
    }
    let coor = coordinate-parser(first,q)
    let coo = coordinate-parser(last,q)
    content((rel: (150deg, 1.2), to: coor), text(str(q), fill: board-color.lighten(50%), size: 2em))
    line((rel: (150deg, 0.5), to: coor), (rel: (-30deg, 0.5), to: coo))
  }

  line((rel: (30deg, 0.5), to: coordinate-parser("e",10)), (rel: (-150deg, 0.5), to: coordinate-parser("b",7)))

  for p in "ghij" {
    line((rel: (30deg, 0.5), to: coordinate-parser(p,11)), (rel: (-150deg, 0.5), to: coordinate-parser("a",5 - "ghij".position(p))))
  }

  line((rel: (30deg, 0.5), to: coordinate-parser("j",10)), (rel: (-150deg, 0.5), to: coordinate-parser("b",2)))

  for q in range(0,4) {
    line((rel: (30deg, 0.5), to: coordinate-parser("k", 10 - q)), (rel: (-150deg, 0.5), to: coordinate-parser("bcde".at(q) ,1)))
  }

  line((rel: (30deg, 0.5), to: coordinate-parser("j",5)), (rel: (-150deg, 0.5), to: coordinate-parser("g",2)))
}

#let show-score(x,y) = {
  if x >= 3 {
  content((-7,-11), box(text([White Scores *#str(x)*], fill: red, size: 2.5em), stroke: 2pt + red, inset: 5pt))
  }
  else {
  content((-7,-11), text([White Scores *#str(x)*], fill: red, size: 2.5em))
  }
  if y >= 3 {
  content((7,11), box(text([Black Scores *#str(y)*],fill: red, size: 2.5em), stroke: 2pt + red, inset: 5pt))
  }
  else {
  content((7,11), text([Black Scores *#str(y)*], fill: red, size: 2.5em))
  }
}

#let play(data, black-first: false) = {
  let status = (:)
  let score = (0,0)
  let rings = ()
  let stones = ()
  let current = ""
  let next-stone = ""
  let to-remove = false
  let n = 0
  let commands = ()
  if type(data) == str {
  commands = data.split(regex("[\r\n]+")).filter(it => it != "")
  }
  else if type(data) == array {
    commands = data
  }
  else {
    panic("TypeError: the parameter must be str or array.")
  }

  cetz.canvas({
    board(black)
    for command in commands {
      command = lower(command).split(regex("[ \t]+")).filter(it => it != "")
      let color-type = ""

      let is-white = true
      if  black-first {
      is-white= calc.odd(n)
      }
      else {
      is-white= calc.even(n)
      }

      if is-white {
        color-type = "w"
      }
      else {
        color-type = "b"
      }
      if command.len() < 2 {
        panic("Missing Prarameter: command '" + str(command.join(" ")) + "' ")
      }
      if to-remove and command.at(0) != "x" {
        panic("It is necessary to remove a ring after removing a line of five stones.")
      }
      if command.at(0) == "p" and n < 10 {
        if command.at(1) in rings {
          panic("The ring may not be placed on another ring.")
        }
        status.insert(command.at(1), ("piece-type": ring, "color-type": color-type))
          rings.push(command.at(1))
      }
      else if command.at(0) == "p" and n >= 10 {
        panic("We can't place a ring at this stage")
      }
      else if command.at(0) == "s" {
        if command.at(1) in rings{
          if status.at(command.at(1)).color-type == color-type {
          status.insert(command.at(1), ("piece-type": none, "color-type": color-type))
          stones.push(command.at(1))
          current = command.at(1)
          n += -1
          }
          else {
            panic("The stone must be placed in a ring of the same color as itself!")
          }
        }
        else {
          panic("The stone must be placed in a ring!")
        }
      }
      else if command.at(0) == "m" {
        if current != none {
          if command.at(1) in rings or command.at(1) in stones {
            panic("The ring may not be placed on another piece.")
          }
          for point in line-parser(current, command.at(1)).filter(it => it != current and it != command.at(1)) {

            if point in stones {
              status.at(point) = ("piece-type": stone, "color-type": "bw".trim(status.at(point).color-type))
              next-stone = point
            }
            else if next-stone != "" and next-stone != command.at(1) {
              panic("After jumping over one or more stones (markers), the ring may not move over any more vacant spaces!")
            }
            if point in rings {
              panic("The ring encounters another ring during the movement.")
            }
          }
          next-stone = ""
          status.insert(command.at(1), ("piece-type": ring, "color-type": color-type))
          status.at(current) = ("piece-type": stone, "color-type": color-type)
          rings = rings.filter(it => it != current)
          rings.push(command.at(1))
          current = none
        }
        else {
          panic("Please choose a ring and place a stone.")
        }
      }
      else if command.at(0) == "x" {
        if to-remove {
          if command.at(1) not in rings {
            panic("There is no ring at the coordinate '" + str(command.at(1)) + "' ")
          }
          // if status.at(command.at(1)).color-type != color-type {
          //   panic("Only when the color of a ring is the same as the stones that were removed from the board can the ring be removed.")
          // }
          _ = status.remove(command.at(1))
          score.at("wb".position(color-type)) += 1
          rings = rings.filter(it => it != command.at(1))
          to-remove = false
        }
        else {
          panic("Only when a row of 5 stones of the same color have been removed can a certain ring be removed from the board.")
        }
      }
      else if command.at(0) == "r" {
        if command.len() < 3 {
        panic("Missing Prarameter: command '" + str(command.join(" ")) + "' ")
        }
        let points = line-parser(command.at(1), command.at(2))
        if  points.all(it => it in stones and status.at(it).color-type == "w") or points.all(it => it in stones and status.at(it).color-type == "b") {
          if points.len() == 5 {
            for point in points {
              stones = stones.filter(it => it != point)
              _ = status.remove(point)
            } 
            to-remove = true
          }
          else {
            panic("Only when the number of stones is 5 can the line of stones be removed.")
          }
        }
        else {
          panic("There are stones of different color in the line, or space/rings exist(s). ")
        }
      }
      else {
        panic("Error: command '" + str(command.join(" ") + "' is unvalid"))
      }
      n += 1
    }

    show-score(..score)
    for coor in status.keys() {
      if status.at(coor).piece-type == none {
        place-piece((coor.at(0), int(coor.slice(1,))), ring, status.at(coor).color-type)
        place-piece((coor.at(0), int(coor.slice(1,))), stone, status.at(coor).color-type)
      }
      else {
        place-piece((coor.at(0), int(coor.slice(1,))), status.at(coor).piece-type, status.at(coor).color-type)
      }
    }
  })
}

#let record(data, step: none, black-first: false) = {
  let commands = data.split(regex("[\r\n]+")).filter(it => it != "")
  if step == none {
    for s in range(commands.len()+1) {
    play(commands.slice(0,s), black-first: black-first)
    }
  }
  else {
    play(commands.slice(0, step), black-first: black-first)
  }
}