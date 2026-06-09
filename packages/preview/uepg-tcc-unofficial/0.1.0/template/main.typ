#import "@preview/uepg-tcc-unofficial:0.1.0": monografia, citacao-longa

#show: monografia.with(
  titulo: "TÍTULO DO TRABALHO DE CONCLUSÃO DE CURSO",
  autor: "NOME COMPLETO DO AUTOR",
  orientadores: (
    "Prof. Dr. Nome do Orientador",
    // "Prof. Dr. Nome do Coorientador",  // Descomente se houver coorientador
  ),
  nota-apresentacao: "Trabalho de Conclusão de Curso apresentado para obtenção do título de Bacharel em Engenharia de Software, Setor de Engenharias, Ciências Agrárias e de Tecnologia da Universidade Estadual de Ponta Grossa.",
  curso: "BACHARELADO EM ENGENHARIA DE SOFTWARE",
  departamento: "DEPARTAMENTO DE INFORMÁTICA",
  // setor: "SETOR DE ENGENHARIAS, CIÊNCIAS AGRÁRIAS E TECNOLOGIA",  // Padrão
  local: "PONTA GROSSA",
  ano: "2026",

  dedicatoria: [
    Dedico este trabalho a todos que contribuíram para minha formação acadêmica.
  ],

  agradecimentos: [
    Agradeço primeiramente à minha família pelo apoio incondicional durante toda a graduação.

    Ao meu orientador, Prof. Dr. Nome do Orientador, pela dedicação, paciência e orientação durante o desenvolvimento deste trabalho.

    Aos professores do Departamento de Informática da UEPG, pelos ensinamentos e contribuições ao longo do curso.

    Aos colegas de turma, pelas trocas de conhecimento e companheirismo.
  ],

  epigrafe: [
    "A única maneira de fazer um bom trabalho é amar o que você faz."

    --- Steve Jobs
  ],

  resumo: [
    Este trabalho apresenta uma análise sobre o tema proposto, abordando seus principais aspectos teóricos e práticos. Inicialmente, é realizada uma revisão bibliográfica dos conceitos fundamentais relacionados ao tema. Em seguida, são descritos os materiais e métodos utilizados para o desenvolvimento do trabalho. Os resultados obtidos são apresentados e discutidos à luz da literatura existente. Por fim, são apresentadas as conclusões e sugestões para trabalhos futuros. O resumo deve conter entre 150 e 500 palavras, em parágrafo único, espaçamento simples, sem recuo na primeira linha.
  ],
  palavras-chave: (
    "Palavra-chave 1",
    "Palavra-chave 2",
    "Palavra-chave 3",
    "Palavra-chave 4",
  ),

  abstract: [
    This work presents an analysis of the proposed topic, addressing its main theoretical and practical aspects. Initially, a bibliographic review of the fundamental concepts related to the topic is carried out. Next, the materials and methods used for the development of the work are described. The results obtained are presented and discussed in light of the existing literature. Finally, conclusions and suggestions for future work are presented. The abstract should contain between 150 and 500 words, in a single paragraph, single-spaced, without first-line indentation.
  ],
  keywords: (
    "Keyword 1",
    "Keyword 2",
    "Keyword 3",
    "Keyword 4",
  ),

  lista-abreviaturas: (
    ("ABNT", "Associação Brasileira de Normas Técnicas"),
    ("UEPG", "Universidade Estadual de Ponta Grossa"),
    ("TCC", "Trabalho de Conclusão de Curso"),
  ),

  // lista-ilustracoes: auto,  // Gera automaticamente se houver figuras
  // lista-quadros: auto,      // Gera automaticamente se houver quadros
  // lista-tabelas: auto,      // Gera automaticamente se houver tabelas
)

= Introdução

Este é um exemplo de documento formatado com a template `monografia-uepg`, que segue as normas da ABNT conforme o Guia de Normalização da Universidade Estadual de Ponta Grossa.

O primeiro parágrafo de cada seção possui recuo de 1,25 cm, assim como todos os demais parágrafos do texto. O espaçamento entre linhas é de 1,5 e o texto é justificado.

== Objetivos

=== Objetivo geral

Descrever o objetivo geral do trabalho de forma clara e concisa.

=== Objetivos específicos

Os objetivos específicos devem detalhar as etapas necessárias para atingir o objetivo geral.

= Referencial teórico

Esta seção apresenta os conceitos fundamentais necessários para a compreensão do trabalho. As citações devem seguir o padrão ABNT.

Exemplo de citação indireta: Segundo Silva (2020), os sistemas modernos oferecem vantagens significativas sobre métodos tradicionais.

Exemplo de citação direta curta: O autor afirma que "a tecnologia transformou significativamente os processos organizacionais" @exemplo1.

Exemplo de citação longa (mais de três linhas):

#citacao-longa[
  As citações longas devem ser destacadas com recuo de 4 cm da margem esquerda, com letra menor que a do texto (tamanho 10), sem aspas e com espaçamento simples. A citação longa deve conter mais de três linhas e seguir as normas estabelecidas pela ABNT NBR 10520 @exemplo2.
]

== Exemplo de quadro

Os quadros são utilizados para apresentar informações qualitativas e textuais, com bordas fechadas em todos os lados.

#figure(
  table(
    columns: (auto, auto),
    stroke: 1pt + black,
    inset: 10pt,
    align: (center, left),
    table.header(
      [*Categoria*], [*Descrição*],
    ),
    [Tipo A], [Descrição da primeira categoria com suas características principais.],
    [Tipo B], [Descrição da segunda categoria com suas características principais.],
    [Tipo C], [Descrição da terceira categoria com suas características principais.],
  ),
  caption: [Classificação dos tipos estudados],
  kind: "quadro",
  supplement: [Quadro],
) <quadro-exemplo>

O @quadro-exemplo apresenta a classificação utilizada neste trabalho.

= Metodologia

Nesta seção, descreva os materiais e métodos utilizados para o desenvolvimento do trabalho.

= Resultados e discussão

Apresente os resultados obtidos e discuta-os à luz da literatura existente.

= Conclusão

Apresente as conclusões do trabalho e sugestões para trabalhos futuros.

#bibliography("refs.bib", title: "REFERÊNCIAS", style: "associacao-brasileira-de-normas-tecnicas")
