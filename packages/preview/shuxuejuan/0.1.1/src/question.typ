#import "env.typ": *
#import "utils.typ": *
#import "answer.typ": *

#let question = heading

/// Reset all counters of question.
/// -> none
#let sxj-question-reset-num() = {
  counter(question).update(0)
  counter-question-l2.update(1)
}

#let _get-question-numbering(
  qst-style: ("一、", "1.", "(1)"),
  level2-index: none,
  numbers: none,
) = {
  let qst-style-func(level, index) = {
    return numbering("1.", index)
  }
  if type(qst-style) == array {
    qst-style-func = {
      (level, index) => {
        if level < qst-style.len() {
          return numbering(
            qst-style.at(level),
            index,
          )
        }
        return numbering("1.", index)
      }
    }
  } else if type(qst-style) == function {
    qst-style-func = qst-style
  }

  let level = numbers.len()
  let result = ()

  if level2-index != none and level >= 2 {
    numbers.at(1) = level2-index
  }

  let i = 0
  while i < level {
    result.push(qst-style-func(i, numbers.at(i)))
    i += 1
  }

  return result
}

#let _get-dist-txt-equ() = {
  let a = query(selector(math.equation).after(here()))
  if a.len() == 0 { return 0em }
  return (measure(a.first()).height - measure[test].height) * 0.45
}

#let id-question-updater(level, ..id-current) = {
  let id-new = id-current.pos()
  id-new.pop()
  while id-new.len() - 1 < level {
    id-new.push(0)
  }
  id-new.at(0) += 1
  id-new.at(level) += 1
  id-new.push(level)
  return id-new
}

#let sxj-question(level, body, qst-number-level2: none) = {
  id-question.update((..args) => id-question-updater(level, ..args))

  let num-l2 = none
  if qst-number-level2 == auto {
    if level == 2 {
      counter-question-l2.step()
    }
    num-l2 = counter-question-l2.get().first()
  }
  let qst-numbering = _get-question-numbering(
    level2-index: num-l2,
    numbers: counter(question).get(),
  )

  let qst-align-style = env-get("qst-align-number")
  let num = [#qst-numbering.last()]
  let body = [#body]

  set text(size: font-size.small, weight: "medium")
  set grid(gutter: 0em)
  if qst-align-style == "One-Lined-Compact" {
    set grid(columns: 1fr)
    set par(hanging-indent: measure[#num#h(0em)].width)
    grid([#num#h(0em)#body])
  } else if qst-align-style == "One-Lined" {
    set grid(columns: 1fr)
    if level == 1 {
      set text(weight: "extrabold")
      set par(hanging-indent: measure[#num#h(-.65em)].width)
      grid([#num#body])
    } else {
      set par(hanging-indent: measure[#num#h(.18em)].width)
      grid([#num#h(.5em)#body])
    }
  } else {
    let offset-cnt-pos = 0em
    if qst-align-style == auto {
      offset-cnt-pos = _get-dist-txt-equ()
    }
    set grid(columns: (auto, 1fr))
    if level == 1 {
      set text(weight: "extrabold")
      grid([#num#sym.wj], [#v(-offset-cnt-pos)#body])
    } else {
      grid([#num#h(.5em)], [#v(-offset-cnt-pos)#body])
    }
  }
}
