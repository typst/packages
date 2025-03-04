[![Typst Package](https://img.shields.io/badge/dynamic/toml?url=https%3A%2F%2Fraw.githubusercontent.com%2FTypsium%2Ftypsium-atomic%2Fmain%2Ftypst.toml&query=%24.package.version&prefix=v&logo=typst&label=package&color=239DAD)](https://github.com/Typsium/typsium-atomic)
[![MIT License](https://img.shields.io/badge/license-MIT-blue)](https://github.com/Typsium/typsium/blob/main/LICENSE)
![User Manual](https://img.shields.io/badge/manual-.pdf-purple)

# Draw Atoms in Typst

Draw simple atomic models consisely using the power of CeTZ and Typst.


## Usage
To draw a simple atom use
```typst
#atom-shells(element:"H")
```
![image](https://raw.githubusercontent.com/Typsium/typsium-atomic/main/tests/hydrogen/ref/1.png)

The electrons should be passed in an array where the index corresponds to the shell, while the value is the amount of electrons on that shell. Here is an example: 
```typst
#atom-shells(element:"Cu", electrons:(1, 8, 18, 2))
```
![image](https://raw.githubusercontent.com/Typsium/typsium-atomic/main/tests/int-electrons/ref/1.png)

To draw the same in a CeTZ canvas, use ```draw-atom-shells```, which takes the same arguments as ```atom-shells```

```typst
#cetz.canvas({
  draw-atom-shells(element: (atomic-number:29, mass-number:64, symbol: "Cu"), electrons:(1, 8, 18, 2))
})
```

If you'd like to exclusively draw the shells (for example to draw your own core) use 
```typst
draw-shell(electrons: 20, radius: 5, fill: blue, stroke: 0.5pt + gray)
```

You can use the following options to customise the way atomic draws:
```typst
#atom-shells(
  element: (
    atomic-number: 2,       // proton count
    mass-number: 4,         // nucleon count
    symbol: "He"),          // element name
  electrons: (2,8),         // electrons in each shell
  core-distance: 1,         // radius of the first shell
  shell-distance: 0.4,      // distance between each shell
  core-radius: 0.6,         // size of the core
  fill: luma(90%),          // color of core and electrons
  stroke: 1pt + black,      // stroke color and width
)
```
