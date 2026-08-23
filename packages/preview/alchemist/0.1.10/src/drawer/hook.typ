
#let draw-hook(hook, ctx) = {
	if hook.name in ctx.hooks {
		panic("Hook " + hook.name + " already exists")
	}
	if ctx.last-anchor.type == "link" {
		ctx.hooks.insert(hook.name, (type: "hook", hook: ctx.last-anchor.name + "-end-anchor"))
	} else if ctx.last-anchor.type == "coord" {
		ctx.hooks.insert(hook.name, (type: "hook", hook: ctx.last-anchor.anchor))
	} else {
		panic("A hook must placed after a link or at the beginning of the skeleton")
	}
	ctx
}