#import "@preview/lilaq:0.4.0" as lq

#let rtalign-diagram = it => {
  show: lq.set-diagram(
        xlabel: [Retention time (s)],
        ylabel: [#sym.Delta rt],
    xaxis: (mirror: none, auto-exponent-threshold : 5),
    yaxis: (mirror: none, tick-args: (density: 50%)),
  )
  it
}

/// retention time delta plot between MS runs plot.
/// -> content
#let rtalign-plot(

  /// The width of the diagram. This can be
  /// - A `length`; in this case, it defines just the width of the data area,
  ///   excluding axes, labels, title etc.
  /// - A `ratio` or `relative` where the ratio part is relative to the width 
  ///   of the parent that the diagram is placed in. This is not allowed if the
  ///   parent has an unbounded width, e.g., a page with `width: auto`.  
  /// -> length | relative
  width: 15cm,
  
  /// The height of the diagram. This can be
  /// - A `length`; in this case, it defines just the height of the data area,
  ///   excluding axes, labels, title etc.
  /// - A `ratio` or `relative` where the ratio part is relative to the height 
  ///   of the parent that the diagram is placed in. This is not allowed if the
  ///   parent has an unbounded height, e.g., a page with `height: auto`.  
  /// -> length | relative
  height: 10cm,
  
  /// Data limits along the x-axis (retention time in seconds). Expects auto or a tuple (min, max) where min and max may individually be auto
  /// -> auto | array
  xlim: auto,
  
  /// Data limits along the y-axis (retention time delta in seconds). Expects auto or a tuple (min, max) where min and max may individually be auto
  /// -> auto | array
  ylim: (-40,40),
  title: none,
  original: array,
  aligned: array,
  ms2-delta-rt: none,
  ms2-mean: none,
  ms2-median: none
) = {
  let rt_diff = ()
  let i=0
  for rt in aligned {
    rt_diff.push(original.at(i) - rt)
    i=i+1
  }
  
  show: rtalign-diagram
  
  //let ms2_mark = lq.mark(size:4pt,stroke:0.7pt, shape:".")
  
  
    lq.diagram(
        width: width,
        height: height,
        ylim: ylim,
        xlim: xlim,
        title: title,
        ..if (ms2-delta-rt != none) {(
          lq.scatter(ms2-delta-rt.x, ms2-delta-rt.y, color: rgb("#0074d9").transparentize(90%), stroke: 1pt, mark: ".", label: [MS2 in common]),
          if (ms2-median != none) {lq.plot(ms2-delta-rt.x,ms2-median, mark: none, label: [MS2 median], color: aqua)},
          if (ms2-mean != none) {lq.plot(ms2-delta-rt.x,ms2-mean, mark: none, label: [MS2 mean], color: eastern)},
        ).flatten()},
        lq.plot(original,rt_diff, mark: none, label: [rt aligned], color: red)
    )
}


#let mcq3-alignment-summary(
  mcq3-json
) = {
//    "identification_data": {
//        "msrun_list": {
//           "msruna1": {
//                "file": "/gorgone/pappso/moulon/raw/20250521_proteobench_dda_ast
// ral/LFQ_Astral_DDA_15min_50ng_Condition_A_REP1.mzML"
//            },

  let msrun_list = mcq3-json.identification_data.msrun_list
  
  let msrun_ref = mcq3-json.alignment_data.first().alignment.msrun_ref
  
  let msrun_ref_file = msrun_list.at(mcq3-json.alignment_data.first().alignment.msrun_ref).file
  
  [msrun reference for alignment is #msrun_ref (#msrun_ref_file)]
//      "alignment_data": [
//        {
//            "alignment": {
//                "corrections": {
  
  
  
  (mcq3-json.alignment_data.first().alignment.corrections.pairs().map(((msrun, msrun_item)) => {
      heading(level: 1)[#msrun vs #msrun_ref]
      [
        #msrun data file path : #msrun_list.at(msrun).file
      
        #msrun_item.ms2_delta_rt.x.len() MS2 events in common between #msrun and #msrun_ref
      ]
      
      
      rtalign-plot(title: [#msrun vs #msrun_ref], ylim: (-40,40),  
  ms2-delta-rt: msrun_item.ms2_delta_rt,
  aligned: msrun_item.aligned,
  ms2-mean: msrun_item.ms2_mean,
  ms2-median: msrun_item.ms2_median,
  original: msrun_item.original)
     
  }).join(pagebreak()))
}

