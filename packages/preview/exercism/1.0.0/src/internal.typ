#import "utils.typ": (
  and_then, error, global-name, global-prefix, hash, map, map_if, map_or,
)

#let global-state = state(
  global-name("global-state"),
  (
    envs: (:),
    items: (:),
  ),
)

/// Create a new exercise environment.
///
/// Returns the function to be used when creating instances of this
/// environment. If two arguments are provided when called, then the first is
/// the question and the second the solution. If three arguments are provided,
/// then the first is the title, the second the question, and the third the
/// solution.
/// -> function
#let new(
  /// A unique key for the environment.
  /// -> str
  identifier,
  /// The environment's supplement.
  ///
  /// If a function is specified, it is passed the environment's body and
  /// should return content.
  /// -> none | content | function
  supplement: none,
  /// How to number the environment. Accepts a #numbering-type.
  /// -> none | str | function
  numbering: "1",
  /// Whether to further separate instances of this environment into groups
  /// based on its location in the document.
  ///
  /// See @group for more information.
  /// -> none | function
  group: none,
) = {
  return (..args) => {
    // Get the exercise's title, question, and solution.
    let args = args.pos()
    let item = if args.len() == 2 {
      (title: none, question: args.at(0), solution: args.at(1))
    } else if args.len() == 3 {
      (title: args.at(0), question: args.at(1), solution: args.at(2))
    } else {
      error("expected either two or three arguments")
    }

    // Unique key for the exercise.
    item.hash = hash(item)

    // Store the exercise in the global state.
    context {
      let group = map(group, x => x(here()))

      let update(state) = {
        if identifier not in state.envs.keys() {
          state.envs.insert(identifier, (
            supplement: supplement,
            numbering: numbering,
            group: false,
          ))
          state.items.insert(identifier, (item,))
        } else {
          state.items.at(identifier) += (item,)
        }
        state
      }

      let update-group(state) = {
        if identifier not in state.envs.keys() {
          state.envs.insert(identifier, (
            supplement: supplement,
            numbering: numbering,
            group: true,
          ))
          state.items.insert(identifier, (:))
        }
        if group not in state.items.at(identifier).keys() {
          state.items.at(identifier).insert(group, (item,))
        } else {
          state.items.at(identifier).at(group) += (item,)
        }
        state
      }

      global-state.update(state => {
        if group == none {
          update(state)
        } else {
          update-group(state)
        }
      })
    }

    // Make a label for the exercise attach to this fake metadata which will
    // get redirected to the actual element later on.
    metadata(global-name("env", identifier, item.hash))
  }
}

/// Type signature of the function expected in @new.group.
/// -> str
#let group(
  /// -> location
  location,
) = {}

/// Display all the collected questions with the given formatting.
///
/// Requires ```typc context```.
/// -> content
#let questions(
  /// Key of the environment to use.
  /// -> str
  identifier,
  /// How to format each question.
  ///
  /// See @formatting for more information.
  /// -> function
  formatting,
  /// If @new.group was specified when creating the environment, then a
  /// specific instance of the value returned by @new.group must be given.
  /// -> none | str
  group: none,
) = {
  // Get all the questions for the env with the given identifier.
  let final-state = global-state.final()

  // Get information about this env.
  let env = final-state.envs.at(identifier, default: none)
  if env == none {
    // Do nothing if this env doesn't exist.
    return
  }

  // Error out if group is not specified when required.
  if env.group and group == none {
    error("env '" + identifier + "' requires a group to be specified")
  }
  let group = and_then(env.group, group)

  // Unique figure kind for this env.
  let kind = global-name(
    "kind",
    map_or(group, x => identifier + "#" + group, identifier),
    "question",
  )

  // Undo show-set rules on figures.
  show figure.where(kind: kind): set align(start)
  show figure.where(kind: kind): set block(breakable: true)

  // Layout each of the questions.
  for item in map_if(
    final-state.items.at(identifier),
    env.group,
    x => x.at(group, default: ()),
  ) [
    #show figure.where(kind: kind): it => {
      let number = map(it.numbering, x => it.counter.display(x))
      formatting(
        it.body,
        it.supplement,
        number,
        map(it.caption, x => x.body),
        label(global-name("solution", identifier, item.hash)),
      )
      [
        #metadata(number)
        #label(global-name("number", identifier, item.hash))
      ]
    }
    #figure(
      item.question,
      kind: kind,
      supplement: env.supplement,
      numbering: env.numbering,
      placement: none,
      caption: item.title,
      gap: 0em,
      outlined: false,
    )
    #label(global-name("question", identifier, item.hash))
  ]
}

/// Display all the collected solutions with the given formatting.
///
/// Requires ```typc context```.
/// -> content
#let solutions(
  /// Key of the environment to use.
  /// -> str
  identifier,
  /// How to format each solution.
  ///
  /// See @formatting for more information.
  /// -> function
  formatting,
  /// If @new.group was specified when creating the environment, then a
  /// specific instance of the value returned by @new.group must be given.
  /// -> none | str
  group: none,
) = {
  // Get all the solutions for the env with the given identifier.
  let final-state = global-state.final()

  // Get information about this env.
  let env = final-state.envs.at(identifier, default: none)
  if env == none {
    // Do nothing if this env doesn't exist.
    return
  }

  // Error out if group is not specified when required.
  if env.group and group == none {
    error("env '" + identifier + "' requires a group to be specified")
  }
  let group = and_then(env.group, group)

  // Unique figure kind for this env.
  let kind = global-name(
    "kind",
    map_or(group, x => identifier + "#" + group, identifier),
    "solution",
  )

  // Undo show-set rules on figures.
  show figure.where(kind: kind): set align(start)
  show figure.where(kind: kind): set block(breakable: true)

  // Layout each of the solutions.
  for item in map_if(
    final-state.items.at(identifier),
    env.group,
    x => x.at(group, default: ()),
  ) [
    #show figure.where(kind: kind): it => formatting(
      it.body,
      it.supplement,
      // Hack for now...
      query(label(global-name("number", identifier, item.hash))).first().value,
      map(it.caption, x => x.body),
      label(global-name("question", identifier, item.hash)),
    )
    #figure(
      item.solution,
      kind: kind,
      supplement: env.supplement,
      numbering: none,
      placement: none,
      caption: item.title,
      gap: 0em,
      outlined: false,
    )
    #label(global-name("solution", identifier, item.hash))
  ]
}

/// Type signature of the function expected in @questions.formatting and
/// @solutions.formatting.
/// -> content
#let formatting(
  /// -> content
  body,
  /// -> none | content
  supplement,
  /// -> none | content
  number,
  /// -> none | content
  title,
  /// Label pointing to the accompanying solution (question) of the current
  /// question (solution).
  /// -> label
  opposite,
) = {}

/// Show rule to enable correct references to questions.
///
/// Should be applied with ```typ #show ref: show-ref``` at the start of the
/// document.
/// -> ref
#let show-ref(
  /// -> ref
  it,
) = {
  // Do we have a sequence?
  if it.element == none or it.element.func() != [].func() {
    return it
  }

  // Is the last child metadata?
  let last = it.element.children.at(-1, default: none)
  if last == none or last.func() != metadata {
    return it
  }

  // Check the metadata to see whether we should hijack this reference.
  let fields = last.value.split(":")
  let prefix = fields.at(0, default: none)
  if prefix == none or prefix != global-prefix or fields.at(1) != "env" {
    return it
  }

  // Redirect reference target to the correct element.
  let (env, hash) = (fields.at(2), fields.at(3))
  ref(
    label(global-name("question", env, hash)),
    supplement: it.supplement,
    form: it.form,
  )
}
