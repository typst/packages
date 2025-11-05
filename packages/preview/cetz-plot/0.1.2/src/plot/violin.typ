#import "/src/cetz.typ": draw
#import "util.typ"
#import "sample.typ"

#let kernel-normal(x, stdev: 1.5) = {
  (1 / calc.sqrt(2 * calc.pi*calc.pow(stdev, 2))) * calc.exp(-(x*x) / (2 * calc.pow(stdev, 2)))
}

#let _violin-render(self, ctx, violin, filling: true) = {
  let path = range(self.samples)
    .map((t)=>violin.min + (violin.max - violin.min) * (t / self.samples ))
    .map((u)=>(u, (violin.convolve)(u)))
    .map(((u,v)) => {
      (violin.x-position + v, u)
    })

  if self.side == "both"{ 
    path += path.rev().map(((x,y))=> {(2 * violin.x-position - x,y)})
  } else if self.side == "left"{
    path = path.map(((x,y)) => (2 * violin.x-position - x,y))
  }

  let stroke-paths = util.compute-stroke-paths(path, ctx.x, ctx.y)

  for p in stroke-paths{
    let args = arguments(..p, closed: self.side == "both")
    if filling {
      args = arguments(..args, stroke: none)
    } else {
      args = arguments(..args, fill: none)
    }
    draw.line(..self.style, ..args)
  }
}

#let _plot-prepare(self, ctx) = {
  self.violins = self.data.map(entry=> {
    let points = entry.at(self.y-key)
    let (min, max) = (calc.min(..points), calc.max(..points))
    let range = calc.abs(max - min)
    (
      x-position: entry.at(self.x-key),
      points: points,
      length: points.len(),
      min: min - (self.extents * range),
      max: max + (self.extents * range),
      convolve: (t) => {
        points.map(y => (self.kernel)((y - t) / self.bandwidth)).sum() / (points.len() * self.bandwidth)
      }
    )
  })
  return self
}

#let _plot-stroke(self, ctx) = { 
  for violin in self.violins {
    _violin-render(self, ctx, violin, filling: false)
  }
}

#let _plot-fill(self, ctx) = { 
  for violin in self.violins {
    _violin-render(self, ctx, violin, filling: true)
  }
}

#let _plot-legend-preview(self) = {
  draw.rect((0,0), (1,1), ..self.style)
}


/// Add a violin plot
///
/// A violin plot is a chart that can be used to compare the distribution of continuous
/// data between categories.
///
/// - data (array): Array of data items. An item is an array containing an `x` and one 
///                 or more `y` values.
/// - x-key (int, string): Key to use for retrieving the `x` position of the violin.
/// - y-key (int, string): Key to use for retrieving values of points within the category.
/// - side (string): The sides of the violin to be rendered:
///   / left: Plot only the left side of the violin.
///   / right: Plot only the right side of the violin.
///   / both: Plot both sides of the violin.
/// - kernel (function): The kernel density estimator function, which takes a single
///                      `x` value relative to the center of a distribution (0) and
///                      normalized by the bandwidth
/// - bandwidth (float): The smoothing parameter of the kernel.
/// - extents (float): The extension of the domain, expressed as a fraction of spread.
/// - samples (int): The number of samples of the kernel to render.
/// - style (dictionary): Style override dictionary.
/// - mark-style (dictionary): (unused, will eventually be used to render interquartile ranges).
/// - axes (axes): (unstable, documentation to follow once completed).
/// - label (none, content): The name of the category to be shown in the legend.
#let add-violin( 
  data,
  x-key: 0,
  y-key: 1,
  side: "right",
  kernel: kernel-normal.with(stdev: 1.5),
  bandwidth: 1,
  extents: 0.25,

  samples: 50,
  style: (:),
  mark-style: (:),
  axes: ("x", "y"),
  label: none,
) = {

  ((
    type: "violins",

    data: data,
    x-key: x-key,
    y-key: y-key,
    side: side,
    kernel: kernel,
    bandwidth: bandwidth,
    extents: extents,

    samples: samples,
    style: style,
    mark-style: mark-style,
    axes: axes,
    label: label,

    plot-prepare: _plot-prepare,
    plot-stroke: _plot-stroke,
    plot-fill: _plot-fill,
    plot-legend-preview: _plot-legend-preview,
  ),)

}
