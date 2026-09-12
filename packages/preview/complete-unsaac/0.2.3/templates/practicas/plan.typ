#import "@preview/complete-unsaac:0.2.3": actividades-tabla, doc-practica-plan-actividades

#import "actividades/mes01.typ": acts01
#import "actividades/mes02.typ": acts02

#show: doc-practica-plan-actividades.with(
  titulo: [Plan de Prácticas Pre Profesionales],
  autor: [Nombre Completo Autor],
  codigo: 100001,
  asesor: [],
  empresa: [Nombre de la Empresa],
  jefe: [],
  area: [Soporte y tecnología de la información],
  fecha-inicio: datetime(day: 02, month: 01, year: 2001),
  horario: [Lunes a viernes, 09:00 – 13:00 hrs y 18:00 – 20:00],
  horas-por-dia: 6,
  actividades: (
    ..acts01,
    ..acts02,
  ),
  // facultad: highlight[Ingrese su facultad],
  // escuela: highlight[Ingrese su E.P.],
  // escuela-logo: rect(height: 100%)[Ponga la imagen de su escudo aca],
)

#v(1em)
#heading(numbering: none, outlined: false)[Plan de Actividades]
#actividades-tabla()
