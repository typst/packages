#set page(width: auto, height: auto, margin: 5mm)

#draw-network((
  (type: "input", height: 8, depth: 8, label: "Input", name: "img"),
  (type: "conv", channels: ("64", "64", "I"), widths: (0.5, 0.5), height: 8, depth: 8, label: "Conv1", name: "c1"),
  (type: "pool", height: 6.5, depth: 6.5, name: "p1"),
  (type: "conv", channels: ("128", "128", "I/2"), widths: (0.6, 0.6), height: 6.5, depth: 6.5, label: "Conv2", name: "c2"),
  (type: "pool", height: 5, depth: 5, name: "p2"),
  (type: "conv", channels: ("256", "256", "256", "I/4"), widths: (0.7, 0.7, 0.7), height: 5, depth: 5, label: "Conv3", name: "c3"),
  (type: "pool", height: 3.5, depth: 3.5, name: "p3"),
  (type: "conv", channels: ("512", "512", "512", "I/8"), widths: (0.8, 0.8, 0.8), height: 3.5, depth: 3.5, label: "Conv4", name: "c4"),
  (type: "pool", height: 2.5, depth: 2.5, name: "p4"),
  (type: "conv", channels: ("512", "512", "512", "I/16"), widths: (0.8, 0.8, 0.8), height: 2.5, depth: 2.5, label: "Conv5", name: "c5"),
  (type: "pool", height: 1.5, depth: 1.5, name: "p5"),
  (type: "conv", channels: ("4096", "4096"), widths: (1.5, 1.5), height: 1.5, depth: 1.5, label: "fc to conv", name: "fc"),
  
  // Upsampling path
  (type: "conv", channels: ("K", "I/32"), widths: (0.3,), height: 2.5, depth: 2.5, label: "fc8 to conv", name: "s32", offset: 0.8, show-relu: false),
  (type: "deconv", channels: ("K", "I/16"), height: 3.5, depth: 3.5, name: "up1", offset: 1),
  (type: "sum", radius: 0.5, label: "+", name: "add1", offset: 1),
  (type: "deconv", height: 5, depth: 5, channels: ("K", "I/8"), name: "up2", offset: 0.5),
  (type: "sum", radius: 0.5, label: "+", name: "add2", offset: 1),
  (type: "deconv", height: 8, depth: 8, channels: ("K",), label: "Deconv", name: "up3", offset: 0.5),
  (type: "convsoftmax", height: 8, depth: 8, channels: ("K", "I"), label: "softmax", offset: 1),
), connections: (
  (from: "p4", to: "add1", type: "skip", mode: "flat", pos: 3,
   layers: (
    (type: "conv", channels: ("K", "I/16"), widths: (0.3,), height: 2, depth: 3.5, name: "s16", show-relu: false),
   )
  ),
  (from: "p3", to: "add2", type: "skip", mode: "flat", pos: 6,
  layers: (
    (type: "conv", channels: ("K", "I/8"), widths: (0.3,), height: 2, depth: 3.5, name: "s16", show-relu: false),
  ))
),
show-relu: true,
)