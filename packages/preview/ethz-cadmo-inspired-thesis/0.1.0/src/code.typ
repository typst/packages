// Code blocks
// --- Thanks to VirtCode (https://github.com/VirtCode)

#let padnum(num, width, padding: "0") = {
  let num = str(num)

  let diff = calc.max(width - num.len(), 0)
  return padding * diff + num
}

/// formats multiple blocks of code with line numbers, adding ellipses between the blocks
#let multi-code(blocks, filename: none, projectname: none, breakable: false) = {
  let radius = 4pt
  let background = gray.lighten(70%)
  let foreground = background.darken(15%)

  let separator = line(length: 100%, stroke: (paint: foreground, cap: "round", dash: "dashed"))
  let numpad = "0"

  // all raws need to be blocks to not get the highlight
  let rraw(..args) = raw(..args, block: true)

  // split blocks into lines with numbers
  let blocks = blocks.map(((code, start)) => code
    .text
    .split("\n")
    .enumerate()
    .map(((i, line)) => (start + i, rraw(line.replace("<fakebreak>", "\n"), lang: code.lang))))

  // width of the line numbers
  let width = str(calc.max(..blocks.join().map(s => s.at(0)))).len()

  // replace numbers with padded raw
  let blocks = blocks.map(lines => lines.map(((line, code)) => (rraw(padnum(line, width, padding: numpad)), code)))

  // join lines with separator of choice
  let lines = blocks.join((
    (rraw("." * width), table.cell(separator, align: horizon)),
  ))

  let header = if filename != none {
    (
      table.header(table.cell(colspan: 2, if projectname != none {
        grid(
          columns: (1fr, auto),
          rraw(filename), rraw(projectname),
        )
      } else {
        rraw(filename)
      })),
    )
  } else {
    ()
  }

  block(fill: gray.lighten(70%), radius: radius, clip: not breakable, breakable: breakable)[
    #table(
      columns: (auto, 1fr),
      align: left, // don't inherit alignment (e.g. center inside a figure)
      stroke: (x, y) => (top: if x == 0 { foreground }, right: if x == 0 { foreground }), // otherwise zathura renders ugly
      fill: (x, y) => if x == 0 or (y == 0 and header.len() > 0) { foreground },
      ..header,
      ..lines.flatten()
    )
  ]
}

/// formats a single block of code
#let code(code, start: 1, filename: none, projectname: none, breakable: false) = multi-code(
  ((code, start),),
  filename: filename,
  projectname: projectname,
  breakable: breakable,
)

/// formats a single block of code read from a file
///
/// `content` is the file's text, read by the caller, e.g. `code-file(read("snippet.rs"), ...)`.
///
/// `from` and `to` optionally select an inclusive, 1-indexed line range; the
/// displayed line numbers keep matching the original file.
///
/// Any line containing `<hide>` starts a hidden region and any line containing
/// `</hide>` ends it. The marker lines and everything between them are dropped
/// from the display (but stay in the file), and the remaining lines are
/// renumbered contiguously. Hiding is meant to strip file-only preambles such
/// as test harness directives and is not combined with `from`/`to`.
#let code-file(content, lang: none, from: none, to: none, filename: none, projectname: none) = {
  // drop a single trailing newline so files don't render an empty last line
  let lines = content.trim("\n", at: end, repeat: false).split("\n")

  // strip `<hide>` … `</hide>` regions from the display
  let visible = ()
  let hidden = false
  let did-hide = false
  for line in lines {
    if line.contains("<hide>") {
      if hidden {
        panic("code-file: nested `<hide>` (a region is already open, close it with `</hide>` first)")
      }
      hidden = true
      did-hide = true
    } else if line.contains("</hide>") {
      if not hidden {
        panic("code-file: stray `</hide>` without a matching `<hide>`")
      }
      hidden = false
    } else if not hidden {
      visible.push(line)
    }
  }
  // a `<hide>` left open would silently swallow the rest of the file
  if hidden {
    panic("code-file: unclosed `<hide>` region (missing a line with `</hide>`)")
  }
  // drop blank lines a stripped preamble leaves at the top of the listing
  while did-hide and visible.len() > 0 and visible.first().trim() == "" {
    let _ = visible.remove(0)
  }
  let lines = visible

  let start = if from != none { from } else { 1 }
  let end = if to != none { to } else { lines.len() }
  let lines = lines.slice(start - 1, end)

  code(
    raw(lines.join("\n"), lang: lang),
    start: start,
    filename: filename,
    projectname: projectname,
  )
}
