#import "@preview/linguify:0.4.0": *
#import "clues.typ": clue, if-auto-then
#import "theme.typ": catppuccin as theme

// load linguify language database
#let lang-database = toml("lang.toml")

/// Helper for fetching the translated title
#let get-title-for(id) = {
  assert.eq(type(id),str);
  return linguify(id, from: lang-database, default: linguify(id, lang: "en", default: id));
}

/// Helper to get the accent-color from the theme
///
/// - id (string): The id for the predefined clue.
/// -> color
#let get-accent-color-for(id) = {
  return theme.at(id).accent-color
}

/// Helper to get the icon from the theme
///
/// - id (string): The id for the predefined clue.
/// -> content
#let get-icon-for(id) = {
  let icon = theme.at(id).icon
  if type(icon) == str {
    return image("assets/" + theme.at(id).icon, fit: "contain")
  } else {
    return icon
  }
}

/// Wrapper function for all predefined clues.
///
/// - id (string): The id of the clue from which color, icon and default title will be calculated.
/// - ..args (parameter): for overwriting the default parameter of a clue.
#let predefined-clue(id, ..args) = clue(
  accent-color: get-accent-color-for(id),
  title: get-title-for(id),
  icon: get-icon-for(id),
  ..args
)

#let info(..args) = predefined-clue("info",..args)
#let notify(..args) = predefined-clue("notify",..args)
#let success(..args) = predefined-clue("success",..args)
#let warning(..args) = predefined-clue("warning",..args)
#let danger(..args) = predefined-clue("danger",..args)
#let error(..args) = predefined-clue("error",..args)
#let tip(..args) = predefined-clue("tip",..args)
#let abstract(..args) = predefined-clue("abstract",..args)
#let goal(..args) = predefined-clue("goal",..args)
#let question(..args) = predefined-clue("question",..args)
#let idea(..args) = predefined-clue("idea",..args)
#let example(..args) = predefined-clue("example",..args)
#let experiment(..args) = predefined-clue("experiment",..args)
#let conclusion(..args) = predefined-clue("conclusion",..args)
#let memo(..args) = predefined-clue("memo",..args)
#let code(..args) = predefined-clue("code",..args)
#let quotation(attribution: none, content, ..args) = predefined-clue("quote",..args)[
  #quote(block: true, attribution: attribution)[#content]
]

#let gc-task-counter = counter("gc-task-counter")
#let gc-task-counter-enabled = state("gc-task-counter", true)

#let increment-task-counter() = {
    context {
    if (gc-task-counter-enabled.get() == true){
      gc-task-counter.step()
    }
  }
}

#let get-task-number() = {
  context {
    if (gc-task-counter-enabled.get() == true){
      " " + gc-task-counter.display()
    }
  }
}

#let task(..args) = {
  increment-task-counter()
  predefined-clue("task", title: get-title-for("task") + get-task-number(), ..args)
}
