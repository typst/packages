#import "@preview/perlit:0.0.2": draw

#draw(
  json("/outside.canvas"),
  velocity: 0.1,
  curve: false,
  file-handlers: (
    "canvas": (path: str, ..args) => {
      draw(json(path), scale: 0.8, ..args)
    },
  ),
)
