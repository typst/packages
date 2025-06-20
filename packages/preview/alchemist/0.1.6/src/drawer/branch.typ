#import "../utils/angles.typ"
#import "../utils/context.typ" as context_

/// Compute the angle the branch should take in order to be "in the center"
/// of the cycle angle
#let cycle-angle(ctx) = {
  if ctx.in-cycle {
    if ctx.faces-count == 0 {
      ctx.relative-angle - ctx.cycle-step-angle - (180deg - ctx.cycle-step-angle) / 2
    } else {
      ctx.relative-angle - (180deg - ctx.cycle-step-angle) / 2
    }
  } else {
    ctx.angle
  }
}

#let draw-branch(branch, ctx, draw-fragments-and-link) = {
	let angle = angles.angle-from-ctx(ctx, branch.args, cycle-angle(ctx))
	let (branch-ctx, drawing, cetz-rec) = draw-fragments-and-link(
		(
			..ctx,
			in-cycle: false,
			first-branch: true,
			cycle-step-angle: 0,
			angle: angle,
		),
		branch.body,
	)
	ctx = context_.update-parent-context(ctx, branch-ctx)
	(ctx, drawing, cetz-rec)
}
