#import "@preview/unsa-epis-abet-report:0.1.0": *

#show: unsa-epis-abet-report.with(
  title: "Estructuras de Datos y Complejidad Algorítmica",
  lab-number: 1,
  course: "Laboratorio de Algoritmos y Complejidad",
  semester: "2026-A",
  date: datetime.today(),
  // time: auto lee automáticamente la hora de compilación si se pasa:
  // typst compile template/main.typ --input hora="$(date +%H:%M)"
  // También puedes definir una hora estricta como "23:59"
  time: auto,
  // Por defecto se muestran únicamente los nombres de los integrantes:
  authors: (
    "Pérez Quispe, Juan Carlos",
    "García López, María Elena",
  ),
  instructor: "Dr. Docente Principal",
)

// Las secciones de solución de ejercicios, cuestionario y conclusiones son
// celdas individuales dentro de la tabla principal con bordes divisorios.
// Puedes usar argumentos nombrados (ejercicios, cuestionario, conclusiones)
// o bloques encadenados: #results-section[...][...][...]
#results-section(
  ejercicios: [
    = Solución de Ejercicios

    En esta sección se presentan el desarrollo, implementación y análisis experimental de los algoritmos solicitados en la guía de práctica.

    == Ejercicio 1: Búsqueda y Ordenamiento

    A continuación se muestra una implementación de referencia en Python para el algoritmo de ordenamiento rápido (Quicksort):

    ```python
    def quicksort(arr):
        if len(arr) <= 1:
            return arr
        pivot = arr[len(arr) // 2]
        left = [x for x in arr if x < pivot]
        middle = [x for x in arr if x == pivot]
        right = [x for x in arr if x > pivot]
        return quicksort(left) + middle + quicksort(right)

    # Ejemplo de ejecución
    datos = [38, 27, 43, 3, 9, 82, 10]
    print(quicksort(datos))
    ```

    == Ejercicio 2: Análisis de Desempeño

    Para evaluar la eficiencia algorítmica, se registraron los tiempos de ejecución teóricos y empíricos en función del tamaño de entrada $N$, siguiendo el marco formal de Cormen et al. @cormen2009introduction.

    #figure(
      rect(
        width: 80%,
        height: 70pt,
        stroke: 0.5pt + luma(160),
        radius: 4pt,
        fill: luma(248),
        align(center + horizon)[
          #text(size: 9pt, style: "italic", fill: luma(100))[
            Esquema de partición del vector y ordenamiento por divide y vencerás
          ]
        ],
      ),
      caption: [Flujo esquemático del proceso de partición y resolución recursiva.],
    ) <fig:sample>

    Como se ilustra en la @fig:sample, la estrategia divide y vencerás permite particionar el espacio del problema con una complejidad promedio de $cal(O)(N log N)$.

    === Métricas de Evaluación

    Se analizaron tres métricas fundamentales durante las pruebas experimentales:
    - Tiempo de CPU en microsegundos ($mu s$).
    - Uso de memoria en la pila de llamadas recursivas.
    - Número de comparaciones e intercambios realizados.
  ],
  cuestionario: [
    = Cuestionario

    - *Pregunta 1:* ¿Cuál es la diferencia fundamental entre la complejidad temporal en el peor caso y en el caso promedio para Quicksort?

      En el caso promedio, la partición divide el arreglo en subarreglos de tamaño proporcional, resultando en una profundidad de recursión de $log N$ y tiempo total $cal(O)(N log N)$. En el peor caso (por ejemplo, pivote siempre extremo en un arreglo ya ordenado), la profundidad de recursión asciende a $N$, alcanzando una complejidad de $cal(O)(N^2)$ @cormen2009introduction.

    - *Pregunta 2:* ¿De qué manera influye la teoría de la información en la cota inferior de ordenamiento por comparaciones?

      Shannon demostró en su teoría matemática de la comunicación @shannon1948mathematical que distinguir entre $N!$ permutaciones posibles requiere un mínimo de $log_2 (N!) approx N log_2 N - N log_2 e$ bits de información. En consecuencia, ningún algoritmo basado exclusivamente en comparaciones binarias puede tener una cota inferior asintótica menor a $Omega(N log N)$.
  ],
  conclusiones: [
    = Conclusiones

    - Se comprobó experimentalmente que el enfoque divide y vencerás optimiza significativamente el tiempo de respuesta frente a algoritmos cuadráticos.
    - La elección del pivote resulta determinante para la estabilidad de la complejidad asintótica en tiempo de ejecución.
    - La estructura modular del informe facilita la presentación rigurosa de resultados bajo los estándares de acreditación ABET.
  ],
)

#feedback-box()

#bibliography-box[
  #bibliography("references.bib", style: "ieee")
]
