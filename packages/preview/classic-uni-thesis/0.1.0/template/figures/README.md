# figures/

Coloca aquí las figuras de tu tesis (gráficos, diagramas, capturas de pantalla) y
referéncialas desde un capítulo con una ruta relativa:

```typ
#figure(
  image("../figures/your-figure.png", width: 100%),
  caption: [Tu leyenda.],
) <fig:your-figure>
```

Typst lee PNG, JPEG, GIF y SVG. `placeholder.svg` viene incluido con la plantilla
para que el ejemplo compile desde el primer momento — bórralo una vez que agregues
tus propias figuras.
