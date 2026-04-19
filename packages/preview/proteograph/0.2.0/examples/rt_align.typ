#import "@preview/proteograph:0.2.0": *

#let rt_align = json("../examples/data/one_alignment.json")
#rtalign-plot(title: "Retention time drift corrections", ylim: auto, 
  ms2-delta-rt: rt_align.ms2_delta_rt,
  aligned: rt_align.aligned,
  ms2-mean: rt_align.ms2_mean,
  ms2-median: rt_align.ms2_median,
  original: rt_align.original)

