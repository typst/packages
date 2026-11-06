#import "@preview/visillos-excelencia:0.3.0": *

// Aquí configuras los datos de tu proyecto.
// (El trabajo de ejemplo es inventado: sustituye los capítulos por los tuyos.)
#show: proyecto.with(
  titulo: "¿Cuánto tarda en enfriarse un café?",
  autor: "Lucía Martín Ortega y Daniel Ruiz Serrano",
  supervisor: "Elena Gómez Prieto",
  instituto: "IES Carmen Martín Gaite",
  lugar: "Navalcarnero",
  fecha: "Mayo 2026", // Cambia la fecha a la de entrega
  logo: image("Logo.svg", width: 30%),
  fuente: "Libertinus Serif", // Puedes cambiar a "Times New Roman" si la tienes instalada
  // tamano-fuente: 12pt,     // Descomenta para ajustar el tamaño del texto
  // interlineado: 1em,       // Descomenta para ajustar el interlineado
  // color-acento: rgb("#279985"), // Descomenta para cambiar el color de los títulos
  doble-cara: false, // Pon true si vas a imprimir a doble cara (capítulos en página impar)
  contar-palabras: false, // Pon true para ver, tras el índice, cuántas palabras tiene el trabajo

  // Páginas iniciales: la plantilla les pone título, página propia y entrada en el índice.
  // Cualquier pieza opcional se quita poniendo false (o none), o borrando su línea.
  abstract: include "Archivos/00_1_Abstract.typ",
  resumen: include "Archivos/00_2_Resumen.typ",
  agradecimientos: include "Archivos/00_3_Agradecimientos.typ",

  // Bibliografía: tus fuentes van en referencias.yaml. Estilos habituales:
  // "apa", "ieee", "mla", "chicago-author-date", "harvard-cite-them-right",
  // "iso-690-author-date", "vancouver".
  bibliografia: bibliography("referencias.yaml", style: "apa", title: "Bibliografía"),

  // Listas de figuras y tablas (van al final, tras la bibliografía). Por defecto
  // salen solas si el documento tiene figuras o tablas. Para forzarlas:
  // lista-figuras: true,  // o false para quitarla
  // lista-tablas: true,   // o false para quitarla
)

// ==========================================
// INCLUYE AQUÍ LOS ARCHIVOS DE TU PROYECTO
// ==========================================

// Capítulos principales
#include "Archivos/01_Introducción.typ"
#include "Archivos/02_Capítulo 1.typ"
#include "Archivos/02_Capítulo 2.typ"
#include "Archivos/02_Capítulo 3.typ"
#include "Archivos/02_Capítulo 4.typ"
// #include "Archivos/02_Capítulo 5.typ" // Quita las barras (//) para añadir más capítulos

// Páginas finales
#include "Archivos/03_Conclusión.typ"

// A partir de aquí, cada "==" es un anexo numerado (Anexo I, Anexo II…)
#show: anexos
#include "Archivos/04_Anexos.typ"
#include "Archivos/05_Glosario.typ"
