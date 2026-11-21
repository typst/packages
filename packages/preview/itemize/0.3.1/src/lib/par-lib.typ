#import "../util/version.typ": package-version
#import "../util/basic-tool.typ": default-block-args, get-elem-label
#import "../util/identifier.typ": prevent-recursion-ID, prevent-recursion-label, prevent-recursion-meta
#import "../util/func-type.typ": block-level-elem, func-seq

#import "parize-internal.typ": *


#let ParState = (
  strong-par: 2, // for description list
  first-par: 0, // first paragraph in list/enum's body
  normal-par: 1,
  not-par: -1,
)

#let par-ID = "__cdl_par-flag-meta__" + package-version
#let par-flag-meta = metadata(par-ID)

/// To track the state of the paragraph
#let par-state-data = state("__cdl_par-state-data__" + package-version, ())

#let record-disable-par = it => {
  it.push(ParState.not-par)
  return it
}

#let record-start-par(start-normal-par) = it => {
  if start-normal-par {
    it.push(ParState.normal-par)
  } else {
    it.push(ParState.first-par)
  }
  return it
}

#let record-end-par = it => {
  if it != () {
    _ = it.pop()
  }
  return it
}

#let record-normal-par = it => {
  let last = it.last(default: none)
  if last == ParState.first-par {
    it.at(-1) = ParState.normal-par
  }
  return it
}

#let record-strong-par = it => {
  let last = it.last(default: none)
  if last == ParState.first-par {
    it.at(-1) = ParState.strong-par
  }
  return it
}

#let is-prevent-par(it) = {
  if it.has("label") {
    if it.label == prevent-recursion-label {
      return true
    } else {
      return (
        it.body.func() == func-seq
          and {
            let flag = for e in it.body.children {
              if e.func() == metadata {
                if e.value == par-ID {
                  true
                  break
                }
              }
            }
            flag != none
          }
      )
    }
  }
  return false
}


/// Implement `hanging-indent` and `line-indent`
/// In the body of lists, all text will be treated as paragraphs by default, but text wrapped in containers (such as `box`, any block-level containers (`block`), etc.) will be not processed.
#let par-box(
  it,
  line-indent: 0pt,
  hanging-indent: 0pt,
  par-line-indent: 0pt,
  hanging-inset: 0pt,
  first-line-indent: 0pt,
  label-tag: none,
  is-strong-par: false,
) = {
  if it.body == none {
    return it
  }
  // prevent recursion
  if is-prevent-par(it) {
    return it
  }

  let (amount, all) = it.first-line-indent

  let (par-type, ..leading-args) = par-type-state.get().data

  let par-line = par-state-data.get().last(default: ParState.not-par)

  let par-args = (:)
  let _body
  let _label
  let prevent-recursion-meta

  let fields = it.fields()
  _ = fields.remove("body")
  _label = fields.remove("label", default: none)

  if _label == none {
    _label = prevent-recursion-label
  } else {
    prevent-recursion-meta = par-flag-meta
  }

  let first-line-indent-args = (:)
  let hanging-indent-args = (:)

  if par-line in (ParState.first-par, ParState.strong-par) {
    // first par
    first-line-indent-args = (first-line-indent: (amount: 0pt, all: true))

    let _hanging-indent = (
      if hanging-indent != auto { hanging-indent } + hanging-inset
    )
    hanging-indent-args = (hanging-indent: _hanging-indent + it.hanging-indent.to-absolute())

    _body = {
      prevent-recursion-meta
      h(first-line-indent)
      h(0pt, weak: true)
      if par-line == ParState.first-par { label-tag }
      // show: highlight.with(fill: red.lighten(90%)) // debug
      it.body
    }
  } else {
    if all {
      if par-type in (ParType.block-all, ParType.block-indent) {
        first-line-indent-args = (first-line-indent: (amount: 0pt, all: true))
      }
    } else {
      if par-type in (ParType.parbreak-indented, ParType.non-tight-list-parbreak) {
        first-line-indent-args = (first-line-indent: (amount: amount, all: true))
      }
    }
    if par-line == ParState.normal-par {
      // other pars
      let _hanging-indent = (
        if hanging-indent != auto { hanging-indent } + hanging-inset
      )
      hanging-indent-args = (hanging-indent: _hanging-indent + it.hanging-indent.to-absolute())

      _body = {
        if (align.alignment.x) != center {
          prevent-recursion-meta
          if line-indent != auto { h(line-indent) }
          h(par-line-indent)
          h(0pt, weak: true)
          // set text(fill: blue.darken(30%)) // debug
          it.body
        } else {
          prevent-recursion-meta
          it.body
        }
      }
    } else {
      _body = {
        prevent-recursion-meta
        // show: highlight.with(fill: purple.lighten(80%), stroke: red) // debug
        it.body
      }
    }
  }

  return {
    par-type-state.update(update-native)
    [#par(..fields, ..first-line-indent-args, ..hanging-indent-args, {
        _body
      })#_label]
    if is-strong-par { par-state-data.update(record-strong-par) } else { par-state-data.update(record-normal-par) }
  }
}

