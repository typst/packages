#import "spec.typ": spec, spell, component-type
#import "util.typ": merge-configs, config-state
#import "markscheme.typ"

//REGION: author

/// Construct a callable author entry.
/// Returns a `function`, which:
/// - is intended to be supplied to this template's functions, where asked. Other packages/templates likely do not respect its usage;
/// - can be left uncalled, i.e. not appending "()" or "[]" to it;
/// - can be called with a suffix, e.g. `returned-func[suffix content]`.
/// See more of its usage in documentation of the `setup()` function.
///
/// - firstname (str, content): The first name.
///   [WARN] If `content` is given, make sure Typst can convert it to `str`, or also provide an `plain`; else in the author metadata it will show as "`<unsupported>`"
/// - lastname (str, content): The last name, i.e. surname.
///   [WARN] If `content` is given, make sure Typst can convert it to `str`, or also provide an `plain`; else in the author metadata it will show as "`<unsupported>`"
/// - id (int, str, content): An ID, perhaps a student number.
///  Will be wrapped in `raw()`, displaying with "code" style.
///  If Typst cannot convert it to `str`, the above will not apply.
/// - plain (str, none): A string, which is the plain representation of the *full* name.
/// -> function
#let author(firstname, lastname, id, plain: none, config: (:), ..pass) = (..args) => {
  let argp = args.pos()
  let argn = args.named()

  (
    (
      name: (
        first: firstname,
        last: lastname,
      ),
      id: id,
      plain: plain,
      prefix: none,
      suffix: none,
      config: config,
      ..pass.named(),
    )
      + argn
      + if argp.len() == 1 { (suffix: argp.at(0)) } else if argp.len() > 1 { (prefix: argp.at(0), suffix: argp.at(1)) }
  )
}

/// Grow author objects by calling each if it is a function.
///
/// - authors (array): The `author()`s to grow.
/// -> array
#let authors-grower(authors) = authors.pos().map(a => if type(a) == function { a() } else { a })

/// Visualize an author object.
///
/// - author (dictionary): The author object to visualize.
/// - config (dictionary): The config.
/// -> content
#let author-visualizer(aut, config: (:)) = {
  let conf = merge-configs(config, aut.config)

  (conf.author.container)(
    stack,
    (
      dir: ttb,
      spacing: .65em,
    ),
    (
      author: aut,
      name: (conf.author.affix-format)(
        (conf.author.name-format)(
          aut.name.first,
          aut.name.last,
        ),
        aut.prefix,
        aut.suffix,
      ),
      id: (
        if type(aut.id) in (int, decimal, float) {
          raw(str(aut.id))
        } else if type(aut.id) == str {
          raw(aut.id)
        } else if type(aut.id) == content and "text" in a.id.fields() {
          raw(aut.id.text)
        } else {
          aut.id
        }
      ),
    ),
    config: conf,
  )
}

/// Visualize a set of authors.
///
/// - authors (array): The set of author to visualize.
/// - config (dictionary): The config.
/// -> content
#let author-set-visualizer(authors, config: (:)) = {
  (config.author.set-container)(
    // the grid for rows
    grid,
    (
      columns: 1fr,
    ),
    (
      authors: authors,
      rows: authors
        .chunks(4)
        .map(ck => grid(
          // above, the grid for cols in a row
          columns: (1fr,) * ck.len(),
          align: center,
          ..ck,
        )),
    ),
    config: config,
  )
}

/// Visualize the project head.
///
/// - title (content, str): The project title.
/// - group (content, str): The group name.
/// - authors (content): The *visualized* authors.
/// - config (dictionary): The config.
/// -> content
#let project-head-visualizer(title, group, authors, config: (:)) = {
  (config.head.container)(
    grid,
    (
      columns: 1fr,
      align: center,
      inset: .65em,
    ),
    (
      title: (config.title.format)(title),
      group: (config.group.format)(group),
      authors: authors,
    ),
    config: config,
  )
}

