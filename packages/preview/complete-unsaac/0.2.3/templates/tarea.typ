#import "@preview/complete-unsaac:0.2.3": doc-tarea, src-block, src-file

#show: doc-tarea.with(
  titulo: [Laboratorio 03: Derivadas Parciales y Gradiente],
  curso: [Metodos Probabilisticos],
  docente: [Dr. Juan Perez Quispe],
  autores: (
    (
      nombre: "Carlos Alberto Ramos",
      codigo: "201302",
    ),
    (
      nombre: "Lucia Fernandez Huaman",
      codigo: "201302",
    ),
  ),
  // facultad: highlight[Ingrese su facultad],
  // escuela: highlight[Ingrese su E.P.],
  // escuela-logo: rect(height: 100%)[Ponga la imagen de su escudo aca],
  // duplex: true,
  // binding-margin: 5%,
)

#set heading(numbering: "1.1")

= Marco Teorico

== Definicion de derivadas parciales

Las derivadas parciales permiten analizar funciones de multiples variables respecto a una sola
variable independiente, manteniendo las demas constantes.

Sea la funcion:
$
  f(x, y) = x^2 y + sin(x y)
$

La derivada parcial respecto a $x$ se define como:
$
  frac(partial f, partial x)
$

Mientras que la derivada parcial respecto a $y$ se expresa como:
$
  frac(partial f, partial y)
$

== Interpretacion geometrica

Las derivadas parciales representan la pendiente de la superficie en una direccion especifica. Esto
permite estudiar el comportamiento local de funciones multivariables.

== Aplicaciones

Las derivadas parciales son ampliamente utilizadas en:

- Optimizacion matematica.
- Redes neuronales y aprendizaje automatico.
- Simulacion fisica.
- Metodos numericos.
- Modelos economicos multivariables.

= Desarrollo

== Implementacion del algoritmo

Para el presente laboratorio se implemento un programa en Python que aproxima derivadas parciales
mediante diferencias finitas.

#src-block[
  ```python
  import math

  def f(x, y):
      return x**2 * y + math.sin(x*y)

  def parcial_x(x, y, h=0.0001):
      return (f(x + h, y) - f(x, y)) / h

  def parcial_y(x, y, h=0.0001):
      return (f(x, y + h) - f(x, y)) / h

  x = 2
  y = 3

  print("df/dx =", parcial_x(x, y))
  print("df/dy =", parcial_y(x, y))
  ```
]

// #image("ejemplo.png", width: 100%)
