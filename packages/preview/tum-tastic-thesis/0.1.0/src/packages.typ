#let package(name) = {
  let packages = (
    algo: "0.3.6",
    cetz: "0.4.2",
  )

  let version = packages.at(name)

  "@preview/" + name + ":" + version
}