/// Explicitly visualize a project head from raw `setup()` arguments.
/// It is a `context {}`.
///
/// - title (content, str): The project title.
/// - group (content, str): The group name.
/// - authors (array): The *raw, un-visualized* authors objects.
/// - config (dictionary): The config.
///   [WARN] This config is merged with the global config state, i.e. the one you gave `setup`.
/// -> content
#let visualize-project-head(title, group, ..authors, config: (:)) = context {
  let conf = merge-configs(config-state.get(), config)

  let authors = authors-grower(authors)
  project-head-visualizer(
    title,
    group,
    author-set-visualizer(
      authors.map(a => author-visualizer(a, config: conf)),
      config: conf,
    ),
    config: conf,
  )
}

//REGION: util

/// Produce `line` number of empty line(s) using `linebreak`, or an empty block till the end of the current container when `line < 0`.
///
/// - lines (int): The number of empty lines to produce. A number less than 0 means all the way to the end of container instead.
/// -> content
#let spacer(lines) = if lines > -1 { linebreak() * lines } else { v(1fr) }

/// Produce a question information object.
///
/// - args (arguments): Information of the question.
///   - `(none, ...)` → empty/null question info;
///   - `(question, ...)` → `id` and `label` of the question;
///   - `(id, label)` → `id` and `label`.
/// -> dictionary
#let qsn-info(..args) = {
  args = args.pos()
  let fst = args.first()
  if fst == none {
    return (
      id: (),
      label: none,
    )
  }
  if component-type(fst) == spec.question.name {
    return (
      id: fst.id,
      label: fst.label,
    )
  }
  (
    id: fst,
    label: args.at(1),
  )
}

/// Produce a label based on a question ID.
///
/// - id (array): The question's ID, an array of integers.
/// - head (str): The head of the label generated.
/// - config (dictionary): The config containing question labelling information.
/// -> label
#let question-labeller(id, head: spec.question.label-head, config: (:)) = {
  if config == (:) { panic(config) }
  label(head + id.enumerate().map(((x, i)) => numbering(config.question.labelling.at(x), i)).join("-"))
}

