// ============================================================
// clari-docs — Example Presentation
// ============================================================
// This file showcases all four categories and the full
// component library. Adjust parameters below to fit your needs.

#import "@preview/clari-docs:0.1.0": *

// ── Presentation Setup ──────────────────────────────────────
// category: "simple" | "math" | "professional" | "allrounder"
// theme: "ocean" | "midnight" | "forest" | "teal" | "sunset"
//        "amber" | "rose" | "lavender" | "slate" | "charcoal"
//        or any rgb() color value
#show: clari-docs.with(
  category:          "allrounder",
  theme:             "ocean",
  font:              "Fira Sans",
  font-size:         20pt,
  show-page-numbers: true,
  show-progress:     true,
  back-color:        white,
)

// ── Cover Slide ─────────────────────────────────────────────
#title-slide(
  title:       "clari-docs",
  subtitle:    [A comprehensive Typst slide template],
  author:      "Your Name",
  date:        datetime.today(),
  institution: "Your Institution",
)

// ── Table of Contents ───────────────────────────────────────
#overview-slide()

// ============================================================
// Section 1 — Slide Types
// ============================================================
#section-slide[Slide Types]

// Standard slide with title
#slide(title: "Standard Slide", outlined: true)[
  The standard `slide` function is your workhorse.

  - Use `title:` for a colored header bar
  - Set `outlined: true` to register in the overview
  - Use `subtitle:` for an optional sub-header

  #callout(type: "tip")[
    Combine `section-slide` + `slide(outlined: true)` to
    build a navigable table of contents automatically.
  ]
]

// Slide without title
#slide[
  A slide *without* a title gives you the full content area.

  #cols[
    #info-v(title: "Left Column")[
      Great for side-by-side content, comparisons,
      or image + text layouts.
    ]
  ][
    #info-v(title: "Right Column")[
      Use `#cols[...][...]` for equal-width columns,
      or pass `columns: (2fr, 1fr)` for custom ratios.
    ]
  ]
]

// Focus slide
#focus-slide[
  Use `#focus-slide` for _key takeaways_.
]

// Blank slide
#blank-slide[
  A `#blank-slide` gives you an unadorned canvas.

  Perfect for full-bleed images, diagrams, or any custom layout
  you want to build from scratch without the header bar.
]

// ============================================================
// Section 2 — Content Components
// ============================================================
#section-slide[Content Components]

#slide(title: "Callout Boxes", outlined: true)[
  #callout(type: "note")[This is a *note* callout — great for supplementary info.]
  #callout(type: "tip")[This is a *tip* callout — use for best practices.]
  #callout(type: "warning")[This is a *warning* callout — flag caution points.]
  #callout(type: "important")[This is an *important* callout — must-know info.]
]

#slide(title: "More Callout Types")[
  #callout(type: "danger")[This is a *danger* callout — critical errors.]
  #callout(type: "success")[This is a *success* callout — positive outcomes.]

  Callouts are great for drawing attention without losing context.
]

#slide(title: "Info Blocks")[
  #info-v(title: "Vertical Info Block")[
    The title sits on top in a colored bar.
    Body content flows naturally below.
  ]

  #info-h(title: "Horizontal Info Block")[
    The title is a compact left label.
    Content stretches to the right — good for key-value style info.
  ]
]

#slide(title: "Framed Boxes")[
  #framed[A plain framed box — subtle background, rounded corners.]

  #framed(title: "Framed with Title")[
    A framed box with a colored title bar. Great for definitions,
    important formulas, or highlighted notes.
  ]

  #highlight-box[
    `#highlight-box` is the simplest highlight — no title, just color.
  ]
]

#slide(title: "Code Blocks")[
  #code-block(title: "hello.py")[
```python
def greet(name: str) -> str:
    return f"Hello, {name}!"

print(greet("World"))
```
  ]

  #code-block(title: "slide.typ", theme: "light")[
```typst
#slide(title: "My Slide")[
  - Point one
  - Point two
]
```
  ]
]

