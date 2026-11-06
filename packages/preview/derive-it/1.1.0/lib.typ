/*

`ded-nat` is a function that expects:
- `stcolor`: the stroke color of the indentation guides. Optional: Default is `black`.
- `arr`: an array with the shape, it can be provided in two shapes.
    - 4 items: (dependency: text content, indentation: integer starting from 0, formula: text content, rule: text content).
    - 3 items: the same as above, but without the dependency.
- `style-dep`: the styling function that will be applied to the dependencies. Optional: Default is `content => text(style: "italic", content)`.
- `style-formula`: the styling function that will be applied to the formula. Optional: Default is `content => content`.
- `style-rule`: the styling function that will be applied to the rule. Optional: Default is `content => text(style: "bold", content)`.
- `nested-boxes`: instead of using indentation lines, use nested boxes. Optional: Default is `false`.

*/


// internal function that stringifies a line array (of a natural deduction table)
// this may be removed at any time
#let derive-it-internal-stringify-line(line-arr) = {
  let to-string(cntnt) = {
    if type(cntnt) != content {
      str(cntnt)
    } else if cntnt.has("text") {
      cntnt.text
    } else if cntnt.has("children") {
      cntnt.children.map(to-string).join("")
    } else if cntnt.has("body") {
      to-string(cntnt.body)
    } else if cntnt == [ ] {
      " "
    }
  }

  if type(line-arr) == str or type(line-arr) == int or type(line-arr) == float {
    str(line-arr)
  } else if type(line-arr) == array {
    line-arr.map(to-string).intersperse(", ").sum()
  } else {
    repr(line-arr)
  }
}

// internal function to validate that each line given by the user is correct, with a descriptive error otherwise
// this may be removed at any time
#let derive-it-internal-validate-line(line, line-num, line-size: none) = {
  let line-text = "[At line: " + str(line-num + 1) + "]: "
  let stringified = "'" + derive-it-internal-stringify-line(line) + "'"
  let ty = type(line)
  if ty != array {
    panic(
      line-text
        + "Line is a '"
        + ty
        + "' instead of an array of 3 or 4 elements: "
        + stringified,
    )
  } else {
    // if the linesize is not the provided in the arguments or its not 3 or 4
    if (line-size != none) and (line.len() != line-size) {
      panic(
        line-text
          + "Line (array) has an incorrect number of elements: "
          + str(line.len())
          + ". It should have "
          + str(line-size)
          + ": "
          + stringified,
      )
    } else if line-size == none and (line.len() != 3 and line.len() != 4) {
      panic(
        line-text
          + "Line (array) has an incorrect number of elements: "
          + str(line.len())
          + ". It should have 3 or 4 elements: "
          + stringified,
      )
    }

    let ruleVal = line.last()
    if type(ruleVal) != str and type(ruleVal) != content {
      panic(
        line-text
          + "Line (array) should receive a 'string' or 'content' as the rule, instead it received '"
          + type(ruleVal)
          + "': "
          + stringified,
      )
    }

    let indentVal = if line.len() == 3 {
      line.at(0)
    } else {
      line.at(1)
    }
    if type(indentVal) != int {
      panic(
        line-text
          + "Line (array) should receive an 'integer' as the indentation, instead it received '"
          + type(indentVal)
          + "': "
          + stringified,
      )
    }
  }
}

#let derive-it-internal-default-style-dep(a) = text(style: "italic", a)
#let derive-it-internal-default-style-formula(a) = a
#let derive-it-internal-default-style-rule(a) = text(weight: "bold", a)

