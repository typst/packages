#let _flush_equal_run(run, threshold, context-lines) = {
  let keep = calc.max(0, context-lines)
  if run.len() > threshold and run.len() > keep * 2 {
    let keep = calc.min(keep, run.len())
    let hidden = run.len() - keep * 2
    run.slice(0, keep) + ((
      kind: "collapsed",
      hidden: hidden,
    ),) + run.slice(run.len() - keep)
  } else {
    run
  }
}

#let _with-collapse(rows, threshold, context-lines) = {
  let output = ()
  let equal-run = ()

  for row in rows {
    if row.kind == "equal" {
      equal-run.push(row)
    } else {
      output += _flush_equal_run(equal-run, threshold, context-lines)
      equal-run = ()
      output.push(row)
    }
  }

  output + _flush_equal_run(equal-run, threshold, context-lines)
}

#let _line-in-range(value, start, end) = {
  value != none and value >= start and value <= end
}

#let _row-in-range(row, start, end, side) = {
  let old-hit = _line-in-range(row.at("old_no", default: none), start, end)
  let new-hit = _line-in-range(row.at("new_no", default: none), start, end)
  if side == "old" {
    old-hit
  } else if side == "new" {
    new-hit
  } else if side == "both" {
    old-hit or new-hit
  } else {
    panic("range-side must be \"both\", \"old\", or \"new\"")
  }
}

#let _range-rows(rows, range, side) = {
  if range == auto {
    rows
  } else {
    if range.len() != 2 {
      panic("range must be (start, end)")
    }
    let start = range.first()
    let end = range.last()
    if start < 1 {
      panic("range start must be greater than or equal to 1")
    }
    if end < start {
      panic("range end must be greater than or equal to range start")
    }

    rows.filter(row => _row-in-range(row, start, end, side))
  }
}

#let diffst-rows(
  report,
  display: "collapsed",
  collapse-threshold: 14,
  context-lines: 3,
  range: auto,
  range-side: "both",
) = {
  if context-lines < 0 {
    panic("context-lines must be greater than or equal to 0")
  }
  if collapse-threshold < 0 {
    panic("collapse-threshold must be greater than or equal to 0")
  }

  let rows = _range-rows(report.rows, range, range-side)
  if display == "full" {
    rows
  } else if display == "collapsed" {
    _with-collapse(rows, collapse-threshold, context-lines)
  } else {
    panic("display must be \"full\" or \"collapsed\"")
  }
}

#let _empty_hunk(row-start) = (
  ops: (),
  row_start: row-start,
  row_end: row-start,
  context_before: 0,
  context_after: 0,
)

#let _start_hunk(previous, op, context-lines) = {
  let hunk = _empty_hunk(op.row_start)

  if previous != none and previous.kind == "equal" {
    hunk.ops.push(previous)
    hunk.context_before = calc.min(previous.row_len, context-lines)
    hunk.row_start = previous.row_start + previous.row_len - hunk.context_before
  }

  hunk
}

#let _equal_gap_exceeds_context(op, context-lines) = {
  let hidden-prefix = op.row_len - calc.min(op.row_len, context-lines)
  hidden-prefix > context-lines
}

#let _finish_hunk(report, hunk) = {
  let rows = report.rows.slice(hunk.row_start, hunk.row_end)
  let old-nos = rows
    .filter(row => row.at("old_no", default: none) != none)
    .map(row => row.old_no)
  let new-nos = rows
    .filter(row => row.at("new_no", default: none) != none)
    .map(row => row.new_no)

  (
    ops: hunk.ops,
    rows: rows,
    row_start: hunk.row_start,
    row_end: hunk.row_end,
    context_before: hunk.context_before,
    context_after: hunk.context_after,
    old_start: if old-nos.len() == 0 { none } else { old-nos.first() },
    old_len: old-nos.len(),
    new_start: if new-nos.len() == 0 { none } else { new-nos.first() },
    new_len: new-nos.len(),
  )
}

#let diffst-hunks(report, context-lines: 3) = {
  if context-lines < 0 {
    panic("context-lines must be greater than or equal to 0")
  }

  let hunks = ()
  let current = none
  let previous = none

  for op in report.ops {
    if op.kind == "equal" {
      if current != none {
        current.ops.push(op)
        current.row_end = op.row_start + op.row_len
        current.context_after = calc.min(op.row_len, context-lines)

        if _equal_gap_exceeds_context(op, context-lines) {
          current.row_end = op.row_start + context-lines
          hunks.push(_finish_hunk(report, current))
          current = none
        }
      }
    } else {
      if current == none {
        current = _start_hunk(previous, op, context-lines)
      }

      current.ops.push(op)
      current.row_end = op.row_start + op.row_len
    }

    previous = op
  }

  if current != none {
    hunks.push(_finish_hunk(report, current))
  }

  hunks
}
