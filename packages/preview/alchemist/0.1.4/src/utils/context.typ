#let update-parent-context(parent-ctx, ctx) = {
  let last-anchor = if parent-ctx.last-anchor != ctx.last-anchor {
    (
      ..parent-ctx.last-anchor,
      drew: true,
    )
  } else {
    parent-ctx.last-anchor
  }
  (
    ..parent-ctx,
    last-anchor: last-anchor,
    hooks: ctx.hooks,
    hooks-links: ctx.hooks-links,
    links: ctx.links,
    group-id: ctx.group-id,
    link-id: ctx.link-id,
  )
}

/// Set the last anchor in the context to the given anchor and save it if needed
#let set-last-anchor(ctx, anchor) = {
  if ctx.last-anchor.type == "link" {
		let drew = ctx.last-anchor.at("drew", default: false)
		if drew and anchor.type == "link" and anchor.name == ctx.last-anchor.name {
			drew = false
			let _ = ctx.links.pop()
		}
		if not drew {
    	ctx.links.push(ctx.last-anchor)
		}
		ctx.last-anchor.drew = true
  }
  (..ctx, last-anchor: anchor)
}
