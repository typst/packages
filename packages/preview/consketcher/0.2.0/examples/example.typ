#import "@local/consketcher:0.1.0": *

= Blocks

== Single blocks

#figure(
  block-open(
    transfer: $frac(D G, 1 + H D G)$,
    input: $V$,
    output: $X$,
  ),
)

```typst
#figure(
  block-open(transfer: $frac(D G, 1 + H D G)$, input: $V$, output: $X$)
)
```

== Transfer blocks

#figure(
  block-closed(
    transfer: $D(s)G(s)$,
    transfer2: $H(s)$,
    input: $V(s)-X(s)H(s)$,
    output: $X(s)$,
    output2: $X(s)H(s)$,
    loss: "Loss",
    reference: $V(s)$,
  ),
)

```typst
#figure(
  block-closed(
    transfer: $D(s)G(s)$,
    transfer2: $H(s)$,
    input: $V(s)-X(s)H(s)$,
    output: $X(s)$,
    output2: $X(s)H(s)$,
    loss: "Loss",
    reference: $V(s)$,
  ),
)
```

= Control systems

== Open loop

#figure(
  sys-open(
    controler: "controler",
    actuator: "actuator",
    process: "process",
    input: "commanded\nsignal",
    output: "actuated\nvariable",
    output2: "manipulated\nvariable",
    output3: "controlled\nsignal",
    subunit: "plant",
  ),
)

```typst
#figure(
  sys-open(
    controler: "controler",
    actuator: "actuator",
    process: "process",
    input: "commanded\nsignal",
    output: "actuated\nvariable",
    output2: "manipulated\nvariable",
    output3: "controlled\nsignal",
    subunit: "plant",
  )
)
```

== Closed loop

#figure(
  sys-closed(
    controler: ctext("控制器"),
    actuator: ctext("执行器"),
    sensor: ctext("传感器"),
    input: ctext("指令信号"),
    output: ctext("执行信号"),
    output2: ctext("传感信号"),
    loss: ctext("损失函数"),
    reference: ctext("校正信号"),
  ),
)

```typst
#figure(
  sys-closed(
    controler: ctext("控制器"),
    actuator: ctext("执行器"),
    sensor: ctext("传感器"),
    input: ctext("指令信号"),
    output: ctext("执行信号"),
    output2: ctext("传感信号"),
    loss: ctext("误差表"),
    reference: ctext("校正信号"),
  )
)
```

= Utils

== Nodes

```typst
// rectangle node
rnode(sym, label, height: 2em)
// circle node
onode(sym, label, height: 1em)
// label node
label(sym, label)
```

== Edges

```typst
// edge with arrowhead
arrow(n1, n2, label, label-pos: 0.5, label-side: left, dashed: false, corner: none, corner-radius: none)

// edge without arrowhead
segment(n1, n2, label, label-pos: 0.5, label-side: left, dashed: false, corner: none, corner-radius: none)

// u-turned edge
uturn(n1, n2, label, label-pos: 0.15, label-side: left, marks: "-|>", height: 1.25, corner: right)

// twice u-turned edge
uturn2(n1, n2, label, label-pos: 0.15, label-side: left, marks: "-|>", height: 1.25, corner: right)

// vertical u-turned edge
uturn-v(n1, n2, label, label-pos: 0.15, label-side: left, marks: "-|>", height: 2.5, corner: right)

// vertical twice u-turned edge
uturn2-v(n1, n2, label, label-pos: 0.15, label-side: left, marks: "-|>", height: 2.5, corner: right)
```
