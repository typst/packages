#import "@preview/epsi-thesis:0.1.0": project

// NOTA: Este template requer a fonte 'NewsGotT' para o estilo oficial da UMinho.
// Como as fontes não podem ser incluídas no package, deves descarregá-la em:
// https://www.ics.uminho.pt/pt/Comunicacao/Documents/NewsGotT.zip
// e fazer upload dos ficheiros .ttf para a pasta do teu projeto no Typst.

// --- CONFIGURAÇÃO DA TESE ---
#show: project((
  // IDENTIFICAÇÃO
  title: "Título Título Título Título Título Título Título Título Título Título Título Título",
  author: "Nome do Autor",
  
  // CURSO
  degree-type: "msc", // ou "phd"
  document-type: "Dissertação de Mestrado",
  degree-name: "Mestrado em X",
  school-id: "EP", // "EAAD", "EC", "ED", "EE", "EEG", "ELACH", "EM", "EP", "ESE", "I3Bs", "ICS", "IE"
  
  // ORIENTAÇÃO
  supervisors: ("Professor Doutor X", "Professora Doutora Y", "Professora Doutora Z","Professora Doutora W"),
  supervisor-gender: "M", // ou "F" para o caso se ser apenas um orientador
  
  // OUTROS
  year: 2026,
  month: "maio",
  language: "PT", // ou "EN"
  
  // PÁGINAS OPCIONAIS 
  include-acknowledgements: true,
  include-funding: true,
  include-abstract-pt: true, 
  include-acronyms: true,
  include-glossary: true,

  // REFERÊNCIAS
  include-bibliography: true, 
  bibliography-style: "ieee", // ou "apa", etc.
  bibliography-path: "bibliography.bib",
  
  // ARQUIVOS YAML (se necessário)
  acronyms-path: "acronyms.yml",
  glossary-path: "glossary.yml",
  
  // --- CONTEÚDOS DAS PÁGINAS ---

  copyright-content: [
  #image("assets/copyright/CCBY.png")

  *CC BY*
  
  https://creativecommons.org/licenses/by/4.0/

  \

  #image("assets/copyright/CCBYSA.png")

  *CC BY-SA*
  
  https://creativecommons.org/licenses/by-sa/4.0/

  \

  #image("assets/copyright/CCBYND.png")

  *CC BY-ND*
  
  https://creativecommons.org/licenses/by-nd/4.0/

  \


  #image("assets/copyright/CCBYNC.png")

  *CC BY-NC*
  
  https://creativecommons.org/licenses/by-nc/4.0/

  \

  #image("assets/copyright/CCBYNCSA.png")

  *CC BY-NC-SA*
  
  https://creativecommons.org/licenses/by-nc-sa/4.0/

  \

  #image("assets/copyright/CCBYNCND.png")

  *CC BY-NC-ND*
  
  https://creativecommons.org/licenses/by-nc-nd/4.0/

  // Escolhe a licença para a tua tese e apaga as restantes

    // Assinatura
  ],

  acknowledgements: [
    Agradeço aos meus orientadores pelo apoio constante...
  ],

  funding: [
    Este trabalho foi financiado por...
  ],

  integrity-content: [
     // Assinatura
  ],

  ai-tools-content: [
     // Assinatura
  ],

  // RESUMOS
  abstract-pt: [
    Este é o texto do resumo em português.
    Pode ter vários parágrafos.
  ],
  keywords-pt: ("Portugal", "Mundo"),

  abstract-en: [
    This is the abstract text in English.
    Multiple paragraphs allowed.
  ],
  keywords-en: ("Portugal", "World"),
  
  // CORPO DA TESE
  body: [
    = Demonstração de Funcionalidades (Guia Rápido)

== Inserir Imagens
Para inserir uma imagem, usamos a função `#figure`. O Typst trata da numeração automática.

#figure(
  image("images/example.png", width: 80%),
  caption: [Legenda da imagem explicativa.],
) <fig-exemplo>

Como podes ver na @fig-exemplo, a imagem fica centrada por padrão.

== Tabelas
As tabelas são muito intuitivas. Podes definir o número de colunas e o alinhamento.

#figure(
  table(
    columns: (auto, 1fr, 1fr),
    inset: 10pt,
    align: horizon,
    [*ID*], [*Ferramenta*], [*Utilidade*],
    [1], [Typst], [Escrita de relatórios],
    [2], [Python], [Análise de dados],
    [3], [Git], [Controlo de versões],
  ),
  caption: [Exemplo de uma tabela comparativa.],
) <tab-ferramentas>

== Equações Matemáticas
O Typst usa uma sintaxe parecida com LaTeX, mas sem os comandos complexos. Usa-se o símbolo `$`.

Equação na linha: $E = m c^2$.

Equação em bloco:
$ sum_(k=1)^n k = (n(n+1)) / 2 $

== Listas e Blocos de Código
Podes criar listas numeradas e blocos de código com destaque de sintaxe:

1. Primeiro passo
2. Segundo passo

```python
def saudacao(nome):
    print(f"Olá, {nome}!")
```

= Introdução

Este é o primeiro capítulo do relatório.

Os objetivos principais são:
- Objetivo 1: Estudar padrões de design @gamma1994
- Objetivo 2: Aplicar boas práticas de programação @dijkstra1968
- Objetivo 3: Utilizar tecnologias web modernas @mozilla2024

= Estado da Arte

Neste capítulo apresenta-se a revisão da literatura.

= Conclusões

Conclusões finais do trabalho.

  ],
  
  appendix: [
    #include "appendix.typ"
  ],
))