#slide(title: "Quotes & Definitions")[
  #quote-block(author: "Donald Knuth", source: "The Art of Computer Programming")[
    Beware of bugs in the above code; I have only proved it correct, not tried it.
  ]

  #definition(
    "Algorithm",
    [A finite sequence of well-defined instructions for solving a class of problems.],
  )
]

#slide(title: "Math Concept Boxes")[
  #theorem(title: "Pythagorean Theorem", number: "1")[
    In a right triangle with legs $a$, $b$ and hypotenuse $c$:
    $ a^2 + b^2 = c^2 $
  ]

  #proof[
    Consider a square with side $a + b$ and four congruent right triangles inside...
    The area argument yields $c^2 = a^2 + b^2$. #sym.square
  ]
]

#slide(title: "Lemmas & Corollaries")[
  #lemma(title: "Triangle Inequality", number: "2")[
    For any vectors $bold(u), bold(v)$:
    $ norm(bold(u) + bold(v)) <= norm(bold(u)) + norm(bold(v)) $
  ]

  #corollary(title: "Norm Bound", number: "1")[
    As a direct consequence, $norm(bold(u) - bold(v)) >= |norm(bold(u)) - norm(bold(v))|$.
  ]
]

#slide(title: "Step Lists")[
  #step-list(
    [Import the package and configure `#show: clari-docs.with(...)`],
    [Add a `#title-slide(...)` as your cover],
    [Use `#section-slide[...]` to divide your content],
    [Fill slides with content and components],
    [Compile with `typst compile main.typ`],
  )
]

#slide(title: "Comparison Layout")[
  #comparison(
    left-title:  "Pros",
    right-title: "Cons",
    [
      - Fast compilation
      - Typst is type-safe
      - Clean, expressive syntax
      - Great math support
    ],
    [
      - Smaller ecosystem vs. LaTeX
      - Some packages still maturing
      - Limited IDE support (improving)
    ],
  )
]

#slide(title: "Data Tables")[
  #data-table(
    ("Model", "Accuracy", "F1 Score", "Latency"),
    (
      ("Baseline", "72.3%", "0.71", "12 ms"),
      ("ResNet-50", "89.1%", "0.88", "45 ms"),
      ("ViT-B/16", "91.5%", "0.91", "110 ms"),
      ("Ours", "93.8%", "0.93", "38 ms"),
    ),
    caption: "Sample performance metrics",
  )
]

// ============================================================
// Section 3 — Image Layouts
// ============================================================
#section-slide[Image Layouts]

#slide(title: "Image Layout Options", outlined: true)[
  clari-docs provides five image placement modes:

  #step-list(
    [`#img-full(src)` — fills the entire slide],
    [`#img-left(src)[content]` — image left, text right],
    [`#img-right(src)[content]` — image right, text left],
    [`#img-top(src)[content]` — image top, text below],
    [`#img-bottom(src)[content]` — text above, image below],
  )

  Replace `src` with your image path (relative to `main.typ`).
]

// ============================================================
// Section 4 — Math & Science
// ============================================================
#section-slide[Mathematics & Science]

#slide(title: "Equation Display", outlined: true)[
  Use `#math-eq` for a beautifully boxed display equation:

  #math-eq(numbered: true)[$ E = m c^2 $]

  #math-eq(numbered: true)[
    $ integral_0^infinity e^(-x^2) dif x = sqrt(pi) / 2 $
  ]
]

#slide(title: "Aligned Equations")[
  Group related equations with `#math-aligned`:

  #math-aligned(
    [$ nabla dot bold(E) &= rho / epsilon_0 $],
    [$ nabla dot bold(B) &= 0 $],
    [$ nabla times bold(E) &= -(partial bold(B)) / (partial t) $],
    [$ nabla times bold(B) &= mu_0 bold(J) + mu_0 epsilon_0 (partial bold(E)) / (partial t) $],
  )
]

