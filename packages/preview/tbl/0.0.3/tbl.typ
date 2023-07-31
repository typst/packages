// SPDX-License-Identifier: MPL-2.0
// vi: ft=typst et ts=2 sts=2 sw=2 tw=72
//
// Copyright Contributors to the "tbl.typ" project.
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v. 2.0. If a copy of the MPL was
// not distributed with this file, You can obtain one at
// http://mozilla.org/MPL/2.0/.
#import "@preview/tablex:0.0.4"

#let CELL-MODES = (
  content: ("[", "]"),
  math: ("$", "$"),
)

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
  macros: (:),
  mode: "content",
  pad: (x: 0.75em, y: 3pt),
  size: 1em,

  // tablex.typ
  auto-lines: false,
  header-rows: 1,
  repeat-header: false,
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
  num-l: 0pt,
  num-r: 0pt,
  alpha: 0pt,
)

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

#let cell-width-at(cell-widths, key, loc: none, spec: none) = {
  let cell-widths = cell-widths
  let key = str(key)
  if spec != none and spec.colspan > 1{
    key += "," + str(spec.colspan)
  }
  if loc != none {
    cell-widths = cell-widths.at(loc)
  }
  (key, cell-widths.at(key, default: WIDTH-DEFAULT))
}

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

// Convert any mix of em / other (absolute) lengths to pt.
// https://github.com/typst/typst/issues/1231
#let pt-length(len, styles) = {
  measure(line(length: len), styles).width
}

#let regex-raw(..patterns) = {
  regex({for pattern in patterns.pos() {
      pattern.text
  }})
}

#let tbl-cell(spec, it) = {
  if type(it) == "function" {
    tbl-cell(spec, style(styles => it(styles)))

  } else {
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
}

#let tbl-color(colors, it) = {
  if it.match(regex-raw(`^[0-9]+$`)) != none {
    colors.at(int(it))
  } else {
    eval(it)
  }
}

#let tbl-spec(txt-specs, cols, cell-widths, options) = {
  let cols = cols
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
      auto
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
        new-vlines.push(tablex.vlinex(
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

      if col >= cols.len() {
        cols.push(auto)
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

      let min-width-given = none

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
          cols.at(col) = "equalize"

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
            options.colors,
            args.k.remove(0),
          )

        } else if mod == "m" {
          arg = args.m.remove(0)
          assert-ctx(
            arg in options.macros,
            "Macro '" + arg + "' not given in region options",
            row: row,
            col: col,
          )
          spec.macro = options.macros.at(arg)

        } else if mod == "o" {
          spec.fg = tbl-color(
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
          min-width-given = coerce-unit(args.w.remove(0), "en")

        } else if mod == "x" {
          cols.at(col) = 1fr

        } else if mod == "z" {
          spec.ignore = true

        }
      }

      if min-width-given != none {
        realize += tbl-cell(spec, styles => {
          cell-widths.update(d => {
            // w(...) does not care about spans
            let (wcol, curr) = cell-width-at(d, col)
            let width = pt-length(min-width-given, styles)
            let width-p = width + pt-length(spec.pad.left + spec.pad.right, styles)
            curr.min = calc.max(curr.min, width)
            curr.max = calc.max(curr.max, width-p)
            d.insert(wcol, curr)
            d
          })
        })
      }

      new-rowdef.push(spec)
    }

    vlines += new-vlines
    specs.push(new-rowdef)
  }

  return (cols, realize, specs, vlines)
}

