#import "../util/parse-args.typ": *
#import "../util/level-state.typ": auto-detect-tight

#let get-tight-mode(
  item-tight-mode,
  item-tight-item-mode,
  item-level,
  config-tight-mode,
  config-tight-item-mode,
  config-level,
  tight-mode,
  tight-item-mode,
  level,
  ..args-with-tags-item,
) = {
  let curr-tight-mode = parse-args-with-level(item-tight-mode, item-level, ..args-with-tags-item)
  let curr-tight-item-mode = parse-args-with-level(item-tight-item-mode, item-level, ..args-with-tags-item)
  curr-tight-mode = get-none-value(
    parse-args-with-level(config-tight-mode, config-level, ..args-with-tags-item),
    curr-tight-mode,
  )
  curr-tight-item-mode = get-none-value(
    parse-args-with-level(
      config-tight-item-mode,
      config-level,
      ..args-with-tags-item,
    ),
    curr-tight-item-mode,
  )
  curr-tight-mode = get-none-value(
    parse-args-with-level(tight-mode, level, ..args-with-tags-item),
    curr-tight-mode,
  )
  curr-tight-item-mode = get-none-value(
    parse-args-with-level(tight-item-mode, level, ..args-with-tags-item),
    curr-tight-item-mode,
  )
  return (curr-tight-mode, curr-tight-item-mode)
}

#let TightMode = (
  "always-tight": "always-tight",
  "never-tight": "never-tight",
  "compact-tight": "compact-tight",
)