/// Generate content for displaying point of a question based on a numeric point value and a display guide.
/// When `point-display == auto`, generate appropriate English point text.
/// [WARN] Does not leave trailing space when `point-display` is a `function`.
///
/// - point (int, decimal): The numeric point.
/// - point-display (auto, str, content, function): The content to display, give `auto` for automatic point display, can be a function that accepts a numeric point argument.
/// -> content
#let point-visualizer(point, point-display) = {
  // if display is func: call it
  if type(point-display) == function {
    return point-display(point)
  }
  // if display is definite, show it
  if point-display != auto {
    return [(#point-display) ]
  }

  // else, automatic point
  if point == 1 {
    return [(#point point) ]
  }
  if point == 0 {
    return []
  }
  return [(#point points) ]
}

/// Visualize a question target, a `ref` or a `label` in general.
///
/// - target (label): The target question's label.
/// - target-display (content, str, function, auto): The display guide/override for the target.
///   - `auto` → a `ref()` to the target label, aligned right.
///   - `function` → called with `target`, and whatever returned.
///   - otherwise, whatever `target-display`, wrapped in a `ref()` to `target`, aligned right.
/// -> content
#let target-visualizer(target, target-display) = {
  // if not to display, return none
  if none in (target, target-display) {
    return none
  }
  // if display is auto, display it
  if target-display == auto {
    return [
      #set align(right)
      #ref(target)
    ]
  }
  // if display is function, call it
  if type(target-display) == function {
    return (target-display)(target)
  }
  // if display is definite, show it with link to target
  return [
    #set align(right)
    #ref(target, supplement: target-display)
  ]
}

/// Find the first (DFS) instance of component that matches all the predicates.
/// Returns an array of 2 elements, firstly, if there is a match, secondly, the first match, if any.
///
/// - tree (array): The tree containing branches of component.
/// - pred (argument): The predicates to match with the components. For positional predicates, each will be compared with components directly, or being called with a component to return a `bool` if it is a function. For named predicates, they will be searched in components as `dictionary` key-value pairs.
/// - no-components (bool): Whether to set `components: none` for the component found. Use `true` if the child components of a component does not matter.
/// -> array
#let find-component(tree, ..pred, no-components: true) = {
  let pcomp = pred.pos()
  let pfield = pred.named()

  for branch in tree {
    if type(branch) != dictionary and pfield != (:) {
      continue
    }

    if (
      pcomp.fold(
        true,
        (can, pred) => {
          if not can { return false }
          if type(pred) == function {
            return pred(branch)
          } else {
            return branch == pred
          }
        },
      )
        and pfield
          .pairs()
          .fold(
            true,
            (can, pred) => {
              if not can { return false }
              return branch.keys().contains(pred.first()) and branch.at(pred.first()) == pred.last()
            },
          )
    ) {
      return (
        true,
        (
          if no-components {
            branch + (components: none)
          } else { branch }
        ),
      )
    } else if component-type(branch) != spec.flat.name {
      let (found, comp) = find-component(branch.components, ..pred)
      if found { return (true, comp) }
    }
  }

  return (false, none)
}

//REGION: flat

/// Visualize "flat" content: stuff not managed or processed by this template.
///
/// - flat (any): The content, anything.
/// - config (dictionary): The config, does nothing for now.
/// -> any
#let flat-visualizer(flat, config: (:)) = {
  flat
}

//REGION: feeder

/// Produce a feeder object.
/// A function, `proc`, and its arguments that will be run, but if an argument is a component, it will be first visualized, then fed to `proc`.
/// - Visualize: This template's helper functions, e.g. `question` and `solution`, produce data that is intended to be visualized by wrapper functions, instead of being put to the document directly. Visualization is the process that such data is turned into display-ready content.
///
/// - proc (function): A function to be run with visualized components.
/// - args (arguments): Arguments for `proc`, components within will be first visualized when visualizing the feeder.
/// -> dictionary
#let feeder(
  proc,
  config: (:),
  ..args,
) = {
  assert(type(proc) == function, message: "`proc` must be a function.")

  spell(
    spec.feeder.name,
    proc: proc.with(..args.named()),
    components: args.pos(),
    config: config,
  )
}

/// Calls a `feeder.proc` with its components, wrapped in a content block.
///
/// - feeder (dictionary): The `feeder` to visualize.
/// -> content
#let feeder-visualizer(tak, config: (:)) = {
  [#(tak.proc)(..tak.components)]
}

//REGION: question

/// Produce a question object.
///
/// - point (int, decimal, float, auto): The point the question is worth.
///   Can be left `auto`:
///   - if there are sub-questions in `args`, the sum of their `point`s becomes this `point`;
///   - if there is no sub-question, it becomes 0.
///   [WARN] For precision, `float` value is converted to `decimal` through `str`.
/// - point-display (any, function, auto): The display guide/override for the point value.
/// - label (str, label, auto): The label for the question.
///   - `auto` → question is automatically labelled with its question number.
///   - `str` → question is labelled with a label comprised of a identifying head, then this `label`.
///   - otherwise, whatever `label`, but it should be a `label`.
/// - config (dictionary): The config used in question processing.
/// - args (arguments): The sub-elements of the question, and API reserve.
///   - positional (like `value, value,`) → the question's sub-elements, can be anything, including `question` and `solution`.
///   - named (like `name: value,`) → reserved for potential modding. Named `args` is added to the question object produced, and can be used by custom processors.
/// -> dictionary
#let question(
  point: auto,
  point-display: auto,
  label: auto,
  config: (:),
  ..args,
) = {
  if type(point) == float {
    point = decimal(str(point))
  }

  spell(
    spec.question.name,
    point: point,
    point-display: point-display,
    id: auto,
    label: label,
    components: args.pos(),
    config: config,
    ..args.named(),
  )
}

/// Visualize a question.
///
/// - qsn (dictionary): The question to be visualized.
/// - config (dictionary, module): The config, containing question visualization information. This config is supposed to be passed down from the recursive visualization call.
///   [WARN] Only the `config` field is extracted from `module`, if provided.
/// -> content
#let question-visualizer(qsn, config: (:)) = {
  let conf = merge-configs(config, qsn.config)
  [
    #set text(fill: conf.question.color-major)
    #show: conf.question.rule

    #block[
      #figure(
        kind: spec.question.kind,
        // makes numbering into supplement, so refs can completely replace the text
        supplement: _ => (
          conf.question.supplement
            + " "
            + qsn.id.enumerate().map(((x, i)) => numbering(conf.question.numbering.at(x), i)).join()
        ),
        numbering: _ => h(-.3em),
      )[]
      #qsn.label
      #(conf.question.container)(
        grid,
        (
          inset: (
            (x: .3em, y: .65em),
            .65em,
          ),
          columns: (1.65em, 1fr),
          align: (right, left),
          stroke: conf.question.stroke-major,
        ),
        (
          number: numbering(
            conf.question.numbering.at(qsn.id.len() - 1),
            qsn.id.last(),
          ),
          point: point-visualizer(qsn.point, qsn.point-display),
          main: qsn.components.join(),
        ),
        config: conf,
      )
    ]
  ]
}

