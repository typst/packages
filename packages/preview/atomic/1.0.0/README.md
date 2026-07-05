[![Typst Package](https://img.shields.io/badge/dynamic/toml?url=https%3A%2F%2Fraw.githubusercontent.com%2FTypsium%2Ftypsium-atomic%2Fmain%2Ftypst.toml&query=%24.package.version&prefix=v&logo=typst&label=package&color=239DAD)](https://typst.app/universe/package/quick-cards)
[![MIT License](https://img.shields.io/badge/license-MIT-blue)](https://github.com/Typsium/typsium/blob/main/LICENSE)

# Draw Atoms in Typst

Draw simple atomic models consisely using the power of CeTZ and Typst.


## Usage
To draw a simple atom use
```typst
#atom(atomic number (proton count), mass number (neutron count), electrons per shell, shells: 1.0, step: 0.4, center: 0.6, color: luma(90%))
```

The electrons should be passed in an array where the index corresponds to the shell, while the value is the amount of electrons on that shell. Here is an example: 
```typst
#atom(29,64, "Cu", (1, 8, 18, 2))
```
![image](https://github.com/user-attachments/assets/42e3ffb2-68d1-44dc-b8e3-039e19b1e942)

You can also auto-populate orbitals.

```typst
#atom(29,64,"Cu",29)
```

To draw the same in a CeTZ canvas, use ```draw-atom```, which takes the same arguments as ```atom```

```typst
#cetz.canvas({
  draw-atom(29,64, "Cu", (1, 8, 18, 2))
})
```

If you'd like to exclusively draw the shells (for example to draw your own core) use ```draw-orbital(radius, electrons, color: luma(90%))```