#let parse-v-spacing(
  curr-level,
  item-spacing,
  whole-spacing,
  curr-tight-mode,
  curr-tight-item-mode,
  spacing-default: 0pt,
  tight: false,
  ..args,
) = {
  let item-args = args.named()
  let _ = item-args.remove("tag", default: none)
  let _ = item-args.remove("number", default: none)
  let _ = item-args.remove("marker", default: none)
  let _whole-spacing = parse-args-with-level(whole-spacing, curr-level, ..item-args)
  let (elem-above-spacing, elem-below-spacing) = if _whole-spacing != auto {
    let _type = type(_whole-spacing)
    if _type in length-type-with-fraction {
      // for spacing, we need to get the relative length
      let abs-whole-spacing = get-relative-length(_whole-spacing)
      (("block": _whole-spacing, "spacing": abs-whole-spacing), _whole-spacing)
    } else if _type == dictionary {
      let above = _whole-spacing.remove("above", default: auto)
      let below = _whole-spacing.remove("below", default: auto)
      assert(
        _whole-spacing == (:),
        message: "The dictionary of `whole-spacing` should have keys: `above` and `below`."
          + "\nBut found: "
          + _whole-spacing.keys().join(", ")
          + ".",
      )
      assert(
        (above == auto or type(above) in length-type-with-fraction),
        message: "The value of `above` should be a length, relative, ratio, fraction or `auto`."
          + "\nBut found: "
          + repr(above)
          + ".",
      )
      assert(
        (below == auto or type(below) in length-type-with-fraction),
        message: "The value of `below` should be a length, relative, ratio, fraction or `auto`."
          + "\nBut found: "
          + repr(below)
          + ".",
      )
      above = get-auto-value(above, spacing-default)
      (("block": above, "spacing": above), below)
    } else if _whole-spacing != none {
      panic(
        "`whole-spacing` should be a length or `auto` or a dictionary with keys `above` and `below`."
          + "\nBut found: "
          + repr(_whole-spacing)
          + ".",
      )
    } else {
      (none, none)
    }
  } else {
    let is-auto-tight-mode = false
    let (default-above, default-below) = (
      ("block": auto, "spacing": if tight { spacing-default } else { par.spacing }),
      auto,
    )

    if curr-tight-mode not in (auto, none) and type(curr-tight-mode) != dictionary {
      if curr-tight-mode == TightMode.always-tight {
        default-above.block = par.leading
        default-above.spacing = par.leading
      } else if curr-tight-mode == TightMode.never-tight {
        default-above.block = par.spacing
        default-above.spacing = par.spacing
      } else if curr-tight-mode == TightMode.compact-tight {
        default-above.block = par.leading
        default-above.spacing = par.leading
        default-below = par.leading
      } else {
        panic(
          "Invalid tight-mode. The legal values are the following strings: "
            + TightMode.keys().map(it => "\"" + it + "\"").join(", ", last: " and ")
            + "; "
            + "or `auto`; or a dictionary."
            + "\nBut found: "
            + repr(curr-tight-mode)
            + ".",
        )
      }
    } else {
      is-auto-tight-mode = true
    }

    let is-enable-par-tight-below-spacing = false
    let (tight-h-spacing, not-tight-h-spacing, par-tight-h-spacing, par-not-tight-h-spacing) = if (
      is-auto-tight-mode == true
    ) {
      if curr-tight-mode == auto {
        ((spacing-default, auto), (par.spacing, auto), (par.spacing, auto), (par.spacing, auto))
      } else {
        if type(curr-tight-mode) == dictionary {
          let default-tight-spacing = (spacing-default, auto)
          let default-not-tight-spacing = (auto, auto)

          let tight-spacing = curr-tight-mode.remove("tight", default: default-tight-spacing)
          let not-tight-spacing = curr-tight-mode.remove("not-tight", default: default-not-tight-spacing)
          let par-tight-spacing = curr-tight-mode.remove("par-tight", default: auto)
          let par-not-tight-spacing = curr-tight-mode.remove("par-not-tight", default: auto)

          // auto value case
          tight-spacing = get-auto-value(tight-spacing, default-tight-spacing)
          not-tight-spacing = get-auto-value(not-tight-spacing, default-not-tight-spacing)
          par-tight-spacing = get-auto-value(par-tight-spacing, not-tight-spacing)
          par-not-tight-spacing = get-auto-value(par-not-tight-spacing, not-tight-spacing)

          if type(tight-spacing) in length-type-with-fraction {
            tight-spacing = (tight-spacing, auto)
          }
          if type(not-tight-spacing) in length-type-with-fraction {
            not-tight-spacing = (not-tight-spacing, auto)
          }
          if type(par-tight-spacing) in length-type-with-fraction {
            par-tight-spacing = (par-tight-spacing, auto)
          }

          if type(par-not-tight-spacing) in length-type-with-fraction {
            par-not-tight-spacing = (par-not-tight-spacing, auto)
          }

          assert(
            curr-tight-mode == (:),
            message: "The keys of `tight-mode` should be: `tight`, `not-tight`, `par-tight`, `par-not-tight`."
              + "\nBut found: "
              + curr-tight-mode.keys().join(", "),
          )

          assert(
            type(tight-spacing) == array
              and tight-spacing.len() == 2
              and type(not-tight-spacing) == array
              and not-tight-spacing.len() == 2
              and type(par-tight-spacing) == array
              and par-tight-spacing.len() == 2
              and type(par-not-tight-spacing) == array
              and par-not-tight-spacing.len() == 2,
            message: "Hint: The values of `tight`, `not-tight`, `par-tight` and `par-not-tight` should be relative, fraction or `auto`, or array with two elements (relative, fraction or `auto`).",
          )
          for i in range(0, 2) {
            assert(
              (
                (tight-spacing.at(i) == auto or type(tight-spacing.at(i)) in length-type-with-fraction)
                  and (not-tight-spacing.at(i) == auto or type(not-tight-spacing.at(i)) in length-type-with-fraction)
                  and (par-tight-spacing.at(i) == auto or type(par-tight-spacing.at(i)) in length-type-with-fraction)
                  and (
                    par-not-tight-spacing.at(i) == auto
                      or type(par-not-tight-spacing.at(i)) in length-type-with-fraction
                  )
              ),
              message: "Hint: The elements should be relative, fraction or `auto`.",
            )
          }
          is-enable-par-tight-below-spacing = (
            not-tight-spacing.at(1) != par-not-tight-spacing.at(1) or tight-spacing.at(1) != par-tight-spacing.at(1)
          )
          (tight-spacing, not-tight-spacing, par-tight-spacing, par-not-tight-spacing)
        } else {
          ((none, none), (none, none), (none, none), (none, none))
        }
      }
    } else { ((none, none), (none, none), (none, none), (none, none)) }

    // feat: auto-detect-tight (ver0.3.0)
    if is-auto-tight-mode == true {
      let is-par = false
      if is-enable-par-tight-below-spacing {
        let enable-auto-detect-tight = auto-detect-tight.get()
        // if not enable-auto-detect-tight {
        //   panic(
        //     "Since the below spacings in tight mode is different, to enable this feature, try to use `config.auto-detect-tight`.",
        //   )
        // }
        if enable-auto-detect-tight {
          let here = std.here()
          let _pars = query(selector(metadata.where(value: paragraph-ID)).before(here))
          is-par = _pars.len() > 0 and _pars.last().location().position() == here.position() // is this enough? at least in default it looks fine.
        }
      }
      if tight {
        (
          ("block": par-tight-h-spacing.at(0), "spacing": get-relative-length(tight-h-spacing.at(0))),
          if is-par {
            par-tight-h-spacing.at(1)
          } else {
            tight-h-spacing.at(1)
          },
        )
      } else {
        (
          (
            "block": par-not-tight-h-spacing.at(0),
            "spacing": get-relative-length(not-tight-h-spacing.at(0)),
          ),
          if is-par {
            par-not-tight-h-spacing.at(1)
          } else {
            not-tight-h-spacing.at(1)
          },
        )
      }
    } else {
      (default-above, default-below)
    }
  }
  // feat: tight-item-mode (ver0.3.0)
  let auto-item-spacing = if curr-tight-item-mode == "always-tight" {
    par.leading
  } else if curr-tight-item-mode == "never-tight" {
    par.spacing
  } else if curr-tight-item-mode == auto {
    if spacing-default == auto {
      if tight { par.leading } else { par.spacing }
    } else {
      spacing-default
    }
  } else if type(curr-tight-item-mode) == dictionary {
    let tight-item-spacing = curr-tight-item-mode.remove("tight", default: auto)
    let not-tight-item-spacing = curr-tight-item-mode.remove("not-tight", default: auto)
    assert(
      curr-tight-item-mode == (:),
      message: "The keys of `tight-item-mode` should be: `tight`, `not-tight`."
        + "\nBut found: "
        + repr(curr-tight-item-mode.keys().join(", "))
        + ".",
    )
    assert(
      (tight-item-spacing == auto or type(tight-item-spacing) in length-type-with-fraction),
      message: "Hint: The values of `tight` should be relative, fraction or `auto`."
        + "\nBut found: "
        + repr(tight-item-spacing)
        + ".",
    )
    assert(
      (not-tight-item-spacing == auto or type(not-tight-item-spacing) in length-type-with-fraction),
      message: "Hint: The values of `not-tight` should be relative, fraction or `auto`."
        + "\nBut found: "
        + repr(not-tight-item-spacing)
        + ".",
    )
    tight-item-spacing = get-auto-value(tight-item-spacing, par.leading)
    not-tight-item-spacing = get-auto-value(not-tight-item-spacing, par.spacing)
    if tight { tight-item-spacing } else { not-tight-item-spacing }
  } else if curr-tight-item-mode != none {
    panic(
      "The legal values of `tight-item-mode` should be the following strings: \"always-tight\", \"never-tight\"; or `auto`; or a dictionary with keys: tight and not-tight"
        + "\nBut found: "
        + repr(curr-tight-item-mode)
        + ".",
    )
  }

  let curr-item-spacing = parse-general-func-with-level-n(
    item-spacing,
    auto,
    auto-item-spacing,
    ..args,
  )(
    curr-level,
  )

  return (
    elem-above-spacing, // with two keys: block, spacing
    elem-below-spacing,
    curr-item-spacing,
    auto-item-spacing,
  )
}

