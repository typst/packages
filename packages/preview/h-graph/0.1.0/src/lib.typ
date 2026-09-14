#import "parser.typ": h-graph-parser
#import "render.typ": polar-render, render-help-draw-edge, tree-render

#let h-graph(code, render-fn) = {
  let res = h-graph-parser(code)
  if (type(res.at(0)) == bool) {
    return res.at(1)
  } else {
    let (nodes, edges, render_args) = res
    render-fn(
      ..render_args,
    )(nodes: nodes, edges: edges)
  }
}

#let enable-graph-in-raw(render-fn) = it => {
  h-graph(it.text, render-fn)
}


