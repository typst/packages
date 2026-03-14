#import "@preview/cetz:0.3.4"
#import "../lib.typ": mark as codez-mark, parse as codez-parse, cetz-block as codez-cetz-block

#set page(width: 29.7cm, height: 16.7cm, margin: 10pt)

#set raw(
  theme: "../syntaxes/codez-light.tmTheme",
  syntaxes: ("../syntaxes/mlir.sublime-syntax",),
)

#let anno-color = rgb("#4a0f2f")
#let anno-bbox-stroke = 1.6pt + rgb("#7a1f44")
#let code-block-stroke = 1pt + anno-color

#let codez-block(..args) = codez-cetz-block(
  stroke: code-block-stroke,
  mark-inset: (x: 4pt, y: 2pt),
  badge-tag-fill: anno-color,
  badge-tag-text: white,
  badge-lang-fill: rgb("#f7f7f2"),
  badge-lang-text: anno-color,
  badge-stroke: code-block-stroke,
  badge-radius: 6pt,
  badge-size: 14pt,
  badge-offset: (6pt, 0pt),
  badge-anchor: "south-west",
  badge-pad-x: 6pt,
  badge-pad-y: 4pt,
  ..args,
)

#let swiglu-lines = (
  "...",
  "%8 = linalg.generic {ins(%7: tensor<1x2x16xf32>) outs(%5: tensor<1x2x16xf32>)} {",
  "  %19 = arith.negf %in : f32",
  "  %20 = math.exp %19 : f32",
  "  %21 = arith.addf %20, %cst_1 : f32",
  "  %22 = arith.divf %cst_1, %21 : f32",
  "  linalg.yield %22 : f32",
  "} -> tensor<1x2x16xf32>",
  "",
  "%9 = linalg.generic {ins(%8, %7: tensor<1x2x16xf32>, tensor<1x2x16xf32>) outs(%5: tensor<1x2x16xf32>)} {",
  "  %19 = arith.mulf %in, %in_7 : f32",
  "  linalg.yield %19 : f32",
  "} -> tensor<1x2x16xf32>",
  "...",
)

#let py-lines = (
  "class LlamaFfnSublayer(nn.Module):",
  "    \"\"\"Llama FFN sublayer using SwiGLU.\"\"\"",
  "",
  "    def __init__(self, dim: int = 512, hidden_dim: int | None = None):",
  "        super().__init__()",
  "        if hidden_dim is None:",
  "            hidden_dim = int(2 * (4 * dim) / 3)",
  "        self.w_gate = nn.Linear(dim, hidden_dim, bias=False)",
  "        self.w_up = nn.Linear(dim, hidden_dim, bias=False)",
  "        self.w_down = nn.Linear(hidden_dim, dim, bias=False)",
  "",
  "    def forward(self, x: torch.Tensor) -> torch.Tensor:",
  "        gate = F.silu(self.w_gate(x))",
  "        up = self.w_up(x)",
  "        return self.w_down(gate * up)",
)

#let mm-lines = (
  "...",
  "%13 = linalg.generic ... ins(%8, %10, %transposed_4 : tensor<1x2x16xf32>, tensor<1x2x16xf32>, tensor<16x8xf32>) outs(%12 : tensor<1x1x2x8xf32>) {",
  "^bb0(%in: f32, %in_6: f32, %in_7: f32, %out: f32):",
  "  %19 = r_arith.div(%14 : !r_arith.r_const, %18 : !r_arith.r_expr)",
  "  ...",
  "  %21 = fixed_pt_arith.from_float <7, -15, signed> from %in : f32 {rounding = 3 : i32, saturate = true}",
  "  %22 = fixed_pt_arith.rescale_2pow %21 : <7, -15, signed> shift by -7",
  "  %23 = fixed_pt_arith.extract <0, -1, signed> from %22 : <0, -22, signed>",
  "  %24 = fixed_pt_arith.get_int from %23 : <0, -1, signed>",
  "  %25 = arith.index_cast %24 : i2 to index",
  "  %26:6 = scf.index_switch %25 -> !fixed_pt_arith.fixedpt<3, -17, signed>, !fixed_pt_arith.fixedpt<0, -17, signed>, !fixed_pt_arith.fixedpt<-3, -17, signed>, !fixed_pt_arith.fixedpt<-5, -17, signed>, !fixed_pt_arith.fixedpt<-8, -17, signed>, !fixed_pt_arith.fixedpt<-9, -17, signed>",
  "  case 0 {",
  "    %64 = fixed_pt_arith.const <66766, !fixed_pt_arith.fixedpt<3, -17, signed>>",
  "...",
)

#let py = codez-parse(py-lines.join("\n"))
#let swiglu = codez-parse(swiglu-lines.join("\n"))
#let mm = codez-parse(mm-lines.join("\n"))

