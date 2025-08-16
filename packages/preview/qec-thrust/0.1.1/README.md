# Visualization of Quantum Error Correction Codes
This is a Typst package for visualizing quantum error correction codes.

**Note: Requires CeTZ version >= 0.3 and compiler version >= 0.13**


## Steane code
You can draw a Steane code by calling the `steane-code` function. The name of the qubits are automatically generated as `steane-1`, `steane-2`, etc.
```java
#import "@preview/qec-thrust:0.1.0": *

#canvas({
  import draw: *
  steane-code((0, 0), size: 3)
    for j in range(7) {
      content((rel: (0, -0.3), to: "steane-" + str(j+1)), [#(j)])
    }
})
```
![Steane code](examples/steane.png)

## Surface code
You can draw a surface code with different size, color and orientation by `surfacecode` function. The name of the qubits can be defined with `name` parameter as `name-i-j`. By default, they will be named as `surface-i-j`. The `type-tag` parameter can be set to `false` to change the orientation of the surface code. Here is an example of two surface codes.
```java
#canvas({
  import draw: *
  let n = 3
  surface-code((0, 0),size:1.5, n, n,name: "surface1")
  for i in range(n) {
    for j in range(n) {
      content((rel: (0.3, 0.3), to: "surface1" + "-" + str(i) + "-" + str(j)), [#(i*n+j+1)])
    }
  }
  surface-code((4, 0), 15, 7,color1:red,color2:green,size:0.5,type-tag: false)
  })
```
![Surface code](examples/surface.png)

## Toric code
You can draw a toric code with different size and color by `toric-code` function. The name of the qubits can be defined with `name` parameter as `name-point-vertical-i-j` and `name-point-horizontal-i-j`. By default, they will begin with `toric`. Here is an example of a toric code with 5x3 size. `plaquette-code-label` and `vertex-code-label` functions can be used to label the plaquette and vertex stabilizers at a specified location. `stabilizer-label` generates a stabilizer legend.
```java
#canvas({
  import draw: *
  let m = 5
  let n = 3
  let size = 2
  let circle-radius = 0.4
  toric-code((0, 0), m, n, size: size, circle-radius: circle-radius)
  plaquette-code-label((0, 0),2,0, size: size, circle-radius: circle-radius)
  vertex-code-label((0, 0),3,2, size: size, circle-radius: circle-radius)
  stabilizer-label((12, -2))
  for i in range(m){
    for j in range(n){
      content( "toric-point-vertical-" + str(i) + "-" + str(j), [#(i*n+j+1)])
      content( "toric-point-horizontal-" + str(i) + "-" + str(j), [#(i*n+j+1+m*n)])
    }
  }
})
```
![Toric code](examples/toric1.png)

`plaquette-code-label` and `vertex-code-label` functions can be adjusted to change the label of the stabilizers. Here is an example of$〚98,8,12〛$BB code.

```java
#canvas({
  import draw: *
  toric-code((0, 0), 7, 7, size: 1)
  plaquette-code-label((0, 0),2,4,ver-vec:((-1,0),(2,1),(3,1)),hor-vec:((0,0),(-1,-4),(-1,-3)), size: 1)
  vertex-code-label((0, 0),6,1,ver-vec:((-1,0),(0,4),(0,3)),hor-vec:((-4,-1),(0,0),(-3,-1)), size: 1)
  stabilizer-label((10, -3))
})
```
![BB code](examples/toric2.png)
## License

Licensed under the [MIT License](LICENSE).
