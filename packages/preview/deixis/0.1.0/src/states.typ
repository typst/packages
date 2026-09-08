#let deixis-system = std.state("deixis-system", (
  note-uid: 0,
  stack: (),
  blocks: (:),
  counters: (:),
  notes: (:), // str(internal-id) -> note-data
  id-index: (:), // str(id) -> str(internal-id)
  label-index: (:), // str(label) -> str(internal-id)
))
#let deixis-setup-state = std.state("deixis-setup-state", false)
#let deixis-auto-id = "deixis-auto"
