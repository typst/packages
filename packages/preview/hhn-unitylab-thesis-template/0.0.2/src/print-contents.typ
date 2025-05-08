
// ###############################################################################
//
//  !   Part of the Template            !
//  !   Should not be touched           !
//  !   Modifications at your own Risk  !  
//
// ###############################################################################


#let print-contents() = {

  // Content Config
  // Appendix Page Number
  // --------------------------------------------------------
  show outline.entry.where(): item => { 
    context {    
      if item.element.supplement == [Appendix] {
        //item.element.body + box(width: 1fr,item.fill) + [A] + item.page() + linebreak()
        item.indented(item.prefix(), item.inner())
      }
      else {item}
    }
  } 
  
  // Main Chapters Strong
  // --------------------------------------------------------
  show outline.entry.where(level: 1,): item => { 
   
    if item.element.body.has("children") {
      if item.element.body.children.at(0) == [Figure] { return item }
      if item.element.body.children.at(0) == [Table] { return item }
      if item.element.body.children.at(0) == [Diagram] { return item }
      if item.element.body.children.at(0) == [Code Snippet] { return item }
      if item.element.body.children.at(0) == [Callout] { return item }
    }
    
    v(11pt, weak: true)
    strong(item)
  }

  
  // Content Tables
  // --------------------------------------------------------
  [
    #pagebreak()
    = Contents
    #outline(title: none)<List_of_Contents>
    #pagebreak()
  

    // Images
    // --------------------------------------------------------
    #context if counter(figure.where(kind: image)).final().last() > 0 [
      = List of Figures
      #outline(
        title: none,
        target: figure.where(kind: image),
      )
    ]
  
    
    // Tables
    // --------------------------------------------------------
    #context if counter(figure.where(kind: image)).final().last() > 0 [
      = List of Tables
      #outline(
        title: none,
        target: figure.where(kind: table),
      )
    ]
    
    // Diagrams
    // --------------------------------------------------------
    #context if counter(figure.where(kind: "diagram")).final().last() > 0 [
      = List of Diagrams
      #outline(
        title: none,
        target: figure.where(kind: "diagram"), 
      )
    ]
  
    
    // Code Snippets
    // --------------------------------------------------------
    #context if counter(figure.where(kind: raw)).final().last() > 0 [
      = List of Code
      #outline(
        title: none,
        target: figure.where(kind: raw), 
      )
    ]
  
    
    // Callouts
    // --------------------------------------------------------
    #context if counter(figure.where(kind: "callout")).final().last() > 0 [
      = List of Callouts
      #outline(
        title: none,
        target: figure.where(kind: "callout"), 
      )
    ]
  ]
}




