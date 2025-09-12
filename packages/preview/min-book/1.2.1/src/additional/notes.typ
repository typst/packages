/**
== Note Command

:note:

Adds an end note, an alternative for footnotes but placed inside of the page
instead of its margins. End notes appear at its own page at the end of the
current section, right before the next heading.
**/
#let note(
  numbering: auto, /// <- auto | string
    /// Custom note numbering — a standard numbering string. |
  content, /// <- content <required>
    /// The content of the end note. |
) = context {
  import "../utils.typ"
  
  // Find the level (numbering) of current section heading:
  let selector = selector(heading).before(here())
  let level = counter(selector).display().replace(".","-")
  
  let numbering = numbering
  if numbering == auto {
    numbering = utils.storage(get: "note.numbering", "1")
  }
  else {
    utils.storage(add: "note", (numbering: numbering))
  }
  
  let count = counter("min-book-note-count")
  counter("min-book-note-count").step()
  
  let this-note = (
    number: count.get().at(0),
    data: content,
    numbering: numbering
  )
  
  // Push a new value to note.level array
  utils.storage(add: "note." + level + "+", this-note)
  
  let note-number = utils.numbering-std(numbering, ..count.get())
  let note-label = level + "_" + utils.numbering-std("1", ..count.get())

  // Set note as #super[NUMBER ::LABEL::] to be managed later
  [#super(note-number + " ::" + note-label + "::")#label(note-label)]
}


// INTERNAL: notes.insert() inserts notes in the document at the right place.
#let insert(body) = {
  import "../utils.typ"
  
  let new-body = body.at("children", default: ())
  let h-index = ()
  
  // Get index of all headings in body.children
  for n in range(new-body.len()) {
    let item = new-body.at(n)
    
    if item.func() == heading {
      h-index.push(n)
    }
  }

  // Insert anchor <note> before each heading obtained
  for n in range(h-index.len()) {
    new-body.insert(h-index.at(n) + n, [#metadata("Note anchor") <note>])
  }

  // Insert a final anchor <note> at the end of the document
  new-body.push([#metadata("Note anchor") <note>])

  // Make the edited new-body into the document body
  body = new-body.join()

  // Make the first note be note 1, instead of note 0.
  counter("min-book-note-count").step()

  // Swap the <note> for the actual notes in the current section, if any.
  show <note>: it => {
    context if utils.storage().final().at("note", default: (:)) != (:) {
      // Find the level (numbering) of current section heading:
      let selector = selector(heading).before(here())
      let level = counter(selector).display().replace(".", "-")

      // Show notes only if there are any in this section
      let notes = utils.storage(get: "note." + level)
      if notes != none {
        pagebreak(weak: true)

        // Insert the notes:
        for note in notes {
          par(
            first-line-indent: 0pt,
            spacing: 0.75em,
            hanging-indent: 1em
          )[
            // Link to the note marker in the text:
            #link(
              label(level + "_" + str(note.number)),
              strong(utils.numbering-std(note.numbering, note.number) + ":")
            )
            // Insert <LEVEl_NUMBER_content> for cross-reference
            #label(level + "_" + str(note.number) + "_content")
            #note.data
          ]
        }

        pagebreak(weak: true)
      }

      // Make every section notes start at note 1
      counter("min-book-note-count").update(1)
    }
  }
  
  // Manages note references
  show super: it => {
    let note-regex = regex("::[0-9-_]+::")
    
    // #note: Parses #super("NUMBER ::LABEL::") -> #link(<LABEL>)[#super("NUMBER")]
    if it.body.text.ends-with(note-regex) {
      let note-label = it.body.text.find(note-regex).trim(":") + "_content"
      let note-number = it.body.text.replace(note-regex, "").trim()
      
      // Link to the actual note content:
      link(label(note-label))[#super(note-number)]
    } else {
      it
    }
  }
  
  body
}