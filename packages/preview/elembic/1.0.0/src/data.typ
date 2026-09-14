// Functions to extract data from custom elements and types, as well as associated constants.

// Type constants:

// Used by typeinfos
#let type-key = "__elembic_type"
// To be used by any custom type instances
#let custom-type-key = "__elembic_custom_type"
// Used by custom types themselves
#let custom-type-data-key = "__elembic_custom_type_data"

// Versions:
#let element-version = 3  // v1 = alphas 1 and 2, v2 = alpha 3-v1.0.0-rc2, v3 = v1.0.0+
#let type-version = 2 // v1 = alphas to v1.0.0-rc2, v2 = v1.0.0+
#let custom-type-version = 3 // v1 = alphas 1 and 2, v2 = alpha 3-v1.0.0-rc2, v3 = v1.0.0+
#let current-field-version = 3 // v1 = alphas 1 and 2, v2 = alpha 3-v1.0.0-rc2, v3 = v1.0.0+

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
#let style-state-key = "__elembic_element_state"
#let style-state = state(style-state-key, ())

// Element constants:

// Prefix for the labels added to shown elements.
#let lbl-show-head = "__elembic_element_shown_"

// Prefix for the labels added to the metadata of each element.
// Used for querying.
#let lbl-meta-head = "__elembic_element_meta_"

// Prefix for the labels added outside shown elements.
// This is used to be able to effectively apply show-set rules to them.
#let lbl-outer-head = "__elembic_element_outer_"

// Prefix for counters of elements.
// This is only used if the element isn't 'refable'.
#let lbl-counter-head = "__elembic_element_counter_"

// Prefix for the figure kind used by 'refable' elements.
// This is not to be confused with figures containing the elements.
// This is the kind for a hidden figure used for ref purposes.
#let lbl-ref-figure-kind-head = "__elembic_element_refable_"

// Custom label applied to the hidden reference figure when the user specifies their own label.
#let lbl-ref-figure-label-head = "__elembic_element_ref_figure_label_"

// Label for the hidden figure used for references.
#let lbl-ref-figure = <__elembic_element_ref_figure>

// Label for context blocks which have access to the virtual stylechain.
#let lbl-get = <__elembic_element_get>

// Label for metadata indicating an element's initial properties post-construction.
#let lbl-tag = <__elembic_element_tag>

// Label for metadata indicating a rule's parameters.
#let lbl-rule-tag = <__elembic_element_rule_v2>

// 'lbl-rule-tag' from older Elembic versions.
#let lbl-old-rule-tag = <__elembic_element_rule>

// Label for other functions which access or modify the style chain, namely
// 'get', 'select', 'debug-get', 'stateful.toggle'.
//
// This is attached to metadata and the 'special-rule-key' property
// indicates which kind of rule this is.
#let lbl-special-rule-tag = <__elembic_element_special_rule>

// Label for metadata which stores the global data.
// In practice, this label is never present in the document
// unless one accidentally leaks the 'bibliography.title'
// override from our workaround.
#let lbl-data-metadata = <__elembic_element_global_data_metadata>

#let lbl-stateful-mode = <__elembic_element_stateful_mode>
#let lbl-normal-mode = <__elembic_element_normal_mode>
#let lbl-leaky-mode = <__elembic_element_leaky_mode>
#let lbl-auto-mode = <__elembic_element_auto_mode>

// Prefix for labels added by 'select' to matched elements.
// These labels are not specific to eids.
#let lbl-global-select-head = "__elembic_element_global_select_"

// Special dictionary key to indicate this is a prepared rule.
#let prepared-rule-key = "__elembic-prepared-rule"

// Special dictionary key to indicate this is a "special rule"
// ('get', 'select', 'debug-get', 'stateful.toggle').
#let special-rule-key = "__elembic-special-rule"

// Special dictionary key which stores element context and other data.
#let stored-data-key = "__elembic_stored_element_data"

// Special dictionary key to indicate this is query metadata for an element.
#let element-meta-key = "__elembic_element_meta"

#let element-key = "__elembic_element"
#let element-data-key = "__elembic_element_data"
#let global-data-key = "__elembic_element_global_data"
#let filter-key = "__elembic_element_filter"

#let sequence = [].func()

// Special values that can be passed to a type or element's constructor to retrieve some data or show
// some behavior.
#let special-data-values = (
  // Indicate that the constructor should return the type or element's data.
  get-data: 0,
  // Indicate that the constructor should return an element filter.
  get-where: 1,
)

