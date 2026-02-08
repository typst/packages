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
                <img width="250px" alt="basics"
                    src="https://github.com/user-attachments/assets/3f792cc9-f8c5-432b-8042-e8952daec0e8" />
            </a>
        </td>
        <td>
            <a href="examples/beads.typ">
                <img width="250px" alt="beads"
                    src="https://github.com/user-attachments/assets/4139f50e-5ca3-4003-9e84-9b50db5b2517" />
            </a>
        </td>
        <td>
            <a href="examples/csg.typ">
                <img width="250px" alt="csg"
                    src="https://github.com/user-attachments/assets/775e3b5f-afbf-4f6b-96f2-c68fe3739d52" />
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
                <img width="250px" alt="example1"
                    src="https://github.com/user-attachments/assets/817cfcb3-5cc8-418e-8eab-9a192077dde9" />
            </a>
        </td>
        <td>
            <a href="examples/func.typ">
                <img width="250px" alt="func"
                    src="https://github.com/user-attachments/assets/759eeafb-9f91-4deb-a169-2d94725ef569" />
            </a>
        </td>
        <td>
            <a href="examples/func2.typ">
                <img width="250px" alt="func2"
                    src="https://github.com/user-attachments/assets/49b15449-2c35-4d52-a927-479a2e0964b7" />
            </a>
        </td>
    </tr>
    <tr>
        <td>example1</td>
        <td>func (about 2s)</td>
        <td>func2 (about 1s)</td>
    </tr>
    <tr>
        <td>
            <a href="examples/func3.typ">
                <img width="250px" alt="func3"
                    src="https://github.com/user-attachments/assets/069fdcbc-9583-47d3-a481-bb3970151269" />
            </a>
        </td>
        <td>
            <a href="examples/graph.typ">
                <img width="250px" alt="graph"
                    src="https://github.com/user-attachments/assets/2a3b782f-58f9-4a77-aa81-36060dbe0dec" />
            </a>
        </td>
        <td>
            <a href="examples/skyscrapers.typ">
                <img width="250px" alt="skyscrapers"
                    src="https://github.com/user-attachments/assets/e980bdce-dbc0-40f2-b048-8095a71ab4b5" /> </a>
        </td>
    </tr>
    <tr>
        <td>func3 (about 1s)</td>
        <td>graph</td>
        <td>skyscrapers (about 3s)</td>
    </tr>
    <tr>
        <td>
            <a href="examples/suzanne.typ">
                <img width="250px" alt="suzanne"
                    src="https://github.com/user-attachments/assets/7a27780f-76b1-4964-bd0f-329e43efe5a4" />
            </a>
        </td>
        <td>
            <a href="examples/test.typ">
                <img width="250px" alt="test"
                    src="https://github.com/user-attachments/assets/c5e78e01-7c82-43be-8306-c26adb61f3d7" />
            </a>
        </td>
        <td>
            <a href="examples/test0.typ">
                <img width="250px" alt="test0"
                    src="https://github.com/user-attachments/assets/70d52efd-b126-4dd2-a77e-2d9ec9358d91" />
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
For information, see the [manual.pdf](https://github.com/HellOwhatAs/larnt/releases/download/typst-0.1.0/manual.pdf).

Add the following code to your document:
```typst
#import "@preview/larnt:0.1.0" as la;

#image(la.render(
  // Some shapes to render
))
```


## Build
```bash
# build the plugin
cargo build --release --target wasm32-unknown-unknown

# copy the wasm file to the current directory
cp ./target/wasm32-unknown-unknown/release/larnt_typst_plugin.wasm ./
```
