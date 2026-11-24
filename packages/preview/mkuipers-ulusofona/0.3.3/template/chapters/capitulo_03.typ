#import "@preview/mkuipers-ulusofona:0.3.3": *

#chapter("Especificação e Modelação", l: "especificacao")

#guidance[
Identificar detalhadamente características da solução a produzir sobre a forma de requisitos, modelos e outros elementos que permitam perceber a estrutura e características da solução a desenvolver. Incluir nesta secção conteúdos desenvolvidos na UC de Engenharia de Software, falando dos #emph[epics];, #emph[features];, #emph[user stories];, #emph[technical user stories];, etc. As primeiras duas secções podem ser adequadas.
]

== Análise de Requisitos
#guidance[
Identificação detalhada de características da solução a produzir sobre a forma de requisitos.

Este levantamento não deve ser restringido ao âmbito do TFC nem aos requisitos efectivamente implementados durante o seu desenvolvimento. No relatório final, deve-se manter a enumeração original, com inclusão requisitos não implementados e cenários de continuidade do projecto em âmbito académico ou empresarial.

No relatório final dever-se-á manter a analise comparativa e avaliação de concretização das propostas realizadas na avaliação anterior. Neste sentido, o relatório deverá apresentar lista de requisitos propostos, indicando cumprimento, parcial ou integral, ou não implementação de cada um. Sempre que aplicável, também deverão ser indicados, justificadamente, requisitos modificados, retirados ou acrescentados. Se aplicável e em trabalhos realizados em parcerias com terceiros, dever-se-á indicar em particular alterações que resultem de orientações específicas dos parceiros
]

=== Enumeração de Requisitos
#guidance[
Lista geral de requisitos identificados para o problema em análise.

Deve indicar-se prioridade e impacto bem como classificação de tipo -- e.g. funcional, não-funcional, sistema.

Com o evoluir do trabalho, particularmente na entrega final, dever-se-á indicar ajustes efectuados aos requisitos ao longo do desenvolvimento do TFC e indicação de concretização -- p.e. implementação integral, parcial, substituição, cancelamento ou não realização

Estes requisitos deverão indicar critérios de aceitação, a validar em testes e que servirão de base para determinar o nível de concretização
]

===  Descrição detalhada dos requisitos principais
#guidance[
Para os requisitos de maior impacto deve ser apresentada descrição em detalhe onde se indique, entre outros, dependências, objectivos, critérios de aceitação e, se aplicável, processos de negócio, ligando a casos de uso da subsecção seguinte
]

=== Casos de Uso/#emph[User Stories] 
#guidance[
Representação de cenários de utilização real da solução proposta/desenvolvida, onde se apresente a exploração da solução por parte dos seus actores/utilizadores/#emph[stakeholders];.

A representação pode incluir casos de uso, processos ou outro formato pertinente contextualizar requisitos descritos nos pontos anteriores e para compreender o contexto de uso e exploração da solução
]

== Modelação
#guidance[
Apresentar diagrama de entidade-relação (obrigatório) com todas as tabelas da aplicação, com o máximo nível de detalhe que conseguirem. O modelo deve ser apresentado em formato normalizado na 3ª forma normal, contendo todas as colunas e respetivos tipos e restrições adequadas, nomeadamente chave e regras de integridade.

Apresentar outras modelações pertinentes para as tecnologias que sejam utilizadas no TFC: Modelo de Classes; Diagramas de Atividade, etc.
]

== Protótipos de Interface
#guidance[
Apresentar mapa aplicacional, que reflete os ecrãs da aplicação e a forma como se navega entre eles. Apresentar, de forma esquemática, os resultados esperados, o formato podendo ser diferente de acordo com a tipologia do TFC. Poderão incluir mockups, storyboards. Se desenvolvido, apresentar protótipo interativo. Apresentar representações mais relevantes para o projecto, deixando as restantes para um anexo.
]
