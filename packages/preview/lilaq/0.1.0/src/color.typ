#import "utility.typ": match-type
#import "logic/scale.typ"
#import "logic/transform.typ": create-trafo
#import "model/diagram.typ": diagram
#import "plot/rect.typ": rect
#import "math.typ" as pmath

#let create-normalized-colors(
  values,
  colormap,
  norm,
  min: auto, 
  max: auto,
  ignore-nan: false
) = {
  if ignore-nan {
    if min == auto { min = pmath.cmin(values) }
    if max == auto { max = pmath.cmax(values) }
  } else {
    if min == auto { min = calc.min(..values) }
    if max == auto { max = calc.max(..values) }
  }
  if min == max { min -= 1; max += 1}

  let norm-fn = match-type(
    norm,
    function: norm,
    string: () => scale.scales.at(norm).transform,
    dictionary: () => {
      assert("transform" in norm, message: "The argument `norm` must be a valid scale from the `scales` module")
      norm.transform
    },
    default: () => assert(false, message: "Unsupported type `" + str(type(norm)) + "` for argument `norm`")
  )
  
  let normalize = create-trafo(norm-fn, min, max)
  assert(type(colormap) in (gradient, array), message: "Invalid type for colormap")
  if type(colormap) == array {
    colormap = gradient.linear(..colormap)
  }
  let convert-scalar-to-color(x) = {
    if float.is-nan(x) { return luma(0, 0%) }
    colormap.sample(normalize(x) * 100%)
  }
  (
    values.map(convert-scalar-to-color), 
    (norm: norm, min: min, max: max, colormap: colormap)
  )
}




#let colorbar(plot) = {
  let cinfo = plot.cinfo
  diagram(
    width: .3cm, 
    xaxis: (ticks: none), 
    yaxis: (position: right, mirror: (:)),
    grid: none,
    // ylabel: "color",
    ylim: (cinfo.min, cinfo.max),
    yscale: cinfo.norm,
    rect(0%, 0%, width: 100%, height: 100%, fill: gradient.linear(..cinfo.colormap.stops(), angle: -90deg))
  )
}