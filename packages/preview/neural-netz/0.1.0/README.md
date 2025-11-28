# neural-netz
Visualize Neural Network Architectures in high-quality diagrams in [Typst](https://typst.app), with style and API inspired by [PlotNeuralNet](https://github.com/HarisIqbal88/PlotNeuralNet).

<p align="center">
<img src="gallery/features/FCN-8(cold).png" alt="Example of Neural Net visualizaiton with cold color palette" width="750px"/>
<img src="gallery/networks/FCN-8.png" alt="Example of Neural Net visualizaiton with warm color palette" width="750px"/>
</p>

Under the hood, this package only uses the native Typst package [CeTZ](https://typst.app/universe/package/cetz/) for building the diagrams.

# Usage

Simply import the package in order to call its drawing function:
```typ
#import "@preview/neural-netz:0.1.0"
```
You can then call `draw-network` which has the following arguments:
```typ
draw-network(
  layers,
  connections: (),
  palette: "warm",
  show-legend: false,
  scale: 100%,
  stroke-thickness: 1,
  depth-multiplier: 0.3,
  show-relu: false,
)
```
See the examples in the following section to understand how to use it. Alternatively, you can also start from already written architecture examples (see the Examples section).

# Getting started

Here are a few simple features for getting started.

### Basic layout

```typ
#draw-network((
    (type: "conv"), // Next layers are automatically connected with arrows
    (type: "conv", offset: 2),
    (type: "pool"), // Pool layers are sticked to previous convolution block
    (type: "conv", widths: (1, 1), offset: 3) // you can offset layers
))
```
<p align="center">
<img src="gallery/features/basic-layout.png" alt="Basic layout example" width="350px"/>
</p>

### Dimensions and labels

```typ
#draw-network((
    (
      type: "convres", // Each layer type has its own color
      widths: (1, 2),
      channels: (32, 64, 128), // An extra channel will be used as diagonal axis label
      height: 6,
      depth: 8,
      label: "residual convolution",
    ),
    (
      type: "pool",
      channels: ("", "text also works"),
      height: 4,
      depth: 6,
    ),
    (
      type: "conv",
      widths: (1.5, 1.5),
      height: 2,
      depth: 3,
      label: "whole block label",
      offset: 3,
    )
))
```
<p align="center">
<img src="gallery/features/dimensions-labels.png" alt="Dimensions and labels example" width="350"/>
</p>

Additionally, if you network does not fit the page width of your Typst document, you can reduce the scale by giving `scale: 50%` as argument of `draw-network`


### Adding other connexions

```typ
#draw-network((
  (type: "conv", label: "A", name: "a"),
  (type: "conv", label: "B", name: "b", offset: 2),
  (type: "conv", label: "C", name: "c", offset: 2),
  (type: "conv", label: "D", name: "d", offset: 2),
  (type: "conv", label: "E", name: "e", offset: 2),
), connections: (
  (from: "a", to: "c", type: "skip", mode: "depth", label: "depth mode", pos: 6),
  (from: "b", to: "d", type: "skip", mode: "flat", label: "flat mode", pos: 5),
  (from: "c", to: "e", type: "skip", mode: "air", label: "air mode (+touch layer instead of arrow)", pos: 5, touch-layer: true),
),
palette: "cold", // There is a "warm" and a "cold" color palette.
show-relu: true // visualize relu using darker color on convolution layers
)
```
<p align="center">
<img src="gallery/features/connexions.png" alt="Adding connexions example" width="350"/>
</p>

# Examples
Here are a few network architectures implemented with neural-netz (more examples can be found [in the repo](https://github.com/edgaremy/neural-netz/tree/f632d92d77517309a2333ee8763ca8e987232db0/examples/networks)).

<h3 style="text-align: center;">ResNet18</h3>
<p align="center">
<img src="gallery/networks/ResNet18.png" alt="ResNet18 visualization" width="500"/>
</p>
<p style="text-align: center;"><a href="https://github.com/edgaremy/neural-netz/blob/f632d92d77517309a2333ee8763ca8e987232db0/examples/networks/ResNet18.typ">code for this image</a></p>

<h3 style="text-align: center;">U-Net</h3>
<p align="center">
<img src="gallery/networks/U-Net.png" alt="U-Net visualization" width="500"/>
</p>
<p style="text-align: center;"><a href="https://github.com/edgaremy/neural-netz/blob/f632d92d77517309a2333ee8763ca8e987232db0/examples/networks/U-Net.typ">code for this image</a></p>

<h3 style="text-align: center;">FCN-8</h3>
<p align="center">
<img src="gallery/networks/FCN-8.png" alt="FCN-8 visualization" width="500"/>
</p>
<p style="text-align: center;"><a href="https://github.com/edgaremy/neural-netz/blob/f632d92d77517309a2333ee8763ca8e987232db0/examples/networks/FCN-8.typ">code for this image</a></p>


# Acknowledgements

This package could not have existed without the great Python+LaTeX visualization package [PlotNeuralNet](https://github.com/HarisIqbal88/PlotNeuralNet) made by Haris Iqbal. It proposes an elegant way for viewing neural networks, and its visual style was obviously a strong inspiration for the implementation of neural-netz.

If you feel like contributing to this package (bug fixes, features, code refactoring), feel free to [make a PR to the neural-netz repo](https://github.com/edgaremy/neural-netz/pulls) :)