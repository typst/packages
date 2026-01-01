#import "../../src/lib.typ": *

#let conf = config.config(
  full-page: true,
  left-labels: true
)
#let alu = schema.load("/gallery/riscv/alu_instr.yaml")
#schema.render(alu, config: conf)

#let branch = schema.load("/gallery/riscv/branch_instr.yaml")
#schema.render(branch, config: conf)

#let mem = schema.load("/gallery/riscv/mem_instr.yaml")
#schema.render(mem, config: conf)
