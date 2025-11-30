#import "lib.typ": draw-network

= Neural Network Architecture Examples

== Example 1: ResNet50
ResNet50 with residual connections and bottleneck blocks.

#draw-network((
  (type: "input", image-file: "bird.jpg", width: 0, height: 7, depth: 7, channels: ("3", "224×224"), label: "Input", name: "input"),
  (type: "conv", widths: (0.5,), height: 7, depth: 7, label: "Conv1", name: "conv1", offset: 1.75),
  (type: "pool", height: 5.5, depth: 5.5, channels: ("64",)),
  
  // Residual Block 1
  (type: "conv", widths: (0.4, 0.4, 0.8), height: 5.5, depth: 5.5, label: "Block1", name: "res1a"),
  (type: "conv", widths: (0.4, 0.4, 0.8), height: 5.5, depth: 5.5, label: "Block1", name: "res1b"),
  (type: "conv", widths: (0.4, 0.4, 0.8), height: 5.5, depth: 5.5, label: "Block1", name: "res1c"),
  
  // Residual Block 2
  (type: "pool", height: 4, depth: 4, channels: ("256",)),
  (type: "conv", widths: (0.5, 0.5, 1.0), height: 4, depth: 4, label: "Block2", name: "res2a"),
  (type: "conv", widths: (0.5, 0.5, 1.0), height: 4, depth: 4, label: "Block2", name: "res2b"),
  (type: "conv", widths: (0.5, 0.5, 1.0), height: 4, depth: 4, label: "Block2", name: "res2c"),
  (type: "conv", widths: (0.5, 0.5, 1.0), height: 4, depth: 4, label: "Block2", name: "res2d"),
  
  // Residual Block 3
  (type: "pool", height: 3, depth: 3, channels: ("512",)),
  (type: "conv", widths: (0.6, 0.6, 1.2), height: 3, depth: 3, label: "Block3", name: "res3a"),
  // ... (simplified for brevity)
  
  (type: "gap", height: 1.5, depth: 1.5, channels: ("2048",), label: "GAP"),
  (type: "fc", height: 1, depth: 1, channels: ("1000",), label: "FC"),
  (type: "output", channels: ("1000",), label: "Output"),
), connections: (
  (from: "conv1", to: "res1b", type: "skip"),
  (from: "res1a", to: "res1c", type: "skip"),
  (from: "res1b", to: "res2a", type: "skip"),
  (from: "res2a", to: "res2c", type: "skip"),
  (from: "res2b", to: "res2c", type: "skip"),
  (from: "res2c", to: "res2d", type: "skip"),
), 
palette: "warm",
scale: 65%)

#pagebreak()

== Example 2: FCN-8s
Fully Convolutional Network for semantic segmentation with depth skip connections.

#draw-network((
  (type: "input", image-file: "bird.jpg", height: 8, depth: 8, label: "Input", name: "img"),
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
scale: 50%,
palette: "warm",
show-relu: true,
)

#pagebreak()

== Example 3: FCN-32s
Simplified fully convolutional network with single upsampling.

#draw-network((
  (type: "input", image-file: "bird.jpg", height: 8, depth: 8, label: "Image", name: "img"),
  (type: "conv", widths: (0.5, 0.5), height: 8, depth: 8, label: "Conv1", name: "c1"),
  (type: "pool", height: 6.5, depth: 6.5),
  (type: "conv", widths: (0.6, 0.6), height: 6.5, depth: 6.5, label: "Conv2", name: "c2"),
  (type: "pool", height: 5, depth: 5),
  (type: "conv", widths: (0.7, 0.7, 0.7), height: 5, depth: 5, label: "Conv3", name: "c3"),
  (type: "pool", height: 3.5, depth: 3.5),
  (type: "conv", widths: (0.8, 0.8, 0.8), height: 3.5, depth: 3.5, label: "Conv4", name: "c4"),
  (type: "pool", height: 2.5, depth: 2.5),
  (type: "conv", widths: (0.8, 0.8, 0.8), height: 2.5, depth: 2.5, label: "Conv5", name: "c5"),
  (type: "pool", height: 1.5, depth: 1.5),
  (type: "conv", widths: (1.0, 1.0), height: 1.5, depth: 1.5, label: "FC", name: "fc"),
  
  // Single upsampling
  (type: "conv", widths: (0.3,), height: 1.5, depth: 1.5, label: "Score", name: "score", offset: 1),
  (type: "deconv", height: 8, depth: 8, channels: ("K",), label: "Up32x", name: "up32", offset: 2),
  (type: "convsoftmax", height: 8, depth: 8, channels: ("K",), label: "Softmax", offset: 1),
),
scale: 80%,
show-relu: true,
)

#pagebreak()

== Example 4: HED (Holistically-Nested Edge Detection)
Multi-scale edge detection with side outputs and diverging connections.

