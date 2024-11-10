#import "words.typ": words, allowed

#import "@preview/suiji:0.3.0"

#let choose_answer(seed) = {
  let rng = suiji.gen-rng(seed)
  let (rng, answer_idx) = suiji.integers(rng, low: 0, high: words.len())
  let answer = words.at(answer_idx)

  answer
}

#let _separate_valid_guesses(guesses, max_guesses) = {
  let valids = ()
  let invalids = ()

  for guess in guesses {
    if guess.match(regex("^[a-zA-Z.]+\\??$")) == none {
      invalids.push((
        word: guess,
        reason: "'" + guess + "' includes non-alphabet characters.",
      ))
      continue
    }

    if not guess.ends-with("?") {
      let letters = guess.clusters()
      if letters.len() > 5 {
        letters = letters.slice(0, 5)
      }
      letters = (..letters, ..(none,) * (5 - letters.len()))
      valids.push((
        word: guess,
        letters: letters,
        complete: false,
      ))
      continue
    }

    guess = guess.slice(0, -1)
    if guess.len() != 5 {
      invalids.push((
        word: guess,
        reason: "'" + guess + "' is not five letter word.",
      ))
      continue
    }
    if guess.match(regex("^[a-zA-Z]+$")) == none {
      invalids.push((
        word: guess,
        reason: "'" + guess + "' includes non-alphabet characters.",
      ))
      continue
    }

    if guess not in allowed {
      invalids.push((
        word: guess,
        reason: "'" + guess + "' is not in valid word list.",
      ))
      continue
    }

    valids.push((
      word: guess,
      letters: guess.clusters(),
      complete: true,
    ))
  }

  (valids: valids, invalids: invalids)
}

#let judge_guesses(guesses, answer, max_guesses) = {
  let inputs = ()
  let warnings = ()
  // type: "guessing" | "over" | "clear"
  let game_state = "guessing"
  let n_attempts = 0

  let (valids, invalids) = _separate_valid_guesses(guesses, max_guesses)
  for guess in valids {
    if guess.complete {
      if n_attempts >= max_guesses {
        continue
      }
      n_attempts = n_attempts + 1
      let input = {
        let pair = guess.letters.zip(answer.clusters())
        let rest_chars = pair
          .filter(((char_guess, char_answer)) => char_guess != char_answer)
          .map(((_, char_answer)) => char_answer)
        pair.map(((char_guess, char_answer)) => {
          let judge = if char_guess == char_answer {
            "correct"
          } else if char_guess in rest_chars {
            "included"
          } else {
            "not_included"
          }
          (char: char_guess, judge: judge)
        })
      }
      inputs.push(input)
      if guess.word == answer {
        game_state = "clear"
      }
    } else {
      let input = guess.letters.map(char => (char: char, judge: none))
      inputs.push(input)
    }

    if n_attempts >= max_guesses and game_state != "clear" {
      game_state = "over"
      continue
    }
  }
  for guess in invalids {
    warnings.push(guess.reason)
  }

  (
    inputs: inputs,
    warnings: warnings,
    game_state: game_state,
  )
}

#let letter_box(char: none, style: none) = {
  set text(font: "DejaVu Sans Mono", weight: 700, size: 24pt)
  if style == none {
    box(
      width: 40pt,
      height: 40pt,
      fill: white,
      stroke: 1pt,
      align(center + horizon, text(fill: luma(20%), upper(char))),
    )
  } else {
    let color = (
      not_included: luma(20%),
      included: yellow.darken(30%),
      correct: green.darken(20%),
    ).at(style)
    box(
      width: 40pt,
      height: 40pt,
      fill: color,
      align(center + horizon, text(fill: white, upper(char))),
    )
  }
}

