#import "../lib/resume-lib.typ" as rl
#import "../lib/label-width-lib.typ" as lw

#import "../core/fix-enum-list.typ" as fel


/// Wraps the current enum or list as a new one
///
/// Parameters
/// - `doc`: The document to wrap
/// - `new`: If `true`, treats the enum or list as a new one (default: `true`)
#let _new-enum(doc, new: true) = if new {
  show enum: it => it
  doc
} else { doc }

/// Continue using the enum numbers from the previous ones.
///
/// Parameters
/// - new (bool): If `true`, starts a new enum (default: `false`)
/// - body`: Content to resume enum
#let resume(new: false, ..body) = {
  rl.resume-list.update(true)
  show: _new-enum.with(new: new)
  if body.pos().len() > 0 {
    let content = for e in body.pos() { e }
    if fel.item_is_blank_in_seq(content) != none {
      show enum: it => it
      content
    }
    rl.resume-list.update(false)
  }
}

/// Label current enum for reference by `key`
///
/// Parameters
/// - key (label, str): Unique identifier for the enum
#let resume-label(key) = {
  let key-label = fel.get_label(key)
  context {
    let sel = selector(key-label).and(metadata.where(value: fel.enum-resume-ID))
    let keys = query(sel)
    if keys.len() == 0 {
      panic("Can't find the enum with key `" + str(key-label) + "`.")
    } else if keys.len() > 1 {
      panic("The enum with labelled key `" + str(key-label) + "` occurs multiple times.")
    } else {
      if fel.item-level.at(sel).at(fel.item-level.get().len() - 1, default: none) != "enum" {
        panic("The label `" + str(key-label) + "` is not attached to enum.")
      }
    }
  }
  rl.resume-label.update(key-label)
  rl.store_resume(key-label)
  [#metadata(fel.enum-resume-ID)#key-label]
}

/// Resumes an enum labelled with `key` (by using method `resume-label`)
///
/// Parameters
/// - key (label, str): Key of the list to resume
/// - new (bool): If `true`, starts new enum (default: `true`)
/// - body (): The enum in the body to resume
///
#let resume-list(key, new: true, ..body) = {
  let key-label = fel.get_label(key)
  rl.resume-label-list.update(key-label)
  show: _new-enum.with(new: new)
  if body.pos().len() > 0 {
    let content = for e in body.pos() { e }
    if fel.item_is_blank_in_seq(content) != none {
      show enum: it => it
      content
    }
    rl.resume-label-list.update(none)
  }
}

/// Convenience method for `resume-list` using @label syntax
///
/// Parameters
/// - `it`: Reference element containing target and supplement
#let ref-resume-list(it) = {
  let el = it.element
  if el != none {
    if el.func() == metadata and el.value == fel.enum-resume-ID {
      if it.supplement != auto {
        resume-list(it.target, it.supplement)
      } else {
        resume-list(it.target)
      }
    } else {
      it
    }
  } else {
    it
  }
}

/// Resets all resume counter.
/// If these records are no longer needed in the document, you can call the `adv.reset-resume()` method to clear this information. One common use case is:
///   ```
///   // New enum-before
///   // el.adv.reset-resume()
///   // New enum-here:
///   // el.adv.reset-resume()
///   // New enum-after
//    ```
// - Improper use of `adv.reset-resume()` may break the `resuming enum` functionality.
#let reset-resume() = {
  context assert(rl.item-counter-dic.get().level == 0, message: "Can not be used in enum or list.")
  rl.reset_resume-dic()
}


/// Isolates resume operations within a scope, allows the enum in the `doc` to be treated as a new enum with independent numbering, without affecting other enums.
#let isolated-resume-enum(doc) = {
  rl.hold_resume-dic()
  show enum: it => it
  // show list: it => it
  doc
  rl.recover_resume-dic()
}

/// Controls auto-resume behavior
///
/// Parameters
/// - doc: Content to process
/// - auto-resuming (array, bool, none): Resume mode
///   - `true`: all enum numbers within `doc` will continue from the previous ones
///   - `false` == `none`: Do not enable the resuming feature
///   - `array`: each element indicates whether the enum numbers for the corresponding level should continue from the previous ones.
#let auto-resume-enum(doc, auto-resuming: none) = {
  context if fel.auto-resuming-form.get() != none {
    panic("This function cannot be nested.")
  }
  context fel.auto-resuming-form.update((form: auto-resuming, current-level: fel.item-level.get().len()))
  isolated-resume-enum(doc)
  fel.auto-resuming-form.update(none)
}

/// Automatic alignment of labels in enums and lists
/// 
/// The method `auto-label-item` cannot be nested.
///
/// Parameters
/// - doc (content): The document to process
/// - form (none, auto, "each", "list", "all", array): 
///     - `none`: No processing.
///     - `"each" == auto`: `Enum` and `list` are considered separately, i.e., align the label in enums and the label in lists independently.
///     - `"enum"`: Only align the label in `enum`.
///     - `"list"`: Only align the label in `list`.
///     - `"all"`: Align the label in both `enum` and `list`.
///     - `array`: Each element can be one of the above values, where the value of the `level-1`-th element represents the alignment method for the label at the `level`-th level.
/// -> content
#let auto-label-item(doc, form: auto) = {
  context fel.width-label-form.update((form: form, current-level: fel.item-level.get().len()))
  context if lw.max-width-label.get().unlock == true {
    panic("The function `auto-label-item` cannot be nested.")
  }
  lw.hold_width-label-dic()
  // box(stroke: 1pt + blue, inset: 1pt)[init|#context lw.max-width-label.get()|]
  show enum: it => it
  show list: it => it
  doc
  [#metadata(fel.enum-label-ID)#label(fel.auto-label-ID)]
  // box(stroke: 1pt + yellow, inset: 1pt)[after|#context lw.max-width-label.get()|]
  lw.recover_width-label-dic()
  fel.width-label-form.update(auto)
}

