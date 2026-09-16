#import "theme.typ": _resolve-font, _resolve-style, _resolve-theme
#import "chrome.typ": _resolve-chrome
#import "session.typ": (
  _execute-session, _parse-commands, _process-keyline,
  _process-keyline-with-history,
)
#import "render.typ": _render-frame

// --- System constructor ---

/// Define a virtual system configuration.
///
/// ```typst
/// #let sys = conch.system(
///   hostname: "dev",
///   users: ((name: "alice", groups: ("sudo",)), (name: "bob",)),
///   files: ("hello.txt": "world"),
/// )
/// ```
#let system(
  hostname: "conch",
  users: (),
  groups: (),
  files: (:),
  plugins: (),
  wasm-plugins: (),
) = (
  hostname: hostname,
  users: users,
  groups: groups,
  files: files,
  plugins: plugins,
  wasm-plugins: wasm-plugins,
)

/// Resolve a system dict: if none provided, build a default one.
#let _resolve-system(sys) = {
  if sys == none {
    system()
  } else {
    // Fill in defaults for missing keys
    let defaults = system()
    defaults + sys
  }
}

// --- Public data function ---

/// Execute commands and return raw session data without rendering.
///
/// Returns a dictionary with `entries` (array of command results) and
/// `final-path` (the working directory after all commands).
///
/// Each entry contains: `user`, `hostname`, `path`, `command`, `output`,
/// `exit-code`, and optionally `lang` (detected language for syntax highlighting).
///
/// ```typst
/// #let result = execute(
///   system: system(files: ("hello.txt": "world")),
///   user: "alice",
///   commands: ("whoami", "cat hello.txt"),
/// )
/// #result.entries.at(0).output // "alice"
/// ```
/// - include-files (bool): If `true`, the returned dictionary includes a `files`
///   key mapping each path to its content, mode, and type after execution.
#let execute(
  system: none,
  user: "user",
  commands: (),
  include-files: false,
) = {
  let sys = _resolve-system(system)
  _execute-session(user, sys, commands, include-files: include-files)
}

// --- Public shell functions ---

// Defaults for `hold` on animation entrypoints; callers may pass a partial dict (`defaults + hold`).
#let _hold-per-line-defaults = (after-frame: 0)
#let _hold-per-char-defaults = (
  after-output: 0,
  after-final: 0,
  final-cursor-blink: false,
  final-blink-hold: 2,
)

// `typst compile --input conch_hold_*=…` overrides `hold:` in source (last wins). Key names are stable for scripts / `just gif`.
#let _parse-bool-input(s) = {
  if s == "0" or s == "false" or s == "no" or s == "off" { return false }
  if s == "1" or s == "true" or s == "yes" or s == "on" { return true }
  false
}

#let _hold-input-patch-char() = {
  let o = (:)
  let a = sys.inputs.at("conch_hold_after_output", default: none)
  if a != none { o.insert("after-output", int(a)) }
  let b = sys.inputs.at("conch_hold_after_final", default: none)
  if b != none { o.insert("after-final", int(b)) }
  let c = sys.inputs.at("conch_hold_final_cursor_blink", default: none)
  if c != none { o.insert("final-cursor-blink", _parse-bool-input(c)) }
  let d = sys.inputs.at("conch_hold_final_blink_hold", default: none)
  if d != none { o.insert("final-blink-hold", int(d)) }
  o
}

#let _hold-input-patch-line() = {
  let o = (:)
  let a = sys.inputs.at("conch_hold_after_frame", default: none)
  if a != none { o.insert("after-frame", int(a)) }
  o
}