#draw-network((
  (type: "input", height: 8, depth: 8, channels: ("3", "H×W"), label: "Input", name: "in"),
  
  // Encoder path
  (type: "conv", widths: (0.5, 0.5), height: 8, depth: 8, label: "Conv1", name: "c1"),
  (type: "pool", height: 6.5, depth: 6.5),
  (type: "conv", widths: (0.6, 0.6), height: 6.5, depth: 6.5, label: "Conv2", name: "c2"),
  (type: "pool", height: 5, depth: 5),
  (type: "conv", widths: (0.7, 0.7, 0.7), height: 5, depth: 5, label: "Conv3", name: "c3"),
  (type: "pool", height: 3.5, depth: 3.5),
  (type: "conv", widths: (0.8, 0.8, 0.8), height: 3.5, depth: 3.5, label: "Conv4", name: "c4"),
  (type: "pool", height: 2.5, depth: 2.5),
  (type: "conv", widths: (0.8, 0.8, 0.8), height: 2.5, depth: 2.5, label: "Conv5", name: "c5"),
  
  // Side outputs with deconvolutions
  (type: "deconv", height: 8, depth: 8, channels: ("1",), label: "Side1", name: "d1", offset: 3),
  (type: "deconv", height: 8, depth: 8, channels: ("1",), label: "Side2", name: "d2", offset: 0.5),
  (type: "deconv", height: 8, depth: 8, channels: ("1",), label: "Side3", name: "d3", offset: 0.5),
  (type: "deconv", height: 8, depth: 8, channels: ("1",), label: "Side4", name: "d4", offset: 0.5),
  (type: "deconv", height: 8, depth: 8, channels: ("1",), label: "Side5", name: "d5", offset: 0.5),
  
  (type: "output", height: 8, depth: 8, channels: ("1",), label: "Edge Map", offset: 1),
), connections: (
  (from: "c1", to: "d1", type: "skip", mode: "depth", pos: 3.0, label: "side1"),
  (from: "c2", to: "d2", type: "skip", mode: "depth", pos: 3.5, label: "side2"),
  (from: "c3", to: "d3", type: "skip", mode: "depth", pos: 4.0, label: "side3"),
  (from: "c4", to: "d4", type: "skip", mode: "depth", pos: 4.5, label: "side4"),
  (from: "c5", to: "d5", type: "skip", mode: "depth", pos: 5.0, label: "side5"),
),
scale: 80%,
show-relu: true,
)

#pagebreak()

= Feature Tests

== Test 1: Arrow Y-Coordinate Alignment
Arrows connect at actual layer centers, not fixed axis-y.

#draw-network((
  (type: "input", height: 6, depth: 6, channels: ("3",), label: "Input", name: "in1"),
  (type: "conv", widths: (0.5, 0.5), height: 5, depth: 5, label: "Conv1", name: "c1"),
  (type: "pool", height: 3.5, depth: 3.5, channels: ("64",)),
  (type: "conv", widths: (0.7,), height: 3.5, depth: 3.5, label: "Conv2", name: "c2"),
  (type: "fc", height: 1, depth: 1, channels: ("128",), label: "FC"),
))

== Example 5: UNet (from test_simple.py)
U-Net architecture for segmentation. Encoder-decoder with skip connections.

#draw-network((
  (type: "conv", channels: ("1", "128"), widths: (0.2,), height: 8, depth: 8, name: "input"),
  
  (type: "conv", channels: ("16", "128"), widths: (0.4,), height: 8, depth: 8, name: "down1"),
  (type: "pool", height: 6.5, depth: 6.5, channels: ("16",), name: "pool1"),
  
  (type: "conv", channels: ("32", "64"), widths: (0.5,), height: 6.5, depth: 6.5, name: "down2"),
  (type: "pool", height: 5, depth: 5, channels: ("32",), name: "pool2"),
  
  (type: "conv", channels: ("64", "32"), widths: (0.8,), height: 5, depth: 5, name: "down3"),
  (type: "pool", height: 3.5, depth: 3.5, channels: ("64",), name: "pool3"),
  
  (type: "conv", channels: ("128", "16"), widths: (1.6,), height: 3.5, depth: 3.5, name: "down4"),
  (type: "pool", height: 2.5, depth: 2.5, channels: ("128",), name: "pool4"),
  
  (type: "conv", channels: ("256", "8"), widths: (3.2,), height: 2.5, depth: 2.5, name: "middle"),
  
  (type: "conv", channels: ("128", "64"), widths: (1.6,), height: 3.5, depth: 3.5, name: "up1", offset: 1.5),
  
  (type: "conv", channels: ("64", "32"), widths: (0.8,), height: 5, depth: 5, offset: 1.5),
  
  (type: "conv", channels: ("32", "64"), widths: (0.5,), height: 6.5, depth: 6.5, name: "up3", offset: 1.5),
  
  (type: "conv", channels: ("16", "128"), widths: (0.4,), height: 8, depth: 8, name: "up4", offset: 1.5),
  
  (type: "conv", channels: ("3", "128"), widths: (0.2,), height: 8, depth: 8, name: "output"),
), connections: (
  // Decoder skip connections (matching test_simple.py architecture)
  (from: "down4", to: "up1", type: "skip", mode: "air", pos: 2.5, touch-layer: true),
  (from: "down3", to: "up2", type: "skip", mode: "air", pos: 3.4, touch-layer: true),
  (from: "down2", to: "up3", type: "skip", mode: "air", pos: 4.1, touch-layer: true),
  (from: "down1", to: "up4", type: "skip", mode: "air", pos: 4.8, touch-layer: true),
),
scale: 70%,
palette: "cold"
)

