#import "@submit/presentate:0.2.0": *

#import "@preview/cetz:0.4.1": canvas, draw
#import "@preview/fletcher:0.5.8": diagram, edge, node

#set page(paper: "presentation-16-9")
#set text(size: 25pt)

#slide[
  = CeTZ integration
  #render(s => ({
      import animation: *
      let (pause,) = settings(hider: draw.hide.with(bounds: true))
      canvas({
        import draw: *
        pause(s, circle((0, 0), fill: green))
        s.push(auto) // update s
        pause(s, circle((1, 0), fill: red))
      })
    },s)
  )
]

#slide[
  = Fletcher integration
  #render(s => ({
    import animation: *
    diagram($
        pause(#s, A edge(->)) #s.push(auto)
          & pause(#s, B edge(->)) #s.push(auto)
            pause(#s, edge(->, "d") & C) \
          & pause(#s, D)
    $,)
  }, s,))
]

