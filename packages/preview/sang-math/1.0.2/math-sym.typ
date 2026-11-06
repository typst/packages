// ═══════════════════════════════════════════════════════════
// MATH-SYM.TYP — Alias LaTeX → Typst cho AI/GV hay gõ nhầm
// Import: #import "math-sym.typ": *
// Dùng trong math mode: $A cap B$, $x geq 0$, $f rightarrow infty$
// ═══════════════════════════════════════════════════════════

// ─── Tập hợp ────────────────────────────────────────────────
#let cap = sym.inter         // ∩  (LaTeX: \cap)
#let cup = sym.union         // ∪  (LaTeX: \cup)
#let notin = sym.in.not        // ∉  (LaTeX:
otin)
#let subseteq = sym.subset.eq     // ⊆  (LaTeX: \subseteq)
#let supseteq = sym.supset.eq     // ⊇  (LaTeX: \supseteq)
#let emptyset = sym.nothing       // ∅  (LaTeX: \emptyset)
#let varnothing = sym.nothing      // ∅  (LaTeX: \varnothing)
#let setminus = sym.backslash     // ∖  (LaTeX: \setminus)

// ─── So sánh & quan hệ ─────────────────────────────────────
#let leq = sym.lt.eq         // ≤  (LaTeX: \leq / \le)
#let geq = sym.gt.eq         // ≥  (LaTeX: \geq / \ge)
#let le = sym.lt.eq         // ≤  alias ngắn
#let ge = sym.gt.eq         // ≥  alias ngắn
#let neq = sym.eq.not        // ≠  (LaTeX:
eq /
e)
#let ne = sym.eq.not        // ≠  alias ngắn
#let approx = sym.approx        // ≈  (LaTeX: \approx)
#let equiv = sym.equiv         // ≡  (LaTeX: \equiv)
#let sim = sym.tilde         // ~  (LaTeX: \sim)
#let simeq = sym.tilde.eq      // ≃  (LaTeX: \simeq)
#let cong = sym.tilde.equiv   // ≅  (LaTeX: \cong)
#let ll = sym.lt.double     // ≪  (LaTeX: \ll)
#let gg = sym.gt.double     // ≫  (LaTeX: \gg)
#let propto = sym.prop          // ∝  (LaTeX: \propto)

// ─── Mũi tên ────────────────────────────────────────────────
#let rightarrow = sym.arrow.r            // →  (LaTeX: \rightarrow)
#let leftarrow = sym.arrow.l            // ←  (LaTeX: \leftarrow)
#let leftrightarrow = sym.arrow.l.r          // ↔  (LaTeX: \leftrightarrow)
#let Rightarrow = sym.arrow.r.double     // ⇒  (LaTeX: \Rightarrow)
#let Leftarrow = sym.arrow.l.double     // ⇐  (LaTeX: \Leftarrow)
#let Leftrightarrow = sym.arrow.l.r.double   // ⇔  (LaTeX: \Leftrightarrow)
#let uparrow = sym.arrow.t            // ↑  (LaTeX: \uparrow)
#let downarrow = sym.arrow.b            // ↓  (LaTeX: \downarrow)
#let to = sym.arrow.r            // →  (LaTeX: \to)
#let mapsto = sym.arrow.r.bar        // ↦  (LaTeX: \mapsto)
#let hookrightarrow = sym.arrow.hook.r       // ↪  (LaTeX: \hookrightarrow)
#let longrightarrow = sym.arrow.long.r       // ⟶  (LaTeX: \longrightarrow)

// ─── Phép tính ──────────────────────────────────────────────
#let pm = sym.plus.minus    // ±  (LaTeX: \pm)
#let mp = sym.minus.plus    // ∓  (LaTeX: \mp)
#let cdot = sym.dot.c         // ·  (LaTeX: \cdot)
#let times = sym.times         // ×  (LaTeX: \times)
#let div = sym.div           // ÷  (LaTeX: \div)
#let ast = sym.ast           // ∗  (LaTeX: \ast)
#let circ = sym.degree        // °  (LaTeX: \circ khi dùng cho độ: 90^\circ → $90^circ$)
#let compose = sym.circle.small  // ∘  phép hợp hàm f∘g (nếu AI gõ \circ cho composition)
#let oplus = sym.plus.o   // ⊕  (LaTeX: \oplus)
#let otimes = sym.times.o  // ⊗  (LaTeX: \otimes)

// ─── Logic & lượng từ ──────────────────────────────────────
#let forall = sym.forall        // ∀  (LaTeX: \forall)
#let exists = sym.exists        // ∃  (LaTeX: \exists)
#let nexists = sym.exists.not    // ∄  (LaTeX:
exists)
#let neg = sym.not           // ¬  (LaTeX:
eg)
#let land = sym.and           // ∧  (LaTeX: \land)
#let lor = sym.or            // ∨  (LaTeX: \lor)
#let therefore = sym.therefore     // ∴  (LaTeX: \therefore)
#let because = sym.because       // ∵  (LaTeX: \because)

// ─── Tích phân & Giải tích ─────────────────────────────────
// Typst dùng `integral` trực tiếp trong math mode.
// Nếu AI gõ `int` thay vì `integral`:
#let int = sym.integral      // ∫  (LaTeX: \int)
#let iint = sym.integral.double   // ∬  (LaTeX: \iint)
#let iiint = sym.integral.triple   // ∭  (LaTeX: \iiint)
#let oint = sym.integral.cont     // ∮  (LaTeX: \oint)
#let partial = sym.partial       // ∂  (LaTeX: \partial)
#let nabla = sym.nabla         // ∇  (LaTeX:
abla)

// ─── Vô cực & giới hạn ─────────────────────────────────────
#let infty = sym.infinity      // ∞  (LaTeX: \infty)
#let infinity = sym.infinity      // ∞  alias dài hơn