#pagebreak()

== Test 2: Sum Circle 3D Sphere Effect
Sum circles have 3D light/shadow gradients and align with arrow axis.

#draw-network((
  (type: "conv", widths: (0.5,), height: 3, depth: 3, label: "A", name: "a"),
  (type: "conv", widths: (0.5,), height: 5, depth: 5, label: "B", name: "b", offset: 2),
  (type: "conv", widths: (0.5,), height: 2, depth: 2, label: "C", name: "c", offset: 2),
  (type: "sum", radius: 0.5, channels: ("64",), label: "+", name: "sum", offset: 2),
  (type: "conv", widths: (0.7,), height: 4, depth: 4, label: "Out", offset: 1.5),
), connections: (
  (from: "a", to: "sum", type: "skip", mode: "air", label: "from A"),
  (from: "b", to: "sum", type: "skip", mode: "flat", label: "from B"),
  (from: "c", to: "sum", type: "skip", mode: "depth", label: "from C"),
))

#pagebreak()

== Test 3: Depth Mode Isometric Angle
Diverging connections match parametrized depth angle.

#draw-network((
  (type: "conv", widths: (0.5, 0.5), height: 6, depth: 6, label: "Conv1", name: "c1"),
  (type: "pool", height: 5, depth: 5, channels: ("64",)),
  (type: "conv", widths: (0.6, 0.6), height: 5, depth: 5, label: "Conv2", name: "c2"),
  (type: "pool", height: 4, depth: 4, channels: ("128",)),
  (type: "conv", widths: (0.8,), height: 4, depth: 4, label: "Conv3", name: "c3"),
  (type: "gap", height: 2, depth: 2, channels: ("512",)),
  (type: "deconv", height: 5, depth: 5, channels: ("128",), label: "Dec1", name: "d1", offset: 2),
  (type: "deconv", height: 6, depth: 6, channels: ("64",), label: "Dec2", name: "d2", offset: 0.5),
), connections: (
  (from: "c2", to: "d1", type: "skip", mode: "depth", pos: 2.5, label: "merge1"),
  (from: "c1", to: "d2", type: "skip", mode: "depth", pos: 3.5, label: "merge2"),
))

#pagebreak()

== Test 4: Scale Parameter
Testing scale at 80% to reduce diagram size.

#draw-network((
  (type: "input", height: 5, depth: 5, channels: ("3",), label: "Input"),
  (type: "conv", widths: (0.5, 0.5), height: 5, depth: 5, label: "Conv"),
  (type: "pool", height: 3.5, depth: 3.5, channels: ("64",)),
  (type: "conv", widths: (0.7,), height: 3.5, depth: 3.5, label: "Conv"),
  (type: "output", channels: ("10",), label: "Output"),
), scale: 80%)

#pagebreak()

== Test 5: Pool Layer Transparency
Pool layers with correct 0.5 opacity matching PlotNeuralNet.

#draw-network((
  (type: "conv", widths: (0.5, 0.5), height: 6, depth: 6, label: "Conv1"),
  (type: "pool", height: 5, depth: 5, channels: ("64",)),
  (type: "conv", widths: (0.6, 0.6), height: 5, depth: 5, label: "Conv2"),
  (type: "pool", height: 4, depth: 4, channels: ("128",)),
  (type: "conv", widths: (0.8,), height: 4, depth: 4, label: "Conv3"),
  (type: "pool", height: 3, depth: 3, channels: ("256",)),
  (type: "fc", height: 1.5, depth: 1.5, channels: ("512",), label: "FC"),
))

#pagebreak()

== Test 6: Connection Endpoint Precision
Testing that connections touch sphere boundary correctly.

#draw-network((
  (type: "conv", widths: (0.5,), height: 4, depth: 4, label: "Left", name: "left"),
  (type: "sum", radius: 0.6, channels: ("128",), label: "+", name: "center", offset: 3),
  (type: "sum", radius: 0.5, channels: ("256",), label: "+", name: "add1", offset: 1),
  (type: "conv", widths: (0.5,), height: 4, depth: 4, label: "Right", offset: 3),
), connections: (
  (from: "left", to: "center", type: "skip"),
))
