#import "@preview/enunciado-facil-fcfm:0.1.0" as template

#show: template.conf.with(
  titulo: "Auxiliar 5",
  subtitulo: "Usando el template",
  titulo-extra: (
    [*Profesora*: Ada Lovelace],
    [*Auxiliares*: Grace Hopper y Alan Turing],
  ),
  departamento: template.departamentos.dcc,
  curso: "CC4034 - Composición de documentos",
)

= Sumatorias

Resuelva:
1. $ sum_(k=1)^n k^3 $
2. $ sum_(k=1)^n k 2^k $
3. $ sum_(k=1)^n k 2^k $

= Recurrencias

1. Resuelva la siguiente ecuación de recurrencia:

$ T_n = 2T_(n-1) + n, #h(2cm) T_0 = c. $

2. Sean $a_n, b_n$ secuencias tal que $a_n != 0$ y $b_n != 0$ $forall n in NN$. Sea $T_n$ definida como:
$ a_n T_n = b_n T_(n-1) + f_n, #h(2cm) T_0 = c. $

Obtenga una fórmula no recursiva para $T_n$.

3. Usando el método visto en clases, resuelva:

$ T_n = (T_(n-1)/T_(n-2))^4 dot 8^(n dot 2^n), #h(2cm) T_0 = 1, T_1 = 2. $

= Funciones generadoras

1. Considere la recurrencia definida para $n <= 0$:
$ a_(n+3) = 5a_(n+2) - 7a_(n+1) + 3a_n + 2^n, $
con $a_0 = 0$, $a_1 = 2$ y $a_2 = 5$.

Utilizando funciones generadoras, resuelva la recurrencia.

2. Cuente el número de palabras en ${0,1,2}^n$ tal que cada subpalabra maximal de ${0}^*$ tiene largo par.