/// Generate an array of terminal frame content blocks — one per animation step.
/// No pages or side effects; integrate with any framework (touying, polylux, …).
///
/// Modes:
/// - `"per-line"` — one frame per command execution step (default)
/// - `"per-char"` — one frame per keystroke (supports `\xNN` keyboard escapes)
/// - `"key-frames"` — only meaningful moments (typed + output for each command)
///
/// The last command in `commands` is always typed but **not executed**.
///
/// ```typst
/// #let frames = terminal-frames(
///   commands: ("ls", "cat hello.txt", "echo done"),
///   files: ("hello.txt": "Hello!"),
/// )
/// // frames: array of content — use with touying #alternatives(..frames)
/// ```
#let terminal-frames(
  mode: "per-line",
  system: none,
  user: "user",
  theme: "dracula",
  font: auto,
  chrome: "macos",
  style: auto,
  width: auto,
  height: auto,
  show-cursor: true,
  overflow: "clip",
  commands: (),
) = {
  let sys = _resolve-system(system)
  let theme = _resolve-theme(theme)
  let font = _resolve-font(font)
  let chrome = _resolve-chrome(chrome)
  let style = _resolve-style(style)
  let term-width = if width == auto { 560pt } else { width }
  let term-height = if height == auto { auto } else { height }

  if commands.len() == 0 { return () }

  let run-cmds = commands.slice(0, commands.len() - 1)
  let last-cmd = commands.last()

  // Shared frame builder
  let frame(session, typing, cursor-pos: none) = _render-frame(
    session,
    user,
    sys.hostname,
    theme,
    font,
    chrome,
    style,
    term-width,
    typing: typing,
    cursor-pos: cursor-pos,
    show-cursor: show-cursor,
    term-height: term-height,
    overflow: overflow,
  )

  let frames = ()

  if mode == "per-line" {
    for i in range(run-cmds.len() + 1) {
      let executed = run-cmds.slice(0, i)
      let session = _execute-session(user, sys, executed)
      let typing = if i < run-cmds.len() { run-cmds.at(i) } else { last-cmd }
      frames += (frame(session, typing),)
    }
  } else if mode == "key-frames" {
    for i in range(run-cmds.len()) {
      // Pre-execution: command typed, not yet run
      let pre-session = _execute-session(user, sys, run-cmds.slice(
        0,
        i,
      ))
      frames += (frame(pre-session, run-cmds.at(i)),)
      // Post-execution: output visible
      let post-session = _execute-session(user, sys, run-cmds.slice(
        0,
        i + 1,
      ))
      frames += (frame(post-session, ""),)
    }
    // Last command typed (not executed)
    let final-session = _execute-session(user, sys, run-cmds)
    frames += (frame(final-session, last-cmd),)
  } else if mode == "per-char" {
    // Pre-process keylines with history
    let cmd-data = {
      let result = ()
      for i in range(run-cmds.len()) {
        let cmd = run-cmds.at(i)
        let history = result.map(d => d.final)
        let d = if cmd.contains("\\x") {
          let states = _process-keyline-with-history(cmd, history)
          let final-text = if states.len() > 0 { states.last().text } else {
            ""
          }
          (final: final-text, states: states)
        } else {
          (final: cmd, states: none)
        }
        result += (d,)
      }
      result
    }
    let exec-cmds = cmd-data.map(d => d.final)

    let last-data = {
      let history = exec-cmds
      if last-cmd.contains("\\x") {
        let states = _process-keyline-with-history(last-cmd, history)
        let final-text = if states.len() > 0 { states.last().text } else { "" }
        (final: final-text, states: states)
      } else {
        (final: last-cmd, states: none)
      }
    }

    for i in range(cmd-data.len()) {
      let info = cmd-data.at(i)
      let executed = exec-cmds.slice(0, i)
      let session = _execute-session(user, sys, executed)

      if info.states != none {
        for state in info.states {
          frames += (frame(session, state.text, cursor-pos: state.cursor),)
        }
      } else {
        let cmd-chars = info.final.clusters()
        for j in range(cmd-chars.len() + 1) {
          let partial = cmd-chars.slice(0, j).join()
          frames += (frame(session, partial),)
        }
      }

      // Output frame
      let session-after = _execute-session(user, sys, exec-cmds.slice(
        0,
        i + 1,
      ))
      frames += (frame(session-after, ""),)
    }

    // Last command typing
    let session-final = _execute-session(user, sys, exec-cmds)
    if last-data.states != none {
      for state in last-data.states {
        frames += (frame(session-final, state.text, cursor-pos: state.cursor),)
      }
    } else {
      let cmd-chars = last-cmd.clusters()
      for j in range(cmd-chars.len() + 1) {
        let partial = cmd-chars.slice(0, j).join()
        frames += (frame(session-final, partial),)
      }
    }
  }

  frames
}

