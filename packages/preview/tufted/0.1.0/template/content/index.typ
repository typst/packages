#import "../config.typ": template, tufted
#import "@preview/cmarker:0.1.7"
#show: template

= Tufted

#tufted.margin-note({
  image("imgs/tufted-duck-female-with-duckling.webp")
  image("imgs/tufted-duck-male.webp")
})

#tufted.margin-note[
  The tufted duck (_Aythya fuligula_) is a medium-sized diving duck native to Eurasia. Known for its diving ability, it can plunge to great depths to forage for food.
]

// NOTE: This page is automatically generated from the package's README.md file.
// See the implementation below.

#{
  let md-content = read("../assets/README.md")
  let md-content = md-content.trim(regex("\s*#.+?\n")) // Remove first-level heading

  // Render markdown content with custom image handling
  cmarker.render(
    md-content,
    scope: (
      image: (source, alt: none, format: auto) => figure(image(
        "../../" + source, // Modify paths for images
        alt: alt,
        format: format,
      )),
    ),
  )
}
