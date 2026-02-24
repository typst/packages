// SPDX-License-Identifier: MPL-2.0
// vi: ft=typst et ts=2 sts=2 sw=2 tw=72
//
// Copyright Contributors to the "tbl.typ" project.
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v. 2.0. If a copy of the MPL was
// not distributed with this file, You can obtain one at
// http://mozilla.org/MPL/2.0/.

#let OPTIONS-DEFAULT = (
  // troff tbl
  box: false,
  decimalpoint: ".",
  doublebox: false,
  font: "Times",
  tab: "\t",

  // tbl.typ
  align: left,
  bg: auto,
  breakable: false,
  colors: (),
  fg: auto,
  leading: 0.65em,
  scope: (:),
  mode: "markup",
  pad: (x: 0.75em, y: 3pt),
  size: 1em,

  // tablex
  auto-lines: false,
  header-rows: 1,
  repeat-header: false,

  // #table()
  stroke: 1pt,
)

#let OPTIONS-ALIAS = (
  allbox: "auto-lines",
  center: (align: center),
  centre: (align: center),
  doubleframe: "doublebox",
  frame: "box",
  linesize: "stroke",
  nokeep: "breakable",
)

// "Column descriptors"
#let SPEC-DEFAULT(options) = {(
  class: "L",

  bg: options.bg,
  bold: false,
  colspan: 1,
  fg: options.fg,
  font: options.font,
  halign: left,
  ignore: false,
  italic: false,
  leading: options.leading,
  macro: none,
  min-width: 0pt,
  origin: none,
  pad: options.pad,
  size: options.size,
  stagger: false,
  valign: horizon,
)}

#let SPECIAL-ENTRIES = (
  "_",
  "=",
  "\\_",
  "\\=",
  "\\^",
)

#let UNITS = (
  // Typst units and aliases
  "pt": ("p",),
  "mm": (),
  "cm": ("c",),
  "in": ("i",),
  "em": ("m",),

  // troff-only units
  "en": ("n",),
  "P": (),
  "M": (),
)

#let WIDTH-DEFAULT = (
  min: 0pt,
  max: 0pt,
  num: (left: 0pt, right: 0pt),
  alpha: 0pt,
)

// Raise an assertion including the current row & column number
// (1-indexed) if available
#let assert-ctx(cond, message, row: none, col: none) = {
  assert(
    cond,
    message: {
      let ctx = ""
      if row != none {
        ctx += "R" + str(row + 1)
      }
      if col != none {
        ctx += "C" + str(col + 1)
      }
      if ctx != "" {
        ctx = "[tbl " + ctx + "] "
      } else {
        ctx = "[tbl] "
      }

      ctx + message
    },
  )
}

#let sub-width-at(sub-widths, key, spec, insert: false) = {
  let key = str(key)
  if spec != none and spec.colspan > 1 {
    key += "," + str(spec.colspan)
  }
  let widths = sub-widths.at(key, default: WIDTH-DEFAULT)
  if insert {
    (key, widths)
  } else {
    widths
  }
}

// Convert length measurement stored as a string (including troff-only
// variants) to a Typst length value
#let coerce-unit(len, default, relative: none) = {
  let given-unit = none

  if relative != none {
    if not (len.starts-with("+") or len.starts-with("-")) {
      relative = none
    }
  }

  for (primary-unit, aliases) in UNITS.pairs() {
    for unit in (primary-unit, ..aliases) {
      if len.ends-with(unit) {
        given-unit = primary-unit
        len = len.trim(unit, at: end, repeat: false)
        break
      }
    }
    if given-unit != none {
      break
    }
  }
  if given-unit == none {
    given-unit = default
  }
  len = float(eval(len))

  if given-unit == "en" {
    given-unit = "em"
    len /= 2
  } else if given-unit == "P" {
    given-unit = "in"
    len /= 6
  } else if given-unit == "M" {
    given-unit = "em"
    len /= 100
  }
  given-unit = eval("1" + given-unit)

  if relative != none {
    relative + len * given-unit
  } else {
    len * given-unit
  }
}

