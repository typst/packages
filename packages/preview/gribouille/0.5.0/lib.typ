// Gribouille -- Create elegant graphics with the Grammar of Graphics for Typst
// Public API for @preview/gribouille.

// Core.
#import "src/plot.typ": plot
#import "src/compose.typ": compose, defer
#import "src/aes.typ": aes
#import "src/data.typ": as-factor, as-numeric
#import "src/utils/typst-markup.typ": typst
#import "src/utils/late-binding.typ": after-scale, after-stat, from-theme, stage

// Datasets.
#import "src/datasets/economics.typ": economics
#import "src/datasets/mpg.typ": mpg
#import "src/datasets/penguins.typ": penguins

// Labels.
#import "src/labels.typ": labels

// Guides.
#import "src/guide/legend.typ": guide-legend
#import "src/guide/axis.typ": guide-axis, guide-axis-logticks
#import "src/guide/axis-stack.typ": guide-axis-stack
#import "src/guide/axis-theta.typ": guide-axis-theta
#import "src/guide/custom.typ": guide-custom
#import "src/guides.typ": guides
#import "src/guide/draw-key.typ": (
  draw-key-blank, draw-key-line, draw-key-path, draw-key-point, draw-key-rect,
)

// Geoms.
#import "src/annotate.typ": annotate
#import "src/geom/point.typ": geom-point
#import "src/geom/line.typ": geom-line
#import "src/geom/path.typ": geom-path
#import "src/geom/step.typ": geom-step
#import "src/geom/area.typ": geom-area
#import "src/geom/rect.typ": geom-rect
#import "src/geom/tile.typ": geom-tile
#import "src/geom/bin-2d.typ": geom-bin-2d
#import "src/geom/hex.typ": geom-hex
#import "src/geom/contour.typ": geom-contour
#import "src/geom/contour-filled.typ": geom-contour-filled
#import "src/geom/segment.typ": geom-segment
#import "src/geom/curve.typ": geom-curve
#import "src/geom/spoke.typ": geom-spoke
#import "src/geom/polygon.typ": geom-polygon
#import "src/geom/ellipse.typ": geom-ellipse
#import "src/geom/mark.typ": geom-mark
#import "src/geom/col.typ": geom-col
#import "src/geom/bar.typ": geom-bar
#import "src/geom/histogram.typ": geom-histogram
#import "src/geom/freqpoly.typ": geom-freqpoly
#import "src/geom/density.typ": geom-density
#import "src/geom/density-2d.typ": geom-density-2d
#import "src/geom/density-2d-filled.typ": geom-density-2d-filled
#import "src/geom/smooth.typ": geom-smooth
#import "src/geom/ribbon.typ": geom-ribbon
#import "src/geom/boxplot.typ": geom-boxplot
#import "src/geom/violin.typ": geom-violin
#import "src/geom/density-ridges.typ": geom-density-ridges
#import "src/geom/errorbar.typ": geom-errorbar
#import "src/geom/errorbarh.typ": geom-errorbarh
#import "src/geom/count.typ": geom-count
#import "src/geom/linerange.typ": geom-linerange
#import "src/geom/crossbar.typ": geom-crossbar
#import "src/geom/pointrange.typ": geom-pointrange
#import "src/geom/hline.typ": geom-hline
#import "src/geom/vline.typ": geom-vline
#import "src/geom/abline.typ": geom-abline
#import "src/geom/text.typ": geom-text
#import "src/geom/typst.typ": geom-typst
#import "src/geom/label.typ": geom-label
#import "src/geom/jitter.typ": geom-jitter
#import "src/geom/beeswarm.typ": geom-beeswarm
#import "src/geom/blank.typ": geom-blank
#import "src/geom/rug.typ": geom-rug
#import "src/geom/function.typ": geom-function
#import "src/geom/dotplot.typ": geom-dotplot
#import "src/geom/quantile.typ": geom-quantile
#import "src/geom/qq.typ": geom-qq
#import "src/geom/qq-line.typ": geom-qq-line