//REGION: solution

/// unique solution count, used for markscheme
#let solution-counter = counter(spec.solution.kind)

/// Produce a solution object.
///
/// - supplement (content, str, none): The supplement to be displayed at the start of solution content, like "Solution: ".
/// - target (label, auto): The question this solution is for. It will be set to the question of lowest level containing this solution, even if with other non-question components in the middle.
/// - target-display (content, str, function, auto): The display guide/override for the target.
///   - `auto` → a `ref()` to the target label, aligned right.
///   - `function` → called with `target`, and whatever returned.
///   - otherwise, whatever `target-display`, wrapped in a `link()` to `target`, aligned right.
/// - label (str, label, none): The label of the solution. If it is a `str`, a specific head, like "sn:" will be automatically prepended, then form a label.
/// - config (dictionary): The config used in solution processing.
/// - args (arguments): The sub-elements of the solution, and API reserve.
///   - positional (like `value, value,`) → the solution's sub-elements, can be anything, including `question` and `solution`.
///   - named (like `name: value,`) → reserved for potential modding. Named `args` is added to the question object produced, and can be used by custom processors.
/// -> dictionary
#let solution(
  supplement: none,
  target: auto,
  target-display: auto,
  label: none,
  config: (:),
  ..args,
) = {
  spell(
    spec.solution.name,
    supplement: supplement,
    target: target,
    target-display: target-display,
    label: label,
    components: args.pos(),
    config: config,
    ..args.named(),
  )
}

/// Visualize a solution.
///
/// - sol (dictionary): The solution to be visualized.
/// - config (dictionary, module): The config, containing solution visualization information. This config is supposed to be passed down from the recursive visualization call.
///   [WARN] Only the `config` field is extracted from `module`, if provided.
/// -> content
#let solution-visualizer(sol, config: (:)) = {
  let conf = merge-configs(config, sol.config)
  solution-counter.step()
  context [
    // make sure all the grids in this figure use the same uid
    #let uid = solution-counter.get().first()

    #set text(fill: conf.solution.color-major)
    #show: conf.solution.rule

    #block[
      #figure(
        kind: spec.solution.kind,
        // makes numbering into supplement, so refs can completely replace the text
        supplement: _ => (
          conf.solution.supplement
            + if sol.target != none {
              [ to #underline(ref(sol.target))]
            }
        ),
        numbering: _ => h(-.3em),
      )[]
      #sol.label
      #(conf.solution.container)(
        grid,
        (
          stroke: conf.solution.stroke-major,
          inset: .65em,
          columns: 1fr,
          align: left,
        ),
        (
          target: target-visualizer(sol.target, sol.target-display),
          supplement: sol.supplement,
          main: sol.components.join(),
          marking-extension: none,
          // marking-extension: v(.65em),
          // + markscheme.embed-pin(id: uid, usage: spec.marker.name, pos: bottom + left),
          marking: markscheme.marking.with(uid),
        ),
        config: conf,
      )
    ]
  ]
}

//REGION: grower