#let derive-it-internal-array-checks(
  arr,
  style-dep,
  style-formula,
  style-rule,
) = {
  let (has-dependencies, line-size) = if arr.at(0).len() == 4 {
    (true, 4)
  } else { (false, 3) }
  let i = 0
  let max-dep-width = 0pt
  let max-indent-level = 0
  let max-formula-width = 0pt
  while i < arr.len() {
    derive-it-internal-validate-line(arr.at(i), i + 1, line-size: line-size)
    if has-dependencies {
      let styled-formula = style-formula(arr.at(i).at(2))
      arr.at(i) = (
        style-dep(arr.at(i).at(0)),
        arr.at(i).at(1),
        styled-formula,
        style-rule(arr.at(i).at(3)),
      )
      max-formula-width = calc.max(
        max-formula-width,
        measure(styled-formula).width,
      )
      max-indent-level = calc.max(max-indent-level, arr.at(i).at(1))
      max-dep-width = calc.max(measure[#arr.at(i).at(0)].width, max-dep-width)
    } else {
      let styled-formula = style-formula(arr.at(i).at(1))
      arr.at(i) = (
        arr.at(i).at(0),
        styled-formula,
        style-rule(arr.at(i).at(2)),
      )
      max-formula-width = calc.max(
        max-formula-width,
        measure(styled-formula).width,
      )
      max-indent-level = calc.max(max-indent-level, arr.at(i).at(0))
    }
    i += 1
  }
  return (
    max-dep-width: max-dep-width,
    has-dependencies: has-dependencies,
    line-size: line-size,
    max-indent-level: max-indent-level,
    max-formula-width: max-formula-width,
    arr: arr,
  )
}

#let ded-nat(
  stcolor: black,
  arr: array,
  style-dep: derive-it-internal-default-style-dep,
  style-formula: derive-it-internal-default-style-formula,
  style-rule: derive-it-internal-default-style-rule,
  nested-boxes: false,
) = context {
  assert(type(arr) == array, message: "The input must be an array.")

  // validate the input and obtain metrics
  let (
    has-dependencies,
    line-size,
    max-dep-width,
    max-indent-level,
    max-formula-width,
    arr,
  ) = derive-it-internal-array-checks(arr, style-dep, style-formula, style-rule)

  let maxWidth = 0pt
  let tupArr = ()
  let i = 0
  while i < arr.len() {
    if not has-dependencies {
      arr.at(i).insert(0, none)
    }
    let (dep, indent, formula, rule) = arr.at(i)

    // +1 -> more indented
    // -1 -> less indented
    // 0  -> equally indented
    let prev-indentation-diff = if (i == 0) { -1 } else {
      // previous line arrays always have 4 elements (dep=none)
      arr.at(i - 1).at(1) - indent
    }
    let next-indentation-diff = if (arr.len() <= i + 1) { -1 } else {
      let ix = if has-dependencies { 1 } else { 0 }
      arr.at(i + 1).at(ix) - indent
    }

    let bl = formula

    ///////////////////////// FOR /////////////////////////////
    let indent-index-top-range = if nested-boxes { max-indent-level + 1 } else {
      indent
    }
    for indent-index in range(0, indent-index-top-range) {
      let stroke = (top: 0pt, right: 0pt, bottom: 0pt, left: 0pt)
      let strength = if (
        (indent >= max-indent-level - indent-index) or not nested-boxes
      ) {
        1pt
      } else { 0.0pt } // 'else' branch for debugging
      let stroke-line-config = strength + stcolor

      if nested-boxes {
        if (indent == (max-indent-level - indent-index)) {
          // we're in the box that corresponds to the indentation of this formula
          if prev-indentation-diff <= -1 {
            // if the previous formula is in a lower indentation level
            stroke.top = stroke-line-config
          }
          if next-indentation-diff <= -1 {
            // if the next formula is in a lower indentation level
            stroke.bottom = stroke-line-config
          }
        }
        stroke.left = stroke-line-config
        stroke.right = stroke-line-config
      } else {
        if next-indentation-diff == -1 and indent-index == 0 {
          stroke.bottom = stroke-line-config
        }
        stroke.left = stroke-line-config
      }

      let rect-width = if nested-boxes and (indent-index == 0) {
        max-formula-width + 10pt // 5pt each for left & right
      } else {
        auto
      }

      let external-box-inset = if nested-boxes {
        if (indent-index != max-indent-level) {
          (x: 1em)
        } else {
          (left: 0em)
        }
      } else {
        (left: 1em)
      }

      let rect-inset = if indent-index == 0 { 5pt } else { 0pt }
      // add stroke for debugging
      bl = box(/* stroke: 0.0pt + blue, */ inset: external-box-inset, rect(
        stroke: stroke,
        inset: rect-inset,
        width: rect-width,
        bl,
      ))
    }
    ///////////////////////// END FOR /////////////////////////////

    let line-index-content = box(width: 1.5em)[#(i + 1).]
    let (line-inset, dep-and-number-inset) = if (
      not nested-boxes and indent == 0
    ) {
      ((y: 0.5em), 0pt)
    } else {
      (0pt, (y: 5pt))
    }

    let line = if has-dependencies {
      let dependency = box(width: max-dep-width + 1em)[#dep]
      let l = box(inset: line-inset)[#box(
          inset: dep-and-number-inset,
        )[#dependency #line-index-content] #bl]
      maxWidth = calc.max(maxWidth, measure(l).width)
      l
    } else {
      let l = box(inset: line-inset)[#box(
          inset: dep-and-number-inset,
          line-index-content,
        ) #bl]
      maxWidth = calc.max(maxWidth, measure(l).width)
      l
    }

    rule = box(baseline: -0.5em, rule)
    tupArr.push((line, rule))
    i += 1
  }
  tupArr = tupArr.map(a => [#box(width: maxWidth, a.at(0)) #h(1em) #a.at(1)])

  block(
    align(
      start,
      stack(..tupArr),
    ),
  )
}

/*

`ded-nat-boxed` is a function that returns the deduction in a `box` and expects:
- `stcolor`: the stroke color of the indentation guides. Optional: Default is `black`.
- `premises-and-conclusion`: bool, whether to automatically insert or not the premises and conclusion of the derivation above the lines. Optional: Default is `true`.
- `premise-rule-text`: text content, used for finding the premises' formulas when `premises-and-conclusion` is set to `true`. Optional: Default is `"PR"`.
- `arr`: an array with the shape, it can be provided in two shapes.
    - 4 items: (dependency: text content, indentation: integer starting from 0, formula: text content, rule: text content).
    - 3 items: the same as above, but without the dependency.
- `style-dep`: the styling function that will be applied to the dependencies. Optional: Default is `content => text(style: "italic", content)`.
- `style-formula`: the styling function that will be applied to the formula. Optional: Default is `content => content`.
- `style-rule`: the styling function that will be applied to the rule. Optional: Default is `content => text(style: "bold", content)`.
- `nested-boxes`: instead of using indentation lines, use nested boxes. Optional: Default is `false`.

*/

#let ded-nat-boxed(
  stcolor: black,
  premises-and-conclusion: true,
  premise-rule-text: "PR",
  style-dep: derive-it-internal-default-style-dep,
  style-formula: derive-it-internal-default-style-formula,
  style-rule: derive-it-internal-default-style-rule,
  nested-boxes: false,
  arr: array,
) = {
  let premConcText = ""
  if premises-and-conclusion {
    let premises = arr
      .filter(x => x.last() == premise-rule-text)
      .map(x => x.at(2))
    let conclusion = arr.last().at(2)
    let joinedPremises = [#premises.join([$,$ \ ])]
    premConcText = [ $\ #joinedPremises \ tack #conclusion$ ]
  }

  box(
    stroke: stcolor,
    inset: 8pt,
    radius: 8pt,
  )[
    #align(center)[
      #if premises-and-conclusion {
        premConcText
      } #ded-nat(
        stcolor: stcolor,
        style-dep: style-dep,
        style-formula: style-formula,
        style-rule: style-rule,
        nested-boxes: nested-boxes,
        arr: arr,
      )
    ]
  ]
}

