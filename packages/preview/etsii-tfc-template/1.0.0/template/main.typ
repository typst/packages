#import "@preview/etsii-tfc-template:1.0.0": *

#show: TFC.with(
  titulo: "Trabajo fin de grado",
  alumno: "Nombre Del Alumno",
  titulacion: "Grado en Ingeniería Informática - Ingeniería del Software",
  director: [Director 1 \ Director 2],
  departamento: "Lenguajes y Sistemas Informáticos",
  convocatoria: "Convocatoria de junio/julio/diciembre, curso 20XX/YY",
  dedicatoria: "Aquí la dedicatoria del trabajo",
  agradecimientos: [
    Quiero agradecer a X por...

    También quiero agradecer a Y por...
  ],
  resumen: [
    Incluya aquí un resumen de los aspectos generales de su trabajo, en español
  ],
  palabrasClave: (
    "palabra clave 1", 
    "palabra clave 2", 
    "...", 
    "palabra clave N"
  ),
  abstract: [
    This section should contain an English version of the Spanish abstract.
  ],
  keywords: (
    "keyword 1", 
    "keyword 2", 
    "...", 
    "keyword N"
  )
)

#include "sections/ejemplos_borrame.typ"
#include "sections/01_introduccion.typ"
#include "sections/02_Gestion.typ"
#include "sections/03_Analisis.typ"
#include "sections/04_Diseño.typ"
#include "sections/05_Implementacion.typ"
#include "sections/06_Pruebas.typ"
#include "sections/XX_Conclusiones.typ"

#bibliography("/bibliografia.bib")