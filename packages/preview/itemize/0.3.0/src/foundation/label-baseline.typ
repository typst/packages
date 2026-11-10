#import "../util/parse-args.typ": *
#import "../lib/baseline-lib.typ": get-shift-baseline-to

#let baseline-align-style = (
  "item": ("top-item", "horizon-item", "bottom-item"),
  "label": ("top-label", "center-label", "bottom-label", "baseline-label"),
  "item-first-line": ("top", "center", "bottom", "baseline"),
)

#let get-to-baseline-at = (
  "top-item": top,
  "horizon-item": horizon,
  "bottom-item": bottom,
  "top-label": top,
  "center-label": horizon,
  "bottom-label": bottom,
  "baseline-label": auto,
  "top": top,
  "center": horizon,
  "bottom": bottom,
  "baseline": auto,
)

#let parse-same-line-label-style(same-line-style, label-height: 0pt) = {
  let amount
  let baseline-at
  let relative-to
  let relative-dic = (:)
  let base-align = none

  if same-line-style in baseline-align-style.values().flatten() {
    amount = 0pt
    same-line-style = (
      amount: 0pt,
      at: auto,
      relative-to: same-line-style,
    )
  }

  if type(same-line-style) == dictionary {
    amount = same-line-style.remove("amount", default: 0pt)
    baseline-at = same-line-style.remove("at", default: auto)
    relative-to = same-line-style.remove("relative-to", default: "baseline")

    assert(
      same-line-style == (:),
      message: "The keys of `same-line-style` should be: `amount`, `at`, `relative-to`."
        + "\nBut found: "
        + same-line-style.keys().join(", ")
        + ".",
    )

    let _type = type(relative-to)

    assert(
      type(amount) in length-type or amount == auto,
      message: "The value of `amount` should be a length or `auto`." + "\nBut found: " + repr(amount) + ".",
    )
    amount = get-auto-value(amount, 0pt)

    let (amount-ratio, amount-length) = parse-relative(amount)
    amount = amount-length.to-absolute() + amount-ratio * label-height

    assert(
      baseline-at in (auto, top, bottom, horizon),
      message: "The value of the key `at` should be `top`, `horizon`, `bottom`, or `auto`."
        + "\nBut found: "
        + repr(baseline-at)
        + ".",
    )

    if relative-to in baseline-align-style.item {
      baseline-at = get-to-baseline-at.at(relative-to)
      base-align = baseline-at
    } else if relative-to in baseline-align-style.label {
      baseline-at = get-to-baseline-at.at(relative-to)
      relative-dic = (
        to: "label",
        at: baseline-at,
        shift: 0pt,
      )
    } else if relative-to in baseline-align-style.item-first-line {
      baseline-at = get-to-baseline-at.at(relative-to)
      relative-dic = (
        to: [A],
        at: baseline-at,
        shift: 0pt,
      )
    } else if (
      _type == array
        and relative-to.len() == 2
        and (type(relative-to.at(0)) in (content,) + length-type)
        and relative-to.at(1) in baseline-align-style.item-first-line
    ) {
      baseline-at = get-to-baseline-at.at(relative-to.at(1))
      if type(relative-to.at(0)) == content {
        relative-dic = (
          to: relative-to.at(0),
          at: baseline-at,
          shift: 0pt,
        )
      } else {
        relative-dic = (
          to: [A],
          at: baseline-at,
          shift: relative-to.at(0),
        )
      }
    } else if _type == content {
      relative-dic = (
        to: relative-to,
        at: auto,
        shift: 0pt,
      )
    } else if _type in length-type {
      relative-dic = (
        to: [A],
        at: auto,
        shift: relative-to,
      )
    } else if _type == dictionary {
      relative-dic = (
        to: relative-to.remove("to", default: [A]),
        at: relative-to.remove("at", default: auto),
        shift: relative-to.remove("shift", default: 0pt),
      )

      assert(
        relative-to == (:),
        message: "The keys of `relative-to` should be: `to`, `at`, `shift`. "
          + "\nBut found: "
          + relative-to.keys().join(", "),
      )

      if relative-dic.to == auto {
        relative-dic.to = [A]
      }

      assert(
        relative-dic.to == "label" or type(relative-dic.to) == content,
        message: "The value of the key `relative-to` should be one of the following: "
          + "a string \"label\""
          + " or a content or auto."
          + "\nBut found: "
          + repr(relative-dic.to)
          + ".",
      )

      assert(
        relative-dic.at in (auto, top, horizon, bottom),
        message: "The value of the key `at` should be `top`, `horizon`,  `bottom`, or `auto`."
          + "\nBut found: "
          + repr(relative-dic.at)
          + ".",
      )

      assert(
        type(relative-dic.shift) in length-type,
        message: "The type of the key `shift` should be relative." + "\nBut found: " + repr(relative-dic.shift) + ".",
      )
    } else {
      panic(
        "The value of the key `relative-to` should be one of the following strings: "
          + baseline-align-style.values().flatten().map(it => "\"" + str(it) + "\"").join(", ")
          + "; \n or a dictionary with the keys: `to`, `at`, `shift`"
          + "; \n or a content"
          + "; \n or an array of two elements: the first element is a content or a relative, and the second element is one of the following strings: \"baseline\", \"top\", \"center\", \"bottom\";"
          + "\nBut found: "
          + repr(relative-to)
          + ".",
      )
    }
  } else {
    panic(
      "The value of the key `same-line-style` should be one of the following strings: "
        + baseline-align-style.values().flatten().map(it => "\"" + str(it) + "\"").join(", ")
        + "; or `auto`"
        + "; or a dictionary with the keys: `amount`, `at`, `relative-to`."
        + "\nBut found: "
        + repr(same-line-style)
        + ".",
    )
  }

  return (amount: amount, at: baseline-at, base-align: base-align, relative-to: relative-dic)
}