// Stats.
#import "src/stat/identity.typ": stat-identity
#import "src/stat/count.typ": stat-count
#import "src/stat/density.typ": stat-density
#import "src/stat/density-2d.typ": stat-density-2d
#import "src/stat/density-2d-filled.typ": stat-density-2d-filled
#import "src/stat/ydensity.typ": stat-ydensity
#import "src/stat/density-ridges.typ": stat-density-ridges
#import "src/stat/sum.typ": stat-sum
#import "src/stat/function.typ": stat-function
#import "src/stat/bin.typ": stat-bin
#import "src/stat/bin-2d.typ": stat-bin-2d
#import "src/stat/bin-hex.typ": stat-bin-hex
#import "src/stat/contour.typ": stat-contour
#import "src/stat/contour-filled.typ": stat-contour-filled
#import "src/stat/bindot.typ": stat-bindot
#import "src/stat/smooth.typ": stat-smooth
#import "src/stat/boxplot.typ": stat-boxplot
#import "src/stat/summary.typ": stat-summary
#import "src/stat/summary-bin.typ": stat-summary-bin
#import "src/stat/summary-2d.typ": stat-summary-2d
#import "src/stat/summary-hex.typ": stat-summary-hex
#import "src/stat/ecdf.typ": stat-ecdf
#import "src/stat/unique.typ": stat-unique
#import "src/stat/qq.typ": stat-qq
#import "src/stat/qq-line.typ": stat-qq-line
#import "src/stat/ellipse.typ": stat-ellipse
#import "src/stat/quantile.typ": stat-quantile
#import "src/stat/manual.typ": stat-manual
#import "src/stat/connect.typ": stat-connect
#import "src/stat/align.typ": stat-align
#import "src/stat/difference.typ": stat-difference
#import "src/stat/waffle.typ": stat-waffle

// Helpers.
#import "src/plot.typ": get-alt-text
#import "src/utils/format.typ": (
  format-comma, format-currency, format-lower, format-number, format-percent,
  format-scientific, format-title, format-upper, format-wrap,
)
#import "src/utils/summaries.typ": (
  mean, mean-cl-boot, mean-cl-normal, mean-sd, mean-se, median, median-hilow,
  quantile, quantiles, summarise,
)
#import "src/utils/cut.typ": cut-interval, cut-number, cut-width
#import "src/utils/resolution.typ": resolution
#import "src/utils/normal.typ": qnorm

// Scales.
#import "src/scales.typ": scales
#import "src/scale/constructors.typ": (
  scale-area, scale-binned, scale-binned-area, scale-brewer, scale-continuous,
  scale-date, scale-datetime, scale-discrete, scale-distiller, scale-fermenter,
  scale-gradient, scale-gradient2, scale-gradientn, scale-grey, scale-hue,
  scale-identity, scale-log10, scale-manual, scale-okabe-ito, scale-radius,
  scale-reverse, scale-sqrt, scale-steps, scale-steps2, scale-stepsn,
  scale-time, scale-viridis-b, scale-viridis-c, scale-viridis-d,
)
#import "src/scale/secondary.typ": dup-axis, sec-axis
#import "src/utils/palette.typ": brewer-palette, okabe-ito
#import "src/utils/colour.typ": colour-mix
#import "src/limits.typ": expand-limits

// Coord.
#import "src/coord/cartesian.typ": coord-cartesian
#import "src/coord/fixed.typ": coord-fixed
#import "src/coord/flip.typ": coord-flip
#import "src/coord/radial.typ": coord-radial
#import "src/coord/transform.typ": coord-transform

// Positions.
#import "src/position/stack.typ": position-stack
#import "src/position/dodge.typ": position-dodge
#import "src/position/fill.typ": position-fill
#import "src/position/identity.typ": position-identity
#import "src/position/jitter.typ": position-jitter
#import "src/position/jitterdodge.typ": position-jitterdodge
#import "src/position/beeswarm.typ": position-beeswarm
#import "src/position/nudge.typ": position-nudge

// Facets.
#import "src/facet/wrap.typ": facet-wrap
#import "src/facet/grid.typ": facet-grid
#import "src/facet/labellers.typ": (
  label-both, label-context, label-value, label-wrap, labeller,
)

// Themes.
#import "src/theme/grey.typ": theme-grey
#import "src/theme/minimal.typ": theme-minimal
#import "src/theme/classic.typ": theme-classic
#import "src/theme/void.typ": theme-void
#import "src/theme/bw.typ": theme-bw
#import "src/theme/linedraw.typ": theme-linedraw
#import "src/theme/light.typ": theme-light
#import "src/theme/dark.typ": theme-dark
#import "src/theme/theme.typ": theme
#import "src/theme/elements.typ": (
  element-blank, element-geom, element-line, element-rect, element-text,
  element-typst, margin,
)
#import "src/theme/sub.typ": (
  theme-sub-axis, theme-sub-axis-bottom, theme-sub-axis-left,
  theme-sub-axis-right, theme-sub-axis-top, theme-sub-axis-x, theme-sub-axis-y,
  theme-sub-legend, theme-sub-panel, theme-sub-plot, theme-sub-strip,
)
#import "src/theme/current.typ": theme-get, theme-set
