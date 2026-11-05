///! Resolution of directives that depend on the final shape of the table.
///!
///! Most directives record what they are told and are validated once at the
///! end. Column ordering could not: `columns-move` used to resolve its anchor
///! against the column list as it stood mid-fold, so hiding the anchor, or
///! promoting it into the stub, changed whether the move succeeded depending on
///! which line was written first. That contradicts the architecture's claim
///! that directive order is free.
///!
///! Ordering now happens here, once, after every directive has been recorded,
///! so a move sees the columns the table actually has.

#import "../format/apply.typ": matches-column, named
#import "../parts/stub.typ": stub-column-names
#import "../utils/columns.typ": check-addressable
#import "../utils/errors.typ": check, check-column

#let _check-visible(spec, name) = check-addressable(
  name,
  "columns-move",
  columns: spec.columns,
  hidden: spec.hidden,
  stub: stub-column-names(spec.stub),
  hidden-hint: "Move a visible column, or drop the columns-hide.",
  stub-hint: "The stub sits on the leading edge; its columns are not reordered.",
)

// Where a combined column goes, resolved once every directive has landed.
//
// Deciding this inside the fold read whichever columns happened to be present
// at that moment, so hiding a source before the combine put the result at the
// end of the table and hiding it afterwards did not. Directive order is free
// everywhere else, and this is the same fix `apply-moves` exists to be.
#let apply-combines(spec) = {
  let out = spec

  // Position in the data as it arrived, which no directive changes. A column
  // built by an earlier combine sits where its own first source sat, so a chain
  // of combines resolves in the order a reader would draw them.
  let order = (:)
  for (index, name) in out.data-columns.enumerate() { order.insert(name, index) }
  for directive in out.combines {
    let sources = if type(directive.from) == array { directive.from } else { () }
    if sources.len() > 0 and directive.into not in order and sources.first() in order {
      order.insert(directive.into, order.at(sources.first()))
    }
  }

  for directive in out.combines {
    let sources = if type(directive.from) == array { directive.from } else { () }
    let hidden = if directive.hide-sources { sources } else { () }
    let kept = out.columns.filter(name => name not in hidden)

    out.columns = if directive.into in kept { kept } else if directive.into not in order {
      kept
    } else {
      // Counted over the columns that survive, against the order the data had:
      // the result takes the place of the first of its sources whether or not
      // that source is still shown.
      let anchor = order.at(directive.into)
      let at = kept.filter(name => order.at(name, default: order.len()) < anchor).len()
      kept.slice(0, at) + (directive.into,) + kept.slice(at)
    }

    // Hidden sources stay readable by predicates and formatters. A name already
    // hidden is not hidden twice.
    for name in hidden {
      if name != directive.into and name not in out.hidden { out.hidden.push(name) }
    }
  }

  out
}

// A column that takes no alignment, said as such rather than as a typo.
//
// The stub is tested before the hidden columns, which reverses the order
// `_check-visible` uses. It can afford either order because it refuses the stub
// anyway; here the order shows, since `columns-hide` on a stub column is
// silently ineffective and the stub still draws it. Reporting that column as
// hidden would name one plainly on the page.
#let _check-alignable(spec, name) = {
  if name == spec.stub.rowname { return }

  check(
    name != spec.stub.group,
    "columns-align",
    "column " + name + " is the stub's group column",
    hint: "Only the row-name column takes an alignment; a group column is drawn as a row label across the table.",
  )
  check(
    name != spec.stub.indent,
    "columns-align",
    "column " + name + " is the stub's indent column",
    hint: "Only the row-name column takes an alignment; an indent column sets the stub's indentation and is never drawn.",
  )
  check(
    name not in spec.hidden,
    "columns-align",
    "column " + name + " is hidden",
    hint: "Align a visible column: columns-hide removes one, and columns-combine hides its sources unless hide-sources is false.",
  )
  // The row-name column is the one name beyond the rendered columns that an
  // alignment takes, so the hint that lists what is known names it too. It goes
  // first, which is the edge the stub sits on.
  let stub = if spec.stub.rowname == none { () } else { (spec.stub.rowname,) }
  check-column(stub + spec.columns, "columns-align", name)
}

// Which column each alignment lands on, resolved once the table knows which
// columns it has.
//
// Deciding this inside the fold read whichever columns happened to be present
// at that moment: a blanket alignment ran before `apply-combines` built the
// combined column and so never reached it, and an array selector was filtered
// against that same half-built list, which dropped a typo without a word.
//
// The recorded order is walked as written, because the last alignment for a
// column wins. Resolving the blanket selectors in a pass of their own would let
// one override a named alignment written after it.
#let apply-alignments(spec) = {
  let out = spec

  for directive in out.alignments {
    let spelled = type(directive.columns) in (str, array)
    // Read through `named` whichever way it is written, so the two sides cannot
    // disagree about what a selector may be. It answers with the names a spelled
    // selector holds, with nothing for `auto` and a predicate, and refuses
    // anything else. A selector that neither names nor filters was left to the
    // filter below, which sees one column at a time, so a table whose every
    // column is hidden ran it against nothing and the selector went unread.
    let spelled-names = named(directive.columns, str)
    let names = if spelled {
      spelled-names
    } else {
      out.columns.filter(name => matches-column(directive.columns, name))
    }

    for name in names {
      if spelled { _check-alignable(out, name) }
      // Indentation is leading space before the row name, and any alignment
      // other than start absorbs it, so every level would sit against the same
      // edge and the hierarchy would be gone.
      check(
        name != out.stub.rowname or out.stub.indent == none or directive.alignment == start,
        "columns-align",
        "an indented stub is start-aligned",
        hint: "The indent column sets the depth of each row name, which any other alignment would flatten.",
      )
      out.align.insert(name, directive.alignment)
    }
  }

  out
}

#let apply-moves(spec) = {
  let columns = spec.columns

  for directive in spec.moves {
    check(
      directive.before == none or directive.after == none,
      "columns-move",
      "before and after cannot both be given",
      hint: "A column goes on one side of the anchor or the other.",
    )
    let anchor = if directive.before != none { directive.before } else { directive.after }
    check(
      anchor != none,
      "columns-move",
      "no anchor given",
      hint: "Pass before: or after: naming the column to move relative to.",
    )
    check(
      directive.columns.dedup().len() == directive.columns.len(),
      "columns-move",
      "the same column is moved twice",
      value: directive.columns,
      hint: "A column appears once in a table.",
    )

    for name in directive.columns { _check-visible(spec, name) }
    _check-visible(spec, anchor)
    check(
      anchor not in directive.columns,
      "columns-move",
      "cannot move " + anchor + " relative to itself",
      hint: "Move relative to a column other than the ones being moved.",
    )

    let rest = columns.filter(name => name not in directive.columns)
    let at = rest.position(name => name == anchor)
    let cut = if directive.before != none { at } else { at + 1 }
    columns = rest.slice(0, cut) + directive.columns + rest.slice(cut)
  }

  spec.columns = columns
  spec
}