#let m-py-linear = codez-mark("m_py_linear", start: 8, end: 10, trim-left: true)
#let m-py-swiglu = codez-mark("m_py_swiglu", start: 13, end: 15, trim-left: true)
#let m-sigmoid = codez-mark("m_sigmoid", start: 3, end: 7, trim-left: true)
#let m-mulf = codez-mark("m_mulf", start: 11, end: 11, trim-left: true)
#let m-mm-entry = codez-mark("m_mm_entry", start: 2, end: 2, trim-left: true)
#let m-mm-fixed = codez-mark("m_mm_fixed", start: 6, end: 11, trim-left: true)

#let w = 580pt
#let py-w = 520pt

// Page 1: Python NN snippet with math annotation.
#cetz.canvas(length: 1pt, {
  import cetz.draw: *
  codez-block(
    name: "py",
    at: (0, 0),
    width: py-w,
    wrap: true,
    code: py.code,
    lang: "python",
    badge-tag: "Llama.py",
    badge-lang: "Python",
    marks: (m-py-linear, m-py-swiglu),
    inline-marks: false,
    text-size: 13pt,
    line-gap: 5pt,
    mark-stroke: none,
  )
  rect("py.m_py_linear.north-west", "py.m_py_linear.south-east", stroke: anno-bbox-stroke, radius: 2pt)
  rect("py.m_py_swiglu.north-west", "py.m_py_swiglu.south-east", stroke: anno-bbox-stroke, radius: 2pt)
  content(
    (rel: (16pt, -10pt), to: "py.m_py_linear.east"),
    text(
      "MatMul projections",
      size: 14pt,
      weight: "bold",
      fill: anno-color,
    ),
    anchor: "west",
  )
  content(
    (rel: (16pt, 0pt), to: "py.m_py_swiglu.east"),
    [
      #set text(size: 13pt, fill: anno-color, weight: "bold")
      $h = (x W_"up") ⊙ sigma(z)$#linebreak()
      $y = h W_"down"$
    ],
    anchor: "west",
  )
})

#pagebreak()

// Page 2: SwiGLU math section only.
#cetz.canvas(length: 1pt, {
  import cetz.draw: *
  codez-block(
    name: "sw",
    at: (0, 0),
    width: w,
    wrap: true,
    code: swiglu.code,
    lang: "mlir",
    badge-tag: "F",
    badge-lang: "MLIR",
    marks: (m-sigmoid, m-mulf),
    inline-marks: false,
    text-size: 12pt,
    line-gap: 4pt,
    mark-stroke: none,
  )
  rect("sw.m_sigmoid.north-west", "sw.m_sigmoid.south-east", stroke: anno-bbox-stroke, radius: 2pt)
})

#pagebreak()

// Page 3: SwiGLU mul section only.
#cetz.canvas(length: 1pt, {
  import cetz.draw: *
  codez-block(
    name: "sw",
    at: (0, 0),
    width: w,
    wrap: true,
    code: swiglu.code,
    lang: "mlir",
    badge-tag: "F",
    badge-lang: "MLIR",
    marks: (m-sigmoid, m-mulf),
    inline-marks: false,
    text-size: 12pt,
    line-gap: 4pt,
    mark-stroke: none,
  )
  rect("sw.m_mulf.north-west", "sw.m_mulf.south-east", stroke: anno-bbox-stroke, radius: 2pt)
  content(
    (rel: (12pt, 0pt), to: "sw.m_mulf.east"),
    text("MatMul contribution in SwiGLU", size: 11pt, weight: "bold", fill: anno-color),
    anchor: "west",
  )
})

#pagebreak()

// Page 4: Matmul lowering entry.
#cetz.canvas(length: 1pt, {
  import cetz.draw: *
  codez-block(
    name: "mm",
    at: (0, 0),
    width: w,
    wrap: true,
    code: mm.code,
    lang: "mlir",
    badge-tag: "G",
    badge-lang: "MLIR",
    marks: (m-mm-entry, m-mm-fixed),
    inline-marks: false,
    text-size: 12pt,
    line-gap: 4pt,
    mark-stroke: none,
  )
  rect("mm.m_mm_entry.north-west", "mm.m_mm_entry.south-east", stroke: anno-bbox-stroke, radius: 2pt)
  content(
    (rel: (12pt, 0pt), to: "mm.m_mm_entry.east"),
    text("Lowered MatMul entry", size: 11pt, weight: "bold", fill: anno-color),
    anchor: "west",
  )
})

#pagebreak()

// Page 5: Fixed-point conversion chunk with wrap.
#cetz.canvas(length: 1pt, {
  import cetz.draw: *
  codez-block(
    name: "mm",
    at: (0, 0),
    width: w,
    wrap: true,
    code: mm.code,
    lang: "mlir",
    badge-tag: "G",
    badge-lang: "MLIR",
    marks: (m-mm-entry, m-mm-fixed),
    inline-marks: false,
    text-size: 12pt,
    line-gap: 4pt,
    mark-stroke: none,
  )
  rect("mm.m_mm_fixed.north-west", "mm.m_mm_fixed.south-east", stroke: anno-bbox-stroke, radius: 2pt)
})
