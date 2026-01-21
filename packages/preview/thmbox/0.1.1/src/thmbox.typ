#import "colors.typ"
#import "translations.typ"

#let thm-counter = counter("thmbox")
#let sans-fonts = ("New Computer Modern Sans",)

/// This function initialized the thmbox package 
/// to work in the current document.
/// 
/// Use as `#show: thmbox-init()` before using any of the
/// functions this package provides.
///
/// - counter-level (int): How many numbers the counter should have. 2 makes the numbers have the format X.X, for example.
#let thmbox-init(counter-level: 2) = (doc) => {
  // Metadata
  [
    #metadata(counter-level) <counter-level>
  ]
  
  thm-counter.update((0,0))

  show heading: it => {
    if it.level < counter-level {
      context thm-counter.update(
        (..counter(heading).get(), 0)
      )
    }
    it
  }
  // This is needed to make the counters work. If this is not
  // wanted, use `counter-level` 1.
  set heading(numbering: "1.1")

  show ref: it => if (
    it.element != none 
    and it.element.func() == figure 
    and it.element.kind == "thmbox"
  ) {
    let supplement = if it.citation.supplement != none { 
      it.citation.supplement
    } else {
      it.element.supplement
    }
    // q is a query result containing the numbering
    // using the correct numbers
    let q = query(
      selector(<thmbox-numbering>).after(it.target)
    ).first()
    let c = (q.value)(q.location())
    link(it.target, [#supplement #c])
  } else {
    it
  }

  doc
}

/// Creates a stylized box for containing theorems or really 
/// anything else (specified in the `variant` parameter).
/// This is displayed in the title bar and after that, there will be
/// a counter and a name for the specific definition/theorem/...
/// it contains (specified in the `title` parameter).
/// 
/// Additionally, a colored bar will be on the left, marking the limits of the box.
/// 
/// Everything is contained in a `figure`, so `set` or `show` rules that affect figures also affect the thmbox.
/// Things like breaking over pages or spanning multiple columns must be configured using this technique.
///
/// - color (color): The color of the colored bar and the title
/// - variant (content): The variant of the box. For example, "Theorem" or "Definition", etc.
/// - title (content): A title for what the box is about. For example, "Vector Space" or "Euler's Identity"
/// - numbering (none | string | function): A numbering string or function for how the number of this box should be displayed (also applies for references). Can be `none` for unnumbered boxes
/// - sans (boolean): If the body should be using a sans-serif font (which can be changed using the `sans-fonts` parameter)
/// - fill (none | color): The background color of the box 
/// - bar-thickness (length): The thickness of the colored bar
/// - sans-fonts (array): What fonts to use in the body if `sans` is true
/// - title-fonts (array): What fonts should be used in the title bar.
/// - rtl (boolean): Whether the box should be using a right-to-left layout
/// - body (content): The body of the box
/// -> content
#let thmbox(
  // Standard arguments for thmbox
  color: colors.dark-gray, 
  variant: "Thmbox", 
  title: none, 
  numbering: "1.1", 
  sans: true,
  fill: none,
  // Advanced styling
  bar-thickness: 3pt,
  sans-fonts: sans-fonts,
  title-fonts: sans-fonts,
  rtl: false,
  // Body
  body,
) = {
  return figure(
    caption: none,
    gap: 0em,
    kind: "thmbox",
    supplement: variant,
    outlined: false,
  )[
    // For having a correct counter in refs
    #if numbering != none [
      #context thm-counter.step(level: query(<counter-level>).first().value)
      #metadata(
        loc => std.numbering(numbering, ..(thm-counter.at(loc)))
      ) <thmbox-numbering>
    ]

    // rtl layout (not possible with context returning content)
    #let rtl = if rtl == auto {false} else {rtl}
    #set align(if rtl {right} else {left})
    
    #let bar = stroke(paint: color, thickness: bar-thickness)
      
    #block(
      stroke: (
        left: if rtl {none} else {bar},
        right: if rtl {bar} else {none},
      ),
      inset: (
        left: if rtl {0em} else {1em}, 
        right: if rtl {1em} else {0em}, 
        top: 0.6em, 
        bottom: 0.6em
      ),
      spacing: 1.2em,
      fill: fill,
    )[
      // Title bar
      #block(
        above: 0em,
        below: 1.2em,
      )[
        #set text(font: title-fonts, color, weight: "bold")
        #let counter-display = if numbering != none {
          context std.numbering(numbering, ..(thm-counter.get()))
        } else {none}
        #variant #counter-display
        #h(1fr)
        #title
      ]
      // Body
      #block(
        inset: (
          left: if rtl {1em} else {0em}, 
          right: if rtl {0em} else {1em}, 
          top: 0em, 
          bottom: 0em
        ),
        spacing: 0em,
        width: 100%,
      )[
        #if sans [
          #set text(font: sans-fonts)
          #body
        ] else [
          #body
        ]
      ]
    ]
  ]
}

/// A q.e.d.; can be used anywhere
///
/// -> content
#let qed() = {
  h(1fr)
  context { 
    set text(size: 0.8 * text.size)
    "☐"
  }
}

/// A simple proof environment, consisting of "Proof:" (can also be changed in the `title` parameter),
/// the actual proof, and a q.e.d. at the end (A q.e.d. can be placed anywhere; it is available as `qed()`).
///
/// - title (content): What is displayed as the introduction of this proof (by default, "Proof")
/// - body (content): The actual proof
/// -> content
#let proof(
  title: translations.proof,
  body
) = [
  #[
    #set text(style: "oblique", weight: "bold")
    #title;:
  ] 
  #body #qed()
]