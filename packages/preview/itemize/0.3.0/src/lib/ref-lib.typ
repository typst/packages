#import "../util/level-state.typ": *

#import "id-lib.typ": *

#import "../util/numbering.typ": *

#import "../foundation/reference.typ": *

#import "../foundation/item-config.typ": is-item-label

/// Creates a labeled reference for enum items.
/// - *Note*: Use this when regular `label(<...>)` won't work with enum references
///
/// - name (string, label, content): Label identifier
///
/// -> content
#let elabel(name) = {
  let _label = get-label(name)
  [#metadata(enum-label-ID)#_label]
}

/// Deal with the `ref.supplement`
#let ref-supplement(supplement) = if supplement not in (none, auto) {
  if type(supplement) == function {
    [#it-supplement(it)~#h(0em, weak: true)]
  } else {
    // content
    [#supplement~#h(0em, weak: true)]
  }
}


/// Internal function for referencing enum label
#let _ref-enum-label(
  it,
  _full,
  _numbering,
  supplement,
  no-label-warning,
  item-supp: none,
  item-label: none,
) = {
  let enum-numbering-info = enum-numbering.at(it.target)
  if enum-numbering-info != () {
    let (
      numbering,
      ref-numbering,
      full,
      auto-base-level,
      curr-enum-level,
      supplement-format,
      level-item,
      ..args-with-tags,
    ) = enum-numbering-info.last()
    if ref-numbering != none {
      numbering = ref-numbering
    } else {
      if _numbering != auto { numbering = _numbering }
    }
    let base-num-count = if auto-base-level { curr-base-parent-level.at(it.target) } else {
      curr-parent-level.at(it.target)
    }
    let number-body = if item-label == none {
      /// cady-b
      /// https://github.com/tianyi-smile/itemize/issues/9
      let here-num-count = if auto-base-level {
        curr-base-parent-level.get()
      } else {
        curr-parent-level.get()
      }
      if (_full == "rel") and here-num-count != () {
        let target-id = auto-id-state.at(it.target).auto-id
        let here-id = auto-id-state.get().auto-id
        let dif = 0
        let min = calc.min(target-id.len(), here-id.len())
        while dif < min and here-id.at(dif) == target-id.at(dif) {
          dif += 1
        }
        if dif > 0 and dif <= here-num-count.len() and here-num-count.at(dif - 1).n != base-num-count.at(dif - 1).n {
          dif -= 1
        }
        if dif == base-num-count.len() {
          dif -= 1
        }
        for i in range(dif, base-num-count.len()) {
          apply-numbering-kth(numbering, i, base-num-count.at(i).number)
        }
      } else if (_full == auto and full) or (_full in (true, "rel")) {
        std.numbering(numbering, ..base-num-count.map(e => e.number))
      } else {
        if auto-base-level {
          apply-numbering-kth(numbering, curr-enum-level, base-num-count.last().number)
        } else {
          apply-numbering-kth(numbering, base-num-count.len() - 1, base-num-count.last().number)
        }
      }
    } else {
      item-label
    }

    let index-n = base-num-count.last().n

    let level = if auto-base-level { curr-enum-level } else { base-num-count.len() }
    // for enum's supplement
    let item-supp-format = if item-supp != none {
      pre-parse-supplement(
        item-supp,
        level-item(index-n),
        ..args-with-tags,
      )
    } else { supplement-format }
    let enum-supp = item-supp-format(index-n)(
      number-body,
      target: it.target,
      numbers: base-num-count.map(it => {it.number}),
      numbering: numbering,
    )
    // fix(ver0.3.0): ref.supplement
    let origin-supp = ref-supplement(it.supplement)
    let ref-supp
    link(it.element.location(), [#origin-supp#parse-supplement(
        supplement,
        level - 1,
        none,
        0,
        ..args-with-tags,
      )(index-n)(
        enum-supp,
        target: it.target,
        numbers: base-num-count.map(it => it.number),
        numbering: numbering,
      )])
  } else {
    it
  }
}

/// Reference formatter for enum and list items (supports `@` syntax).
#let ref-enum(it, full: auto, numbering: auto, supplement: auto, no-label-warning: false) = {
  assert(
    type(no-label-warning) == bool,
    message: "`no-label-warning` must be bool;\nbut found: " + repr(no-label-warning),
  )
  let e = it.element
  if e != none {
    assert(
      full in (auto, true, false, "rel"),
      message: "`full` must be `auto`, bool, or \"rel\";" + "\nbut found: " + repr(full),
    )
    assert(
      numbering == auto or type(numbering) in (str, function),
      message: "`numbering` should be `auto`, str, or function;" + "\nbut found: " + repr(numbering),
    )
    let e-func = e.func()
    if (
      e-func == text or e-func == enum.item or e-func == metadata and e.value == enum-label-ID
    ) {
      _ref-enum-label(it, full, numbering, supplement, no-label-warning)
    } else if is-item-label(e) {
      let item-elem = item-level.at(it.target)
      let body = e.value.body
      let item-supp = e.value.at("supplement", default: none)
      if item-elem.len() > 0 and item-elem.last() == "list" {
        // feat: reference for `list` (ver0.3.0)
        if body == none {
          it
        } else {
          // do not support for index property
          let list-level = item-elem.filter(it => it == "list").len() - 1 // use list-level
          let list-supp = if item-supp != none {
            let item-supp-format = pre-parse-supplement(item-supp, list-level)
            item-supp-format(0)(body, target: it.target, numbers: ())
          } else {
            body
          }
          let origin-supp = ref-supplement(it.supplement)
          link(it.element.location(), [#origin-supp#parse-supplement(
              supplement,
              list-level,
              none,
              0,
            )(0)(list-supp, target: it.target, numbers: ())])
        }
      } else {
        // reference for enum
        _ref-enum-label(
          it,
          full,
          numbering,
          supplement,
          no-label-warning,
          item-supp: item-supp,
          item-label: body,
        )
      }
    } else {
      it
    }
  } else {
    if no-label-warning {
      if query(it.target).len() > 1 {
        it
      } else {
        // do not find the target
        [#text(weight: "bold", fill: red)[#repr(it.target)?]]
      }
    } else { it }
  }
}
