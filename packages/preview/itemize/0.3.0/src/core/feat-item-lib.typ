#import "../lib/resume-lib.typ" as rl
#import "../lib/label-width-lib.typ" as lw
#import "../core/new-enum-list.typ" as fel

/// Continue using the enum numbers from the previous ones (for the same level).
///
/// - *Note*: In order to make this method work, set the argument `auto-resuming` in the method `*-enum-list` (`*-enum`) to `auto`.
///
/// - body (content): The `enum` in the body to resume
///
/// -> content
#let resume(..body) = {
  rl.resume-list.update(true)
  if body.pos().len() > 0 {
    let content = for e in body.pos() { e }
    if content != none {
      { show enum: it => it }
      content
      { show enum: it => it }
    }
    rl.resume-list.update(false)
  }
}

/// Label current `enum` for reference by `key`
///
/// - key (label, string, content): Unique identifier for the `enum`
///
/// -> content
#let resume-label(key) = {
  let key-label = fel.get-label(key)
  context {
    let sel = metadata.where(value: fel.enum-resume-ID, label: key-label)
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

/// Resumes an enum labelled with `key` (by using the method `resume-label`)
///
/// - *Note*: In order to make this method work, set the argument `auto-resuming` in the method `*-enum-list` (`*-enum`) to `auto`.
///
/// - key (label, string, content): Key of the `enum` to resume
/// - body (content): The `enum` in the body to resume
/// -> content
#let resume-list(key, ..body) = {
  let key-label = fel.get-label(key)
  rl.resume-label-list.update(key-label)
  if body.pos().len() > 0 {
    { show enum: it => it }
    body.pos().join()
    { show enum: it => it }
    rl.resume-label-list.update(none)
  }
}

/// Convenience method for `resume-list` using @label syntax
///
/// - it: Reference element containing target and supplement
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

/// Resets all resume counter (in module `adv`)
///
/// If these records are no longer needed in the document, you can call the `adv.reset-resume()` method to clear this information. One common use case is:
///   ```typst
///   // New enum-before
///   #el.adv.reset-resume()
///   // New enum-here:
///   #el.adv.reset-resume()
///   // New enum-after
///   ```
///   - *Note*: Improper use of `adv.reset-resume()` may break the `resuming enum` functionality (*not* recommended to use).
#let reset-resume() = {
  context assert(rl.item-counter-dic.get().level == 0, message: "Can not be used in enum or list.")
  rl.reset_resume-dic()
}


/// Recovery operations within an isolation scope, allows the `enum` in the `doc` to be treated as a new enum with independent numbering, without affecting other enums.
/// - doc (content): The `enum` in the `doc` to process
///
/// -> content
#let isolated-resume-enum(doc) = {
  // context if "copy" in rl.item-counter-dic.get() {
  //   panic("The functions `isolated-resume-enum` and `auto-resume-enum` cannot be nested.")
  // }
  rl.hold_resume-dic()
  { show enum: it => it }
  doc
  { show enum: it => it }
  rl.recover_resume-dic()
}

/// Resume enum in `doc`.
///
/// - *Note*: The method `auto-resume-enum` cannot be nested.
///
/// - *Note*: In order to make `auto-resume-enum` work, should set the argument `auto-resuming` in `*-enum-list` (`*-enum`) to `auto`.
///
/// - doc (content): The `enum` in the `doc` to process
/// - auto-resuming (none, bool, array, function): Resume mode
///   - `none` == `false`: Disable this feature.
///   - `true`: All enum numbers within `doc` will continue from the previous ones (for each level).
///   - `array` (level-property): The elements are `bool` or `none`. The `level`-th level will be set to the corresponding value of the array at position `level - 1`; now `true` means the enum numbers at the `level`-th level will continue from the previous ones.
///     - *Note*: The `enum`'s level in `doc` uses the relative or absolute level depending on which `*-enum-list` or `*-enum` is used in the document; but starting from *1*.
///     - If the last element of the array is `LOOP`, the values in the array will be used cyclically;
///     - otherwise, the last value of the array will be used for residual levels.
///   - `function` (level-property): The return value will be used for each level.
///     - The function form: `it => bool | none`
///     - Access the following values available on `it`:
///       - `it.level`: The level of the item, starting from 1.
///       - `it.n-last`: The index of the last item in the current level.
///       - `it.elem-tag`: The tag of the `enum` or `list`.
///       - `it.e`: The construct function (`enum` or `list`) of the item.
///       - `it.hanging-type`: The hanging type of the current level.
///     - Example: Using `it.elem-tag`, specify which `enum` continues to use the previous enum's numbers.
///       ```typst
///       #show: el.default-enum-list.with(auto-resuming: auto)
///       + List one
///       #el.auto-resume-enum(auto-resuming: it => {
///         if it.elem-tag == "resume" { true } else { false }
///       })[
///         + Item one
///         + Item two
///           + Sub item one
///           + Sub item two
///         New paragraph
///         + Item one // not resume
///           + #el.item(elem-tag: "resume") Sub item // resume
///       ]
///       + List two // not resume
///       ```
/// -> content
#let auto-resume-enum(doc, auto-resuming: none) = {
  context if fel.auto-resuming-form.get() != none {
    panic("The function `auto-resume-enum` cannot be nested.")
  }
  context fel.auto-resuming-form.update((
    form: auto-resuming,
    current-level: fel.item-level.get().len(),
    current-enum-level: fel.enum-level.get(),
  ))
  isolated-resume-enum(doc)
  fel.auto-resuming-form.update(none)
}