// Usage: regex-raw(`pattern`)
#let regex-raw(..patterns) = {
  regex({for pattern in patterns.pos() {
      pattern.text
  }})
}

// Set a default rowspan for later use
#let tbl-cell(body, ..options) = {
  let options = options.named()
  options.rowspan = options.remove("rowspan", default: 1)
  (body: body, ..options)
}

// Evaluate cell contents within given specification
#let tbl-cell-ctx(spec, it) = {
  set text(
    baseline:
      if spec.stagger { -1em }
      else { 0em },
    font: spec.font,
    size: spec.size,
    number-width:
      if spec.class == "N" { "tabular" }
      else { auto },
  )
  set par(leading: spec.leading)

  let it = it()
  if spec.macro != none {
    it = (spec.macro)(it)
  }
  if spec.bold {
    it = strong(it)
  }
  if spec.italic {
    it = emph(it)
  }
  if spec.fg != auto {
    it = text(fill: spec.fg, it)
  }
  it
}

// Construct a numerically-aligned cell.
// The width is initially unconstrained while parsing the table,
// but will be added later once the width of the entire column can be
// measured.
#let tbl-cell-numeric(options, spec, txt-left, sep, txt-right, width: none) = {
  let cell-left = tbl-cell-ctx(spec, () => eval(
    txt-left.trim(at: start) + "#box[]",
    mode: options.mode,
    scope: options.scope,
  ))
  let cell-right = tbl-cell-ctx(spec, () => eval(
    "#box[]" + txt-right.trim(at: end),
    mode: options.mode,
    scope: options.scope,
  ))

  let sep = tbl-cell-ctx(spec, () => sep)
  if txt-right.trim() == "" {
    sep = tbl-cell-ctx(spec, () => hide(options.decimalpoint))
  }

  if width != none {
    stack(
      dir: ltr,
      box(width: width.left, align(right, cell-left)),
      sep,
      box(width: width.right, align(left, cell-right)),
    )
  } else {
    stack(dir: ltr, cell-left, sep, cell-right)
  }
}

// Temporarily hold vline information. Needed when considering subtables
// (.T&) because the number of rows won't be known ahead of time.
#let tbl-vline(..options) = options.named()

#let tbl-color(scope, colors, it) = {
  if it.match(regex-raw(`^[0-9]+$`)) != none {
    colors.at(int(it))
  } else {
    eval(it, scope: scope)
  }
}

