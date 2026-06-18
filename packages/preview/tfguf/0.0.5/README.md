
# TFG UNIR Física
This template is used to prepare Bachelor’s Degree Final Projects for the [Degree in Physics](https://bit.ly/unirfisica) at the International University of La Rioja ([UNIR](https://unir.net)).

Esta plantilla sirve para preparar trabajos de fin de grado del [grado en Física](https://bit.ly/unirfisica) de la Universidad Internacional de La Rioja ([UNIR](https://unir.net)).

![Lema del grado en Física de UNIR](https://p.ipic.vip/vbt7pt.jpg)

## Contexto

Esta plantilla está pensada para estudiantes del [Grado en Física de UNIR](https://bit.ly/unirfisica). Está mantenida por Alberto Corbi (UNIR).

Otros TFG relacionados:

- [TFG de Kenia Aranda](https://tinyurl.com/tfgkeniaaranda)
- [TFG de Abel Río](https://tinyurl.com/tfgabelrio)
- [TFG de Patricia Urquía](https://tinyurl.com/tfgurquia)
- [TFG grupal de Alberto Calatayud y Jorge Martínez](https://typst.app/project/r2Mhv06ZsN9dO2VxPB5BR3)
- [TFG de Luis Fernando (PER 10372)](https://typst.app/project/rZ9FnjxyF0P1u3pIQkNoZ6)

## Inicio rápido
Importa el paquete y aplica la regla `show` principal:

```typst
#import "@local/tfguf:0.0.5": *

#show: unirfisica.with(
  titulo: "Mi trabajo de fin de grado",
  alumno: "Nombre del estudiante",
  director: "Nombre del director",
  resumen: [Resumen del trabajo en castellano.],
  abstract: [English abstract of the thesis.],
  pclave: ("física", "simulación", "datos"),
  kwords: ("physics", "simulation", "data"),
)
```

Si no tienes la **familia tipográfica Calibri**, puedes descargarla desde [aquí](https://www.rmtweb.co.uk/calibri-and-cambria-fonts-for-mac). Después, sube los archivos `Calibri*.ttf` al directorio de tu proyecto.

## Datos del TFG

La plantilla acepta uno o varios autores y directores. Usa una cadena de texto para una sola persona o un array para varias.

```typst
#show: unirfisica.with(
  titulo: "Dinámica de un oscilador cuántico acoplado",
  alumno: ("Ana García", "Luis Pérez"),
  director: ("Dra. Marta López", "Dr. Javier Ruiz"),
  resumen: [
    Este trabajo estudia la evolución temporal de un oscilador cuántico
    acoplado mediante métodos numéricos.
  ],
  abstract: [
    This thesis studies the time evolution of a coupled quantum oscillator
    using numerical methods.
  ],
  pclave: ("mecánica cuántica", "oscilador", "simulación numérica"),
  kwords: ("quantum mechanics", "oscillator", "numerical simulation"),
)
```

## Figuras

Usa la función `figure` de Typst y la función auxiliar `caption` de la plantilla. El primer argumento de `caption` es el título que se muestra sobre la figura; el segundo argumento opcional es la fuente que se muestra debajo.

```typst
#figure(
  image("figuras/espectro.png", width: 80%),
  caption: caption[
    Espectro de emisión de la muestra analizada.
  ][
    Elaboración propia.
  ],
) <fig:espectro>

Como se observa en la @fig:espectro, ...
```

El mismo patrón sirve para tablas:

```typst
#figure(
  table(
    columns: 3,
    table.header[Magnitud][Valor][Unidad],
    [$E$], [1.2], [eV],
    [$T$], [300], [K],
  ),
  caption: caption[
    Parámetros físicos usados en la simulación.
  ][
    Elaboración propia.
  ],
) <tab:parametros>
```

<p align="center">
  <img src="https://upload.wikimedia.org/wikipedia/commons/0/01/UNIR_Logo.svg" alt="Logo de UNIR" width="220">
</p>
