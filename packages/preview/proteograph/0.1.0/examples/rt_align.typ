#import "@local/proteograph:0.0.1": *

#let rt_align = json("../examples/data/one_alignment.json")
#rtalign-plot(title: "Whatever", ylim: (-40,40), 
  ms2_delta_rt: rt_align.ms2_delta_rt,
  aligned: rt_align.aligned,
  ms2_mean: rt_align.ms2_mean,
  ms2_median: rt_align.ms2_median,
  original: rt_align.original)