// Parse format specifications.
#let tbl-spec(txt-specs, col-widths, options) = {
  let col-widths = col-widths
  let realize = []
  let specs = ()
  let vlines = ()

  ////////////////// TABLE FORMAT / LAYOUT PARSING //////////////////
  // Strip out any column modifier arguments first, since they may
  // contain spaces, tabs, commas, or any of the classifier
  // characters.
  let args = (:)
  let arg = txt-specs.match(regex-raw(`(?s)[ \t]*\((.*?)\)`))
  while arg != none {
    let modifier = lower(txt-specs.slice(arg.start - 1, count: 1))
    if modifier not in args {
      args.insert(modifier, ())
    }
    let txt-arg = arg.captures.first()

    let num-open-parens = txt-arg.matches("(").len()
    let close-parens = txt-specs.slice(arg.end).matches(")")
    assert-ctx(
      num-open-parens <= close-parens.len(),
      "Expected ')' for column modifier argument",
    )
    if num-open-parens > 0 {
      let old-end = arg.end
      arg.end += close-parens.at(num-open-parens - 1).end
      txt-arg += txt-specs.slice(old-end, arg.end)
    }

    args.at(modifier).push(txt-arg)
    txt-specs = txt-specs.slice(0, arg.start) + txt-specs.slice(arg.end)
    arg = txt-specs.match(regex-raw(`(?s)[ \t]*\((.*?)\)`))
  }

  // Remove whitespace.
  txt-specs = txt-specs.replace(regex-raw(`[ \t]`), "")

  // Strip out column separations next.
  let col-seps = ()
  let sep = txt-specs.match(regex-raw(`([0-9]+)`))
  while sep != none {
    col-seps.push(sep.captures.first())
    // Leave a single space as a placeholder for parsing below.
    txt-specs = txt-specs.slice(0, sep.start) + " " + txt-specs.slice(sep.end)
    sep = txt-specs.match(regex-raw(`([0-9]+)`))
  }

  // "Newlines and commas are special; they apply the descriptors
  // following them to a subsequent row of the table."
  txt-specs = txt-specs.split(regex-raw(`[,\n]+`)).enumerate()
  for (row, txt-row) in txt-specs {
    let vline-end = if row == txt-specs.len() - 1 {
      none
    } else {
      row + 1
    }

    // Column descriptors are optionally separated by spaces or tabs.
    // Commas and newlines start a new "row definition" of column
    // descriptors (see outer loop).
    txt-row = txt-row.matches(regex-raw(
      `(?i)`,
      `([ACLNRS=^_-]|[|]+)`,
      `([^ACLNRS=|^_-]+)?`,
    ))
    let new-vlines = ()
    let new-rowdef = ()

    let column-sep-given = none
    for (col, txt-col) in txt-row.enumerate() {
      let (class, txt-mods) = txt-col.captures

      let spec = SPEC-DEFAULT(options)
      spec.class = upper(class)
      if txt-mods == none { txt-mods = "" }
      txt-mods = lower(txt-mods)

      col -= new-vlines.len()
      let col-line = if col == 0 { 0 } else { col - 1 }
      if spec.class == "S" {
        spec.origin = col - 1
        while new-rowdef.at(spec.origin, default: (class: none)).class == "S" {
          spec.origin -= 1
        }
        new-rowdef.at(spec.origin).colspan += 1
      } else if spec.class == "|" {
        assert-ctx(
          txt-mods == "",
          "Column modifiers should precede vertical lines",
          row: row,
          col: col-line,
        )
        new-vlines.push(tbl-vline(
          start: row,
          end: vline-end,
          x: col,
          stroke: options.stroke,
        ))
        continue
      } else if spec.class == "||" {
        assert-ctx(
          false,
          "Double vertical lines are not supported",
          row: row,
          col: col-line,
        )
      } else if spec.class.starts-with("|") {
        assert-ctx(
          false,
          "Invalid column class: '" + spec.class + "'",
          row: row,
          col: col-line,
        )
      }

      if col >= col-widths.len() {
        col-widths.push(auto)
      }

      if column-sep-given != none {
        spec.pad.left = column-sep-given
        column-sep-given = none
      }

      spec.halign = {
        if spec.class in ("C", "N", "A") {
          center
        } else if spec.class == "R" {
          right
        } else {
          left
        }
      }

      for mod in txt-mods.clusters() {
        assert-ctx(
          mod in " bdefikmoptuvwxz".clusters(),
          "Column modifier '" + mod + "' is not supported",
          row: row,
          col: col,
        )

        if mod in "fkmopvw".clusters() {
          assert-ctx(
            mod in args,
            "Missing argument for column modifier '" + mod + "'",
            row: row,
            col: col,
          )
        }

        if mod == " " {
          // Not a real modifier, but rather a placeholder for where a
          // column separation was given.

          // The following assertion should never fire, unless there
          // is a bug.
          assert(col-seps.len() > 0)

          spec.pad.right = coerce-unit(col-seps.remove(0), "en") / 2
          column-sep-given = spec.pad.right
        }

        else if mod == "b" {
          spec.bold = true

        } else if mod == "d" {
          spec.valign = bottom

        } else if mod == "e" {
          col-widths.at(col) = "equalize"

        } else if mod == "f" {
          arg = args.f.remove(0)
          if arg == "B" {
            spec.bold = true
          } else if arg == "I" {
            spec.italic = true
          } else if arg == "BI" {
            spec.bold = true
            spec.italic = true
          } else {
            spec.font = arg
          }

        } else if mod == "i" {
          spec.italic = true

        } else if mod == "k" {
          spec.bg = tbl-color(
            options.scope,
            options.colors,
            args.k.remove(0),
          )

        } else if mod == "m" {
          arg = args.m.remove(0)
          assert-ctx(
            arg in options.scope,
            "Macro '" + arg + "' not in scope region option",
            row: row,
            col: col,
          )
          spec.macro = options.scope.at(arg)

        } else if mod == "o" {
          spec.fg = tbl-color(
            options.scope,
            options.colors,
            args.o.remove(0),
          )

        } else if mod == "p" {
          spec.size = coerce-unit(
            args.p.remove(0),
            "pt",
            relative: spec.size,
          )

        } else if mod == "t" {
          spec.valign = top

        } else if mod == "u" {
          spec.stagger = true

        } else if mod == "v" {
          spec.leading = coerce-unit(
            args.v.remove(0),
            "pt",
            relative: spec.leading,
          )

        } else if mod == "w" {
          spec.min-width = coerce-unit(args.w.remove(0), "en")

        } else if mod == "x" {
          col-widths.at(col) = 1fr

        } else if mod == "z" {
          spec.ignore = true

        }
      }

      new-rowdef.push(spec)
    }

    vlines += new-vlines
    specs.push(new-rowdef)
  }

  return (col-widths, realize, specs, vlines)
}

