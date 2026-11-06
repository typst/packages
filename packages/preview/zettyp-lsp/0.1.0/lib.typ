// Source-backed LSP values and announcements, without application policy.
#import "@preview/zettyp-core:0.1.0": eval

/// Publish a constructed value under one of the LSP effect kinds.
#let announce = eval.announce

#let effect-kinds = (
  publish-diagnostics: label("lsp.publish-diagnostics"),
  code-actions: label("lsp.code-actions"),
  hover: label("lsp.hover"),
  definition: label("lsp.definition"),
  references: label("lsp.references"),
)

#let severity = (
  error: 1,
  warning: 2,
  information: 3,
  hint: 4,
)

#let severity-values = severity.values()

/// Declare one source-backed LSP diagnostic.
#let diagnostic(
  origin: none,
  message: none,
  severity: none,
  code: none,
  source: none,
  tags: none,
  related-information: none,
  data: none,
) = {
  if type(origin) != content {
    panic("diagnostic origin must be content")
  }
  if type(message) != str {
    panic("diagnostic message must be a string")
  }
  if severity != none and severity not in severity-values {
    panic("diagnostic severity must be an LSP severity")
  }
  if code != none and type(code) not in (int, str, label) {
    panic("diagnostic code must be an integer, string, or label")
  }
  if source != none and type(source) != str {
    panic("diagnostic source must be a string")
  }

  (
    origin: eval.inspect(origin),
    message: message,
    severity: severity,
    code: if type(code) == label { str(code) } else { code },
    source: source,
    tags: tags,
    related-information: related-information,
    data: data,
  )
}

/// Declare one source-backed LSP text edit.
#let text-edit(origin: none, new-text: none) = {
  if type(origin) != content {
    panic("text-edit origin must be content")
  }
  if type(new-text) != str {
    panic("text-edit new-text must be a string")
  }
  (origin: eval.inspect(origin), new-text: new-text)
}

/// Group source-backed text edits into one host-resolved workspace edit.
#let workspace-edit(edits: ()) = {
  if type(edits) != array {
    panic("workspace-edit edits must be an array")
  }
  if edits.any(item => type(item) != dictionary) {
    panic("each workspace edit must be a dictionary")
  }
  (edits: edits)
}

/// Declare one LSP code action and the source content to which it applies.
#let code-action(
  applies-to: none,
  title: none,
  kind: none,
  diagnostics: (),
  edit: none,
  is-preferred: none,
  disabled: none,
  data: none,
) = {
  if type(applies-to) != content {
    panic("code-action applies-to must be content")
  }
  if type(title) != str {
    panic("code-action title must be a string")
  }
  if kind != none and type(kind) != str {
    panic("code-action kind must be a string")
  }
  if type(diagnostics) != array {
    panic("code-action diagnostics must be an array")
  }
  if edit != none and type(edit) != dictionary {
    panic("code-action edit must be a dictionary")
  }
  if is-preferred != none and type(is-preferred) != bool {
    panic("code-action is-preferred must be a boolean")
  }
  if disabled != none and type(disabled) != str {
    panic("code-action disabled reason must be a string")
  }

  (
    applies-to: eval.inspect(applies-to),
    title: title,
    kind: kind,
    diagnostics: diagnostics,
    edit: edit,
    is-preferred: is-preferred,
    disabled: disabled,
    data: data,
  )
}

/// Construct a complete diagnostic publication for the source document that
/// owns `document`. Keep empty publications to clear stale diagnostics.
#let publish-diagnostics(document: none, diagnostics: ()) = {
  if type(document) != content {
    panic("diagnostic document must be source-backed content")
  }
  if type(diagnostics) != array {
    panic("published diagnostics must be an array")
  }
  if diagnostics.any(item => type(item) != dictionary) {
    panic("each published diagnostic must be a dictionary")
  }

  (
    document: eval.inspect(document),
    diagnostics: diagnostics,
  )
}

/// Construct every code-action candidate computed for one source document. A
/// handler selects actions whose `applies-to` ranges intersect a request.
#let offer-code-actions(document: none, actions: ()) = {
  if type(document) != content {
    panic("code-action document must be source-backed content")
  }
  if type(actions) != array {
    panic("offered code actions must be an array")
  }
  if actions.any(item => type(item) != dictionary) {
    panic("each offered code action must be a dictionary")
  }

  (
    document: eval.inspect(document),
    actions: actions,
  )
}

/// Attach caller-computed LSP MarkupContent to a source occurrence.
#let hover(applies-to: none, contents: none) = {
  if type(applies-to) != content {
    panic("hover applies-to must be content")
  }
  if type(contents) != dictionary {
    panic("hover contents must be LSP MarkupContent")
  }
  if contents.at("kind", default: none) not in ("plaintext", "markdown") {
    panic("hover content kind must be plaintext or markdown")
  }
  if type(contents.at("value", default: none)) != str {
    panic("hover content value must be a string")
  }

  (applies-to: eval.inspect(applies-to), contents: contents)
}

/// Attach a caller-resolved definition to a source occurrence.
#let definition(applies-to: none, target: none) = {
  if type(applies-to) != content or type(target) != content {
    panic("definition applies-to and target must be content")
  }

  (applies-to: eval.inspect(applies-to), target: eval.inspect(target))
}

/// Attach caller-resolved reference occurrences to a source occurrence.
/// `targets` excludes declarations; the host includes `declarations` only when
/// the LSP request sets `context.includeDeclaration`. No relation is inferred.
#let references(applies-to: none, targets: (), declarations: ()) = {
  if type(applies-to) != content {
    panic("references applies-to must be content")
  }
  if type(targets) != array or type(declarations) != array {
    panic("references targets and declarations must be arrays")
  }
  if (targets + declarations).any(item => type(item) != content) {
    panic("each reference or declaration must be content")
  }

  (
    applies-to: eval.inspect(applies-to),
    targets: targets.map(eval.inspect),
    declarations: declarations.map(eval.inspect),
  )
}
