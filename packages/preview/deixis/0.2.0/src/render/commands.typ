// Private drawing units. Preparing a command never invokes its live painter.
// The ordinal preserves adapter/batch insertion order for equal priorities.
#let _deixis-paint-command(kind, identity, paint, members: (), priority: 0, offset: (0pt, 0pt)) = (
  kind: kind, identity: identity, members: members, priority: priority, paint: paint, offset: offset,
)

#let _deixis-order-paint-commands(commands) = {
  commands.enumerate().map(((i, command)) => command + (ordinal: i,))
    .sorted(key: command => (command.priority, command.ordinal))
}

#let _deixis-emit-paint-commands(commands, deferred: true, priority: auto) = {
  let selected = commands.filter(c => priority == auto or c.priority == priority)
  for command in _deixis-order-paint-commands(selected) {
    // Independent bands get stable native contexts. Inside a band (or direct
    // layout), reuse its context: another boundary can delay geometry a pass.
    // Apply numeric offsets outside lazy content so placement stays explicit.
    // Ordering/offset changes must not become part of a band's native context
    // identity. Its explicit identity already includes the selected priority.
    let invocation = (kind: command.kind, identity: command.identity, paint: command.paint)
    let body = if deferred { context (invocation.paint)() } else { (invocation.paint)() }
    place(top + left, dx: command.offset.at(0), dy: command.offset.at(1), body)
  }
}
