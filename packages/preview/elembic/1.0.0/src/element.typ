#import "data.typ": data, lbl-show-head, lbl-meta-head, lbl-outer-head, lbl-counter-head, lbl-ref-figure-kind-head, lbl-ref-figure-label-head, lbl-ref-figure, lbl-get, lbl-tag, lbl-rule-tag, lbl-old-rule-tag, lbl-special-rule-tag, lbl-data-metadata, lbl-stateful-mode, lbl-leaky-mode, lbl-normal-mode, lbl-auto-mode, lbl-global-select-head, prepared-rule-key, stored-data-key, element-key, element-data-key, element-meta-key, global-data-key, filter-key, special-rule-key, special-data-values, custom-type-key, custom-type-data-key, type-key, element-version, style-modes, style-state
#import "fields.typ" as field-internals
#import "types/base.typ"
#import "types/types.typ"

// Basic elements for our document tree analysis
#let sequence = [].func()
#let space = [ ].func()
#let styled = { set text(red); [a] }.func()
#let state-update-func = state(".").update(1).func()
#let counter-update-func = counter(".").update(1).func()

// Default library-wide data.
#let default-global-data = (
  (global-data-key): true,

  // Keep track of versions in case we need some backwards-compatibility behavior
  // in the future.
  version: element-version,

  // If the style state should be read by set rules as the user has
  // enabled stateful mode with `#show: e.stateful.enable()`.
  stateful: false,

  // First known bib title.
  // This is used by leaky mode to attempt to preserve the correct bibliography.title
  // property. Evidently, it's not perfect, and leaky mode should be avoided.
  first-bib-title: (),

  // Identical to 'global.select-count', this is only here for compatibility
  // with older elements.
  where-rule-count: 0,

  // Some global settings changeable through set rules.
  settings: (
    // Whether non-stateful rules should default to leaky mode.
    prefer-leaky: false,

    // Additional elements for which ancestry should be tracked.
    // Setting this to 'any' will enable ancestry tracking for all elements
    // (POTENTIALLY SLOW!).
    track-ancestry: (:),

    // Additional elements which should support ancestry-related filters when
    // queried.
    store-ancestry: (:),
  ),

  // Shared state between elements.
  // Differently from settings, this is not meant to be configurable by users.
  global: (
    // Version that created the default global data.
    version: element-version,

    // Amount of select rules in the style chain so far.
    // Used to apply a unique label.
    select-count: 0,

    // Current element ancestors, from outermost to innermost.
    ancestry-chain: (),
  ),

  // Per-element data (set rules and other style chain info).
  elements: (:),
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
  //       (index: 3, name: none, names: (), value: 4pt),     // If 'revoke' or 'reset' are used, this list is used instead
  //       (index: 5, name: none, names: (), value: orange),  // so we can know which values were revoked.
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
  revoke-chain: (),

  // This is set to true when a rule with '.within(eid)' is used.
  track-ancestry: false,

  // Data for filtering.
  filters: (
    // Filters applying to this element. Each filter is associated with a rule below.
    // While some filters might trivially apply to all instances of an element,
    // others might require specific field values to match, for example.
    all: (),

    // This is an array of rules to apply for each filter in the same index.
    // These rules are applied whenever an element matching the given filter
    // is found.
    rules: (),

    // Data associated with each filter, such as its name(s).
    // Format:
    // ((names: ("name1", "name2", ...)), ...)
    data: (),
  ),

  // Conditional set rules, which only apply to matching instances of an
  // element.
  cond-sets: (
    // Filters to apply to each set rule.
    filters: (),
    // For each filter above, the associated set rule args with the changed
    // fields.
    args: (),
    // Data associated with each conditional set rule.
    // Format:
    // ((names: ("name1", "name2", ...), index: 0), ...)
    data: (),
  ),

  // Show rules that might apply to this element.
  show-rules: (
    // Filters for each show rule.
    filters: (),
    // For each filter above, the associated show rule function.
    callbacks: (),
    // Data associated with each show rule.
    // Format:
    // ((names: ("name1", "name2", ...), index: 0), ...)
    data: (),
  ),

  // Applied selectors (filters for labels).
  selects: (
    filters: (),
    labels: (),
    data: (),
  )
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
  assert(args.pos().len() > 0, message: "elembic: element.ref: expected at least one positional argument (reference or label)")
  let first-arg = args.pos().first()

  set ref(..args.named())

  show ref: it => {
    let element = if it.has("element") {
      it.element
    } else {
      query(it.target).at(0, default: none)
    }
    if (
      element == none
      or element.has("label") and str(element.label).starts-with(lbl-ref-figure-label-head)
      or type(it.target) != label
    ) {
      // This is known to be a reference to a custom element
      // (or the target is not something we can deal with, i.e. not a label)
      return it
    }

    let info = data(element)
    if type(info) == dictionary and "data-kind" in info and info.data-kind == "element-instance" {
      if "__future-ref" in info and element-version <= info.__future-ref.max-version {
        return (info.__future-ref.call)(target: it.target, supplement: it.at("supplement", default: none), ref-instance: it, __future-version: element-version)
      }

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

  [#metadata(((special-rule-key): "toggle-stateful-mode", data-kind: "special-rule", kind: "toggle-stateful-mode", version: element-version, enable: enable, force: force))#lbl-special-rule-tag]
}

// Check if an element instance satisfies a filter.
//
// Assumes this filter already accepts this element, so eid is not checked.
#let verify-filter(fields, eid: none, filter: none, ancestry: ()) = {
  if filter == none {
    return false
  }
  if eid == none {
    assert(false, message: "elembic: element.verify-filter: eid must not be none")
  }

  if "__future" in filter and element-version <= filter.__future.max-version {
    return (filter.__future.call)(fields, eid: eid, filter: filter, ancestry: ancestry, __future-version: element-version)
  } else if filter.kind == "where" {
    return eid == filter.eid and filter.fields.pairs().all(((k, v)) => k in fields and fields.at(k) == v)
  } else if filter.kind == "where-any" {
    return eid in filter.fields-any and filter.fields-any.at(eid).any(f => f.pairs().all(((k, v)) => k in fields and fields.at(k) == v))
  } else if filter.kind == "custom" {
    return (filter.elements == none or eid in filter.elements) and (filter.call)(
      fields, eid: eid, ancestry: if filter.may-need-ancestry { ancestry } else { () }, __please-use-var-args: true
    )
  }

  // Manually simulate a recursive algorithm.
  // Normally, for OR(A, B), we could just call (verify(A), verify(B)), but
  // recursive calls are limited and expensive.
  // We instead do the following:
  // - Have a stack of filters pending evaluation.
  // - Have a stack of evaluation results (operands). This is only used for
  // non-short circuiting operations (see below).
  // - Each time a filter is pushed to the pending stack, we push its operands
  // to the pending stack too, until the top of the stack has no further
  // operands, and mark the filter as "visited" so we don't add its operands
  // again. Note that operands are always pushed in reverse for short circuit
  // to work, since we have to evaluate - thus pop from the end - each operand
  // in its original order.
  // - We evaluate each leaf filter (where or custom) and push their results to
  // 'operands' (in reverse order, from last to first).
  // - We then reach the filter that will use the latest N results from
  // 'operands' and push that filter's evaluated result (e.g. AND of the latest
  // two results) into 'operands'.
  // - Repeat the process until the filter stack is empty (all evaluated) and
  // operands has only a single element (for the root filter).
  // - If operands is empty or has more than one element, something bad
  // happened. Otherwise, its only remaining element is the evaluated result of
  // the root filter.
  //
  // We also have an "op-stack" to indicate the latest operation whose operands
  // were expanded into the filter stack.
  //
  // The idea is to allow short circuiting when the latest operation is an AND
  // or OR. Otherwise, the operation in op-stack is only used to indicate the
  // latest operation doesn't short-circuit.
  //
  // It works as follows: we store the filter stack state in "op-stack"
  // whenever we push an operation, such as and, or, xor etc. When the latest
  // pushed operation is an "and" and the current filter returned false, we
  // immediately restore the filter state at the "and" (ignore its other
  // operands) and assign its value to "false". If it was an "or", we do the
  // same if the current filter returned true, assigning its value to true.
  let filter-stack = (filter,)
  let op-stack = ()
  let operands = ()
  while filter-stack != () {
    let last = filter-stack.last()

    // Expand the latest filter's children into the evaluation stack.
    while (
      last.at(filter-key) != "visited"
      and ("__future" not in last or element-version > last.__future.max-version)
      and "operands" in last
      and last.operands != ()
    ) {
      // Ensure we don't reach the parent operation until we have evaluated
      // each child operation.
      op-stack.push((last.kind, filter-stack.len() - 1))
      filter-stack.last().at(filter-key) = "visited"
      if "__subject" in filter {
        // Ensure children filters apply to the same subject.
        filter-stack += last.operands.map(op => if "__subject" in op { op } else { (..op, __subject: filter.__subject) }).rev()
      } else {
        // In reverse order to pop the first operand first.
        filter-stack += last.operands.rev()
      }
      last = filter-stack.last()
    }

    let filter = filter-stack.pop()
    let (kind,) = filter
    let fields = fields
    let eid = eid
    let ancestry = ancestry
    if "__subject" in filter {
      (fields, eid, ancestry) = filter.__subject
    }

    let value = if "__future" in filter and element-version <= filter.__future.max-version {
      (filter.__future.call)(fields, eid: eid, filter: filter, ancestry: ancestry, __future-version: element-version)
    } else if kind == "where" {
      eid == filter.eid and filter.fields.pairs().all(((k, v)) => k in fields and fields.at(k) == v)
    } else if kind == "where-any" {
      eid in filter.fields-any and filter.fields-any.at(eid).any(f => f.pairs().all(((k, v)) => k in fields and fields.at(k) == v))
    } else if kind == "custom" {
      (filter.elements == none or eid in filter.elements) and (filter.call)(
        fields, eid: eid, ancestry: if filter.may-need-ancestry { ancestry } else { () }, __please-use-var-args: true
      )
    } else if kind == "within" {
      // Expand 'within' filter into
      // (ancestor 1 matches OR ancestor 2 matches OR ...)
      if filter.elements == none or eid in filter.elements {
        let (ancestor-filter,) = filter
        let matching-ancestors = if "depth" in filter and filter.depth != none and filter.depth > 0 {
          let total-depth = ancestry.len()
          if total-depth >= filter.depth {
            ((total-depth - filter.depth, ancestry.at(total-depth - filter.depth)),)
          } else {
            ()
          }
        } else if "max-depth" in filter and filter.max-depth != none and filter.max-depth > 0 {
          let total-depth = ancestry.len()
          if total-depth <= filter.max-depth {
            ancestry.enumerate()
          } else {
            ancestry.enumerate().slice(total-depth - filter.max-depth)
          }
        } else {
          ancestry.enumerate()
        }

        filter-stack.push(
          (
            (filter-key): true,
            element-version: element-version,
            kind: "or",
            operands: matching-ancestors.map(((i, ancestor)) => (
              ..ancestor-filter,

              // TODO: maybe don't clone the ancestry for each ancestor...
              __subject: (eid: ancestor.eid, fields: ancestor.fields, ancestry: ancestry.slice(0, i))
            )),
            elements: ancestor-filter.elements,

            // Since this is an internal filter, doesn't matter
            ancestry-elements: (:),
            may-need-ancestry: true,
          )
        )

        // This filter won't be evaluated, but rather the pushed OR.
        continue
      }

      // Invalid
      false
    } else if kind == "and" {
      // Due to short-circuiting, a false would have failed earlier.
      true
    } else if kind == "or" {
      // Due to short-circuiting, a true would have succeeded earlier.
      false
    } else if "operands" in filter {
      let first-applied-operand = operands.len() - filter.operands.len()
      // Operation requires N operands => take N operands from the top of the
      // stack.
      let applied-operands = operands.slice(first-applied-operand)
      operands = operands.slice(0, first-applied-operand)

      if kind == "not" {
        assert(applied-operands.len() == 1, message: "elembic: element.verify-filter: expected one child filter for 'not'")
        (filter.elements == none or eid in filter.elements) and not applied-operands.first()
      } else if kind == "xor" {
        assert(applied-operands.len() == 2, message: "elembic: element.verify-filter: expected two children filters for 'xor'")
        // Here the order doesn't matter, since we always need to evaluate both
        // XOR operands (no short-circuit).
        applied-operands.first() != applied-operands.at(1)
      } else {
        assert(false, message: "elembic: element.verify-filter: unsupported filter kind '" + kind + "'\n\nhint: this might mean you're using packages depending on conflicting elembic versions. Please ensure your dependencies are up-to-date.")
      }
    } else {
      assert(false, message: "elembic: element.verify-filter: unsupported or invalid filter kind '" + kind + "'\n\nhint: this might mean you're using packages depending on conflicting elembic versions. Please ensure your dependencies are up-to-date.")
    }

    if op-stack != () and op-stack.last().at(1) == filter-stack.len() {
      // We have just evaluated this operation.
      _ = op-stack.pop()
    }

    // Short-circuit: for certain operations, a specific value must stop all
    // other operand filters from running.
    let (current-op, op-pos) = if op-stack == () { (none, none) } else { op-stack.last() }
    while current-op == "and" and not value or current-op == "or" and value {
      filter-stack = filter-stack.slice(0, op-pos)
      _ = op-stack.pop()
      if op-stack == () {
        current-op = none
        op-pos = none
        break
      } else {
        (current-op, op-pos) = op-stack.last()
      }
    }

    if current-op not in ("and", "or") {
      operands.push(value)
    }
  }

  if operands.len() != 1 or op-stack != () {
    assert(false, message: "elembic: element.verify-filter: filter didn't receive enough operands.")
  }

  operands.first()
}

#let multi-operand-filter(kind: "", arg-count: none) = (..args) => {
  assert(args.named() == (:), message: "elembic: filters: invalid named arguments given to '" + kind + "' filter constructor.")
  let filters = args.pos()
  if arg-count != none and filters.len() != arg-count {
    assert(false, message: "elembic: filters: must give exactly " + str(arg-count) + " arguments to a '" + kind + "' filter constructor.")
  }

  filters = filters.map(filter => {
    if type(filter) == function {
      filter = filter(__elembic_data: special-data-values.get-where)
    }
    assert(type(filter) == dictionary and filter-key in filter, message: "elembic: filters: invalid filter passed to '" + kind + "' constructor, please use 'custom-element.with(...)' to generate a filter.")

    // Flatten "and", "or"
    if filter.kind == kind and kind in ("and", "or") {
      filter.operands
    } else {
      (filter,)
    }
  }).flatten()

  let elements = none
  if kind == "and" {
    // Merge where filters as an optimization
    let where-fields = (:)
    let where-eid = none
    let may-merge-filters = filters != ()

    // Intersect elements.
    // Start accepting all elements and narrow it down from there.
    for filter in filters {
      assert("elements" in filter, message: "elembic: filters.and: this filter operand is missing the 'elements' field; this indicates it comes from an element generated with an outdated elembic version. Please use an element made with an up-to-date elembic version.")
      if elements == none {
        elements = filter.elements
      } else if filter.elements != none {
        // Cannot add new elements, only remove non-shared elements.
        for (eid, elem-data) in elements {
          if eid not in filter.elements {
            _ = elements.remove(eid)
          }
        }
      }

      if filter.kind == "where" and may-merge-filters {
        if where-eid == none {
          where-eid = filter.eid
        } else if where-eid != filter.eid {
          // More than one element to check will never match.
          may-merge-filters = false
          continue
        }
        let (eid, fields) = filter
        if where-fields == (:) {
          where-fields = fields
        } else {
          for (field, value) in fields {
            if field in where-fields and value != where-fields.at(field) {
              // and(elem.with(a: 1), elem.with(a: 2))
              // impossible to match
              may-merge-filters = false
              break
            }

            where-fields.insert(field, value)
          }
        }
      } else if may-merge-filters {
        // Has a custom filter, don't merge
        may-merge-filters = false
      }
    }

    if may-merge-filters and where-eid != none {
      // and(elem, elem.with(a: 0), elem.with(b: 1))
      return (
        (filter-key): true,
        element-version: element-version,
        kind: "where",
        eid: where-eid,
        fields: where-fields,
        elements: ((where-eid): elements.at(where-eid)),
        ancestry-elements: (:),

        // For optimizations
        may-need-ancestry: false,
      )
    }

    // Ensure the filters won't match on the wrong elements.
    // Workaround for e.filters.and_(custom, element)
    filters = filters.map(f => f + (elements: elements,))

    elements
  } else if kind == "or" or kind == "xor" {
    // Join together.
    elements = (:)
    let may-merge-filters = kind == "or" and filters != ()
    let wheres = (:)

    for filter in filters {
      if "elements" in filter and filter.elements == none {
        // OR(Any, ...) is always Any.
        // For XOR, we still have to check all operands so this would also be
        // Any.
        elements = none
      } else if "elements" not in filter or type(filter.elements) != dictionary {
        assert(false, message: "elembic: filters: invalid operand filter received by '" + kind + "' filter constructor\n\nhint: this filter was likely constructed with an old elembic version. Please update your packages.")
      } else if elements != none {
        elements += filter.elements
      }

      if may-merge-filters and filter.kind in ("where", "where-any") {
        for (eid, fields) in if filter.kind == "where-any" { filter.fields-any } else { ((filter.eid): (filter.fields,)) } {
          if eid in wheres {
            wheres.at(eid) += fields
          } else {
            wheres.insert(eid, fields)
          }
        }
      } else if may-merge-filters {
        // Not all "where"
        may-merge-filters = false
      }
    }

    if may-merge-filters {
      return (
        (filter-key): true,
        element-version: element-version,
        kind: "where-any",
        fields-any: wheres,
        elements: elements,
        ancestry-elements: (:),
        may-need-ancestry: false,
      )
    }

    elements
  } else if kind == "not" {
    // No elements for NOT since it is unrestricted.
    // User will have to restrict it manually.
    none
  } else {
    assert(false, message: "elembic: filters: internal error: invalid kind '" + kind + "'")
  }

  (
    (filter-key): true,
    element-version: element-version,
    kind: kind,
    operands: filters,
    elements: elements,
    ancestry-elements: (:) + filters.map(f => f.at("ancestry-elements", default: none)).join(),
    may-need-ancestry: filters.any(f => "may-need-ancestry" in f and f.may-need-ancestry),
  )
}

