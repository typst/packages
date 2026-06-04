#import "metadata.typ": *
#import "@preview/grotesk-cv:0.1.0": *

#show: layout

#set list(marker: [‣])

#create-header(use-photo: true)

#grid(
  columns: (71%, 25%),
  gutter: 20pt,
  stroke: none,
  stack(
    spacing: 20pt,
    import-section("profile"),
    import-section("experience"),
    import-section("education"),
    //import-section("references"),
  ),
  stack(
    spacing: 20pt,
    import-section("skills"),
    import-section("languages"),
    import-section("other_experience"),
    import-section("references"),
  ),
)
