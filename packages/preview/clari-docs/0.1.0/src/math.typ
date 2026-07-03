// ============================================================
// clari-slides — Math & Science Components
// ============================================================
// Production-ready, context-aware math/science slide components
// for the clari-slides Typst presentation framework.
//
// All components read `cs-primary`, `cs-accent`, and
// `cs-back-color` from the global state defined in state.typ.
// ============================================================

#import "state.typ": *

// ============================================================
// Internal helpers
// ============================================================

/// Muted gray background color used in equation boxes.
#let _cs-eq-gray = rgb("#F4F5F6")

/// Chemistry green used for chem-eq left border.
#let _cs-chem-green = rgb("#2D6A4F")

/// Small muted label style.
#let _muted-label(body) = text(size: 0.72em, fill: rgb("#888888"), style: "italic")[#body]

/// Thin rounded box wrapper used as the base for most components.
/// `accent-bar`: if `none` no left bar; if a color, draws a 3pt left bar.
#let _eq-box(
  body,
  back-color: none,
  accent-bar: none,
  radius: 5pt,
  inset: (x: 12pt, y: 9pt),
) = {
  let bg = if back-color != none { back-color } else { _cs-eq-gray }
  if accent-bar != none {
    // Composite: colored left bar + content area
    stack(
      dir: ltr,
      rect(width: 3pt, fill: accent-bar, radius: (top-left: radius, bottom-left: radius)),
      rect(
        fill: bg,
        inset: inset,
        radius: (top-right: radius, bottom-right: radius),
        width: 100%,
        body,
      ),
    )
  } else {
    rect(
      fill: bg,
      inset: inset,
      radius: radius,
      width: 100%,
      body,
    )
  }
}

// ============================================================
// Equation counter
// ============================================================

#let _cs-eq-counter = counter("cs-eq")

// ============================================================
// math-eq
// ============================================================

