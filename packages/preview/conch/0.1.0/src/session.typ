#import "wasm.typ": _plugin

// =========================================================================
// Layer 3: Shell simulator — command engine powered by WASM
// =========================================================================

// --- Internal helpers ---

/// Process a line containing `\xNN` keyboard escape notation.
/// Returns an array of buffer states: (text, cursor, event).
#let _process-keyline(line) = json(_plugin.process_keyline(bytes(line)))

/// Process keyline with history for Up/Down arrow navigation.
#let _process-keyline-with-history(line, history) = json(
  _plugin.process_keyline_with_history(
    bytes(json.encode((input: line, history: history))),
  ),
)

#let _find-raw(it) = {
  ""
  if type(it) == content {
    if it.func() == raw { it.text } else if it.func() == [].func() {
      it.children.map(_find-raw).join()
    }
  }
}

/// Analyze a script to get statement ranges without executing.
#let _analyze-script(script) = {
  if script == "" { return (statements: ()) }
  json(_plugin.analyze_script(bytes(script)))
}

#let _parse-commands(body) = {
  let found = _find-raw(body)
  if found == "" { return () }
  // Use statement-aware splitting: multi-line constructs (if/fi, for/done)
  // become single command strings instead of being split per line.
  let analysis = _analyze-script(found)
  if "error" in analysis {
    // Fallback to line-by-line for backward compat on parse errors
    found.split("\n").filter(line => line.trim() != "")
  } else {
    analysis.statements.map(s => s.source)
  }
}

/// Call an external plugin handler (WASM plugin or Typst function).
/// `files` is a dict of arg-name → VFS content for args that reference existing files.
#let _call-plugin(handler, args, stdin, files) = {
  if type(handler) == plugin {
    let input = json.encode((args: args, stdin: stdin, files: files))
    json(handler.execute(bytes(input)))
  } else {
    handler(args, stdin, files)
  }
}

/// Resolve delegate entries by calling external plugins.
#let _resolve-delegates(session, plugins) = {
  if plugins.len() == 0 { return session }
  let plugin-map = (:)
  for p in plugins {
    plugin-map.insert(p.at(0), p.at(1))
  }
  let new-entries = ()
  for entry in session.entries {
    if "delegate" not in entry or entry.delegate == none {
      new-entries.push(entry)
    } else {
      let d = entry.delegate
      let handler = plugin-map.at(d.command, default: none)
      let out = none
      let code = 127
      let files = if "files" in d { d.files } else { (:) }
      if handler == none {
        out = d.command + ": plugin not found\n"
      } else {
        let result = _call-plugin(handler, d.args, d.stdin, files)
        out = result.stdout
        code = result.exit-code
      }
      new-entries.push((
        user: entry.user,
        hostname: entry.hostname,
        path: entry.path,
        command: entry.command,
        output: out,
        exit-code: code,
      ))
    }
  }
  // Return session with replaced entries
  let result = (:)
  for (k, v) in session {
    if k == "entries" {
      result.insert(k, new-entries)
    } else {
      result.insert(k, v)
    }
  }
  result
}

#let _execute-session(user, system, commands, include-files: false) = {
  let today = datetime.today()
  let date-str = today.display(
    "[weekday repr:short] [month repr:short] [day padding:space] 00:00:00 UTC [year]",
  )
  // Register WASM plugins (wasmi, executed inside conch)
  let wasm-plugins = if "wasm-plugins" in system {
    system.at("wasm-plugins")
  } else { () }
  for (name, wasm-bytes) in wasm-plugins {
    let name-bytes = bytes(name)
    // Header: 4 bytes LE name length + name + wasm bytes
    let name-len = name-bytes.len()
    let header = bytes((
      calc.rem(name-len, 256),
      calc.rem(calc.quo(name-len, 256), 256),
      calc.rem(calc.quo(name-len, 65536), 256),
      calc.rem(calc.quo(name-len, 16777216), 256),
    ))
    let _ = _plugin.register_plugin(header + name-bytes + wasm-bytes)
  }
  // Typst function plugins (delegate path)
  let plugins = if "plugins" in system { system.plugins } else { () }
  let ext-names = plugins.map(p => p.at(0))
  // Strip non-serializable fields from system before JSON encoding
  let sys = system
  if "plugins" in sys { let _ = sys.remove("plugins") }
  if "wasm-plugins" in sys { let _ = sys.remove("wasm-plugins") }
  let config = json.encode((
    user: user,
    system: sys,
    commands: commands,
    date: date-str,
    include-files: include-files,
    external-commands: ext-names,
  ))
  let session = json(_plugin.execute(bytes(config)))
  _resolve-delegates(session, plugins)
}
