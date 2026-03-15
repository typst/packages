#import "@preview/plantilla-excelencia-gaite:0.1.0": *

// Aquí configuras los datos de tu proyecto
#show: proyecto.with(
  titulo: "Las reliquias de la muerte",
  autor: "Harry Potter",
  supervisor: "Albus Dumbledore",
  instituto: "IES Carmen Martín Gaite",
  lugar: "Navalcarnero",
  fecha: "Mayo 2026", // Cambia la fecha a la de entrega
  logo: image("Logo.svg", width: 30%),
  fuente: "Libertinus Serif", // Puedes cambiar a "Times New Roman" si la tienes instalada
)

// ==========================================
// INCLUYE AQUÍ LOS ARCHIVOS DE TU PROYECTO
// ==========================================

// 1. Páginas iniciales
#include "Archivos/00_1_Abstract.typ"
#include "Archivos/00_2_Resumen.typ"
#include "Archivos/00_3_Agradecimientos.typ"

// 2. Capítulos principales
#include "Archivos/01_Introducción.typ"
#include "Archivos/02_Capítulo 1.typ"
#include "Archivos/02_Capítulo 2.typ"
#include "Archivos/02_Capítulo 3.typ"
#include "Archivos/02_Capítulo 4.typ"
// #include "Archivos/02_Capítulo 5.typ" // Quita las barras (//) para añadir más capítulos

// 3. Páginas finales
#include "Archivos/03_Conclusión.typ"
#include "Archivos/04_Anexos.typ"
#include "Archivos/05_Glosario.typ"

// Bibliografía (asegúrate de que el archivo referencias.yaml esté en la misma carpeta)
#bibliography("referencias.yaml", style: "apa", title: "Bibliografía")
