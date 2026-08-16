// # Glossary. Glossário.

#import "../components.typ": *


// ## Abbreviations. Abreviaturas.
// NBR 14724:2024 4.2.1.11

#let abbreviations_entries = (
  (
    key: "ibge",
    short: "IBGE",
    long: "Instituto Brasileiro de Geografia e Estatística",
    group: "Normatização",
  ),
  (
    key: "abnt",
    short: "ABNT",
    long: "Associação Brasileira de Normas Técnicas",
    group: "Normatização",
  ),
  (
    key: "nbr",
    short: "NBR",
    plural: "NBRs",
    long: "Norma Brasileira",
    longplural: "Normas Brasileiras",
    group: "Normatização",
  ),
  (
    key: "ia",
    short: "IA",
    long: "Inteligência Artificial",
    group: "Computação",
  ),
  (
    key: "bi",
    short: "BI",
    long: [#foreign_text[Business Intelligence]],
    description: "Em português, Inteligência de Negócios.",
    group: "Computação",
  ),
  (
    key: "mcts",
    short: "MCTS",
    long: "busca em árvore de Monte Carlo",
    group: "Computação",
  ),
  (
    key: "uct",
    short: "UCT",
    long: "limite superior de confiança aplicado a árvores",
    longplural: "limites superiores de confiança aplicados a árvores",
    custom: foreign_text[Upper Confidence bounds applied to Trees],
    group: "Computação",
  ),
  (
    key: "resnet",
    short: "ResNet",
    plural: "ResNets",
    long: "rede neural residual",
    longplural: "redes neurais residuais",
    group: "Computação",
  ),
)


// ## Glossary. Glossário.
// NBR 14724:2024 4.2.3.2

#let glossary_entries = (
  (
    key: "firewall",
    short: "firewall",
    description: "Dispositivo de segurança de rede que monitora e controla o tráfego de entrada e saída com base em regras de segurança predefinidas.",
    group: "Computação",
  ),
  (
    key: "aprendizado_maquina",
    short: [aprendizado de máquina],
    custom: foreign_text[machine learning],
    description: [Em inglês, #foreign_text[machine learning]. Área da @ia que desenvolve algoritmos capazes de aprender padrões a partir de dados sem programação explícita, melhorando seu desempenho através da experiência @geeksforgeeks:2025:machine_learning_algorithms.],
    group: "Computação",
  ),
  (
    key: "fitness",
    short: foreign_text[fitness],
    plural: foreign_text[fitnesses],
    custom: [avaliação],
    description: [Em português, avaliação. Métrica que quantifica a qualidade de uma solução em relação aos objetivos, atribuindo um valor numérico que orienta a tomada de decisão ou o processo de aprendizado.],
    group: "Computação",
  ),
  (
    key: "exploração",
    short: [exploração],
    plural: [explorações],
    custom: foreign_text[exploration],
    description: [Em inglês #foreign_text[exploration]. Componente do critério @uct na @mcts que prioriza nós pouco visitados, ampliando a busca e evitando convergir cedo demais @kocsis:2006:bandit_based_mcts_planning.],
    group: "Computação",
  ),
  (
    key: "aproveitamento",
    short: [aproveitamento],
    plural: [aproveitamentos],
    custom: [exploitation],
    description: [Em inglês, #foreign_text[exploitation]. Componente do critério @uct na @mcts que favorece nós com maior valor médio estimado, aproveitando recompensas já observadas para guiar a seleção @kocsis:2006:bandit_based_mcts_planning.],
    group: "Computação",
  ),
  (
    key: "rn",
    short: "rede neural",
    plural: "redes neurais",
    custom: foreign_text[neural network],
    description: [Em inglês, #foreign_text[neural network]. Modelo computacional composto por camadas de unidades interligadas que aprendem padrões em dados por meio de ajustes de pesos @li:2022:survey_convolutional_neural_networks.],
    group: "Computação",
  ),
  (
    key: "alphazero",
    short: foreign_text[AlphaZero],
    description: [Algoritmo de autoaprendizado por reforço que combina @mcts e @resnet:pl profundas para dominar jogos de tabuleiro, desenvolvido pelo laboratório Google DeepMind @silver:2018:general_reinforcement_learning_algorithm.],
    group: "Computação",
  ),
  (
    key: "casa",
    short: "casa",
    plural: "casas",
    custom: foreign_text[slot],
    description: [Em inglês, #foreign_text[slot]. Unidade discreta que compõe o tabuleiro e pode conter peças ou recursos.],
    group: "Jogos",
  ),
  (
    key: "estado",
    short: "estado",
    plural: "estados",
    custom: foreign_text[state],
    description: [Em inglês, #foreign_text[state]. Representação completa da situação do @jogo em um instante, incluindo o conteúdo das @casa:pl, os recursos, a @pontuacao dos @jogador:pl e demais condições vigentes.],
    group: "Jogos",
  ),
  (
    key: "jogo",
    short: "jogo",
    plural: "jogos",
    custom: foreign_text[game],
    description: [Em inglês, #foreign_text[game]. Sistema de regras que define objetivos, @jogador:pl, @movimento:pl e condições de vitória ou encerramento @suits:1967:what_is_a_game.],
    group: "Jogos",
  ),
  (
    key: "jogador",
    short: "jogador",
    plural: "jogadores",
    custom: foreign_text[player],
    description: [Em inglês, #foreign_text[player]. Participante que toma decisões e executa @movimento:pl conforme as regras do @jogo.],
    group: "Jogos",
  ),
  (
    key: "movimento",
    short: "movimento",
    plural: "movimentos",
    custom: foreign_text[move],
    description: [Em inglês, #foreign_text[move]. Ação tomada a partir de um @estado que altera as condições atuais, levando a um novo @estado.],
    group: "Jogos",
  ),
  (
    key: "partida",
    short: "partida",
    plural: "partidas",
    custom: foreign_text[match],
    description: [Em inglês, #foreign_text[match]. Sessão completa do @jogo, iniciando nas condições iniciais e terminando quando uma condição de fim é atingida.],
    group: "Jogos",
  ),
  (
    key: "pontuacao",
    short: "pontuação",
    plural: "pontuações",
    custom: foreign_text[score],
    description: [Em inglês, #foreign_text[score]. Valor que indica o desempenho de um @jogador segundo as regras do @jogo.],
    group: "Jogos",
  ),
)


// ## Symbols. Símbolos.
// NBR 14724:2024 4.2.1.12

#let symbols_entries = (
  (
    key: "emptyset",
    short: $#sym.emptyset$,
    long: "Conjunto vazio",
    description: "Conjunto que não contém nenhum elemento.",
  ),
)