#let tbl(txt, ..options) = layout(size => {
  let txt = txt.replace("\r", "")

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
      if type(mapping) == "dictionary" {
        options += mapping
        let _ = options.remove(name)
      } else if type(mapping) == "string" {
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

  // Array of rows, each containing dictionaries ("column class" and
  // "column modifiers")
  let specs = ()

  // Array of rows, each containing an entry from `specs` and an array
  // of content cells
  let rows = ()

  // Named parameter "columns:" for tablex. Mostly used to track how
  // many columns are in the table, and which have modifier "e"
  // ("equalize") or "x" (1fr). The rest are auto, but will be
  // replaced by real lengths before tablex is called; see
  // "cell-widths" below.
  let cols = ()

  // Manually specified vertical and horizontal lines. These are
  // arrays of tablex.vlinex and tablex.hlinex. The latter also keeps
  // track of how many lines of input in the txt-data have been
  // ignored so that we can still properly map each table row into the
  // correct entry in "specs" above.
  let vlines = ()
  let hlines = ()

  // Largest width of any cell in any column that has been modified "e".
  let equalize-width = state("tbl-equalize-width")
  equalize-width.update(0pt)
  // Dictionary of column # -> dictionary:
  //   min:   as specified by modifier "w", EXCLUDING padding
  //   max:   maximum from all cells in this column, INCLUDING padding
  //   num-l: maximum from all left halves of class "N" cells in this
  //          column, EXCLUDING padding
  //   num-r: same as above, but right halves
  //
  //   column # may be "j,n" in which case it applies to column j iff
  //   colspan == n
  let cell-widths = state("tbl-cell-widths")
  cell-widths.update((:))
  // Maximum possible width of the current table, based on the
  // container we're in - or the width of the page minus the margins
  // if there is no container.
  let tbl-max-width = size.width

  let found-spec = txt.match(regex-raw(`(?ms)(?:\A|^\.T&\n)(.*?)\.[ \t]*\n`))
  while found-spec != none {
    let ret = tbl-spec(
      found-spec.captures.at(0), // consumed
      cols,                      // in-out
      cell-widths,               // modified (state)
      options,                   // not modified
    )
    cols = ret.at(0)
    ret.at(1) // realize invisible content for state updates etc.
    specs.push(ret.at(2))
    vlines.push(ret.at(3))

    txt = txt.slice(0, found-spec.start) + "#tbl.next\n" + txt.slice(found-spec.end)
    found-spec = txt.match(regex-raw(`(?ms)^\.T&\n(.*?)\.[ \t]*\n`))
  }
  let txt-data = txt

  specs = specs.map(subtable => subtable.map(
    rowdef => {
      let missing = cols.len() - rowdef.len()
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
  for (row, txt-row) in txt-data.split("\n").enumerate() {
    row -= hlines.len()

    // Skippable data entries:
    if txt-row == "_" {
      // Horizontal rule
      hlines.push(tablex.hlinex(
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
      hlines.push(()) // A bit of a hack, but this keeps row numbering
                      // correct later.
      continue

    } else if txt-row == "#tbl.next" {
      vlines.at(subtable) = vlines.at(subtable).map(vline => {
        if vline.end == auto and subtable > -1 { vline.end = row }
        vline
      })
      subtable += 1
      subtable-offset = row
      vlines.at(subtable) = vlines.at(subtable).map(vline => {
        vline.start += subtable-offset
        if vline.end != auto { vline.end += subtable-offset }
        vline
      })
      hlines.push(())
      continue

    } else if txt-row.starts-with(".\\\"") {
      // Comment
      hlines.push(())
      continue
    } else if txt-row.starts-with(".") {
      panic("Unsupported command: `" + txt-row + "'")
    }

    let rowdef = specs.at(subtable)
    rowdef = rowdef.at(calc.min(row - subtable-offset, specs.at(subtable).len() - 1))
    txt-row = txt-row.split(options.tab)

    let missing = rowdef.len() - txt-row.len()
    if missing > 0 {
      // Add empty columns if fewer than expected are provided
      txt-row += ("",) * missing
    } else if missing < 0 {
      panic("Too many columns")
    }

    // This will hold each parsed cell
    let new-row = ()

    for (col, cell) in txt-row.enumerate() {
      let txt-block = false
      if cell.trim() == "#tbl.txt-block" {
        txt-block = true
        cell = txt-blocks.remove(0)
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

      let rep = cell.match(regex-raw(`^\\R(.)$`))
      if rep != none {
        rep = rep.captures.first()
        cell = "#box(width: 100%, repeat("
        cell += repr(rep)
        cell += "))"
      }

      let spec = rowdef.at(col)
      let tbl-numeric = none

      cell = tbl-cell(spec, {
        let (cell-open, cell-close) = CELL-MODES.at(options.mode)
        let align-pos = none
        let sep = []
        let sep-len = 0

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

        if align-pos != none {
          let txt-left = txt-cell.slice(0, align-pos)
          let txt-right = txt-cell.slice(align-pos + sep-len)

          // Hacky as it gets... but necessary to preserve some
          // spacing across the decimalpoint.
          let sp = style(styles => {
            let w = measure("x  .", styles).width
            w -= measure("x.", styles).width
            h(w)
          })

          let cell-left = eval(cell-open + txt-left.trim() + cell-close)
          let cell-right = eval(cell-open + txt-right.trim() + cell-close)

          // Spacing adjustments
          if txt-left.ends-with(regex-raw(`[^ \t][ \t]`)) {
            cell-left = cell-left + sp
          }
          if txt-right.trim() == "" {
            sep = hide(options.decimalpoint)
          } else if txt-right.starts-with(regex-raw(`[ \t][^ \t]`)) {
            cell-right = sp + cell-right
          }

          tbl-numeric = (cell-left, sep, cell-right)
          stack(dir: ltr, ..tbl-numeric)

        } else {
          eval(cell-open + cell + cell-close)
        }
      })

      if txt-block {
        cell = locate(loc => {
          let (_, curr) = cell-width-at(cell-widths, col, loc: loc)
          if curr.min != 0pt {
            box(width: curr.min, cell)
          } else {
            let width = tbl-max-width
            width *= spec.colspan
            width /= cols.len() + 1

            box(width: width, cell)
          }
        })
      }

      if spec.ignore {
        // Preserve height, but ignore width.
        cell = tbl-cell(spec, styles => {
          box(
            width: 0pt,
            height: measure(cell, styles).height,
            place(spec.halign + spec.valign, cell)
          )
        })
      } else {
        tbl-cell(spec, styles => {
          let width = measure(cell, styles).width
          let width-p = width + pt-length(spec.pad.left + spec.pad.right, styles)
          if spec.colspan == 1 and cols.at(col) == "equalize" {
              equalize-width.update(e => calc.max(e, width-p))
          }
          cell-widths.update(d => {
            let (wcol, curr) = cell-width-at(d, col, spec: spec)
            curr.max = calc.max(curr.max, width-p)

            if tbl-numeric != none {
              let (cell-left, _, cell-right) = tbl-numeric
              cell-left = measure(cell-left, styles).width
              cell-right = measure(cell-right, styles).width

              curr.num-l = calc.max(curr.num-l, cell-left)
              curr.num-r = calc.max(curr.num-r, cell-right)
            } else if spec.class == "A" {
              curr.alpha = calc.max(curr.alpha, width)
            }

            d.insert(wcol, curr)
            d
          })
        })
      }

      if spec.class == "S" {
        assert-ctx(
          empty,
          "Non-empty cell when class is spanned column",
          row: row,
          col: col,
        )
        cell = ()

      } else if spec.class == "^" or txt-cell == "\\^" {
        assert-ctx(
          txt-cell == "\\^" or empty,
          "Non-empty cell when class is spanned row",
          row: row,
          col: col,
        )

        // Find origin cell for this spanned one in current column
        let prev-row = -1
        while rows.at(prev-row).at(1).at(col) == () {
          prev-row -= 1
        }
        rows.at(prev-row).at(1).at(col).rowspan += 1
        cell = ()

      } else if (spec.class in ("_", "-", "=")
            or txt-cell in ("_", "=", "\\_", "\\=")
      ) {
        assert-ctx(
          empty,
          "Non-empty cell when class is horizontal rule",
          row: row,
          col: col,
        )

        let line-start-x = 0%
        let line-length = 100%
        if txt-cell in ("\\_", "\\=") {
          line-start-x += spec.pad.left
          line-length -= spec.pad.left + spec.pad.right
        }

        cell = tablex.cellx(
          align: center + horizon,
          fill: spec.bg,
          colspan: spec.colspan,

          {
            if spec.class in ("_", "-") or txt-cell in ("_", "\\_") {
              // Horizontal rule
              line(
                start: (line-start-x, 50%),
                length: line-length,
                stroke: options.stroke,
              )
            } else {
              // Double horizontal rule
              line(
                start: (line-start-x, 50% - 1pt),
                length: line-length,
                stroke: options.stroke,
              )
              line(
                start: (line-start-x, 50% + 1pt),
                length: line-length,
                stroke: options.stroke,
              )
            }
          }
        )

      } else if spec.class in ("L", "C", "R", "N", "A") {
        cell = tablex.cellx(
          align: spec.halign + spec.valign,
          fill: spec.bg,
          colspan: spec.colspan,

          if spec.class == "A" { cell }
          else { pad(..spec.pad, cell) },
        )

        if tbl-numeric != none {
          cell.tbl-numeric = tbl-numeric
        }
      }

      new-row.push(cell)
    }
    rows.push((rowdef, new-row))
  }

  ///////////////////////// LINE REALIZATION /////////////////////////

  vlines = vlines.flatten()

  if options.box and not options.auto-lines {
    hlines += (
      tablex.hlinex(y: 0),
      tablex.hlinex(y: rows.len()),
    )

    vlines += (
      tablex.vlinex(x: 0),
      tablex.vlinex(x: cols.len()),
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
      locate(loc => {
        let equalize-width = equalize-width.at(loc)
        let cell-widths = cell-widths.at(loc)
        let rows = rows.enumerate().map(row => {
          let (row, cells) = row
          let (rowdef, cells) = cells

          cells.enumerate().map(cell => {
            let (col, cell) = cell
            let spec = rowdef.at(col)
            let (_, curr) = cell-width-at(cell-widths, col, spec: spec)

            if type(cell) == "dictionary" and "tbl-numeric" in cell {
              // Align smaller class "N" cells in this column
              cell.content = tbl-cell(spec, {
                let (cell-left, sep, cell-right) = cell.tbl-numeric

                pad(
                  ..spec.pad,
                  stack(
                    dir: ltr,
                    box(width: curr.num-l, align(right, cell-left)),
                    sep,
                    box(width: curr.num-r, align(left, cell-right)),
                  )
                )
              })
            } else if type(cell) == "dictionary" and spec.class == "A" {
              // Align smaller class "A" cells in this column
              cell.content = tbl-cell(spec, {
                pad(
                  ..spec.pad,
                  box(width: curr.alpha, align(left, cell.content)),
                )
              })
            }

            cell
          })
        })

        // Freeze all "auto" widths into real lengths
        let cols = cols.enumerate().map(col => {
          let (col, width) = col
          if width == auto {
            cell-widths.at(str(col), default: (max: auto)).max
          } else {
            width
          }
        })

        // Distribute excess width from colspanned cells
        for (col, cell) in cell-widths {
          if "," not in col {
            continue
          }
          let (begin, end) = col.split(",")
          begin = int(begin)
          end = int(end)
          let curr-widths = cols.slice(begin, end)
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
          if diff <= 0 {
            continue
          }
          for (col, width) in curr-widths.enumerate() {
            col += begin
            width += diff * width / (curr-width) * 1pt
            cols.at(col) = width
          }
          equalize-width += eq * diff * equalize-width / (curr-width) * 1pt
        }

        // Freeze "equalize" widths into real lengths
        cols = cols.map(width => {
          if width == "equalize" {
            equalize-width
          } else {
            width
          }
        })

        tablex.tablex(
          columns: cols,
          auto-lines: options.auto-lines,
          header-rows: options.header-rows,
          inset: 0pt,
          repeat-header: options.repeat-header,
          stroke: options.stroke,

          ..vlines,
          ..hlines,
          ..rows.flatten(),
        )
      })
    )
  )
})

#let template(body, ..options) = {
  show raw.where(lang: "tbl"): it => tbl(it.text, ..options)

  body
}
