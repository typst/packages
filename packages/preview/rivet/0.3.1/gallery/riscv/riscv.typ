#import "@preview/rivet:0.3.1": *

#let conf = config.config(
  full-page: true,
  left-labels: true
)
#let alu = schema.load(yaml("./alu_instr.yaml"))
#schema.render(alu, config: conf)

#let branch = schema.load(yaml("./branch_instr.yaml"))
#schema.render(branch, config: conf)

#let mem = schema.load(yaml("./mem_instr.yaml"))
#schema.render(mem, config: conf)
