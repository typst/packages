
#let create-puzzle(
    cell-size: 1.1cm,
    font-size: 18pt,
    solution: false,
    size,
    pos,
    across-words: none,
    down-words: none,
    across-clues: none,
    down-clues: none,
) = {

    // Function for deciding whether or not a given cell is the starting
    // cell for an across clue.
    let across-start(i) = {(
            // Across
            calc.rem(i, size) < size - 1 and (
            (
                i - 1 in pos and i + 1 not in pos
            ) or (
                calc.rem(i, size) == 0 and i + 1 not in pos
            )
        )
    )}

    // Function for computing the length of an across clue.
    let across-length(i) = {
        let n = 1
        // Keep looping as long as the cells below are whites
        while calc.div-euclid(i, size) == calc.div-euclid(i + 1, size) and i + 1 not in pos {
            i += 1
            n += 1
        }
        n
    }

    // Function for deciding whether or not a given cell is the starting
    // cell for ad own clue.
    let down-start(i) = {
        // Down
        i < (size - 1) * size and (
            ( 
            i - size in pos and i + size not in pos
            ) or (
            i < size and i + size not in pos
            )
        )
    }

    // Function for computing the length of a down clue.
    let down-length(i) = {
        let n = 1
        // Keep looping as long as the cells below are whites
        while (i < (size - 1) * size) and (i not in pos) and (i + size not in pos) {
            i += size
            n += 1
        }
        n
    }

    // Create an integer counter that keeps track of the clue number.
    let clue-counter = 1

    // Create an empty array for both across and down, storing where in the grid
    // each clue will start.
    let across-starting-positions = ()
    let down-starting-positions = ()

    // Array storing the clue numbers of the across clues.
    let across-numbers = ()

    // Array storing the clue numbers of the down clues.
    let down-numbers = ()

    // Compute the starting positions, i.e. the numbers for the clues.
    for i in range(size * size) {
        if not (i in pos or size * size - i - 1 in pos) {
            if across-start(i) {
                across-numbers.push((clue-counter, across-length(i)))
                across-starting-positions.push((
                    calc.div-euclid(i, size),
                    calc.rem(i, size)
                ))
            }
            if down-start(i) {
                down-numbers.push((clue-counter, down-length(i)))
                down-starting-positions.push((
                    calc.div-euclid(i, size),
                    calc.rem(i, size)
                ))
            }
            if across-start(i) or down-start(i) {
                clue-counter = clue-counter + 1
            }
        }
    }



    // Compute the arrays of the lengths of the words.
    let across-length-array = across-starting-positions.map(ij => (ij.at(0) * size + ij.at(1))).map(i => across-length(i))
    let down-length-array = down-starting-positions.map(ij => (ij.at(0) * size + ij.at(1))).map(i => down-length(i))

    // This is an array of size size * size that will contain the letters in the
    // correct positions, later to be filled into the grid of cells.
    let letters-array = range(size * size).map(i => "")

    if (solution) {

        // Fill the grid with the across words.
        for l in range(across-starting-positions.len()) {
            let i = across-starting-positions.at(l).at(0)
            let j = across-starting-positions.at(l).at(1)
            if across-words.at(l).len() == across-length-array.at(l) {
                for k in range(across-length-array.at(l)) {
                    letters-array.at(i * size + j + k) = across-words.at(l).at(k)
                }
            }
        }

        // Fill the grid with the down words.
        for l in range(down-starting-positions.len()) {
            let i = down-starting-positions.at(l).at(0)
            let j = down-starting-positions.at(l).at(1)
            if down-words.at(l).len() == down-length-array.at(l) {
                for k in range(down-length-array.at(l)) {
                    letters-array.at((i + k) * size + j) = down-words.at(l).at(k)
                }
            }
        }

    }

    clue-counter = 1

    // Create an array of cells.
    let cells = ()

    // Fill the array row by row.
    // At the end, these are going to be the cells that will make up the puzzle.
    for i in range(size * size) {
        if i in pos or size * size - i - 1 in pos {
            cells.push(square(height: cell-size, fill: black))
            // cells.push(table.cell[0])
        } else {
            if across-start(i) or down-start(i) {
                cells.push(square(height: cell-size, fill: none, stroke: black, inset: 1pt)[
                    #align(center + horizon)[#text(size: font-size)[#letters-array.at(i)]]
                    #place(top + left)[#clue-counter]
                ])
                clue-counter = clue-counter + 1
            } else {
                cells.push(square(height: cell-size, fill: none, stroke: black, inset: 1pt)[
                    #align(center + horizon)[#text(size: font-size)[#letters-array.at(i)]]
                ])
            }
        }
    }








  let puzzle = table(
      columns: size,
      inset: 0pt,
      ..range(size * size).map(i => cells.at(i))
    )

    let clues = ()

    if (across-clues == none) {
        across-clues = ()
    }

    if (down-clues == none) {
        down-clues = ()
    }

    clues = align(left + top)[
        #table(
        stroke: 0pt,
        columns: (50%, 0%, 50%),
        table.header([*Across:*], [], [*Down:*]),
        table.hline()
        )[
        #set enum(numbering: "1:")
        #for i in range(across-numbers.len()) {
        enum.item(across-numbers.at(i).first())[
            #let number = [(#across-numbers.at(i).last())]
            #if i < across-clues.len() {
                let clue = across-clues.at(i)
                if type(across-clues.at(i)) == array {
                clue = across-clues.at(i).first()
                number = [(#across-clues.at(i).last())]
                }
                clue
            }
            #number
            ]
        }

        ][][#table.vline()][
        #set enum(numbering: "1:")
        #for i in range(down-numbers.len()) {
        enum.item(down-numbers.at(i).first())[
            #let number = [(#down-numbers.at(i).last())]
            #if i < down-clues.len() {
                let clue = down-clues.at(i)
                if type(down-clues.at(i)) == array {
                clue = down-clues.at(i).first()
                number = [(#down-clues.at(i).last())]
                }
                clue
            }
            #number
            ]
        }
        ]
    ]

    return (puzzle, clues)


    // return (puzzle, clues)

}
