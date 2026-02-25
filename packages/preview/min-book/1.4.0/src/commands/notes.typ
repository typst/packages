/**
== Note
:note:

Adds an end note, an alternative for footnotes but placed inside of page body
instead of its footer. End notes generally appears in a separated page at
the end of the current section, right before the next heading.
**/
#let note(
  numbering: auto, /// <- auto | string
    /// Custom note numbering (restarts note counter when set). |
  body, /// <- content <required>
    /// The content of the end note. |
) = context {
  h(0pt, weak: true) // remove neighbor spaces
  
  import "@preview/nexus-tools:0.1.0": storage, has
  import "../orig.typ"
  
  let selected = selector(heading).before(here())
  let level = counter(selected).display() // numbering of current heading
  let count = counter("note:count")
  let numbering = numbering
  let labels = (:)
  let data = (:)
  let ref = (:)
  let number
  
  // Retrieve/store note numbering
  if numbering == auto {
    numbering = storage
      .get("note", (:), namespace: "min-book")
      .at("numbering", default: "1")
    number = orig.numbering(numbering, count.get().at(0))
  }
  else {
    let value = (numbering: numbering)
    
    storage.add("note", value, namespace: "min-book", append: true)
    
    number = orig.numbering(numbering, 1)
    count.update(1)
  }
  
  labels = (
    data: "note:" + level + "-" + number,
    ref: "note:" + level + "-" + number + "-ref",
  )
  data = (
    this: labels.data,
    dest: labels.ref,
    id: strong(number + ":"),
    data: body,
  )
  ref = (
    this: labels.ref,
    dest: labels.data,
    body: number,
  )
  
  // Store note data
  storage.this.update(curr => {
    if not has.key(curr.min-book, "note") { curr.min-book.insert("note", (:)) }
    if not has.key(curr.min-book.note, level) {
      curr.min-book.note.insert(level, ())
    }
    
    curr.min-book.note.at(level).push(data)
    curr
  })
  
  [#metadata(ref) #label("note:ref-placeholder")]
  
  count.step()
}


// internal: Insert notes before the next heading
#let insert(body, new-page: true) = {
  import "@preview/nexus-tools:0.1.0": storage, its
  import "../orig.typ"
  
  let tmp = [#metadata("#note placeholder") #label("note:data-placeholder")]
  let doc = body.at("children", default: ())
  let index = ()
  let added = 0
  
  // Insert temporary placeholders before headings
  for (index, item) in doc.enumerate() {
    if item.func() == heading {
      doc.insert(index + added, tmp)
      
      added += 1
    }
  }
  doc.push(tmp) // additional placeholder at the end
  
  show <note:ref-placeholder>: it => {
    let ref = it.value
    let link = link(label(ref.dest), ref.body)
    
    [#super(link) #label(ref.this)]
  }
  show <note:data-placeholder>: it => context {
    let stored = storage.final("note", (), namespace: "min-book")
    
    if not its.empty(stored) {
      let selected = selector(heading).before(here())
      let level = counter(selected).display() // numbering of current heading.
      
      stored = stored.at(level, default: ()) // notes for current heading.
      
      if not its.empty(stored) {
        if new-page {pagebreak(weak: true)} else {v(par.spacing)}
        
        for note in stored {
          let note = [
            #link(label(note.dest), note.id) #label(note.this)
            #note.data
          ]
          
          par(note, first-line-indent: 0pt, hanging-indent: 1em)
        }

        if new-page {pagebreak(weak: true)}
      }
      
      counter("note:count").update(1) // restart note count for next heading.
    }
  }
  
  doc.join()
}