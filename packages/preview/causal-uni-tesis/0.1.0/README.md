# causal-uni-tesis

Plantilla de tesis de **Maestría / Doctorado** para la **Universidad Nacional de Ingeniería** (Perú, Facultad de Ingeniería Económica, Estadística y Ciencias Sociales), en [Typst](https://typst.app).

Composición clásica de libro, aperturas de capítulo, entornos matemáticos con numeración compartida (`#teorema`, `#lema`, `#definicion`, `#proposicion`, `#ejemplo`…), cabeceras vivas, tablas al estilo *booktabs* y bibliografía APA en español. Versión 0.1.0 (corresponde a la plantilla v0.1.0 del repositorio).

## Uso

```typst
#import "@preview/causal-uni-tesis:0.1.0": *

#let meta = (
  titulo: "Título de la tesis",
  autor: "Nombre del Autor",
  asesor: "Dr. Nombre del Asesor",
  grado: "Magíster en Ciencias e Ingeniería Estadística",
  tipo-doc: "Tesis de maestría",
  universidad: "Universidad Nacional de Ingeniería",
  facultad: "Facultad de Ingeniería Económica, Estadística y Ciencias Sociales",
  unidad: "Unidad de Posgrado",
  ciudad: "Lima — Perú",
  anio: 2026,
  logo: "logo_uni.png",          // ruta a su emblema institucional
  palabras-clave: ("inferencia causal",),
  resumen-corto: "Resumen breve para metadatos del PDF.",
  repositorio: "https://github.com/jelincovil/grupo_estudio_inferencia_causal_uni_peru",
)

#show: tesis.with(meta)
#portada(meta)

#show: frontmatter
// … dedicatoria, agradecimientos, resúmenes, índice …

#show: mainmatter
= Introducción
Contenido con #teorema(nombre: "De consistencia")[…] y matemática.

#show: apendices
= Apéndice A
```

La tipografía **New Computer Modern** viene incluida con Typst; no requiere instalar fuentes.

## Qué incluye

- `tesis(meta, body)` — envoltura principal (metadatos del PDF, geometría A4 con márgenes UNI, tipografía, ecuaciones numeradas).
- `portada(meta)` — portada institucional (requiere `meta.logo`, p. ej. `logo_uni.png`).
- `frontmatter` / `mainmatter` / `apendices` — numeración romana / arábiga / A, B, …
- Entornos: `teorema`, `lema`, `corolario`, `proposicion`, `definicion`, `axioma`, `observacion`, `ejemplo`, `nota`, `demostracion`, `algoritmo`, `aviso`, `evidencia`.
- Operadores matemáticos: `E`, `Var`, `Cov`, `Corr`, `argmax`, `argmin`, `vect`, `mat`.
- `prefacio(titulo, cuerpo)`, `TODO(txt)` (marcador rojo para borradores).

## Licencia

Creative Commons Attribution 4.0 International (CC-BY-4.0).

## Repositorio y ejemplo completo

<https://github.com/jelincovil/grupo_estudio_inferencia_causal_uni_peru> — incluye un ejemplo de tesis completo (maestría y doctorado) compilable con `./compilar.sh`.
