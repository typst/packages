#import "data.typ": element-version, filter-key, special-data-values

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
