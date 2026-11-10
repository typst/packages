/// Scope figure, table, and equation numbers to a chapter or appendix.
///
/// The chapter number is captured in each element's numbering function, so a
/// reference from another chapter keeps the target's prefix. Put a chapter's
/// headings and content inside the scope. `chapter` is manual: nothing reads
/// the visible heading counter, so pass the chapter number yourself. Heading
/// numbering and chapter page breaks remain the document class's responsibility.
///
/// ```example
/// #chapter-numbering(chapter: 1)[
///   = Methods
///   #figure(rect(), caption: [First figure]) <fig:methods>
/// ]
/// #chapter-numbering(chapter: 2)[
///   = Results
///   See @fig:methods.
/// ]
/// ```
///
/// - body (content): headings and content belonging to this chapter
/// - chapter (int): positive chapter number used in prefixes; defaults to 1
/// - appendix (bool): use `"A.N"` figure/table prefixes and `"(A.N)"`
///   equations, regardless of `chapter`; defaults to false
///
/// Only image figures, table figures, and equations are reset. Headings are not
/// renumbered by this component.
#let chapter-numbering(body, chapter: 1, appendix: false) = {
  assert(type(chapter) == int and chapter > 0, message: "chapter must be a positive integer")
  let figure-format = (n) => numbering(if appendix { "A.1" } else { "1.1" }, chapter, n)
  let equation-format = (n) => numbering(if appendix { "(A.1)" } else { "(1.1)" }, chapter, n)
  set figure(numbering: figure-format)
  set math.equation(numbering: equation-format)
  counter(figure.where(kind: image)).update(0)
  counter(figure.where(kind: table)).update(0)
  counter(math.equation).update(0)
  body
}
