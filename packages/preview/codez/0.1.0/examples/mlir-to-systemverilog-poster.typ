#import "@preview/cetz:0.3.4"
#import "@preview/codez:0.1.0": mark as codez-mark, parse as codez-parse, cetz-block as codez-cetz-block

#set page(width: 26cm, height: 11.5cm, margin: 8pt)

#set raw(
  theme: "../syntaxes/codez-light.tmTheme",
  syntaxes: ("../syntaxes/mlir.sublime-syntax",),
)

#let uni-dark-blue = rgb("#1d154d")
#let anno-bbox-stroke = 1.6pt + rgb("#3b82f6")

#let codez-block(..args) = codez-cetz-block(
  stroke: 1pt + uni-dark-blue,
  mark-inset: (x: 4pt, y: 2pt),
  badge-tag-fill: uni-dark-blue,
  badge-tag-text: white,
  badge-lang-fill: rgb("#f7f7f2"),
  badge-lang-text: uni-dark-blue,
  badge-stroke: 1pt + uni-dark-blue,
  badge-radius: 7pt,
  badge-size: 18pt,
  badge-offset: (8pt, 0pt),
  badge-anchor: "south-west",
  badge-pad-x: 8pt,
  badge-pad-y: 7pt,
  ..args,
)

#let comb-lines = (
  "module {",
  "  hw.module @forward(in %arg0 : !hw.array<16xi32>, in %arg1 : !hw.array<16xi32>, in %clk : !seq.clock, in %reset : i1, out arg1_out : !hw.array<16xi32>) {",
  "    ...",
  "    %111 = comb.extract %local_mem_2_rdata from 31 : (i32) -> i1",
  "    %112 = comb.extract %local_mem_3_rdata from 31 : (i32) -> i1",
  "    %113 = comb.xor %111, %112 : i1",
  "    %114 = comb.extract %local_mem_2_rdata from 23 : (i32) -> i8",
  "    %115 = comb.extract %local_mem_3_rdata from 23 : (i32) -> i8",
  "    %118 = comb.concat %c1_i25, %116 : i25, i23",
  "    %120 = comb.mul %118, %119 : i48",
  "    %123 = comb.add %114, %115, %122, %c-127_i8 : i8",
  "    ...",
  "  }",
  "}",
)

#let sv-lines = (
  "module forward(",
  "  input  [15:0][31:0] arg0,",
  "                      arg1,",
  "  input               clk,",
  "                      reset,",
  "  output [15:0][31:0] arg1_out",
  ");",
  "  wire [511:0] _GEN_57 = arg0;",
  "  reg  [31:0]  arg1_mem[0:15];",
  "  always_ff @(posedge clk) begin",
  "    if (!reset) begin",
  "      if (_GEN_5) arg1_mem[_GEN_1] <= _GEN_0;",
  "      if (_GEN_9) arg1_mem[_GEN_6] <= 32'h0;",
  "    end",
  "  end",
  "  ...",
  "endmodule",
)

#let comb = codez-parse(comb-lines.join("\n"))
#let sv = codez-parse(sv-lines.join("\n"))

#let comb-mul = codez-mark("comb_mul", start: 10, end: 10, trim-left: true)
#let comb-add = codez-mark("comb_add", start: 11, end: 11, trim-left: true)
#let sv-always = codez-mark("sv_always", start: 10, end: 15, trim-left: true)

#let w = 440pt

// Page 1: MLIR comb mul focus.
#cetz.canvas(length: 1pt, {
  import cetz.draw: *
  codez-block(
    name: "comb",
    at: (0, 0),
    width: w,
    code: comb.code,
    wrap: true,
    lang: "mlir",
    badge-tag: "F",
    badge-lang: "MLIR",
    text-size: 13pt,
    line-gap: 5pt,
    marks: (comb-mul, comb-add),
    inline-marks: false,
    mark-stroke: none,
  )
  rect("comb.comb_mul.north-west", "comb.comb_mul.south-east", stroke: anno-bbox-stroke, radius: 2pt)
  content(
    (rel: (12pt, 0pt), to: "comb.comb_mul.east"),
    text("48-bit multiplication", size: 12pt, weight: "bold", fill: uni-dark-blue),
    anchor: "west",
  )
})

#pagebreak()

// Page 2: MLIR comb add focus.
#cetz.canvas(length: 1pt, {
  import cetz.draw: *
  codez-block(
    name: "comb",
    at: (0, 0),
    width: w,
    code: comb.code,
    wrap: true,
    lang: "mlir",
    badge-tag: "F",
    badge-lang: "MLIR",
    text-size: 13pt,
    line-gap: 5pt,
    marks: (comb-mul, comb-add),
    inline-marks: false,
    mark-stroke: none,
  )
  rect("comb.comb_add.north-west", "comb.comb_add.south-east", stroke: anno-bbox-stroke, radius: 2pt)
  content(
    (rel: (12pt, 0pt), to: "comb.comb_add.east"),
    text("Post-matmul add path", size: 12pt, weight: "bold", fill: uni-dark-blue),
    anchor: "west",
  )
})

#pagebreak()

// Page 3: exported SystemVerilog sequential region.
#cetz.canvas(length: 1pt, {
  import cetz.draw: *
  codez-block(
    name: "sv",
    at: (0, 0),
    width: w,
    code: sv.code,
    wrap: true,
    lang: "verilog",
    badge-tag: "G",
    badge-lang: "SystemVerilog",
    text-size: 13pt,
    line-gap: 5pt,
    marks: (sv-always,),
    inline-marks: false,
    mark-stroke: none,
  )
  rect("sv.sv_always.north-west", "sv.sv_always.south-east", stroke: anno-bbox-stroke, radius: 2pt)
})