#let or-filter = multi-operand-filter(kind: "or")
#let and-filter = multi-operand-filter(kind: "and")
#let not-filter = multi-operand-filter(kind: "not", arg-count: 1)
#let xor-filter = multi-operand-filter(kind: "xor", arg-count: 2)
#let custom-filter(callback) = {
  assert(type(callback) == function, message: "elembic: filters.custom: 'callback' for custom filter must be a function (fields, eid: eid, ..) => bool.")

  (
    (filter-key): true,
    element-version: element-version,
    kind: "custom",
    call: callback,
    elements: none,
    ancestry-elements: (:),
    may-need-ancestry: true,
  )
}

/// Filter that only matches when this element is inside another elembic element.
///
/// For example:
///
/// ```typ
/// #show: e.show_(e.filters.and(elem, e.filters.within(other-elem)), none)
///
/// #other-elem(elem[This element will be matched and removed])
/// #elem[This element stays, as it is not inside `other-elem`]
/// ```
///
/// - ancestor-filter (filter): a filter to match potential ancestors.
/// - depth (int): only match at this exact KNOWN depth.
/// - max-depth (int): only match up to this exact KNOWN depth.
/// -> filter
#let within-filter(ancestor-filter, depth: none, max-depth: none) = {
  if type(ancestor-filter) == function {
    ancestor-filter = ancestor-filter(__elembic_data: special-data-values.get-where)
  }
  assert(type(ancestor-filter) == dictionary and filter-key in ancestor-filter, message: "elembic: filters.within: invalid filter, please use 'custom-element.with(...)' to generate a filter.")
  assert("elements" in ancestor-filter, message: "elembic: filters.within: the ancestor filter is missing the 'elements' field; this indicates it comes from an element generated with an outdated elembic version. Please use an element made with an up-to-date elembic version.")
  assert(ancestor-filter.elements != (:), message: "elembic: filters.within: the ancestor filter appears to not be restricted to any elements and is thus impossible to match. It must apply to at least one element (potential ancestor). Consider using a different filter.")
  assert(ancestor-filter.elements != none, message: "elembic: filters.within: the ancestor filter appears to apply to any element. It must apply to exactly one element (the one receiving the set rule). Consider using an 'and' filter, e.g. 'e.filters.within(e.filters.and(wibble, e.not(wibble.with(a: 10))))' instead of just 'e.filters.within(e.not(wibble.with(a: 10)))', to restrict it.")
  assert(depth == none or max-depth == none, message: "elembic: filters.within: cannot specify both depth and max-depth (please pick one).")
  assert(depth == none or type(depth) == int and depth > 0, message: "elembic: filters.within: 'depth' parameter must be a positive integer or 'none'.")
  assert(max-depth == none or type(max-depth) == int and max-depth > 0, message: "elembic: filters.within: 'max-depth' parameter must be a positive integer or 'none'.")

  (
    (filter-key): true,
    element-version: element-version,
    kind: "within",
    ancestor-filter: ancestor-filter,
    depth: depth,
    max-depth: max-depth,
    elements: none,
    ancestry-elements: (:) + ancestor-filter.elements + ancestor-filter.at("ancestry-elements", default: (:)),
    may-need-ancestry: true,
  )
}

#let request-ancestry-tracking(elements, requests) = {
  for (eid, elem-data) in requests {
    if eid not in elements {
      elements.insert(eid, elem-data.default-data)
    }
    elements.at(eid).track-ancestry = true
  }

  elements
}

