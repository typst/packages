#import "utils.typ": get_default_dict

#let begin = state("begin", false)

#let cut_blocks = state("cut_blocks", ())
#let loop_blocks = state("loop_blocks", ())

#let time_block = state("time_block", 1)
#let time = state("time", 0)

#let max_block = state("max_block", 1)
#let current_block = state("current block", 1)

#let timeline = state("timeline", (
  "builtin_pause_counter": get_default_dict(),
))