#let get-v-spacing(
  rel-level,
  curr-enum-level,
  level-item,
  item-spacing-f,
  whole-spacing-f,
  item-spacing-f-e,
  whole-spacing-f-e,
  item-spacing-f-item,
  whole-spacing-f-item,
  curr-tight-mode,
  curr-tight-item-mode,
  spacing-default: 0pt,
  tight: false,
  args-with-tags,
  args-with-tags-item,
) = {
  let (elem-above-spacing-f, elem-below-spacing-f, item-spacing-f, auto-item-spacing-f) = parse-v-spacing(
    rel-level,
    item-spacing-f,
    whole-spacing-f,
    curr-tight-mode,
    curr-tight-item-mode,
    spacing-default: spacing-default,
    tight: tight,
    ..args-with-tags,
  )
  let (
    elem-above-spacing-f-e,
    elem-below-spacing-f-e,
    item-spacing-f-e,
    auto-item-spacing-f-e,
  ) = parse-v-spacing(
    curr-enum-level,
    item-spacing-f-e,
    whole-spacing-f-e,
    curr-tight-mode,
    curr-tight-item-mode,
    spacing-default: spacing-default,
    tight: tight,
    ..args-with-tags,
  )

  let (
    elem-above-spacing-f-item,
    elem-below-spacing-f-item,
    item-spacing-f-item,
    auto-item-spacing-f-item,
  ) = {
    let item-args = n => parse-v-spacing(
      level-item(n),
      item-spacing-f-item(n),
      whole-spacing-f-item(n),
      curr-tight-mode,
      curr-tight-item-mode,
      spacing-default: spacing-default,
      tight: tight,
      ..args-with-tags-item,
    )
    let args-size = 4 // TODO
    for i in range(args-size) {
      (n => item-args(n).at(i),)
    }
  }

  return (
    get-none-value(elem-above-spacing-f, get-none-value(elem-above-spacing-f-e, elem-above-spacing-f-item(0))),
    get-none-value(elem-below-spacing-f, get-none-value(elem-below-spacing-f-e, elem-below-spacing-f-item(0))),
    (n, ..more-args) => get-none-value(item-spacing-f(n, ..more-args), get-none-value(
      item-spacing-f-e(n, ..more-args),
      item-spacing-f-item(n)(n, ..more-args),
    )),
    get-none-value(auto-item-spacing-f, get-none-value(
      auto-item-spacing-f-e,
      auto-item-spacing-f-item(0),
    )),
  )
}



