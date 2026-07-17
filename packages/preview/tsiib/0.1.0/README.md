# tsiib

Plantilla tipográfica para artículos académicos en español con estilo LaTeX,
para [Typst](https://typst.app) v0.15+.

## Instalación

### Desde Typst Universe

Una vez publicado, se importa con:

```typst
#import "@preview/tsiib:0.1.0": *
```

### Instalación local (para desarrollo o antes de la publicación)

Copia la carpeta del paquete a la ruta local de Typst:

| Sistema | Ruta |
|---------|------|
| Windows | `%APPDATA%\typst\packages\local\tsiib\0.1.0\` |
| macOS   | `~/Library/Application Support/typst/packages/local/tsiib/0.1.0/` |
| Linux   | `~/.local/share/typst/packages/local/tsiib/0.1.0/` |

Luego importa con `@local`:

```typst
#import "@local/tsiib:0.1.0": *
```

### Uso directo (sin instalar)

Descarga el repositorio de [GitHub](https://github.com/MHAlberto/tsiib) e
importa `lib.typ` con ruta relativa:

```typst
#import "ruta/a/tsiib/lib.typ": *
```

## Uso rápido

```typst
#import "@local/tsiib:0.1.0": *

#show: tsiib.with(
  title: "Título del Artículo",
  subtitle: "Subtítulo opcional",
  author: "Tu Nombre",
  affiliation: "Universidad o Instituto",
  email: "correo@ejemplo.com",
  date: "1 de enero de 2026",
  abstract: [Resumen del artículo...],
  keywords: "palabras, clave",  // solo metadato PDF
  bib: bibliography("refs.bib"),
)

= Introducción

#definicion[
  Una *función continua* es aquella donde límite y evaluación conmutan.
] <def-continua>

En la Definición @def-continua se establece la propiedad fundamental...
```

## Parámetros de la plantilla `tsiib()`

| Parámetro     | Tipo     | Requerido | Descripción                                                    |
|--------------|----------|-----------|----------------------------------------------------------------|
| `title`      | string   | Sí        | Título del documento                                           |
| `subtitle`   | string   | No        | Subtítulo del documento                                        |
| `author`     | string   | No        | Nombre del autor                                               |
| `affiliation`| string   | No        | Afiliación del autor (universidad, instituto)                  |
| `email`      | string   | No        | Correo del autor (se renderiza como `mailto:`)                 |
| `date`       | string   | No        | Fecha (por defecto: fecha actual en español)                   |
| `abstract`   | content  | No        | Resumen del artículo                                           |
| `keywords`   | string   | No        | Palabras clave (solo metadato PDF, no se muestra)              |
| `bib`        | content  | No        | Contenido de bibliografía: `bibliography("refs.bib")`          |
| `body`       | content  | Sí        | Contenido del documento                                        |

## Macros disponibles

### Entornos matemáticos

| Macro | Numeración | Descripción |
|-------|-----------|-------------|
| `teorema(titulo: none, cuerpo)` | Dependiente de sección | Teorema. Comparte contador con proposición, corolario y axioma |
| `proposicion(titulo: none, cuerpo)` | Dependiente de sección | Proposición |
| `corolario(titulo: none, cuerpo)` | Dependiente de sección | Corolario |
| `axioma(titulo: none, cuerpo)` | Dependiente de sección | Axioma |
| `lema(titulo: none, cuerpo)` | Dependiente de sección | Lema con contador propio |
| `definicion(titulo: none, cuerpo)` | Dependiente de sección | Definición con contador propio |
| `ejemplo(titulo: none, cuerpo)` | Dependiente de sección | Ejemplo con contador propio |
| `problema(titulo: none, cuerpo)` | Dependiente de sección | Problema con contador propio |
| `demostracion(cuerpo)` | No numerado | Demostración con QED `$square$` alineado a la derecha |
| `solucion(cuerpo)` | No numerado | Solución en texto normal |

Cada entorno numerado acepta un título opcional:

```typst
#teorema(titulo: "del Valor Medio")[
  Sea $f$ continua en $[a,b]$...
]
// Renderiza: Teorema 1.1 (del Valor Medio). Sea $f$...
```

### Figuras y tablas

| Macro | Descripción |
|-------|------------|
| `figura(body, caption: none)` | Figura auto-numerada con caption abajo |
| `tabla(caption: none, columns: auto, ..body)` | Tabla estilo booktabs (LaTeX profesional) |
| `imagen(path, width: 100%, caption: none)` | Atajo para imágenes desde archivo |
| `figura-izq-texto(ruta, caption, img-width, gutter, texto)` | Imagen a la izquierda, texto a la derecha |
| `figura-der-texto(ruta, caption, img-width, gutter, texto)` | Imagen a la derecha, texto a la izquierda |

### Ecuaciones numeradas

Las ecuaciones display (`$ ... $`) por defecto **no** llevan numeración. Para
obtener una ecuación numerada y referenciable se usa la macro `ecuacion()`:

```typst
#ecuacion[$ E = m c^2 $] <eq-einstein>

