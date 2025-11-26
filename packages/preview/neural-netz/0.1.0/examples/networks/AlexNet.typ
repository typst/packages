#set page(width: auto, height: auto, margin: 5mm)

#let layers = (
  (
    type: "conv",
    widths: (0.5,),
    height: 8,
    depth: 8,
    label: "conv1",
    channels: (64, 16),
  ),
  (
    type: "pool",
    height: 6,
    depth: 6,
    label: "pool1",
    channels: ("", 8),
  ),
  (
    type: "conv",
    widths: (1,),
    height: 6,
    depth: 6,
    label: "conv2",
    channels: ("", 8),
  ),
  (
    type: "pool",
    height: 4,
    depth: 4,
    label: "pool2",
    channels: ("", 4),
  ),
  (
    type: "conv",
    widths: (4, 2.5, 2.5),
    height: 2,
    depth: 2,
    label: "conv3",
    channels: (384, 256, 256, 4),
  ),
  (
    type: "pool",
    height: 1,
    depth: 1,
    label: "pool3",
    channels: ("", 2),
  ),
  (
    type: "fc",
    label: "fc4",
    channels: (4096,),
    height: 8,
    depth: 0.5,
    offset: 1,
  ),
  // FC5
  (
    type: "fc",
    label: "fc5",
    channels: (4096,),
    height: 8,
    depth: 0.5,
    offset: 0.5,
  ),
  // FC6+softmax
  (
    type: "fc",
    label: "fc6+softmax",
    channels: (10,),
    height: 1,
    depth: 0.5,
    offset: 1,
  ),
)

#draw-network(layers, palette: "warm", show-relu: true)