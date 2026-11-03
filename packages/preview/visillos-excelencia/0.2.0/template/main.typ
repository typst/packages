#import "@preview/visillos-excelencia:0.2.0": *

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
  // tamano-fuente: 12pt,     // Descomenta para ajustar el tamaño del texto
  // interlineado: 1em,       // Descomenta para ajustar el interlineado
  // color-acento: rgb("#279985"), // Descomenta para cambiar el color de los títulos
  doble-cara: false, // Pon true si vas a imprimir a doble cara (capítulos en página impar)

  // Páginas iniciales: la plantilla les pone título, página propia y entrada en el índice.
  // Cualquier pieza opcional se quita poniendo false (o none), o borrando su línea.
  abstract: include "Archivos/00_1_Abstract.typ",
  resumen: include "Archivos/00_2_Resumen.typ",
  agradecimientos: include "Archivos/00_3_Agradecimientos.typ",

  // Bibliografía y listas finales (van al final del documento, en este orden).
  // Las listas de figuras y tablas aparecen solas si el documento las tiene;
  // fuerza con lista-figuras: true/false (igual lista-tablas).
  bibliografia: bibliography("referencias.yaml", style: "apa", title: "Bibliografía"),
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
#include "Archivos/04_Anexos.typ"
#include "Archivos/05_Glosario.typ"
