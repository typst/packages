#let (
  generate-empty,
  generate-table,
  truth-table,
  truth-table-empty,
  NAND,
  NOR,
  nand,
  nor,
  karnaugh-empty,
  //karnaugh,
) = {
  let symboles-conv(a) = {
    if (a) {
      "1"
    } else { "0" }
  }

  /// Transform a simple math equation to a string
  let _strstack(obj) = {
    let i = obj.at("body", default: false)
    if i == false {
      return obj
        .values()
        .map(a => a.map(subobj => if subobj.has("text") {
          subobj.text
        } else {
          if subobj.fields().len() == 0 {
            " "
          } else {
            if (subobj.has("b")) {
              subobj.base.text + "_" + subobj.b.text
            } else {
              _strstack(subobj.fields())
            }
          }
        }))
    } else if obj.body.has("b") {
      return obj.body.base.text + "_" + obj.body.b.text
    } else if not obj.body.has("children") {
      return " "
    } else {
      return obj
        .body
        .children
        .map(subobj => {
          if subobj.has("text") {
            subobj.text
          } else {
            if subobj.fields().len() == 0 {
              " "
            } else {
              if (subobj.has("b")) {
                subobj.base.text + "_" + subobj.b.text
              } else {
                _strstack(subobj.fields())
              }
            }
          }
        })
        .flatten()
        .join("")
    }
  }

  /// Replaces names with their values (true or false)
  let _replaces(names, vals, obj) = {
    // Replace names by their values
    let text = obj
    for e in range(names.len()) {
      let reg = regex("\b(?:\(?\s?)(" + names.at(e) + ")(?:\s?\W?\)?)?\b")
      for f in text.matches(reg) {
        text = text.replace(reg, vals.at(e))
      }
    }

    // Basic operations, they doesn't need a particular approach
    text = str(text.replace("∧", "and").replace("∨", "or")).replace("¬", "not").replace("→", "⇒")

    // => Approach
    // Please implement the do while :pray:
    while true {
      let pos = text.match(regex("([(]+.*[)]|[a-zA-Z](_\d+)?)+[ ]*⇒[ ]*([(]+.*[)]|[a-zA-Z](_\d+)?)+")) // regex hell
      if (pos != none) {
        text = text.replace(pos.text, "not " + pos.text.replace("⇒", "or", count: 1))
      } else { break }
    }

    // ↑ Approach
    while true {
      let pos = text.match(regex("([(]+.*[)]|[a-zA-Z](_\d+)?)+[ ]*↑[ ]*([(]+.*[)]|[a-zA-Z](_\d+)?)+"))
      if (pos != none) {
        text = text.replace(pos.text, "not(" + pos.text.replace("↑", "and", count: 1) + ")")
      } else { break }
    }

    // ↓ Approach
    while true {
      let pos = text.match(regex("([(]+.*[)]|[a-zA-Z](_\d+)?)+[ ]*↓[ ]*([(]+.*[)]|[a-zA-Z](_\d+)?)+"))
      if (pos != none) {
        text = text.replace(pos.text, "not(" + pos.text.replace("↓", "or", count: 1) + ")")
      } else { break }
    }

    // <=> Approach
    while true {
      let pos = text.match(regex("([(]+.*[)]|[a-zA-Z](_\d+)?)+[ ]*⇔[ ]*([(]+.*[)]|[a-zA-Z](_\d+)?)+"))
      if (pos != none) {
        text = text.replace(pos.text, "(" + pos.text.replace("⇔", "==", count: 1) + ")")
      } else { break }
    }

    // a ? b : c Approach
    while true {
      let pos = text.match(
        regex("([(]+.*[)]|[a-zA-Z](_\d+)?)+[ ]*\?[ ]*([(]+.*[)]|[a-zA-Z](_\d+)?)+[ ]*\:[ ]*([(]+.*[)]|[a-zA-Z](_\d+)?)+"),
      )
      if (pos != none) {
        text = text.replace(
          pos.text,
          " if (" + pos.text.replace("?", "){ ").replace(":", " } else { ") + " }",
        )
      } else { break }
    }

    // ⊕ Approach
    while true {
      let pos = text.match(regex("([(]+.*[)]|[a-zA-Z](_\d+)?)+[ ]*⊕[ ]*([(]+.*[)]|[a-zA-Z](_\d+)?)+"))
      if (pos != none) {
        text = text.replace(pos.text, "not (" + pos.text.replace("⊕", "==", count: 1) + ")")
      } else { break }
    }

    return text
  }

  /// Extract all propositions
  let _extract(..obj) = {
    let single_letters = ()
    for operation in obj.pos() {
      let string_operation = _strstack(operation).split(" ")
      for substring in string_operation {
        let match = substring.match(regex("[a-zA-Z](_\d+)?"))
        if match != none and (match.text not in single_letters) {
          single_letters.push(match.text)
        }
      }
    }
    return single_letters
  }

  let _gen-nb-left-empty-truth(reverse: false, sc: symboles-conv, bL, row) = {
    let rng = range(1, bL + 1)
    for col in if reverse { rng } else { rng.rev() } {
      let raised = calc.pow(2, col - 1)
      let vl = if reverse { (L - 1) - row } else { row }
      let value = not calc.even(calc.floor(vl / raised))
      ([#sc(value)],)
    }
  }

  let _mathed(obj) = eval(obj, mode: "math")

  let truth-table-empty(reverse: false, order: "default", sc: symboles-conv, info, data) = {
    let base = _extract(..info)

    if order.contains("alphabetical") {
      base = base.sorted(
        key: a => {
          let val = a.split("_")
          let m = (
            for i in range(val.len()) {
              if i == 0 { (val.at(i).to-unicode() * 1000,) } else { (int(val.at(i)),) }
            }
          )
          m.reduce((a, b) => a + b)
        },
      )
    }
    if order.contains("reverse") {
      base = base.rev()
    }

    let bL = base.len()
    let L = calc.pow(2, bL)
    let iL = info.len()
    let nbBox = (iL + bL) * calc.pow(2, bL)

    if data.len() < nbBox {
      for _ in range(nbBox - data.len()) {
        data.push([])
      }
    }

    table(
      columns: iL + bL,
      ..base.map(_mathed),
      ..info,
      ..(
        for row in range(L) {
          (.._gen-nb-left-empty-truth(reverse: reverse, sc: sc, bL, row),)
          (
            ..data.slice(row * iL, count: iL).map(a => [#if type(a) != "content" { sc(a) } else { a }]),
          )
        }
      ),
    )
  }

  let _first-elem-karnaugh = (0, 0, 1, 1)
  let _second-elem-karnaugh = (0, 1, 1, 0)

  let _nb-cols-karnaugh = (0, 3, 3, 5, 5)

  let _concat-name-karnaugh(list: ()) = {
    let bL = list.len()
    let name = list.at(0)
    if (bL == 2) { return name + "/" + list.at(1) } else if (bL == 3) {
      return name + "/" + list.at(1) + list.at(2)
    } else { return name + list.at(1) + "/" + list.at(2) + list.at(3) }
  }

  let _concat-object-karnaugh(reverse: false, sc: symboles-conv, i: 0, nb: false) = {
    let m = [#sc(_first-elem-karnaugh.at(if reverse { 3 - i } else { i }) == 1)]
    let n = [#sc(_second-elem-karnaugh.at(if reverse { 3 - i } else { i }) == 1)]
    n
    if nb {
      m
    }
  }

  let karnaugh-empty(reverse: false, order: "default", sc: symboles-conv, info, data) = {
    let base = _extract(..info)

    if order.contains("alphabetical") {
      base = base.sorted(
        key: a => {
          let val = a.split("_")
          let m = (
            for i in range(val.len()) {
              if i == 0 { (val.at(i).to-unicode() * 1000,) } else { (int(val.at(i)),) }
            }
          )
          m.reduce((a, b) => a + b)
        },
      )
    }
    if order.contains("reverse") {
      base = base.rev()
    }

    let bL = base.len()
    assert(
      bL >= 2,
      message: "You need more than 1 variable and less or equal 4 variables to use a karnaugh table.",
    )

    let L = int(calc.pow(2, bL - 1) / 2)
    if L == 1 { L = 2 } // hack for now
    let nbBox = calc.pow(2, bL)
    let columns = _nb-cols-karnaugh.at(bL)

    let name = _concat-name-karnaugh(list: base)
    if data.len() < nbBox {
      for _ in range(nbBox - data.len()) {
        data.push([ ])
      }
    }

    table(
      columns: columns,
      name,
      ..for col in range(columns - 1) {
        let m = _concat-object-karnaugh(reverse: reverse, sc: sc, i: col, nb: bL >= 3)
        (m,)
      },
      ..for row in range(L) {
        (
          ..(
            [#_concat-object-karnaugh(reverse: reverse, sc: sc, i: row, nb: bL >= 4)],
          ),
        )

        (
          ..data
            .slice(row * (columns - 1), count: columns - 1)
            .map(a => [#if type(a) != "content" { sc(a) } else { a }]),
        )
      },
    )
  }

  /*let karnaugh(sc: symboles-conv, ..info) = {
    let objInfo = info.pos()
    let base = _extract(..objInfo)
    let data = ()
    let bL = base.len()
    assert(
      bL >= 2,
      message: "You need more than 1 variable and max 4 variables to use a karnaugh table.",
    );

    let L = int(calc.pow(2, bL - 1) / 2);
    if L == 1 { L = 2 } // hack for now
    let nbBox = calc.pow(2, bL)
    let columns = _nb-cols-karnaugh.at(bL)

    let transform = objInfo.map(_strstack).map(a => "(" + a + ")")

    let joined = if transform.at(0).contains("∧") {
      transform.join("∨")
    } else {
      transform.join("∧")
    }

    let elems2 = ((false, false), (false, true), (true, false), (true, true)).map(a => a.map(repr))

    let elem3 = {
      let o = elems2
      (o.map(a => ("false", ..a)) + o.map(a => ("true", ..a)))
    }

    let zeros = if (base.len() == 2) { elem2 } else if (base.len() == 3) { elem3 } else {}

    for i in range(nbBox) {
      let x = zeros.at(i)
      repr(x)
      /*let repp = _replaces(base, x, joined)
      data.push(eval(repp))*/
      //data.push(false)
    }

    //karnaugh-empty(sc: sc, objInfo, data)
  }*/

  let truth-table(reverse: false, sc: symboles-conv, order: "default", ..inf) = {
    let info = inf.pos()
    let base = _extract(..info)
    let bL = base.len()
    let L = calc.pow(2, bL)
    let iL = info.len()
    let nbBox = (iL + bL) * calc.pow(2, bL)
    let transform = info.map(_strstack)

    if order.contains("alphabetical") {
      base = base.sorted(
        key: a => {
          let val = a.split("_")
          let m = (
            for i in range(val.len()) {
              if i == 0 { (val.at(i).to-unicode() * 1000,) } else { (int(val.at(i)),) }
            }
          )
          m.reduce((a, b) => a + b)
        },
      )
    }
    if order.contains("reverse") {
      base = base.rev()
    }

    table(columns: iL + bL, ..base.map(_mathed), ..info, ..(
        for row in range(L) {
          let list = ()
          let rng = range(1, bL + 1)
          (
            ..for col in rng {
              // The left side
              let raised = calc.pow(2, col - 1)
              let vl = if reverse { (L - 1) - row } else { row }
              let value = not calc.even(calc.floor(vl / raised))
              list.push(value)
              ([#sc(value)],)
            },
          )
          let x = list.map(repr)
          if x != none and x.len() != 0 {
            (
              ..for col in range(iL) {
                // The right side
                let m = _replaces(base, x, transform.at(col))
                // ([#m],) // Debug
                let k = eval(m)
                ([#sc(k)],)
              },
            )
          }
        }
      ))
  }

  let generate-table = truth-table // DEPRECATED
  let generate-empty = truth-table-empty // DEPRECATED

  // For simplified writing
  let NAND = "↑"
  let NOR = "↓"
  let nand = "↑"
  let nor = "↓"

  (
    generate-empty,
    generate-table,
    truth-table,
    truth-table-empty,
    NAND,
    NOR,
    nand,
    nor,
    karnaugh-empty,
    //karnaugh,
  )
}
