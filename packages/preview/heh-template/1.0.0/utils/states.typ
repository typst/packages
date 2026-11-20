// Contient la configuration du document
#let heh-config = state(
  "heh-config",
  (
    document: (:),
    print: (:),
    campus: (:),
  ),
)


#let slidegroups-count = counter("slidegroups")
#let group-slide-count = counter("group-slide-count")
#let group-title-state = state("group-title", "")
#let group-current-slide = counter("group-current-slide")