#let get-item-spacing(
  index,
  len,
  item-spacing,
  enum-above-block-spacing,
  enum-below-spacing,
  pre-item-below-spacing,
  curr-auto-item-spacing,
) = {
  let is-full-item-spacing = false
  let above-item-spacing
  let below-item-spacing
  let _item-spacing = item-spacing
  let pre-item-below-spacing = pre-item-below-spacing
  if type(_item-spacing) == dictionary {
    above-item-spacing = _item-spacing.remove("above", default: auto)
    below-item-spacing = _item-spacing.remove("below", default: auto)
    assert(
      (
        (above-item-spacing == auto or type(above-item-spacing) in length-type-with-fraction)
          and (below-item-spacing == auto or type(below-item-spacing) in length-type-with-fraction)
      )
        and _item-spacing == (:),
      message: "The key value of `item-spacing` must be \"above\" and \"below\", with value be a length or `auto`."
        + "\nBut found: "
        + repr(item-spacing)
        + ".",
    )
    if pre-item-below-spacing == auto and above-item-spacing == auto {
      above-item-spacing = curr-auto-item-spacing
    } else {
      is-full-item-spacing = true
    }
    pre-item-below-spacing = below-item-spacing
  } else {
    pre-item-below-spacing = below-item-spacing // TODO: none
    above-item-spacing = _item-spacing
    below-item-spacing = _item-spacing
  }

  let (above-spacing, below-spacing) = {
    if index == 0 {
      if index == len - 1 {
        // last and first
        let _temp-enum-below-spacing = if is-full-item-spacing and below-item-spacing != auto {
          0pt
        } else {
          enum-below-spacing
        }
        (enum-above-block-spacing, _temp-enum-below-spacing)
      } else {
        // first but not last
        (enum-above-block-spacing, below-item-spacing)
      }
    } else if index == len - 1 {
      // last but not first
      let _temp-enum-below-spacing = if is-full-item-spacing and below-item-spacing != auto {
        0pt
      } else {
        enum-below-spacing
      }
      (above-item-spacing, _temp-enum-below-spacing)
    } else {
      // not first and not last
      (above-item-spacing, below-item-spacing)
    }
  }
  return (
    is-full-item-spacing,
    above-spacing,
    below-spacing,
    pre-item-below-spacing,
  )
}
