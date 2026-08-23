#import "@preview/complete-unsaac:0.2.3": (
  actividades-contenidos, actividades-gantt, doc-practica-informe-parcial,
)

#import "actividades/mes01.typ": acts01

#show: doc-practica-informe-parcial.with(
  titulo: [Informe N° 01 - Prácticas Pre Profesionales],
  autor: [Nombre Completo Autor],
  codigo: 100001,
  asesor: [],
  empresa: [],
  jefe: [],
  area: [Soporte y tecnología de la información],
  fecha-inicio: datetime(day: 02, month: 01, year: 2001),
  // horario: [Lunes a viernes, 09:00 – 13:00 hrs y 18:00 – 20:00],
  horas-por-dia: 6,
  actividades: acts01,
  // facultad: highlight[Ingrese su facultad],
  // escuela: highlight[Ingrese su E.P.],
  // escuela-logo: rect(height: 100%)[Ponga la imagen de su escudo aca],
  // duplex: true,
  // binding-margin: 5%,
)

= Diagrama de actividades
#actividades-gantt()

= Actividades Realizadas
#actividades-contenidos()

= Dificultades Encontradas
#lorem(20)
- #lorem(10)
- #lorem(10)
- #lorem(10)

= Conclusiones del Mes
#lorem(50)

= Plan para el siguiente Mes
#lorem(50)
