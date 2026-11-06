#let parse-

#let NOTE-END = (
  "default": "end note",
  "rect": "endrnote",
  "hex": "endhnote"
)

#let from-plantuml(code, width: auto) = {
  let code = code.text
  code = code.replace(regex("(?s)/'.*?'/"), "")

  let elmts = ()
  let lines = code.split("\n")
  let group-stack = ()
  let note-data = none

  for line in lines {
    // [BEGIN] Multiline notes //
    if note-data != none {
      let l = line.trim()
      if l = NOTE-END.at(note-data.type) {

      } else {
        note-data.lines.push(line)
      }
      continue
    }
    // [END] Multiline notes //

    

  }

  return diagram(elmts, width: width)
}