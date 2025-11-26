#set page(width: auto, height: auto, margin: 5mm)

#draw-network((
  (type: "conv", channels: ("1", "128"), widths: (0.2,), height: 8, depth: 8, name: "input"),
  
  (type: "conv", channels: ("16", "128"), widths: (0.4,), height: 8, depth: 8, name: "down1"),
  (type: "pool", height: 6.5, depth: 6.5, name: "pool1"),
  
  (type: "conv", channels: ("32", "64"), widths: (0.5,), height: 6.5, depth: 6.5, name: "down2"),
  (type: "pool", height: 5, depth: 5, name: "pool2"),
  
  (type: "conv", channels: ("64", "32"), widths: (0.8,), height: 5, depth: 5, name: "down3"),
  (type: "pool", height: 3.5, depth: 3.5, name: "pool3"),
  
  (type: "conv", channels: ("128", "16"), widths: (1.6,), height: 3.5, depth: 3.5, name: "down4"),
  (type: "pool", height: 2.5, depth: 2.5, name: "pool4"),
  
  (type: "conv", channels: ("256", "8"), widths: (3.2,), height: 2.5, depth: 2.5, name: "middle"),
  
  (type: "conv", channels: ("128", "64"), widths: (1.6,), height: 3.5, depth: 3.5, name: "up1", offset: 1.5),
  
  (type: "conv", channels: ("64", "32"), widths: (0.8,), height: 5, depth: 5, name: "up2", offset: 1.5),
  
  (type: "conv", channels: ("32", "64"), widths: (0.5,), height: 6.5, depth: 6.5, name: "up3", offset: 1.5),
  
  (type: "conv", channels: ("16", "128"), widths: (0.4,), height: 8, depth: 8, name: "up4", offset: 1.5),
  
  (type: "conv", channels: ("3", "128"), widths: (0.2,), height: 8, depth: 8, name: "output"),
), connections: (
  // Decoder skip connections (matching test_simple.py architecture)
  (from: "down4", to: "up1", type: "skip", mode: "air", pos: 2.5, touch-layer: true),
  (from: "down3", to: "up2", type: "skip", mode: "air", pos: 3.4, touch-layer: true),
  (from: "down2", to: "up3", type: "skip", mode: "air", pos: 4.1, touch-layer: true),
  (from: "down1", to: "up4", type: "skip", mode: "air", pos: 4.8, touch-layer: true),
))