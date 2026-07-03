// Ficheiro de anexos
// Cada título de nível 1 (=) cria um novo anexo com letra automática (A, B, C, ...)
// Cada anexo começa numa página nova e é adicionado ao índice

= Tabela de Exemplo

Este é o conteúdo do Anexo A. Podes adicionar texto, imagens, tabelas, etc.

#figure(
  table(
    columns: 2,
    [*Item*], [*Valor*],
    [Exemplo 1], [100],
    [Exemplo 2], [200],
  ),
  caption: [Tabela de exemplo no Anexo A]
)

= Segundo Anexo

Este é o conteúdo do Anexo B. Cada novo título de nível 1 (=) cria automaticamente um novo anexo.

= Terceiro Anexo

Este é o conteúdo do Anexo C.
