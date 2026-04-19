/* TODOs: zie dat de kleurtjes & todo-ballon settings overeenkomen met semantiek */
#import "@preview/drafting:0.2.2": *
#import "/src/i18n.typ"
/*#set-page-properties() // whenever page is reconfigured
 * After importing, use this...
 */

#let note(pos: "margin", ..kwargs) = {
// pos: margin (=auto), left, right
//      block, inline (inspired by CSS display)
    if pos in ("margin", "left", "right") {
        let s = if pos == "left"  {left}
           else if pos == "right" {right}
           else                   {auto}
        margin-note(side: s, ..kwargs)
    } else if pos in ("block", "inline") {
        inline-note(par-break: pos == "block", ..kwargs)
    } else {
        panic("Wrong argument for 'pos'.")
    }
}
#let todo-ballon(..kwargs, content) = {
  /* The return value needs to be an 'element', such that the fields can
   * be accessed (aka todo-ballon.has("fill") is true). The 'set' rules
   * are thus applied inside the content of 'rect'.
   */
  rect(inset: 0.3em, radius: 0.5em, ..kwargs)[
      #set text(0.75em)
      #set par(leading:0.4em)
      #content
  ]
}

#let todo-outline = note-outline.with(title: i18n.list_todos) // alias
// Default todo
#let todo = note.with(rect: todo-ballon)
// Variations of todo
#let todo-unsure = todo.with(
        stroke: maroon,
        fill  : maroon.lighten(70%))
#let todo-add    = todo.with(
        stroke: blue,
        fill  : blue.lighten(60%))
#let todo-change = todo.with(
        stroke: red,
        fill  : red.lighten(50%))
