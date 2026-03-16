#let package(name) = {
  let packages = (
    abbr: "0.3.0",
    tum-tastic-thesis: "0.1.1",
  )

  let version = packages.at(name)

  "@preview/" + name + ":" + version
}