// Extract data from a type's or element's constructor, as well as convert
// a custom type or element instance into a dictionary with keys such as body (for elements only),
// fields and func, allowing you to access its fields and information when given content (for elements)
// or the type instance (for types).
//
// When given content that is not a custom element, 'body' will be the given value,
// 'fields' will be 'body.fields()' and 'func' will be 'body.func()'.
//
// The returned 'data-kind' indicates which kind of data was retrieved.
#let data(it) = {
  if type(it) == function {
    it(__elembic_data: special-data-values.get-data)
  } else if type(it) == dictionary and element-key in it {
    (data-kind: "element", ..it)
  } else if type(it) == dictionary and custom-type-data-key in it {
    (data-kind: "custom-type-data", ..it)
  } else if type(it) == dictionary and custom-type-key in it {
    it.at(custom-type-key)
  } else if type(it) == dictionary and stored-data-key in it {
    it.at(stored-data-key)
  } else if type(it) != content {
    (data-kind: "unknown", body: it, fields: (:), func: none, eid: none, fields-known: false, valid: false)
  } else if (
    it.has("label")
    and str(it.label).starts-with(lbl-show-head)
  ) {
    // Decomposing an element inside a show rule
    it.children.at(1).value
  } else if it.func() == sequence and it.children.len() >= 2 {
    let last = it.children.last()
    if (
      last.at("label", default: none) == lbl-tag
      // Workaround for 0.11.0 weirdly placing some 'meta' element sometimes
      or sys.version < version(0, 12, 0) and {
        last = it.children.at(it.children.len() - 2)
        last.at("label", default: none) == lbl-tag
      }
    ) {
      // Decomposing a recently-constructed (but not placed) element
      last.value
    } else {
      (data-kind: "content", body: it, fields: it.fields(), func: it.func(), eid: none, fields-known: false, valid: false)
    }
  } else if (
    it.has("label")
    and str(it.label).starts-with(lbl-outer-head)
  ) {
    (data-kind: "incomplete-element-instance", body: it, fields: (:), func: (:), eid: str(it.label).slice(lbl-outer-head.len()), fields-known: false, valid: false)
  } else {
    (data-kind: "content", body: it, fields: it.fields(), func: it.func(), eid: none, fields-known: false, valid: false)
  }
}

// Obtain the fields of a type instance or element instance (custom or not).
//
// SAMPLE USAGE:
//
// #show e.selector(elem): it => {
//   let fields = e.fields(it)
//   [Hello #fields.name!]
// }
#let fields(it) = {
  let info = data(it)

  if type(info) == dictionary and "data-kind" in info {
    if info.data-kind in ("content", "element-instance", "type-instance") {
      return info.fields
    }
  }

  (:)
}

// Obtain context at an element's site.
//
// SAMPLE USAGE:
//
// 1. In show rules:
//
// #show e.selector(elem): it => {
//   let (get, ..) = e.ctx(it)
//   let other-elem-ctx = get(other-elem)
//   [The other element field was set to #other-elem-ctx.field at that point!]
// }
//
// 2. In element declarations:
//
// #e.element.declare(
//   ...
//   synthesize: it => {
//     // Get context for other element
//     it.some-field = (e.ctx(it).get)(other-elem).field
//   },
//   ...
// )
#let ctx(it) = {
  let info = data(it)
  if type(info) == dictionary and "ctx" in info {
    info.ctx
  } else {
    none
  }
}

// Obtain an element's or type's scope (usually a module with important definitions).
//
// SAMPLE USAGE:
//
// #let subelem = e.scope(elem).subelem
#let scope(it) = {
  let info = data(it)
  if type(info) == dictionary and "scope" in info {
    info.scope
  } else {
    none
  }
}

/// Obtain an element's or custom type's constructor function.
/// For native elements, this will be equivalent to `it.func()`.
///
/// Useful in custom element show rules, for example.
///
/// This is equivalent to `e.data(it).func`.
///
/// SAMPLE USAGE:
///
/// ```typ
/// #show selector.or(e.selector(elem1), e.selector(elem2)): it => {
///   // Will be either elem1 or elem2
///   let elem = e.func(it)
///   // 'elem == elem1' works, but comparing 'eid's is recommended
///   if e.eid(elem) == e.eid(elem1) {
///     [This is elem1]
///   } else {
///     [This is elem2]
///   }
/// }
/// ```
///
/// - it (any): element/custom type instance (or element/custom type itself) to get the constructor from
/// -> function | none
#let func(it) = {
  let info = data(it)
  if type(info) == dictionary and "func" in info {
    info.func
  } else {
    none
  }
}

/// Obtain an element's eid. It uniquely distinguishes this element from others,
/// even if they have the same name, by including both its prefix and name.
///
/// This is equivalent to `e.data(elem).eid`.
///
/// - elem (any): custom element (or an instance of it) to get 'eid' from
/// -> function | none
#let eid(it) = {
  let info = data(it)
  if type(info) == dictionary and "eid" in info {
    info.eid
  } else {
    none
  }
}

/// Obtain a custom type's tid. It uniquely distinguishes a custom type from
/// others, even if they have the same name, by including both its prefix and
/// name. Returns `none` on invalid input.
///
/// This is equivalent to `e.data(typ).tid`.
///
/// - typ (any): custom type (or an instance of it) to get 'tid' from
/// -> function | none
#let tid(it) = {
  let info = data(it)
  if type(info) == dictionary and "tid" in info {
    info.tid
  } else {
    none
  }
}

