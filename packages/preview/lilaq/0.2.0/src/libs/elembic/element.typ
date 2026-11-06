#import "data.typ": data, lbl-show-head, lbl-outer-head, lbl-counter-head, lbl-ref-figure-kind-head, lbl-ref-figure-label-head, lbl-ref-figure, lbl-get, lbl-tag, lbl-rule-tag, lbl-data-metadata, lbl-stateful-mode, lbl-normal-mode, lbl-auto-mode, lbl-global-where-head, prepared-rule-key, stored-data-key, element-key, element-data-key, global-data-key, filter-key, special-data-values, custom-type-key, custom-type-data-key, type-key
#import "fields.typ" as field-internals
#import "types/base.typ"
#import "types/types.typ"

#let element-version = 1

// Basic elements for our document tree analysis
#let sequence = [].func()
#let space = [ ].func()
#let styled = { set text(red); [a] }.func()
#let state-update-func = state(".").update(1).func()
#let counter-update-func = counter(".").update(1).func()

// Potential modes for configuration of styles.
// This defines how we declare a set rule (or similar)
// within a certain scope.
#let style-modes = (
  // Normal mode: we store metadata in a bibliography.title set rule.
  //
  // Before doing so, we retrieve the original value for bibliography.title,
  // allowing us to restore it later. The effect is that the library is
  // fully hygienic, that is, the change to bibliography.title is not perceptible.
  //
  // The downside is that retrieving the original value for bibliography.title costs
  // an additional nested context { } call, of which there is a limit of 64. This means
  // that, in this mode, you can have up to 32 non-consecutive set rules.
  normal: 0,

  // leaky mode: similar to normal mode, but we don't try to preserve the value of bibliography.title
  // after applying our changes to the document. This doubles the limit to up to 64 non-consecutive
  // set rules since we no longer have an extra step to retrieve the old value, but, as a downside,
  // we lose the original value of bibliography.title. While, in a future change, we might be able to
  // preserve the FIRST known value, we can't generally preserve its value at later points, so the
  // value of bibliography.title is effectively frozen before the first custom set rule.
  //
  // This mode should be used by package authors which know there won't be a bibliography (or, really,
  // any custom user input) at some point to avoid consuming the set rule cost. End users can also use
  // this mode if they hit a "max show rule depth exceeded" error.
  //
  // Note that this mode can only be enabled on individual set rules.
  leaky: 1,

  // Stateful mode: this is entirely different from the other modes and should only be set by the end
  // user (not by packages). This stores the style chain - and, thus, set rules' updated fields - in
  // a 'state()'. This is more likely to be slower and lead to trouble as it triggers at least one
  // document relayout. However, **this mode does not have a set rule limit.** Therefore, it can be
  // used as a last resort by the end user if they can't fix the "max show rule depth exceeded error".
  //
  // Enabling this mode is as simple as using `#show: e.stateful.toggle(true)` at the beginning of the
  // document. This will trigger a compatibility behavior where existing set rules will push to the
  // state, even if they're not in the stateful mode. It will also push existing set rule data into
  // the style 'state()'. Therefore, existing set rules are compatible with stateful mode, but this
  // only effectively fixes the error if the set rules are individually switched to stateful mode
  // with `e.stateful.set_` instead of `e.set_`.
  stateful: 2
)

// When on stateful mode, this state holds the sequence of 'data' for each scope.
// The last element on the list is the "current" data.
#let style-state = state("__elembic_element_state", ())

// Default library-wide data.
#let default-global-data = (
  (global-data-key): true,

  // Keep track of versions in case we need some backwards-compatibility behavior
  // in the future.
  version: element-version,

  // If the style state should be read by set rules as the user has
  // enabled stateful mode with `#shoW: e.stateful.toggle(true)`.
  stateful: false,

  // First known bib title.
  // This is used by leaky mode to attempt to preserve the correct bibliography.title
  // property. Evidently, it's not perfect, and leaky mode should be avoided.
  first-bib-title: (),

  // How many 'where rules' have been applied so far to all
  // elements. This is needed as, for each 'where rule', we have
  // to apply a unique label to matching elements, so we increase
  // this 'counter' by one each time.
  where-rule-count: 0,

  // Per-element data (set rules and other style chain info).
  elements: (:)
)

// Default per-element data.
#let default-data = (
  (element-data-key): true,

  version: element-version,

  // Chain for foldable fields, that is, fields which have special behavior
  // when changed through more than one set rule. By default, specifying the
  // same field in two subsequent set rules will have the innermost set rule
  // override the value from the previous one, but this can be overridden
  // for certain types where it makes sense to combine the two values in
  // some way instead. For example, stroke fields have custom folding: if
  // you specify 4pt for a stroke field in one set rule and orange in another,
  // the final stroke will be 4pt + orange, not orange.
  //
  // This data structure has an entry for each changed foldable field, laid out as follows:
  // (
  //   foldable-field-name: (
  //     folder: auto or (outer, inner) => combined value  // how to combine two values, auto = simple sum, equivalent to (a, b) => a + b
  //     default: stroke(),  // default value for this field to begin folding. This is 'field.default' unless 'required = true'.
  //                         // Then, it is the type's default.
  //     values: (4pt, orange, ...)  // list of all set values for this field (length = amount of times this field was changed)
  //                                 // only 'values' is used if possible, for efficiency. E.g.: values.sum(default: stroke())
  //     data: (                                   // list to associate each value with the real style chain index and name.
  //       (index: 3, name: none, value: 4pt),     // If 'revoke' or 'reset' are used, this list is used instead
  //       (index: 5, name: none, value: orange),  // so we can know which values were revoked.
  //       ...
  //     )
  //   ),
  //   ...
  // )
  //
  // The final argument passed to the constructor, if any, also has to be folded with the latest folded value,
  // or with the field's default value if nothing was changed. However, that step is done separately. So, if
  // no set rules change a particular foldable field, it is not present in this dictionary at all.
  fold-chain: (:),

  // The current accumulated styles (overridden values for arguments) for the element.
  chain: (),

  // Maps each style in the chain to some data.
  // This is used to assign names to styles, so they can be revoked later.
  data-chain: (),

  // All known names, so we can be aware of invalid revoke rules.
  names: (:),

  // List of active revokes, of the form:
  // (index: last-chain-index, revoking: name-revoked, name: none / name of the revoke itself)
  revoke-chain: ()
)

/// This is meant to be used in a show rule of the form `#show ref: e.ref` to ensure
/// references to custom elements work properly.
///
/// Please use [`e.prepare`](#eprepare) as it does that automatically, and more if
/// necessary.
///
/// - args (arguments): ref and extra arguments
/// -> content
#let ref_(..args) = {
  assert(args.pos().len() > 0, message: "element.ref: expected at least one positional argument (reference or label)")
  let first-arg = args.pos().first()

  set ref(..args.named())
  show ref: it => {
    if (
      it.element == none
      or it.element.has("label") and str(it.element.label).starts-with(lbl-ref-figure-label-head)
      or type(it.target) != label
    ) {
      // This is known to be a reference to a custom element
      // (or the target is not something we can deal with, i.e. not a label)
      return it
    }

    let info = data(it.element)
    if type(info) == dictionary and "data-kind" in info and info.data-kind == "element-instance" {
      let supplement = if it.has("supplement") and it.supplement != none {
        (supplement: it.supplement)
      } else {
        (:)
      }

      // Convert into a reference towards the reference figure
      let converted-label = label(lbl-ref-figure-label-head + str(it.target))
      let reference = ref(converted-label, ..supplement)

      if "custom-ref" in info and info.custom-ref != none {
        show ref.where(target: converted-label): [#info.custom-ref]

        reference
      } else {
        reference
      }
    } else {
      it
    }
  }

  if type(first-arg) == content and first-arg.func() == ref {
    first-arg
  } else {
    ref(..args)
  }
}

// Changes stateful mode settings within a certain scope.
// This function will sync all data between all modes (data from normal mode
// goes to state and data from stateful mode goes to normal mode).
//
// Setting it to 'true' tells all set rules to update the state, and also ensures
// getters retrieve the value from the state, even if not explicitly aware of
// stateful mode.
//
// By default, this function will not trigger any changes if one attempts to
// change the stateful mode to its current value. This behavior can be disabled
// with 'force: true', though that is not expected to make a difference in any way.
#let toggle-stateful-mode(enable, force: false) = doc => {
  context {
    let previous-bib-title = bibliography.title
    [#context {
      let (global-data, was-first-bib-title) = if (
        type(bibliography.title) == content
        and bibliography.title.func() == metadata
        and bibliography.title.at("label", default: none) == lbl-data-metadata
      ) {
        (bibliography.title.value, false)
      } else {
        ((..default-global-data, first-bib-title: previous-bib-title), true)
      }

      set bibliography(title: previous-bib-title)

      if global-data.stateful != enable or force {
        if not enable {
          // Enabling stateful mode => use data from the style chain
          //
          // Disabling stateful mode => need to sync stateful with non-stateful,
          // so we use data from the state
          let chain = style-state.get()
          global-data = if chain == () {
            default-global-data
          } else {
            chain.last()
          }

          // Store the first known bib title in the state as well
          if global-data.first-bib-title == () and was-first-bib-title {
            global-data.first-bib-title = previous-bib-title
          }
        }

        // Notify both modes about it (non-stateful and stateful)
        global-data.stateful = enable

        let (show-normal, show-stateful) = if enable {
          // TODO: Have a way to keep track of previous toggles and undo them
          (none, it => it.value.body)
        } else {
          (it => it.value.body, none)
        }

        show lbl-auto-mode: none
        show lbl-normal-mode: show-normal
        show lbl-stateful-mode: show-stateful

        // Sync data with style chain for non-stateful modes
        show lbl-get: set bibliography(title: [#metadata(global-data)#lbl-data-metadata])

        // Sync data with state for stateful mode
        // Push at the start of the scope, pop at the end
        [#style-state.update(chain => {
          chain.push(global-data)
          chain
        })#doc#style-state.update(chain => {
          _ = chain.pop()
          chain
        })]
      } else {
        // Nothing to do: it is already toggled to this value
        doc
      }
    }#lbl-get]
  }
}

