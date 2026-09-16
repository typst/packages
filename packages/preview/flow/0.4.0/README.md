# flow

Want to use [Typst], but the default look is a bit too, well, default for you?
Don't want to think too much about where to put what and
instead just start typing?
Well then, flow might just be the right template for you!

## Quick start

```typst
#import "@preview/flow:0.4.0": *
#show: note.with(
  title: "Super cool title!",
)

The actual body text!
```

Or just `typst init @preview/flow` which does the same!

## What's in here?

A set of utils for actual application.
While there's many amazing libraries for Typst,
such as [cetz], [cetz-plot] or [whalogen],
often they're *too* flexible for just getting things down.

Flow aims to fill that missing spot between
flexible unlimited libraries and ad-hoc application.
It offers a set of explicitly biased defaults and
different fields, but doesn't force them:
Anyone can add or change them as-needed.

So, get ready for a quick tour on what's offered!

[cetz]: https://typst.app/universe/package/cetz
[cetz-plot]: https://typst.app/universe/package/cetz-plot
[whalogen]: https://typst.app/universe/package/whalogen

### Notes

- Just typing some text and want some metadata, outline, formatting and todo lists?
  `#show: note`, that's it!
- Need to pass something through as LaTeX
  under significant time pressure?
  `#show: template.latex-esque`
- Want something rather custom
  while still getting the other utils?
  Use `#show: template.generic` anywhere in *your* template!

### Callouts!

They're functions that accept content,
e.g.:

```typst
#question[
  Chicken/chicken. Chicken?
  (https://isotropic.org/papers/chicken.pdf)
]
```

- `question`, `hint`, `remark`, `urgent` and `complete` for
  quickly communicating intent of some text!
- `axiom`, `define`, `theorem`, `propose`, `lemma` and `corollary` for
  math and structured workflows!

### Todo lists!

```typst
= Shopping list

- [ ] Still to do
- [>] Currently doing this
- [:] Some paused item
- [/] Aww this has been cancelled
- [?] Not sure what to do
- [!] *Really* need to do this
```

- Want something to be an unchecked task?
  Just make it a list entry in the form of `- [ ] thing`!
- Completed the task?
  Replace the space in the brackets with an `x`!
- In progress? Paused? Idle? Cancelled? Questioned? Urgent?
  Just use other characters instead of `x`,
  like `>`, `:`, `-`, `/`, `?` and `!`

### Field-specific presets!

- Typing a lot of math? Check out `preset.math`
  (mostly just linear algebra for now)!
  - Bored of `abs`, `bold`, `norm`, `arrow`, `tilde`
    being too long to type?
    Common math characters are double-defined
    to have common shortcuts!
    - Bold x?
      `xb`
    - Vector c?
      `cv`
    - Conjugate transposed M?
      `MH`
    - Absolute value of vector p?
      `pva`
  - Null vector?
    `null`
  - Plane defined via 3 points?
    `plp(a, b, c)`
  - Want to quickly throw a function plot in?
    `plot(x => pow(x, 2))`
  - `integral_(-oo)^oo` is too long?
    `iinf`
  - Sum with index k starting at 1 ending at n?
    `sk1n` or even just `sk1n`
  - Limit of k towards infinity?
    `limk(oo)`

### Themes!

- Controlled via the command-line inputs
  rather than the file you're writing!
- Pass `--input theme=duality` (or set `theme` to `duality` in your UI's inputs)
  for a nicer dark mode theme!
- In the file, use
  - `bg` for the background color!
  - `fg` for the foreground color!
  - `gamut.sample(n%)` to select `n` percent
    between background and foreground!

### Metadata!

- Pass any extra arguments you want available to your template of choice!
- Some templates like e.g. `note` render them before the main content!
  - Some metadata like `cw` even highlights specially!
- If you just want to get the metadata out of a file
  without anything else,
  you can use `typst query --input render=false`
  which take on the text and
  is far faster!

### Diagrams!

- Want to render a directed graph? Use `gfx.diagram`!
  - Pass
    - a dictionary as a keyword argument to `nodes`,
      keyed by name and position as value
    - a dictionary to `edges`,
      keyed by source and target as string
      - the target can also be several (`all("a", "b", "c")`)
        or in a row (`seq("a", "b", "c")`)!
  - Edges can be tagged, colored, stroked, branched!
    - E.g. `tag("a", tag: [hi!])`,
      `styled("a", stroke: blue)`,
      `br(br("a", "b"), "c")`

## Where do I find out more?

See [the manual](https://codeberg.org/MultisampledNight/flow/src/tag/v0.4.0/doc/manual.pdf)!

[Typst]: https://typst.app

