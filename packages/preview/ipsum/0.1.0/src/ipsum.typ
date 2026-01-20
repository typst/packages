/*
  File: ipsum.typ
  Author: neuralpain
  Date Modified: 2026-01-04

  Description: Lorem's Ipsum.
*/

#let __golden = 0.61803398875

#let info-block = (
  config: (inset: 1em, radius: 4pt, width: 100%),
  err: (
    fill: rgb("#ffcccc"),
    border: 1pt + red,
    text: red.darken(30%),
  ),
  warn: (
    fill: rgb("#fff4cc"),
    border: 1pt + orange.darken(10%),
    text: orange.darken(40%),
  ),
  hint: (
    fill: rgb("#e6f7ff"),
    border: 1pt + blue.lighten(30%),
    text: blue.darken(30%),
  ),
  stats: (
    fill: rgb("#f6ffed"),
    border: 1pt + rgb("#b7eb8f"),
    text: rgb("#389e0d"),
    text-2: gray,
  ),
)

#let _err(msg, title: "Error") = {
  block(
    ..info-block.config,
    fill: info-block.err.fill,
    stroke: info-block.err.border,
  )[
    #set text(fill: info-block.err.text)
    #box(inset: (right: 0.5em))[#emoji.warning]
    #h(0.3em)*#raw(title + ": ")*#raw(msg)
  ]
}

#let _warn(msg, title: "Warning") = {
  block(
    ..info-block.config,
    fill: info-block.warn.fill,
    stroke: info-block.warn.border,
  )[
    #set text(fill: info-block.warn.text)
    #box(inset: (right: 0.5em))[#emoji.warning]
    #h(0.3em)*#raw(title + ": ")*#raw(msg)
  ]
}

#let _hint(mode, params) = {
  block(
    ..info-block.config,
    fill: info-block.hint.fill,
    stroke: info-block.hint.border,
  )[
    #set text(fill: info-block.hint.text)
    #h(0.6em)
    #box(inset: (right: 0.3em))[#emoji.info]
    #h(1em)
    *#raw("Parameter list for mode '" + mode + "':")*
    #h(0.5em)
    #params.map(p => raw(p)).join(",   ")
  ]
}