// Obtain an element's counter.
//
// USAGE:
//
// #context {
//   [The element counter value is #e.counter(elem).get().first()]
// }
#let counter_(elem) = {
  let info = data(elem)

  if type(info) == dictionary and "data-kind" in info and (info.data-kind == "element" or info.data-kind == "element-instance") {
    info.counter
  } else {
    assert(false, message: "elembic: e.counter: this is not an element")
  }
}

/// Get the name of a content's constructor function as a string.
///
/// Returns 'none' on invalid input.
///
/// USAGE:
///
/// ```typ
/// assert.eq(func-name(my-elem()), "my-elem")
/// assert.eq(func-name([= abc]), "heading")
/// ```
///
/// - c (content): content to get the constructor function of
/// -> function | none
#let func-name(c) = {
  if type(c) == function {
    let func-data = data(c)
    return if "name" in func-data {
      func-data.name
    } else {
      none
    }
  } else if type(c) != content {
    return none
  }
  let name = repr(c.func())
  if c.func() == sequence {
    let element-data = data(c)
    if "eid" in element-data and element-data.eid != none {
      name = if "name" in element-data and type(element-data.name) == str { element-data.name } else { "unknown custom element" }
    }
  }
  name
}

#let _letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_-"

/// This is used to obtain a debug representation of custom elements and types.
///
/// Also supports native types (just calls `repr()` for them).
///
/// - value (any): value to represent
/// - depth (int): current depth (must start at 0, conservative limit of 10 for now)
/// -> str
#let repr_(value, depth: 0) = {
  if depth >= 10 {
    return repr(value)
  }
  let typename = ""
  let value-type = type(value)
  if value-type == content and value.func() == sequence {
    let value-data = data(value)
    if "eid" in value-data and value-data.eid != none {
      value = value-data.fields
      value-type = dictionary
      typename = if "name" in value-data and type(value-data.name) == str {
        value-data.name
      } else {
        "unknown-element"
      }
    }
  }

  if value-type == dictionary {
    let pairs = if typename != "" {
      // Element fields => sort
      value.pairs().sorted(key: ((k, _)) => k)
    } else if custom-type-key in value {
      let type-data = value.at(custom-type-key)

      let id = type-data.id

      typename = if "name" in id {
        id.name
      } else if id == "custom type" {
        return if custom-type-data-key in value {
          "custom-type(name: " + repr(value.name) + ", tid: " + repr(value.tid) + ")"
        } else {
          "custom-type()"
        }
      } else {
        str(id)
      }

      type-data.fields.pairs().sorted(key: ((k, _)) => k)
    } else {
      value.pairs()
    }

    typename
    "("
    pairs.map(((k, v)) => {
      if k.codepoints().all(c => c in _letters) {
        k
      } else {
        repr(k)
      }

      ": "

      repr_(v, depth: depth + 1)
    }).join(", ")
    ")"
  } else if value-type == array {
    "("
    value.map(repr_.with(depth: depth + 1)).join(", ")
    ")"
  } else {
    repr(value)
  }
}

/// Performs deep equality of values.
///
/// This is necessary to reliably compare instances of the same element or
/// custom type, as well as data structures containing them such as arrays
/// or dictionary, between different versions of the same element or type,
/// by recursively comparing `eid(a) == eid(b) and fields(a) == fields(b)`.
/// However, this is notably slower than Typst's built-in equality check.
///
/// - a (any): First value to compare.
/// - b (any): Second value to compare.
/// -> bool
#let eq(a, b) = {
  if a == b {
    return true
  }
  if type(a) != type(b) or type(a) not in (content, dictionary, array) {
    return false
  }

  // Recursively compare until we find a 'false'
  let stack = ((a, b),)
  let fuel = 3000
  while stack != () {
    let (a, b) = stack.pop()
    if a == b {
      // Good!
      continue
    }
    fuel -= 1
    if fuel == 0 {
      return false
    }
    // Of course, the types must match
    let a-type = type(a)
    let b-type = type(b)
    if a-type != b-type {
      return false
    }

    if a-type == array {
      if a.len() != b.len() {
        return false
      }
      stack += array.zip(a, b)

    // Only have special checks for composed types and custom types and elements
    // of same type
    } else if (a-type == content or a-type == dictionary) and eid(a) == eid(b) and tid(a) == tid(b) {
      if eid(a) != none or tid(a) != none or a-type == content and a.func() == b.func() {
        // Same element id, compare their fields
        a = fields(a)
        b = fields(b)
        a-type = type(a)
        if a-type != type(b) {
          return false
        }
      }
      if a-type != dictionary or a.len() != b.len() {
        // Fields were invalid, or content didn't have the same func
        return false
      }
      for (key, a-val) in a {
        if key not in b {
          return false
        }
        stack.push((a-val, b.at(key),))
      }
    } else {
      return false
    }
  }

  // No checks failed
  true
}
