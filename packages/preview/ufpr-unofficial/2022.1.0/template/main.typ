#import "@preview/ufpr-unofficial:2022.1.0": *

#show: template.with(
  // Obligatory parameters
  title: "Aplicação de Machine Learning para Classificação de Imagens de Satélite na Agricultura de Precisão",
  authors: ("Marina Silva Santos",),
  advisor: "Prof. Dr. Roberto Pereira Costa",
  city: "Curitiba",
  year: 2024,
  description: [
    Relatório técnico apresentado à disciplina de Metodologia Científica 
    do curso de Engenharia de Computação da Universidade Federal do Paraná, 
    como requisito parcial para aprovação na disciplina.
  ],
  references: bibliography("refs.bib"),
  // Optional parameters
  has-cover: true,
  glossary: (
    "Agricultura de Precisão", [Metodologia de produção agrícola que utiliza tecnologia para otimizar recursos e aumentar produtividade.],
    "Machine Learning", [Subárea da inteligência artificial que permite computadores aprenderem com dados sem serem explicitamente programados.],
    "Imagem de Satélite", [Representação digital de uma área da superfície terrestre capturada por sensores orbitais.],
  )
)

// !!! GENERATED WITH GITHUB COPILOT !!!
= Introdução

Este relatório apresenta uma proposta de aplicação de técnicas de aprendizado de máquina para classificação de imagens de satélite no contexto da agricultura de precisão. A motivação do estudo está na necessidade de melhorar a tomada de decisão no campo por meio de dados geoespaciais e modelos preditivos, reduzindo custos e aumentando a produtividade agrícola.

Além disso, o trabalho busca demonstrar como a integração entre sensoriamento remoto e métodos computacionais pode apoiar atividades como monitoramento de lavouras, identificação de padrões de uso do solo e detecção de áreas com maior risco de perda de rendimento.

= Desenvolvimento

No desenvolvimento, foi definido um fluxo de trabalho composto por três etapas principais: preparação dos dados, treinamento do modelo e avaliação dos resultados. Na etapa de preparação, as imagens de satélite foram organizadas e rotuladas conforme classes de interesse agronômico, garantindo consistência para o processo de aprendizagem.

Em seguida, realizou-se o treinamento de um classificador supervisionado, com ajuste de parâmetros e validação por amostragem. Para avaliação, foram analisadas métricas como acurácia e matriz de confusão, permitindo identificar o desempenho do modelo em diferentes classes e verificar limitações associadas à qualidade das imagens e ao desbalanceamento dos dados.

Por fim, os resultados foram interpretados sob a perspectiva da aplicação prática, considerando cenários reais de uso em propriedades rurais. A análise evidenciou que a abordagem tem potencial para apoiar o planejamento agrícola, desde que combinada com atualização periódica dos dados e calibração contínua do modelo.

= Conclusão

Conclui-se que a aplicação de aprendizado de máquina em imagens de satélite constitui uma alternativa viável para apoiar a agricultura de precisão, contribuindo para decisões mais eficientes e baseadas em evidências. O estudo também reforça que a qualidade dos dados de entrada é fator determinante para o desempenho final do sistema.

Como trabalhos futuros, recomenda-se ampliar a base de dados, comparar diferentes arquiteturas de modelos e incorporar variáveis complementares, como informações climáticas e de solo, para aumentar a robustez das previsões e a utilidade do método em ambientes produtivos diversos.