// Apply set and revoke rules to the current per-element data.
#let apply-rules(rules, elements: none, settings: (:), global: (:), extra-output: (:)) = {
  for rule in rules {
    if "__future" in rule and element-version <= rule.__future.max-version {
      let output = (rule.__future.call)(rule, elements: elements, settings: settings, global: global, extra-output: extra-output, __future-version: element-version)
      extra-output += output
      if "elements" in output {
        elements = output.elements
      }
      if "settings" in output {
        settings = output.settings
      }
      if "global" in output {
        global = output.global
      }
      continue
    }

    let kind = rule.kind
    if kind == "settings" {
      let (write, transform) = rule
      if write != none {
        settings += write
      }
      if transform != none {
        settings = transform(settings)
      }
    } else if kind == "set" {
      let (element, args) = rule
      let (eid, default-data, fields) = element

      // Forward-compatibility with newer elements
      if (
        "__future-rules" in default-data
        and "set" in default-data.__future-rules
        and element-version <= default-data.__future-rules.set.max-version
      ) {
        let output = (default-data.__future-rules.set.call)(rule, elements: elements, settings: settings, global: global, extra-output: extra-output, __future-version: element-version)
        extra-output += output
        if "elements" in output {
          elements = output.elements
        }
        if "settings" in output {
          settings = output.settings
        }
        if "global" in output {
          global = output.global
        }
        continue
      }

      if eid in elements {
        elements.at(eid).chain.push(args)
      } else {
        elements.insert(eid, (..default-data, chain: (args,)))
      }

      let names = if "names" in rule { rule.names } else if "name" in rule and rule.name != none { (rule.name,) } else { () }
      let compat-name = none
      if names != () {
        let element-data = elements.at(eid)
        let index = element-data.chain.len() - 1
        compat-name = names.last()

        // Lazily fill the data chain with 'none'
        // Add 'name' for compatibility with older elembic versions
        elements.at(eid).data-chain += (none,) * (index - element-data.data-chain.len())
        elements.at(eid).data-chain.push((kind: "set", name: compat-name, names: names))

        for rule-name in names {
          elements.at(eid).names.insert(rule-name, true)
        }
      }

      if fields.foldable-fields != (:) and args.keys().any(n => n in fields.foldable-fields) {
        // A foldable field was specified in this set rule, so we need to record the fold
        // data in the corresponding data structures separately for later.
        let element-data = elements.at(eid)
        let index = element-data.chain.len() - 1
        for (field-name, fold-data) in fields.foldable-fields {
          if field-name in args {
            let value = args.at(field-name)
            let value-data = (index: index, name: compat-name, names: names, value: value)
            if field-name in element-data.fold-chain {
              elements.at(eid).fold-chain.at(field-name).values.push(value)
              elements.at(eid).fold-chain.at(field-name).data.push(value-data)
            } else {
              elements.at(eid).fold-chain.insert(
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
      let rule-names = if "names" in rule { rule.names } else if "name" in rule and rule.name != none { (rule.name,) } else { () }
      let compat-name = if rule-names == () {
        none
      } else {
        rule-names.last()
      }

      for (name, element-data) in elements {
        // Forward-compatibility with newer elements
        if (
          "__future-rules" in element-data
          and "revoke" in element-data.__future-rules
          and element-version <= element-data.__future-rules.revoke.max-version
        ) {
          let output = (element-data.__future-rules.revoke.call)(rule, elements: elements, settings: settings, global: global, extra-output: extra-output, __future-version: element-version)
          extra-output += output
          if "elements" in output {
            elements = output.elements
          }
          if "settings" in output {
            settings = output.settings
          }
          if "global" in output {
            global = output.global
          }
          continue
        }

        // Can only revoke what's before us.
        // If this element has no rules with this name, there is nothing to revoke;
        // we shouldn't revoke names that come after us (inner rules).
        // Note that this potentially includes named revokes as well.
        if rule.revoking in element-data.names {
          elements.at(name).revoke-chain.push((kind: "revoke", name: compat-name, names: rule-names, index: element-data.chain.len(), revoking: rule.revoking))

          if rule-names != () {
            for rule-name in rule-names {
              elements.at(name).names.insert(rule-name, true)
            }
          }
        }
      }
    } else if kind == "reset" {
      // Whether the list of elements that this reset applies to is restricted.
      let filtering = rule.eids != ()
      let rule-names = if "names" in rule { rule.names } else if "name" in rule and rule.name != none { (rule.name,) } else { () }
      let compat-name = if rule-names == () {
        none
      } else {
        rule-names.last()
      }

      for (name, element-data) in elements {
        // Forward-compatibility with newer elements
        if (
          "__future-rules" in element-data
          and "reset" in element-data.__future-rules
          and element-version <= element-data.__future-rules.reset.max-version
        ) {
          let output = (element-data.__future-rules.reset.call)(rule, elements: elements, settings: settings, global: global, extra-output: extra-output, __future-version: element-version)
          extra-output += output
          if "elements" in output {
            elements = output.elements
          }
          if "settings" in output {
            settings = output.settings
          }
          if "global" in output {
            global = output.global
          }
          continue
        }

        // Can only revoke what's before us.
        // If this element has no rules, no need to add a reset.
        if (not filtering or name in rule.eids) and element-data.chain != () {
          elements.at(name).revoke-chain.push((kind: "reset", name: compat-name, names: rule-names, index: element-data.chain.len()))

          if rule-names != () {
            for rule-name in rule-names {
              elements.at(name).names.insert(rule-name, true)
            }
          }
        }
      }
    } else if kind == "filtered" {
      let (filter, rule: inner-rule, names) = rule
      if type(filter) != dictionary or "elements" not in filter or "kind" not in filter {
        assert(false, message: "elembic: element.filtered: invalid filter found while applying rule: " + repr(filter) + "\nPlease use 'elem.with(field: value, ...)' to create a filter.\n\nhint: it might come from a package's element made with an outdated elembic version. Please update your packages.")
      }
      let target-elements = filter.elements
      if target-elements == none {
        assert(false, message: "elembic: element.filtered: this filter appears to apply to any element (e.g. it's a 'not' or 'custom' filter). It must match only within a certain set of elements. Consider using an 'and' filter, e.g. 'e.filters.and(wibble, e.not(wibble.with(a: 10)))' instead of just 'e.not(wibble.with(a: 10))', to restrict it.")
      }
      let base-data = (names: names)

      if "ancestry-elements" in filter and filter.ancestry-elements not in (none, (:)) {
        elements = request-ancestry-tracking(elements, filter.ancestry-elements)
      }

      for (eid, all-elem-data) in target-elements {
        // Forward-compatibility with newer elements
        if (
          "__future-rules" in all-elem-data.default-data
          and "filtered" in all-elem-data.default-data.__future-rules
          and element-version <= all-elem-data.default-data.__future-rules.filtered.max-version
        ) {
          let output = (all-elem-data.default-data.__future-rules.filtered.call)(rule, elements: elements, settings: settings, global: global, extra-output: extra-output, __future-version: element-version)
          extra-output += output
          if "elements" in output {
            elements = output.elements
          }
          if "settings" in output {
            settings = output.settings
          }
          if "global" in output {
            global = output.global
          }
          continue
        }

        if eid not in elements {
          elements.insert(eid, all-elem-data.default-data)
        }
        if "filters" not in elements.at(eid) {
          // Old version
          elements.at(eid).filters = default-data.filters
        }

        let index = elements.at(eid).chain.len()
        let data = (..base-data, index: index)

        elements.at(eid).filters.all.push(filter)
        elements.at(eid).filters.rules.push(inner-rule)
        elements.at(eid).filters.data.push(data)

        // Push an entry to the data chain so we have an index to assign to
        // this filter rule. This allows us to reset() it later.
        elements.at(eid).chain.push((:))

        // Lazily fill the data chain with 'none'
        elements.at(eid).data-chain += (none,) * (index - elements.at(eid).data-chain.len())

        // Keep "name" for some compatibility with older versions...
        elements.at(eid).data-chain.push(
          (kind: "filtered", name: if data.names == () { none } else { data.names.last() }, names: data.names)
        )

        for name in data.names {
          // Ensure the name is registered so revoke rules on this name are
          // treated as valid.
          elements.at(eid).names.insert(name, true)
        }
      }
    } else if kind == "show" {
      let (filter, callback, names) = rule
      if type(filter) != dictionary or "elements" not in filter or "kind" not in filter {
        assert(false, message: "elembic: element.show_: invalid filter found while applying rule: " + repr(filter) + "\nPlease use 'elem.with(field: value, ...)' to create a filter.\n\nhint: it might come from a package's element made with an outdated elembic version. Please update your packages.")
      }
      let target-elements = filter.elements
      if target-elements == none {
        assert(false, message: "elembic: element.show_: this filter appears to apply to any element (e.g. it's a 'not' or 'custom' filter). It must match only within a certain set of elements. Consider using an 'and' filter, e.g. 'e.filters.and(wibble, e.not(wibble.with(a: 10)))' instead of just 'e.not(wibble.with(a: 10))', to restrict it.")
      }
      let base-data = (names: names)

      if "ancestry-elements" in filter and filter.ancestry-elements not in (none, (:)) {
        elements = request-ancestry-tracking(elements, filter.ancestry-elements)
      }

      for (eid, all-elem-data) in target-elements {
        // Forward-compatibility with newer elements
        if (
          "__future-rules" in all-elem-data.default-data
          and "show" in all-elem-data.default-data.__future-rules
          and element-version <= all-elem-data.default-data.__future-rules.show.max-version
        ) {
          let output = (all-elem-data.default-data.__future-rules.show.call)(rule, elements: elements, settings: settings, global: global, extra-output: extra-output, __future-version: element-version)
          extra-output += output
          if "elements" in output {
            elements = output.elements
          }
          if "settings" in output {
            settings = output.settings
          }
          if "global" in output {
            global = output.global
          }
          continue
        }

        if eid not in elements {
          elements.insert(eid, all-elem-data.default-data)
        }
        if "show-rules" not in elements.at(eid) {
          // Old version
          elements.at(eid).show-rules = default-data.show-rules
        }

        let index = elements.at(eid).chain.len()
        let data = (..base-data, index: index)

        elements.at(eid).show-rules.filters.push(filter)
        elements.at(eid).show-rules.callbacks.push(callback)
        elements.at(eid).show-rules.data.push(data)

        // Push an entry to the data chain so we have an index to assign to
        // this show rule. This allows us to reset() it later.
        elements.at(eid).chain.push((:))

        // Lazily fill the data chain with 'none'
        elements.at(eid).data-chain += (none,) * (index - elements.at(eid).data-chain.len())

        // Keep "name" for some compatibility with older versions...
        elements.at(eid).data-chain.push(
          (kind: "show", name: if data.names == () { none } else { data.names.last() }, names: data.names)
        )

        for name in data.names {
          // Ensure the name is registered so revoke rules on this name are
          // treated as valid.
          elements.at(eid).names.insert(name, true)
        }
      }
    } else if kind == "cond-set" {
      let (filter, args, names, element) = rule
      if type(filter) != dictionary or "elements" not in filter or "kind" not in filter {
        assert(false, message: "elembic: element.cond-set: invalid filter found while applying rule: " + repr(filter) + "\nPlease use 'elem.with(field: value, ...)' to create a filter.\n\nhint: it might come from a package's element made with an outdated elembic version. Please update your packages.")
      }

      if "ancestry-elements" in filter and filter.ancestry-elements not in (none, (:)) {
        elements = request-ancestry-tracking(elements, filter.ancestry-elements)
      }

      let (eid,) = element

      // Forward-compatibility with newer elements
      if (
        "__future-rules" in element.default-data
        and "cond-set" in element.default-data.__future-rules
        and element-version <= element.default-data.__future-rules.cond-set.max-version
      ) {
        let output = (element.default-data.__future-rules.cond-set.call)(rule, elements: elements, settings: settings, global: global, extra-output: extra-output, __future-version: element-version)
        extra-output += output
        if "elements" in output {
          elements = output.elements
        }
        if "settings" in output {
          settings = output.settings
        }
        if "global" in output {
          global = output.global
        }
        continue
      }

      if eid not in elements {
        elements.insert(eid, element.default-data)
      }
      if "cond-sets" not in elements.at(eid) {
        // Old version
        elements.at(eid).cond-sets = default-data.cond-sets
      }

      let index = elements.at(eid).chain.len()
      let data = (names: names, index: index)
      elements.at(eid).cond-sets.filters.push(filter)
      elements.at(eid).cond-sets.args.push(args)
      elements.at(eid).cond-sets.data.push(data)

      // Push an entry to the data chain so we have an index to assign to
      // this filter rule. This allows us to reset() it later.
      elements.at(eid).chain.push((:))

      // Lazily fill the data chain with 'none'
      elements.at(eid).data-chain += (none,) * (index - elements.at(eid).data-chain.len())

      // Keep "name" for some compatibility with older versions...
      elements.at(eid).data-chain.push(
        (kind: "cond-set", name: if data.names == () { none } else { data.names.last() }, names: data.names)
      )

      for name in data.names {
        // Ensure the name is registered so revoke rules on this name are
        // treated as valid.
        elements.at(eid).names.insert(name, true)
      }
    } else if kind == "select" {
      let (element-data: target-elements, names) = rule
      let base-data = (names: names)

      for (eid, elem-data) in target-elements {
        if "filters" not in elem-data or "labels" not in elem-data {
          assert(false, message: "elembic: element.select: missing filters or labels for element " + repr(eid))
        }
        let (filters, labels) = elem-data
        assert(filters.len() == labels.len(), message: "elembic: element.select: differing lengths for filters and labels found (this is an internal error)")
        if filters == () {
          continue
        }

        let sample-filter = filters.first()
        assert(
          type(sample-filter) == dictionary
          and "kind" in sample-filter
          and "elements" in sample-filter
          and type(sample-filter.elements) == dictionary
          and eid in sample-filter.elements,
          message: "elembic: element.select: invalid filter found for element " + repr(eid) + ", it must contain the element's data.\nPlease use 'elem.with(field: value, ...)' to create a filter.\n\nhint: it might come from a package's element made with an outdated elembic version. Please update your packages."
        )

        let all-elem-data = sample-filter.elements.at(eid)

        // Forward-compatibility with newer elements
        if (
          "__future-rules" in all-elem-data.default-data
          and "select" in all-elem-data.default-data.__future-rules
          and element-version <= all-elem-data.default-data.__future-rules.select.max-version
        ) {
          let output = (all-elem-data.default-data.__future-rules.select.call)(rule, elements: elements, settings: settings, global: global, extra-output: extra-output, __future-version: element-version)
          extra-output += output
          if "elements" in output {
            elements = output.elements
          }
          if "settings" in output {
            settings = output.settings
          }
          if "global" in output {
            global = output.global
          }
          continue
        }

        for filter in filters {
          assert(
            type(filter) == dictionary
            and "kind" in filter
            and "elements" in filter,
            message: "elembic: element.select: invalid filter found for element " + repr(eid) + "\nPlease use 'elem.with(field: value, ...)' to create a filter.\n\nhint: it might come from a package's element made with an outdated elembic version. Please update your packages."
          )
          if "ancestry-elements" in filter and filter.ancestry-elements not in (none, (:)) {
            elements = request-ancestry-tracking(elements, filter.ancestry-elements)
          }
        }

        if eid not in elements {
          elements.insert(eid, all-elem-data.default-data)
        }
        if "selects" not in elements.at(eid) {
          // Old version
          elements.at(eid).selects = default-data.selects
        }

        let index = elements.at(eid).chain.len()
        let data = (..base-data, index: index)

        elements.at(eid).selects.filters += filters
        elements.at(eid).selects.labels += labels
        elements.at(eid).selects.data += (data,) * filters.len()

        // Push an entry to the data chain so we have an index to assign to
        // this filter rule. This allows us to reset() it later.
        elements.at(eid).chain += (((:),) * filters.len())

        // Lazily fill the data chain with 'none'
        elements.at(eid).data-chain += (none,) * (index - elements.at(eid).data-chain.len())

        // Keep "name" for some compatibility with older versions...
        elements.at(eid).data-chain.push(
          (kind: "select", name: if data.names == () { none } else { data.names.last() }, names: data.names)
        )

        for name in data.names {
          // Ensure the name is registered so revoke rules on this name are
          // treated as valid.
          elements.at(eid).names.insert(name, true)
        }
      }
    } else if kind == "apply" {
      // Mostly a fallback in case the rule is accidentally passed here...
      let output = apply-rules(rule.rules, elements: elements, settings: settings, global: global, extra-output: extra-output)
      extra-output += output
      if "elements" in output {
        elements = output.elements
      }
      if "settings" in output {
        settings = output.settings
      }
      if "global" in output {
        global = output.global
      }
    } else {
      assert(false, message: "elembic: element: invalid rule kind '" + rule.kind + "'\n\nhint: this might mean you're using packages depending on conflicting elembic versions. Please ensure your dependencies are up-to-date.")
    }
  }

  (..extra-output, elements: elements, settings: settings)
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
    let last-label = none
    while (
      potential-doc.func() == sequence
      and potential-doc.children.len() == 2
      and {
        last-label = potential-doc.children.last().at("label", default: none)
        last-label == lbl-rule-tag or last-label == lbl-old-rule-tag
      }
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
      rule = ((prepared-rule-key): true, version: element-version, kind: "apply", rules: rules, mode: mode, name: none, names: ())

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

      if "__future" in last.value and element-version <= last.value.__future.max-version {
        let res = (last.value.__future.call)(rule, doc, __future-version: element-version)

        if "doc" in res {
          return res.doc
        }
      }

      if last-label == lbl-old-rule-tag {
        // If we're merging with an older rule version, we may have to merge a
        // newer version again
        potential-doc = last.value.doc
      } else {
        break
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
          message: "elembic: element rule: cannot use a stateful rule without enabling the global stateful toggle\n  hint: if you don't mind the performance hit, write '#show: e.stateful.enable()' somewhere above this rule, or at the top of the document to apply to all"
        )

        if "settings" not in global-data {
          global-data.settings = default-global-data.settings
        }

        if "global" not in global-data {
          global-data.global = default-global-data.global
        }

        global-data += apply-rules(rules, elements: global-data.elements, settings: global-data.settings, global: global-data.global)

        chain.push(global-data)
        chain
      })
      doc
      style-state.update(chain => {
        _ = chain.pop()
        chain
      })
    }

    // Leaky mode: one context resetting bibliography.title.
    let leaky = [#context {
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

      if mode == auto and ("settings" not in global-data or "prefer-leaky" not in global-data.settings or not global-data.settings.prefer-leaky) {
        // User didn't want leaky.
        return none
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

      if "settings" not in global-data {
        global-data.settings = default-global-data.settings
      }

      if "global" not in global-data {
        global-data.global = default-global-data.global
      }

      global-data += apply-rules(rules, elements: global-data.elements, settings: global-data.settings, global: global-data.global)

      set bibliography(title: first-bib-title)
      show lbl-get: set bibliography(title: [#metadata(global-data)#lbl-data-metadata])
      doc
    }#lbl-get]

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

        if mode == auto and "settings" in global-data and "prefer-leaky" in global-data.settings and global-data.settings.prefer-leaky {
          // User wants leaky.
          return none
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

        if "settings" not in global-data {
          global-data.settings = default-global-data.settings
        }

        if "global" not in global-data {
          global-data.global = default-global-data.global
        }

        global-data += apply-rules(rules, elements: global-data.elements, settings: global-data.settings, global: global-data.global)

        set bibliography(title: previous-bib-title)
        show lbl-get: set bibliography(title: [#metadata(global-data)#lbl-data-metadata])
        doc
      }#lbl-get]
    }

    let body = if mode == auto {
      // Allow user to pick the mode through show rules.
      [#metadata((body: stateful))#lbl-stateful-mode]
      [#metadata((body: normal))#lbl-normal-mode]
      [#leaky]
      [#normal#lbl-auto-mode]
    } else if mode == style-modes.normal {
      normal
    } else if mode == style-modes.leaky {
      leaky
    } else if mode == style-modes.stateful {
      [#context {
        let global-data = if (
          type(bibliography.title) == content
          and bibliography.title.func() == metadata
          and bibliography.title.at("label", default: none) == lbl-data-metadata
        ) {
          bibliography.title.value
        } else {
          default-global-data
        }

        if not global-data.stateful {
          let only-rule = if rules.len() == 1 { rules.first() } else { (kind: "apply", rules: rules, name: none, names: (), mode: auto) }
          let named = if "names" in only-rule and only-rule.names != () {
            " named " + only-rule.names.map(repr).join(", ")
          } else if "name" in only-rule and only-rule.name != none {
            " named " + repr(only-rule.name)
          } else {
            ""
          }

          let extra = if only-rule.kind == "revoke" {
            " revoking " + repr(only-rule.revoking)
          } else {
            ""
          }

          assert(
            false,
            message: (
              "elembic: element rule: cannot use a stateful rule without enabling the global stateful toggle" +
              "\n  hint: if you don't mind the performance hit, write '#show: e.stateful.enable()' somewhere above this rule, or at the top of the document to apply to all" +
              if only-rule.kind != "apply" { "\n  help: this was triggered by a " + repr(only-rule.kind) + " rule" + named + extra }
            )
          )
        }
      }#lbl-get]

      stateful
    } else {
      panic("element rule: unknown mode: " + repr(mode))
    }

    // Add the rule tag after each rule application.
    // This allows extracting information about the rule before it is applied.
    // It also allows combining the rule with an outer rule before application,
    // as we do earlier.
    [#body#metadata((data-kind: "prepared-rule", version: element-version, routines: (prepare-rule: prepare-rule, apply-rules: apply-rules), doc: doc, rule: rule))#lbl-rule-tag]
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
  assert(type(elem) == dictionary, message: "elembic: element.set_: please specify the element's constructor or data in the first parameter")
  let (res, args) = (elem.parse-args)(fields, include-required: false)
  if not res {
    assert(false, message: args)
  }

  prepare-rule(
    ((prepared-rule-key): true, version: element-version, kind: "set", name: none, names: (), mode: auto, element: (eid: elem.eid, default-data: elem.default-data, fields: elem.fields), args: args)
  )
}

/// Prepare a selector similar to 'element.where(..args)'
/// which can be used in "show sel: set". Receives a filter
/// generated by 'element.with(fields)' or '(element-data.where)(fields)'.
///
/// This works by checking the filter within all element instances and,
/// if they match, they receive a unique label to be matched
/// by that selector. The label is then provided to the callback function
/// as the selector.
///
/// Each requested selector is passed as a separate parameter to the callback.
/// You must wrap the remainder of the document that depends on those selectors
/// in this callback.
///
/// USAGE:
///
/// ```typ
/// #e.select(superbox.with(fill: red), prefix: "my first select", superbox.with(width: auto), (red-superbox, auto-superbox) => {
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
/// - prefix (str): a unique prefix for selectors generated by this 'selector' to disambiguate from other calls to this function.
/// -> content
#let select(..args, receiver, prefix: 0) = {
  assert(type(prefix) == str, message: "elembic: element.select: please pick a unique string 'prefix:' argument for the selectors generated by this call to 'select' to ensure they don't clash with other calls to 'select'.")
  assert(args.named() == (:), message: "elembic: element.select: unexpected named arguments")
  assert(type(receiver) == function, message: "elembic: element.select: last argument must be a function receiving each prepared selector as a separate argument")

  let filters = args.pos()

  // (eid: ((index, filter), ...))
  // The idea is to apply all filters for a given eid at once
  let filters-by-eid = (:)
  // (eid: sel)
  let labels-by-eid = (:)
  // Elements which still require explicit show rules.
  let old-elements = (:)
  let ordered-eids = ()

  let i = 0
  for filter in filters {
    if type(filter) == function {
      filter = filter(__elembic_data: special-data-values.get-where)
    }

    if type(filter) != dictionary or filter-key not in filter {
      if type(filter) == selector {
        assert(false, message: "elembic: element.select: Typst-native selectors cannot be specified here, only those of custom elements")
      }
      assert(false, message: "elembic: element.select: expected a valid filter, such as 'custom-element' or 'custom-element.with(field-name: value, ...)', got " + base.typename(filter))
    }

    if "elements" not in filter {
      assert(false, message: "elembic: element.select: invalid filter found while applying rule, as it did not have an 'elements' field: " + repr(filter) + "\nPlease use 'elem.with(field: value, ...)' to create a filter.\n\nhint: it might come from a package's element made with an outdated elembic version. Please update your packages.")
    }

    for (eid, elem-data) in filter.elements {
      if "sel" not in elem-data {
        assert(false, message: "elembic: element.select: filter did not have the element's selector")
      }
      if elem-data.eid in labels-by-eid and labels-by-eid.at(elem-data.eid) != elem-data.sel {
        assert(false, message: "elembic: element.select: filter had a different selector from the others for the same element ID, check if you're not using conflicting library versions (could also be a bug)")
      }

      if elem-data.eid not in labels-by-eid {
        labels-by-eid.insert(elem-data.eid, elem-data.sel)
      }

      if elem-data.eid in filters-by-eid {
        filters-by-eid.at(elem-data.eid).push((i, filter))
      } else {
        filters-by-eid.insert(elem-data.eid, ((i, filter),))
        ordered-eids.push(elem-data.eid)
      }

      if ("version" not in elem-data or elem-data.version <= 1) and ("default-data" not in elem-data or "selects" not in elem-data.default-data) {
        old-elements.insert(elem-data.eid, true)
      }
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

      if "global" not in global-data {
        global-data.global = default-global-data.global
      }

      // Amount of 'select rules' so far, so we can
      // assign a unique number to each query
      let rule-counter = global-data.global.at("select-count", default: 0)

      // Generate labels by counting up, and update counter
      let matching-labels = range(0, filters.len()).map(i => label(lbl-global-select-head + prefix + str(rule-counter + i)))
      rule-counter += matching-labels.len()
      global-data.global.select-count = rule-counter

      // Provide labels to the body, one per filter
      // These labels only match the shown bodies of
      // elements with matching field values
      let body = receiver(..matching-labels)

      // Apply show rules to the body to add labels to matching elements
      let styled-body = ordered-eids.filter(e => e in old-elements).fold(body, (acc, eid) => {
        let filters = filters-by-eid.at(eid)
        show labels-by-eid.at(eid): it => {
          let data = data(it)
          let tag = [#metadata(data)#lbl-tag]
          let fields = data.fields

          let labeled-it = it
          for (i, filter) in filters {
            // Check if all positional and named arguments match
            // Note: no ancestry support since newer elements don't run this
            // code, they use 'select' rules instead
            if verify-filter(fields, eid: eid, filter: filter, ancestry: ()) {
              // Add corresponding label and preserve tag so 'data(it)' still works
              labeled-it = [#[#labeled-it#tag]#matching-labels.at(i)]
            }
          }

          labeled-it
        }

        acc
      })

      set bibliography(title: previous-bib-title)

      let pairs-by-eid = (:)
      for eid in ordered-eids {
        if eid in old-elements or filters-by-eid.at(eid, default: ()) == () {
          continue
        }
        let pairs = filters-by-eid.at(eid).map(((i, f)) => (f, matching-labels.at(i)))
        let (filters, labels) = array.zip(..pairs)
        pairs-by-eid.insert(eid, (filters: filters, labels: labels))
      }

      if pairs-by-eid != (:) {
        let select-rule = (
          ((prepared-rule-key): true,
            version: element-version,
            kind: "select",
            name: none,
            names: (),
            mode: auto,
            element-data: pairs-by-eid,
          )
        )
        global-data += apply-rules(
          (select-rule,),
          elements: global-data.elements,
          settings: global-data.at("settings", default: default-global-data.settings),
          global: global-data.at("global", default: default-global-data.global)
        )
      }

      // Increase select rule counter for further select rules
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

  [#metadata(
    (
      (special-rule-key): "select",
      data-kind: "special-rule",
      kind: "select",
      version: element-version,
      filters: filters,
      computed: (filters-by-eid: filters-by-eid, labels-by-eid: labels-by-eid, ordered-eids: ordered-eids),
      receiver: receiver,
      prefix: prefix
    )
  )#lbl-special-rule-tag]
}

/// Apply filtered rules to a custom element's descendants
/// (but not to itself; for that use `cond-set`).
///
/// USAGE:
///
/// ```typ
/// #show: e.filtered(
///   elem,
///   e.set_(elem3, fields: ...)
/// )
/// ```
///
/// When applying many set rules at once, use 'apply' instead of 'set' on the last parameter.
///
/// - filter (filter): filter specifying which element instances should create this set rule
/// for their children.
/// - rule (rule): which rule to create under matched elements.
/// -> function
#let filtered(filter, rule) = {
  if type(filter) == function {
    filter = filter(__elembic_data: special-data-values.get-where)
  }
  assert(type(filter) == dictionary and filter-key in filter, message: "elembic: element.filtered: invalid filter, please use 'custom-element.with(...)' to generate a filter.")
  assert(type(rule) == function, message: "elembic: element.filtered: this is not a valid rule (not a function), please use functions such as 'set_' to create one.")
  assert("elements" in filter, message: "elembic: element.filtered: this filter is missing the 'elements' field; this indicates it comes from an element generated with an outdated elembic version. Please use an element made with an up-to-date elembic version.")
  assert(filter.elements != (:), message: "elembic: element.filtered: this filter appears to not be restricted to any elements and is thus impossible to match. It must apply to exactly one element (the one receiving the set rule). Consider using a different filter.")
  assert(filter.elements != none, message: "elembic: element.filtered: this filter appears to apply to any element (e.g. it's a 'not' or 'custom' filter). It must match only within a certain set of elements. Consider using an 'and' filter, e.g. 'e.filters.and(wibble, e.not(wibble.with(a: 10)))' instead of just 'e.not(wibble.with(a: 10))', to restrict it.")

  let rule = rule([]).children.last().value.rule
  let filtered-rule = ((prepared-rule-key): true, version: element-version, kind: "filtered", filter: filter, rule: rule, name: none, names: (), mode: rule.at("mode", default: auto))
  if rule.kind == "apply" {
    // Transpose filtered(filter, apply(a, b, c)) into apply(filtered(filter, a), filtered(filter, b), filtered(filter, c))
    let i = 0
    for inner-rule in rule.rules {
      assert(inner-rule.kind in ("show", "set", "revoke", "reset", "cond-set", "filtered"), message: "elembic: element.filtered: can only filter apply, show, set, revoke, reset, filtered and cond-set rules at this moment, not '" + inner-rule.kind + "'")

      rule.rules.at(i) = (..filtered-rule, rule: inner-rule, mode: inner-rule.at("mode", default: auto))

      i += 1
    }

    // Keep the apply but with everything filtered.
    prepare-rule(rule)
  } else {
    assert(rule.kind in ("show", "set", "revoke", "reset", "cond-set", "filtered"), message: "elembic: element.filtered: can only filter apply, show, set, revoke, reset, filtered and cond-set rules at this moment, not '" + rule.kind + "'")

    prepare-rule(filtered-rule)
  }
}

/// Apply a conditional set rule to a custom element. The set rule is only applied if
/// the given filter matches for that element.
///
/// Check out the Styling guide for more information.
///
/// Note that this function only accepts non-required fields (that have a `default`).
/// Any required fields must always be specified at call site and, as such, are always
/// going to be prioritized, so it is pointless to have set rules for those.
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
/// #show: e.cond-set(superbox.with(data: 10), fill: blue)
///
/// #superbox(data: 5) // this will have red fill
/// #superbox(data: 10) // this will have blue fill
/// ```
///
/// - filter (filter): filter specifying which element instances should receive this set rule.
/// - fields (arguments): optional fields to set (positionally or named, depending on the field)
/// -> function
#let cond-set(filter, ..fields) = {
  if type(filter) == function {
    filter = filter(__elembic_data: special-data-values.get-where)
  }
  assert(type(filter) == dictionary and filter-key in filter, message: "elembic: element.cond-set: invalid filter, please pass just 'custom-element' or use 'custom-element.with(...)' to generate a filter.")
  assert("elements" in filter, message: "elembic: element.cond-set: this filter is missing the 'elements' field; this indicates it comes from an element generated with an outdated elembic version. Please use an element made with an up-to-date elembic version.")
  assert(filter.elements != (:), message: "elembic: element.cond-set: this filter appears to not be restricted to any elements and is thus impossible to match. It must apply to exactly one element (the one receiving the set rule). Consider using a different filter.")
  assert(filter.elements != none, message: "elembic: element.cond-set: this filter appears to apply to any element. It must apply to exactly one element (the one receiving the set rule). Consider using an 'and' filter, e.g. 'e.filters.and(wibble, e.not(wibble.with(a: 10)))' instead of just 'e.not(wibble.with(a: 10))', to restrict it.")
  assert(filter.elements.len() == 1, message: "elembic: element.cond-set: this filter appears to apply to more than one element. It must apply to exactly one element (the one receiving the set rule).")
  let (eid, elem) = filter.elements.pairs().first()

  let (res, args) = (elem.parse-args)(fields, include-required: false)
  if not res {
    assert(false, message: args)
  }

  prepare-rule(
    ((prepared-rule-key): true, version: element-version, kind: "cond-set", name: none, names: (), mode: auto, filter: filter, element: (eid: elem.eid, default-data: elem.default-data, fields: elem.fields), args: args)
  )
}

/// Applies a show rule through the elembic stylechain, thus making it
/// revokable and also allowing easy usage of filters.
///
/// Show rules allow you to transform all occurrences of one or more elements,
/// replacing them with arbitrary document content.
///
/// For example:
///
/// ```typ
/// #show: e.show_(elem.with(fill: blue), it => [Hello *#it*!])
///
/// #elem(fill: red)[First]
/// #elem(fill: blue)[Second] // displays as "Hello *Second*!"
/// ```
///
/// - filter (filter): which element(s) to apply the rule to, with which fields etc.
/// - callback (function | content | str | none): replacement content or transformation function (content -> content)
/// receiving any matched elements and returning what to replace it with.
/// -> function
#let show_(filter, replacement, mode: auto) = {
  if type(filter) == function {
    filter = filter(__elembic_data: special-data-values.get-where)
  }
  assert(type(filter) == dictionary and filter-key in filter, message: "elembic: element.show_: invalid filter, please use 'custom-element.with(...)' to generate a filter.")
  assert(replacement == none or type(replacement) in (function, str, content), message: "elembic: element.show_: second parameter is not a valid show rule replacement or callback. Must be either a function 'it => content', or the content to unconditionally replace by (if it does not depend on the matched element). For example, you can write 'show: e.show_(elem, it => [*#it*])' to make an element bold, or 'show: e.show_(elem, [Hi])' to always replace it with the word 'Hi'.")

  let callback = replacement
  if type(replacement) != function {
    replacement = [#replacement]
    callback = _ => replacement
  }

  prepare-rule(((prepared-rule-key): true, version: element-version, kind: "show", filter: filter, callback: callback, name: none, names: (), mode: mode))
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
  assert(args.named() == (:), message: "elembic: element.apply: unexpected named arguments")
  assert(mode == auto or mode == style-modes.normal or mode == style-modes.leaky or mode == style-modes.stateful, message: "elembic: element.apply: invalid mode, must be auto or e.style-modes.(normal / leaky / stateful)")

  let rules = args.pos().map(
    rule => {
      assert(type(rule) == function, message: "elembic: element.apply: invalid rule of type " + str(type(rule)) + ", please use 'set_' or some other function from this library to generate it")

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

#let settings(..args, mode: auto) = {
  assert(args.pos() == (), message: "elembic: element.settings: unexpected positional args")
  let args = args.named()
  assert(args != (:), message: "elembic: element.settings: please specify some setting, e.g. e.settings(prefer-leaky: true)")

  let write = (:)
  let transform = ()
  for (key, val) in args {
    if key not in default-global-data.settings {
      assert(false, message: "elembic: element.settings: invalid setting '" + key + "', valid keys are " + default-global-data.settings.keys().map(repr).join(", "))
    }

    let default-setting = default-global-data.settings.at(key)
    if key in ("track-ancestry", "store-ancestry") and val != "any" {
      if type(val) == array {
        let new-elements = (:)
        for elem in val {
          if type(elem) == function {
            elem = data(elem)
          }
          if type(elem) != dictionary or "eid" not in elem {
            assert(false, message: "elembic: element.settings: expected array of elements or literal \"any\" (apply to any element) for setting '" + key + "', got array of '" + str(type(elem)) + "'")
          }

          new-elements.insert(elem.eid, elem)
        }

        if new-elements != (:) {
          transform.push(s => {
            let existing = if s != none and key in s { s.at(key) } else { (:) }
            if existing == "any" {
              // Nothing to change, already applies to all elements
              s
            } else {
              (:..s, (key): (:) + existing + new-elements)
            }
          })
        }
      } else {
        assert(false, message: "elembic: element.settings: expected array of elements or literal \"any\" (apply to any element) for setting '" + key + "', got '" + str(type(val)) + "'")
      }
    } else if key == "prefer-leaky" and type(val) != type(default-setting) {
      assert(false, message: "elembic: element.settings: expected type of '" + str(type(default-setting)) + "' for setting '" + key + "', got '" + str(type(val)) + "'")
    } else {
      write.insert(key, val)
    }
  }

  let transform = if transform == () {
    none
  } else if transform.len() == 1 {
    transform.first()
  } else {
    s => transform.fold(s, (acc, fun) => fun(acc))
  }

  prepare-rule(((prepared-rule-key): true, version: element-version, kind: "settings", write: write, transform: transform, mode: mode))
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
#let named(..names, rule) = {
  assert(names.named() == (:), message: "elembic: element.named: unexpected named arguments")
  let names = names.pos()
  assert(names != (), message: "elembic: element.named: expected at least two arguments (one or more names and a rule)")
  assert(type(rule) == function, message: "elembic: element.named: last parameter is not a valid rule (not a function), please use functions such as 'set_' to create one.")
  for name in names {
    assert(type(name) == str, message: "elembic: element.named: rule name must be a string, not " + str(type(name)))
    assert(name != "", message: "elembic: element.named: name must not be empty")
  }

  // For backwards compatibility when only one name was possible
  let compat-name = names.last()
  let rule = rule([]).children.last().value.rule
  if rule.kind == "apply" {
    let i = 0
    for inner-rule in rule.rules {
      assert(inner-rule.kind in ("show", "set", "revoke", "reset", "filtered", "cond-set"), message: "elembic: element.named: can only name show, set, revoke, reset, filtered and cond-set rules at this moment, not '" + inner-rule.kind + "'")

      rule.rules.at(i).name = compat-name

      if "names" in inner-rule {
        rule.rules.at(i).names += names
      } else {
        rule.rules.at(i).names = names
      }

      i += 1
    }
  } else {
    assert(rule.kind in ("show", "set", "revoke", "reset", "filtered", "cond-set"), message: "elembic: element.named: can only name show, set, revoke, reset, filtered and cond-set rules at this moment, not '" + rule.kind + "'")
    rule.name = compat-name

    if "names" in rule {
      rule.names += names
    } else {
      rule.names = names
    }
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
  assert(type(name) == str, message: "elembic: element.revoke: rule name must be a string, not " + str(type(name)))
  assert(mode == auto or mode == style-modes.normal or mode == style-modes.leaky or mode == style-modes.stateful, message: "elembic: element.revoke: invalid mode, must be auto or e.style-modes.(normal / leaky / stateful)")

  prepare-rule(((prepared-rule-key): true, version: element-version, kind: "revoke", revoking: name, name: none, names: (), mode: mode))
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
  assert(args.named() == (:), message: "elembic: element.reset: unexpected named arguments")
  assert(mode == auto or mode == style-modes.normal or mode == style-modes.leaky or mode == style-modes.stateful, message: "elembic: element.reset: invalid mode, must be auto or e.style-modes.(normal / leaky / stateful)")

  let filters = args.pos().map(it => if type(it) == function { data(it) } else { it })
  assert(filters.all(x => type(x) == dictionary and "eid" in x), message: "elembic: element.reset: invalid arguments, please provide a function or element data with at least an 'eid'")

  prepare-rule(((prepared-rule-key): true, version: element-version, kind: "reset", eids: filters.map(x => x.eid), name: none, names: (), mode: mode))
}

// Stateful variants
#let stateful-set(..args) = {
  apply(set_(..args), mode: style-modes.stateful)
}
#let stateful-cond-set(..args) = {
  apply(cond-set(..args), mode: style-modes.stateful)
}
#let stateful-settings = settings.with(mode: style-modes.stateful)
#let stateful-apply = apply.with(mode: style-modes.stateful)
#let stateful-show = show_.with(mode: style-modes.stateful)
#let stateful-revoke = revoke.with(mode: style-modes.stateful)
#let stateful-reset = reset.with(mode: style-modes.stateful)

// Leaky variants
#let leaky-set(..args) = {
  apply(set_(..args), mode: style-modes.leaky)
}
#let leaky-cond-set(..args) = {
  apply(cond-set(..args), mode: style-modes.leaky)
}
#let leaky-settings = settings.with(mode: style-modes.leaky)
#let leaky-apply = apply.with(mode: style-modes.leaky)
#let leaky-show = show_.with(mode: style-modes.leaky)
#let leaky-revoke = revoke.with(mode: style-modes.leaky)
#let leaky-reset = reset.with(mode: style-modes.leaky)

#let leaky-toggle(enable) = leaky-settings(prefer-leaky: enable)

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
    let was-not-revoked = (
      (
        "names" not in revoke or revoke.names.all(n => n not in active-revokes)
      )
      and (
        "names" in revoke or "name" not in revoke or revoke.name == none or revoke.name not in active-revokes
      )
    )

    if revoke.kind == "revoke" and revoke.revoking not in active-revokes and was-not-revoked {
      active-revokes.insert(revoke.revoking, revoke.index)
    } else if revoke.kind == "reset" and was-not-revoked {
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
      if data != none and (
        "names" in data and data.names.any(n => n in active-revokes and i < active-revokes.at(n))
        or "names" not in data and "name" in data and data.name in active-revokes and i < active-revokes.at(data.name)
      ) {
        // Nullify changes at this stage
        chain.at(i) = (:)
      }

      i += 1
    }

    for (field-name, fold-data) in fold-chain {
      let filtered-data = fold-data.data.filter(d => (
        // Only keep data without a name in the revoked name map, or, if the
        // name is there, then data that came after the name was revoked.
        ("names" not in d or d.names.all(n => n not in active-revokes or d.index >= active-revokes.at(n)))
        and ("names" in d or "name" not in d or (d.name == none or d.name not in active-revokes or d.index >= active-revokes.at(d.name)))
      ))
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

  (folded: final-values, active-revokes: active-revokes, first-active-index: first-active-index)
}

// Retrieves the final chain data for an element, after applying all set rules so far.
#let get-styles(element, elements: (:), use-routine: false) = {
  if type(element) == function {
    element = data(element)
  }
  let (eid, default-fields) = if type(element) == dictionary and "eid" in element and "default-fields" in element {
    (element.eid, element.default-fields)
  } else {
    assert(false, message: "elembic: element.get: expected element (function / data dictionary), received " + str(type(element)))
  }

  if (
    use-routine
    and ("version" not in element or element.version != element-version)
    and "routines" in element
    and "get-styles" in element.routines
    and type(element.routines.get-styles) == function
  ) {
    // Use the element's own "get styles".
    return (element.routines.get-styles)(element, elements: elements)
  }

  let element-data = elements.at(eid, default: default-data)
  let folded-chain = if element-data.revoke-chain == default-data.revoke-chain and element-data.fold-chain == default-data.fold-chain {
    element-data.chain.sum(default: (:))
  } else {
    fold-styles(element-data.chain, element-data.data-chain, element-data.revoke-chain, element-data.fold-chain).folded
  }

  // No need to do extra folding like in constructor:
  // if a foldable field hasn't been specified, it is either equal to
  // its default, or it is a required field which has no default and
  // thus it is not returned here since it can't be set.
  default-fields + folded-chain
}

/// Reads the current values of element fields after applying set rules.
/// Must be in a context block.
///
/// This is a stateful version, which doesn't require a callback, but only
/// works on stateful mode (less performant).
///
/// USAGE:
/// ```typ
/// #show: e.set_(elem, fill: green)
/// // ...
/// #context {
///   // OK
///   assert(e.stateful.get(elem).fill == green)
/// }
/// ```
///
/// - receiver (function): function ('get' function) -> content
/// -> content
#let stateful-get(element) = {
  let chain = style-state.get()
  let global-data = if chain == () {
    default-global-data
  } else {
    chain.last()
  }

  assert(
    global-data.stateful,
    message: "elembic: stateful.get: cannot use this function without enabling the global stateful toggle\n  hint: if you don't mind the performance hit, write '#show: e.stateful.enable()' somewhere above the 'context {}' in which this call happens, or at the top of the document to apply to all rules as well"
  )

  get-styles(element, elements: global-data.elements, use-routine: true)
}

/// Used for debugging elembic. Stateful version of `debug-get`.
#let stateful-debug-get() = {
  let chain = style-state.get()
  let global-data = if chain == () {
    default-global-data
  } else {
    chain.last()
  }

  assert(
    global-data.stateful,
    message: "elembic: stateful.debug-get: cannot use this function without enabling the global stateful toggle\n  hint: if you don't mind the performance hit, write '#show: e.stateful.enable()' somewhere above the 'context {}' in which this call happens, or at the top of the document to apply to all rules as well"
  )

  let getter = get-styles.with(elements: global-data.elements, use-routine: true)
  (:..global-data, ctx: (get: getter))
}

#let _is-get(body) = (
  type(body) == content
    and body.func() == sequence
    and body.children.len() == 2  // [#context{...}#metadata(get-meta)#lbl-special-rule-tag]
    and body.children.last().func() == metadata
    and body.at("label", default: none) == none
    and body.children.last().at("label", default: none) == lbl-special-rule-tag
    and body.children.last().value.kind == "get"
)

#let _recurse-get(body, elements: none) = {
  let get-meta = body.children.last().value

  if "__future" in get-meta and element-version <= get-meta.__future.max-version {
    let res = (get-meta.__future.call)(body, __future-version: element-version)

    if "doc" in res {
      res.doc
    }
  } else if "receiver" in get-meta and type(get-meta.receiver) == function {
    // Pick up updates from filtered rules
    let getter = get-styles.with(elements: elements, use-routine: true)
    (get-meta.receiver)(getter)
  }
}

#let prepare-ctx(receiver, include-global: false) = context {
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

    let getter = get-styles.with(elements: global-data.elements, use-routine: true)
    let body = if include-global {
      receiver((:..global-data, ctx: (get: getter)))
    } else {
      receiver(getter)
    }

    // Optimization: flatten 'get'
    while _is-get(body) { body = _recurse-get(body, elements: global-data.elements) }
    body
  }#lbl-get]
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
/// - receiver (function): function ('get' function) -> content
/// -> content
#let prepare-get(receiver) = {
  let output = prepare-ctx(include-global: false, receiver)
  [#output#metadata(((special-rule-key): "get", data-kind: "special-rule", kind: "get", version: element-version, receiver: receiver))#lbl-special-rule-tag]
}

/// Used for debugging elembic. Passes the internal style chain information.
#let prepare-debug(receiver) = {
  let output = prepare-ctx(include-global: true, receiver)
  [#output#metadata(((special-rule-key): "debug-get", data-kind: "special-rule", kind: "debug-get", version: element-version, receiver: receiver))#lbl-special-rule-tag]
}

// Obtain a Typst selector to use to match this element in show rules or in the outline.
// Specify 'meta: true' to match this element in a query, as that selector is
// generated once regardless of show rules.
#let elem-selector(elem, outline: false, outer: false, meta: false) = {
  if outline {
    assert(not outer, message: "elembic: element.selector: cannot have 'outline: true' and 'outer: true' at the same time, please pick one selector")
    assert(not meta, message: "elembic: element.selector: cannot have 'outline: true' and 'meta: true' at the same time, please pick one selector")
    let elem-data = data(elem)
    assert("outline-sel" in elem-data, message: "elembic: element.selector: this isn't a valid element")
    assert(elem-data.outline-sel != none, message: "elembic: element.selector: this element isn't outlinable\n  hint: try asking its author to define it as such with 'outline: auto', 'outline: (caption: [...])' or 'outline: (caption: it => ...)'")
    elem-data.outline-sel
  } else if outer {
    assert(not meta, message: "elembic: element.selector: cannot have 'outer: true' and 'meta: true' at the same time, please pick one selector")
    data(elem).outer-sel
  } else if meta {
    let elem-data = data(elem)
    elem-data.at("meta-sel", default: elem-data.sel)
  } else {
    data(elem).sel
  }
}

#let elem-query(filter, before: none, after: none) = {
  if type(filter) == function {
    filter = filter(__elembic_data: special-data-values.get-where)
  }

  if type(filter) != dictionary or filter-key not in filter {
    if type(filter) == selector {
      assert(false, message: "elembic: element.query: Typst-native selectors cannot be specified here, only those of custom elements")
    }
    assert(false, message: "elembic: element.query: expected a valid filter, such as 'custom-element' or 'custom-element.with(field-name: value, ...)', got " + base.typename(filter))
  }

  assert("elements" in filter, message: "elembic: element.query: this filter is missing the 'elements' field; this indicates it comes from an element generated with an outdated elembic version. Please use an element made with an up-to-date elembic version.")
  assert(filter.elements != none, message: "elembic: element.query: this filter appears to apply to any element (e.g. it's a 'not' or 'custom' filter). It must match only within a certain set of elements. Consider using an 'and' filter, e.g. 'e.filters.and(wibble, e.not(wibble.with(a: 10)))' instead of just 'e.not(wibble.with(a: 10))', to restrict it.")

  let results = ()
  for (eid, elem-data) in filter.elements {
    if "meta-sel" in elem-data {
      let sel = elem-data.meta-sel
      if before != none {
        sel = selector(sel).before(before)
      }
      if after != none {
        sel = selector(sel).after(after)
      }

      results += query(sel).filter(
        instance => (
          instance.func() == metadata
            and {
              let meta = data(instance.value)

              verify-filter(
                meta.at("fields", default: (:)),
                eid: eid,
                filter: filter,
                ancestry: if "may-need-ancestry" in filter and filter.may-need-ancestry and meta.at("ctx", default: none) != none and "ancestry" in meta.ctx {
                  meta.ctx.ancestry
                } else {
                  ()
                }
              ) and "rendered" in instance.value
            }
        )
      ).map(
        instance => instance.value.rendered
      )
    } else if "sel" in elem-data {
      let sel = elem-data.sel
      if before != none {
        sel = selector(sel).before(before)
      }
      if after != none {
        sel = selector(sel).after(after)
      }
      // This element is probably too outdated to have ancestry checks anyway, so we don't bother
      results += query(sel).filter(instance => verify-filter(data(instance).at("fields", default: (:)), eid: eid, filter: filter, ancestry: ()))
    } else {
      assert(false, message: "elembic: element.query: filter did not have the element's meta selector")
    }
  }

  results
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
  assert(args.named() == (:), message: "elembic: element.prepare: unexpected named arguments")
  let default-rules = doc => {
    show ref: ref_

    doc
  }

  if args.pos() == () {
    return default-rules
  }

  let elems = args.pos().map(data)

  if elems.len() == 1 and type(args.pos().first()) == content {
    assert(false, message: "elembic: element.prepare: expected (optional) element functions as arguments, not the document\n  hint: write '#show: e.prepare()', not '#show: e.prepare' - note the parentheses")
  }

  assert(elems.all(it => it.data-kind == "element"), message: "elembic: element.prepare: positional arguments must be elements")
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
/// - doc (none | str): The element's documentation, if any.
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
  doc: none,
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
  assert(type(display) == function, message: "elembic: element.declare: please specify a show rule in 'display:' to determine how your element is displayed.")

  let fields-hint = if type(fields) == dictionary { "\n  hint: check if you didn't forget to add a trailing comma for a single field: write 'fields: (field,)', not 'fields: (field)'" } else { "" }
  assert(type(fields) == array, message: "elembic: element.declare: please specify an array of fields, creating each field with the 'field' function. It can be empty with '()'." + fields-hint)
  assert(doc == none or type(doc) == str, message: "elembic: element.declare: 'doc' must be none or a string (add documentation)")
  assert(prefix != none, message: "elembic: element.declare: please specify a 'prefix: ...' for your type, to distinguish it from types with the same name. If you are writing a package or template to be used by others, please do not use an empty prefix.")
  assert(type(prefix) == str, message: "elembic: element.declare: the prefix must be a string, not '" + str(type(prefix)) + "'")
  assert(parse-args == auto or type(parse-args) == function, message: "elembic: element.declare: 'parse-args' must be either 'auto' (use built-in parser) or a function (default arg parser, fields: dictionary, typecheck: bool) => (user arguments, include-required: true (required fields must be specified - in constructor) / false (required fields must be omitted - in set rules)) => (bool (true on success, false on error), dictionary with parsed fields (or error message string if the bool is false)).")
  assert(type(typecheck) == bool, message: "elembic: element.declare: the 'typecheck' argument must be a boolean (true to enable typechecking, false to disable).")
  assert(type(allow-unknown-fields) == bool, message: "elembic: element.declare: the 'allow-unknown-fields' argument must be a boolean.")
  assert(template == none or type(template) == function, message: "elembic: element.declare: 'template' must be 'none' or a function displayed element => content (usually set rules applied on the displayed element). This is used to add a set of overridable set rules to the element, such as paragraph settings.")
  assert(prepare == none or type(prepare) == function, message: "elembic: element.declare: 'prepare' must be 'none' or a function (element, document) => styled document (used to apply show and set rules to the document).")
  assert(count == none or type(count) == function, message: "elembic: element.declare: 'count' must be 'none', a function counter => counter step/update element, or a function counter => final fields => counter step/update element.")
  assert(synthesize == none or type(synthesize) == function, message: "elembic: element.declare: 'synthesize' must be 'none' or a function element fields => element fields.")
  assert(contextual == auto or type(contextual) == bool, message: "elembic: element.declare: 'contextual' must be 'auto' (true if using a contextual feature) or a boolean (true to wrap the output in a 'context { ... }', false to not).")
  assert(construct == none or type(construct) == function, message: "elembic: element.declare: 'construct' must be 'none' (use default constructor) or a function receiving the original constructor and returning the new constructor.")
  assert(scope == none or type(scope) in (dictionary, module), message: "elembic: element.declare: 'scope' must be either 'none', a dictionary or a module")
  assert(type(labelable) == bool, message: "elembic: element.declare: 'labelable' must be a boolean (true to enable the special 'label' constructor argument, false to disable it)")
  assert(
    reference == none
    or type(reference) == dictionary
      and reference.keys().all(x => x in ("supplement", "numbering", "custom"))
      and ("supplement" not in reference or reference.supplement == none or type(reference.supplement) in (str, content, function))
      and ("numbering" not in reference or reference.numbering == none or type(reference.numbering) in (str, function))
      and ("custom" not in reference or reference.custom == none or type(reference.custom) == function),
    message: "elembic: element.declare: 'reference' must be 'none' or a dictionary (supplement: \"Name\" or [Name] or function fields => supplement, numbering: \"1.\" or function fields => (str / function numbers => content), custom (optional): none (default) or function fields => content)."
  )
  assert(
    reference == none or "supplement" in reference and "numbering" in reference or "custom" in reference,
    message: "elembic: element.declare: reference must either have 'custom', or have both 'supplement' and 'numbering' (or all three, though 'custom' has priority when displaying references)."
  )
  assert(
    outline == none
    or outline == auto
    or type(outline) == dictionary
      and "caption" in outline,
    message: "elembic: element.declare: 'outline' must be 'none', 'auto' (to use data from 'reference') or a dictionary with 'caption'."
  )
  assert(outline != auto or reference != none, message: "elembic: element.declare: if 'outline' is set to 'auto', 'reference' must be specified and not be 'none'.")
  assert(labelable or reference == none, message: "elembic: element.declare: 'labelable' must be true for 'reference' to not be 'none'")

  // All element args as originally provided.
  let elem-args = arguments(
    name,
    display: display,
    fields: fields,
    prefix: prefix,
    doc: doc,
    parse-args: parse-args,
    typecheck: typecheck,
    allow-unknown-fields: allow-unknown-fields,
    template: template,
    prepare: prepare,
    construct: construct,
    scope: scope,
    count: count,
    labelable: labelable,
    reference: reference,
    outline: outline,
    synthesize: synthesize,
    contextual: contextual,
  )

  if contextual == auto {
    // Provide separate context for synthesize.
    // By default, assume it isn't needed.
    contextual = synthesize != none
  }

  let eid = base.unique-id("e", prefix, name)
  let lbl-show = label(lbl-show-head + eid)
  let lbl-meta = label(lbl-meta-head + eid)
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
    assert(false, message: "elembic: element.declare: labelable element cannot have a conflicting 'label' field\n  hint: you can set 'labelable: false' to disable the special label parameter, but note that it will then be impossible to refer to your element")
  }

  let default-arg-parser = field-internals.generate-arg-parser(
    fields: fields,
    general-error-prefix: "elembic: element '" + name + "': ",
    field-error-prefix: field-name => "field '" + field-name + "' of element '" + name + "': ",
    typecheck: typecheck
  )

  let parse-args = if parse-args == auto {
    default-arg-parser
  } else {
    let parse-args = parse-args(default-arg-parser, fields: fields, typecheck: typecheck)
    if type(parse-args) != function {
      assert(false, message: "elembic: element.declare: 'parse-args', when specified as a function, receives the default arg parser alongside `fields: fields dictionary` and `typecheck: bool`, and must return a function (the new arg parser), and not " + base.typename(parse-args))
    }

    parse-args
  }

  let default-fields = fields.user-fields.values().map(f => if f.required { (:) } else { ((f.name): f.default) }).sum(default: (:))

  let set-rule = set_.with((parse-args: parse-args, eid: eid, default-data: default-data, fields: fields))

  let get-rule(receiver) = prepare-get(g => receiver(g((eid: eid, default-fields: default-fields))))

  // Partial version of element data to store in filters.
  let partial-element-data = (
    version: element-version,
    name: name,
    doc: doc,
    eid: eid,
    parse-args: parse-args,
    default-data: default-data,
    default-global-data: default-global-data,
    fields: fields,
    sel: lbl-show,
    meta-sel: lbl-meta,
    routines: (
      prepare-rule: prepare-rule,
      apply-rules: apply-rules,
      get-styles: get-styles,
      fold-styles: fold-styles,
      verify-filter: verify-filter,
      select: select,
      toggle-stateful: toggle-stateful-mode,
      settings: settings
    )
  )

  // Prepare a filter which should be passed to 'select()'.
  // This function will specify which field values for this
  // element should be matched.
  let where(func) = (..args) => {
    assert(args.pos().len() == 0, message: "elembic: unexpected positional arguments\nhint: here, specify positional fields as named arguments, using their names")
    let args = args.named()

    if not allow-unknown-fields {
      // Note: 'where' on synthesized fields is legal,
      // so we check 'all-fields' rather than 'user-fields'.
      let unknown-fields = args.keys().filter(k => k not in all-fields and (not labelable or k != "label"))
      if unknown-fields != () {
        let s = if unknown-fields.len() == 1 { "" } else { "s" }
        assert(false, message: "elembic: element.where: element '" + name + "': unknown field" + s + " " + unknown-fields.map(f => "'" + f + "'").join(", "))
      }
    }

    (
      (filter-key): true,
      element-version: element-version,
      kind: "where",
      eid: eid,
      fields: args,
      sel: lbl-show,
      elements: ((eid): (:..partial-element-data, func: func)),
      ancestry-elements: (:),
      may-need-ancestry: false,
    )
  }

  let elem-data = (
    (element-key): true,
    version: element-version,
    name: name,
    doc: doc,
    eid: eid,
    scope: scope,
    set_: set-rule,
    get: get-rule,
    where: none, // Filled later when func is known
    sel: lbl-show,
    meta-sel: lbl-meta,
    outer-sel: lbl-outer,
    outline-sel: if outline == none { none } else { figure.where(kind: ref-figure-kind) },
    counter: element-counter,
    parse-args: parse-args,
    default-data: default-data,
    default-global-data: default-global-data,
    default-fields: default-fields,
    routines: partial-element-data.routines,
    user-fields: user-fields,
    all-fields: all-fields,
    fields: fields,
    typecheck: typecheck,
    allow-unknown-fields: allow-unknown-fields,
    template: template,
    prepare: prepare,
    default-constructor: none,
    func: none,
    elem-args: elem-args,
  )

  // Figure placed for referencing to work.
  let ref-figure(tag, synthesized-fields, ref-label) = {
    let numbering = if numbering-type == str {
      reference.numbering
    } else if numbering-type == function {
      let numbering = (reference.numbering)(synthesized-fields)
      assert(type(numbering) in (str, function), message: "elembic: element: 'reference.numbering' must be a function fields => numbering (a string or a function), but returned " + str(type(numbering)))
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

      ..if sys.version >= version(0, 12, 0) {
        (placement: none, scope: "column")
      },

      ..caption
    )[#[]#metadata(tag)#lbl-tag]#ref-label]

    let tagged-figure = [#[#ref-figure#metadata(tag)#lbl-tag]#lbl-ref-figure]

    show figure: none

    tagged-figure
  }

  let apply-show-rules(body, rule, show-rules) = {
    if rule >= show-rules.len() {
      rule = show-rules.len() - 1
    } else if rule < 0 {
      assert(false, message: "elembic: internal error: show rule index cannot be negative")
    }

    // Show rules are applied from last to first.
    // The first is the base case.
    if rule == 0 {
      show: show-rules.at(rule)
      body
    } else {
      // Don't recursively apply show rules immediately.
      // Do it lazily through a matching show rule.
      // This is so that a show rule that doesn't place down 'it'
      // stops further show rules from executing.
      //
      // We could use 'context' for this, but then the show rule
      // limit is lower even for 'it => it' (60 vs 30). It is always
      // lower when the show rule is of the form 'it => element(it)',
      // however, but it still feels like a waste to force it to be
      // lower in all cases.
      let lbl-tmp-show = label(str(lbl-show) + "-rule" + str(rule))
      (show-rules.at(rule))({
        // Take just the first child to remove the label.
        // Add tag AFTER the show rule so data() can still pick it up.
        show lbl-tmp-show: it => apply-show-rules(it.children.first(), rule - 1, show-rules)
        [#[#body#[]]#lbl-tmp-show]
      } + [#metadata(data(body))#lbl-tag])
    }
  }

  // Sentinel for 'unspecified value'
  let _missing() = {}
  let std-label = label

  let default-constructor(..args, __elembic_data: none, __elembic_func: auto, __elembic_mode: auto, __elembic_settings: (:), label: _missing) = {
    if __elembic_func == auto {
      __elembic_func = default-constructor
    }

    let default-constructor = default-constructor.with(__elembic_func: __elembic_func)
    if __elembic_data != none {
      return if __elembic_data == special-data-values.get-data {
        (data-kind: "element", ..elem-data, func: __elembic_func, default-constructor: default-constructor, where: where(__elembic_func))
      } else if __elembic_data == special-data-values.get-where {
        if label == _missing {
          where(__elembic_func)(..args)
        } else {
          where(__elembic_func)(..args, label: label)
        }
      } else {
        assert(false, message: "elembic: element: invalid data key to constructor: " + repr(__elembic_data))
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
        assert(false, message: "elembic: element '" + name + "': expected label or 'none' for 'label', found " + base.typename(label))
      }
    } else if label == _missing {
      label = none
    } else {
      // Also parse label as a field if we don't want element to be labelable
      args = arguments(..args, label: label)
    }

    let (res, args) = parse-args(args, include-required: true)
    if not res {
      assert(false, message: args)
    }

    // Step the counter early if we don't need additional context
    let early-step = if not count-needs-fields { count }

    let inner = early-step + [#context {
      let previous-bib-title = bibliography.title
      [#context {
        set bibliography(title: previous-bib-title)

        // Only update style chain if needed, e.g. filtered rules
        let data-changed = false
        let global-data = if (
          type(bibliography.title) == content
          and bibliography.title.func() == metadata
          and bibliography.title.at("label", default: none) == lbl-data-metadata
        ) {
          bibliography.title.value
        } else {
          (..default-global-data, first-bib-title: previous-bib-title)
        }

        let is-stateful = global-data.stateful
        if is-stateful {
          let chain = style-state.get()
          global-data = if chain == () {
            default-global-data
          } else {
            chain.last()
          }
        }

        let ancestry = ()
        let synthesized-futures = ()  // forward-compat callbacks which need synthesized fields
        if "global" in global-data {
          if "ancestry-chain" in global-data.global {
            ancestry = global-data.global.ancestry-chain
          }

          // For set rules from the future...
          if "__futures" in global-data.global and "global-data" in global-data.global.__futures {
            for future in global-data.global.__futures.global-data {
              if element-version <= future.max-version {
                let res = (future.call)(
                  global-data: global-data,
                  element-data: global-data.elements.at(eid, default: default-data),
                  args: args,
                  all-element-data: (data-kind: "element", ..elem-data, func: __elembic_func, default-constructor: default-constructor, where: where(__elembic_func)),
                  __future-version: element-version
                )

                if "global-data" in res {
                  global-data = res.global-data
                  if "data-changed" in res {
                    // Maybe we don't want to forward changes to children
                    // More efficient etc.
                    data-changed = data-changed or res.data-changed
                  } else {
                    // Assume we want to forward these changes to children
                    data-changed = true
                  }
                }

                continue
              }
            }
          }
        }

        let element-data = global-data.elements.at(eid, default: default-data)

        if "__futures" in element-data {
          if "construct" in element-data.__futures {
            for future in element-data.__futures.construct {
              if element-version <= future.max-version {
                let res = (future.call)(
                  global-data: global-data,
                  element-data: element-data,
                  args: args,
                  all-element-data: (data-kind: "element", ..elem-data, func: __elembic_func, default-constructor: default-constructor, where: where(__elembic_func)),
                  __future-version: element-version
                )

                if "construct" in res {
                  return res.construct
                }
              }
            }
          }

          if "element-data" in element-data.__futures {
            for future in element-data.__futures.element-data {
              if element-version <= future.max-version {
                let res = (future.call)(
                  global-data: global-data,
                  element-data: element-data,
                  args: args,
                  all-element-data: (data-kind: "element", ..elem-data, func: __elembic_func, default-constructor: default-constructor, where: where(__elembic_func)),
                  __future-version: element-version
                )

                if "construct" in res {
                  return res.construct
                }

                if "element-data" in res {
                  element-data = res.element-data
                }
              }
            }
          }

          if "synthesized-fields" in element-data.__futures {
            synthesized-futures += element-data.__futures.synthesized-fields.filter(f => element-version <= f.max-version)
          }
        }

        let has-synthesized-futures = synthesized-futures != ()
        let settings = if "settings" in global-data { global-data.settings } else { default-global-data.settings }
        let filters = element-data.at("filters", default: default-data.filters)
        let has-filters = filters.all != ()
        let cond-sets = element-data.at("cond-sets", default: default-data.cond-sets)
        let has-cond-sets = cond-sets.args != ()
        let show-rules = element-data.at("show-rules", default: default-data.show-rules)
        let has-show-rules = show-rules.callbacks != ()
        let selects = element-data.at("selects", default: default-data.selects)
        let has-selects = selects.filters != ()
        let has-ancestry-tracking = (
          // Either a rule with a 'within(this element)' filter was used, or
          // the user specifically requested ancestry tracking.
          element-data.at("track-ancestry", default: default-data.track-ancestry)
          or "track-ancestry" in settings and (
            settings.track-ancestry == "any"
            or eid in settings.track-ancestry
          )
        )

        // Whether ancestry should be made available in a query() for this
        // element, allowing usage of 'within()' rules for that element in a
        // query.
        let store-ancestry = has-ancestry-tracking or "store-ancestry" in settings and (
          settings.store-ancestry == "any"
          or eid in settings.store-ancestry
        )

        let updates-stylechain-inside = has-filters or has-ancestry-tracking

        let (folded-fields, constructed-fields, active-revokes, first-active-index) = if (
          element-data.revoke-chain == default-data.revoke-chain
          and (
            foldable-fields == (:)
            or element-data.fold-chain == default-data.fold-chain
            and args.keys().all(f => f not in foldable-fields)
          )
        ) {
          let folded-fields = default-fields + element-data.chain.sum(default: (:))
          // Sum the chain of dictionaries so that the latest value specified for
          // each property wins.
          (folded-fields, folded-fields + args, (:), 0)
        } else {
          // We can't just sum, we need to filter and fold first.
          // Memoize this operation through a function.
          let (folded, active-revokes, first-active-index) = fold-styles(element-data.chain, element-data.data-chain, element-data.revoke-chain, element-data.fold-chain)
          let outer-chain = default-fields + folded
          let finalized-chain = outer-chain + args

          // Fold received arguments with outer chain or defaults
          for (field-name, fold-data) in foldable-fields {
            if field-name in args {
              let outer = outer-chain.at(field-name, default: fold-data.default)
              if fold-data.folder == auto {
                finalized-chain.insert(field-name, outer + args.at(field-name))
              } else {
                finalized-chain.insert(field-name, (fold-data.folder)(outer, args.at(field-name)))
              }
            }
          }

          (outer-chain, finalized-chain, active-revokes, first-active-index)
        }

        let filter-revokes
        let filter-first-active-index
        let editable-global-data
        if has-filters or has-synthesized-futures {
          // The closures inside context {} below will capture global-data,
          // reducing potential for memoization of their output, so, for
          // performance reasons, we only pass the real global data if
          // necessary due to filtering (which will update the data on a
          // match).
          editable-global-data = global-data
          filter-revokes = active-revokes
          filter-first-active-index = first-active-index
        } else if has-cond-sets or has-show-rules or has-selects {
          // No need for global data, but still need revokes to see which
          // conditional sets were revoked
          filter-revokes = active-revokes
          filter-first-active-index = first-active-index
          if updates-stylechain-inside {
            editable-global-data = global-data
          }
        } else if updates-stylechain-inside {
          editable-global-data = global-data
        }

        let cond-set-foldable-fields
        if has-cond-sets {
          cond-set-foldable-fields = foldable-fields
        }

        let all-elem-data-for-futures
        let element-data-for-futures
        if has-synthesized-futures {
          all-elem-data-for-futures = (data-kind: "element", ..elem-data, func: __elembic_func, default-constructor: default-constructor, where: where(__elembic_func))
          element-data-for-futures = element-data
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
              // Note: we add ancestry later if there is ancestry tracking
              // to avoid interfering with memoization of other things
              (get: get-styles.with(elements: global-data.elements), ancestry: ancestry)
            } else {
              (:)
            },
            counter: element-counter,
            reference: reference,
            custom-ref: none,
            fields-known: true,
            valid: true
          )

          {
            // Use context for synthesize as well
            let synthesized-fields = if synthesize == none {
              constructed-fields
            } else {
              // Pass contextual information to synthesize
              // Remove it afterwards to ensure the final tag's 'fields' won't
              // have its own copy of the tag
              let new-fields = synthesize(constructed-fields + ((stored-data-key): tag))
              if type(new-fields) != dictionary {
                assert(false, message: "elembic: element '" + name + "': 'synthesize' didn't return a dictionary, but rather " + repr(new-fields) + " (a(n) '" + str(type(new-fields)) + "') instead). Please contact the element author.")
              }
              if stored-data-key in new-fields {
                _ = new-fields.remove(stored-data-key)
              }
              new-fields
            }

            if labelable and label != none and label != _missing {
              synthesized-fields.label = label
            }

            // Update synthesized fields BEFORE applying filters!
            if has-cond-sets {
              let i = 0
              let new-synthesized-fields = folded-fields // only add args later (args must win)
              let affected-fields = (:)
              for filter in cond-sets.filters {
                let data = cond-sets.data.at(i)
                if (
                  filter != none
                  and (data.index == none or data.index >= filter-first-active-index)
                  and data.names.all(n => n not in filter-revokes or data.index == none or data.index >= filter-revokes.at(n))
                  and verify-filter(synthesized-fields, eid: eid, filter: filter, ancestry: if "may-need-ancestry" in filter and filter.may-need-ancestry { ancestry } else { () })
                ) {
                  let cond-args = cond-sets.args.at(i)

                  affected-fields += cond-args

                  // Fold received arguments with existing fields or defaults
                  for (field-name, value) in cond-args {
                    if field-name in cond-set-foldable-fields {
                      let fold-data = cond-set-foldable-fields.at(field-name)
                      let outer = new-synthesized-fields.at(field-name, default: fold-data.default)
                      if fold-data.folder == auto {
                        new-synthesized-fields.insert(field-name, outer + value)
                      } else {
                        new-synthesized-fields.insert(field-name, (fold-data.folder)(outer, value))
                      }
                    } else {
                      new-synthesized-fields.insert(field-name, value)
                    }
                  }
                }
                i += 1
              }

              // Fold args again (they must win).
              for (field-name, value) in synthesized-fields {
                if field-name not in args {
                  // Not an argument, and we already folded it with cond-sets
                  // before (not a synthesized field), so stop.
                  continue
                }

                if (
                  field-name in affected-fields
                  and field-name in cond-set-foldable-fields
                  // If field was changed due to synthetization, don't allow
                  // folding it further
                  and constructed-fields.at(field-name) == value
                ) {
                  let fold-data = cond-set-foldable-fields.at(field-name)
                  if fold-data.folder == auto {
                    new-synthesized-fields.at(field-name) += args.at(field-name)
                  } else {
                    new-synthesized-fields.at(field-name) = (fold-data.folder)(new-synthesized-fields.at(field-name), args.at(field-name))
                  }
                } else {
                  // Undo (give precedence to already folded and synthesized argument)
                  new-synthesized-fields.insert(field-name, value)
                }
              }

              synthesized-fields = new-synthesized-fields
            }

            let new-global-data = if data-changed { editable-global-data } else { none }
            if has-synthesized-futures {
              if new-global-data == none {
                new-global-data = editable-global-data
              }
              let element-data-for-futures = element-data-for-futures
              for future in synthesized-futures {
                let res = (future.call)(
                  synthesized-fields: synthesized-fields,
                  global-data: new-global-data,
                  element-data: element-data-for-futures,
                  args: args,
                  all-element-data: all-elem-data-for-futures,
                  __future-version: element-version
                )

                if "construct" in res {
                  return res.construct
                }

                if "global-data" in res {
                  new-global-data = res.global-data
                }

                if "element-data" in res {
                  element-data-for-futures = res.element-data
                }

                if "synthesized-fields" in res {
                  synthesized-fields = res.synthesized-fields
                }
              }
            }

            let select-labels = ()
            if has-selects {
              let i = 0
              for filter in selects.filters {
                let data = selects.data.at(i)
                if (
                  filter != none
                  and (data.index == none or data.index >= filter-first-active-index)
                  and data.names.all(n => n not in filter-revokes or data.index == none or data.index >= filter-revokes.at(n))
                  and verify-filter(synthesized-fields, eid: eid, filter: filter, ancestry: if "may-need-ancestry" in filter and filter.may-need-ancestry { ancestry } else { () })
                ) {
                  select-labels.push(selects.labels.at(i))
                }
                i += 1
              }
            }

            let tag = tag
            tag.fields = synthesized-fields

            // Store contextual information in synthesize
            synthesized-fields.insert(stored-data-key, tag)

            if has-filters {
              let i = 0
              let rules = ()
              for filter in filters.all {
                let data = filters.data.at(i)
                if (
                  filter != none
                  and (data.index == none or data.index >= filter-first-active-index)
                  and data.names.all(n => n not in filter-revokes or data.index == none or data.index >= filter-revokes.at(n))
                  and verify-filter(synthesized-fields, eid: eid, filter: filter, ancestry: if "may-need-ancestry" in filter and filter.may-need-ancestry { ancestry } else { () })
                ) {
                  let rule = filters.rules.at(i)
                  if rule.kind == apply {
                    rules += rule.rules
                  } else {
                    rules.push(rule)
                  }
                }
                i += 1
              }

              if rules != () {
                // Only update style chain if at least one filter matches
                new-global-data = editable-global-data

                new-global-data += apply-rules(
                  rules,
                  elements: new-global-data.elements,
                  settings: new-global-data.at("settings", default: default-global-data.settings),
                  global: new-global-data.at("global", default: default-global-data.global)
                )
              }
            }

            if has-ancestry-tracking {
              if new-global-data == none {
                new-global-data = editable-global-data
              }

              if "global" not in new-global-data {
                new-global-data.global = default-global-data
              }
              if "ancestry-chain" in new-global-data.global {
                new-global-data.global.ancestry-chain.push((eid: eid, fields: synthesized-fields))
              } else {
                new-global-data.global.ancestry-chain = ((eid: eid, fields: synthesized-fields),)
              }
            }

            // Save updated styles from applied rules
            show lbl-get: set bibliography(title: [#metadata(new-global-data)#lbl-data-metadata]) if new-global-data != none and not is-stateful

            if new-global-data != none and is-stateful {
              // Popping after the if below
              style-state.update(chain => {
                chain.push(new-global-data)
                chain
              })
            }

            // Filter show rules
            let show-rules = if has-show-rules {
              let i = 0
              let final-rules = ()
              for filter in show-rules.filters {
                let data = show-rules.data.at(i)
                if (
                  filter != none
                  and (data.index == none or data.index >= filter-first-active-index)
                  and data.names.all(n => n not in filter-revokes or data.index == none or data.index >= filter-revokes.at(n))
                  and verify-filter(synthesized-fields, eid: eid, filter: filter, ancestry: if "may-need-ancestry" in filter and filter.may-need-ancestry { ancestry } else { () })
                ) {
                  final-rules.push(show-rules.callbacks.at(i))
                }
                i += 1
              }
              final-rules
            } else {
              ()
            }

            let newest-global-data = if new-global-data == none { global-data } else { new-global-data }
            if count-needs-fields or contextual {
              if count-needs-fields {
                count(synthesized-fields)
              }

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

                if not contextual and store-ancestry {
                  tag.ctx = (ancestry: ancestry)
                }

                let body = [#[#body#metadata(tag)#lbl-tag]#lbl-show]

                if select-labels != () {
                  body = select-labels.fold(body, (acc, lbl) => [#[#acc#metadata(tag)#lbl-tag]#lbl])
                }

                let shown-body = if show-rules == () {
                  body
                } else {
                  apply-show-rules(body, show-rules.len() - 1, show-rules)
                }

                // Include metadata for querying
                let meta-body = [#shown-body#metadata(((element-meta-key): true, kind: "element-meta", eid: eid, rendered: body, (stored-data-key): tag))#lbl-meta#metadata(tag)#lbl-tag]

                if labeling {
                  [#[#meta-body#metadata(tag)#lbl-tag]#label]
                } else {
                  meta-body
                }
              }
            } else {
              let body = display(synthesized-fields)

              // Optimization: flatten 'get'
              while _is-get(body) { body = _recurse-get(body, elements: newest-global-data.elements) }

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

              if not contextual and store-ancestry {
                tag.ctx = (ancestry: ancestry)
              }

              let body = [#[#body#metadata(tag)#lbl-tag]#lbl-show]

              if select-labels != () {
                body = select-labels.fold(body, (acc, lbl) => [#[#acc#metadata(tag)#lbl-tag]#lbl])
              }

              let shown-body = if show-rules == () {
                body
              } else {
                apply-show-rules(body, show-rules.len() - 1, show-rules)
              }

              // Include metadata for querying
              let meta-body = [#shown-body#metadata(((element-meta-key): true, kind: "element-meta", eid: eid, rendered: body, (stored-data-key): tag))#lbl-meta#metadata(tag)#lbl-tag]

              if labeling {
                [#[#meta-body#metadata(tag)#lbl-tag]#label]
              } else {
                meta-body
              }
            }

            if new-global-data != none and is-stateful {
              // Pushed before the if above
              style-state.update(chain => {
                _ = chain.pop()
                chain
              })
            }
          }
        }

        if data-changed and not updates-stylechain-inside {
          if is-stateful {
            [#style-state.update(chain => {
              chain.push(global-data)
              chain
            })#shown#style-state.update(chain => {
              _ = chain.pop()
              chain
            })]
          } else {
            show lbl-get: set bibliography(title: [#metadata(global-data)#lbl-data-metadata])
            shown
          }
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
      assert(type(test-construct) == function, message: "elembic: element.declare: the 'construct' function must receive original constructor and return the new constructor, a new function, not '" + str(type(test-construct)) + "'.")
    }

    let final-constructor(..args, __elembic_data: none, __elembic_mode: auto, __elembic_settings: (:)) = {
      if __elembic_data != none {
        return if __elembic_data == special-data-values.get-data {
          (data-kind: "element", ..elem-data, func: final-constructor, default-constructor: default-constructor.with(__elembic_func: final-constructor), where: where(final-constructor))
        } else if __elembic_data == special-data-values.get-where {
          where(final-constructor)(..args)
        } else {
          assert(false, message: "elembic: element: invalid data key to constructor: " + repr(__elembic_data))
        }
      }

      construct(default-constructor.with(__elembic_func: final-constructor, __elembic_mode: __elembic_mode, __elembic_settings: __elembic_settings))(..args)
    }

    final-constructor
  } else {
    default-constructor
  }

  final-constructor
}
