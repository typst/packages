#import "@preview/deal-us-tfc-template:1.0.0": *

= Ejemplos de uso de Typst
<sec:ejemplos>

Este capítulo se incluye únicamente como ayuda y referencia de uso de Typst. \ No debe aparecer en el documento final.

== Intruducción

En este capítulo se muestran ejemplos de uso de Typst para operaciones
comunes. En el código fuente se pueden observar dos modos: contenido, y código. En un archivo, el modo por defecto es el modo contenido. Para usar el modo código dentro del contenido, por ejemplo para llamar a una función, se usa el símbolo ```Typst #```, pero si ya se está en modo código no es necesario usarlo. De forma inversa, para indicar contenido estando en el modo código, se delimita el contenido con ```Typst [...]```.

== Estilos
<sec:estilos> 

Se pueden aplicar estilos al texto como *negritas*, _cursiva_, #underline[subrayado] y ` monoespaciado`. También se #text(fill: red)[pueden] #text(fill: blue)[aplicar] #text(fill: green)[colores] y #underline[_combinar_] #text(fill: red)[*estilos*]. Se recomienda usar sólo negritas para hacer énfasis, y no abusar de este recurso.

Para cambiar el formato de grandes cantidades de contenido, deben usarse las funciones ```Typst #set funcion(parametro:valor)``` (altera un parámetro siempre que se llame a la función ) y ```Typst #show funcionOContenido: it => {...}``` (reemplaza el resultado de una función o contenido concreto completamente).

== Listados

Con '-' se pueden crear listas no numeradas:

- Fresas
- Melocotones
- Piñas
- Nectarinas

De manera similar, '1.' permite crear listas numeradas

1. Elaborar la memoria del TFG
2. Elaborar la presentación
3. Presentar el TFG
4. Solicitar el título de Grado

== Subsecciones

Se pueden definir subsecciones con diferentes cantidades de '=':

=== Primera subsección
<sec:subseccion>

Esto es una subsección

=== Segunda subsección

Esto es otra subsección

==== Sub-sub-sección

Este es un tercer nivel de profundidad, que no aparece en el índice general. Se recomienda no utilizarlo, si es posible.

== Imágenes y figuras

Todas las imágenes y figuras del documento se incluirán en la carpeta 'figures'. Se pueden incluir de la siguiente manera:

#figure(
  image("/figures/ejemplo.png", width:70%),
  caption: "Un feroz depredador"
)<fig:ejemplo>

Observe que las figuras se numeran automáticamente según el capítulo y el número de figuras que hayan aparecido anteriormente en dicho capítulo. Existen muchas maneras de definir el tamaño de una figura, pero se aconseja utilizar la mostrada en este ejemplo: se define el ancho de la figura como un porcentaje del ancho total de la página, y la altura se escala automáticamente.

Tenga en cuenta que Typst intenta incluir las figuras en el mismo sitio donde se declaran, pero en ocasiones no es posible por motivos de espacio. En estos casos, Typst colocará la figura lo más cerca posible de su declaración, puede que en una página diferente. Esto es un comportamiento normal.

== Tablas

Existe una gran variedad de formas de crear tablas en Typst puro. Se pueden usar dos funciones similares: ```Typst #table``` y ```Typst #grid```. ```Typst #grid``` es la función básica, mientras que ```Typst #table``` añade básicamente presets para algunos atributos relacionados con el aspecto. Mediante ```Typst #set``` y ```Typst #show``` se pueden alterar estilos para una fila o columna concreta. A continuación se muestra un ejemplo simple de tabla nativa, en la @table:ejemplo.

Usando un ```Typst #grid``` se podría colocar manualmente dónde hay bordes con funciones indicadas en la documentación.

#include "../tables/tabla_ejemplo.typ"

Para tablas con un formato más complejo, considere la posibilidad de diseñarla usando otro software externo (por ejemplo Excel) e incluirla de manera similar a una figura. *Observe en el código Typst a continuación cómo usar el atributo ```Typst kind``` para indicar manualmente el tipo de figura (figura en Typst no son las imágenes sino un elemento genérico con leyenda). Se puede indicar cualquier ```Typst kind``` personalizado como se indica en la documentación:*

#figure(
  image("../tables/complex_table.png", width:100%),
  caption: "Tabla compleja introducida como imagen",
  kind: table,
)<table:ejemplo2>

== Referencias

Observe cómo en el código fuente de esta sección se ha usado varias veces el siguiente formato: ```Typst <etiqueta>```. Esto permite marcar un elemento, ya sea capítulo, sección, figura, etc. para hacer una referencia numérica al mismo. Para referenciar una etiqueta se usa el formato de ```Typst @referencias``` incluyendo el nombre de la referencia:

Esta es la @sec:ejemplos.

En la @sec:estilos se muestran ejemplos de estilos.

La @sec:subseccion explica...

En la @fig:ejemplo vemos que...