#let tbl-options(..options) = {
  ////////////////////// TABLE OPTION PARSING //////////////////////
  let options = options.named()
  for (name, value) in OPTIONS-DEFAULT.pairs() {
    if name not in options {
      options.insert(name, value)
    }
  }
  for (name, value) in options.pairs() {
    if name in OPTIONS-ALIAS {
      let mapping = OPTIONS-ALIAS.at(name)
      if type(mapping) == dictionary {
        options += mapping
        let _ = options.remove(name)
      } else if type(mapping) == str {
        options.insert(mapping, value)
        let _ = options.remove(name)
      } else {
        panic("Invalid OPTIONS-ALIAS type", type(mapping))
      }
    } else if name == "pad" {
      let rest = value.at("rest", default: none)
      for (axis, dirs) in (x: ("left", "right"), y: ("top", "bottom")) {
        let given-axis = value.at(axis, default: none)
        for dir in dirs {
          if dir not in value {
            value.insert(
              dir,
              if given-axis != none { given-axis }
              else if rest != none { rest }
              else { OPTIONS-DEFAULT.pad.at(axis) },
            )
          }
        }
      }
      options.insert("pad", value)
    } else if name not in OPTIONS-DEFAULT {
      panic("Unknown region option '" + name + "'")
    }
  }
  if options.doublebox { options.box = true }
  options
}

