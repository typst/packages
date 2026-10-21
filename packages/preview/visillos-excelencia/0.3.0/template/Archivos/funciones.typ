// Funciones de ayuda para los capítulos. Este fichero no depende de la
// plantilla: cada capítulo que lo use lo importa al principio con
//   #import "funciones.typ": figura

// Figura con título y, si quieres, borde negro y nota debajo (estilo APA).
//
//   #figura(
//     "Imágenes/foto.png",          // la imagen (ruta desde la carpeta Archivos)
//     titulo: [Título de la figura],
//     ancho: 80%,                   // opcional: tamaño de la imagen
//     borde: true,                  // opcional: true o false (sin borde)
//     nota: [Elaboración propia.],  // opcional: sale como «Nota. Elaboración propia.»
//   ) <fig-foto>
//
// En lugar de la ruta puede ir cualquier contenido: una tabla, una gráfica…
#let figura(contenido, titulo: none, ancho: auto, borde: false, nota: none) = {
  let cuerpo = if type(contenido) == str { image(contenido, width: ancho) } else { contenido }
  if borde { cuerpo = box(stroke: 1pt, cuerpo) }
  figure(
    if nota == none { cuerpo } else { [#cuerpo #[#nota] <nota>] },
    caption: titulo,
  )
}