/// Render a terminal session as an embeddable block — no page settings,
/// composable with surrounding content.
///
/// ````typst
/// = Build Log
///
/// #terminal-block(user: "ci", files: (...))[```
/// cargo build --release
/// cargo test
/// ```]
/// ````
#let terminal-block(
  body,
  system: none,
  user: "user",
  theme: "dracula",
  font: auto,
  chrome: "macos",
  style: auto,
  width: auto,
  height: auto,
  show-cursor: true,
  overflow: "clip",
) = {
  let sys = _resolve-system(system)
  let commands = _parse-commands(body)
  let session = _execute-session(user, sys, commands)
  let theme = _resolve-theme(theme)
  let font = _resolve-font(font)
  let chrome = _resolve-chrome(chrome)
  let style = _resolve-style(style)
  let term-width = if width == auto { 560pt } else { width }
  let term-height = if height == auto { auto } else { height }
  _render-frame(
    session,
    user,
    sys.hostname,
    theme,
    font,
    chrome,
    style,
    term-width,
    show-cursor: show-cursor,
    term-height: term-height,
    overflow: overflow,
  )
}

/// Render a full terminal session as a standalone page.
/// Intended as a show rule: `#show: terminal.with(...)`.
/// Sets page dimensions automatically.
#let terminal(
  body,
  system: none,
  user: "user",
  theme: "dracula",
  font: auto,
  chrome: "macos",
  style: auto,
  width: auto,
  height: auto,
  show-cursor: true,
  overflow: "clip",
) = {
  set page(height: auto, width: auto, margin: 0.5in)
  terminal-block(
    body,
    system: system,
    user: user,
    theme: theme,
    font: font,
    chrome: chrome,
    style: style,
    width: width,
    height: height,
    show-cursor: show-cursor,
    overflow: overflow,
  )
}

/// Per-line animation: one frame per command execution.
#let terminal-per-line(
  body,
  system: none,
  user: "user",
  theme: "dracula",
  font: auto,
  chrome: "macos",
  style: auto,
  width: auto,
  height: auto,
  overflow: "clip",
  /// Extra duplicate pages per animation step (PNG/GIF/video frame pacing). Pass a partial dict; merges with defaults, then `sys.inputs` (`conch_hold_after_frame`, …).
  hold: (:),
) = {
  set page(height: auto, width: auto, margin: 0.5in)
  let sys = _resolve-system(system)
  let h = _hold-per-line-defaults + hold + _hold-input-patch-line()
  let commands = _parse-commands(body)
  let theme = _resolve-theme(theme)
  let font = _resolve-font(font)
  let chrome = _resolve-chrome(chrome)
  let style = _resolve-style(style)
  let term-width = if width == auto { 560pt } else { width }
  let term-height = if height == auto { auto } else { height }
  let run-cmds = commands.slice(0, commands.len() - 1)
  let last-cmd = commands.last()

  for i in range(run-cmds.len() + 1) {
    let executed = run-cmds.slice(0, i)
    let session = _execute-session(user, sys, executed)
    let typing = if i < run-cmds.len() { run-cmds.at(i) } else { last-cmd }
    _render-frame(
      session,
      user,
      sys.hostname,
      theme,
      font,
      chrome,
      style,
      term-width,
      typing: typing,
      term-height: term-height,
      overflow: overflow,
    )
    for _ in range(h.after-frame) {
      pagebreak()
      _render-frame(
        session,
        user,
        sys.hostname,
        theme,
        font,
        chrome,
        style,
        term-width,
        typing: typing,
        term-height: term-height,
        overflow: overflow,
      )
    }
    if i < run-cmds.len() { pagebreak() }
  }
}