#let tbl(txt, ..options) = layout(size => {
  let txt = txt.replace("\r", "")

  // Region options
  let options = tbl-options(..options)

  // Array of dictionaries representing each row ("column class" and
  // "column modifiers")
  let specs = ()

  // Array of rows, each consisting of an array of content cells
  let rows = ()

  // The same cells as in the rows variable above, but organized by
  // column.
  let cols = ()

  // Named parameter "columns:" for #table(). Mostly used to track how
  // many columns are in the table, and which have modifier "e"
  // ("equalize") or "x" (1fr). The rest are auto, but will be
  // replaced by real lengths before #table() is called.
  let col-widths = ()

  // Manually specified vertical and horizontal lines. These are arrays
  // of tbl-vline and table.hline. The latter also helps keeps track of
  // how many lines of input in the txt-data have been ignored so that
  // we can still properly map each table row into the correct entry in
  // "specs" above. tbl-vline will be realized into table.vline right
  // before the table is laid out.
  let vlines = ()
  let hlines = ()

  // Maximum possible width of the current table, based on the
  // container we're in - or the width of the page minus the margins
  // if there is no container.
  let tbl-max-width = size.width

  // Parse format specifications
  let found-spec = txt.match(regex-raw(`(?ms)(?:\A|^\.T&\n)(.*?)\.[ \t]*\n`))
  while found-spec != none {
    let ret = tbl-spec(
      found-spec.captures.at(0), // consumed
      col-widths,                // in-out
      options,                   // not modified
    )
    col-widths = ret.at(0)
    ret.at(1) // realize invisible content for state updates etc.
    specs.push(ret.at(2))
    vlines.push(ret.at(3))

    // #tbl.next is a sentinel used to replace .T& in the input for
    // later consumption by the row parser. It doesn't correspond to an
    // actual object.
    txt = txt.slice(0, found-spec.start) + "#tbl.next\n" + txt.slice(found-spec.end)
    found-spec = txt.match(regex-raw(`(?ms)^\.T&\n(.*?)\.[ \t]*\n`))
  }
  let txt-data = txt

  // Add missing specifications based on maximum number of columns
  // encountered
  specs = specs.map(subtable => subtable.map(
    rowdef => {
      let missing = col-widths.len() - rowdef.len()
      if missing > 0 {
        rowdef += (SPEC-DEFAULT(options),) * missing
      }
      rowdef
    })
  )

  /////////////////////// TABLE DATA PARSING ///////////////////////

  // Strip out text blocks first.
  let txt-blocks = ()
  let txt-block = txt-data.match(regex-raw(`(?s)T\{\n(.*?)\nT\}`))
  // Like #tbl.next, #tbl.txt-block is a sentinel used to replace
  // T{...T} in the input. The contents of the text block are stored in
  // the txt-blocks array for later retrieval when the #tbl.txt-block
  // sentinel is encountered by the row parser.
  while txt-block != none {
    txt-blocks.push(txt-block.captures.first())
    txt-data = (
      txt-data.slice(0, txt-block.start)
      + "#tbl.txt-block"
      + txt-data.slice(txt-block.end)
    )
    txt-block = txt-data.match(regex-raw(`(?s)T\{\n(.*?)\nT\}`))
  }

  // Replace line continuations.
  txt-data = txt-data.replace("\\\n", "")

  let subtable = -1
  let subtable-offset = 0
  let other-offset = 0
  for (row, txt-row) in txt-data.split("\n").enumerate() {
    row -= hlines.len() + other-offset

    // Skippable data entries:
    if txt-row == "_" {
      // Horizontal rule
      hlines.push(table.hline(
        y: row,
        stroke: options.stroke,
      ))
      continue

    } else if txt-row == "=" {
      // Double horizontal rule
      panic("Double horizontal lines are not supported")

    } else if txt-row == ".TH" {
      // End-of-header
      options.repeat-header = true
      options.header-rows = row
      other-offset += 1
      continue

    } else if txt-row == "#tbl.next" {
      // .T& (new "subtable" / format specifications)
      vlines.at(subtable) = vlines.at(subtable).map(vline => {
        if vline.end == none and subtable > -1 { vline.end = row }
        vline
      })
      subtable += 1
      subtable-offset = row
      vlines.at(subtable) = vlines.at(subtable).map(vline => {
        vline.start += subtable-offset
        if vline.end != none { vline.end += subtable-offset }
        vline
      })
      other-offset += 1
      continue

    } else if txt-row.starts-with(".\\\"") {
      // Comment
      other-offset += 1
      continue
    } else if txt-row.starts-with(".") {
      panic("Unsupported command: `" + txt-row + "'")
    }

    let rowdef = specs.at(subtable)
    rowdef = rowdef.at(calc.min(row - subtable-offset, specs.at(subtable).len() - 1))
    txt-row = txt-row.split(options.tab)

    assert-ctx(
      rowdef.len() - txt-row.len() >= 0,
      "Too many columns",
      row: row,
    )

    // This will hold each parsed cell
    let new-row = ()
    let col = 0
    let col-offset = 0

    while col < rowdef.len() {
      let cell = txt-row.at(col - col-offset, default: "")
      let txt-block = false
      // Reinsert text blocks that were previously removed
      if cell.trim() == "#tbl.txt-block" {
        txt-block = true
        cell = txt-blocks.remove(0).split("\n").filter(it => {
          if it.starts-with(".\\\"") {
            false
          } else if it.starts-with(".") {
            assert-ctx(
              false,
              "Unsupported command: `" + it + "'",
              row: row,
              col: col,
            )
          } else {
            true
          }
        }).join("\n")
      } else if cell.trim().starts-with("#tbl.txt-block") {
        assert-ctx(
          false,
          "Nothing should follow text block close `T}` in same cell",
          row: row,
          col: col,
        )
      }

      cell = cell.trim()
      let txt-cell = cell
      if txt-cell in SPECIAL-ENTRIES { cell = "" }
      let empty = cell == ""
      cell = cell.replace("\\&", "")

      // \Rx character repetition cell fill
      let rep = cell.match(regex-raw(`^\\R(.)$`))
      if rep != none {
        rep = rep.captures.first()
        cell = "#box(width: 100%, repeat("
        cell += repr(rep)
        cell += "))"
      }

      let spec = rowdef.at(col)

      let align-pos = none
      let sep = []
      let sep-len = 0

      // Find alignment point for numerically-aligned cells
      if (spec.class == "N"
          and cell != "" // Do nothing if special entry
          and not txt-block
      ) {
        // one position AFTER \&
        align-pos = txt-cell.position("\\&")
        sep-len = "\\&".len()

        if align-pos == none {
          // OR rightmost decimalpoint "ADJACENT TO DIGIT"
          //    (so "26.4. 12" aligns on "26.4", but
          //     "26.4 .12" aligns on ".12")
          let all-pos = txt-cell.matches(options.decimalpoint)

          if all-pos != () {
            sep = options.decimalpoint
            sep-len = sep.len()

            for prev-pos in all-pos.rev() {
              if prev-pos.start + sep-len >= txt-cell.len() {
                continue
              }
              let next-char = txt-cell.slice(prev-pos.start + sep-len, count: 1)
              if next-char.match(regex-raw(`[0-9]`)) != none {
                align-pos = prev-pos.start
                break
              }
            }
          }

          if align-pos == none {
            align-pos = txt-cell.matches(regex-raw(`[0-9]`))
            if align-pos != () {
              // OR rightmost digit
              align-pos = align-pos.last().end
              sep = []
              sep-len = 0
            } else {
              // OR centered (no digits)
              align-pos = none
              sep = []
              sep-len = 0
            }
          }
        }
      }
      // Hold markup of left/right halves of numerically-aligned cell to
      // later re-evaluate when the necessary widths are known
      let tbl-n = none
      if align-pos != none {
        let txt-left = txt-cell.slice(0, align-pos)
        let txt-right = txt-cell.slice(align-pos + sep-len)
        tbl-n = (txt-left, sep, txt-right)
        cell = tbl-cell-numeric(options, spec, txt-left, sep, txt-right)
      } else {
        cell = tbl-cell-ctx(spec, () => {
          eval(
            cell,
            mode: options.mode,
            scope: options.scope,
          )
        })
      }

      if spec.class == "S" {
        // Horizontal span
        if not empty {
          col-offset += 1
        }
        cell = ()

      } else if spec.class == "^" or txt-cell == "\\^" {
        // Vertical span
        if not empty {
          col-offset += 1
        }

        // Find origin cell for this spanned one in current column
        let prev-row = -1
        while rows.at(prev-row).at(col) == () {
          prev-row -= 1
        }
        rows.at(prev-row).at(col).rowspan += 1
        cell = ()

      } else if (spec.class in ("_", "-", "=")
            or txt-cell in ("_", "=", "\\_", "\\=")
      ) {
        // Line
        if not empty {
          col-offset += 1
        }

        let line-start-x = 0%
        let line-length = 100%
        if txt-cell in ("\\_", "\\=") {
          line-start-x += spec.pad.left
          line-length -= spec.pad.left + spec.pad.right
        }

        cell = tbl-cell(
          align: left + horizon,
          fill: spec.bg,
          colspan: spec.colspan,

          tbl-spec: spec,
          tbl-n: none,
          tbl-pad: false,
          tbl-txt-block: false,

          {
            if spec.class in ("_", "-") or txt-cell in ("_", "\\_") {
              // Horizontal rule
              line(
                start: (line-start-x, 0%),
                length: line-length,
                stroke: options.stroke,
              )
            } else {
              // Double horizontal rule
              stack(
                dir: ttb,
                line(
                  start: (line-start-x, 0%),
                  length: line-length,
                  stroke: options.stroke,
                ),
                2pt,
                line(
                  start: (line-start-x, 0%),
                  length: line-length,
                  stroke: options.stroke,
                ),
              )
            }
          }
        )

      } else if spec.class in ("L", "C", "R", "N", "A") {
        // Normal cell
        if spec.ignore {
          // Preserve height, but ignore width.
          cell = tbl-cell-ctx(spec, () => {
            box(
              width: 0pt,
              height: measure(cell).height,
              place(spec.halign + spec.valign, cell)
            )
          })
        }

        cell = tbl-cell(
          align: spec.halign + spec.valign,
          fill: spec.bg,
          colspan: spec.colspan,
          x: col,
          y: row,

          tbl-spec: spec,
          tbl-n: tbl-n,
          tbl-pad: true,
          tbl-txt-block: txt-block,

          cell,
        )
      }

      if cols.len() <= col {
        cols.push(())
      }
      cols.at(col).push(cell)
      new-row.push(cell)
      col += 1
    }
    rows.push(new-row)
  }

  ///////////////////////// LINE REALIZATION /////////////////////////

  vlines = vlines.flatten()

  if options.box and not options.auto-lines {
    hlines += (
      table.hline(y: 0),
      table.hline(y: rows.len()),
    )

    vlines += (
      tbl-vline(x: 0),
      tbl-vline(x: col-widths.len()),
    )
  }

  //////////////////////// TABLE REALIZATION ////////////////////////
  align(
    options.align,

    block(
      breakable: options.breakable,
      inset:
        if options.doublebox { 2pt }
        else { 0pt },
      stroke:
        if options.doublebox { options.stroke }
        else { none },

      /********************* WIDTH REALIZATION *********************/
      context {
        // Dictionary of column # -> dictionary:
        //   min:       as specified by modifier "w", EXCLUDING padding
        //   max:       maximum from all cells in this column, INCLUDING
        //              padding
        //   num.left:  maximum from all left halves of class "N" cells
        //              in this column, EXCLUDING padding
        //   num.right: same as above, but right halves
        //
        //   column # may be "j,n" in which case it applies to column j
        //   iff colspan == n
        let sub-widths = (:)
        // Column modifier "e"(qualize) width
        let equalize-width = 0pt

        for (col, cells) in cols.enumerate() {
          for cell in cells {
            if cell == () or cell.tbl-spec.ignore {
              continue
            }
            let (wcol, widths) = sub-width-at(sub-widths, col, cell.tbl-spec, insert: true)
            let padding-cell = if cell.tbl-pad {
                (cell.tbl-spec.pad.left + cell.tbl-spec.pad.right).to-absolute()
              } else {
                0pt
              }

            // Minimum width for each column
            widths.min = calc.max(widths.min, cell.tbl-spec.min-width.to-absolute())

            let width-cell = measure(cell.body).width + padding-cell

            // Maximum width for each column
            let width-max = 0pt
            if cell.tbl-txt-block and col-widths.at(col) != 1fr {
              width-max = widths.min
              if width-max == 0pt {
                width-max = tbl-max-width
                width-max *= cell.tbl-spec.colspan
                width-max /= col-widths.len() + 1
              }
              width-max += padding-cell
            } else if not cell.tbl-txt-block {
              width-max = width-cell
            }
            widths.max = calc.max(widths.min + padding-cell, widths.max, width-max)

            // Maximum numeric left/right width for each column
            if cell.at("tbl-n", default: none) != none {
              let child = cell.at("body", default: none)
              while child != none and child.func() != stack {
                child = child.at("body", default: child.at("child", default: none))
              }
              if child.func() == stack {
                let (c-left, _, c-right) = child.children

                widths.num.left = calc.max(widths.num.left, measure(c-left).width)
                widths.num.right = calc.max(widths.num.right, measure(c-right).width)
              }
            }

            // Maximum alphabetic width for each column
            if cell.tbl-spec.class == "A" {
              widths.alpha = calc.max(widths.alpha, measure(cell.body).width)
            }

            // Column modifier "e"(qualize)
            if cell.colspan == 1 and col-widths.at(col) == "equalize" {
              equalize-width = calc.max(equalize-width, widths.max)
            }

            sub-widths.insert(wcol, widths)
          }
        }

        // Now that all widths are known, apply them to each cell as
        // necessary
        let rows = rows.enumerate().map(((row, cells)) => {
          cells.filter(cell => cell != ()).enumerate().map(cell => {
            let (col, cell) = cell

            let body = cell.remove("body")
            let spec = cell.remove("tbl-spec")
            let tbl-n = cell.remove("tbl-n")
            let tbl-pad = cell.remove("tbl-pad")
            let tbl-txt-block = cell.remove("tbl-txt-block")

            // Text block width
            if tbl-txt-block and col-widths.at(col) != 1fr {
              body = {
                let width = sub-width-at(sub-widths, col, spec).min
                if width == 0pt {
                  width = tbl-max-width
                  width *= spec.colspan
                  width /= col-widths.len() + 1
                }

                box(width: width, body)
              }
            }

            if spec.class == "N" and tbl-n != none {
              // Numeric column width alignment
              let width = sub-width-at(sub-widths, col, spec).num
              body = tbl-cell-numeric(options, spec, ..tbl-n, width: width)
            } else if spec.class == "A" {
              // Alphabetic column width alignment
              let width = sub-width-at(sub-widths, col, spec).alpha
              body = tbl-cell-ctx(spec, () => {
                box(width: width, align(left, body))
              })
            }

            // Column separation
            if spec.class in ("L", "C", "R", "N", "A") and tbl-pad {
              body = pad(..spec.pad, body)
            }

            table.cell(body, ..cell)
          })
        })

        // Freeze all "auto" widths into real lengths
        let col-widths = col-widths.enumerate().map(((col, width)) => {
          if width == auto {
            sub-width-at(sub-widths, col, none).max
          } else {
            width
          }
        })

        // Distribute excess width from colspanned cells
        for (col, cell) in sub-widths {
          if "," not in col {
            continue
          }
          let (begin, end) = col.split(",")
          begin = int(begin)
          end = int(end)
          let curr-widths = col-widths.slice(begin, end)
          if curr-widths.any(w => w == 1fr) {
            continue
          }
          let curr-width = 0pt
          let eq = 0
          for width in curr-widths {
            if width == "equalize" {
              eq += 1
              curr-width += equalize-width
            } else {
              curr-width += width
            }
          }
          let diff = (cell.max - curr-width) / 1pt
          if diff <= 0 or curr-width == 0pt {
            continue
          }
          for (col, width) in curr-widths.enumerate() {
            if width == "equalize" {
              continue
            }
            col += begin
            width += diff * width / (curr-width) * 1pt
            col-widths.at(col) = width
          }
          equalize-width += eq * diff * equalize-width / (curr-width) * 1pt
        }

        // Freeze "equalize" widths into real lengths
        col-widths = col-widths.map(width => {
          if width == "equalize" {
            equalize-width
          } else {
            width
          }
        })

        let vlines = vlines.map(vline => table.vline(..vline))
        let header = rows.slice(0, count: options.header-rows)
        rows = rows.slice(options.header-rows)

        table(
          columns: col-widths,
          inset: 0pt,
          stroke: if options.auto-lines { options.stroke } else { none },

          ..vlines,
          ..hlines,
          table.header(..header.flatten(), repeat: options.repeat-header),
          ..rows.flatten(),
        )
      }
    )
  )
})

#let template(body, ..options) = {
  show raw.where(lang: "tbl"): it => tbl(it.text, ..options)

  body
}