/// Grow (process) a branch, only effective against components of this package.
/// Returns an array as `(grown-branch, question-count)`
///
/// - branch (dictionary): The branch to be grown.
/// - parent (dictionary): Information of its parent question.
/// - qs-count (int): The number of question on the same level before it.
/// - components-grower (function): How to grow its components.
/// - config (dictionary, module): The config used in component processing.
///   [WARN] Only the `config` field is extracted from `module`, if provided.
/// -> array
#let branch-grower(branch, parent, qs-count, components-grower, config: (:)) = {
  let btype = component-type(branch)
  let pt = 0

  if btype == spec.flat.name {
    // flat: no action
  } else {
    let conf = merge-configs(config, branch.config)

    if btype == spec.question.name {
      // question:
      // - assign ID
      branch.id = parent.id + (qs-count,)
      // - assign label
      if branch.label == auto {
        branch.label = question-labeller(branch.id, config: conf)
      } else if type(branch.label) == str {
        branch.label = label(spec.question.label-head + branch.label)
      }
      // - grow components
      (branch.components, pt, _) = components-grower(branch.components, qsn-info(branch))
      // - collect points
      if branch.point == auto {
        branch.point = pt
      }
    } else if btype == spec.solution.name {
      // solution:
      // - assign label
      if type(branch.label) == str {
        branch.label = label(spec.solution.label-head + branch.label)
      }
      // - set target to parent question
      if branch.target == auto {
        branch.target = parent.label
      }
      // update target-display
      if branch.target-display == auto {
        if branch.target == parent.label {
          branch.target-display = none
        }
      }
      // - grow components
      (branch.components, _, _) = components-grower(branch.components, parent)
    } else if btype == spec.feeder.name {
      // feeder:
      // - ignore the feed and continue to its components
      (branch.components, _, qs-count) = components-grower(branch.components, parent, qs-count: qs-count)
    } else {
      panic("Unknown component type `" + btype + "`!")
    }
  }

  // finally return the branch
  return (branch, qs-count)
}

/// Grow (process) an array of branches as an integral.
/// It is used as the `components-grower` for `branch-grower`.
/// Returns an array as `(grown-branches, total-point, question-count)`
///
/// - branches (array): The branches to grow.
/// - parent (dictionary): Information of their parent question.
/// - qs-count (int): The number of questions on the same level.
/// - config (dictionary, module): The config used in component processing.
///   [WARN] Only the `config` field is extracted from `module`, if provided.
/// -> array
#let grow-branches(branches, parent, qs-count: 0, config: (:)) = {
  // initialize from branches
  branches.fold(
    ((), 0, qs-count),
    ((bs, pt, qc), branch) => {
      // update root question ID
      if component-type(branch) == spec.question.name {
        qc += 1
      }
      // start growing the branch
      let (grown, qc) = branch-grower(
        branch,
        parent,
        qc,
        grow-branches.with(config: config),
        config: config,
      )

      (
        bs + (grown,),
        pt + grown.at("point", default: 0),
        qc,
      )
    },
  )
}

//REGION: visualizer

/// Visualize an array of branches as an integral.
/// Returns an array of visualized branches.
///
/// - branches (array): The branches to visualize.
/// - config (dictionary, module): The config used in component visualization.
///   [WARN] Only the `config` field is extracted from `module`, if provided.
/// -> array
#let visualize-branches(branches, config: (:)) = {
  branches.map(branch => {
    let btype = component-type(branch)

    if btype == spec.flat.name {
      flat-visualizer(branch, config: config)
    } else {
      let conf = merge-configs(config, branch.config)

      // first, visualize its components
      branch.components = visualize-branches(branch.components, config: conf)

      // then, call respective visualizer
      if btype == spec.question.name {
        question-visualizer(branch, config: conf)
      } else if btype == spec.solution.name {
        solution-visualizer(branch, config: conf)
      } else if btype == spec.feeder.name {
        feeder-visualizer(branch, config: conf)
      } else {
        panic("Unknown componemnt type `" + btype + "`!")
      }
    }
  })
}

//REGION: wrapper

/// [USER]: Put the `question`s, `solution`s and things that fit in a question-solution structure as this function's arguments!
///
/// - branches (arguments): The branches, including components of this package, to process and visualize.
/// - config (dictionary, module): The config used in processing and visualizing this package's components.
///   [WARN] Only the `config` field is extracted from `module`, if provided.
/// -> content
#let components-wrapper(..branches, config: (:)) = context {
  let conf = merge-configs(config-state.get(), config)

  visualize-branches(
    grow-branches(
      branches.pos(),
      qsn-info(none),
      config: conf,
    ).first(),
    config: conf,
  ).join()
}

/// Nullify figures of `kind in (spec.question.kind, spec.solution.kind)`, showing them as `none`.
///
/// - body (content): The body to apply the rules on.
/// -> content
#let qns-nullifier(body) = {
  show figure: it => if it.kind in ("question", "solution").map(e => spec.at(e).kind) {
    none
  } else {
    it
  }

  body
}