/// Per-char animation: typing effect, one frame per keystroke.
#let terminal-per-char(
  body,
  system: none,
  user: "user",
  theme: "dracula",
  font: auto,
  chrome: "macos",
  style: auto,
  width: auto,
  height: auto,
  overflow: "clip",
  /// Frame pacing for sequence/GIF export. Pass a partial dict; merges with defaults, then `sys.inputs` (`conch_hold_after_output`, …) so CLI can override.
  hold: (:),
) = {
  set page(height: auto, width: auto, margin: 0.5in)
  let sys = _resolve-system(system)
  let h = _hold-per-char-defaults + hold + _hold-input-patch-char()
  let commands = _parse-commands(body)
  let theme = _resolve-theme(theme)
  let font = _resolve-font(font)
  let chrome = _resolve-chrome(chrome)
  let style = _resolve-style(style)
  let term-width = if width == auto { 560pt } else { width }
  let term-height = if height == auto { auto } else { height }
  let run-cmds = commands.slice(0, commands.len() - 1)
  let last-cmd = commands.last()
  let first-frame = true

  // Pre-process: resolve key events for lines with \x escapes (with history)
  let cmd-data = {
    let result = ()
    for i in range(run-cmds.len()) {
      let cmd = run-cmds.at(i)
      let history = result.map(d => d.final)
      let d = if cmd.contains("\\x") {
        let states = _process-keyline-with-history(cmd, history)
        let final-text = if states.len() > 0 { states.last().text } else { "" }
        (final: final-text, states: states)
      } else {
        (final: cmd, states: none)
      }
      result += (d,)
    }
    result
  }
  let exec-cmds = cmd-data.map(d => d.final)

  let last-data = {
    let history = exec-cmds
    if last-cmd.contains("\\x") {
      let states = _process-keyline-with-history(last-cmd, history)
      let final-text = if states.len() > 0 { states.last().text } else { "" }
      (final: final-text, states: states)
    } else {
      (final: last-cmd, states: none)
    }
  }

  for i in range(cmd-data.len()) {
    let info = cmd-data.at(i)
    let executed = exec-cmds.slice(0, i)
    let session = _execute-session(user, sys, executed)

    if info.states != none {
      // Keyline path: animate each buffer state with cursor position
      for state in info.states {
        if not first-frame { pagebreak() }
        first-frame = false
        _render-frame(
          session,
          user,
          sys.hostname,
          theme,
          font,
          chrome,
          style,
          term-width,
          typing: state.text,
          cursor-pos: state.cursor,
          term-height: term-height,
          overflow: overflow,
        )
      }
    } else {
      // Classic path: animate character by character
      let cmd-chars = info.final.clusters()
      for j in range(cmd-chars.len() + 1) {
        if not first-frame { pagebreak() }
        first-frame = false
        let partial = cmd-chars.slice(0, j).join()
        _render-frame(
          session,
          user,
          sys.hostname,
          theme,
          font,
          chrome,
          style,
          term-width,
          typing: partial,
          term-height: term-height,
          overflow: overflow,
        )
      }
    }

    pagebreak()
    let session-after = _execute-session(user, sys, exec-cmds.slice(
      0,
      i + 1,
    ))
    _render-frame(
      session-after,
      user,
      sys.hostname,
      theme,
      font,
      chrome,
      style,
      term-width,
      typing: "",
      term-height: term-height,
      overflow: overflow,
    )
    for _ in range(h.after-output) {
      pagebreak()
      _render-frame(
        session-after,
        user,
        sys.hostname,
        theme,
        font,
        chrome,
        style,
        term-width,
        typing: "",
        term-height: term-height,
        overflow: overflow,
      )
    }
  }

  {
    let session-final = _execute-session(user, sys, exec-cmds)

    if last-data.states != none {
      for state in last-data.states {
        pagebreak()
        _render-frame(
          session-final,
          user,
          sys.hostname,
          theme,
          font,
          chrome,
          style,
          term-width,
          typing: state.text,
          cursor-pos: state.cursor,
          term-height: term-height,
          overflow: overflow,
        )
      }
    } else {
      let cmd-chars = last-cmd.clusters()
      for j in range(cmd-chars.len() + 1) {
        pagebreak()
        let partial = cmd-chars.slice(0, j).join()
        _render-frame(
          session-final,
          user,
          sys.hostname,
          theme,
          font,
          chrome,
          style,
          term-width,
          typing: partial,
          term-height: term-height,
          overflow: overflow,
        )
      }
    }

    for k in range(h.after-final) {
      pagebreak()
      let show-cursor = if h.final-cursor-blink {
        let half-period = calc.max(1, h.final-blink-hold)
        let phase = calc.floor(k / half-period)
        calc.rem(phase, 2) == 0
      } else {
        true
      }
      _render-frame(
        session-final,
        user,
        sys.hostname,
        theme,
        font,
        chrome,
        style,
        term-width,
        typing: last-data.final,
        show-cursor: show-cursor,
        term-height: term-height,
        overflow: overflow,
      )
    }
  }
}
