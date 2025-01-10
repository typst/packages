#import "../src/lib.typ" as flow: *
#let accent = ("root", "vertex", "yield", "edge").zip(
  duality.values().slice(2)
)
#let steps = gradient-map(
  ("initialize", "gather", "extract", "condense", "refine"),
  (duality.orange, duality.yellow, duality.green),
)
#let bold = ("source", "target", "incoming", "outgoing").map(name => (name, strong))
#show: note.with(
  title: "Multi's workflow",
  author: "MultisampledNight",
  keywords: (accent + bold).to-dict() + steps,
)

This is tuned to my needs.
Chances are you want something else.
Feel free to take what seems useful
and change or leave what you don't find so.

= Idea

The flow of information in my knowledge
can be represented as
#fxfirst("Directed Graph").
Its components have the following meanings:

/ Vertex:
  A codification of information.
  - Examples: Note, reference, manual, webpage, video, verbal communication

  / Root:
    A vertex without incoming edges.
    Where information originally stems from.

  / Yield:
    A vertex without outgoing edges.
    Final product that can be given to others and
    presented to a wider audience without worries.

  / Source:
    A vertex $a$ which has an outgoing edge
    which is also an incoming edge of a given vertex $b$.

  / Target:
    The given vertex $b$ in the definition of source.

/ Edge:
  A vertex influencing another vertex directly and significantly.
  - Generally the vertices that one is viewing while modifying a vertex.
  - There's a lot of subjective leeway here on what is "influence".

This allows gamification:
Given a set of roots,
find the smallest and easiest comprehensible yield
without sacrificing too much on accuracy.

As a side effect, if one isn't happy with the current yield,
one is never bound to it.
Either the yield itself can be modified,
or a new yield can be created with the current yield as basis.

= Application

The general high-level algorithm I use this with is the following:

+ *Initialize* via a spark that piques interest in a topic.
  - Sometimes it's a cool talk on https://media.ccc.de.
  - Sometimes it's a friend telling a story.
  - Sometimes it's having to look into a complicated problem.
+ *Gather* external resources to use as roots.
+ *Extract* relevant information out of the roots into new vertices.
+ *Condense* existing vertices into new vertices.
  - Note that _all_ vertices can be used as sources.
+ *Refine* until a satisfying yield is reached.
  - By condensing ever further.
  - Possibly also gathering and extracting new roots if needed.

In an ideal world,
one would would have infinitely much time for every step.
Realistically though,
one will need to weigh off time investments.

For example,
if it's known one has a presentation of a paper at some point,
then the presentation and paper should both be yields, ideally.
Things never go clean though
— so it's okay if it doesn't work out.

The theoretical model is nice and all,
but most of the time I actually don't have it in my mind.
Instead, at the bottom of a note
is usually a section `References` or `Resources`
where I put all links, talks and notes this is an effect of into
without thinking too much of them as roots.
