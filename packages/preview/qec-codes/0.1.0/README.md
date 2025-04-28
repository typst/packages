# Visualization of Quantum Error Correction Codes
This is a Typst package for visualizing quantum error correction codes.


## Steane code
You can draw a Steane code by calling the `steane_code` function. The name of the qubits are automatically generated as `steane_1`, `steane_2`, etc.
```java
#canvas({
  import draw: *
  steane_code((0, 0), size: 3)
    for j in range(7) {
      content((rel: (0, -0.3), to: "steane_" + str(j+1)), [#(j)])
    }
})
```
![Steane code](examples/steane.png)

## Surface code
You can draw a surface code with different size, color and orientation by `surface_code` function. The name of the qubits can be defined with `name` parameter as `name_i_j`. By default, they will be named as `surface_i_j`. The `type_tag` parameter can be set to `false` to change the orientation of the surface code. Here is an example of two surface codes.
```java
#canvas({
  import draw: *
  let n = 3
  surface_code((0, 0),size:1.5, n, n,name: "surface1")
  for i in range(n) {
    for j in range(n) {
      content((rel: (0.3, 0.3), to: "surface1" + "_" + str(i) + "_" + str(j)), [#(i*n+j+1)])
    }
  }
  surface_code((4, 0), 15, 7,color1:red,color2:green,size:0.5,type_tag: false)
  })
```
![Surface code](examples/surface.png)

## Toric code
You can draw a toric code with different size and color by `toric_code` function. The name of the qubits can be defined with `name` parameter as `name_point_vertical_i_j` and `name_point_horizontal_i_j`. By default, they will begin with `toric`. Here is an example of a toric code with 5x3 size. `plaquette_code_label` and `vertex_code_label` functions can be used to label the plaquette and vertex stabilizers at a specified location. `stabilizer_label` generates a stabilizer legend.
```java
#canvas({
  import draw: *
  let m = 5
  let n = 3
  let size = 2
  let circle_radius = 0.4
  toric_code((0, 0), m, n, size: size, circle_radius: circle_radius)
  plaquette_code_label((0, 0),2,0, size: size, circle_radius: circle_radius)
  vertex_code_label((0, 0),3,2, size: size, circle_radius: circle_radius)
  stabilizer_label((12, -2))
  for i in range(m){
    for j in range(n){
      content( "toric_point_vertical_" + str(i) + "_" + str(j), [#(i*n+j+1)])
      content( "toric_point_horizontal_" + str(i) + "_" + str(j), [#(i*n+j+1+m*n)])
    }
  }
})
```
![Toric code](examples/toric1.png)

`plaquette_code_label` and `vertex_code_label` functions can be adjusted to change the label of the stabilizers. Here is an example of$〚98,8,12〛$BB code.

```java
#canvas({
  import draw: *
  toric_code((0, 0), 7, 7, size: 1)
  plaquette_code_label((0, 0),2,4,ver_vec:((-1,0),(2,1),(3,1)),hor_vec:((0,0),(-1,-4),(-1,-3)), size: 1)
  vertex_code_label((0, 0),6,1,ver_vec:((-1,0),(0,4),(0,3)),hor_vec:((-4,-1),(0,0),(-3,-1)), size: 1)
  stabilizer_label((10, -3))
})
```
![BB code](examples/toric2.png)
## License

Licensed under the [MIT License](LICENSE).