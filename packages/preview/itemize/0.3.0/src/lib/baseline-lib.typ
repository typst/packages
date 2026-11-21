#import "../util/basic-tool.typ": *


#let get-the-next-list-flag(it, label-value: none) = {
  if it.has("label") {
    if it.label == label-value {
      return true
    } else {
      return (
        it.body.func() == func-seq
          and {
            let flag = for e in it.body.children {
              if e.func() == metadata {
                if e.value == label-value {
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

/// Display current label's content
#let label-box-with-baseline(
  body,
  indent: 0pt,
  width: 0pt,
  height: auto,
  label-inset: 0pt,
  label-indent: 0pt,
  body-inset: 0pt,
  label-align: end,
  baseline-at: auto,
  baseline-inset: 0pt,
  given-width: auto,
  given-height: auto,
  given-align: end,
  ..format-args,
  adjust-width: 0pt,
  // dir
  dir: "left",
  dir-rev: "right",
) = {
  h(indent)
  label-box(
    {
      set align(label-align)
      label-box(
        width: given-width,
        height: given-height,
        ..format-args,
        {
          set align(given-align) if given-align != none
          body
        },
      )
    },
    width: width + label-indent,
    height: height,
    // stroke: .5pt + black, // debug
    baseline: (at: baseline-at, shift: baseline-inset),
    inset: (str(dir): label-inset + label-indent, str(dir-rev): -label-inset),
  )
  h(body-inset + adjust-width)
  h(0pt, weak: true)
}

#let get-shift-baseline-to(baseline-inset, to-height, at) = {
  if at == auto {
    baseline-inset
  } else if at == top {
    to-height
  } else if at == horizon {
    to-height * .5
  } else if at == bottom {
    0pt
  }
}


#let get-same-line-label-baseline(
  to-shift: 0pt,
  to-above-height: 0pt,
  to-below-height: 0pt,
  to-baseline-at: auto,
) = {
  // to baseline info
  // this is the same behavior as the native one
  // See:
  // ```
  // #let my = box(height: 2em, baseline: 4em, stroke: red, width: 1em)
  // #box(my, baseline: top) 1111111
  // #box(my, baseline: (at: top, shift: 50%)) 1111111 // the height is 4em
  // ```
  let to-height = to-above-height + to-below-height
  let (shift-ratio, shift-abs) = parse-relative(to-shift)
  let to-shift-baseline = shift-ratio * to-height + shift-abs.to-absolute()

  let to-baseline = get-shift-baseline-to(to-below-height, to-height, to-baseline-at) // TODO
  let amount-baseline = to-baseline + to-shift-baseline - to-below-height

  return amount-baseline
}

#let get-baseline-with-same-line-style(
  above-height: 0pt,
  below-height: 0pt,
  same-line-style: auto,
  final-above-height: 0pt,
  final-below-height: 0pt,
  final-base-align: none,
  text-style: (:),
  line-height: 0pt,
  body-height: 0pt,
) = {
  let amount-baseline = 0pt
  if same-line-style != auto {
    let (amount, at, relative-to) = same-line-style
    let curr-label-baseline = get-baseline-at-auto(at: at, height: above-height + below-height, baseline: below-height)
    if relative-to.to == "label" {
      if final-base-align == none {
        amount-baseline = (
          (
            get-same-line-label-baseline(
              to-shift: relative-to.shift,
              to-above-height: final-above-height,
              to-below-height: final-below-height,
              to-baseline-at: relative-to.at,
            )
              - curr-label-baseline.below-height
              + below-height
          )
            - amount
        )
      } else {
        let to-shift-baseline = get-same-line-label-baseline(
          to-shift: relative-to.shift,
          to-above-height: final-above-height,
          to-below-height: final-below-height,
          to-baseline-at: relative-to.at,
        )
        let body-shift = if final-base-align == top {
          line-height - final-above-height //
        } else if final-base-align == horizon {
          line-height - body-height * .5 + (final-above-height + final-below-height) * .5 - final-above-height
        } else if final-base-align == bottom {
          line-height - body-height + final-below-height
        } else { 0pt }
        amount-baseline = (
          (
            to-shift-baseline - curr-label-baseline.below-height + below-height
          )
            - amount
            + body-shift
        )
      }
    } else {
      // relative-to item's first line
      let (baseline-inset, to-height) = get-baseline-inset-in-box(show-text(text-style, relative-to.to))

      amount-baseline = (
        (
          get-same-line-label-baseline(
            to-shift: relative-to.shift,
            to-above-height: to-height - baseline-inset,
            to-below-height: baseline-inset,
            to-baseline-at: relative-to.at,
          )
            - curr-label-baseline.below-height
            + below-height
        )
          - amount
      )
    }
  }
  return amount-baseline
}


#let move-space(
  flag: "label",
  above-height: 0pt,
  below-height: 0pt,
  inner-top-inset: 0pt,
  same-line-style: auto,
  curr-len: 0,
) = context {
  let label-pos-next-e = query(selector(el-baseline-label).after(here())).first(default: none)
  if label-pos-next-e == none {
    // It won't happen (unless doc is broken)
    return none
  }
  let label-pos-next = label-pos-next-e.location()

  let (
    line-height,
    body-height,
    final-above-height,
    final-below-height,
    text-style,
    final-base-align,
    top-inset,
    parent,
  ) = label-pos-next-e.value

  let amount-baseline = get-baseline-with-same-line-style(
    above-height: above-height,
    below-height: below-height,
    same-line-style: same-line-style,
    final-above-height: final-above-height,
    final-below-height: final-below-height,
    text-style: text-style,
    final-base-align: final-base-align,
    line-height: line-height,
    body-height: body-height,
  )
  let curr-above-height = above-height + amount-baseline

  let sum = 0pt
  let after-inset-with-height = 0pt
  let pre-inner-top-inset = inner-top-inset
  for i in range(curr-len, parent.len()) {
    let p = parent.at(i)
    sum += p.outer-top-inset + p.whole-top-inset + pre-inner-top-inset
    let p-amount-baseline = 0pt
    if p.base-align != none {
      if p.same-line-style != auto {
        p-amount-baseline = get-baseline-with-same-line-style(
          above-height: p.above-height,
          below-height: p.below-height,
          same-line-style: p.same-line-style,
          final-above-height: final-above-height,
          final-below-height: final-below-height,
          text-style: text-style,
          final-base-align: final-base-align,
        )
      }
    }
    let p-above-height = p.above-height + p-amount-baseline
    let temp = p-above-height + sum
    if after-inset-with-height < temp {
      after-inset-with-height = temp
    }
    pre-inner-top-inset = p.inner-top-inset
  }
  let final = line-height + top-inset + sum + pre-inner-top-inset
  let after-max-height = calc.max(after-inset-with-height, final)
  let EPS = 1pt
  if curr-above-height > after-max-height + EPS {
    if flag == "body" {
      move-block(curr-above-height - after-max-height) // debug, stroke: red
    }
  } else if curr-above-height < after-max-height - EPS {
    if flag == "label" {
      move-block(after-max-height - curr-above-height) //debug, stroke: purple
    }
  }
}

#let baseline-tag-meta(weak: false, tag: none, ..args) = {
  let _tag = if tag == none { el-baseline-label } else { tag }
  if weak {
    [#h(0pt, weak: true)#metadata(args.named())#_tag]
  } else {
    [#metadata(args.named())#_tag]
  }
}
