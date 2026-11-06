#import "ansi.typ": _has-ansi, _render-ansi-raw
#import "chrome.typ": _resolve-chrome

#let _render-bg-completions(entry, theme) = {
  if "bg-completions" in entry {
    for note in entry.bg-completions {
      text(fill: theme.fg)[#note]
      linebreak()
    }
  }
}

#let _render-output(entry, theme, font) = {
  if entry.output == "" { return }
  // Strip trailing \n — commands produce stdout with trailing newline (bash
  // convention), but the terminal display doesn't render a visible blank line
  // for the final newline (it just positions the cursor for the next prompt).
  let output = entry.output.trim("\n", at: end)
  if output == "" { return }
  let has-lang = "lang" in entry and entry.lang != none
  let has-ansi = _has-ansi(output)
  if has-lang and not has-ansi {
    show raw.where(block: false): it => {
      set text(..font)
      box(fill: none, inset: 0pt, outset: 0pt, radius: 0pt, stroke: none, it)
    }
    for line in output.split("\n") {
      raw(lang: entry.lang, line)
      linebreak()
    }
  } else if has-ansi {
    _render-ansi-raw(output, theme.fg, theme.ansi)
    linebreak()
  } else {
    let color = if entry.exit-code != 0 { theme.error } else { theme.fg }
    for line in output.split("\n") {
      text(fill: color)[#line]
      linebreak()
    }
  }
}

