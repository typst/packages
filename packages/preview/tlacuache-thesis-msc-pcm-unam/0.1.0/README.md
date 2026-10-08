# tlacuache-thesis-pcm-unam template

🇺🇸 [English](README.en.md)

Este repositorio contiene un template para tesis de maestría del Posgrado en Ciencias Matemáticas de la Universidad Nacional Autónoma de México (UNAM).

El diseño está basado en el template [tlacuache-thesis-fc-unam](https://github.com/davidalencia/tlacuache-thesis-fc-unam), originalmente desarrollado para la licenciatura en la Facultad de Ciencias. La portada ha sido adaptada para cumplir (de manera aproximada) con los lineamientos del programa de posgrado.

## Uso

⚠️ Nota: Actualmente este template no se encuentra en el repositorio oficial de paquetes de Typst.

- Clonar el repositorio usando git:
  ```bash
  git clone git@github.com:rubal501/tlacuache-thesis-pccm-unam.git
  ```
- Importa el template en tu archivo principal:
  ```typ
  #import "./tlacuache-thesis-pccm-unam/lib.typ":*
  ```

## Configuración

Para configurar tu tesis puedes hacerlo con estas lineas al inicio de tu archivo principal.

```typ
#import "./tlacuache-thesis-pccm-unam/lib.typ":*

#show: thesis.with(
  titulo: [Titulo],
  autor: [Autor],
  asesor: [Asesor],
  asesorAD: [Instituto 1],
  lugar: [Ciudad de México, México],
  agno: [#datetime.today().year()],
  bibliography: bibliography("references.bib"),
)

// Tu tesis va aquí
```

### Parámetros de la portada

| Parámetro   | Descripción                                                      | Valor por defecto               |
|-------------|------------------------------------------------------------------|---------------------------------|
| `titulo`    | Título de la tesis                                               | `[Titulo]`                      |
| `autor`     | Nombre completo del autor                                        | `[Autor]`                       |
| `asesor`    | Nombre del director de tesis                                     | `[Asesor]`                      |
| `asesorAD`  | Adscripción del director (instituto o facultad)                  | `[Adscripción]`                 |
| `lugar`     | Ciudad y país donde se presenta la tesis                         | `[Ciudad de México, México]`    |
| `agno`      | Año de presentación                                              | Año actual                      |

### Parámetros de contenido

| Parámetro         | Descripción                                                  | Valor por defecto |
|-------------------|--------------------------------------------------------------|-------------------|
| `bibliography`    | Referencia al archivo de bibliografía (`bibliography(...)`)  | `[]` (ninguna)    |
| `abstract`        | Resumen de la tesis                                          | `[]` (ninguno)    |
| `agradecimientos` | Sección de agradecimientos                                   | `[]` (ninguno)    |

También puedes utilizar estas lineas para crear capítulos con bibliografía,
si deseas crear un pdf solamente para el capítulo.

```typ
#import "./tlacuache-thesis-pccm-unam/lib.typ":chapter


// completamente opcional cargar la bibliografía, compilar el capítulo
#show: chapter.with(bibliography: bibliography("references.bib"))

// Tu capítulo va aquí
```

Si quieres crear pdf aún más cortos, puedes utilizar estas lineas para crear un pdf solo para la sección de tu capítulo.

```typ
#import "./tlacuache-thesis-pccm-unam/lib.typ":section


// completamente opcional cargar la bibliografía, compilar el sección
#show: section.with(bibliography: bibliography("references.bib"))

// Tu sección va aquí
```

## 🫶 Agradecimientos

- [David Valencia Rodríguez](https://github.com/davidalencia) por el desarrollo del template original.

## 🚨 Disclaimer

Este template no es oficial y no está afiliado al Posgrado en Ciencias Matemáticas de la UNAM. Su uso es bajo responsabilidad del usuario.
