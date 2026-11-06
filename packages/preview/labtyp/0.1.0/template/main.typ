#import "@preview/labtyp:0.1.0": lablist, lab, mset
// #import "../lib.typ": lablist, lab, mset

#mset(values: (
  title: "The title of the document", 
  author: "Jane Doe", 
  date: "2025-07-31",
  newlab: "more"))

= `labtyp` 
`labtyp` is for labeling text documents like dialogue threads or legal documents for precise citing. 

// A json file with the labels in a document can be produced using `typst query`

// ```bash
// typst query main.typ <lab> > doclabels.json
// ``` 
// Which can then be translated into `hayagriva` or `biblatex` formats. 


// `labtyp` defines 3 commands:

// - `lab`: creates an in-place label, defined by `key`, `text` and  `note`
// - `mset`: adds metadata that gets assigned to _subsequent labels_ (i.e. labels defined below the current mset command in the document), like the title of the document, date, pagenumber in the original document, this can be expanded with any key for other labelling needs

//   - Each label ends up being a concatenation of the label information, and the mset information. 
// - `lablist`: prints a table of the labels created 


// #mset(values: (opage: 1))
// #mset(values: (date: "2025-08-01", opage: 2))

// = Labelling in vscode

// In order to label currently selected text in vscode using `ctrl+L`, define the following in `keybindings.json`:

// ```json
//     {
//         "key": "ctrl+L",
//         "command": "editor.action.insertSnippet",
//         "when": "editorTextFocus && editorLangId == 'typst'",
//         "args": {"snippet": "#lab(\"$1\",\"${TM_SELECTED_TEXT}\",\"$2\")"}
//     }
// ```
= Example
This is what a labelled document looks like in typst:
```typst
#mset(values: (
  title: "The title of the document", 
  author: "Jane Doe", 
  date: "2025-07-31",
  newlab: "more"))
=== A labelled dialogue
#mset(values:(date:"2025-07-1", author:"X"))
X: #lab("mail1","Can you get some rice and coffee on the way home","email by X to Y")
#mset(values:(date:"2025-07-2", author:"Y"))
Y: #lab("mail2","Sorry, I didn't check my mail.. ","reply by Y to X")
= List of Labels
#lablist()
```
== Rendered
Below the same dialogue rendered:

=== A labelled dialogue
#mset(values:(date:"2025-07-1", author:"X"))
X: #lab("mail1","Can you get some rice and coffee on the way home","email by X to Y")

#mset(values:(date:"2025-07-2", author:"Y"))

Y: #lab("mail2","Sorry, I didn't check my mail.. ","reply by Y to X")

= List of Labels
#lablist()
