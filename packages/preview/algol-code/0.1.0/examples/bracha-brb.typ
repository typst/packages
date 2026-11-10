#import "@preview/algol-code:0.1.0": algol

#set page(height: auto, width: 40em, margin: 1em)
#set par(justify: true)
// math-compliant smallcaps font
#show smallcaps: set text(font: "Libertinus Serif")

#let algorithm = figure.with(kind: "algorithm", supplement: [Algorithm])
#show figure.where(kind: "algorithm"): it => grid(columns: 1,
  grid.header(grid.cell(stroke: (top: 1.5pt, bottom: 1pt), inset: (y: .5em), {
    let fig-nb = counter(figure.where(kind: "algorithm")).get().at(0)
    [*Algorithm~#fig-nb:* #it.caption.body]
  })),
  grid.footer(grid.cell(stroke: (bottom: 1.5pt), it.body)),
)

#let sn = $italic("sn")$
#let broadcast = $sans("broadcast")$
#let received = $sans("received")$
#let brbbroadcast = $sans("brb_broadcast")$
#let brbdeliver = $sans("brb_deliver")$
#let initm = smallcaps("init")
#let echom = smallcaps("echo")
#let readym = smallcaps("ready")

#algorithm(algol(box-stroke: none)[
- *operation* $brbbroadcast(v,sn)$ *is* $broadcast initm(v,sn)$.

- *when* $initm(v,sn)$ is $received$ from $p_j$ *do*
  - *if* $p_i$ has not already broadcast some $echom(star,sn,j)$ *then*
    - $broadcast echom(v,sn,j)$.

- *when* $echom(v,sn,j)$ is $received$ from strictly more than $(n+t)/2$ processes *do*
  - *if* $p_i$ has not already broadcast some $echom(star,sn,j)$ *then*
    - $broadcast$ $echom(v,sn,j)$;
  - *if* $p_i$ has not already broadcast some $readym(star,sn,j)$ *then*
    - $broadcast$ $readym(v,sn,j)$.

- *when* $readym(v,sn,j)$ is $received$ from at least $t+1$ processes *do*
  - *if* $p_i$ has not already broadcast some $readym(star,sn,j)$ *then*
    - $broadcast$ $readym(v,sn,j)$.

- *when* $readym(v,sn,j)$ is $received$ from at least $2t+1$ processes *do*
  - *if* $p_i$ has not already brb-delivered some $(star,sn,j)$ *then*
    - $brbdeliver(v,sn,j)$.
], caption: [
  Multi-shot version of Bracha's BRB ($n>3t$, code for $p_i$).
]) <alg:bracha-brb>

@alg:bracha-brb describes the multi-shot version of Bracha's Byzantine Reliable Broadcast algorithm ($n>3t$).