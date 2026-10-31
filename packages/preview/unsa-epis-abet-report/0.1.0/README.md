# UNSA EPIS ABET Laboratory Report Template (`unsa-epis-abet-report`)

[![Typst Version](https://img.shields.io/badge/Typst-0.13.0%2B-239DAD.svg)](https://typst.app)
[![Package Version](https://img.shields.io/badge/version-0.1.0-blue.svg)](https://typst.app/universe/package/unsa-epis-abet-report)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

> 🌐 **Language / Idioma:** [English](#english) | [Español](#español)

---

<a id="english"></a>
## English

### 1. Overview

**`unsa-epis-abet-report`** is a standardized, modular Typst template designed for engineering laboratory reports at the **Escuela Profesional de Ingeniería de Sistemas (EPIS)** of **Universidad Nacional de San Agustín (UNSA)** conforming to **ABET (Accreditation Board for Engineering and Technology)** quality criteria.

Originally based on institutional university practice guides (such as format `GUIA-PRLE-001`), this package provides:
- Standardized institutional header with university hierarchy, quality control code, approval date, and logos.
- Structured front matter table capturing course title, lab session number, academic semester, presentation date and time, student credentials (names, student IDs/codes, emails), instructor information, and grading rubric space.
- Modular section helpers: boxed results table (`results-section`), teacher feedback box (`feedback-box`), and framed IEEE bibliography (`bibliography-box`).
- Clean, customizable typography powered by `Lato`, `Liberation Sans`, or system sans fonts, with syntax-highlighted code blocks and styled headings.

---

### 2. Quick Start

Create a ready-to-compile laboratory report directly from the Typst Universe CLI:

```bash
typst init @preview/unsa-epis-abet-report:0.1.0 my-lab-report
cd my-lab-report
typst compile main.typ
```

This initializes the standard template skeleton including `main.typ` and `references.bib`.

---

### 3. Usage & Import

#### Typst Universe Package Import
Import the package entrypoint into your document:

```typst
#import "@preview/unsa-epis-abet-report:0.1.0": *

#show: unsa-epis-abet-report.with(
  title: "Laboratorio 01: Análisis de Circuitos y Simulación",
  lab-number: 1,
  course: "Sistemas Digitales",
  semester: "2026-A",
  date: datetime.today(),
  time: auto, // captures --input hora="$(date +%H:%M)" or renders "—"
  authors: (
    "Pérez Quispe, Juan Carlos",
    "García López, María Elena",
  ),
  instructor: "Ing. Docente Principal",
)

#results-section(
  ejercicios: [
    = SOLUCIÓN DE EJERCICIOS
    Se implementó el circuito usando HDL.
  ],
  cuestionario: [
    = CUESTIONARIO
    Respuestas a las preguntas formuladas...
  ],
  conclusiones: [
    = CONCLUSIONES
    - Conclusiones del desarrollo experimental.
  ],
)

#feedback-box()

#bibliography-box(
  bibliography("references.bib", title: none, style: "ieee")
)
```

#### Local Development Staging
To test or develop this package locally before publication, stage it in the Typst local preview package cache:

```bash
# Linux / macOS
mkdir -p ~/.cache/typst/packages/preview/unsa-epis-abet-report/0.1.0
cp -r lib.typ template assets typst.toml README.md LICENSE thumbnail.png ~/.cache/typst/packages/preview/unsa-epis-abet-report/0.1.0/

# Windows (PowerShell)
New-Item -ItemType Directory -Force -Path "$env:LOCALAPPDATA\typst\packages\preview\unsa-epis-abet-report\0.1.0"
Copy-Item -Recurse lib.typ, template, assets, typst.toml, README.md, LICENSE, thumbnail.png "$env:LOCALAPPDATA\typst\packages\preview\unsa-epis-abet-report\0.1.0"
```

Then compile `template/main.typ` using:
```bash
typst compile template/main.typ
```

---

### 4. Parameter Reference

#### `unsa-epis-abet-report(...)` (alias `abet-report`)

The main show rule function accepts the following parameters:

| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `title` | `str`, `content` | `"Título de la Práctica"` | Title of the laboratory practice session. |
| `lab-number` | `int`, `str`, `content` | `"1"` | Laboratory session number or identifier. |
| `course` | `str`, `content` | `"Laboratorio de Computación"` | Subject or course title. |
| `semester` | `str`, `content` | `"A"` | Academic semester identifier (e.g. `"A"`, `"2026-A"`, `"II"`). |
| `academic-year` | `str`, `int`, `auto` | `auto` | Academic year. When `auto`, automatically derived from `date` or current calendar year. |
| `date` | `auto`, `datetime`, `str`, `none` | `auto` | Presentation date. `auto` uses `datetime.today()`. If `none`, displays `"—"`. |
| `date-format` | `str` | `"[day]/[month]/[year]"` | Date format specification for `datetime` instances. |
| `time` | `str`, `none`, `auto` | `auto` | Presentation hour/time (e.g., `"14:00"`). If `none` or unspecified in CLI, displays `"—"`. |
| `authors` | `array`, `dictionary`, `str` | `()` | Student author(s). Accepts single string, array of strings, or dictionaries with keys `name`, `code`, `email`. |
| `instructor` | `str`, `content` | `"Nombre del Docente"` | Name of the instructor or professor. |
| `institution` | `dictionary`, `str`, `content` | *(see below)* | Institutional hierarchy dictionary containing `university`, `faculty`, and `school`. |
| `doc-code` | `str`, `content` | `"GUIA-PRLE-001"` | Accreditation / quality management document code. |
| `approval-date`| `str`, `content` | `"2022/03/01"` | Formal approval date of the laboratory guide standard. |
| `logo-left` | `auto`, `content`, `str`, `none` | `auto` | Left logo in header. Defaults to department logo (`assets/epis.png`). Set `none` to omit. |
| `logo-right` | `auto`, `content`, `str`, `none` | `auto` | Right logo in header. Defaults to ABET seal (`assets/abet.png`). Set `none` to omit. |
| `primary-color`| `color`, `str` | `rgb("#C8310E")` | Accent color applied to table header cells and branded highlights. |
| `header-border-color` | `color`, `str` | `rgb("#808080")` | Stroke color for the running page header grid. |
| `code-bg-color`| `color`, `str` | `rgb("#F1F3F4")` | Background fill color for code blocks (`raw.where(block: true)`). |
| `font` | `str`, `array` | `("Lato", "Liberation Sans", ...)` | Font family or font preference list. |
| `paper` | `str` | `"a4"` | Document paper format (`"a4"`, `"us-letter"`, etc.). |
| `lang` | `str` | `"es"` | Document language code for hyphenation and Typst primitives. |
| `margin` | `dictionary`, `auto` | `auto` | Page margins. Defaults to `(top: 6cm, bottom: 2.54cm, left: 1.9cm, right: 1.9cm)`. |
| `main-title` | `str`, `content` | `"INFORME DE LABORATORIO"` | Main document heading text placed below the running header. |

##### Default `institution` Dictionary:
```typst
(
  university: "UNIVERSIDAD NACIONAL DE SAN AGUSTÍN",
  faculty: "FACULTAD DE INGENIERÍA DE PRODUCCIÓN Y SERVICIOS",
  school: "ESCUELA PROFESIONAL DE INGENIERÍA DE SISTEMAS",
)
```

> **Tip:** When customizing `logo-left` or `logo-right` with external images, pass `image("path/to/logo.png")` directly as content.

---

### 5. Modular Section Helpers

#### `results-section`
Encloses the lab report exercises, questionnaires, and conclusions within the standardized ABET boxed container. Each section is rendered as an individual bordered cell/row inside the main table:

```typst
// Option A: Explicit named parameters (recommended)
#results-section(
  ejercicios: [
    = SOLUCIÓN DE EJERCICIOS
    Contenido de la resolución...
  ],
  cuestionario: [
    = SOLUCIÓN DEL CUESTIONARIO
    Respuestas a las preguntas formuladas...
  ],
  conclusiones: [
    = CONCLUSIONES
    - Conclusión principal 1.
  ],
)

// Option B: Chained positional content blocks
#results-section[
  = SOLUCIÓN DE EJERCICIOS
  ...
][
  = SOLUCIÓN DEL CUESTIONARIO
  ...
][
  = CONCLUSIONES
  ...
]
```

#### `feedback-box`
Generates the official boxed space for instructor feedback and grading comments:

```typst
#feedback-box(
  title: "RETROALIMENTACIÓN GENERAL", // header title
  height: 6em,                        // vertical blank space if no content
  fill: auto,                         // defaults to package primary-color
  content: none,                      // optional custom content to insert
)
```

#### `bibliography-box`
Wraps the bibliography section in the ABET standardized frame:

```typst
#bibliography-box(
  title: "REFERENCIAS Y BIBLIOGRAFÍA",
  bibliography("references.bib", title: none, style: "ieee")
)
```

---

### 6. Configuration Examples

#### 6.1. Minimal Single-Author Setup
```typst
#import "@preview/unsa-epis-abet-report:0.1.0": *

#show: unsa-epis-abet-report.with(
  title: "Introducción a Sistemas Embebidos",
  lab-number: 1,
  course: "Arquitectura de Computadoras",
  semester: "2026-A",
  authors: "Pérez Quispe, Juan Carlos",
  instructor: "Ing. Docente del Curso",
)

#results-section(
  ejercicios: [
    = 1. Procedimiento Experimental
    Configuración inicial del microcontrolador.
  ],
  conclusiones: [
    = 2. Conclusiones
    - Se inicializaron correctamente los puertos GPIO.
  ],
)

#feedback-box()
```

#### 6.2. Multi-Author Team with Custom Brand Color
```typst
#import "@preview/unsa-epis-abet-report:0.1.0": *

#show: unsa-epis-abet-report.with(
  title: "Concurrencia y Sincronización Multihilo",
  lab-number: 3,
  course: "Sistemas Concurrentes",
  semester: "2026-B",
  date: datetime(year: 2026, month: 11, day: 20),
  time: "15:30",
  primary-color: rgb("#1565C0"), // Custom Cobalt Blue
  authors: (
    "Morales Rojas, Ana Lucía",
    "Mendoza Ramos, Carlos David",
    "Fernández Torres, Lucía Beatriz",
  ),
  instructor: "Dr. Roberto Casas Vargas",
)

#results-section[
  = 1. Problema de Sincronización
  Implementación de monitores y exclusión mutua.
][
  = 2. Conclusiones
  - La exclusión mutua previene condiciones de carrera.
]

#feedback-box()
```

#### 6.3. Custom Institutional Hierarchy & Logos
```typst
#import "@preview/unsa-epis-abet-report:0.1.0": *

#show: unsa-epis-abet-report.with(
  title: "Filtros Digitales FIR",
  lab-number: 4,
  course: "Procesamiento Digital de Señales",
  semester: "2026-I",
  primary-color: rgb("#003366"),
  institution: (
    university: "UNIVERSIDAD NACIONAL DE INGENIERÍA",
    faculty: "FACULTAD DE INGENIERÍA ELÉCTRICA Y ELECTRÓNICA",
    school: "ESCUELA PROFESIONAL DE CIENCIA DE LA COMPUTACIÓN",
  ),
  doc-code: "FIEE-CC-LAB-04",
  approval-date: "2025/08/15",
  authors: "Vargas Huamán, Diego Alonso",
  instructor: "Dr. Docente Especialista",
)

#results-section(
  ejercicios: [
    = 1. Diseño del Filtro
    Respuesta al impulso y coeficientes Kaiser.
  ],
  conclusiones: [
    = 2. Conclusiones
    - Cumplimiento de especificaciones de atenuación.
  ],
)

#feedback-box()
```

---

### 7. Typst Universe Compatibility & Technical Reference

- **Package Immutability:** Once published to Typst Universe under `@preview/unsa-epis-abet-report:0.1.0`, the package release is permanently immutable. Any update, fix, or improvement requires publishing a new version (e.g., `0.1.1` for bug fixes, `0.2.0` for backward-compatible features) following SemVer 2.0.0.
- **Minimum Compiler Version:** Declared as `compiler = "0.13.0"` in `typst.toml`. The package is fully compatible with Typst 0.13.0 through current releases (such as Typst 0.15+).
- **Date & Time Handling:**
  - `date`: Accepts native `datetime` values (e.g. `datetime(year: 2026, month: 10, day: 24)` or `datetime.today()`), strings, or `none`.
  - `time`: When set to `auto`, users can inject the build time via CLI (`typst compile main.typ --input hora="$(date +%H:%M)"`). If omitted or set to `none`, it cleanly renders as `"—"`.

---

### 8. License & Contributing

- **License**: Distributed under the [MIT License](LICENSE).
- **Contributing**: Suggestions, issues, and pull requests are welcome on GitHub: [https://github.com/alvaro9rqc/unsa-epis-abet-report](https://github.com/alvaro9rqc/unsa-epis-abet-report).

---

<a id="español"></a>
## Español

### 1. Descripción General

**`unsa-epis-abet-report`** es una plantilla estandarizada y modular para Typst, creada específicamente para la redacción de informes de prácticas de laboratorio en la **Escuela Profesional de Ingeniería de Sistemas (EPIS)** de la **Universidad Nacional de San Agustín (UNSA)** bajo los estándares de acreditación **ABET**.

Inspirada en las guías oficiales de prácticas universitarias (formato de calidad `GUIA-PRLE-001`), ofrece:
- **Encabezado institucional normado**: incluye jerarquía de universidad, facultad, escuela, código de formato de laboratorio, fecha de aprobación del estándar y logotipos institucionales.
- **Tabla de metadatos completa**: registra curso, número de laboratorio, semestre, fecha y hora de entrega, integrantes (apellidos, nombres, CUI/código, correo electrónico), docente y casillero de nota.
- **Secciones modulares preconfiguradas**: contenedores estandarizados para solución de ejercicios (`results-section`), retroalimentación del docente (`feedback-box`) y referencias bibliográficas (`bibliography-box`).
- **Manejo inteligente de fechas y horas**: integración nativa con `datetime` de Typst, cálculo automático del año lectivo y guión limpio (`"—"`) cuando no se especifica hora, evitando mensajes estáticos no deseados.

---

### 2. Inicio Rápido

Para crear un nuevo informe de laboratorio desde la línea de comandos con Typst Universe:

```bash
typst init @preview/unsa-epis-abet-report:0.1.0 mi-informe
cd mi-informe
typst compile main.typ
```

Este comando descargará e inicializará automáticamente el archivo `main.typ` y la bibliografía de ejemplo `references.bib`.

---

### 3. Instalación y Uso

#### Importación desde Typst Universe
Agrega la importación al inicio de tu archivo `.typ`:

```typst
#import "@preview/unsa-epis-abet-report:0.1.0": *

#show: unsa-epis-abet-report.with(
  title: "Título de la Práctica de Laboratorio",
  lab-number: 1,
  course: "Nombre de la Asignatura",
  semester: "2026-A",
  date: datetime.today(),
  time: auto, // detecta automáticamente --input hora="$(date +%H:%M)"
  authors: (
    "Quispe Condori, Alvaro Raul",
    "Pérez Quispe, Juan Carlos",
  ),
  instructor: "Nombre del Docente",
)

#results-section(
  ejercicios: [
    = SOLUCIÓN DE EJERCICIOS
    Desarrollo de las actividades...
  ],
  cuestionario: [
    = SOLUCIÓN DEL CUESTIONARIO
    Respuestas a las preguntas formuladas...
  ],
  conclusiones: [
    = CONCLUSIONES
    - Conclusiones del desarrollo experimental.
  ],
)

#feedback-box()

#bibliography-box(
  bibliography("references.bib", title: none, style: "ieee")
)
```

#### Desarrollo Local y Pruebas
Si deseas probar la plantilla localmente antes de su publicación o trabajar con los archivos fuente:

```bash
# En Linux / macOS
mkdir -p ~/.cache/typst/packages/preview/unsa-epis-abet-report/0.1.0
cp -r lib.typ template assets typst.toml README.md LICENSE thumbnail.png ~/.cache/typst/packages/preview/unsa-epis-abet-report/0.1.0/

# En Windows (PowerShell)
New-Item -ItemType Directory -Force -Path "$env:LOCALAPPDATA\typst\packages\preview\unsa-epis-abet-report\0.1.0"
Copy-Item -Recurse lib.typ, template, assets, typst.toml, README.md, LICENSE, thumbnail.png "$env:LOCALAPPDATA\typst\packages\preview\unsa-epis-abet-report\0.1.0"
```

Luego puedes compilar `template/main.typ`:
```bash
typst compile template/main.typ
```

---

### 4. Referencia de Parámetros

#### `unsa-epis-abet-report(...)` (alias `abet-report`)

| Parámetro | Tipo | Valor por Defecto | Descripción |
| :--- | :--- | :--- | :--- |
| `title` | `str`, `content` | `"Título de la Práctica"` | Título descriptivo de la práctica de laboratorio. |
| `lab-number` | `int`, `str`, `content` | `"1"` | Número o identificador de la sesión de laboratorio. |
| `course` | `str`, `content` | `"Laboratorio de Computación"` | Nombre oficial de la asignatura o materia. |
| `semester` | `str`, `content` | `"A"` | Semestre lectivo (ej. `"A"`, `"2026-A"`, `"II"`). |
| `academic-year` | `str`, `int`, `auto` | `auto` | Año académico. En `auto`, se deduce del parámetro `date` o del año en curso. |
| `date` | `auto`, `datetime`, `str`, `none` | `auto` | Fecha de presentación. En `auto`, usa `datetime.today()`. Con `none`, muestra `"—"`. |
| `date-format` | `str` | `"[day]/[month]/[year]"` | Formato para renderizar fechas de tipo `datetime`. |
| `time` | `str`, `none`, `auto` | `auto` | Hora de entrega (ej. `"14:00"`). Si no se define o es `none`, muestra `"—"`. |
| `authors` | `array`, `dictionary`, `str` | `()` | Lista de autores o autor individual. Permite diccionario con campos `name`, `code` y `email`. |
| `instructor` | `str`, `content` | `"Nombre del Docente"` | Nombre y título del docente responsable. |
| `institution` | `dictionary`, `str`, `content` | *(ver tabla inferior)* | Jerarquía institucional (`university`, `faculty`, `school`). |
| `doc-code` | `str`, `content` | `"GUIA-PRLE-001"` | Código normativo del formato de calidad. |
| `approval-date`| `str`, `content` | `"2022/03/01"` | Fecha de aprobación del formato institucional. |
| `logo-left` | `auto`, `content`, `str`, `none` | `auto` | Logo izquierdo del encabezado. Por defecto usa el logo de EPIS (`assets/epis.png`). |
| `logo-right` | `auto`, `content`, `str`, `none` | `auto` | Logo derecho del encabezado. Por defecto usa el sello ABET (`assets/abet.png`). |
| `primary-color`| `color`, `str` | `rgb("#C8310E")` | Color primario para cabeceras de tablas y secciones. |
| `header-border-color` | `color`, `str` | `rgb("#808080")` | Color de bordes para la tabla del encabezado de página. |
| `code-bg-color`| `color`, `str` | `rgb("#F1F3F4")` | Color de fondo de los bloques de código fuente. |
| `font` | `str`, `array` | `("Lato", "Liberation Sans", ...)` | Tipografía principal y lista de fuentes de reserva. |
| `paper` | `str` | `"a4"` | Formato de hoja (`"a4"`, `"us-letter"`). |
| `lang` | `str` | `"es"` | Idioma del documento para separación silábica y términos Typst. |
| `margin` | `dictionary`, `auto` | `auto` | Márgenes de página. Por defecto: `(top: 6cm, bottom: 2.54cm, left: 1.9cm, right: 1.9cm)`. |
| `main-title` | `str`, `content` | `"INFORME DE LABORATORIO"` | Título general centrado bajo el encabezado. |

> **Nota:** Al personalizar `logo-left` o `logo-right`, pasa directamente el contenido `image("ruta/al/logo.png")`.

---

### 5. Secciones Modulares

1. **`results-section(...)`**:
   Agrupa los ejercicios resueltos, cuestionarios y conclusiones dentro de la tabla principal, renderizando cada sección como una celda independiente con bordes divisorios normados (`stroke: 0.5pt`).
   ```typst
   // Opción A: Argumentos nombrados (recomendado)
   #results-section(
     ejercicios: [
       = SOLUCIÓN DE EJERCICIOS
       ...
     ],
     cuestionario: [
       = SOLUCIÓN DEL CUESTIONARIO
       ...
     ],
     conclusiones: [
       = CONCLUSIONES
       ...
     ],
   )

   // Opción B: Bloques posicionales encadenados
   #results-section[
     = SOLUCIÓN DE EJERCICIOS
     ...
   ][
     = SOLUCIÓN DEL CUESTIONARIO
     ...
   ][
     = CONCLUSIONES
     ...
   ]
   ```

2. **`feedback-box(...)`**:
   Genera el espacio en blanco requerido para que el docente calificador asigne observaciones o rúbrica de retroalimentación.
   ```typst
   #feedback-box(title: "RETROALIMENTACIÓN GENERAL", height: 6em)
   ```

3. **`bibliography-box(...)`**:
   Enmarca la bibliografía generada con el motor nativo de Typst dentro del estilo visual uniforme del documento.
   ```typst
   #bibliography-box(
     bibliography("references.bib", title: none, style: "ieee")
   )
   ```

---

### 6. Patrones de Configuración

#### 6.1. Configuración Mínima y Fecha Automática
```typst
#import "@preview/unsa-epis-abet-report:0.1.0": *

#show: unsa-epis-abet-report.with(
  title: "Introducción a Sistemas Embebidos",
  lab-number: 1,
  course: "Arquitectura de Computadoras",
  semester: "2026-A",
  authors: "Pérez Quispe, Juan Carlos",
  instructor: "Ing. Docente del Curso",
)

#results-section(
  ejercicios: [
    = 1. Procedimiento Experimental
    Configuración inicial del microcontrolador.
  ],
  conclusiones: [
    = 2. Conclusiones
    - Se inicializaron correctamente los puertos GPIO.
  ],
)

#feedback-box()
```

#### 6.2. Equipo Multiautor con Color Personalizado
```typst
#import "@preview/unsa-epis-abet-report:0.1.0": *

#show: unsa-epis-abet-report.with(
  title: "Concurrencia y Sincronización Multihilo",
  lab-number: 3,
  course: "Sistemas Concurrentes",
  semester: "2026-B",
  date: datetime(year: 2026, month: 11, day: 20),
  time: "15:30",
  primary-color: rgb("#1565C0"), // Azul Cobalto personalizado
  authors: (
    "Morales Rojas, Ana Lucía",
    "Mendoza Ramos, Carlos David",
    "Fernández Torres, Lucía Beatriz",
  ),
  instructor: "Dr. Roberto Casas Vargas",
)

#results-section[
  = 1. Problema de Sincronización
  Implementación de monitores y exclusión mutua.
][
  = 2. Conclusiones
  - La exclusión mutua previene condiciones de carrera.
]

#feedback-box()
```

#### 6.3. Institución y Logotipos Personalizados
```typst
#import "@preview/unsa-epis-abet-report:0.1.0": *

#show: unsa-epis-abet-report.with(
  title: "Filtros Digitales FIR",
  lab-number: 4,
  course: "Procesamiento Digital de Señales",
  semester: "2026-I",
  primary-color: rgb("#003366"),
  institution: (
    university: "UNIVERSIDAD NACIONAL DE INGENIERÍA",
    faculty: "FACULTAD DE INGENIERÍA ELÉCTRICA Y ELECTRÓNICA",
    school: "ESCUELA PROFESIONAL DE CIENCIA DE LA COMPUTACIÓN",
  ),
  doc-code: "FIEE-CC-LAB-04",
  approval-date: "2025/08/15",
  authors: "Vargas Huamán, Diego Alonso",
  instructor: "Dr. Docente Especialista",
)

#results-section(
  ejercicios: [
    = 1. Diseño del Filtro
    Respuesta al impulso y coeficientes Kaiser.
  ],
  conclusiones: [
    = 2. Conclusiones
    - Cumplimiento de especificaciones de atenuación.
  ],
)

#feedback-box()
```

---

### 7. Compatibilidad con Typst Universe y Referencia Técnica

- **Inmutabilidad de Paquetes:** Al publicarse en Typst Universe bajo `@preview/unsa-epis-abet-report:0.1.0`, dicha versión es permanente e inmutable. Cualquier actualización, corrección o cambio futuro requiere un incremento de versión (ej. `0.1.1` para corrección de errores, `0.2.0` para nuevas características compatibles) de acuerdo con SemVer 2.0.0.
- **Versión Mínima del Compilador:** Declarada como `compiler = "0.13.0"` en `typst.toml`. Es compatible hacia adelante con versiones recientes de Typst (como 0.15+).
- **Manejo de Fechas y Horas:**
  - `date`: Admite instancias nativas de `datetime` (ej. `datetime(year: 2026, month: 10, day: 24)` o `datetime.today()`), cadenas de texto o `none`.
  - `time`: Con valor `auto`, permite capturar la hora de compilación vía CLI (`typst compile main.typ --input hora="$(date +%H:%M)"`). Si no se proporciona o se define en `none`, se visualiza de forma limpia como `"—"`.

---

### 8. Licencia y Contribución

- **Licencia**: Distribuido bajo la [Licencia MIT](LICENSE). Consulta el archivo de licencia para más detalles.
- **Contribuciones**: Se aceptan sugerencias, correcciones y pull requests en el repositorio oficial de GitHub: [https://github.com/alvaro9rqc/unsa-epis-abet-report](https://github.com/alvaro9rqc/unsa-epis-abet-report).
