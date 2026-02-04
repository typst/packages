# larnt

[![Typst Universe](https://img.shields.io/badge/Typst-Universe-239dad)](https://typst.app/universe/package/larnt/)
[![crates.io](https://img.shields.io/crates/v/larnt)](https://crates.io/crates/larnt)
[![Repo](https://img.shields.io/badge/GitHub-repo-444)](https://github.com/HellOwhatAs/larnt/tree/master/examples/larnt_typst)

_3D line art engine using [rust rewrite](https://github.com/HellOwhatAs/larnt) of [fogleman/ln](https://github.com/fogleman/ln)._

## Examples
<table>
    <tr>
        <td>
            <a href="examples/basics.typ">
                <img width="250px" src="https://github.com/user-attachments/assets/c54761a6-a7f6-43e9-b813-355ef6b29558">
            </a>
        </td>
        <td>
            <a href="examples/beads.typ">
                <img width="250px" src="https://github.com/user-attachments/assets/eb321af0-1b4f-4e10-97c1-0dac85650e03">
            </a>
        </td>
        <td>
            <a href="examples/csg.typ">
                <img width="250px" src="https://github.com/user-attachments/assets/7da071ef-8781-4155-b07c-fa59b3acc806">
            </a>
        </td>
    </tr>
<tr>
  <td>basics</td>
  <td>beads (about 1min)</td>
  <td>csg</td>
</tr>
    <tr>
        <td>
            <a href="examples/example1.typ">
                <img width="250px" src="https://github.com/user-attachments/assets/03f0952b-b900-4ed4-ac2c-f3242355db21">
            </a>
        </td>
        <td>
            <a href="examples/func.typ">
                <img width="250px" src="https://github.com/user-attachments/assets/d9a1ae75-c485-439c-afc6-e4a7c80e0465">
            </a>
        </td>
        <td>
            <a href="examples/func2.typ">
                <img width="250px" src="https://github.com/user-attachments/assets/0a15e40a-f4ca-4e35-a4d0-eff93c161c92">
            </a>
        </td>
    </tr>
<tr>
  <td>example1</td>
  <td>func (about 7s)</td>
  <td>func2 (about 3s)</td>
</tr>
    <tr>
        <td>
            <a href="examples/func3.typ">
                <img width="250px" src="https://github.com/user-attachments/assets/6e898eaf-a33e-4376-8106-91f9960ccefb">
            </a>
        </td>
        <td>
            <a href="examples/graph.typ">
                <img width="250px" src="https://github.com/user-attachments/assets/9818ad38-d102-4356-a485-e0e05dc26975">
            </a>
        </td>
        <td>
            <a href="examples/skyscrapers.typ">
                <img width="250px" src="https://github.com/user-attachments/assets/5acb9f04-86a7-4bee-9760-b224cd2ea280">
            </a>
        </td>
    </tr>
<tr>
  <td>func3 (about 7s)</td>
  <td>graph</td>
  <td>skyscrapers (about 3s)</td>
</tr>
    <tr>
        <td>
            <a href="examples/suzanne.typ">
                <img width="250px" src="https://github.com/user-attachments/assets/2634d184-e695-4fc8-9e47-9ae74e3ea204">
            </a>
        </td>
        <td>
            <a href="examples/test.typ">
                <img width="250px" src="https://github.com/user-attachments/assets/760303ea-7c99-491b-bfd1-1d41b3aee537">
            </a>
        </td>
        <td>
            <a href="examples/test0.typ">
                <img width="250px" src="https://github.com/user-attachments/assets/a50084a9-2ee8-4a82-8694-7574973a241d">
            </a>
        </td>
    </tr>
<tr>
  <td>suzanne</td>
  <td>test (about 20s)</td>
  <td>test0</td>
</tr>
</table>

*Click on the example image to jump to the code.*

## Features

- Primitives
	- Sphere
	- Cube
	- Triangle
	- Cylinder
	- Cone
	- 3D Functions
- Triangle Meshes
- Vector-based "Texturing"
- CSG (Constructive Solid Geometry) Operations
	- Intersection
	- Difference
- Output SVG

## Usage
For information, see the [manual.pdf](https://github.com/user-attachments/files/25073081/manual.pdf).

Add the following code to your document:
```typst
#import "@preview/larnt:0.1.0" as la;

#la.render(
  // Some shapes to render
)
```


## Build
```bash
# build the plugin
cargo build --release --target wasm32-unknown-unknown

# copy the wasm file to the current directory
cp ./target/wasm32-unknown-unknown/release/larnt_typst_plugin.wasm ./
```
