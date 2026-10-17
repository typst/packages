#import "@preview/numera:0.1.0": numera, subfigure-counter-dependent

#set page(width: 18cm, height: auto, margin: 1cm)
#show: numera()
#show figure.where(kind: "subfigure"): set figure(
  supplement: [Panel],
  numbering: subfigure-counter-dependent("1a"),
)

// The parent's supplement must not override the subfigure's configured one.
#figure(
  [
    #figure(
      [Default panel],
      caption: [Configured supplement],
      kind: "subfigure",
    ) <panel>
    #figure(
      [Custom panel],
      caption: [Explicit supplement],
      kind: "subfigure",
      supplement: [Detail],
    ) <detail>
    #figure(
      [Bare panel],
      caption: [No supplement],
      kind: "subfigure",
      supplement: none,
    ) <bare>
  ],
  caption: [Image parent],
  supplement: [Illustration],
) <image-parent>

@panel; @detail; @bare; @image-parent.

// A different normal figure kind also resets the subfigure counter.
#figure(
  [#figure(
    [Table panel],
    caption: [Counter restarts],
    kind: "subfigure",
  ) <table-panel>],
  kind: table,
  supplement: [Table],
  caption: [Table parent],
) <table-parent>

@table-panel; @table-parent.

#context {
  assert(query(<panel>).first().supplement == [Panel])
  assert(query(<detail>).first().supplement == [Detail])
  assert(query(<bare>).first().supplement == none)
  assert(query(<table-panel>).first().supplement == [Panel])
  assert(
    counter(figure.where(kind: "subfigure")).at(
      query(<table-panel>).first().location(),
    )
      == (1,),
  )
}
