#let chapter-opener(number) = {
  let graphics = (
    "../figures/artwork/01_earthrise.svg",
    "../figures/artwork/02_liftoff.svg",
    "../figures/artwork/03_telescope.svg",
    "../figures/artwork/04_satellite.svg",
    "../figures/artwork/05_ground_station.svg",
  )

  if number >= 1 and number <= graphics.len() {
    move(dy: -22pt, image(graphics.at(number - 1), width: 116pt))
  }
}