/// Prepare a selector similar to 'element.where(..args)'
/// which can be used in "show sel: set". Receives a filter
/// generated by'element.with(fields)' or '(element-data.where)(fields)'.
///
/// This works by applying a show rule to all element instances and,
/// if they match, they receive a unique label to be matched
/// by that selector. The selector is then provided to the callback function.
///
/// Each requested selector is passed as a separate parameter to the callback.
/// You must wrap the remainder of the document that depends on those selectors
/// in this callback.
///
/// USAGE:
///
/// ```typ
/// #e.select(superbox.with(fill: red), superbox.with(width: auto), (red-superbox, auto-superbox) => {
///   // Hide superboxes with red fill or auto width
///   show red-superbox: none
///   show auto-superbox: none
///
///   // This one is hidden
///   #superbox(fill: red)
///
///   // This one is hidden
///   #superbox(width: auto)
///
///   // This one is kept
///   #superbox(fill: green, width: 5pt)
/// })
/// ```
///
/// - args (function): filters in the format 'element.with(field-a: a, field-b: b)'. Note that you must write fields' names even if they are positional.
/// - receiver (function): receives one requested selector per filter as separate arguments, must return content.
/// -> content
#let select(..args, receiver) = {
  assert(args.named() == (:), message: "element.select: unexpected named arguments")
  assert(type(receiver) == function, message: "element.select: last argument must be a function receiving each prepared selector as a separate argument")

  let filters = args.pos()

  // (eid: ((index, filter), ...))
  // The idea is to apply all filters for a given eid at once
  let filters-by-eid = (:)
  // (eid: sel)
  let labels-by-eid = (:)
  let ordered-eids = ()

  let i = 0
  for filter in filters {
    if type(filter) == function {
      filter = filter(__elembic_data: special-data-values.get-where)
    }

    if type(filter) != dictionary or filter-key not in filter {
      if type(filter) == selector {
        assert(false, message: "element.select: Typst-native selectors cannot be specified here, only those of custom elements")
      }
      assert(false, message: "element.select: expected a valid filter, such as 'custom-element' or 'custom-element.with(field-name: value, ...)', got " + base.typename(filter))
    }

    if "eid" in filter {
      if "sel" not in filter {
        assert(false, message: "element.select: filter did not have the element's selector")
      }
      if filter.eid in labels-by-eid and labels-by-eid.at(filter.eid) != filter.sel {
        assert(false, message: "element.select: filter had a different selector from the others for the same element ID, check if you're not using conflicting library versions (could also be a bug)")
      } else if filter.eid not in labels-by-eid {
        labels-by-eid.insert(filter.eid, filter.sel)
      }

      if filter.eid in filters-by-eid {
        filters-by-eid.at(filter.eid).push((i, filter))
      } else {
        filters-by-eid.insert(filter.eid, ((i, filter),))
        ordered-eids.push(filter.eid)
      }
    } else {
      assert(false, message: "element.select: non-element-specific filters are not supported yet\n  hint: try removing this filter: " + repr(filter))
    }
    i += 1
  }

  context {
    let previous-bib-title = bibliography.title
    [#context {
      let global-data = if (
        type(bibliography.title) == content
        and bibliography.title.func() == metadata
        and bibliography.title.at("label", default: none) == lbl-data-metadata
      ) {
        bibliography.title.value
      } else {
        (..default-global-data, first-bib-title: previous-bib-title)
      }

      if global-data.stateful {
        let chain = style-state.get()
        global-data = if chain == () {
          default-global-data
        } else {
          chain.last()
        }
      }

      // Amount of 'where rules' so far, so we can
      // assign a unique number to each query
      let rule-counter = global-data.where-rule-count

      // Generate labels by counting up, and update counter
      let matching-labels = range(0, filters.len()).map(i => label(lbl-global-where-head + str(rule-counter + i)))
      rule-counter += matching-labels.len()
      global-data.where-rule-count = rule-counter

      // Provide labels to the body, one per filter
      // These labels only match the shown bodies of
      // elements with matching field values
      let body = receiver(..matching-labels)

      // Apply show rules to the body to add labels to matching elements
      let styled-body = ordered-eids.fold(body, (acc, eid) => {
        let filters = filters-by-eid.at(eid)
        show labels-by-eid.at(eid): it => {
          let data = data(it)
          let tag = [#metadata(data)#lbl-tag]
          let fields = data.fields

          let labeled-it = it
          for (i, filter) in filters {
            // Check if all positional and named arguments match
            if type(fields) == dictionary and filter.fields.pairs().all(((k, v)) => k in fields and fields.at(k) == v) {
              // Add corresponding label and preserve tag so 'data(it)' still works
              labeled-it = [#[#labeled-it#tag]#matching-labels.at(i)]
            }
          }

          labeled-it
        }

        acc
      })

      set bibliography(title: previous-bib-title)

      // Increase where rule counter for further where rules
      if global-data.stateful {
        style-state.update(chain => {
          chain.push(global-data)
          chain
        })

        styled-body

        style-state.update(chain => {
          _ = chain.pop()
          chain
        })
      } else {
        show lbl-get: set bibliography(title: [#metadata(global-data)#lbl-data-metadata])
        styled-body
      }
    }#lbl-get]
  }
}

// Apply set and revoke rules to the current per-element data.
#let apply-rules(data, rules) = {
  for rule in rules {
    let kind = rule.kind
    if kind == "set" {
      let (element, args) = rule
      let (eid, default-data, fields) = element
      if eid in data {
        data.at(eid).chain.push(args)
      } else {
        data.insert(eid, (..default-data, chain: (args,)))
      }

      if rule.name != none {
        let element-data = data.at(eid)
        let index = element-data.chain.len() - 1

        // Lazily fill the data chain with 'none'
        data.at(eid).data-chain += (none,) * (index - element-data.data-chain.len())
        data.at(eid).data-chain.push((kind: "set", name: rule.name))
        data.at(eid).names.insert(rule.name, true)
      }

      if fields.foldable-fields != (:) and args.keys().any(n => n in fields.foldable-fields) {
        // A foldable field was specified in this set rule, so we need to record the fold
        // data in the corresponding data structures separately for later.
        let element-data = data.at(eid)
        let index = element-data.chain.len() - 1
        for (field-name, fold-data) in fields.foldable-fields {
          if field-name in args {
            let value = args.at(field-name)
            let value-data = (index: index, name: rule.name, value: value)
            if field-name in element-data.fold-chain {
              data.at(eid).fold-chain.at(field-name).values.push(value)
              data.at(eid).fold-chain.at(field-name).data.push(value-data)
            } else {
              data.at(eid).fold-chain.insert(
                field-name,
                (
                  folder: fold-data.folder,
                  default: fold-data.default,
                  values: (value,),
                  data: (value-data,)
                )
              )
            }
          }
        }
      }
    } else if kind == "revoke" {
      for (name, _) in data {
        // Can only revoke what's before us.
        // If this element has no rules with this name, there is nothing to revoke;
        // we shouldn't revoke names that come after us (inner rules).
        // Note that this potentially includes named revokes as well.
        if rule.revoking in data.at(name).names {
          data.at(name).revoke-chain.push((kind: "revoke", name: rule.name, index: data.at(name).chain.len(), revoking: rule.revoking))

          if rule.name != none {
            data.at(name).names.insert(rule.name, true)
          }
        }
      }
    } else if kind == "reset" {
      // Whether the list of elements that this reset applies to is restricted.
      let filtering = rule.eids != ()
      for (name, element-data) in data {
        // Can only revoke what's before us.
        // If this element has no rules, no need to add a reset.
        if (not filtering or name in rule.eids) and element-data.chain != () {
          data.at(name).revoke-chain.push((kind: "reset", name: rule.name, index: element-data.chain.len()))

          if rule.name != none {
            data.at(name).names.insert(rule.name, true)
          }
        }
      }
    } else {
      assert(false, message: "element: invalid rule kind '" + rule.kind + "'")
    }
  }

  data
}

// Prepare rule(s), returning a function `doc => ...` to be used in
// `#show: rule`. The rule is attached as metadata to the returned
// content so it can still be accessed outside of a show rule.
//
// This is where we execute our main machinery to apply rules to the
// document, that is, modifications to the global data of custom
// elements. This is done in different ways depending on the mode:
//
// - In normal mode, we create 'get rule' points by annotating
// context blocks with `#lbl-get`. Any modifications to the global
// data are stored as 'set bibliography(title: metadata with data)'
// scoped to context blocks with that label. Therefore, we can access
// the data by retrieving bibliography.title inside those blocks.
//
// The downside is that the entire document is wrapped in context,
// so 'max show rule depth exceeded' errors can occur.
//
// - In leaky mode, it is similar, but we reset bibliography.title
// to an arbitrary value instead of having two context blocks to
// ensure it remains unchanged.
//
// - In stateful mode, we don't wrap anything around the document,
// removing the 'max show rule depth exceeded' problem. Rather, we
// place a state update at the start and another at the end of the
// scope, respectively updating the global data and then undoing
// the update, ensuring it only applies to that scope.
//
// The downside is that this uses 'state()', which can lead to
// relayouts (slower) and even diverging layout.
#let prepare-rule(rule) = {
  let rules = if rule.kind == "apply" { rule.rules } else { (rule,) }

  doc => {
    let rule = rule
    let rules = rules
    let mode = rule.mode

    // If there are two 'show:' in a row, flatten into a single set of rules
    // instead of running this function multiple times, reducing the
    // probability of accidental nested function limit errors.
    //
    // Note that all rules replace the document with
    // [#context { ... doc .. }[#metadata(doc: doc, rule: rule)#lbl-rule-tag]]
    // We get the second child to extract the original rule information.
    // If 'doc' has the form above, this means the user wrote
    // #show: rule1
    // #show: rule2
    // which we want to unify. So we check children len == 2 and unify if the tag is there.
    //
    // But we also want to accept some parbreaks before, i.e.
    //
    // #show: rule1
    //
    // #show: rule2
    //
    // This generates a doc of the form
    // [#parbreak()[#context { ... doc .. }[#metadata(doc: doc, rule: rule)#lbl-rule-tag]]]
    // So we also check for children len >= 2 (although == 2 is enough in that case) and
    // strip any leading parbreaks / spaces / linebreaks, moving them to the new 'doc' (they
    // now receive the rules, which is technically incorrect, but in practice is only a problem
    // if you have a show rule on parbreak or space or something, which is odd).
    //
    // Note also that
    // #show: rule1
    //
    // // hello world!
    // // hello world!
    // // hello world!
    //
    // #show: rule2
    //
    // produces
    // [#parbreak()#space()#space()#parbreak()[... rule substructure with metadata... ]]
    // which makes the need for stripping multiple kinds of whitespace explicit.
    // We limit at 100 to prevent unbounded search.
    //
    // We also need to consider the case with
    // #show: rule1
    // #set native(field: value)
    // #show: rule2
    //
    // in which case the document structure (from rule1's view) is
    //
    // styled(child: [... rule2 ...], styles: ..)
    //
    // Worse, there could be parbreaks around the set rule:
    //
    // #show: rule1
    //
    // #set native(field: value)
    //
    // #show: rule2
    //
    // leading to
    //
    // sequence(parbreak(), styled(child: sequence(parbreak(), [ ... rule2 ... ]), styles: ..))
    //
    // so we need to perform a document tree walk to lift rule2 and transform this into
    //
    // #show: apply(
    //   rule1
    //   rule2
    // )
    //
    // #set native(field: value)
    // ...
    //
    // Tree walk is performed as follows:
    //
    // this rule
    //   \
    //   sequence
    //      \ space  parbreak ... sequence
    //                              \ space parbreak ... styled (styles = S)
    //                                                       \ sequence
    //                                                             \ space parbreak ... inner rule!
    //                                                                                    \ (rule.doc, rule.rule)
    // We store each tree level in 'wrappers' so we can reconstruct this document structure without 'rule!'.
    // In the case above, that would correspond to
    // wrappers = ((sequence, (space, parbreak, ...)), (sequence, space, parbreak, ...), (styled, S), (sequence, space, parbreak, ...))
    // and 'rule' would become 'potential-doc'.
    //
    // We would then wrap 'rule.doc' in reverse order, adding after the sequence prefix or
    // making it the styled child, producing
    //
    // this rule + inner rule
    //   \
    //   (sequence,     apply(this rule, inner rule))
    //      \ space  parbreak ... sequence
    //                              \ space parbreak ... styled (styles = S)
    //                                                       \ sequence
    //                                                             \ space parbreak ... rule.doc
    //
    // as desired. That is, we move the inner rule up into this rule in order to only consume 1 from
    // the rule limit, which is valid since the rule won't apply to spaces, parbreaks, and styled.
    // Of course, there could be show rules towards a different structure, but we assume that the user
    // understands that show rules on spacing may cause unexpected behavior.
    let potential-doc = [#doc]
    let wrappers = ()
    let max-depth = 150
    // Acceptable content types for set rule lifting.
    // These are content types that are leaves and we usually don't expect them to
    // be replaced in a show rule by an actual custom element.
    // If we find something that isn't here, e.g. a block, we stop searching as we can't lift any further rules.
    // We also exclude anything with a label since that indicates there might be a show rule application incoming.
    let whitespace-funcs = (parbreak, space, linebreak, h, v, state-update-func, counter-update-func)
    // Content types we can peek at.
    let recursing-funcs = (styled, sequence)
    let loop-prefix = none
    let loop-children = ()
    let loop-last = none

    while max-depth > 0 {
      // Child is #{
      //    set something(abc: def)
      //    show something: else
      //    [some stuff]
      // }
      if potential-doc.func() == styled {
        max-depth -= 1
        wrappers.push((styled, potential-doc.styles))

        // 'Recursively' check the child
        potential-doc = [#potential-doc.child]
      } else if (
        // Child is #[
        //   (parbreak)
        //   (space)
        //   #[ sequence, rule or more styles ]
        // ]
        potential-doc.func() == sequence
        and { loop-children = potential-doc.children; loop-children.len() >= 2 }  // something like 'if let Sequence(children) = potential-doc { ... }'
        and { loop-last = loop-children.last(); loop-last.func() in recursing-funcs }
        and max-depth - loop-children.len() > 0
        and {
          loop-prefix = loop-children.slice(0, -1);
          loop-prefix.all(t => (t.func() in whitespace-funcs or t == []) and t.at("label", default: none) == none)
        }
      ) {
        max-depth -= loop-children.len()
        wrappers.push((sequence, loop-prefix))

        // 'Recursively' check the last child
        potential-doc = loop-last
      } else {
        break
      }
    }

    // Merge with the closest rule application below us, "moving" it upwards
    // and reducing the rule count by 1
    if (
      potential-doc.func() == sequence
      and potential-doc.children.len() == 2
      and potential-doc.children.last().at("label", default: none) == lbl-rule-tag
    ) {
      let last = potential-doc.children.last()
      let inner-rule = last.value.rule

      // Process all rules below us together with this one
      if inner-rule.kind == "apply" {
        // Note: apply should automatically distribute modes across its children,
        // so it's okay if we don't inherit its own mode here.
        rules += inner-rule.rules
      } else {
        rules.push(inner-rule)
      }

      // We assume 'apply' already checked its own rules.
      // Therefore, we only need to fold a single time.
      // Don't check all rules every time again.
      if (
        inner-rule.mode == style-modes.stateful
        or mode != style-modes.stateful and inner-rule.mode == style-modes.leaky
        or mode == auto
      ) {
        // Prioritize more explicit modes:
        // stateful > leaky > normal
        mode = inner-rule.mode
      }

      // Convert this into an 'apply' rule
      rule = ((prepared-rule-key): true, version: element-version, kind: "apply", rules: rules, mode: mode)

      // Place what's inside, don't place the context block that would run our code again
      doc = last.value.doc

      // Reconstruct the document structure.
      // Must be in reverse (innermost wrapper to outermost).
      for (func, data) in wrappers.rev() {
        if func == styled {
          doc = styled(doc, data)
        } else {
          // (sequence, prefix)
          // Re-add stripped whitespace and stuff
          doc = data.join() + doc
        }
      }
    }

    // Stateful mode: no context, just push in a state at the start of the scope
    // and pop to previous data at the end.
    let stateful = {
      style-state.update(chain => {
        let global-data = if chain == () {
          default-global-data
        } else {
          chain.last()
        }

        assert(
          global-data.stateful,
          message: "element rule: cannot use a stateful rule without enabling the global stateful toggle\n  hint: write '#show: e.stateful.toggle(true)' somewhere above this rule, or at the top of the document to apply to all"
        )

        global-data.elements = apply-rules(global-data.elements, rules)

        chain.push(global-data)
        chain
      })
      doc
      style-state.update(chain => {
        _ = chain.pop()
        chain
      })
    }

    // Normal mode: two nested contexts: one retrieves the current bibliography title,
    // and the other retrieves the title with metadata and restores the current title.
    let normal = context {
      let previous-bib-title = bibliography.title
      [#context {
        let global-data = if (
          type(bibliography.title) == content
          and bibliography.title.func() == metadata
          and bibliography.title.at("label", default: none) == lbl-data-metadata
        ) {
          bibliography.title.value
        } else {
          (..default-global-data, first-bib-title: previous-bib-title)
        }

        if global-data.stateful {
          if mode == auto {
            // User chose something else.
            // Don't even place anything.
            return none
          } else {
            // Use state instead!
            return {
              set bibliography(title: previous-bib-title)
              stateful
            }
          }
        }

        global-data.elements = apply-rules(global-data.elements, rules)

        set bibliography(title: previous-bib-title)
        show lbl-get: set bibliography(title: [#metadata(global-data)#lbl-data-metadata])
        doc
      }#lbl-get]
    }

    let body = if mode == auto {
      // Allow user to pick the mode through show rules.
      // Note: picking leaky mode has no effect on show rule depth, so we don't allow choosing
      // it globally. For it to make a difference, it must be explicitly chosen.
      [#metadata((body: stateful))#lbl-stateful-mode]
      [#metadata((body: normal))#lbl-normal-mode]
      [#normal#lbl-auto-mode]
    } else if mode == style-modes.normal {
      normal
    } else if mode == style-modes.leaky {
      [#context {
        let global-data = if (
          type(bibliography.title) == content
          and bibliography.title.func() == metadata
          and bibliography.title.at("label", default: none) == lbl-data-metadata
        ) {
          bibliography.title.value
        } else {
          // Bibliography title wasn't overridden, so we can use it
          (..default-global-data, first-bib-title: bibliography.title)
        }

        let first-bib-title = global-data.first-bib-title
        if first-bib-title == () {
          // Nobody has seen the bibliography title (bug?)
          first-bib-title = auto
        }

        if global-data.stateful {
          if mode == auto {
            // User chose something else.
            // Don't even place anything.
            return none
          } else {
            // Use state instead!
            return {
              set bibliography(title: first-bib-title)
              stateful
            }
          }
        }

        global-data.elements = apply-rules(global-data.elements, rules)

        set bibliography(title: first-bib-title)
        show lbl-get: set bibliography(title: [#metadata(global-data)#lbl-data-metadata])
        doc
      }#lbl-get]
    } else if mode == style-modes.stateful {
      stateful
    } else {
      panic("element rule: unknown mode: " + repr(mode))
    }

    // Add the rule tag after each rule application.
    // This allows extracting information about the rule before it is applied.
    // It also allows combining the rule with an outer rule before application,
    // as we do earlier.
    [#body#metadata((doc: doc, rule: rule))#lbl-rule-tag]
  }
}

/// Apply a set rule to a custom element. Check out the Styling guide for more information.
///
/// Note that this function only accepts non-required fields (that have a `default`).
/// Any required fields must always be specified at call site and, as such, are always
/// be prioritized, so it is pointless to have set rules for those.
///
/// Keep in mind the limitations when using set rules, as well as revoke, reset and
/// apply rules.
///
/// As such, when applying many set rules at once, please use `e.apply` instead
/// (or specify them consecutively so `elembic` does that automatically).
///
/// USAGE:
///
/// ```typ
/// #show: e.set_(superbox, fill: red)
/// #show: e.set_(superbox, optional-pos-arg1, optional-pos-arg2)
///
/// // This call will be equivalent to:
/// // #superbox(required-arg, optional-pos-arg1, optional-pos-arg2, fill: red)
/// #superbox(required-arg)
/// ```
///
/// - elem (function): element to apply the set rule on
/// - fields (arguments): optional fields to set (positionally or named, depending on the field)
/// -> function
#let set_(elem, ..fields) = {
  if type(elem) == function {
    elem = data(elem)
  }
  assert(type(elem) == dictionary, message: "element.set_: please specify the element's constructor or data in the first parameter")
  let args = (elem.parse-args)(fields, include-required: false)

  prepare-rule(
    ((prepared-rule-key): true, version: element-version, kind: "set", name: none, mode: auto, element: (eid: elem.eid, default-data: elem.default-data, fields: elem.fields), args: args)
  )
}

/// Apply multiple rules (set rules, etc.) at once.
///
/// These rules do not count towards the "set rule limit" observed in 'Limitations';
/// `apply` itself will always count as a single rule regardless of the amount of rules
/// inside it (be it 5, 50, or 500). Therefore,
/// **it is recommended to group rules together under `apply` whenever possible.**
///
/// Note that Elembic will automatically wrap consecutive rules (only whitespace
/// or native set/show rules inbetween) into a single `apply`, bringing the same benefit.
///
/// USAGE:
///
/// ```typ
/// #show: e.apply(
///   set_(elem, fields),
///   set_(elem, fields)
/// )
/// ```
///
/// - mode (int): style mode given by the `style-modes` dictionary
/// - args (arguments): rules to apply
/// -> function
#let apply(mode: auto, ..args) = {
  assert(args.named() == (:), message: "element.apply: unexpected named arguments")
  assert(mode == auto or mode == style-modes.normal or mode == style-modes.leaky or mode == style-modes.stateful, message: "element.apply: invalid mode, must be auto or e.style-modes.(normal / leaky / stateful)")

  let rules = args.pos().map(
    rule => {
      assert(type(rule) == function, message: "element.apply: invalid rule of type " + str(type(rule)) + ", please use 'set_' or some other function from this library to generate it")

      // Call it as if it we were in a show rule.
      // It will have some trailing metadata indicating its arguments.
      let inner = rule([])
      let rule-data = inner.children.last().value.rule

      if rule-data.kind == "apply" {
        // Flatten 'apply'
        rule-data.rules
      } else {
        (rule-data,)
      }
    }
  ).sum(default: ())

  if mode == auto {
    mode = rules.fold(auto, (mode, rule) => {
      if (
        rule.mode == style-modes.stateful
        or mode != style-modes.stateful and rule.mode == style-modes.leaky
        or mode == auto
      ) {
        // Prioritize more explicit modes:
        // stateful > leaky > normal
        rule.mode
      } else {
        mode
      }
    })
  }

  if mode != auto {
    rules = rules.map(r => r + (mode: mode))
  }

  // Set this apply rule's mode as an optimization, but note that we have forcefully altered
  // its children's modes above.
  prepare-rule(((prepared-rule-key): true, version: element-version, kind: "apply", rules: rules, mode: mode))
}

/// Name a certain rule. Use `e.apply` to name a group of rules.
/// This is used to be able to revoke the rule later with `e.revoke`.
///
/// Please note that, at the moment, each rule can only have
/// one name. This means that applying multiple `named` on
/// the same set of rules will simply replace the previous
/// names.
///
/// However, more than one rule can have the same name, allowing both to be
/// revoked at once if needed.
///
/// USAGE:
///
/// ```typ
/// #show: e.named(
///   "cool set",
///   e.set_(elem, fields)
/// )
/// ```
///
/// - name (str): The name to give to the rule.
/// - rule (function): The rule to apply this name to.
/// -> function
#let named(name, rule) = {
  assert(type(name) == str, message: "element.named: rule name must be a string, not " + str(type(name)))
  assert(name != "", message: "element.named: name must not be empty")
  assert(type(rule) == function, message: "element.named: this is not a valid rule (not a function), please use functions such as 'set_' to create one.")

  let rule = rule([]).children.last().value.rule
  if rule.kind == "apply" {
    let i = 0
    while i < rule.rules.len() {
      let inner-rule = rule.rules.at(i)
      assert(inner-rule.kind in ("set", "revoke", "reset"), message: "element.named: can only name set, revoke and reset rules at this moment, not '" + inner-rule.kind + "'")

      rule.rules.at(i).insert("name", name)

      i += 1
    }
  } else {
    assert(rule.kind in ("set", "revoke", "reset"), message: "element.named: can only name set, revoke and reset rules at this moment, not '" + rule.kind + "'")
    rule.insert("name", name)
  }

  // Re-prepare the rule
  prepare-rule(rule)
}

/// Revoke all rules with a certain name.
///
/// This is intended to be used in a specific scope,
/// and temporary. This means you are supposed to only revoke the rule
/// for a short portion of the document. If you wish to do the opposite,
/// that is, only apply the rule for a short portion for the document
/// (and have it never apply again afterwards), then please just scope
/// the set rule itself instead.
///
/// USAGE:
///
/// ```typ
/// #show: e.named("name", set_(element, fields))
/// ...
/// #[
///   #show: e.revoke("name")
///   // rule 'name' doesn't apply here
///   ...
/// ]
///
/// // Applies here again
/// ...
/// ```
///
/// - name (str): name of rules to be revoked
/// - mode (int): style mode given by the `style-modes` dictionary
/// -> function
#let revoke(name, mode: auto) = {
  assert(type(name) == str, message: "element.revoke: rule name must be a string, not " + str(type(name)))
  assert(mode == auto or mode == style-modes.normal or mode == style-modes.leaky or mode == style-modes.stateful, message: "element.revoke: invalid mode, must be auto or e.style-modes.(normal / leaky / stateful)")

  prepare-rule(((prepared-rule-key): true, version: element-version, kind: "revoke", revoking: name, name: none, mode: mode))
}

/// Temporarily revoke all active set rules for certain elements (or even all elements if none are specified).
/// Applies only to the current scope, like other rules.
///
/// USAGE:
///
/// ```typ
/// #show: e.set_(element, fill: red)
/// #[
///   // Revoke all previous set rules on 'element' for this scope
///   #show: e.reset(element)
///   #element[This is using the default fill (not red)]
/// ]
///
/// // Rules not revoked outside the scope
/// #element[This is using red fill]
/// ```
///
/// - args (arguments): elements whose rules should be reset, or none to reset all rules
/// - mode (int): style mode given by the `style-modes` dictionary
/// -> function
#let reset(..args, mode: auto) = {
  assert(args.named() == (:), message: "element.reset: unexpected named arguments")
  assert(mode == auto or mode == style-modes.normal or mode == style-modes.leaky or mode == style-modes.stateful, message: "element.reset: invalid mode, must be auto or e.style-modes.(normal / leaky / stateful)")

  let filters = args.pos().map(it => if type(it) == function { data(it) } else { x })
  assert(filters.all(x => type(x) == dictionary and "eid" in x), message: "element.reset: invalid arguments, please provide a function or element data with at least an 'eid'")

  prepare-rule(((prepared-rule-key): true, version: element-version, kind: "reset", eids: filters.map(x => x.eid), name: none, mode: mode))
}

// Stateful variants
#let stateful-set(..args) = {
  apply(set_(..args), mode: style-modes.stateful)
}
#let stateful-apply = apply.with(mode: style-modes.stateful)
#let stateful-revoke = revoke.with(mode: style-modes.stateful)
#let stateful-reset = reset.with(mode: style-modes.stateful)

// Leaky variants
#let leaky-set(..args) = {
  apply(set_(..args), mode: style-modes.leaky)
}
#let leaky-apply = apply.with(mode: style-modes.leaky)
#let leaky-revoke = revoke.with(mode: style-modes.leaky)
#let leaky-reset = reset.with(mode: style-modes.leaky)

// Apply revokes and other modifications to the chain and generate a final set
// of fields.
#let fold-styles(chain, data-chain, revoke-chain, fold-chain) = {
  // Map name -> up to which index (exclusive) it is revoked.
  //
  // Importantly, a revoke at index B will apply to
  // all rules with the revoked name before that index.
  // If that revoke rule is, itself, revoked, that either
  // completely eliminates the name from being revoked,
  // or it simply leads the name to be revoked up to
  // an index A < B. That, or it was also being revoked
  // by another unrevoked revoke rule at index C > B,
  // in which case the name is still revoked up to C.
  // In all cases, the name is always revoked from the
  // start until some end index. Otherwise, it isn't
  // revoked at all (end index 0).
  let active-revokes = (:)

  let first-active-index = 0

  // Revoke revoked revokes by analyzing revokes in reverse
  // order: a revoke that came later always takes priority.
  for revoke in revoke-chain.rev() {
    // This revoke will revoke rules named 'revoking' up to 'index' in the chain, which
    // automatically revokes revoke rules before it as well, since they were added when
    // the chain length was smaller (or the same), and 'index' is always the chain length
    // at the moment the revoke rule was added.
    //
    // We don't explicitly add revoke rules to the chain as their order in the revoke-chain
    // list is enough to know which revoke rules can revoke others, and the index indicates
    // which set rules are revoked.
    //
    // Regarding the first part of the AND, note that, if a name is already revoked up to
    // index C from a later revoke (since we're going in reverse, so this one appears earlier
    // than the previous ones), then revoking it up to index B <= C for this revoke is
    // unnecessary since the index interval [0, B) is already contained in [0, C).
    //
    // In other words, only the last revoke for a particular name matters, which is the
    // first one we find in this loop.
    //
    // (As you can see, we assume above that, if revoke 1 comes before revoke 2 in the revoke-chain
    // (before reversing), with revoke 1 applying up to chain index B and revoke 2 up to index C,
    // then B <= C. This is enforced in 'prepare-rules' as we analyze revokes and push their
    // information to the chain in order (outer to inner / earlier to later).)
    if revoke.kind == "revoke" and revoke.revoking not in active-revokes and (revoke.name == none or revoke.name not in active-revokes) {
      active-revokes.insert(revoke.revoking, revoke.index)
    } else if revoke.kind == "reset" and (revoke.name == none or revoke.name not in active-revokes) {
      // Applying a reset, so we delete everything before this index and stop revoking since
      // any revokes before this reset won't count anymore.
      first-active-index = revoke.index

      chain = if chain.len() <= first-active-index {
        ()
      } else {
        chain.slice(first-active-index)
      }

      data-chain = if data-chain.len() <= first-active-index {
        ()
      } else {
        data-chain.slice(first-active-index)
      }

      for (field-name, fold-data) in fold-chain {
        let first-fold-index = fold-data.data.position(d => d.index >= first-active-index)
        if first-fold-index == none {
          // All folded values removed.
          // The caller will be responsible for joining the default value with the
          // final arguments (without any chain values inbetween) if that's necessary.
          _ = fold-chain.remove(field-name)
        } else {
          fold-chain.at(field-name).values = fold-data.values.slice(first-fold-index)
          fold-chain.at(field-name).data = fold-data.data.slice(first-fold-index)
        }
      }

      // No need to analyze any further revoke rules since everything was reset.
      break
    }
  }

  if active-revokes != (:) {
    let i = first-active-index
    for data in data-chain {
      if data != none and data.name in active-revokes and i < active-revokes.at(data.name) {
        // Nullify changes at this stage
        chain.at(i) = (:)
      }

      i += 1
    }

    for (field-name, fold-data) in fold-chain {
      let filtered-data = fold-data.data.filter(d => d.name == none or d.name not in active-revokes or d.index >= active-revokes.at(d.name))
      if filtered-data == () {
        _ = fold-chain.remove(field-name)
      } else {
        fold-chain.at(field-name).data = filtered-data
        fold-chain.at(field-name).values = filtered-data.map(d => d.value)
      }
    }
  }

  let final-values = chain.sum(default: (:))

  // Apply folds separately (their fields' values are meaningless in the above dict)
  for (field-name, fold-data) in fold-chain {
    final-values.at(field-name) = if fold-data.values == () {
      fold-data.default
    } else if fold-data.folder == auto {
      fold-data.default + fold-data.values.sum()
    } else {
      fold-data.values.fold(fold-data.default, fold-data.folder)
    }
  }

  final-values
}

// Retrieves the final chain data for an element, after applying all set rules so far.
#let get-styles(element, elements: (:)) = {
  if type(element) == function {
    element = data(element)
  }
  let (eid, default-fields) = if type(element) == dictionary and "eid" in element and "default-fields" in element {
    (element.eid, element.default-fields)
  } else {
    assert(false, message: "element.get: expected element (function / data dictionary), received " + str(type(element)))
  }

  let element-data = elements.at(eid, default: default-data)
  let folded-chain = if element-data.revoke-chain == default-data.revoke-chain and element-data.fold-chain == default-data.fold-chain {
    element-data.chain.sum(default: (:))
  } else {
    fold-styles(element-data.chain, element-data.data-chain, element-data.revoke-chain, element-data.fold-chain)
  }

  // No need to do extra folding like in constructor:
  // if a foldable field hasn't been specified, it is either equal to
  // its default, or it is a required field which has no default and
  // thus it is not returned here since it can't be set.
  default-fields + folded-chain
}

/// Reads the current values of element fields after applying set rules.
///
/// The callback receives a 'get' function which can be used to read the
/// values for a given element. The content returned by the function, which
/// depends on those values, is then placed into the document.
///
/// USAGE:
/// ```typ
/// #show: e.set_(elem, fill: green)
/// // ...
/// #e.get(get => {
///   // OK
///   assert(get(elem).fill == green)
/// })
/// ```
///
/// - receiver (function):
/// -> content
#let prepare-get(receiver) = context {
  let previous-bib-title = bibliography.title
  [#context {
    let global-data = if (
      type(bibliography.title) == content
      and bibliography.title.func() == metadata
      and bibliography.title.at("label", default: none) == lbl-data-metadata
    ) {
      bibliography.title.value
    } else {
      (..default-global-data, first-bib-title: previous-bib-title)
    }

    if global-data.stateful {
      let chain = style-state.get()
      global-data = if chain == () {
        default-global-data
      } else {
        chain.last()
      }
    }

    set bibliography(title: previous-bib-title)
    receiver(get-styles.with(elements: global-data.elements))
  }#lbl-get]
}

// Obtain a Typst selector to use to match this element in show rules or in the outline.
#let selector(elem, outline: false, outer: false) = {
  if outline {
    assert(not outer, message: "element.selector: cannot have 'outline: true' and 'outer: true' at the same time, please pick one selector")
    let elem-data = data(elem)
    assert("outline-sel" in elem-data, message: "element.selector: this isn't a valid element")
    assert(elem-data.outline-sel != none, message: "element.selector: this element isn't outlinable\n  hint: try asking its author to define it as such with 'outline: auto', 'outline: (caption: [...])' or 'outline: (caption: it => ...)'")
    elem-data.outline-sel
  } else if outer {
    data(elem).outer-sel
  } else {
    data(elem).sel
  }
}



