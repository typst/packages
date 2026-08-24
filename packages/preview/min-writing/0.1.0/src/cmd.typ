/// = Additional commands

#let original = (figure: figure, align: align)

/**
== Figure
:figure:
Adds the option to insert the figure source.
**/
#let figure(
  source: none, /// <- content | string
    /// Figure source. |
  align: center, /// <- alignment
    /// Align the figure. |
  ..args, /// <- arguments
    /// Any `#figure` options. |
  body /// <- content
    /// Figure content. |
) = context {
  set original.figure.caption(position: top)
  
  show block: set original.align(align)
  
  block({
    set original.align(center)
    
    (original.figure)(..args, body)
    
    v(-par.leading)
    text(source, size: 1em - 2pt)
  })
}


/**
== Boxed text
:boxed:
Inserts inline text boxes.
**/
#let boxed(
  stroke: auto, /// <- stroke
    /// Set border stroke. |
  body /// <- content | string
    /// Text to be boxed. |
) = context {
  import "@preview/catppuccin:1.1.0": get-flavor
  
  let stroke = stroke
  
  if stroke == auto {
    import "@preview/nexus-tools:0.3.0": storage
    
    stroke = storage.get("accent-color", gray, namespace: "min-writing")
  }
  
  box(body, stroke: stroke, outset: (y: 2pt), inset: (x: 2pt))
}


/**
== Mermaid diagrams
:mermaid:
Inserts Mermaid flowcharts and diagrams.

..args <- arguments
  Any~#univ("merman") options.
**/
#let mermaid(..args) = {
  import "@preview/merman:0.1.0": mermaid
  
  mermaid(..args)
}