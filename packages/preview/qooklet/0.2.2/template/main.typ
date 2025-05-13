#import "@preview/qooklet:0.2.2": *

#show: qooklet.with(
  title: "",
  info: toml("../config/info.toml").global,
  outline-on: false,
  paper: "iso-b5",
)
