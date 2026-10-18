#import "planet.typ": *
#import "surfaces.typ": uranus-ring, neptune-ring

// default radii
#let dr = (
  "sun": 4.0,
  "mercury": 0.35,
  "venus": 0.87,
  "earth": 1.0,
  "moon": 0.27,
  "mars": 0.53,
  "jupiter": 2.5,
  "saturn": 2,
  "uranus": 1.5,
  "neptune": 1.45,
  "pluto": 0.5,
)

// default names
#let dn = (
  "sun": "Sun",
  "mercury": "Mercury",
  "venus": "Venus",
  "earth": "Earth",
  "moon": "Moon",
  "mars": "Mars",
  "jupiter": "Jupiter",
  "saturn": "Saturn",
  "uranus": "Uranus",
  "neptune": "Neptune",
  "pluto": "Pluto",
)

#let sun(..args) = planet(surface: "sun", radius: dr.at("sun"), name: dn.at("sun"), ..args)
#let mercury(..args) = planet(surface: "mercury", radius: dr.at("mercury"), name: dn.at("mercury"), ..args)
#let venus(..args) = planet(surface: "venus", radius: dr.at("venus"), name: dn.at("venus"), ..args)
#let earth(..args) = planet(surface: "earth", radius: dr.at("earth"), name: dn.at("earth"), ..args)
#let moon(..args) = planet(surface: "moon", radius: dr.at("moon"), name: dn.at("moon"), ..args)
#let mars(..args) = planet(surface: "mars", radius: dr.at("mars"), name: dn.at("mars"), ..args)
#let jupiter(..args) = planet(surface: "jupiter", radius: dr.at("jupiter"), name: dn.at("jupiter"), ..args)
#let saturn(..args) = planet(surface: "saturn", radius: dr.at("saturn"), rings: true, name: dn.at("saturn"), ..args)
#let uranus(..args) = planet(surface: "uranus", radius: dr.at("uranus"), ring: 1.5, ring-color: uranus-ring, name: dn.at("uranus"), ..args)
#let neptune(..args) = planet(surface: "neptune", radius: dr.at("neptune"), ring: 1.5, ring-color: neptune-ring, name: dn.at("neptune"), ..args)
#let pluto(..args) = planet(surface: "pluto", radius: dr.at("pluto"), name: dn.at("pluto"), ..args)