#let _render-prompt-parts(user, hostname, path, theme) = {
  let user-host = user + "@" + hostname
  let colon = ":"
  let dollar = "$ "
  text(fill: theme.prompt-user)[#user-host]
  text(fill: theme.prompt-sym)[#colon]
  text(fill: theme.prompt-path)[#path]
  text(fill: theme.prompt-sym)[#dollar]
}

#let _render-prompt(entry, theme) = {
  let cmd = entry.command
  if cmd.contains("\n") {
    // Multi-line command: first line gets full prompt, rest get "> "
    let lines = cmd.split("\n")
    _render-prompt-parts(entry.user, entry.hostname, entry.path, theme)
    text(fill: theme.fg)[#lines.at(0)]
    for line in lines.slice(1) {
      linebreak()
      text(fill: theme.prompt-sym)[> ]
      text(fill: theme.fg)[#line]
    }
  } else {
    _render-prompt-parts(entry.user, entry.hostname, entry.path, theme)
    text(fill: theme.fg)[#cmd]
  }
}

/// Caret at the prompt (`0.85em` tall — small enough that line height stays stable when wrap moves it to the next line). Hidden frames omit the box entirely.
#let _cursor-cell(theme) = box(
  fill: theme.cursor,
  width: 0.5em,
  height: 0.85em,
  baseline: 15%,
)

// Unified frame renderer for shell sessions
#let _render-frame(
  session,
  user,
  hostname,
  theme,
  font,
  chrome,
  style,
  term-width,
  typing: none,
  cursor-pos: none,
  show-cursor: true,
  term-height: auto,
  overflow: "clip",
) = {
  let title = user + "@" + hostname
  let title-bar = (chrome.bar)(title, theme, font)

  let body-content = {
    set text(..font, fill: theme.fg)
    set par(leading: style.leading)

    for entry in session.entries {
      _render-prompt(entry, theme)
      linebreak()
      _render-output(entry, theme, font)
      _render-bg-completions(entry, theme)
    }

    // Final prompt
    {
      _render-prompt-parts(
        session.final-user,
        session.final-hostname,
        session.final-path,
        theme,
      )
      if typing != none {
        if cursor-pos != none {
          // Mid-line cursor: split text at cursor position
          let chars = typing.clusters()
          let pos = calc.min(cursor-pos, chars.len())
          let before = chars.slice(0, pos).join()
          let after = chars.slice(pos).join()
          text(fill: theme.fg)[#before]
          if show-cursor { _cursor-cell(theme) }
          text(fill: theme.fg)[#after]
        } else {
          // Default: cursor at end
          text(fill: theme.fg)[#typing]
          if show-cursor { _cursor-cell(theme) }
        }
      } else if show-cursor {
        _cursor-cell(theme)
      }
    }
  }

  if term-height != auto and overflow == "paginate" {
    // Paginate: split content across new pages instead of clipping
    context {
      let title-h = if title-bar == none { 0pt } else {
        measure(title-bar).height
      }
      let available = term-height - title-h

      let one-line = measure(block({
        set text(..font)
        set par(leading: style.leading)
        [X]
      })).height
      let two-lines = measure(block({
        set text(..font)
        set par(leading: style.leading)
        [X]
        linebreak()
        [X]
      })).height
      let line-step = two-lines - one-line
      let lines-per-page = calc.max(1, calc.floor(
        (available - 20pt) / line-step,
      ))

      // Count lines per entry: 1 (prompt) + output lines
      let entries = session.entries
      let line-counts = entries.map(e => {
        let n = if e.output == "" { 0 } else { e.output.split("\n").len() }
        1 + n
      })

      // Group entries into pages via fold
      let pages = if entries.len() == 0 {
        ((items: (), count: 0),)
      } else {
        line-counts
          .zip(entries)
          .fold(
            ((items: (), count: 0),),
            (acc, pair) => {
              let n = pair.at(0)
              let entry = pair.at(1)
              let last = acc.last()
              if last.count + n > lines-per-page and last.items.len() > 0 {
                acc + ((items: (entry,), count: n),)
              } else {
                let updated = (
                  items: last.items + (entry,),
                  count: last.count + n,
                )
                acc.slice(0, acc.len() - 1) + (updated,)
              }
            },
          )
      }

      // Does the final prompt (1 line) still fit on the last page?
      let last-page = pages.last()
      let final-fits = last-page.count + 1 <= lines-per-page

      for (pi, page) in pages.enumerate() {
        if pi > 0 { pagebreak() }
        let is-last = pi == pages.len() - 1

        block(
          fill: theme.bg,
          radius: chrome.radius,
          clip: true,
          width: term-width,
          height: term-height,
          {
            if title-bar != none { title-bar }
            block(width: 100%, height: available, clip: true, {
              block(inset: style.inset, width: term-width, {
                set text(..font, fill: theme.fg)
                set par(leading: style.leading)
                for entry in page.items {
                  _render-prompt(entry, theme)
                  linebreak()
                  _render-output(entry, theme, font)
                  if "bg-completions" in entry {
                    for note in entry.bg-completions {
                      text(fill: theme.fg)[#note]
                      linebreak()
                    }
                  }
                }
                if is-last and final-fits {
                  _render-prompt-parts(
                    session.final-user,
                    session.final-hostname,
                    session.final-path,
                    theme,
                  )
                  if typing != none { text(fill: theme.fg)[#typing] }
                  if show-cursor {
                    _cursor-cell(theme)
                  }
                }
              })
            })
          },
        )
      }

      if not final-fits {
        pagebreak()
        block(
          fill: theme.bg,
          radius: chrome.radius,
          clip: true,
          width: term-width,
          height: term-height,
          {
            if title-bar != none { title-bar }
            block(width: 100%, height: available, clip: true, {
              block(inset: style.inset, width: term-width, {
                set text(..font, fill: theme.fg)
                set par(leading: style.leading)
                _render-prompt-parts(
                  session.final-user,
                  session.final-hostname,
                  session.final-path,
                  theme,
                )
                if typing != none { text(fill: theme.fg)[#typing] }
                if show-cursor {
                  _cursor-cell(theme)
                }
              })
            })
          },
        )
      }
    }
  } else if term-height != auto {
    // Clip: shift old lines off the top like a real terminal.
    // Use grid(rows: auto, 1fr) so the title bar takes its natural height
    // and the body fills the rest — no manual title-bar measurement needed.
    block(
      fill: theme.bg,
      radius: chrome.radius,
      clip: true,
      width: term-width,
      height: term-height,
      grid(
        columns: (1fr,),
        rows: if title-bar != none { (auto, 1fr) } else { (1fr,) },
        ..if title-bar != none { (title-bar,) } else { () },
        layout(size => context {
          let available = size.height
          let body-block = block(
            inset: style.inset,
            width: term-width,
            body-content,
          )
          let body-h = measure(body-block).height

          // Measure line-to-line step for snapping to whole lines
          let one-line = measure(block({
            set text(..font)
            set par(leading: style.leading)
            [X]
          })).height
          let two-lines = measure(block({
            set text(..font)
            set par(leading: style.leading)
            [X]
            linebreak()
            [X]
          })).height
          let line-step = two-lines - one-line

          block(width: 100%, height: available, clip: true, {
            if body-h > available {
              // Snap to whole-line boundary, accounting for the body inset.
              // Line tops sit at inset-y + k*line-step inside the body block.
              let inset-y = style.inset.at("y", default: 6pt)
              let lines-to-skip = calc.max(0, calc.ceil(
                (body-h - available - inset-y) / line-step,
              ))
              v(-(inset-y + lines-to-skip * line-step - 2pt))
            }
            body-block
          })
        }),
      ),
    )
  } else {
    block(
      fill: theme.bg,
      radius: chrome.radius,
      clip: true,
      width: term-width,
      {
        if title-bar != none { title-bar }
        block(inset: style.inset, width: 100%, body-content)
      },
    )
  }
}
