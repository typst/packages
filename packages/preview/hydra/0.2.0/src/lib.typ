#import "/src/core.typ"
#import "/src/util.typ"

#let hydra-anchor() = [#metadata(()) <hydra-anchor>]

#let hydra(
  sel: heading,
  prev-filter: (_, _, _) => true,
  next-filter: (_, _, _) => true,
  display: core.display,
  fallback-next: false,
  paper: "a4",
  page-size: auto,
  top-margin: auto,
  loc: none,
) = {
  let (sel, filter) = util.into-sel-filter-pair(sel)

  assert((paper, page-size, top-margin).filter(x => x != auto).len() >= 1,
    message: "Must set one of (`paper`, `page-size` or `top-margin`)",
  )

  if top-margin == auto {
    if page-size == auto {
      page-size = util.page-sizes.at(paper, default: none)
      assert.ne(page-size, none, message: util.oxi.strfmt("Unknown paper: `{}`", paper))
      page-size = page-size.values().fold(10000mm, calc.min)
    }

    top-margin = (2.5 / 21) * page-size
  }

  

  let func = loc => {
    let ctx = (
      top-margin: top-margin,
      loc: loc,
    )

    let (last, next, loc) = core.get-adjacent-from(ctx, sel, filter)
    ctx.loc = loc

    let last-eligible = last != none and prev-filter(ctx, last, next)
    let next-eligible = next != none and next-filter(ctx, last, next)
    let last-redundant = next-eligible and ctx.top-margin != none and core.is-redundant(ctx, next)

    if last-eligible and not last-redundant {
      display(ctx, last)
    } else if fallback-next and next-eligible {
      display(ctx, next)
    }
  }

  if type(loc) == location {
    func(loc)
  } else {
    locate(func)
  }
}
