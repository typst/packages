#import "@preview/elembic:1.1.1" as e
#import "utils.typ"
#import "problem.typ": problem
#import "section.typ": section
#import "solution.typ": solution
#import "config.typ": config
#import "i18n.typ": m, files


#let show-tags(problem) = context {
  if problem.tags == none { return none }
  let tags = problem.tags
  if type(tags) != array {
    tags = (tags,)
  }

  let result = ()
  for tag in tags {
    let obj = config.get().tags.find(t => t.id == tag)
    assert.ne(obj, none, message: "Tag not found: " + tag)

    result.push(text(
      obj.color,
      "(" + (if obj.name == none { obj.id } else { obj.name }) + ")",
      style: "italic",
      weight: "bold",
    ))
  }

  result.join([ ])
}

///
/// - problem (problem):
/// -> link
#let show-link(problem) = context {
  let config-link = config.get().link
  if config-link == none {
    return []
  }
  let url = if utils.istype(config-link, str) {
    config-link + problem.id
  } else { config-link(problem) }

  return link(url, problem.id)

}

///
/// Render a list of the section(s) or problem(s) specified.
///
/// - problem-counter (counter): The counter that will be used to index the problems.
/// - data (array | section | problem): Object or array of type `section` or `problem` that will be presented as content.
/// - num-base (content | none): Content to be appended at the front of the problem counter, with a dot.
/// ->
#let problems-list(data, ..args, num-base: none) = context {
  let problem-counter = args.pos().first(default: none)
  if problem-counter == none {
    problem-counter = counter("__oak_problem_counter")
    problem-counter.update(0)
  }

  if utils.istype(data, e.types.array(section)) {
    list(tight: false, ..data.map(sect => problems-list(sect, problem-counter, num-base: num-base)))
  } else if utils.istype(data, section) [
    *#data.name.*

    #data.descr

    #problems-list(data.problems, problem-counter, num-base: num-base)

  ] else if utils.istype(data, e.types.array(problem)) {
    list(tight: false, ..data.map(prob => problems-list(prob, problem-counter, num-base: num-base)))
  } else if utils.istype(data, problem) {
    let prob = data

    context problem-counter.step()

    context [
      *#m("problem", true) #if num-base == none { "" } else {
        str(num-base) + "."
      }#problem-counter.display().* #prob.name #show-tags(prob)
    ]
    if prob.id != none {
      [ -- ]
      if config.get().link == none { prob.id } else { show-link(prob) }
    }
    if prob.author != none [ -- #emph(prob.author)]

    parbreak()

    prob.descr
  }
}


#let problems-solutions(data, ..args, num-base: none, level: 2) = context {
  let problem-counter = args.pos().first(default: none)
  if problem-counter == none {
    problem-counter = counter("__oak_problem_counter")
    problem-counter.update(0)
  }

  let heading-message = utils.capitalize(files.at(text.lang).at("problem"))

  if utils.istype(data, problem) {
    let prob = data
    if prob.sol == none {
      return problem-counter.step()
    }
    problem-counter.step()
    heading(
      level: level,
      {
        heading-message
        [
          #if num-base == none { "" } else {
            str(num-base) + "."
          }#(problem-counter.get().at(0) + 1). #prob.name #show-tags(prob)
        ]
        if prob.id != none {
          [ -- ]
          if config.get().link == none { prob.id } else { show-link(prob) }
        }
      },
      numbering: none,
    )

    prob.descr-sol

    if type(prob.sol) != array {
      prob.sol = (prob.sol,)
    }

    let indexsols = prob.sol.len() > 1
    for (i, sol) in prob.sol.enumerate(start: 1) {
      if type(sol) == content { sol = solution(sol) }
      if sol == auto { sol = solution(auto) }

      if sol.body == auto {
        assert.ne(config.get().read-func, none, message: "Code field set to auto, but read function not set.")
        assert.ne(prob.id, none, message: "Code field set to auto, but ID not set.")

        let lang = if sol.lang == none {
          assert.ne(
            config.get().default-lang,
            none,
            message: "Using code solution without specifying language, but default language not set.",
          )
          config.get().default-lang
        } else { sol.lang }

        let file = (
          data.id
            + {
              if indexsols { "-" + str(i) } else { "" }
            }
            + "."
            + lang
        )

        sol.body = raw((config.get().read-func)(file), lang: lang)
      }

      let headingtext = utils.capitalize(files.at(text.lang).at("solution"))
      if indexsols {
        headingtext += " "
        headingtext += str(i)
      }
      if sol.title != none {
        headingtext += ". "
        headingtext += sol.title
      }
      heading(level: level + 1, headingtext, numbering: none)
      sol.descr

      parbreak()
      if sol.body.func() == raw {
        set text(config.get().code-size)
        sol.body
      } else { sol.body }

    }
  } else if utils.istype(data, e.types.array(problem)) {
    for prob in data {
      problems-solutions(prob, problem-counter, num-base: num-base, level: level)
    }
  } else if utils.istype(data, section) {
    heading(level: level, data.name)
    data.descr-sol
    problems-solutions(data.problems, problem-counter, num-base: num-base, level: level + 1)
  } else if utils.istype(data, e.types.array(section)) {
    for s in data {
      problems-solutions(s, problem-counter, num-base: num-base, level: level)
    }
  }
}