#let letter_boxes(inputs, max_guesses) = {
  if inputs.len() > max_guesses {
    inputs = inputs.slice(0, max_guesses)
  }
  let n_blanks = max_guesses - inputs.len()

  grid(
    columns: 5,
    row-gutter: 6pt,
    column-gutter: 6pt,
    ..inputs
      .map(input => {
          input.map(((char, judge)) => {
            letter_box(char: char, style: judge)
          })
        })
      .flatten(),
    ..range(n_blanks * 5).map(_ => {
      box(
        width: 40pt,
        height: 40pt,
        fill: white,
        stroke: 1pt,
      )
    })
  )
}

#let keyboard(inputs, key_layout: ("qwertyuiop", "asdfghjkl", "zxcvbnm")) = {
  let score = (correct: 2, included: 1, not_included: 0)
  let char_attempts = if inputs.len() > 0 {
    inputs.sum().filter(((judge,)) => judge != none).fold(
      (:),
      (d, (char, judge)) => {
        if score.at(judge) >= score.at(d.at(char, default: "not_included")) {
          d.insert(char, judge)
        }
        d
      },
    )
  } else {
    (:)
  }
  set text(font: "DejaVu Sans Mono", weight: 400, size: 12pt)
  set par(spacing: 2pt)

  key_layout
    .map(
      row => {
        let line = row
          .clusters()
          .map(
            char => {
              let status = char_attempts.at(char, default: none)
              let b = if status == none {
                box(
                  width: 14pt,
                  height: 16pt,
                  radius: 2pt,
                  fill: white,
                  stroke: 1pt,
                  align(center + horizon, text(fill: luma(20%), upper(char))),
                )
              } else {
                let color = (
                  not_included: luma(20%),
                  included: yellow.darken(30%),
                  correct: green.darken(20%),
                ).at(status)
                box(
                  width: 13pt,
                  height: 17pt,
                  radius: 2pt,
                  fill: color,
                  baseline: 0.5pt,
                  align(center + horizon, text(fill: white, upper(char))),
                )
              }
              box(inset: 3pt, b)
            }
          )
          .join()
        block(line)
      }
    )
    .join()
}

#let _wordle_ui(answer, user_guesses, max_guesses, seed, key_layout) = {
  let (inputs, warnings, game_state) = judge_guesses(
    user_guesses,
    answer,
    max_guesses,
  )

  let status_message = (
    guessing: none,
    over: "You've used all your attempts. Better luck next time!",
    clear: "Congraturations! You've got the correct answer.",
  ).at(game_state)

  show heading: set text(font: "DejaVu Sans Mono", size: 1.2em)
  show heading: set block(spacing: 20pt)
  set align(center)

  page(
    width: 320pt,
    height: auto,
    margin: 20pt,
    footer: align(right, text(fill: luma(60%))[seed: #seed]),
  )[
    = Typst Wordle

    #letter_boxes(inputs, max_guesses)

    #if status_message != none {
      block(
        width: 100%,
        fill: green.lighten(80%),
        inset: 15pt,
        radius: 5pt,
        align(center, status_message),
      )
    }

    #keyboard(inputs, key_layout: key_layout)

    #if warnings.len() > 0 {

      block(
        width: 100%,
        fill: yellow.lighten(80%),
        inset: 15pt,
        radius: 5pt,
        [
          === Warnings

          #align(
            left,
            list(
              marker: emoji.warning,
              ..warnings,
            ),
          )
        ],
      )
    }

  ]
}


#let wordle(
  body,
  seed: none,
  max-guesses: 6,
  key-layout: ("qwertyuiop", "asdfghjkl", "zxcvbnm"),
) = {
  if seed == none {
    seed = datetime.today()
  }
  if type(seed) == "datetime" {
    seed = seed.year() * 10000 + seed.month() * 100 + seed.day()
  }

  let answer = choose_answer(seed)
  let user_guesses = body
    .children
    .filter(c => c.has("text"))
    .map(c => lower(c.text))

  _wordle_ui(answer, user_guesses, max-guesses, seed, key-layout)
}
