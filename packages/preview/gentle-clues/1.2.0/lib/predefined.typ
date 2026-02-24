#import "@preview/linguify:0.4.2": *
#import "clues.typ": clue, if-auto-then
#import "theme.typ": catppuccin as theme

// load linguify language database
#let lang-database = toml("lang.toml")

/// Helper for fetching the translated title
#let _get-title-for(id) = {
  assert.eq(type(id),str);
  return linguify(id, from: lang-database, default: linguify(id, lang: "en", default: id));
}

/// Helper to get the accent-color from the theme
/// -> color
#let _get-accent-color-for(
  /// The id for the predefined clue.
  /// -> string
  id
) = {
  return theme.at(id).accent-color
}

/// Helper to get the icon from the theme
/// -> content
#let _get-icon-for(
  /// The id for the predefined clue.
  /// -> string
  id
) = {
  let icon = theme.at(id).icon
  if type(icon) == str {
    return image("assets/" + theme.at(id).icon, fit: "contain")
  } else {
    return icon
  }
}

/// Wrapper function for all predefined clues.
/// -> clue
#let _predefined-clue(
  /// The id of the clue from which color, icon and default title will be calculated.
  /// -> string
  id,
  /// for overwriting the default parameter of a clue.
  /// -> parameter
  ..args
) = clue(
  accent-color: _get-accent-color-for(id),
  title: _get-title-for(id),
  icon: _get-icon-for(id),
  ..args
)


/// #docs-info("abstract")
/// ```example
/// #abstract[Make it short. This is all you need.]
/// ```
/// -> content
#let abstract(
  /// Supports all parameters of @clue.
  /// -> arguments
  ..args
) = _predefined-clue("abstract",..args)

/// #docs-info("info")
/// ```example
/// #info[Whatever you want to say]
/// ```
/// -> content
#let info(..args) = _predefined-clue("info",..args)

/// #docs-info("notify")
/// Notificaton
/// ```example
/// #notify[New features in future versions.]
/// ```
/// -> content
#let notify(..args) = _predefined-clue("notify",..args)

/// #docs-info("success")
/// ```example
/// #success[All tests passed. It's worth a try.]
/// ```
/// -> content
#let success(..args) = _predefined-clue("success",..args)

/// #docs-info("warning")
/// ```example
/// #warning[Still a work in progress.]
/// ```
/// -> content
#let warning(..args) = _predefined-clue("warning",..args)

/// #docs-info("danger")
/// ```example
/// #danger[Be carefull.]
/// ```
/// -> content
#let danger(..args) = _predefined-clue("danger",..args)

/// #docs-info("error")
/// ```example
/// #error[Something did not work here.]
/// ```
/// -> content
#let error(..args) = _predefined-clue("error",..args)

/// #docs-info("tip")
/// ```example
/// #tip[Check out this cool package]
/// ```
/// -> content
#let tip(..args) = _predefined-clue("tip",..args)

/// #docs-info("goal")
/// ```example
/// #goal[Beatuify your document!]
/// ```
/// -> content
#let goal(..args) = _predefined-clue("goal",..args)

/// #docs-info("question")
/// ```example
/// #question[How do amonishments work?]
/// ```
/// -> content
#let question(..args) = _predefined-clue("question",..args)

/// #docs-info("idea")
/// ```example
/// #idea[Some content]
/// ```
/// -> content
#let idea(..args) = _predefined-clue("idea",..args)

/// #docs-info("example")
/// ```example
/// #example[Lets make something beautifull.]
/// ```
/// -> content
#let example(..args) = _predefined-clue("example",..args)

/// #docs-info("experiment")
/// ```example
/// #experiment[Try this ...]
/// ```
/// -> content
#let experiment(..args) = _predefined-clue("experiment",..args)

/// #docs-info("conclusion")
/// ```example
/// #conclusion[This package makes it easy to add some beatufillness to your documents.]
/// ```
/// -> content
#let conclusion(..args) = _predefined-clue("conclusion",..args)

/// #docs-info("memo")
/// ```example
/// #memo[Leave a #emoji.star on github.]
/// ```
/// -> content
#let memo(..args) = _predefined-clue("memo",..args)

/// #docs-info("code")
/// ```example
/// #code[`#let x = "secret"`]
/// ```
/// -> content
#let code(..args) = _predefined-clue("code",..args)

/// #docs-info("quote")
/// ```example
/// #quotation(attribution: "The maintainer")[Keep it simple. Admonish your life.]
/// ```
/// -> content
#let quotation(
  /// The author of the quote
  /// -> string | none
  attribution: none,
  /// the quote itself
  /// -> content
  content,
  /// Supports all parameter from @clue.
  /// -> arguments
  ..args) = _predefined-clue("quote",..args)[
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

/// #docs-info("task")
/// ```example
/// #task[Check out this wonderful typst package!]
/// ```
/// -> content
#let task(..args) = {
  increment-task-counter()
  _predefined-clue("task", title: _get-title-for("task") + get-task-number(), ..args)
}
