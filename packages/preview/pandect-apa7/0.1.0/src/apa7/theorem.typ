/// Mathematical and STEM Academic Blocks module for APA 7th Edition.
///
/// Implements formal STEM theorem environments (Theorems, Definitions, Lemmas,
/// Corollaries, Propositions, Examples, Proofs) and accessible math equation
/// helpers with full PDF/UA-1 conformance and multilingual localization (EN/ES).

/// Counters for each academic environment.
#let theorem-counter = counter("apa-theorem")
#let definition-counter = counter("apa-definition")
#let lemma-counter = counter("apa-lemma")
#let corollary-counter = counter("apa-corollary")
#let proposition-counter = counter("apa-proposition")
#let example-counter = counter("apa-example")

/// Helper for accessible inline math equations (PDF/UA-1).
///
/// Example: `#eq("f of x", $f(x)$)`
#let eq(alt, body) = math.equation(alt: alt, block: false, body)

/// Helper for accessible display/block math equations (PDF/UA-1).
///
/// Example: `#deq("E equals m c squared", $E = m c^2$)`
#let deq(alt, body) = math.equation(alt: alt, block: true, body)

/// ── Standard Mathematical Operators in Spanish (Paridad Notacional) ──
/// Trigonometric functions
#let sen = math.op("sen")
#let tg = math.op("tg")
#let ctg = math.op("ctg")
#let cotg = math.op("cotg")
#let cosec = math.op("cosec")
#let arcsen = math.op("arcsen")
#let arctg = math.op("arctg")
#let arcctg = math.op("arcctg")
#let arccotg = math.op("arccotg")

/// Hyperbolic functions
#let senh = math.op("senh")
#let tgh = math.op("tgh")
#let ctgh = math.op("ctgh")
#let cotgh = math.op("cotgh")
#let cosech = math.op("cosech")

/// Arithmetic & Number Theory
#let mcd = math.op("mcd")
#let mcm = math.op("mcm")
#let MCD = math.op("MCD")
#let MCM = math.op("MCM")

/// Linear Algebra & Vector Calculus
#let rot = math.op("rot")
#let traza = math.op("traza")
#let rango = math.op("rango")

/// Formats a formal Theorem environment.
///
/// Parameters:
/// - title: Optional name of the theorem (e.g. "Mean Value Theorem").
/// - lang: "en" | "es" (default: "en").
/// - body: Content of the theorem (rendered in italics by convention).
#let apa-theorem(title: none, lang: "en", body) = {
  theorem-counter.step()
  context {
    let num = theorem-counter.get().first()
    let label = if lang == "es" [Teorema #num] else [Theorem #num]
    let title-str = if title != none [ (#title)] else []
    block(spacing: 1em)[
      #strong[#label#title-str.] #emph(body)
    ]
  }
}

/// Formats a formal Definition environment.
///
/// Parameters:
/// - title: Optional concept being defined (e.g. "Continuity").
/// - lang: "en" | "es" (default: "en").
/// - body: Content of the definition.
#let apa-definition(title: none, lang: "en", body) = {
  definition-counter.step()
  context {
    let num = definition-counter.get().first()
    let label = if lang == "es" [Definición #num] else [Definition #num]
    let title-str = if title != none [ (#title)] else []
    block(spacing: 1em)[
      #strong[#label#title-str.] #body
    ]
  }
}

/// Formats a formal Lemma environment.
#let apa-lemma(title: none, lang: "en", body) = {
  lemma-counter.step()
  context {
    let num = lemma-counter.get().first()
    let label = if lang == "es" [Lema #num] else [Lemma #num]
    let title-str = if title != none [ (#title)] else []
    block(spacing: 1em)[
      #strong[#label#title-str.] #emph(body)
    ]
  }
}

/// Formats a formal Corollary environment.
#let apa-corollary(title: none, lang: "en", body) = {
  corollary-counter.step()
  context {
    let num = corollary-counter.get().first()
    let label = if lang == "es" [Corolario #num] else [Corollary #num]
    let title-str = if title != none [ (#title)] else []
    block(spacing: 1em)[
      #strong[#label#title-str.] #emph(body)
    ]
  }
}

/// Formats a formal Proposition environment.
#let apa-proposition(title: none, lang: "en", body) = {
  proposition-counter.step()
  context {
    let num = proposition-counter.get().first()
    let label = if lang == "es" [Proposición #num] else [Proposition #num]
    let title-str = if title != none [ (#title)] else []
    block(spacing: 1em)[
      #strong[#label#title-str.] #emph(body)
    ]
  }
}

/// Formats a formal Example environment.
#let apa-example(title: none, lang: "en", body) = {
  example-counter.step()
  context {
    let num = example-counter.get().first()
    let label = if lang == "es" [Ejemplo #num] else [Example #num]
    let title-str = if title != none [ (#title)] else []
    block(spacing: 1em)[
      #strong[#label#title-str.] #body
    ]
  }
}

/// Formats a formal mathematical Proof environment with end-of-proof QED symbol.
///
/// Parameters:
/// - title: Optional custom proof header (defaults to "Proof." or "Demostración.").
/// - lang: "en" | "es" (default: "en").
/// - body: Steps of the mathematical proof.
#let apa-proof(title: none, lang: "en", body) = {
  let label = if title != none {
    title
  } else if lang == "es" {
    [Demostración.]
  } else {
    [Proof.]
  }
  let qed-sym = math.equation(alt: "QED", $square$)
  block(spacing: 1em)[
    #emph(label) #body
    #h(1fr) #qed-sym
  ]
}