#let _nerdstats(mode, words, pars, notes: ()) = {
  let avg = if pars > 0 { int(words / pars) } else { 0 }

  block(
    ..info-block.config,
    fill: info-block.stats.fill,
    stroke: info-block.stats.border,
    above: 1.5em,
  )[
    #set text(fill: info-block.stats.text)
    #stack(dir: ttb,
      spacing: 0.8em,
      [
        #box(inset: (right: 0.5em))[#emoji.chart]
        *`Stats for Nerds`* #h(1fr) #text(fill: info-block.stats.text-2, size: 0.8em, raw(mode))
      ],
      line(length: 100%, stroke: info-block.stats.border),
      grid(
        columns: (1fr, 1fr, 1fr),
        align: center,
        stack(spacing: 0.5em, text(size: 0.8em, fill: info-block.stats.text-2)[`Total Words`], text(weight: "bold", size: 1.2em)[#raw(str(words))]),
        stack(spacing: 0.5em, text(size: 0.8em, fill: info-block.stats.text-2)[`Paragraphs`], text(weight: "bold", size: 1.2em)[#raw(str(pars))]),
        stack(spacing: 0.5em, text(size: 0.8em, fill: info-block.stats.text-2)[`Avg. Length`], text(weight: "bold", size: 1.2em)[#raw(str(avg))]),
      ),
      if notes.len() > 0 {
        line(length: 100%, stroke: info-block.stats.border)
        set text(size: 0.85em)
        text(weight: "bold")[`Notes`]
        list(indent: 1em, marker: [•], raw(..notes))
      }
    )
  ]
}

/// Generate blind text through different modes such as natural writing,
/// dialogue patterns, geometric structures, and mathematical sequences.
///
/// - mode (string): The generation method.
/// - pars (int): Number of paragraphs to generate. Applies to most modes.
/// - events (int): `Dialogue` — Total number of lines (narrative or spoken).
/// - base (int): `Grow` — Minimum base word count.
/// - start (int): `Fade` — The word count of the first paragraph.
/// - total (int): `Fit` — The sum of words across all generated paragraphs.
/// - var (int): `Natural` — How much the length deviates from the average.
/// - average (int): `Natural` — The baseline word count per paragraph.
/// - factor (int): `Grow` — The steepness of the growth curve.
/// - seed (int): `Natural, Dialogue` — Random seed for variations.
/// - ratio (float): Decay/growth rate or dialogue probability.
/// - steps (int): `Fibonacci` — How many steps of the sequence to generate.
/// - reverse (bool): Switch to reverse the sequence.
/// - spacing (length): Vertical spacing between paragraphs.
/// - justify (bool): Whether to justify the generated text.
/// - indent (length): Paragraph first line indent.
/// - h-indent (length): `Dialogue` — Paragraph hanging indent.
/// - word-count (bool): Display paragraph word count.
/// - hint (bool): Displays the valid parameters for the selected mode.
/// - stats (bool): Show generation statistics and notes.
/// - ignore-limits (bool): Allow values to go past safe limits.
/// - ignore-warnings (bool): Hide warning text when thresholds are exceeded.
/// -> content
#let ipsum(
  mode: "natural",
  pars: 5,
  events: 10,
  base: 20,
  start: 100,
  total: 300,
  var: 30,
  average: 60,
  factor: 50,
  seed: 42,
  ratio: __golden,
  steps: 8,
  reverse: true,
  spacing: 1em,
  justify: false,
  indent: 0em,
  h-indent: 0em,
  word-count: false,
  // System
  hint: false,
  stats: false,
  ignore-limits: false,
  ignore-warnings: false,
) = {
  let average-minimum = 5
  let seed-threshold = 1000000000000 // one trillion
  let pars-threshold = 50
  let words-threshold = 100000
  let fib-threshold = 25
  let fib-high-volume = 20
  let fib-large-volume = 15
  // Stats
  let actual-words = 0
  let actual-pars = 0
  let stats-note = ()

  let valid-modes = (
    "natural",    // Natural human flow
    "grow",       // Logarithmic
    "fade",       // Geometric
    "fit",        // Geometric
    "dialogue",   // Natural speech patterns
    "fibonacci",  // Mathematic
  )

  let common-param = ("spacing", "indent")
  let param-map = (
    "natural":    ("pars", "average", "var", "seed", ..common-param),
    "grow":       ("pars", "base", "factor", "word-count", ..common-param),
    "fade":       ("pars", "start", "ratio", "word-count", ..common-param),
    "fit":        ("pars", "total", "ratio", "word-count", ..common-param),
    "dialogue":   ("events", "ratio", "seed", ..common-param),
    "fibonacci":  ("steps", "reverse", "word-count", ..common-param),
  )

  if type(mode) != str {
    return _err("`mode` must be of type `string`.")
  }

  if mode.len() == 0 {
    _err("`mode` cannot be empty.")
    _err(title: "Valid modes", valid-modes.join(", "))
    return
  }

  if mode not in valid-modes {
    _err("Unknown mode '" + mode + "'.")
    _err(title: "Valid modes", valid-modes.join(", "))
    return
  }

  for (key, value) in param-map {
    if mode == key and "pars" in value and pars < 1 {
      return _err(title: "Invalid value", "`pars` must be >= 1.")
    }
  }

  if mode == "fade" {
    if start < 1 {
      return _err(title: "Invalid value", "Start count must be positive.")
    }
    if ratio < 0 {
      return _err(title: "Invalid value", "`ratio` cannot be negative.")
    }
  }

  if mode == "grow" {
    // Ln(1) is 0, so base must handle the minimum size
    if base < 1 {
      return _err(title: "Invalid value", "`base` size must be positive.")
    }
    if factor < 5 {
      _warn("`factor` size too small for any significant change.")
    }
  }

  if mode == "fit" {
    if total < pars {
      return _err("Total words (" + str(total) + ") is too low for " + str(pars) + " pars.")
    }
    // The formula uses division by (1 - ratio). If ratio is 1.0, this causes division by zero.
    if ratio == 1.0 {
      return _err("Division by zero. `ratio` cannot be exactly 1.0 in fit. Use 0.99 or 1.01.")
    }
    if ratio <= 0 {
      return _err("`ratio` must be positive.")
    }
  }

  if mode == "fibonacci" {
    if steps < 1 {
      return _err(title: "Invalid value", "`steps` must be >= 1.")
    }
    if steps > fib-threshold {
      if ignore-limits and not ignore-warnings {
        _warn("High `steps` value (>" + str(fib-threshold) + "). System may be slow to respond.")
      } else if not ignore-limits {
        return _err(title: "Limit Reached", "Larger `steps` value may result in poor performance or responsiveness.")
      }
    }
  }

  if mode == "natural" {
    if average < average-minimum {
      return _err("Average word count too low (min " + str(average-minimum) + ").")
    }
    // Ensure var doesn't create negative lengths
    if (average - var) < 0 {
      return _err("`var` (" + str(var) + ") is higher than `average` (" + str(average) + "). This may result in negative word counts.")
    }
  }

  if mode == "dialogue" {
    if events < 1 {
      return _err(title: "Invalid value", "`events` must be >= 1.")
    }
    if ratio < 0.0 or ratio > 1.0 {
      return _err(title: "Invalid value", "Talk ratio must be between 0.0 and 1.0.")
    }
  }

  if hint { _hint(mode, param-map.at(mode)) }

  if not ignore-warnings {
    if seed > seed-threshold { _warn("Set `seed` between 1 and one trillion for best results.") }
    if pars > pars-threshold {
      _warn(title: "High volume", "System may be slow to respond.")
    }
    if total > words-threshold or (mode == "fibonacci" and steps > fib-high-volume) {
      _warn(title: "High volume", "System may be slow to respond.")
    }
    if mode == "fibonacci" and steps >= fib-large-volume and reverse {
      _warn("Reverse Fibonacci `steps` > " + str(fib-large-volume) + " creates a very large leading paragraph.")
    } else if steps >= fib-large-volume {
      _warn("Fibonacci `steps` > " + str(fib-large-volume) + " creates very large paragraphs.")
    }
    if mode == "dialogue" and (ratio < 0.1 or ratio > 0.9) {
      _warn("Extreme `ratio` value may result in no dialogue or no narrative text.")
    }
    if mode == "fit" and ratio > 0.95 and ratio < 1.05 {
      _warn("`ratio` is very close to 1.0; paragraph lengths may appear identical due to integer rounding.")
    }
  }

  let ipsum-render = [
    #if mode == "fade" {
      let results = range(0, pars).map(i => {
        let count = int(start * calc.pow(ratio, i))
        if count < 1 { count = 1 }
        let content = [
          #if word-count { text(weight: "bold")[#count words:] }
          #h(indent)#lorem(count)
        ]
        (len: count, content: content)
      })

      if stats {
        actual-words = results.map(r => r.len).sum()
        actual-pars = results.len()
        if ratio > 0.9 { stats-note.push("Ratio is high (" + str(ratio) + "). Decrease to fade text faster.") }
      }

      stack(dir: ttb, spacing: spacing, ..results.map(r => r.content))
    }

    #if mode == "grow" {
      let results = range(1, pars + 1).map(i => {
        let count = int(base + (factor * calc.ln(i)))
        let content = [
          #if word-count { text(weight: "bold")[#count words:] }
          #h(indent)#lorem(count)
        ]
        (len: count, content: content)
      })

      if stats {
        actual-words = results.map(r => r.len).sum()
        actual-pars = results.len()
      }

      stack(dir: ttb, spacing: spacing, ..results.map(r => r.content))
    }

    #if mode == "fit" {
      // a = S * (1 - r) / (1 - r^n)
      let first-len = total * (1 - ratio) / (1 - calc.pow(ratio, pars))

      let results = range(0, pars).map(i => {
        let len = int(first-len * calc.pow(ratio, i))
        if len < 1 { len = 1 }
        let content = [
          #if word-count { text(weight: "bold")[#len words:] }
          #h(indent)#lorem(len)
        ]
        (len: len, content: content)
      })

      if stats {
        actual-words = results.map(r => r.len).sum()
        actual-pars = results.len()
        let diff = calc.abs(actual-words - total)
        if diff > (total * 0.05) {
          stats-note.push("Result deviates from target " + str(total) + " by " + str(diff) + " words due to integer rounding.")
          stats-note.push("Try slightly adjusting `ratio` or `pars` for better fit.")
        }
      }

      stack(dir: ttb, spacing: spacing, ..results.map(r => r.content))
    }

    #if mode == "fibonacci" {
      set par(justify: true, first-line-indent: 1.5em)

      let get-fibs(steps) = {
        let nums = (1, 1)
        while nums.len() < steps {
          let len = nums.len()
          let next = nums.at(len - 1) + nums.at(len - 2)
          nums.push(next)
        }
        return nums
      }

      let fibs = get-fibs(steps)
      let reversed-fibs = if reverse { fibs.rev() } else { fibs }

      if stats {
        actual-words = reversed-fibs.sum()
        actual-pars = reversed-fibs.len()
      }

      stack(dir: ttb, spacing: spacing, ..reversed-fibs.map(count => {
        if word-count {
          grid(
            columns: (3em, 1fr),
            gutter: 1em,
            align(right + top)[
              #text(weight: "bold", fill: gray)[#count]
            ],
            [#h(indent)#lorem(count)],
          )
        } else {
          [#h(indent)#lorem(count)]
        }
      }))
    }

    #if mode == "natural" {
      let results = range(0, pars).map(i => {
        let noise = calc.sin((i + 1) * seed)
        let len = int(average + (noise * var))

        if noise > 0.8 {
          len = int(len * 1.5)
        } else if noise < -0.8 {
          len = int(len * 0.4)
        }

        if len < 5 { len = 5 }

        (len: len, content: [#h(indent)#lorem(len)])
      })

      if stats {
        actual-words = results.map(r => r.len).sum()
        actual-pars = results.len()
        if var > (average * 0.7) {
          stats-note.push("High variance detected. If paragraphs look too chaotic, reduce `var`.")
        }
      }

      stack(dir: ttb, spacing: spacing, ..results.map(r => r.content))
    }

    #if mode == "dialogue" {
      let results = range(0, events).map(i => {
        let noise = calc.sin((i + 9) * seed)
        let length-noise = calc.cos((i + 3) * seed)
        let is-dialogue = noise < (ratio * 2 - 1)
        let len = 0
        let content = []

        if is-dialogue {
          len = int(3 + calc.abs(length-noise * 12))
          content = par(hanging-indent: h-indent)[
            #h(indent)“#lorem(len)#if len < 10 {"?"}”
          ]
        } else {
          len = int(25 + calc.abs(length-noise * 45))
          content = [#h(indent)#lorem(len)]
        }

        (len: len, content: content)
      })

      if stats {
        actual-words = results.map(r => r.len).sum()
        actual-pars = results.len()
      }

      stack(dir: ttb, spacing: spacing, ..results.map(r => r.content))
    }
  ]

  set par(spacing: spacing)

  ipsum-render

  if stats {
    _nerdstats(mode, actual-words, actual-pars, notes: stats-note)
  }
}