/// Displays a centered equation in a subtle gray rounded box.
///
/// - body (content): The mathematical expression. Write raw math tokens
///   (without `$` delimiters); they are placed inside a display math block.
/// - label (none, string): LaTeX-style label for cross-referencing. When
///   provided, the label string is embedded as metadata so call sites can
///   locate the equation. (Typst labels require literal syntax at definition
///   site; use `#metadata` queries to retrieve by label string.)
/// - numbered (bool): If `true`, increments the equation counter and shows
///   the number flush-right.
/// - back-color (none, color): Background fill. Defaults to a light gray.
#let math-eq(
  body,
  label: none,
  numbered: false,
  back-color: none,
) = {
  if numbered { _cs-eq-counter.step() }

  let eq-num = if numbered {
    context [(#_cs-eq-counter.display())]
  } else { none }

  block(
    width: 100%,
    {
      _eq-box(
        grid(
          columns: (1fr, auto),
          column-gutter: 8pt,
          align: (center + horizon, right + horizon),
          body,
          if eq-num != none { _muted-label(eq-num) } else { [] },
        ),
        back-color: back-color,
      )
      if label != none {
        // Embed metadata for traceability; true Typst labels require
        // literal syntax at call site, so we store the string in metadata.
        [#metadata((cs-eq-label: label))]
      }
    },
  )
}

// ============================================================
// math-aligned
// ============================================================

/// Displays a group of aligned equations in a styled box.
///
/// Each positional argument is one equation line (content with `&` for
/// alignment points). Lines are separated by `\` in the resulting math block.
///
/// Example:
/// ```typst
/// #math-aligned(
///   $f(x) &= x^2 + 3x$,
///   $f'(x) &= 2x + 3$,
/// )
/// ```
///
/// - ..rows (arguments): Positional content arguments, one per equation row.
#let math-aligned(..rows) = {
  let items = rows.pos()
  // Build a math block with aligned rows
  // Each item is already a math expression; join with line breaks
  block(
    width: 100%,
    _eq-box(
      align(center,
        // We render each row individually and stack them
        // to preserve alignment marks the user wrote.
        stack(
          dir: ttb,
          spacing: 4pt,
          ..items.map(row => block(width: 100%, align(center, row))),
        )
      ),
    ),
  )
}

// ============================================================
// chem-eq
// ============================================================

/// Chemical equation component with optional conditions above the arrow.
///
/// - reactants (content): Left-hand side content, e.g. `[2H#sub[2] + O#sub[2]]`.
/// - products (content): Right-hand side content.
/// - arrow-type (string): One of "forward" (→), "reverse" (←),
///   "equilibrium" (⇌), or "double" (⇔). Default: "forward".
/// - conditions (none, content): Optional text shown above the arrow
///   (e.g. temperature, catalyst name).
/// - label (none, string): Optional label shown flush-right in muted text.
#let chem-eq(
  reactants,
  products,
  arrow-type: "forward",
  conditions: none,
  label: none,
) = {
  let arrow-sym = if arrow-type == "reverse"     { [←]  }
             else if arrow-type == "equilibrium" { [⇌]  }
             else if arrow-type == "double"      { [⇔]  }
             else                                { [→]  }

  let arrow-col = stack(
    dir: ttb,
    spacing: 2pt,
    if conditions != none {
      text(size: 0.75em, fill: _cs-chem-green, weight: "semibold")[#conditions]
    } else { [] },
    text(size: 1.1em)[#arrow-sym],
  )

  let label-col = if label != none {
    _muted-label(label)
  } else { [] }

  block(
    width: 100%,
    _eq-box(
      grid(
        columns: (1fr, auto, 1fr, auto),
        column-gutter: 10pt,
        align: (right + horizon, center + horizon, left + horizon, right + horizon),
        text(weight: "semibold")[#reactants],
        arrow-col,
        text(weight: "semibold")[#products],
        label-col,
      ),
      accent-bar: _cs-chem-green,
    ),
  )
}

// ============================================================
// phys-eq
// ============================================================

/// Physics equation display with a labeled header bar.
///
/// - body (content): The equation body (math tokens, no `$` delimiters needed
///   — wrap in `$...$` yourself for inline math, or pass math content).
/// - label (none, string): Equation name shown in the header bar,
///   e.g. `"Newton's Second Law"`.
/// - unit (none, string): SI unit string shown to the right of the equation,
///   e.g. `"[N·m²·kg⁻²]"`.
/// - derivation (bool): If `true`, uses the accent color for the header
///   instead of the primary color, signalling a derivation step.
/// - back-color (none, color): Box background. Defaults to light gray.
#let phys-eq(
  body,
  label: none,
  unit: none,
  derivation: false,
  back-color: none,
) = {
  let bg = if back-color != none { back-color } else { _cs-eq-gray }

  context {
    let header-color = if derivation { cs-accent.get() } else { cs-primary.get() }

    block(
      width: 100%,
      radius: 5pt,
      clip: true,
      stack(
        dir: ttb,
        // Header bar
        if label != none {
          rect(
            fill: header-color,
            width: 100%,
            inset: (x: 12pt, y: 5pt),
            text(fill: white, size: 0.8em, weight: "semibold")[#label],
          )
        } else { [] },
        // Body row
        rect(
          fill: bg,
          width: 100%,
          inset: (x: 12pt, y: 9pt),
          grid(
            columns: (1fr, auto),
            column-gutter: 10pt,
            align: (center + horizon, right + horizon),
            $ #body $,
            if unit != none {
              _muted-label(unit)
            } else { [] },
          ),
        ),
      ),
    )
  }
}

// ============================================================
// equation-set
// ============================================================

/// A titled group of related equations.
///
/// Displays a small primary-colored title above a column of `math-eq` boxes.
///
/// - title (string, content): Section title shown above the equations.
/// - ..equations (arguments): Positional content arguments, each rendered
///   as an individual `math-eq` box.
#let equation-set(title, ..equations) = {
  let items = equations.pos()
  block(
    width: 100%,
    stack(
      dir: ttb,
      spacing: 6pt,
      // Title
      context text(fill: cs-primary.get(), weight: "bold", size: 0.9em)[#title],
      // Stack of equation boxes
      ..items.map(eq => math-eq(eq)),
    ),
  )
}

// ============================================================
// pin-eq
// ============================================================

/// Equation with pin-style annotations listed below.
///
/// - body (content): The equation content (display math).
/// - ..annotations (arguments): Positional content items. Each is shown as
///   a bulleted annotation below the equation with a colored bullet.
#let pin-eq(body, ..annotations) = {
  let items = annotations.pos()
  block(
    width: 100%,
    stack(
      dir: ttb,
      spacing: 4pt,
      // The equation box
      _eq-box(align(center, body)),
      // Annotation list
      if items.len() > 0 {
        context {
          let pc = cs-primary.get()
          block(
            width: 100%,
            inset: (left: 10pt, top: 12pt, bottom: 8pt),
            stack(
              dir: ttb,
              spacing: 12pt,
              ..items.enumerate().map(((i, ann)) =>
                grid(
                  columns: (auto, 1fr),
                  column-gutter: 12pt,
                  align: top,
                  text(fill: pc, weight: "bold", size: 1.0em)[#(i + 1).],
                  text(size: 1.0em)[#ann],
                )
              ),
            ),
          )
        }
      } else { [] },
    ),
  )
}

// ============================================================
// annotated-term
// ============================================================

/// Inline annotation helper. Highlights `term` in the primary color and
/// places a smaller description below it.
///
/// - term (content): The symbol or term to highlight.
/// - description (content): Explanatory text shown below the term.
#let annotated-term(term, description) = {
  context {
    let pc = cs-primary.get()
    stack(
      dir: ttb,
      spacing: 2pt,
      text(fill: pc, weight: "semibold")[#term],
      text(size: 0.75em, fill: rgb("#555555"))[#description],
    )
  }
}

// ============================================================
// function-def
// ============================================================

/// Function definition box.
///
/// - name (string): Function name (e.g. `"f"`).
/// - domain (content): Domain set (e.g. `$RR$`).
/// - codomain (content): Codomain set (e.g. `$RR^+$`).
/// - body (content): The function definition body.
#let function-def(name, domain, codomain, body) = {
  context {
    let pc = cs-primary.get()
    block(
      width: 100%,
      radius: 5pt,
      clip: true,
      stack(
        dir: ttb,
        // Header: f: Domain → Codomain
        rect(
          fill: pc,
          width: 100%,
          inset: (x: 12pt, y: 6pt),
          text(fill: white, weight: "semibold", size: 0.85em)[
            #name: #domain → #codomain
          ],
        ),
        // Body
        rect(
          fill: _cs-eq-gray,
          width: 100%,
          inset: (x: 12pt, y: 9pt),
          align(center, body),
        ),
      ),
    )
  }
}

// ============================================================
// sequence-display
// ============================================================

/// Displays a named sequence with its general term and first few explicit terms.
///
/// - name (string): Sequence name (e.g. `"Fibonacci"`).
/// - general-term (content): General term formula (math content, e.g. `$a_n = ...$`).
/// - ..terms (arguments): Explicit term values (e.g. `[1]`, `[1]`, `[2]`, `[3]`).
#let sequence-display(name, general-term, ..terms) = {
  let items = terms.pos()
  context {
    let pc = cs-primary.get()
    block(
      width: 100%,
      radius: 5pt,
      clip: true,
      stack(
        dir: ttb,
        // Header
        rect(
          fill: pc,
          width: 100%,
          inset: (x: 12pt, y: 5pt),
          text(fill: white, weight: "semibold", size: 0.82em)[Sequence: #name],
        ),
        // General term
        rect(
          fill: _cs-eq-gray,
          width: 100%,
          inset: (x: 12pt, y: 7pt),
          stack(
            dir: ttb,
            spacing: 5pt,
            align(center, general-term),
            if items.len() > 0 {
              let terms-text = items.enumerate().map(((i, v)) =>
                [#(sym.a)#sub[str(i + 1)] = #v]
              ).join([, #h(2pt)])
              text(size: 0.8em, fill: rgb("#555555"))[First terms: #items.join([, ])]
            } else { [] },
          ),
        ),
      ),
    )
  }
}

// ============================================================
// matrix-display
// ============================================================

/// Displays a matrix in a styled box.
///
/// - rows (array): Array of arrays of content (cells). E.g.
///   `(([$a$], [$b$]), ([$c$], [$d$]))`.
/// - style (string): `"plain"` (parentheses), `"bracket"` (square brackets),
///   or `"determinant"` (vertical bars). Default: `"plain"`.
/// - label (none, string): Optional label shown flush-right.
#let matrix-display(rows, style: "plain", label: none) = {
  // Build math content for the matrix body
  let n-cols = if rows.len() > 0 { rows.at(0).len() } else { 1 }

  // Choose delimiters
  let (open, close) = if style == "bracket"     { (sym.bracket.l, sym.bracket.r) }
                 else if style == "determinant" { (sym.bar.v,     sym.bar.v)     }
                 else                           { (sym.paren.l,   sym.paren.r)   }

  // Build the matrix rows as a math-compatible grid inside a math block
  let cell-rows = rows.map(row => row.join([, ]))
  let mat-content = cell-rows.join([; ])

  block(
    width: 100%,
    _eq-box(
      grid(
        columns: (1fr, auto),
        column-gutter: 8pt,
        align: (center + horizon, right + horizon),
        $ mat(delim: #open, ..rows.map(r => r)) $,
        if label != none { _muted-label(label) } else { [] },
      ),
    ),
  )
}

// ============================================================
// vector-display
// ============================================================

/// Displays a column or row vector in a styled box.
///
/// - components (array): Array of content for each component.
/// - name (none, content): Optional variable name shown to the left.
/// - style (string): `"column"` or `"row"`. Default: `"column"`.
#let vector-display(components, name: none, style: "column") = {
  let vec-math = if style == "row" {
    // Row vector: (c1, c2, ..., cn)
    let inner = components.join([, ])
    $ vec(delim: "(", #inner) $
  } else {
    // Column vector using mat with single column
    $ mat(delim: "(", ..components.map(c => (c,))) $
  }

  block(
    width: 100%,
    _eq-box(
      align(center,
        if name != none {
          grid(
            columns: (auto, auto),
            column-gutter: 6pt,
            align: center + horizon,
            $ #name = $,
            vec-math,
          )
        } else {
          vec-math
        }
      ),
    ),
  )
}

// ============================================================
// integral-display
// ============================================================

/// Displays a definite or indefinite integral in a styled box.
///
/// - integrand (content): The integrand expression (math content).
/// - var (none, content): The variable of integration (e.g. `$x$`).
/// - lower (none, content): Lower bound.
/// - upper (none, content): Upper bound.
/// - label (none, string): Optional label string.
#let integral-display(integrand, var: none, lower: none, upper: none, label: none) = {
  let int-body = if lower != none and upper != none {
    $ integral_(#lower)^(#upper) #integrand thin dif #var $
  } else if lower != none {
    $ integral_(#lower) #integrand thin dif #var $
  } else if upper != none {
    $ integral^(#upper) #integrand thin dif #var $
  } else {
    $ integral #integrand thin dif #var $
  }

  block(
    width: 100%,
    _eq-box(
      grid(
        columns: (1fr, auto),
        column-gutter: 8pt,
        align: (center + horizon, right + horizon),
        int-body,
        if label != none { _muted-label(label) } else { [] },
      ),
    ),
  )
}

// ============================================================
// derivative-display
// ============================================================

/// Displays a derivative in a styled box.
///
/// - func (content): The function being differentiated (e.g. `$f$`).
/// - var (content): The variable (e.g. `$x$`).
/// - order (int, string): Derivative order: `1`, `2`, or `"n"`. Default: `1`.
/// - point (none, content): Optional evaluation point.
/// - label (none, string): Optional label string.
#let derivative-display(func, var, order: 1, point: none, label: none) = {
  let order-str = if order == 1 { none }
             else if order == 2 { $2$ }
             else               { $n$ }

  let deriv-body = if order == 1 {
    if point != none {
      $ (dif #func) / (dif #var) mid|_(#point) $
    } else {
      $ (dif #func) / (dif #var) $
    }
  } else {
    if point != none {
      $ (dif^(#order-str) #func) / (dif #var^(#order-str)) mid|_(#point) $
    } else {
      $ (dif^(#order-str) #func) / (dif #var^(#order-str)) $
    }
  }

  block(
    width: 100%,
    _eq-box(
      grid(
        columns: (1fr, auto),
        column-gutter: 8pt,
        align: (center + horizon, right + horizon),
        deriv-body,
        if label != none { _muted-label(label) } else { [] },
      ),
    ),
  )
}

// ============================================================
// limit-display
// ============================================================

/// Displays a limit in a styled box.
///
/// - expr (content): The expression whose limit is taken.
/// - var (content): The variable (e.g. `$x$`).
/// - to (content): The value the variable approaches (e.g. `$infinity$`).
/// - label (none, string): Optional label string.
#let limit-display(expr, var, to, label: none) = {
  block(
    width: 100%,
    _eq-box(
      grid(
        columns: (1fr, auto),
        column-gutter: 8pt,
        align: (center + horizon, right + horizon),
        $ lim_(#var -> #to) #expr $,
        if label != none { _muted-label(label) } else { [] },
      ),
    ),
  )
}

// ============================================================
// sum-display
// ============================================================

/// Displays a summation in a styled box.
///
/// - expr (content): The summand.
/// - index (content): The summation index variable (e.g. `$i$`).
/// - from (content): Lower bound (e.g. `$1$`).
/// - to (content): Upper bound (e.g. `$n$`).
/// - label (none, string): Optional label string.
#let sum-display(expr, index, from, to, label: none) = {
  block(
    width: 100%,
    _eq-box(
      grid(
        columns: (1fr, auto),
        column-gutter: 8pt,
        align: (center + horizon, right + horizon),
        $ sum_(#index = #from)^(#to) #expr $,
        if label != none { _muted-label(label) } else { [] },
      ),
    ),
  )
}

// ============================================================
// product-display
// ============================================================

/// Displays a product (Π notation) in a styled box.
///
/// - expr (content): The factor expression.
/// - index (content): The product index variable.
/// - from (content): Lower bound.
/// - to (content): Upper bound.
/// - label (none, string): Optional label string.
#let product-display(expr, index, from, to, label: none) = {
  block(
    width: 100%,
    _eq-box(
      grid(
        columns: (1fr, auto),
        column-gutter: 8pt,
        align: (center + horizon, right + horizon),
        $ product_(#index = #from)^(#to) #expr $,
        if label != none { _muted-label(label) } else { [] },
      ),
    ),
  )
}

// ============================================================
// si-value
// ============================================================

/// Displays a measurement with its SI unit (and optional uncertainty).
///
/// - value (content): The numeric value.
/// - unit (string): Unit string, e.g. `"m/s²"` or `"kg·m·s⁻²"`.
/// - uncertainty (none, content): Uncertainty, e.g. `[±0.01]`.
#let si-value(value, unit, uncertainty: none) = {
  context {
    let pc = cs-primary.get()
    box(
      inset: (x: 7pt, y: 4pt),
      radius: 4pt,
      fill: _cs-eq-gray,
      {
        text(weight: "semibold")[#value]
        if uncertainty != none {
          text(size: 0.85em, fill: rgb("#555555"))[ ± #uncertainty]
        }
        h(4pt)
        text(fill: pc, size: 0.85em, weight: "semibold")[#unit]
      },
    )
  }
}

// ============================================================
// reaction-mechanism
// ============================================================

/// Multi-step reaction mechanism display.
///
/// - steps (array): Array of dictionaries, each with keys:
///   - `reagent` (content): The reagent/starting material.
///   - `conditions` (content): Reaction conditions above the arrow.
///   - `product` (content): The product.
///
/// Example:
/// ```typst
/// #reaction-mechanism((
///   (reagent: [CH#sub[4]], conditions: [Cl#sub[2], hν], product: [CH#sub[3]Cl]),
///   (reagent: [CH#sub[3]Cl], conditions: [Cl#sub[2], hν], product: [CH#sub[2]Cl#sub[2]]),
/// ))
/// ```
#let reaction-mechanism(steps) = {
  block(
    width: 100%,
    _eq-box(
      stack(
        dir: ttb,
        spacing: 8pt,
        ..steps.enumerate().map(((i, step)) =>
          grid(
            columns: (auto, auto, auto, auto, 1fr),
            column-gutter: 6pt,
            align: center + horizon,
            // Step number
            text(size: 0.75em, fill: _cs-chem-green, weight: "bold")[#(i + 1).],
            // Reagent
            text(weight: "semibold")[#step.reagent],
            // Arrow with conditions
            stack(
              dir: ttb,
              spacing: 1pt,
              text(size: 0.7em, fill: _cs-chem-green)[#step.conditions],
              text(size: 1.1em)[→],
            ),
            // Product
            text(weight: "semibold")[#step.product],
            [],
          )
        ),
      ),
      accent-bar: _cs-chem-green,
    ),
  )
}

// ============================================================
// energy-diagram
// ============================================================

/// Simplified energy level diagram using Typst layout primitives.
///
/// Shows reactant level, activation energy peak, and product level with
/// ΔE and activation energy labels.
///
/// - label (string): Title for the diagram.
/// - reactants-label (string): Label for the reactant energy level.
/// - products-label (string): Label for the product energy level.
/// - delta-e (string): ΔE label string, e.g. `"−286 kJ/mol"`.
/// - activation-e (none, string): Activation energy label, e.g. `"Ea = 40 kJ/mol"`.
#let energy-diagram(
  label: "Energy Diagram",
  reactants-label: "Reactants",
  products-label: "Products",
  delta-e: "ΔE",
  activation-e: none,
) = {
  context {
    let pc = cs-primary.get()
    let ac = cs-accent.get()

    block(
      width: 100%,
      radius: 5pt,
      clip: true,
      stack(
        dir: ttb,
        // Title bar
        rect(
          fill: pc,
          width: 100%,
          inset: (x: 12pt, y: 5pt),
          text(fill: white, weight: "semibold", size: 0.82em)[#label],
        ),
        // Diagram body
        rect(
          fill: _cs-eq-gray,
          width: 100%,
          inset: (x: 16pt, y: 12pt),
          {
            // Reactant level (left, higher)
            grid(
              columns: (auto, 1fr, auto),
              column-gutter: 0pt,
              row-gutter: 0pt,
              align: bottom,
              // Left column: reactant label + level bar
              stack(
                dir: ttb,
                spacing: 2pt,
                text(size: 0.72em, fill: pc, weight: "semibold")[#reactants-label],
                rect(width: 60pt, height: 3pt, fill: pc, radius: 1pt),
              ),
              // Middle: activation energy arch (simplified as text)
              align(center,
                stack(
                  dir: ttb,
                  spacing: 2pt,
                  if activation-e != none {
                    text(size: 0.68em, fill: ac)[#activation-e]
                  } else { [] },
                  // Simple arch representation
                  box(
                    width: 100%,
                    height: 32pt,
                    // Visual arch using a centered peak indicator
                    align(center + bottom,
                      stack(
                        dir: ttb,
                        spacing: 0pt,
                        text(size: 1.4em, fill: ac)[∧],
                        rect(width: 2pt, height: 18pt, fill: ac.lighten(30%)),
                      ),
                    ),
                  ),
                  // ΔE label
                  text(size: 0.72em, fill: rgb("#555555"))[#delta-e],
                )
              ),
              // Right column: products level (lower)
              stack(
                dir: ttb,
                spacing: 2pt,
                text(size: 0.72em, fill: rgb("#888888"), weight: "semibold")[#products-label],
                rect(width: 60pt, height: 3pt, fill: rgb("#888888"), radius: 1pt),
                // Spacer so product level appears lower
                v(14pt),
              ),
            )
          },
        ),
      ),
    )
  }
}

// ============================================================
// molecular-formula
// ============================================================

/// Renders a molecular formula with proper subscripts and superscripts.
///
/// The `formula` string is parsed: digit sequences following a letter become
/// subscripts, and any trailing charge is applied as a superscript.
///
/// - formula (string): Chemical formula string, e.g. `"H2O"`, `"Ca(OH)2"`,
///   `"CO2"`, `"H2SO4"`.
/// - charge (none, string): Optional charge string, e.g. `"+"`, `"2-"`, `"3+"`.
/// - state-of-matter (none, string): Optional state label, e.g. `"(s)"`,
///   `"(l)"`, `"(g)"`, `"(aq)"`.
#let molecular-formula(formula, charge: none, state-of-matter: none) = {
  // Parse formula string into segments: text or subscript-digits
  let segments = ()
  let i = 0
  let chars = formula.clusters()
  let n = chars.len()

  while i < n {
    let c = chars.at(i)
    // Check if current char is a digit
    if c >= "0" and c <= "9" {
      // Collect all consecutive digits
      let digits = c
      i += 1
      while i < n and chars.at(i) >= "0" and chars.at(i) <= "9" {
        digits += chars.at(i)
        i += 1
      }
      segments.push((type: "sub", val: digits))
    } else {
      segments.push((type: "text", val: c))
      i += 1
    }
  }

  // Render segments
  box({
    for seg in segments {
      if seg.type == "sub" {
        sub(seg.val)
      } else {
        seg.val
      }
    }
    if charge != none {
      super(charge)
    }
    if state-of-matter != none {
      text(size: 0.82em, fill: rgb("#555555"))[#state-of-matter]
    }
  })
}

// ============================================================
// constants-table
// ============================================================

/// Displays a styled table of physical constants.
///
/// - constants (array): Array of dictionaries with keys:
///   - `symbol` (content): The symbol (math content), e.g. `$c$`.
///   - `name` (string): Full name, e.g. `"Speed of light"`.
///   - `value` (content): Numerical value with exponent.
///   - `unit` (string): SI unit string.
#let constants-table(constants) = {
  context {
    let pc = cs-primary.get()

    block(
      width: 100%,
      radius: 5pt,
      clip: true,
      table(
        columns: (auto, 1fr, auto, auto),
        align: (center + horizon, left + horizon, right + horizon, left + horizon),
        stroke: none,
        fill: (col, row) => if row == 0 {
          pc
        } else if calc.rem(row, 2) == 0 {
          _cs-eq-gray
        } else {
          white
        },
        // Header row
        table.cell(text(fill: white, weight: "bold", size: 0.78em)[Symbol]),
        table.cell(text(fill: white, weight: "bold", size: 0.78em)[Constant]),
        table.cell(text(fill: white, weight: "bold", size: 0.78em)[Value]),
        table.cell(text(fill: white, weight: "bold", size: 0.78em)[Unit]),
        // Data rows
        ..constants.map(c => (
          table.cell(text(size: 0.82em)[#c.symbol]),
          table.cell(text(size: 0.82em)[#c.name]),
          table.cell(text(size: 0.82em, weight: "semibold")[#c.value]),
          table.cell(text(size: 0.78em, fill: rgb("#555555"))[#c.unit]),
        )).flatten(),
      ),
    )
  }
}

// ============================================================
// bar-chart
// ============================================================

/// Simple inline bar chart using Typst rectangles.
///
/// - data (array): Array of dictionaries with `label` (string) and
///   `value` (float) keys. Up to 8 bars are rendered.
/// - x-label (none, string): Optional horizontal axis label.
/// - y-label (none, string): Optional vertical axis label (shown rotated left).
/// - color (none, color): Bar fill color. Defaults to primary color.
/// - max-val (none, float): Maximum value for scaling. Defaults to the
///   largest value in `data`.
#let bar-chart(
  data,
  x-label: none,
  y-label: none,
  color: none,
  max-val: none,
  chart-height: 80pt,
  bar-width: 28pt,
  bar-gap: 8pt,
) = {
  // Limit to 8 bars
  let bars = if data.len() > 8 { data.slice(0, 8) } else { data }
  let max-v = if max-val != none {
    max-val
  } else {
    bars.fold(0, (acc, d) => if d.value > acc { d.value } else { acc })
  }

  context {
    let bar-color = if color != none { color } else { cs-primary.get() }

    block(
      width: 100%,
      _eq-box(
        align(center, stack(
          dir: ttb,
          spacing: 4pt,
          // Y-axis label
          if y-label != none {
            align(left, text(size: 0.72em, fill: rgb("#888888"))[#y-label])
          } else { [] },
          // Chart area
          grid(
            columns: bars.map(_ => bar-width),
            column-gutter: bar-gap,
            align: bottom + center,
            ..bars.map(d => {
              let ratio = if max-v == 0 { 0% } else { d.value / max-v * 100% }
              let bar-h = if max-v == 0 { 0pt } else { chart-height * d.value / max-v }
              stack(
                dir: ttb,
                spacing: 2pt,
                // Value label above bar
                text(size: 0.65em, weight: "semibold")[#d.value],
                // Bar rectangle
                rect(
                  width: bar-width,
                  height: bar-h,
                  fill: bar-color,
                  radius: (top-left: 3pt, top-right: 3pt),
                ),
                // Category label below bar
                text(size: 0.65em, fill: rgb("#555555"))[#d.label],
              )
            }),
          ),
          // X-axis label
          if x-label != none {
            align(center, text(size: 0.72em, fill: rgb("#888888"))[#x-label])
          } else { [] },
        )),
      ),
    )
  }
}

// ============================================================
// scatter-hint
// ============================================================

/// Placeholder box marking where a scatter plot should be inserted.
///
/// - caption (string): Descriptive caption shown inside the placeholder.
#let scatter-hint(caption: "Insert scatter plot here") = {
  context {
    let pc = cs-primary.get()
    block(
      width: 100%,
      height: 120pt,
      radius: 5pt,
      stroke: 1.5pt + pc.lighten(40%),
      fill: pc.lighten(93%),
      align(center + horizon,
        stack(
          dir: ttb,
          spacing: 6pt,
          text(size: 1.6em, fill: pc.lighten(40%))[⊞],
          text(size: 0.78em, fill: pc.lighten(20%), style: "italic")[#caption],
        ),
      ),
    )
  }
}

// ============================================================
// pie-chart-hint
// ============================================================

/// Placeholder box marking where a pie chart should be inserted.
///
/// - caption (string): Descriptive caption shown inside the placeholder.
#let pie-chart-hint(caption: "Insert pie chart here") = {
  context {
    let ac = cs-accent.get()
    block(
      width: 100%,
      height: 120pt,
      radius: 5pt,
      stroke: 1.5pt + ac.lighten(30%),
      fill: ac.lighten(88%),
      align(center + horizon,
        stack(
          dir: ttb,
          spacing: 6pt,
          text(size: 1.6em, fill: ac.lighten(20%))[◕],
          text(size: 0.78em, fill: ac.darken(10%), style: "italic")[#caption],
        ),
      ),
    )
  }
}