/// Applies necessary show rules to the entire document so that custom elements behave
/// properly. This is usually only needed for elements which have custom references,
/// since, in that case, the document-wide rule `#show ref: e.ref` is required.
/// **It is recommended to always use `e.prepare` when using Elembic.**
///
/// However, **some custom elements also have their own `prepare` functions.** (Read
/// their documentation to know if that's the case.) Then, you may specify their functions
/// as parameters to this function, and this function will run the `prepare` function of
/// each element. Not specifying any elements will just run the default rules, which may
/// still be important.
///
/// As an example, an element may use its own `prepare` function to apply some special
/// behavior to its `outline`.
///
/// USAGE:
/// ```rs
/// // Apply default rules + special rules for these elements (if they need it)
/// #show: e.prepare(elemA, elemB)
///
/// // Apply default rules only
/// #show: e.prepare()
/// ```
/// - args (arguments): element functions which need special preparation, or none to just apply default rules
/// -> function
#let prepare(
  ..args
) = {
  assert(args.named() == (:), message: "element.prepare: unexpected named arguments")
  let default-rules = doc => {
    show ref: ref_

    doc
  }

  if args.pos() == () {
    return default-rules
  }

  let elems = args.pos().map(data)

  if elems.len() == 1 and type(args.pos().first()) == content {
    assert(false, message: "element.prepare: expected (optional) element functions as arguments, not the document\n  hint: write '#show: e.prepare()', not '#show: e.prepare' - note the parentheses")
  }

  assert(elems.all(it => it.data-kind == "element"), message: "element.prepare: positional arguments must be elements")
  let prepares = elems.filter(elem => "prepare" in elem and elem.prepare != none).map(elem => elem.prepare.with(elem.func))

  doc => {
    show: default-rules
    prepares.fold(doc, (acc, prepare) => prepare(acc))
  }
}

