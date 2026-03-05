# molchemist

**molchemist** is a Typst package for rendering chemical structures directly from Molfile (`.mol`) and Structure-Data File (`.sdf`) formats. 

It leverages a blazing-fast Rust/WASM core (powered by [`sdfrust`](https://github.com/hfooladi/sdfrust)) to parse molecular graphs and detect cycles, and seamlessly renders them using the declarative drawing engine of [`alchemist`](https://github.com/Typsium/alchemist).

## Usage

Import the `render-mol` function from the package and pass the raw string data of your `.mol` or `.sdf` file.

```typ
#import "@preview/molchemist:0.1.0": render-mol

// Read your molecule data
// Example: https://pubchem.ncbi.nlm.nih.gov/compound/93406
#let mol-data = read("Structure2D_COMPOUND_CID_93406.sdf")
```

### Rendering Modes

`molchemist` supports three distinct rendering styles to suit your document's needs:

#### 1. Full Mode (Default)

Draws every single atom and bond explicitly exactly as defined in the source file, including all carbons and hydrogens.

*Note: For complex molecules, text overlapping may occur. See [Known Limitations](#known-limitations) for workarounds.*

```typ
#render-mol(mol-data)
```

![Full Mode](images/ex01.png)

#### 2. Abbreviated Mode

A standard chemical representation. It hides the carbon backbone, wraps explicit hydrogens into their parent heteroatoms (e.g., `O` + `H` becomes `OH`), and neatly formats terminal carbon groups (e.g., `CH3`).

```typ
#render-mol(mol-data, abbreviate: true)
```

![Abbreviated Mode](images/ex02.png)

#### 3. Skeletal Mode

A pure skeletal formula. All backbone carbons and their attached hydrogens are completely hidden, leaving only the zigzag lines and heteroatoms.

```typ
#render-mol(mol-data, skeletal: true)
```

![Skeletal Mode](images/ex03.png)

### Customizing Appearance

Under the hood, `molchemist` parses the graph and generates native `alchemist` elements. You can customize the look of your molecules by passing styling arguments via the `config` dictionary, which are passed directly to `alchemist`'s `skeletize` function.

```typ
#render-mol(
  mol-data, 
  skeletal: true,
  config: (
    atom-sep: 2em,
    fragment-margin: 2pt,
    fragment-color: blue,
    fragment-font: "New Computer Modern",
    single: (stroke: 1pt + black),
    double: (gap: 0.3em, stroke: 1pt + red)
  )
)
```

![Custom Appearance](images/ex04.png)

**Important Note on Configuration:**

- **Routing overrides:** Because `molchemist` maps the exact 2D absolute coordinates from the source `.sdf`/`.mol` file, `alchemist`'s automatic routing configs (like `angle-increment`, `base-angle`) are bypassed and have no effect.
- **Lewis Structures:** `molchemist` does not automatically infer or generate Lewis structures from SDF files, so `lewis-*` configs are not applicable out of the box.

### Advanced: Ejecting to Alchemist Code (Dump Mode)

If you need to manually fine-tune a molecule, add a specific Lewis structure, or integrate the structure into a larger custom `alchemist` drawing, you can use the `dump` parameter.

When `dump: true` is passed, `molchemist` will not render the molecule. Instead, it will output the generated native `alchemist` code block into your document. You can then copy, paste, and modify this code directly.

```typ
#render-mol(mol-data, dump: true)
```

**Output (Example):**

```typ
#let base-sep = 3em
#skeletize({
  fragment("O", name: "a0")
  double(absolute: 90deg, atom-sep: base-sep * 1.2053886190984355)
  fragment("C", name: "a4")
  branch({
    single(absolute: 149.99927221917264deg, atom-sep: base-sep * 1.2053621002571053)
    fragment("N", name: "a1")
    branch({
      single(absolute: 90deg, atom-sep: base-sep * 1.2053886190984355)
      fragment("C", name: "a5")
      branch({
        double(absolute: 30.000727780827354deg, atom-sep: base-sep * 1.2053621002571053, offset: "right")
        fragment("N", name: "a2")
        single(absolute: −29.997863113888936deg, atom-sep: base-sep * 1.2054664907148052)
        fragment("C", name: "a6")
        branch({
          double(absolute: −90deg, atom-sep: base-sep * 1.2053886190984355, offset: "right")
          fragment("C", name: "a3", links: (
            "a4": single(absolute: −150.00213688611106deg, atom-sep: base-sep * 1.2054664907148052),
          ))
          single(absolute: −30.000727780827354deg, atom-sep: base-sep * 1.2053621002571053)
          fragment("C", name: "a7")
          branch({
            single(absolute: 30.00072778082738deg, atom-sep: base-sep * 1.2053621002571044)
            fragment("C", name: "a11")
            branch({
              single(absolute: −60.00296847068038deg, atom-sep: base-sep * 0.7474080148754706)
              fragment("H", name: "a19")
            })
            branch({
              single(absolute: 29.997031529319667deg, atom-sep: base-sep * 0.7474080148754708)
              fragment("H", name: "a20")
            })
            single(absolute: 120.00165197278548deg, atom-sep: base-sep * 0.7473036244664235)
            fragment("H", name: "a21")
          })
          branch({
            single(absolute: −129.9948801549935deg, atom-sep: base-sep * 0.7473674327585829)
            fragment("H", name: "a15")
          })
          single(absolute: −50.00511984500657deg, atom-sep: base-sep * 0.7473674327585822)
          fragment("H", name: "a16")
        })
        single(absolute: 30.000727780827354deg, atom-sep: base-sep * 1.2053621002571053)
        fragment("C", name: "a12")
        branch({
          single(absolute: −60.00296847068038deg, atom-sep: base-sep * 0.7474080148754706)
          fragment("H", name: "a22")
        })
        branch({
          single(absolute: 30.00165197278554deg, atom-sep: base-sep * 0.747303624466423)
          fragment("H", name: "a23")
        })
        single(absolute: 120.00165197278552deg, atom-sep: base-sep * 0.7473036244664242)
        fragment("H", name: "a24")
      })
      single(absolute: 149.11831959471084deg, atom-sep: base-sep * 1.2554886995491945)
      fragment("C", name: "a9")
      branch({
        double(absolute: −150.44478717401188deg, atom-sep: base-sep * 1.2555773909515242, offset: "left")
        fragment("C", name: "a13")
        branch({
          single(absolute: −90deg, atom-sep: base-sep * 1.2555327856529301)
          fragment("C", name: "a10")
          branch({
            double(absolute: −29.559997423347433deg, atom-sep: base-sep * 1.255636852575184, offset: "left")
            fragment("C", name: "a8", links: (
              "a1": single(absolute: 30.886401239241575deg, atom-sep: base-sep * 1.2555505724154539),
            ))
            single(absolute: −89.34106169184625deg, atom-sep: base-sep * 1.2053477918944862)
            fragment("C", name: "a14")
            branch({
              single(absolute: −179.3345522447223deg, atom-sep: base-sep * 0.7472708044296151)
              fragment("H", name: "a26")
            })
            branch({
              single(absolute: −89.33465956535612deg, atom-sep: base-sep * 0.7473913351631287)
              fragment("H", name: "a27")
            })
            single(absolute: 0.6561004087622995deg, atom-sep: base-sep * 0.7473899451702973)
            fragment("H", name: "a28")
          })
          single(absolute: −149.77482801822677deg, atom-sep: base-sep * 0.747322376737303)
          fragment("H", name: "a18")
        })
        single(absolute: 149.77482801822677deg, atom-sep: base-sep * 0.747322376737303)
        fragment("H", name: "a25")
      })
      single(absolute: 89.3438995912377deg, atom-sep: base-sep * 0.7473899451702976)
      fragment("H", name: "a17")
    })
  })
})
```

## Known Limitations

When rendering highly complex or dense molecules (e.g., polycyclic compounds, dense substituents) in the default **Full Mode**, you may encounter overlapping atoms or intersecting bonds. This occurs because the 2D absolute coordinates provided in the source `.sdf`/`.mol` files might not allocate enough physical space on the canvas to draw every explicit text label without collisions.

**Recommended Workarounds:**

1. **Use Abbreviated or Skeletal Mode:** For complex organic structures, it is highly recommended to set `abbreviate: true` or `skeletal: true`. This hides redundant atoms, dramatically improving readability and preventing overlaps, which aligns with standard chemical drawing practices.
2. **Increase Bond Length:** If you strictly require Full Mode, you can increase the distance between atoms to create more physical space for the text labels by adjusting the `atom-sep` property in the `config` argument:
    ```typ
    // The default atom-sep is 3em
    #render-mol(mol-data, config: (atom-sep: 4.5em))
    ```

## API Reference

- **`data`** (`str`): The raw string content of a `.mol` or `.sdf` file.
- **`abbreviate`** (`bool`): If `true`, applies standard chemical abbreviations (e.g., folding H into heteroatoms, labeling terminal CH3). Default is `false`.
- **`skeletal`** (`bool`): If `true`, renders a pure skeletal structure, overriding `abbreviate`. Hides all backbone C and H atoms. Default is `false`.
- **`dump`** (`bool`): If `true`, outputs the generated `alchemist` source code as a formatted Typst code block instead of rendering the molecule graphic. Useful for manual tweaking. Default is `false`.
- **`config`** (`dictionary`): A dictionary of visual styling options passed directly to the `alchemist` package.

## License

This project is distributed under the MIT License. See [LICENSE](LICENSE) for details.