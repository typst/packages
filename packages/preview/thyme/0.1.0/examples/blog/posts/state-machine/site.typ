#import "@preview/thyme:0.1.0": *
#import blog: *

#show: post.with(
  slug: "state-machine",
  title: [Parity Automata & Co-Located Assets],
  subtitle: [Folder-based posts emitting directly into posts/state-machine/],
  author: "Emmy Noether",
  created: datetime(year: 2026, month: 10, day: 21),
  modified: datetime(year: 2026, month: 10, day: 26),
  summary: [Keeping vector diagrams next to their post source while emitting flat `/posts/<slug>/` bundles.],
  tags: ("automata", "assets"),
  assets: (("dfa.svg", read("dfa.svg", encoding: none)),),
)

Posts with co-located figures can live in a subfolder (`posts/state-machine/site.typ`) while still emitting cleanly to `posts/state-machine/index.html` and `posts/state-machine.typ`#sidenote[The post slug resolves automatically from the parent folder name whenever the file is named `site.typ`.].

#diagram(caption: [Two-state parity acceptor over $\{0, 1\}^*$.])[
  #image("dfa.svg", width: 240pt)
]

#proposition[Parity Invariant][
  Let $delta : Q times {0, 1} -> Q$ flip between $q_0$ and $q_1$ on symbol $1$ and stay fixed on $0$. Then $delta^*(q_0, w) = q_0$ if and only if $|w|_1 equiv 0 mod 2$.
]