/// legel baseline keys
#let baseline-allowed-keys = ("amount", "at", "relative-to", "same-line-style", "impact-first-line")

#let baseline-align-allowed-keys = ("center", "top", "bottom", "top-item", "horizon-item", "bottom-item", "baseline")

/// Parse the baseline value. (ver0.3.0: add `impact-first-line` and `relative-to`, allow to align in whole item)
#let parse-baseline(baseline, text-style, label-height: 0pt) = {
  let base-align = none
  let amount
  let baseline-at = auto
  let same-line-style = auto

  let relative-to = "baseline"
  let to-height = 0pt
  let to-baseline = 0pt
  let baseline-inset = 0pt
  let relative-baseline = 0pt

  let relative-dic = (:)

  let amount-baseline = 0pt

  let impact-first-line = auto

  if type(baseline) == dictionary {
    amount = baseline.remove("amount", default: 0pt)
    baseline-at = baseline.remove("at", default: auto)
    same-line-style = baseline.remove("same-line-style", default: auto)
    relative-to = baseline.remove("relative-to", default: "baseline")
    impact-first-line = baseline.remove("impact-first-line", default: auto)

    assert(
      baseline == (:),
      message: "The `label-baseline` legal keys are: "
        + baseline-allowed-keys.join(", ", last: " and ")
        + ";\nbut found: "
        + baseline.keys().join(", "),
    )

    assert(
      type(amount) in length-type or amount in baseline-align-allowed-keys or amount == auto,
      message: "The value of amount should be: `relative`, `auto`; or one of the following strings: "
        + baseline-align-allowed-keys.map(it => "\"" + it + "\"").join(", ", last: " and ")
        + ".",
    )
    amount = get-auto-value(amount, 0pt)

    // parse relative-to
    let _type = type(relative-to)

    if relative-to in baseline-align-style.item-first-line {
      relative-dic = (
        to: show-text(text-style, [A]),
        at: auto,
        shift: 0pt,
      )
    } else if _type == content {
      relative-dic = (
        to: show-text(text-style, relative-to),
        at: auto,
        shift: 0pt,
      )
    } else if _type in length-type {
      relative-dic = (
        to: show-text(text-style, [A]),
        at: auto,
        shift: relative-to,
      )
    } else if (
      _type == array
        and relative-to.len() == 2
        and (type(relative-to.at(0)) in (content,) + length-type)
        and relative-to.at(1) in baseline-align-style.item-first-line
    ) {
      let at = get-to-baseline-at.at(relative-to.at(1))
      if type(relative-to.at(0)) == content {
        relative-dic = (
          to: show-text(text-style, relative-to.at(0)),
          at: at,
          shift: 0pt,
        )
      } else {
        relative-dic = (
          to: show-text(text-style, [A]),
          at: at,
          shift: relative-to.at(0),
        )
      }
      // relative-to = relative-to.at(1)
    } else if relative-to in baseline-align-style.item {
      base-align = get-to-baseline-at.at(relative-to)
      baseline-at = base-align
    } else if _type == dictionary {
      relative-dic = (
        to: relative-to.remove("to", default: auto),
        at: relative-to.remove("at", default: auto),
        shift: relative-to.remove("shift", default: 0pt),
      )
      assert(
        relative-to == (:),
        message: "The keys of `relative-to` should be: `to`, `at`, `shift`. "
          + "\nBut found: "
          + relative-to.keys().join(", "),
      )

      if relative-dic.to == auto {
        relative-dic.to = show-text(text-style, [A])
      }

      assert(
        relative-dic.at in (auto, top, horizon, bottom),
        message: "The value of the key `at` should be `top`, `horizon`, `bottom`, or `auto`."
          + "\nBut found: "
          + repr(relative-dic.at)
          + ".",
      )

      assert(
        type(relative-dic.shift) in length-type,
        message: "The type of the key `shift` should be a relative." + "\nBut found: " + repr(relative-dic.shift) + ".",
      )

      assert(
        type(relative-dic.to) == content,
        message: "The type of the key `to` should be a content." + "\nBut found: " + repr(relative-dic.to) + ".",
      )
    } else {
      panic(
        "The value of the key `relative-to` should be one of the following strings: "
          + baseline-align-allowed-keys.map(it => "\"" + it + "\"").join(", ", last: " and ")
          + ";\n or a content"
          + ";\n or an array of two elements: the first element is a content or a length, and the second element is one of the following strings: \"baseline\", \"top\", \"center\", \"bottom\""
          + ";\n or a dictionary with keys: `to`, `at`, `shift`."
          + "\nBut found: "
          + repr(relative-to)
          + ".",
      )
    }

    assert(
      type(impact-first-line) == bool or impact-first-line == auto,
      message: "The value of the key `impact-first-line` should be a bool or `auto`."
        + "\nBut found: "
        + repr(impact-first-line)
        + ".",
    )

    assert(
      baseline-at in (auto, top, bottom, horizon),
      message: "The value of the key `at` should be `top`, `horizon`, `bottom`, or `auto`."
        + "\nBut found: "
        + repr(baseline-at)
        + ".",
    )
  } else {
    amount = baseline
    (baseline-inset, to-height) = get-baseline-inset-in-box(show-text(text-style, [A]))
  }

  if relative-dic != (:) {
    (baseline-inset, to-height) = get-baseline-inset-in-box(relative-dic.to)
    to-baseline = get-shift-baseline-to(baseline-inset, to-height, relative-dic.at)

    let (shift-ratio, shift-abs) = parse-relative(relative-dic.shift)
    relative-baseline = shift-ratio * to-height + shift-abs.to-absolute()

    if relative-to == "baseline" or relative-to == auto {
      amount-baseline = relative-baseline
    } else if relative-to == "center" {
      // baseline-at = horizon
      amount-baseline = to-height * .5 + relative-baseline - baseline-inset
    } else if relative-to == "top" {
      // baseline-at = top
      amount-baseline = to-height + relative-baseline - baseline-inset
    } else if relative-to == "bottom" {
      // baseline-at = bottom
      amount-baseline = relative-baseline - baseline-inset
    } else {
      amount-baseline = to-baseline + relative-baseline - baseline-inset
    }
  }

  // panic(amount)
  if amount == auto {
    amount = 0pt
  } else if amount == "center" {
    baseline-at = horizon
    amount = baseline-inset - to-height * .5
    base-align = none
  } else if amount == "top" {
    baseline-at = top
    amount = -to-height + baseline-inset
    base-align = none
  } else if amount == "bottom" {
    baseline-at = bottom
    amount = baseline-inset
    base-align = none
  } else if amount == "baseline" {
    baseline-at = auto
    amount = 0pt
    base-align = none
  } else if amount == "top-item" {
    amount = 0pt
    base-align = top
  } else if amount == "horizon-item" {
    amount = 0pt
    base-align = horizon
  } else if amount == "bottom-item" {
    amount = 0pt
    base-align = bottom
  } else {
    assert(
      type(amount) in length-type,
      message: "The value of `label-baseline` should be: `relative`, `auto`; or one of the following strings: "
        + baseline-align-allowed-keys.map(it => "\"" + it + "\"").join(", ", last: " and ")
        + "."
        + "\nBut found: "
        + repr(amount)
        + ".",
    )

    let (amount-ratio, amount-length) = parse-relative(amount)
    amount = amount-length.to-absolute() + amount-ratio * label-height - amount-baseline
  }
  if same-line-style != auto {
    same-line-style = parse-same-line-label-style(same-line-style, label-height: label-height)
  }
  return (amount, same-line-style, base-align, impact-first-line, baseline-at)
}
