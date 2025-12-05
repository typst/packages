#let package(name) = {
  let packages = (
    citegeist: "0.1.0",
    codly: "1.3.0",
    glossarium: "0.5.8",
    hydra: "0.6.1",
    linguify: "0.4.2",
  )

  let version = packages.at(name)

  "@preview/" + name + ":" + version
}