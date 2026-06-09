#let _math-to-string(sym_) = {
  let rs = ""
  let fields = sym_.fields()
  // check if the symbol has any of those attributes in order
  for field in ("body", "base", "b", "t") {
      // only do something if it actually has the attribute
      if field in fields {
        if fields.at(field).has("text"){
          // if the attribute is text, we can directly append it
          rs = rs + fields.at(field).text
        } else {
          // if it hasn't, it's another formula and must be processed recursively with this function
          rs += _math-to-string(fields.at(field))
        }
      }
  }
  return rs
}

#let _get-latin-equivalent(entry) = {
  // greek chars are more than one byte (unicode). if we slice the string, we may not respect character boundaries since one greek char can take up two spaces in the string. So we first convert the string into an array of characters using codepoints
  let char-array = entry.codepoints()
  // subtract 848 from the unicode value to map to latin letters
  let equivalent = str.from-unicode(char-array.at(0).to-unicode() - 848)
  // add back the rest of the char-array as a string by joining the slice staring from char at index 1
  equivalent = equivalent + char-array.slice(1).join()
  return equivalent
}

#let _is-greek-symbol(entry) = {
  let num = entry.codepoints().at(0).to-unicode()
  if (913 <= num) and (num <= 913 + 26) {
    return true
  }
  if (945 <= num) and (num <= 945 + 26) {
    return true
  }
  return false
}

#let _symbol-state = state("symbol-state", ())

#let def-symbol(symbol-definition, description, unit: none) = {
  let math_string = _math-to-string(symbol-definition)
  context{
  _symbol-state.update(s => {
    let new_s = s
    new_s.push((math_string, symbol-definition, description, unit))
    return new_s
  })}
}

#let get-latin-symbols() = {
  let latin-symbols = ()
  for (sym_string, sym_math, desc, unit) in _symbol-state.final().sorted(key: item => item.at(0)) {
    if not _is-greek-symbol(sym_string) {
      latin-symbols.push((sym_math, desc, unit))
    }
  }
  return latin-symbols
}

#let get-greek-symbols() = {
  let greek-symbols = ()
  for (sym_string, sym_math, desc, unit) in _symbol-state.final().sorted(key: item => item.at(0)) {
    if _is-greek-symbol(sym_string) {
      greek-symbols.push((sym_math, desc, unit))
    }
  }
  return greek-symbols
}

#let print-symbols(print-units: true, print-header: true, ..table-args) = {
  context{
    let latin-symbols = ()
    let greek-symbols = ()
    for (sym_string, sym_math, desc, unit) in _symbol-state.final() {
      if _is-greek-symbol(sym_string) {
        greek-symbols.push((sym_string, sym_math, desc, unit))
      } else {
        latin-symbols.push((sym_string, sym_math, desc, unit))
      }
    }

    let columns = if print-units { 3 } else { 2 }

    let header-cells = if print-header {
      if print-units { ([Symbol], [Description], [Unit]) }
      else { ([Symbol], [Description]) }
    } else { () }

    let symbol-cells(symbols) = {
      for (sym_string, sym_math, desc, unit) in symbols.sorted(key: item => item.at(0)) {
        if print-units {
          (math.upright(sym_math), desc, if unit != none { math.upright(unit) } else { [] })
        } else {
          (math.upright(sym_math), desc)
        }
      }
    }

    let has-latin = latin-symbols.len() > 0
    let has-greek = greek-symbols.len() > 0

    if has-latin or has-greek {
      let cells = ()

      if has-latin {
        cells.push(table.cell(colspan: columns, inset: (x: 0pt))[
          #heading(outlined: false, level: 2)[Latin symbols]
        ])
        cells += header-cells
        cells += symbol-cells(latin-symbols)
      }

      if has-greek {
        cells.push(table.cell(colspan: columns, inset: (x: 0pt))[
          #heading(outlined: false, level: 2)[Greek symbols]
        ])
        cells += header-cells
        cells += symbol-cells(greek-symbols)
      }

      table(
        inset: (x: 0pt),
        columns: columns,
        column-gutter: 1em,
        stroke: none,
        ..table-args.named(),
        ..cells,
      )
    }
  }
}