#slide(title: "Physics Equations")[
  #phys-eq(
    label: "Newton's Law of Gravitation",
    unit:  "[N]",
  )[$ F = G (m_1 m_2) / r^2 $]

  #phys-eq(
    label: "Schrödinger Equation",
    derivation: true,
  )[$ i ℏ (partial Psi) / (partial t) = hat(H) Psi $]
]

#slide(title: "Chemical Equations")[
  #chem-eq(
    [2H#sub[2] + O#sub[2]],
    [2H#sub[2]O],
    conditions: [Δ, catalyst],
  )

  #chem-eq(
    [N#sub[2] + 3H#sub[2]],
    [2NH#sub[3]],
    arrow-type: "equilibrium",
    conditions: [450°C, 200 atm, Fe],
  )
]

#slide(title: "SI Values & Constants")[
  Inline SI values with `#si-value`:

  Speed of light: #si-value("299 792 458", "m·s⁻¹") \
  Planck constant: #si-value("6.626 × 10⁻³⁴", "J·s", uncertainty: "±0.001 × 10⁻³⁴") \
  Boltzmann constant: #si-value("1.380 649 × 10⁻²³", "J·K⁻¹")

  #constants-table((
    (symbol: [$c$],     name: "Speed of light",      value: [$2.998 times 10^8$], unit: "m·s⁻¹"),
    (symbol: [$h$],     name: "Planck constant",     value: [$6.626 times 10^(-34)$], unit: "J·s"),
    (symbol: [$k_B$],   name: "Boltzmann constant",  value: [$1.381 times 10^(-23)$], unit: "J·K⁻¹"),
    (symbol: [$N_A$],   name: "Avogadro constant",   value: [$6.022 times 10^(23)$], unit: "mol⁻¹"),
  ))
]

#slide(title: "Annotated Equations")[
  #pin-eq(
    [$ F = m dot a $],
    [$F$ — net force applied to the object],
    [$m$ — mass of the object],
    [$a$ — resulting acceleration],
  )
]

#slide(title: "Function Definitions")[
  #function-def(
    "f",
    $RR^n$,
    $RR$,
  )[
    $ f(bold(x)) = bold(w)^T bold(x) + b $
    where $bold(w) in RR^n$ is the weight vector and $b in RR$ is the bias.
  ]
]

#slide(title: "Calculus Display")[
  #derivative-display($f$, $x$, order: 2,
    label: "Second derivative")

  #integral-display(
    $f(x)$, var: $x$,
    lower: $a$, upper: $b$,
    label: "Definite integral",
  )

  #limit-display(
    $(sin x) / x$,
    $x$, $0$,
    label: "Fundamental limit",
  )
]

#slide(title: "Bar Chart Example")[
  #bar-chart(
    (
      (label: "A", value: 85),
      (label: "B", value: 92),
      (label: "C", value: 71),
      (label: "D", value: 96),
      (label: "E", value: 78),
    ),
    x-label: "Category",
    y-label: "Score (%)",
  )
]

// ============================================================
// Section 5 — Colour Themes
// ============================================================
#section-slide[Colour Themes]

#slide(title: "Available Themes", outlined: true)[
  Pass any theme name to `clari-docs.with(theme: ...)`:

  #cols[
    #step-list(
      [`"ocean"` — deep blue (simple default)],
      [`"midnight"` — navy (professional default)],
      [`"forest"` — forest green],
      [`"teal"` — teal (allrounder default)],
      [`"sunset"` — deep red],
    )
  ][
    #step-list(
      [`"amber"` — warm amber],
      [`"rose"` — rose/magenta],
      [`"lavender"` — purple],
      [`"slate"` — slate (math default)],
      [`"charcoal"` — near-black],
    )
  ]

  Or pass any `rgb(...)` color directly!
]

// ── End Slide ───────────────────────────────────────────────
#end-slide(title: "Thank You")[
  Questions? \
  #link("https://github.com/Joe02exe/clari-slides")
]
