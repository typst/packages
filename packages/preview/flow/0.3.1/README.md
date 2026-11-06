# flow

A bundle of template and a few more utils, written in and for [Typst].

## Quick start

```typst
#import "@preview/flow:0.3.1": *
#show: note.with(
  title: "Super cool title!",
)

The actual body text!
```

Or just `typst init @preview/flow` which does the same!

## What's in here?

### Well, templates!

- Just typing a note and need a few defaults?
  `#show: note`, that's it!
- Need to pass something through as LaTeX
  under significant time pressure?
  `#show: template.latex-esque`
- Want something rather custom
  while still getting the other utils?
  Use `#show: template.generic` anywhere in *your* template!

### Callouts!

- `question`, `hint`, `remark` and `caution` for
  quickly communicating intent of some text!
- `axiom`, `define`, `theorem`, `propose`, `lemma` and `corollary` for
  math and structured workflows!

### Todo lists!

- Want something to be an unchecked task?
  Just make it a list entry in the form of `- [ ] thing`!
- Completed the task?
  Replace the space in the brackets with an `x`!
- In progress? Paused? Blocked? Cancelled? Unknown? Urgent?
  Just use other characters instead of `x`,
  like `>`, `:`, `-`, `/`, `?` and `!`

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

- Nodes and edges!
- Edges can be tagged, colored, stroked, branched!

## I'm sold, where do I find out more?

See the manual!
You can compile `doc/manual.typ` manually
or just download
[the last run compiled by CI](https://github.com/MultisampledNight/flow/actions/workflows/compile-docs.yaml)!

[Typst]: https://typst.app

# License

The template under `template` is under MIT-0,
everything else here is under MIT.
See [LICENSE.md](./LICENSE.md) for details.