/// Used to share the same maximum label width for different `enum`s and `list`s in `doc`.
///
/// - *Note*: The method `auto-label-item` cannot be nested.
/// - *Note*: In order to make `auto-label-item` work, should set the argument `auto-label-width` in `*-enum-list` (`*-enum`) to `auto`.
///
/// - doc (content): The `enum` or `list` in the `doc` to process
/// - form (none, auto, string, array, function):
///     - `none`: No processing.
///     - `"each" == auto`: The maximum widths of `enum`'s labels and `list`'s labels are considered separately.
///     - `"enum"`: Only the maximum widths of `enum`'s labels are considered.
///     - `"list"`: Only the maximum widths of `list`'s labels are considered.
///     - `"all"`: The maximum widths of `enum`'s labels and `list`'s labels are both considered.
///     - `array` (level-property): The elements are `none`, `auto`, `"each"`, `"list"`, `"enum"`, `"all"`. The `level`-th level will be set to the corresponding value of the array at position `level - 1`.
///       - *Note*: The level in `doc` uses the relative or absolute level depending on which `*-enum-list` or `*-enum` is used in the document; but starting from *1*.
///       - `"each"` is equivalent to `auto`.
///       - If the last element of the array is `LOOP`, the values in the array will be used cyclically;
///       - otherwise, the last value of the array will be used for residual levels.
///     - `function` (level-property):
///       - The function form: `it => none | auto | "each" | "list" | "enum" | "all"`
///       - Access the following values available on `it`:
///         - `it.level`: The level of the item, starting from 1.
///         - `it.n-last`: The index of the last item in the current level.
///         - `it.elem-tag`: The tag of the `enum` or `list`.
///         - `it.e`: The construct function (`enum` or `list`) of the item.
///         - `it.hanging-type`: The hanging type of the current level.
///       - Example: In the following, for the same level of `enum`s or `list`s, if they are marked as "auto-label" (with the help of `el.item(elem-tag: ...)`), then they will share the same maximum label width.
///         ```typst
///         #show: el.default-enum-list.with(auto-label-width: auto)
///         + List one
///         #el.auto-label-item(form: it => {
///           if it.elem-tag == "auto-label" { auto }
///         })[
///           + Item one
///           + Item two
///             + #el.item(elem-tag: "auto-label") Sub item one
///             + Sub item two
///           + Item one
///             10. #el.item(elem-tag: "auto-label") Sub item
///        ]
///        + List two
///        ```
/// -> content
#let auto-label-item(doc, form: auto) = {
  context if lw.max-width-label.get().unlock == true {
    panic("The function `auto-label-item` cannot be nested.")
  }
  context fel.width-label-form.update((
    form: form,
    current-level: fel.item-level.get().len(),
    current-enum-level: fel.enum-level.get(),
    current-list-level: fel.list-level.get(),
  ))
  lw.hold_width-label-dic()
  {
    show enum: it => it
    show list: it => it
  }
  doc
  {
    show enum: it => it
    show list: it => it
  }
  [#metadata(fel.enum-label-ID)#label(fel.auto-label-ID)]
  lw.recover_width-label-dic()
  fel.width-label-form.update(auto)
}

