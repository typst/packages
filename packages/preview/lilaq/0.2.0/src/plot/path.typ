#import "../assertations.typ"
#import "../logic/limits.typ": compute-primitive-limits
#import "../logic/process-coordinates.typ": convert-bezier-curve, transform-point
#import "../math.typ": vec
#import "@preview/tiptoe:0.3.0"




#let path-to-curve(
  ..vertices,
  closed: false
) = {
  vertices = vertices.pos()
  if vertices.len() == 0 { return }

  let is-vertex(v) = type(v) == array and type(v.first()) != array
  let extract-vertex(v) = {
    if is-vertex(v) { v }
    else { v.first() }
  }
  
  let curve-elements = ()
  let start-in = none
  let out = none
  for vertex in vertices {
    let v = extract-vertex(vertex)
    
    if is-vertex(vertex) {
      if out == none {
        curve-elements.push((v,))
      } else {
        curve-elements.push((out, none, v))
        out = none
      }
    } else {
      if vertex.len() == 2 {
        vertex.push(vec.multiply(vertex.at(1), -1))
        // now its definitely a "cubic"!
      }
      if curve-elements.len() == 0 {
        curve-elements.push((v,))
        start-in = vec.add(v, vertex.at(1))
      } else if out == none {
        curve-elements.push((auto, vec.add(v, vertex.at(1)), v))
        out = auto
      } else {
        curve-elements.push((out, vec.add(v, vertex.at(1)), v))
      }
      out = vec.add(v, vertex.at(2))
    }
  }

  let to-curve-element(x) = {
    if x.len() == 1 { curve.line(..x) }
    else if x.len() == 2 { curve.quad(..x) }
    else if x.len() == 3 { curve.cubic(..x) }
  }
  curve-elements = curve-elements.map(to-curve-element)
  let start = extract-vertex(vertices.first())
  if closed {
    if out != none or start-in != none {
      curve-elements.push(curve.cubic(out, start-in, start))
    }
    curve-elements.push(curve.close(mode: "straight"))
  }
  
  (
    curve.move(start),
    ..curve-elements,
  )
}


/// Draws a path into the data area. Each vertex may be given as data coordinates, 
/// as percentage relative to the data area or in absolute lengths (see @rect). 
///
/// ```example
/// #lq.diagram(
///   height: 3.8cm,
///   width: 4cm, 
///   lq.path(
///     ((0, 1), (0, -1)),
///     ((.5, 1), (0, 1)),
///     ((0,-1), (0, 1), (0, 1)),
///     ((-.5, 1), (0, -1)),
///     ((0, 1), (0, 1)),
///     stroke: red + 2pt
///   )
/// )
/// ```
/// 
#let path(

  /// Vertices and curve elements. See the Typst built-in `path` function. 
  /// -> array
  ..vertices,

  /// How to fill the path.  
  /// -> none | color | gradient | tiling
  fill: none,

  /// How to stroke the path.
  /// -> auto | none | stroke
  stroke: auto,

  /// Whether to close the path. 
  /// -> bool
  closed: false,

  /// Places an arrow tip on the curve. This expects a mark as specified by
  /// the #link("https://typst.app/universe/package/tiptoe")[tiptoe package]. 
  /// -> none | tiptoe.mark
  tip: none,
  
  /// Places an arrow tail on the curve. This expects a mark as specified by 
  /// the #link("https://typst.app/universe/package/tiptoe")[tiptoe package]. 
  /// -> none | tiptoe.mark
  toe: none,

  /// The legend label for this plot. See @plot.label. 
  /// -> content
  label: none,

  /// Whether to clip the plot to the data area. See @plot.clip. 
  /// -> bool
  clip: true,
  
  /// Determines the $z$ position of this plot in the order of rendered diagram objects. 
  /// See @plot.z-index.  
  /// -> int | float
  z-index: 2,

) = {
  assertations.assert-no-named(vertices, fn: "path")

  let sub(p, q) = (p.at(0) - q.at(0), p.at(1) - q.at(1))
  let add(p, q) = (p.at(0) + q.at(0), p.at(1) + q.at(1))

  vertices = vertices.pos()
  let all-points = vertices.enumerate().map(((i, v)) => {
    if type(v.at(0)) != array { return (v,) }
    if v.len() == 3 { 
      return (v.at(0),) + v.slice(1).map(c => {
         if not c.map(type).all(x => x in (int, float)) { return v.at(0) }
        add(v.at(0), c)
      }) 
    } 
    let vs = (v.at(0),)
    if i != 0 and v.at(1).map(type).all(x => x in (int, float)){
      vs.push(add(v.at(0), v.at(1)))
    }
    if i != vertices.len() - 1 {
      // vs.push(sub(v.at(0), v.at(1)))
    }
    return vs
  }).join()
  // vertices = all-points  
  // let all-points = vertices
  (
    vertices: vertices,
    plot: (plot, transform) => { 
      if "make-legend" in plot {
        return std.rect(
          width: 100%, height: 100%, 
          fill: fill, stroke: stroke
        )
      }

      let new-vertices = vertices.map(v => {
        if type(v.at(0)) != array { return transform-point(..v, transform) }
        return convert-bezier-curve(v, transform)
        let p = transform-point(..v.at(0), transform)
        let cs = v.slice(1).map(c => {
          let cabs = add(v.at(0), c)
          let cabs = c
          sub(transform-point(..cabs, transform), p)
        })
        (p,) + cs
      })
      let segments = path-to-curve(
        closed: closed,
        ..new-vertices
      )
      let curve = std.curve
      if tip != none or toe != none {
        curve = tiptoe.curve.with(tip: tip, toe: toe)
      }

      place(
        curve(
          ..segments, 
          fill: fill, stroke: stroke, 
        )
      )
    },
    xlimits: compute-primitive-limits.with(all-points.map(x => x.at(0))),
    ylimits: compute-primitive-limits.with(all-points.map(x => x.at(1))),
    label: label,
    legend: true,
    clip: clip,
    z-index: z-index
  )
}