// ─── Dấu chấm & dấu ba chấm ────────────────────────────────
#let ldots = sym.dots.h        // …  (LaTeX: \ldots)
#let cdots = sym.dots.c        // ⋯  (LaTeX: \cdots)
#let vdots = sym.dots.v        // ⋮  (LaTeX: \vdots)


// ─── Hình học ───────────────────────────────────────────────
#let perp = sym.perp          // ⊥  (LaTeX: \perp)
#let parallel = sym.parallel      // ∥  (LaTeX: \parallel)
#let angle = sym.angle         // ∠  (LaTeX: \angle)
#let measuredangle = sym.angle.arc // ∡  (LaTeX: \measuredangle)
#let triangle = sym.triangle      // △  (LaTeX: \triangle)
#let square = sym.square        // □  (LaTeX: \square)
#let diamond = sym.diamond       // ◇  (LaTeX: \diamond)

// ─── Ký hiệu đặc biệt ──────────────────────────────────────
#let hbar = sym.planck // ℏ  (LaTeX: \hbar)
#let ell = sym.ell           // ℓ  (LaTeX: \ell)
#let Re = sym.Re            // ℜ  (LaTeX: \Re)
#let Im = sym.Im            // ℑ  (LaTeX: \Im)
#let aleph = sym.aleph         // ℵ  (LaTeX: \aleph)
#let prime_sym = sym.prime         // ′  dùng khi cần prime standalone

// ─── Tổ hợp chập ────────────────────────────────────────────
// Định dạng chuẩn Việt Nam: C_n^k, A_n^k, P_n (ưu tiên user memory)
#let C(n, k) = math.attach(math.op("C"), b: n, t: k) // Tổ hợp
#let A(n, k) = math.attach(math.op("A"), b: n, t: k) // Chỉnh hợp
#let P(n) = math.attach(math.op("P"), b: n)          // Hoán vị
#let binom(n, k) = math.binom(n, k) // Giữ lại nếu lỡ cần dùng kiểu LaTeX cũ

// ─── Hàm lượng giác ngược ───────────────────────────────────
// Typst đã có: sin, cos, tan, ln, log, exp, lim, max, min, sup, inf, det, ...
// Thêm các hàm hay thiếu:
#let arcsin = math.op("arcsin")    // arcsin (LaTeX: \arcsin)
#let arccos = math.op("arccos")    // arccos (LaTeX: \arccos)
#let arctan = math.op("arctan")    // arctan (LaTeX: \arctan)
#let arccot = math.op("arccot")    // arccot
#let cot = math.op("cot")       // cot    (LaTeX: \cot)
#let csc = math.op("csc")       // csc    (LaTeX: \csc)
#let sec = math.op("sec")       // sec    (LaTeX: \sec)
#let sgn = math.op("sgn")       // sgn    (LaTeX: \operatorname{sgn})

// ─── Vector & accent ────────────────────────────────────────
// LaTeX: \vec{v}   → Typst: $arrow(v)$  hoặc $vec(v)$
// LaTeX: \overline → Typst: $overline(x)$
// LaTeX: \hat{x}   → Typst: $hat(x)$
// Alias để tránh nhầm:
#let overrightarrow(x) = math.arrow(x)  // \overrightarrow{AB} → overrightarrow(A B)
#let vec(x) = math.arrow(x)             // \vec{v} → vec(v)    (override nếu cần)
#let prod = sym.product                 // \prod → prod
#let pmat = math.mat                    // \pmatrix / \pmat → mat
#let Tr = math.op("Tr")                 // Trace of a matrix




// ─── Phân số & căn ──────────────────────────────────────────
// LaTeX: \frac{a}{b} → Typst: $a/b$   hoặc $frac(a, b)$
// LaTeX: \dfrac      → $dfrac(a, b)$ luôn giữ phân số display lớn
// LaTeX: \sqrt[n]{x} → Typst: $root(n, x)$
// Alias:
#let dfrac(a, b) = math.display(math.frac(a, b))      // \dfrac{a}{b} → dfrac(a, b)
#let tfrac-tex(a, b) = {
  show math.frac: f => f
  scale(x: 72%, y: 72%, origin: center + horizon, reflow: true, math.inline(math.frac(a, b)))
} // \tfrac{a}{b} — luôn cỡ inline nhỏ

// ─── Tổng kết ký hiệu thường nhầm ───────────────────────────
//
//  LaTeX           Typst thuần     Alias file này
//  ──────────────  ─────────────   ──────────────
//  \cap            sect            cap
//  \cup            union           cup
//  \leq / \le      lt.eq           leq / le
//  \geq / \ge      gt.eq           geq / ge
//
eq /
e      eq.not          neq / ne
//  \pm             plus.minus      pm
//  \cdot           dot.c           cdot
//  \infty          infinity        infty
//  \rightarrow     arrow.r         rightarrow / to
//  \Rightarrow     arrow.r.double  Rightarrow
//  \Leftrightarrow arrow.l.r.double Leftrightarrow
//  \forall         forall          forall
//  \exists         exists          exists
//  \therefore      therefore       therefore
//  \partial        partial         partial
//  \int            integral        int
//  \perp           perp            perp
//  \parallel       parallel        parallel
//  \subset         subset          (đã có sẵn)
//  \subseteq       subset.eq       subseteq
//  \emptyset       nothing         emptyset
//  \in             in              (đã có sẵn)
//
otin          in.not          notin
//  \cot            —               cot (math.op)
//  \arcsin         —               arcsin (math.op)
//  \vec{v}         arrow(v)        vec(v) / overrightarrow(v)

#let boxed(x) = box(stroke: 0.5pt, inset: 3pt, outset: 0pt)[#x]
