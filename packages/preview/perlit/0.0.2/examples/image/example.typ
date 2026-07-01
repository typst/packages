#import "@preview/perlit:0.0.2": draw

#draw(
  json("/example.canvas"),
  velocity: 0.1,
  curve: false,
  file-handlers: (
    "jpg": (path: str, length: length, ..args) => {
      image(path, width: length)
    },
  ),
)
