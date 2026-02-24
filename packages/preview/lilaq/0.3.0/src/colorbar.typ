#import "model/diagram.typ": diagram
#import "plot/rect.typ": rect



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