#let fix-terms(doc, enable: true) = {
  if not enable {
    return doc
  }
  show terms: it => {
    if it.has("label") and it.label == prevent-recursion-label {
      return it
    }
    par-state-data.update(it => {
      it.push(ParState.normal-par)
      it
    })
    [#terms(
        tight: it.tight,
        separator: it.separator,
        indent: it.indent,
        hanging-indent: it.hanging-indent,
        spacing: it.spacing,
        ..{
          for e in it.children {
            (terms.item(e.term, [#e.description#parbreak()]),)
          }
        },
      )#prevent-recursion-label]
    par-state-data.update(it => {
      if it != () {
        _ = it.pop()
      }
      let last = it.last(default: none)
      if last == ParState.first-par {
        it.at(-1) = ParState.normal-par
      }
      return it
    })
  }
  doc
}

#let fix-eq(doc) = {
  show math.equation.where(block: true): eq => {
    eq
    par-state-data.update(record-normal-par)
  }
  doc
}

#let fix-place-and-float-figure(doc, enable: true) = {
  let record-hold = p => {
    if enable {
      p.push(ParState.normal-par)
      return p
    } else {
      p.push(ParState.not-par)
      return p
    }
  }
  show place: it => {
    let self
    if it.float {
      // include float-figure
      if it.has("label") {
        if it.label == prevent-recursion-label {
          return it
        } else if (
          it.body.func() == func-seq
            and {
              let flag = for e in it.body.children {
                if e.func() == metadata {
                  if e.value == prevent-recursion-ID {
                    true
                    break
                  }
                }
              }
              flag != none
            }
        ) {
          return it
        }
      }
      let fields = it.fields()
      let body = fields.remove("body")
      let alignment = fields.remove("alignment")
      let _label = fields.remove("label", default: none)
      let _meta
      if _label == none {
        _label = prevent-recursion-label
      } else {
        _meta = prevent-recursion-meta
      }
      self = [#place(..fields, alignment, {
          _meta
          body
        })#_label]
    } else {
      self = it
    }
    par-state-data.update(record-hold)
    self
    par-state-data.update(record-end-par)
  }

  doc
}

#let enable-par-in-block(doc, enable: true) = {
  show selector.or(..block-level-elem): it => {
    if it.has("body") and it.body in (auto, none) {
      return it
    }
    if it.has("label") and it.label in (prevent-recursion-label, prevent-parize-recursion-label) {
      return it
    }

    if not enable { par-state-data.update(record-disable-par) }

    it
    par-state-data.update(it => {
      if not enable {
        if it != () {
          _ = it.pop()
        }
      }
      let last = it.last(default: none)
      if last == ParState.first-par {
        it.at(-1) = ParState.normal-par
      }
      return it
    })
  }
  doc
}

#let process-body-par(
  doc,
  enable-strong-par: false,
  my-first-line-inset: auto,
  label-cell-inset: 0pt, // for paragraph and contains inner-dir-inset
  start-margin-len: 0pt,
  enable-process: true,
  line-indent: 0pt,
  hanging-indent: 0pt,
  first-line-inset: 0pt,
  label-tag: none,
  start-normal-par: false,
) = {
  let (par-line-indent, par-hanging-indent) = {
    (-label-cell-inset, -label-cell-inset)
  }

  // let enable-process = true
  show: enable-par-in-block.with(enable: enable-process)
  // equation
  show: fix-eq
  // place and float-figure
  show: fix-place-and-float-figure.with(enable: enable-process)
  // terms
  show: fix-terms.with(enable: enable-process)
  let first-line-indent = (
    if my-first-line-inset == auto { first-line-inset + start-margin-len } else {
      first-line-inset + my-first-line-inset + start-margin-len
    }
  )

  show par: par-box.with(
    line-indent: line-indent,
    hanging-indent: hanging-indent,
    par-line-indent: par-line-indent,
    hanging-inset: par-hanging-indent,
    first-line-indent: first-line-indent,
    label-tag: label-tag,
    is-strong-par: enable-strong-par,
  )
  par-state-data.update(record-start-par(start-normal-par))
  parbreak()
  doc
  // parbreak()
  par-state-data.update(record-end-par)
}


#let disable-par(doc) = {
  par-state-data.update(record-disable-par)
  // compatible with parize
  par-type-state.update(update-native)
  show par: it => {
    // disable-par
    if it.has("label") {
      // prevent recursion
      if is-prevent-par(it) {
        return it
      }
      let field = it.fields()
      let _label = field.remove("label")
      let _body = field.remove("body")
      [#par(..field, {
          par-flag-meta
          _body
        })#_label]
    } else {
      [#it#prevent-recursion-label]
    }
  }
  doc
  par-state-data.update(record-end-par)
}
