# tybloch

Draw Bloch spheres using [cetz](https://typst.app/universe/package/cetz) in Typst.

## Usage

The ``bloch-from-spherical`` function plots a single state vector at the given spherical coordinates.

```typ
#import "@preview/tybloch:0.1.0": bloch-from-spherical

#bloch-from-spherical(
    45deg,
    45deg,
    state-color: purple,
    show-projections: true,
)
```

![Example of the output of the bloch-from-spherical function](https://raw.githubusercontent.com/yalap13/tybloch/refs/heads/main/docs/images/bloch-from-spherical.png)

The ``bloch-state-linear-evolution`` functions shows the evolution between an initial state vector and a final state vector.

```typ
#import "@preview/tybloch:0.1.0": bloch-state-linear-evolution

#bloch-state-linear-evolution(
    (1, 0deg, 0deg),
    (1, 90deg, 90deg),
    number-of-shadows: 9,
    state-color: purple,
)
```

![Example of the output of the bloch-state-linear-evolution function](https://raw.githubusercontent.com/yalap13/tybloch/refs/heads/main/docs/images/bloch-state-linear-evolution.png)

The ``bloch-state-rotation-evolution`` functions shows the evolution for an initial state vector rotating around a given
rotation axis for a total rotation angle.

```typ
#import "@preview/tybloch:0.1.0": bloch-state-rotation-evolution

#bloch-state-rotation-evolution(
  (1, 25deg, 90deg),
  (0deg, 0deg),
  360deg,
  number-of-shadows: 11,
)
```

![Example of the output of the bloch-state-evolution function](https://raw.githubusercontent.com/yalap13/tybloch/refs/heads/main/docs/images/bloch-state-rotation-evolution.png)

## Changelog

### 0.1.0

Initial release