Esto evita que tengamos que escribir directamente los índices de las secciones y figuras que queremos mencionar, ya que Typst lo hace por nosotros y además se encarga de mantenerlos actualizados en caso de que cambien (pruebe a mover este capítulo al final del documento y observe cómo se actualizan automáticamente todos los índices referenciados). Además, las referencias actúan como hipervínculos dentro del documento que llevan al elemento referenciado al pulsar en ellas.

Es habitual nombrar las etiquetas con un prefijo que indica el tipo de elemento para encontrarlo luego más fácilmente, pero no es obligatorio.

== Extractos de código

Se pueden incluir extractos de código, existiendo paquetes que los hacen más bonitos como #link("https://typst.app/universe/package/codly")[codly]:

#figure(
```python
if num > 0:
   print("Positive number")
elif num == 0:
   print("Zero")
else:
   print("Negative number")
```,
caption: "Código Python"
)<cod:python>

Se puede usar la función proporcionada para cambiar desde el momento que se usa el estilo de los fragmentos. Por ejemplo, al comienzo de esta plantilla se llama a `Typst #codly(zebra-fill:none)` para eliminar el sombreado alterno de las líneas.

Para evitar tener que incluir el código directamente en el texto del documento, se pueden guardar en archivos separados y referenciarlos:

#figure(
raw(read("/code/java_example.java"), block: true, lang:"java"),
caption: "Código Java"
)<cod:java>

#figure(
raw(read("/code/html_example.html"), block: true, lang:"html"),
caption: "Código HTML"
)<cod:html>

#figure(
raw(read("/code/javascript_example.js"), block: true, lang:"javascript"),
caption: "Código JavaScript"
)<cod:js>
/*
Los extractos de código también se pueden referenciar: @cod:python, @cod:java, @cod:html, @cod:js.
*/
== Enlaces

Puede enlazar una web externa mediante la función ```Typst #link``` o directamente escribiendo el enlace: https://example.com. También se puede vincular un enlace a un texto: #link("https://example.com")[dominio de ejemplo].

== Citas y bibliografía

En Typst, los elementos de la bibliografía se almacenan en un fichero bibliográfico en un formato llamado `.bib`, en el caso de este proyecto se encuentran en `bibliografia.bib`. Para citar un elemento se usa el mismo formato de ```Typst @referencias```. Se pueden citar tanto artículos científicos @borrego2019 como enlaces web @webETSII. 

También se puede usar la función ```Typst #cite``` para incluir opciones adicionales o personalizar el resultado, como incluir una referencia junto con el nombre de su autor o autores: #cite(<borrego2021>, form: "prose") #footnote[El estilo bibliográfico, determinado por un archivo CSL que puede personalizarse, determina cuando la lista de autores se reemplaza por '_et al_'. Ver https://github.com/typst/hayagriva/issues/164]. Todas las citas se numeran automáticamente y se incluyen en la sección de bibliografía del trabajo. El orden por defecto es según su orden de aparición en el documento. Para ordenarlas por orden alfabético del autor, puede modificar la opción `style` de la función ```Typst #bibliography("/bibliografia.bib", style:...)``` del archivo principal y reemplazar su valor por otro estilo.

Observe cómo los elementos bibliográficos almacenados en `bibliografia.bib` tienen una etiqueta asociada, que es la que se usa al citarlos. *Añadir una referencia al fichero bibliográfico no hace que ésta aparezca automáticamente en la sección de bibliografía del trabajo, es necesario citarla en algún lugar del mismo*.

== Ecuaciones

Typst tiene un potente motor para mostrar ecuaciones matemáticas y un amplio catálogo de símbolos matemáticos. El entorno matemático se puede activar de muchas maneras. Para incluir ecuaciones simples en un texto se pueden rodear de símbolos dólar: $1 + 2 = 3$, $sqrt(81) = 3^2 = 9$, $forall x in y thin exists thin z : S_z < 4$.

Las ecuaciones más complejas pueden expresarse aparte y son numeradas: @eq:ecuacion

$ limits("lím")_(x -> 0) (e^x - 1) / (2x) limits(=)_(upright(H))^[0/0] 
limits("lím")_(x -> 0) e^2/2 =
1/2 + 7 integral_0^2(-1/4(e^(-4t_1) + e^(4t_1-8) )) dif t_1 $<eq:ecuacion>

Dispone #link("https://typst.app/docs/reference/symbols/sym/")[aquí] de un amplio listado de símbolos que pueden usarse en modo matemático.

== Caracteres y símbolos especiales

Algunos caracteres y símbolos deben ser escapados para poder representarse en el documento, ya que tienen un significado especial en Typst. Algunos de ellos son:

- El símbolo dólar \$ se usa para ecuaciones.
- Los símbolos usados para formato como \*, \_ , \` .
- Las comillas deben expresarse \'así\' para comillas simples y 'así' para comillas dobles. Las comillas españolas pueden expresarse "así".
- La almohadilla \# se usa para llamar a funciones dentro del modo contenido.