/// Creates a new element, returning its constructor. Read the "Creating custom elements"
/// chapter for more information.
///
/// USAGE:
///
/// ```typ
/// #import "@preview/elembic:X.X.X" as e: field
///
/// // For references to apply
/// #show: e.prepare()
///
/// #let elem = e.element.declare(
///   "elem",
///   prefix: "@preview/my-package,v1",
///   display: it => {
///     [== #it.title]
///     block(fill: it.fill)[#it.inner]
///   },
///   fields: (
///     field("fill", e.types.option(e.types.paint)),
///     field("inner", content, default: [Hello!]),
///     field("title", content, default: [Hello!]),
///   ),
///   reference: (
///     supplement: [Elem],
///     numbering: "1"
///   ),
///   outline: (caption: it => it.title),
/// )
///
/// #outline(target: e.selector(elem, outline: true))
///
/// #elem()
/// #elem(title: [abc], label: <abc>)
/// @abc
/// ```
///
/// - name (str): The element's name.
/// - prefix (str): The element's prefix, used to distinguish it from elements with the same name. This is usually your package's name alongside a (major) version.
/// - display (function): Function `fields => content` to display the element.
/// - fields (array): Array with this element's fields.
/// - parse-args (auto | function): Optional override for the built-in argument parser
/// (or `auto` to keep as is).  Must be in the form
/// `function(args, include-required: bool) => dictionary`, where `include-required: true`
/// means required fields are enforced (constructor), while `include-required: false` means
/// they are forbidden (set rules).
/// - typecheck (bool): Set to `false` to disable field typechecking.
/// - allow-unknown-fields (bool): Set to `true` to allow users to specify unknown
/// fields to your element. They are not typechecked and are simply forwarded to
/// the element's fields by the argument parser.
/// - template (none | function): Optional function displayed element => content to define overridable default set rules for your elements, such as paragraph settings. Users can override these settings with show-set rules on elements.
/// - prepare (none | function): Optional function (element, document) => content
/// to define show and set rules that should be applied to the whole document for your
/// element to properly function.
/// - construct (none | function): Optional function that overrides the default
/// element constructor, returning arbitrary content. This should be used over
/// manually wrapping the returned constructor as it ensures set rules and data
/// extraction from the constructor still work.
/// - scope (none | dictionary | module): Optional scope with associated data for your
/// element. This could be a module with constructors for associated elements, for
/// instance. This value can be accessed with `e.scope(elem)`, e.g.
/// `#import e.scope(elem): sub-elem`.
/// - count (none | function): Optional function `counter => (content | function fields => content)`
/// which inserts a counter step before the element. Ensures the element's display function has
/// updated context to get the latest counter value (after the step / update) with
/// `e.counter(it).get()`. Defaults to `counter.step` to step the counter once before
/// each element placed.
/// - labelable (bool): Defaults to `true`, allows specifying `#element(label: <abc>)`, which
/// not only ensures show rules on that label work and have access to the element's final fields,
/// but also allows referring to that element. When `false`, the element may have a field
/// named `label` instead, but it won't have these effects.
/// - reference (none | (supplement: none | str | content | function fields => str | content, numbering: none | str | function fields => str | function, custom: none | function fields => content)):
/// When not `none`, allows referring to the new element with Typst's built-in
/// `@ref` syntax. Requires the user to execute `#show: e.prepare()` at the top
/// of their document (it is part of the default rules, so `prepare` needs no
/// arguments there). Specify either a `supplement` and `numbering` for references
/// looking like "Name 2", and/or `custom` to show some fully customized content
/// for the reference instead.
/// - outline (none | auto | dictionary):
/// Accepts either `auto` or a dictionary of the form
/// `(caption: str | content | function fields => content)`.
/// When not `none`, allows creating an outline for the element's appearances
/// with `#outline(target: e.selector(elem, outline: true))`. When set to `auto`,
/// the entries will display "Name 2" based on reference information. When a caption
/// is specified, it will display as "Name 2: caption", unless supplement and numbering
/// for reference are both none.
/// - synthesize (none | function): Can be set to a function `fields => fields` to
/// override final values of fields, or create new fields based on final values of
/// fields, before the first show rule. When computing new fields based on other
/// fields, please specify those new fields in the fields array with
/// `synthesized: true`. This forbids the user from specifying them manually,
/// but allows them to filter based on that field.
/// - contextual (bool): When set to `true`, functions `fields => something` for
/// other options, including `display`, will be able to access the current
/// values of set rules with `(e.ctx(fields).get)(other-elem)`. In addition,
/// an additional context block is created, so that you may access the correct
/// values for `native-elem.field` in the context. In practice, this is a bit
/// expensive, and so this option shouldn't be enabled unless you need precisely
/// `bibliography.title`, or you really need to get set rule information from
/// other elements within functions such as `synthesize` or `display`.
/// -> function
#let declare(
  name,
  display: none,
  fields: none,
  prefix: none,
  parse-args: auto,
  typecheck: true,
  allow-unknown-fields: false,
  template: none,
  prepare: none,
  construct: none,
  scope: none,
  count: counter.step,
  labelable: true,
  reference: none,
  outline: none,
  synthesize: none,
  contextual: false,
) = {
  assert(type(display) == function, message: "element.declare: please specify a show rule in 'display:' to determine how your element is displayed.")

  let fields-hint = if type(fields) == dictionary { "\n  hint: check if you didn't forget to add a trailing comma for a single field: write 'fields: (field,)', not 'fields: (field)'" } else { "" }
  assert(type(fields) == array, message: "element.declare: please specify an array of fields, creating each field with the 'field' function. It can be empty with '()'." + fields-hint)
  assert(prefix != none, message: "element.declare: please specify a 'prefix: ...' for your type, to distinguish it from types with the same name. If you are writing a package or template to be used by others, please do not use an empty prefix.")
  assert(type(prefix) == str, message: "element.declare: the prefix must be a string, not '" + str(type(prefix)) + "'")
  assert(parse-args == auto or type(parse-args) == function, message: "element.declare: 'parse-args' must be either 'auto' (use built-in parser) or a function (default arg parser, fields: dictionary, typecheck: bool) => (user arguments, include-required: true (required fields must be specified - in constructor) / false (required fields must be omitted - in set rules)) => dictionary with parsed fields.")
  assert(type(typecheck) == bool, message: "element.declare: the 'typecheck' argument must be a boolean (true to enable typechecking, false to disable).")
  assert(type(allow-unknown-fields) == bool, message: "element.declare: the 'allow-unknown-fields' argument must be a boolean.")
  assert(template == none or type(template) == function, message: "element.declare: 'template' must be 'none' or a function displayed element => content (usually set rules applied on the displayed element). This is used to add a set of overridable set rules to the element, such as paragraph settings.")
  assert(prepare == none or type(prepare) == function, message: "element.declare: 'prepare' must be 'none' or a function (element, document) => styled document (used to apply show and set rules to the document).")
  assert(count == none or type(count) == function, message: "element.declare: 'count' must be 'none', a function counter => counter step/update element, or a function counter => final fields => counter step/update element.")
  assert(synthesize == none or type(synthesize) == function, message: "element.declare: 'synthesize' must be 'none' or a function element fields => element fields.")
  assert(contextual == auto or type(contextual) == bool, message: "element.declare: 'contextual' must be 'auto' (true if using a contextual feature) or a boolean (true to wrap the output in a 'context { ... }', false to not).")
  assert(construct == none or type(construct) == function, message: "element.declare: 'construct' must be 'none' (use default constructor) or a function receiving the original constructor and returning the new constructor.")
  assert(scope == none or type(scope) in (dictionary, module), message: "element.declare: 'scope' must be either 'none', a dictionary or a module")
  assert(type(labelable) == bool, message: "element.declare: 'labelable' must be a boolean (true to enable the special 'label' constructor argument, false to disable it)")
  assert(
    reference == none
    or type(reference) == dictionary
      and reference.keys().all(x => x in ("supplement", "numbering", "custom"))
      and ("supplement" not in reference or reference.supplement == none or type(reference.supplement) in (str, content, function))
      and ("numbering" not in reference or reference.numbering == none or type(reference.numbering) in (str, function))
      and ("custom" not in reference or reference.custom == none or type(reference.custom) == function),
    message: "element.declare: 'reference' must be 'none' or a dictionary (supplement: \"Name\" or [Name] or function fields => supplement, numbering: \"1.\" or function fields => (str / function numbers => content), custom (optional): none (default) or function fields => content)."
  )
  assert(
    reference == none or "supplement" in reference and "numbering" in reference or "custom" in reference,
    message: "element.declare: reference must either have 'custom', or have both 'supplement' and 'numbering' (or all three, though 'custom' has priority when displaying references)."
  )
  assert(
    outline == none
    or outline == auto
    or type(outline) == dictionary
      and "caption" in outline,
    message: "element.declare: 'outline' must be 'none', 'auto' (to use data from 'reference') or a dictionary with 'caption'."
  )
  assert(outline != auto or reference != none, message: "element.declare: if 'outline' is set to 'auto', 'reference' must be specified and not be 'none'.")
  assert(labelable or reference == none, message: "element.declare: 'labelable' must be true for 'reference' to not be 'none'")

  if contextual == auto {
    // Provide separate context for synthesize.
    // By default, assume it isn't needed.
    contextual = synthesize != none
  }

  let eid = base.unique-id("e", prefix, name)
  let lbl-show = label(lbl-show-head + eid)
  let lbl-outer = label(lbl-outer-head + eid)
  let ref-figure-kind = if reference == none and outline == none { none } else { lbl-ref-figure-kind-head + eid }
  // Use same counter as hidden figure for ease of use
  let counter-key = lbl-counter-head + eid
  let element-counter = counter(counter-key)
  let count = if count == none { none } else { count(element-counter) }
  let count-needs-fields = type(count) == function
  let custom-ref = if reference != none and "custom" in reference and type(reference.custom) == function { reference.custom } else { none }

  let supplement-type = if reference == none or "supplement" not in reference {
    none
  } else {
    type(reference.supplement)
  }
  let numbering-type = if reference == none or "numbering" not in reference {
    none
  } else {
    type(reference.numbering)
  }
  let caption-type = if outline == none or outline == auto {
    none
  } else {
    type(outline.caption)
  }

  let fields = field-internals.parse-fields(fields, allow-unknown-fields: allow-unknown-fields)
  let (all-fields, user-fields, foldable-fields) = fields

  if labelable and "label" in all-fields {
    assert(false, message: "element.declare: labelable element cannot have a conflicting 'label' field\n  hint: you can set 'labelable: false' to disable the special label parameter, but note that it will then be impossible to refer to your element")
  }

  let default-arg-parser = field-internals.generate-arg-parser(
    fields: fields,
    general-error-prefix: "element '" + name + "': ",
    field-error-prefix: field-name => "field '" + field-name + "' of element '" + name + "': ",
    typecheck: typecheck
  )

  let parse-args = if parse-args == auto {
    default-arg-parser
  } else {
    let parse-args = parse-args(default-arg-parser, fields: fields, typecheck: typecheck)
    if type(parse-args) != function {
      assert(false, message: "element.declare: 'parse-args', when specified as a function, receives the default arg parser alongside `fields: fields dictionary` and `typecheck: bool`, and must return a function (the new arg parser), and not " + base.typename(parse-args))
    }

    parse-args
  }

  let default-fields = fields.user-fields.values().map(f => if f.required { (:) } else { ((f.name): f.default) }).sum(default: (:))

  let set-rule = set_.with((parse-args: parse-args, eid: eid, default-data: default-data, fields: fields))

  let get-rule(receiver) = prepare-get(g => receiver(g((eid: eid, default-fields: default-fields))))

  // Prepare a filter which should be passed to 'select()'.
  // This function will specify which field values for this
  // element should be matched.
  let where(..args) = {
    assert(args.pos().len() == 0, message: "unexpected positional arguments\nhint: here, specify positional fields as named arguments, using their names")
    let args = args.named()

    if not allow-unknown-fields {
      // Note: 'where' on synthesized fields is legal,
      // so we check 'all-fields' rather than 'user-fields'.
      let unknown-fields = args.keys().filter(k => k not in all-fields and (not labelable or k != "label"))
      if unknown-fields != () {
        let s = if unknown-fields.len() == 1 { "" } else { "s" }
        assert(false, message: "element.where: element '" + name + "': unknown field" + s + " " + unknown-fields.map(f => "'" + f + "'").join(", "))
      }
    }

    ((filter-key): true, kind: "where", eid: eid, fields: args, sel: lbl-show)
  }

  let elem-data = (
    (element-key): true,
    version: element-version,
    name: name,
    eid: eid,
    scope: scope,
    set_: set-rule,
    get: get-rule,
    where: where,
    sel: lbl-show,
    outer-sel: lbl-outer,
    outline-sel: if outline == none { none } else { figure.where(kind: ref-figure-kind) },
    counter: element-counter,
    parse-args: parse-args,
    default-data: default-data,
    default-global-data: default-global-data,
    default-fields: default-fields,
    user-fields: user-fields,
    all-fields: all-fields,
    fields: fields,
    typecheck: typecheck,
    allow-unknown-fields: allow-unknown-fields,
    template: template,
    prepare: prepare,
    default-constructor: none,
    func: none,
  )

  // Figure placed for referencing to work.
  let ref-figure(tag, synthesized-fields, ref-label) = {
    let numbering = if numbering-type == str {
      reference.numbering
    } else if numbering-type == function {
      let numbering = (reference.numbering)(synthesized-fields)
      assert(type(numbering) in (str, function), message: "element: 'reference.numbering' must be a function fields => numbering (a string or a function), but returned " + str(type(numbering)))
      numbering
    } else {
      none
    }

    let number = if numbering == none { none } else { element-counter.display(numbering) }

    let caption = if caption-type == function {
      (caption: (outline.caption)(synthesized-fields))
    } else if caption-type in (str, content) {
      (caption: [#outline.caption])
    } else if outline == auto {
      if (
        "supplement" in reference and "numbering" in reference
        or "custom-ref" not in tag
        or tag.custom-ref == none
      ) {
        // Add some caption so it is displayed with the supplement and
        // number, but remove useless separator
        (caption: figure.caption(separator: "")[])
      } else {
        // No supplement or number, but there are custom reference
        // contents, so we display that
        (caption: tag.custom-ref)
      }
    } else {
      (:)
    }

    let ref-figure = [#figure(
      supplement: if supplement-type in (str, content) {
        [#reference.supplement]
      } else if supplement-type == function {
        (reference.supplement)(synthesized-fields)
      } else {
        []
      },

      numbering: if number == none { none } else { _ => number },

      kind: ref-figure-kind,

      ..caption
    )[#[]#metadata(tag)#lbl-tag]#ref-label]

    let tagged-figure = [#[#ref-figure#metadata(tag)#lbl-tag]#lbl-ref-figure]

    show figure: none

    tagged-figure
  }

  // Sentinel for 'unspecified value'
  let _missing() = {}
  let std-label = label

  let default-constructor(..args, __elembic_data: none, __elembic_func: auto, label: _missing) = {
    if __elembic_func == auto {
      __elembic_func = default-constructor
    }

    let default-constructor = default-constructor.with(__elembic_func: __elembic_func)
    if __elembic_data != none {
      return if __elembic_data == special-data-values.get-data {
        (data-kind: "element", ..elem-data, func: __elembic_func, default-constructor: default-constructor)
      } else if __elembic_data == special-data-values.get-where {
        if label == _missing {
          where(..args)
        } else {
          where(..args, label: label)
        }
      } else {
        assert(false, message: "element: invalid data key to constructor: " + repr(__elembic_data))
      }
    }

    let labeling = false
    let ref-label = none
    if labelable {
      if label == _missing {
        label = none
      } else if type(label) == std-label {
        ref-label = std-label(lbl-ref-figure-label-head + str(label))
        labeling = true
      } else if label != none {
        assert(false, message: "element '" + name + "': expected label or 'none' for 'label', found " + base.typename(label))
      }
    } else if label == _missing {
      label = none
    } else {
      // Also parse label as a field if we don't want element to be labelable
      args = arguments(..args, label: label)
    }

    let args = parse-args(args, include-required: true)

    // Step the counter early if we don't need additional context
    let early-step = if not count-needs-fields { count }

    let inner = early-step + [#context {
      let previous-bib-title = bibliography.title
      [#context {
        set bibliography(title: previous-bib-title)

        let (global-data, data-changed) = if (
          type(bibliography.title) == content
          and bibliography.title.func() == metadata
          and bibliography.title.at("label", default: none) == lbl-data-metadata
        ) {
          (bibliography.title.value, false)
        } else {
          ((..default-global-data, first-bib-title: previous-bib-title), true)
        }

        if global-data.stateful {
          let chain = style-state.get()
          global-data = if chain == () {
            default-global-data
          } else {
            chain.last()
          }
        }

        let element-data = global-data.elements.at(eid, default: default-data)

        let constructed-fields = if (
          element-data.revoke-chain == default-data.revoke-chain
          and (
            foldable-fields == (:)
            or element-data.fold-chain == default-data.fold-chain
            and args.keys().all(f => f not in foldable-fields)
          )
        ) {
          // Sum the chain of dictionaries so that the latest value specified for
          // each property wins.
          default-fields + element-data.chain.sum(default: (:)) + args
        } else {
          // We can't just sum, we need to filter and fold first.
          // Memoize this operation through a function.
          let outer-chain = default-fields + fold-styles(element-data.chain, element-data.data-chain, element-data.revoke-chain, element-data.fold-chain)
          let finalized-chain = outer-chain + args

          // Fold received arguments with outer chain or defaults
          for (field-name, fold-data) in foldable-fields {
            if field-name in args {
              let outer = outer-chain.at(field-name, default: fold-data.default)
              if fold-data.folder == auto {
                finalized-chain.at(field-name) = outer + args.at(field-name)
              } else {
                finalized-chain.at(field-name) = (fold-data.folder)(outer, args.at(field-name))
              }
            }
          }

          finalized-chain
        }

        let shown = {
          let tag = (
            data-kind: "element-instance",
            body: none,
            fields: constructed-fields,
            func: __elembic_func,
            scope: scope,
            default-constructor: default-constructor,
            name: name,
            eid: eid,
            ctx: if contextual {
              (get: get-styles.with(elements: global-data.elements))
            } else { none },
            counter: element-counter,
            reference: reference,
            custom-ref: none,
            fields-known: true,
            valid: true
          )

          if contextual {
            // Use context for synthesize as well
            context {
              let synthesized-fields = if synthesize == none {
                constructed-fields
              } else {
                // Pass contextual information to synthesize
                // Remove it afterwards to ensure the final tag's 'fields' won't
                // have its own copy of the tag
                let new-fields = synthesize(constructed-fields + ((stored-data-key): tag))
                if type(new-fields) != dictionary {
                  assert(false, message: "element '" + name + "': 'synthesize' didn't return a dictionary, but rather " + repr(new-fields) + " (a(n) '" + str(type(new-fields)) + "') instead). Please contact the element author.")
                }
                if stored-data-key in new-fields {
                  _ = new-fields.remove(stored-data-key)
                }
                new-fields
              }

              if labelable and label != none and label != _missing {
                synthesized-fields.label = label
              }

              let tag = tag
              tag.fields = synthesized-fields

              // Store contextual information in synthesize
              synthesized-fields.insert(stored-data-key, tag)

              if count-needs-fields {
                count(synthesized-fields)

                // Wrap in additional context so the counter step is detected
                context {
                  let body = display(synthesized-fields)
                  let tag = tag
                  tag.body = body

                  if custom-ref != none {
                    // Update with body
                    let synthesized-fields = synthesized-fields
                    synthesized-fields.at(stored-data-key) = tag

                    tag.custom-ref = custom-ref(synthesized-fields)
                  }

                  let tag-metadata = metadata(tag)

                  if reference != none and ref-label != none or outline != none {
                    // Update with custom-ref
                    let synthesized-fields = synthesized-fields
                    synthesized-fields.at(stored-data-key) = tag

                    ref-figure(tag, synthesized-fields, ref-label)
                  }

                  if labeling {
                    [#[#[#body#metadata(tag)#lbl-tag]#label#metadata(tag)]#lbl-show]
                  } else {
                    [#[#body#metadata(tag)]#lbl-show]
                  }
                }
              } else {
                let body = display(synthesized-fields)
                let tag = tag
                tag.body = body

                if custom-ref != none {
                  // Update with body
                  synthesized-fields.at(stored-data-key) = tag

                  tag.custom-ref = custom-ref(synthesized-fields)
                }

                let tag-metadata = metadata(tag)

                if reference != none and ref-label != none or outline != none {
                  // Update with custom-ref
                  synthesized-fields.at(stored-data-key) = tag

                  ref-figure(tag, synthesized-fields, ref-label)
                }

                if labeling {
                  [#[#[#body#metadata(tag)#lbl-tag]#label#metadata(tag)]#lbl-show]
                } else {
                  [#[#body#metadata(tag)]#lbl-show]
                }
              }
            }
          } else {
            let synthesized-fields = if synthesize == none {
              constructed-fields
            } else {
              // Pass contextual information to synthesize
              // Remove it afterwards to ensure the final tag's 'fields' won't
              // have its own copy of the tag
              let new-fields = synthesize(constructed-fields + ((stored-data-key): tag))
              if type(new-fields) != dictionary {
                assert(false, message: "element '" + name + "': 'synthesize' didn't return a dictionary, but rather " + repr(new-fields) + " (a(n) '" + str(type(new-fields)) + "') instead). Please contact the element author.")
              }
              if stored-data-key in new-fields {
                _ = new-fields.remove(stored-data-key)
              }
              new-fields
            }

            if labelable and label != none and label != _missing {
              synthesized-fields.label = label
            }

            tag.fields = synthesized-fields

            // Store contextual information in synthesize
            synthesized-fields.insert(stored-data-key, tag)

            if count-needs-fields {
              count(synthesized-fields)

              // Wrap in additional context so the counter step is detected
              context {
                let body = display(synthesized-fields)
                let tag = tag
                tag.body = body

                if custom-ref != none {
                  // Update with body
                  let synthesized-fields = synthesized-fields
                  synthesized-fields.at(stored-data-key) = tag

                  tag.custom-ref = custom-ref(synthesized-fields)
                }

                let tag-metadata = metadata(tag)

                if reference != none and ref-label != none or outline != none {
                  // Update with custom-ref
                  let synthesized-fields = synthesized-fields
                  synthesized-fields.at(stored-data-key) = tag

                  ref-figure(tag, synthesized-fields, ref-label)
                }

                if labeling {
                  [#[#[#body#metadata(tag)#lbl-tag]#label#metadata(tag)]#lbl-show]
                } else {
                  [#[#body#metadata(tag)]#lbl-show]
                }
              }
            } else {
              let body = display(synthesized-fields)
              tag.body = body

              if custom-ref != none {
                // Update with body
                synthesized-fields.at(stored-data-key) = tag

                tag.custom-ref = custom-ref(synthesized-fields)
              }

              let tag-metadata = metadata(tag)

              if reference != none and ref-label != none or outline != none {
                // Update with custom-ref
                synthesized-fields.at(stored-data-key) = tag

                ref-figure(tag, synthesized-fields, ref-label)
              }

              if labeling {
                [#[#[#body#metadata(tag)#lbl-tag]#label#metadata(tag)]#lbl-show]
              } else {
                [#[#body#metadata(tag)]#lbl-show]
              }
            }
          }
        }

        if data-changed {
          show lbl-get: set bibliography(title: [#metadata(global-data)#lbl-data-metadata])
          shown
        } else {
          shown
        }
      }#lbl-get]
    }#lbl-outer]

    let tag = [#metadata((
      data-kind: "element-instance",
      body: inner,
      scope: scope,
      fields: args,
      func: __elembic_func,
      default-constructor: default-constructor,
      name: name,
      eid: eid,
      ctx: none,
      counter: element-counter,
      reference: reference,
      custom-ref: none,
      fields-known: false,
      valid: true
    ))#lbl-tag]

    if template != none {
      inner = template[#inner#tag]
    }

    [#inner#tag]
  }

  let final-constructor = if construct != none {
    {
      let test-construct = construct(default-constructor)
      assert(type(test-construct) == function, message: "element.declare: the 'construct' function must receive original constructor and return the new constructor, a new function, not '" + str(type(test-construct)) + "'.")
    }

    let final-constructor(..args, __elembic_data: none) = {
      if __elembic_data != none {
        return if __elembic_data == special-data-values.get-data {
          (data-kind: "element", ..elem-data, func: final-constructor, default-constructor: default-constructor.with(__elembic_func: final-constructor))
        } else if __elembic_data == special-data-values.get-where {
          where(..args)
        } else {
          assert(false, message: "element: invalid data key to constructor: " + repr(__elembic_data))
        }
      }

      construct(default-constructor.with(__elembic_func: final-constructor))(..args)
    }

    final-constructor
  } else {
    default-constructor
  }

  final-constructor
}