Como se observa en la ecuación @eq-einstein...
```

### Bloques de código

| Macro | Descripción |
|-------|------------|
| `codigo-formal(codigo, lang: "python", titulo: none)` | Código con números de línea, fondo gris, y título opcional como «Listado X.Y» |

```typst
#codigo-formal(```
import pandas as pd
df = pd.read_csv("datos.csv")
```)

#codigo-formal(titulo: "Función de activación", ```
def relu(x):
    return max(0, x)
```) <listado-ols>
```

### Referencias cruzadas

Todas las referencias (`@label`), citas bibliográficas (`@bibkey`), y
entradas del índice se renderizan en color azul (`#2563eb`).

Cada entorno numerado acepta un label después de la macro:

```typst
#teorema[
  Sea $f$ continua en $[a,b]$...
] <teo-importante>

Como se demostró en el Teorema @teo-importante...
```

La referencia `@teo-importante` se renderiza como *Teorema 1.1*, incluyendo
el número de sección principal en formato homogéneo "Nombre X.Y".

### Bibliografía

Se pasa el resultado de `bibliography()` al parámetro `bib`. La ruta al
archivo `.bib` se resuelve desde tu documento:

```typst
#show: tsiib.with(
  title: "Mi Artículo",
  author: "Autor",
  bib: bibliography("refs.bib"),
)
```

## Estructura del proyecto

```
tsiib/
├── typst.toml              Metadatos del paquete
├── lib.typ                 Punto de entrada
├── main.typ                Artículo de ejemplo
├── refs.bib                Bibliografía de ejemplo
├── cuadrado.png            Imagen de ejemplo
├── LICENSE                 Licencia MIT
├── README.md
├── .gitignore
└── src/
    ├── template.typ        Plantilla principal tsiib()
    ├── counters.typ        Contadores y numbering
    ├── macros.typ          Entornos matemáticos
    ├── figures.typ         Figuras, tablas e imágenes
    ├── codigo.typ          Bloques de código
    └── links.typ           Hipervínculos
```

## Detalles técnicos

### Contadores

Los entornos numerados usan `figure()` con distintos valores de `kind`:

| Entorno      | Figure kind | Comparte con | Formato de @ref |
|-------------|-------------|-------------|-----------------|
| Teorema     | `teo`       | Prop, Cor, Ax | Teorema 1.1    |
| Proposición | `teo`       | Teo, Cor, Ax  | Proposición 1.2 |
| Corolario   | `teo`       | Teo, Prop, Ax | Corolario 1.3  |
| Axioma      | `teo`       | Teo, Prop, Cor| Axioma 1.4     |
| Definición  | `def`       | —            | Definición 1.1  |
| Ejemplo     | `ej`        | —            | Ejemplo 1.1     |
| Problema    | `prob`      | —            | Problema 1.1    |
| Lema        | `lema`      | —            | Lema 1.1        |
| Figura      | `image`     | —            | Figura 1.1      |
| Tabla       | `table`     | —            | Tabla 1.1       |
| Listado     | `code`      | —            | Listado 1.1     |

Los contadores se reinician en cada sección principal (`=`).
El formato es siempre "Nombre X.Y": X = número de sección, Y = secuencial.

### Tipografía y diseño

- **Fuente:** New Computer Modern (texto) + New Computer Modern Math (ecuaciones)
- **Tamaño:** 11pt, justificado, sangría de 1.5em
- **Papel:** US Letter, márgenes de 3cm
- **Encabezado:** Título del artículo en cursiva (excepto página 1)
- **Color de enlaces:** Azul `#2563eb`

## Compilar el ejemplo

```bash
git clone https://github.com/MHAlberto/tsiib.git
cd tsiib
typst compile main.typ
```

## Publicar en Typst Universe

1. Haz un fork de [`typst/packages`](https://github.com/typst/packages)
2. Crea la carpeta `packages/preview/tsiib/0.1.0/`
3. Copia solo los archivos del paquete: `typst.toml`, `lib.typ`, `src/`
   (no incluyas `main.typ`, `refs.bib`, `cuadrado.png`, `README.md`, `LICENSE`)
4. Abre un Pull Request

## Licencia

MIT © M.H. Alberto
